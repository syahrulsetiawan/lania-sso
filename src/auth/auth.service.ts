import {
  Injectable,
  UnauthorizedException,
  BadRequestException,
  Logger,
  ConflictException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../prisma/prisma.service';
import { AuditService } from '../audit/audit.service';
import { EmailService } from './email.service';
import * as bcrypt from 'bcryptjs';
import * as crypto from 'crypto';
import { v4 as uuidv4 } from 'uuid';
import type { FastifyRequest } from 'fastify';
import {
  LoginDto,
  LoginResponseDto,
  RefreshTokenDto,
  RefreshTokenResponseDto,
  ForgotPasswordDto,
  ResetPasswordDto,
  PasswordResetResponseDto,
  LogoutResponseDto,
  LogoutAllResponseDto,
  UserMeResponseDto,
  SendEmailVerificationDto,
  VerifyEmailDto,
  SwitchTenantDto,
  SwitchTenantResponseDto,
  ToggleUserLockedResponseDto,
  UserConfigDto,
  UserConfigResponseDto,
} from './dto';

/**
 * Authentication Service
 * Handles user authentication, token management, and password reset
 */
@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);
  private readonly ACCESS_TOKEN_EXPIRATION = '1h'; // 1 hour
  private readonly REFRESH_TOKEN_EXPIRATION_DAYS = 7; // 7 days

  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
    private readonly auditService: AuditService,
    private readonly emailService: EmailService,
  ) {}

  /**
   * User login with username/email and password
   */
  async login(
    loginDto: LoginDto,
    request: FastifyRequest,
  ): Promise<LoginResponseDto> {
    const {
      usernameOrEmail,
      password,
      deviceName,
      latitude,
      longitude,
      rememberMe,
    } = loginDto;
    const ipAddress = this.getIpAddress(request);
    const userAgent = request.headers['user-agent'] || 'Unknown';

    try {
      // Find user by username or email
      const user = await this.prisma.user.findFirst({
        where: {
          OR: [{ username: usernameOrEmail }, { email: usernameOrEmail }],
          deletedAt: null,
        },
        include: {
          tenants: {
            include: {
              tenant: true,
            },
          },
        },
      });

      // Check if user exists
      if (!user) {
        await this.handleFailedLogin(
          null,
          usernameOrEmail,
          ipAddress,
          userAgent,
          request,
        );
        throw new UnauthorizedException({
          message: 'Invalid credentials',
          reason: 'login.invalid_credentials',
        });
      }

      // Check if account is locked
      if (user.isLocked) {
        await this.auditService.log({
          userType: 'User',
          userId: user.id,
          event: 'LOGIN_ATTEMPT_LOCKED_ACCOUNT',
          auditableTable: 'users',
          auditableId: user.id,
          url: request.url,
          ipAddress,
          userAgent,
          tags: 'security,authentication',
        });
        throw new UnauthorizedException({
          message: 'Your account has been locked. Please contact support.',
          reason: 'login.account_locked',
        });
      }

      // Check if account is temporarily locked
      if (
        user.temporaryLockUntil &&
        new Date(user.temporaryLockUntil) > new Date()
      ) {
        const minutesRemaining = Math.ceil(
          (new Date(user.temporaryLockUntil).getTime() - Date.now()) / 60000,
        );

        await this.auditService.log({
          userType: 'User',
          userId: user.id,
          event: 'LOGIN_ATTEMPT_TEMPORARY_LOCK',
          auditableTable: 'users',
          auditableId: user.id,
          url: request.url,
          ipAddress,
          userAgent,
          payload: { lockedUntil: user.temporaryLockUntil, minutesRemaining },
          tags: 'security,authentication',
        });

        throw new UnauthorizedException({
          message: `Account temporarily locked. Try again in ${minutesRemaining} minute(s).`,
          reason: 'login.temporary_locked',
          lockedUntil: user.temporaryLockUntil,
          minutesRemaining,
        });
      }

      // Reset temporary lock if time has passed
      if (
        user.temporaryLockUntil &&
        new Date(user.temporaryLockUntil) <= new Date()
      ) {
        await this.prisma.user.update({
          where: { id: user.id },
          data: {
            temporaryLockUntil: null,
            failedLoginCounter: 0,
          },
        });
      }

      // Check if user has at least one active tenant relationship
      const hasActiveTenantRelation = user.tenants.some(
        (tenantHasUser) => tenantHasUser.isActive === true,
      );

      if (!hasActiveTenantRelation) {
        await this.auditService.log({
          userType: 'User',
          userId: user.id,
          event: 'LOGIN_ATTEMPT_NO_ACTIVE_TENANT',
          auditableTable: 'users',
          auditableId: user.id,
          url: request.url,
          ipAddress,
          userAgent,
          tags: 'security,authentication',
        });
        throw new UnauthorizedException({
          message: 'Your account is not associated with any active tenant.',
          reason: 'login.no_active_tenant',
        });
      }

      // Check if at least one tenant is active and not revoked
      const hasValidTenant = user.tenants.some(
        (tenantHasUser) =>
          tenantHasUser.isActive === true &&
          tenantHasUser.tenant.isActive === true &&
          tenantHasUser.tenant.revokedAt === null,
      );

      if (!hasValidTenant) {
        await this.auditService.log({
          userType: 'User',
          userId: user.id,
          event: 'LOGIN_ATTEMPT_INVALID_TENANT',
          auditableTable: 'users',
          auditableId: user.id,
          url: request.url,
          ipAddress,
          userAgent,
          tags: 'security,authentication',
        });
        throw new UnauthorizedException({
          message:
            'All your tenants are inactive or revoked. Please contact support.',
          reason: 'login.tenant_inactive_or_revoked',
        });
      }

      // Check if force logout is active
      if (user.forceLogoutAt && new Date(user.forceLogoutAt) > new Date()) {
        await this.auditService.log({
          userType: 'User',
          userId: user.id,
          event: 'LOGIN_ATTEMPT_FORCE_LOGOUT',
          auditableTable: 'users',
          auditableId: user.id,
          url: request.url,
          ipAddress,
          userAgent,
          tags: 'security,authentication',
        });
        throw new UnauthorizedException({
          message: 'Your account is temporarily suspended.',
          reason: 'login.account_suspended',
        });
      }

      // Verify password
      const isPasswordValid = await bcrypt.compare(password, user.password);
      if (!isPasswordValid) {
        await this.handleFailedLogin(
          user.id,
          usernameOrEmail,
          ipAddress,
          userAgent,
          request,
        );

        // Increment failed login counter
        const updatedUser = await this.prisma.user.update({
          where: { id: user.id },
          data: { failedLoginCounter: { increment: 1 } },
        });

        const failedAttempts = updatedUser.failedLoginCounter;

        // Progressive lockout logic:
        // 1-5 attempts: 5 minute lock
        // 6-10 attempts: 15 minute lock
        // 11+ attempts: Permanent lock + force logout for 24 hours

        if (failedAttempts >= 11) {
          // 3rd set of 5 attempts (11+): Permanent lock + force logout
          const forceLogoutUntil = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24 hours

          await this.prisma.user.update({
            where: { id: user.id },
            data: {
              isLocked: true,
              lockedAt: new Date(),
              forceLogoutAt: forceLogoutUntil,
              temporaryLockUntil: null,
            },
          });

          // Revoke all sessions
          await this.prisma.session.updateMany({
            where: { userId: user.id },
            data: { revokedAt: new Date() },
          });

          await this.auditService.log({
            userType: 'User',
            userId: user.id,
            event: 'ACCOUNT_PERMANENTLY_LOCKED',
            auditableTable: 'users',
            auditableId: user.id,
            url: request.url,
            ipAddress,
            userAgent,
            payload: {
              failedAttempts,
              forceLogoutUntil,
              reason: 'login.15_failed_attempts',
            },
            tags: 'security,account_locked,force_logout',
          });

          throw new UnauthorizedException({
            message:
              'Account locked permanently due to too many failed login attempts. Please contact support.',
            reason: 'account_permanently_locked',
            failedAttempts,
          });
        } else if (failedAttempts >= 6 && failedAttempts <= 10) {
          // 2nd set of 5 attempts (6-10): 15 minute lock
          const lockUntil = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes

          await this.prisma.user.update({
            where: { id: user.id },
            data: {
              temporaryLockUntil: lockUntil,
            },
          });

          await this.auditService.log({
            userType: 'User',
            userId: user.id,
            event: 'ACCOUNT_TEMPORARY_LOCK_15MIN',
            auditableTable: 'users',
            auditableId: user.id,
            url: request.url,
            ipAddress,
            userAgent,
            payload: {
              failedAttempts,
              lockedUntil: lockUntil,
              lockDuration: '15_minutes',
            },
            tags: 'security,temporary_lock',
          });

          throw new UnauthorizedException({
            message:
              'Account temporarily locked for 15 minutes due to multiple failed login attempts.',
            reason: 'login.temporary_locked_15min',
            lockedUntil: lockUntil,
            failedAttempts,
            minutesRemaining: 15,
          });
        } else if (failedAttempts >= 1 && failedAttempts <= 5) {
          // 1st set of 5 attempts (1-5): 5 minute lock
          const lockUntil = new Date(Date.now() + 5 * 60 * 1000); // 5 minutes

          await this.prisma.user.update({
            where: { id: user.id },
            data: {
              temporaryLockUntil: lockUntil,
            },
          });

          await this.auditService.log({
            userType: 'User',
            userId: user.id,
            event: 'ACCOUNT_TEMPORARY_LOCK_5MIN',
            auditableTable: 'users',
            auditableId: user.id,
            url: request.url,
            ipAddress,
            userAgent,
            payload: {
              failedAttempts,
              lockedUntil: lockUntil,
              lockDuration: '5_minutes',
            },
            tags: 'security,temporary_lock',
          });

          throw new UnauthorizedException({
            message: `Invalid credentials. Account temporarily locked for 5 minutes. (Attempt ${failedAttempts}/5)`,
            reason: 'login.temporary_locked_5min',
            lockedUntil: lockUntil,
            failedAttempts,
            minutesRemaining: 5,
          });
        }

        throw new UnauthorizedException({
          message: 'Invalid credentials',
          reason: 'login.invalid_credentials',
        });
      }

      // Generate remember token if requested
      let rememberToken: string | null = null;
      if (rememberMe) {
        rememberToken = crypto.randomBytes(32).toString('hex');
        await this.prisma.user.update({
          where: { id: user.id },
          data: { rememberToken },
        });
      }

      // Set default lastTenantId and lastServiceKey if empty
      let updatedLastTenantId = user.lastTenantId;
      let updatedLastServiceKey = user.lastServiceKey;

      if (!user.lastTenantId) {
        // Get first tenant relation
        const firstTenant = user.tenants.find((t) => t.isActive);
        if (firstTenant) {
          updatedLastTenantId = firstTenant.tenantId;

          // Get first service for this tenant
          if (!user.lastServiceKey) {
            const tenantServices = await this.prisma.tenantHasService.findFirst(
              {
                where: { tenantId: firstTenant.tenantId },
                select: { serviceKey: true },
              },
            );
            if (tenantServices) {
              updatedLastServiceKey = tenantServices.serviceKey;
            }
          }
        }
      }

      // Reset failed login counter on successful login
      await this.prisma.user.update({
        where: { id: user.id },
        data: {
          failedLoginCounter: 0,
          temporaryLockUntil: null,
          lastLoginAt: new Date(),
          lastLoginIp: ipAddress,
          lastTenantId: updatedLastTenantId,
          lastServiceKey: updatedLastServiceKey,
        },
      });

      // Create session
      const sessionId = uuidv4();
      await this.prisma.session.create({
        data: {
          id: sessionId,
          userId: user.id,
          ipAddress,
          userAgent,
          deviceName: deviceName || this.extractDeviceName(userAgent),
          latitude,
          longitude,
          payload: JSON.stringify({
            loginMethod: 'password',
            usernameOrEmail,
          }),
          lastActivity: new Date(),
        },
      });

      // Generate tokens (JWT only contains session_id)
      const accessToken = await this.generateAccessToken(sessionId);
      const refreshToken = await this.generateRefreshToken(
        user.id,
        sessionId,
        ipAddress,
        userAgent,
      );

      // Log successful login
      await this.auditService.logUserLogin(request, user.id);

      this.logger.log(
        `User ${user.username} (${user.id}) logged in successfully from ${ipAddress}`,
      );

      return {
        accessToken,
        refreshToken,
        expiresIn: 3600, // 1 hour in seconds
        tokenType: 'Bearer',
        rememberToken: rememberMe ? rememberToken : undefined,
        user: {
          id: user.id,
          name: user.name,
          username: user.username,
          email: user.email,
          phone: user.phone,
          profilePhotoPath: user.profilePhotoPath,
          lastTenantId: updatedLastTenantId,
          lastServiceKey: updatedLastServiceKey,
        },
      };
    } catch (error) {
      if (
        error instanceof UnauthorizedException ||
        error instanceof BadRequestException
      ) {
        throw error;
      }
      this.logger.error('Login error:', error);
      throw new BadRequestException('An error occurred during login');
    }
  }

  /**
   * Refresh access token using refresh token
   */
  async refresh(
    refreshTokenDto: RefreshTokenDto,
    request: FastifyRequest,
  ): Promise<RefreshTokenResponseDto> {
    const { refreshToken } = refreshTokenDto;
    const ipAddress = this.getIpAddress(request);
    const userAgent = request.headers['user-agent'] || 'Unknown';

    try {
      // Hash the refresh token to find it in database
      const tokenHash = this.hashToken(refreshToken);

      // Find refresh token
      const storedToken = await this.prisma.refreshToken.findUnique({
        where: { tokenHash },
        include: {
          user: true,
          session: true,
        },
      });

      if (!storedToken) {
        throw new UnauthorizedException({
          message: 'Invalid refresh token',
          reason: 'refreshToken.invalid_refresh_token',
        });
      }

      // Check if token is revoked
      if (storedToken.revoked) {
        await this.auditService.log({
          userType: 'User',
          userId: storedToken.userId,
          event: 'REFRESH_TOKEN_REVOKED',
          auditableTable: 'refresh_tokens',
          auditableId: storedToken.id,
          url: request.url,
          ipAddress,
          userAgent,
          tags: 'security,token_revoked',
        });
        throw new UnauthorizedException({
          message: 'Refresh token has been revoked',
          reason: 'refreshToken.refresh_token_revoked',
        });
      }

      // Check if token is expired
      if (new Date() > storedToken.expiresAt) {
        await this.prisma.refreshToken.update({
          where: { id: storedToken.id },
          data: { revoked: true, revokedAt: new Date() },
        });
        throw new UnauthorizedException({
          message: 'Refresh token has expired',
          reason: 'refreshToken.refresh_token_expired',
        });
      }

      // Check if session is still active
      if (storedToken.session.revokedAt) {
        throw new UnauthorizedException({
          message: 'Session has been terminated',
          reason: 'refreshToken.session_terminated',
        });
      }

      // Revoke old refresh token (token rotation)
      await this.prisma.refreshToken.update({
        where: { id: storedToken.id },
        data: { revoked: true, revokedAt: new Date() },
      });

      // Generate new tokens (JWT only contains session_id)
      const newAccessToken = await this.generateAccessToken(
        storedToken.sessionId,
      );
      const newRefreshToken = await this.generateRefreshToken(
        storedToken.user.id,
        storedToken.sessionId,
        ipAddress,
        userAgent,
      );

      // Update session last activity
      await this.prisma.session.update({
        where: { id: storedToken.sessionId },
        data: { lastActivity: new Date() },
      });

      // Log token refresh
      await this.auditService.log({
        userType: 'User',
        userId: storedToken.userId,
        event: 'TOKEN_REFRESHED',
        auditableTable: 'refresh_tokens',
        auditableId: storedToken.id,
        url: request.url,
        ipAddress,
        userAgent,
        tags: 'authentication,token_refresh',
      });

      this.logger.log(`User ${storedToken.user.username} refreshed token`);

      return {
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
        expiresIn: 3600, // 1 hour in seconds
        tokenType: 'Bearer',
      };
    } catch (error) {
      if (error instanceof UnauthorizedException) {
        throw error;
      }
      this.logger.error('Token refresh error:', error);
      throw new BadRequestException('An error occurred during token refresh');
    }
  }

  /**
   * Forgot password - Send reset email
   */
  async forgotPassword(
    forgotPasswordDto: ForgotPasswordDto,
    request: FastifyRequest,
  ): Promise<PasswordResetResponseDto> {
    const { email } = forgotPasswordDto;
    const ipAddress = this.getIpAddress(request);
    const userAgent = request.headers['user-agent'] || 'Unknown';

    try {
      // Find user by email
      const user = await this.prisma.user.findUnique({
        where: { email, deletedAt: null },
      });

      // Always return success to prevent email enumeration
      if (!user) {
        this.logger.warn(
          `Password reset requested for non-existent email: ${email}`,
        );
        return {
          message: 'If the email exists, a password reset link has been sent',
        };
      }

      // Generate reset token
      const resetToken = crypto.randomBytes(32).toString('hex');
      const expirationMinutes = this.configService.get<number>(
        'PASSWORD_RESET_EXPIRATION_MINUTES',
        60,
      );
      const expiresAt = new Date(Date.now() + expirationMinutes * 60 * 1000);

      // Store reset token (upsert: delete old token if exists)
      await this.prisma.passwordResetToken.upsert({
        where: { email },
        create: {
          email,
          token: resetToken,
          expiresAt,
          createdAt: new Date(),
        },
        update: {
          token: resetToken,
          expiresAt,
          createdAt: new Date(),
        },
      });

      // Send password reset email
      await this.emailService.sendPasswordResetEmail(
        email,
        resetToken,
        user.name,
      );

      // Log password reset request
      await this.auditService.log({
        userType: 'User',
        userId: user.id,
        event: 'PASSWORD_RESET_REQUESTED',
        auditableTable: 'users',
        auditableId: user.id,
        url: request.url,
        ipAddress,
        userAgent,
        tags: 'security,password_reset',
      });

      this.logger.log(`Password reset requested for ${email}`);

      return {
        message: 'If the email exists, a password reset link has been sent',
      };
    } catch (error) {
      this.logger.error('Forgot password error:', error);
      throw new BadRequestException(
        'An error occurred while processing your request',
      );
    }
  }

  /**
   * Reset password with token
   */
  async resetPassword(
    resetPasswordDto: ResetPasswordDto,
    request: FastifyRequest,
  ): Promise<PasswordResetResponseDto> {
    const { email, token, password, passwordConfirmation } = resetPasswordDto;
    const ipAddress = this.getIpAddress(request);
    const userAgent = request.headers['user-agent'] || 'Unknown';

    try {
      // Check if passwords match
      if (password !== passwordConfirmation) {
        throw new BadRequestException({
          message: 'Passwords do not match',
          reason: 'resetPassword.password_mismatch',
        });
      }

      // Find reset token
      const resetToken = await this.prisma.passwordResetToken.findUnique({
        where: { email },
      });

      if (!resetToken || resetToken.token !== token) {
        throw new BadRequestException({
          message: 'Invalid or expired reset token',
          reason: 'resetPassword.invalid_reset_token',
        });
      }

      // Check if token is expired
      if (new Date() > resetToken.expiresAt) {
        await this.prisma.passwordResetToken.delete({ where: { email } });
        throw new BadRequestException({
          message: 'Reset token has expired',
          reason: 'resetPassword.reset_token_expired',
        });
      }

      // Find user
      const user = await this.prisma.user.findUnique({
        where: { email, deletedAt: null },
      });

      if (!user) {
        throw new BadRequestException({
          message: 'User not found',
          reason: 'resetPassword.user_not_found',
        });
      }

      // Hash new password
      const hashedPassword = await bcrypt.hash(password, 10);

      // Update user password
      await this.prisma.user.update({
        where: { id: user.id },
        data: {
          password: hashedPassword,
          updatedAt: new Date(),
        },
      });

      // Delete reset token
      await this.prisma.passwordResetToken.delete({ where: { email } });

      // Revoke all sessions and refresh tokens (force logout from all devices)
      await this.prisma.session.updateMany({
        where: { userId: user.id },
        data: { revokedAt: new Date() },
      });

      await this.prisma.refreshToken.updateMany({
        where: { userId: user.id },
        data: { revoked: true, revokedAt: new Date() },
      });

      // Log password change
      await this.auditService.logPasswordChange(request, user.id);

      this.logger.log(`Password reset successful for ${email}`);

      return {
        message:
          'Password has been reset successfully. Please login with your new password.',
      };
    } catch (error) {
      if (error instanceof BadRequestException) {
        throw error;
      }
      this.logger.error('Reset password error:', error);
      throw new BadRequestException(
        'An error occurred while resetting password',
      );
    }
  }

  /**
   * Logout - Revoke current session
   */
  async logout(
    userId: string,
    request: FastifyRequest,
  ): Promise<LogoutResponseDto> {
    const ipAddress = this.getIpAddress(request);
    const userAgent = request.headers['user-agent'] || 'Unknown';

    try {
      // Get current session from JWT token
      const authHeader = request.headers.authorization;
      if (!authHeader) {
        throw new UnauthorizedException({
          message: 'No authorization header',
          reason: 'logout.no_authorization_header',
        });
      }

      const token = authHeader.replace('Bearer ', '');
      const decoded = this.jwtService.verify(token);
      const sessionId = decoded.sessionId;

      if (sessionId) {
        // Revoke session
        await this.prisma.session.update({
          where: { id: sessionId },
          data: { revokedAt: new Date() },
        });

        // Revoke all refresh tokens for this session
        await this.prisma.refreshToken.updateMany({
          where: { sessionId },
          data: { revoked: true, revokedAt: new Date() },
        });
      }

      // Log logout
      await this.auditService.logUserLogout(request, userId);

      this.logger.log(`User ${userId} logged out`);

      return {
        message: 'Successfully logged out',
      };
    } catch (error) {
      if (error instanceof UnauthorizedException) {
        throw error;
      }
      this.logger.error('Logout error:', error);
      throw new BadRequestException('An error occurred during logout');
    }
  }

  /**
   * Logout from all devices - Revoke all sessions
   */
  async logoutAll(
    userId: string,
    request: FastifyRequest,
  ): Promise<LogoutAllResponseDto> {
    const ipAddress = this.getIpAddress(request);
    const userAgent = request.headers['user-agent'] || 'Unknown';

    try {
      // Count active sessions
      const activeSessions = await this.prisma.session.count({
        where: {
          userId,
          revokedAt: null,
        },
      });

      // Revoke all sessions
      await this.prisma.session.updateMany({
        where: { userId },
        data: { revokedAt: new Date() },
      });

      // Revoke all refresh tokens
      await this.prisma.refreshToken.updateMany({
        where: { userId },
        data: { revoked: true, revokedAt: new Date() },
      });

      // Log logout all
      await this.auditService.log({
        userType: 'User',
        userId,
        event: 'LOGOUT_ALL_DEVICES',
        auditableTable: 'users',
        auditableId: userId,
        url: request.url,
        ipAddress,
        userAgent,
        payload: { sessionsTerminated: activeSessions },
        tags: 'security,logout_all',
      });

      this.logger.log(
        `User ${userId} logged out from all devices (${activeSessions} sessions)`,
      );

      return {
        message: 'Successfully logged out from all devices',
        sessionsTerminated: activeSessions,
      };
    } catch (error) {
      this.logger.error('Logout all error:', error);
      throw new BadRequestException('An error occurred during logout');
    }
  }

  /**
   * Get current user profile with configs and tenants
   */
  async getMe(userId: string): Promise<UserMeResponseDto> {
    try {
      const user = await this.prisma.user.findUnique({
        where: { id: userId, deletedAt: null },
        include: {
          userConfigs: {
            select: {
              id: true,
              configKey: true,
              configValue: true,
            },
          },
          tenants: {
            where: { isActive: true },
            select: {
              tenantId: true,
              isActive: true,
              isOwner: true,
              tenant: {
                select: {
                  id: true,
                  name: true,
                  code: true,
                  logoPath: true,
                  status: true,
                  isActive: true,
                  // configs: {
                  //   select: {
                  //     id: true,
                  //     configKey: true,
                  //     configValue: true,
                  //     configType: true,
                  //   },
                  // },
                  // services: {
                  //   select: {
                  //     serviceKey: true,
                  //     service: {
                  //       select: {
                  //         key: true,
                  //         name: true,
                  //         description: true,
                  //         icon: true,
                  //         isActive: true,
                  //       },
                  //     },
                  //   },
                  // },
                },
              },
            },
          },
        },
      });

      if (!user) {
        throw new UnauthorizedException({
          message: 'User not found',
          reason: 'getMe.user_not_found',
        });
      }

      // Get detailed current tenant if lastTenantId exists
      let detailCurrentTenant: any = null;
      if (user.lastTenantId) {
        const currentTenant = await this.prisma.tenant.findUnique({
          where: { id: user.lastTenantId },
          include: {
            services: {
              include: {
                service: {
                  select: {
                    key: true,
                    name: true,
                    description: true,
                    icon: true,
                    isActive: true,
                  },
                },
              },
            },
            configs: {
              select: {
                id: true,
                configKey: true,
                configValue: true,
                configType: true,
              },
            },
            licenses: {
              include: {
                coreLicense: {
                  select: {
                    key: true,
                    name: true,
                    description: true,
                    defaultValue: true,
                  },
                },
              },
            },
          },
        });

        if (currentTenant) {
          detailCurrentTenant = currentTenant;
        }
      }

      // Format user configs into structured object
      const userConfig = {
        rtl: false,
        language: 'id',
        content_width: 'full',
        dark_mode: 'by_system',
        email_notifications: true,
        menu_layout: 'vertical',
      };

      // Map database configs to structured format
      user.userConfigs.forEach((config) => {
        const key = config.configKey;
        if (key in userConfig) {
          // Parse boolean values
          if (key === 'rtl' || key === 'email_notifications') {
            userConfig[key] =
              config.configValue === 'true' || config.configValue === '1';
          } else {
            userConfig[key] = config.configValue || userConfig[key];
          }
        }
      });

      // Remove password and userConfigs from response
      const { password, userConfigs, ...userWithoutPassword } = user;

      return {
        ...userWithoutPassword,
        user_config: userConfig,
        detailCurrentTenant,
      } as any;
    } catch (error) {
      if (error instanceof UnauthorizedException) {
        throw error;
      }
      this.logger.error('Get user profile error:', error);
      throw new BadRequestException(
        'An error occurred while fetching user profile',
      );
    }
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /**
   * Generate JWT access token (1 hour expiration)
   * JWT only contains session_id for security - user data fetched from session on each request
   */
  private async generateAccessToken(sessionId: string): Promise<string> {
    const payload = {
      session_id: sessionId,
      type: 'access',
    };

    return this.jwtService.sign(payload, {
      secret: this.configService.get('JWT_SECRET'),
      expiresIn: this.ACCESS_TOKEN_EXPIRATION,
    });
  }

  /**
   * Generate refresh token (7 days expiration)
   */
  private async generateRefreshToken(
    userId: string,
    sessionId: string,
    ipAddress: string,
    userAgent: string,
  ): Promise<string> {
    const token = crypto.randomBytes(64).toString('hex');
    const tokenHash = this.hashToken(token);
    const expiresAt = new Date(
      Date.now() + this.REFRESH_TOKEN_EXPIRATION_DAYS * 24 * 60 * 60 * 1000,
    );

    await this.prisma.refreshToken.create({
      data: {
        id: uuidv4(),
        userId,
        sessionId,
        tokenHash,
        expiresAt,
        createdAt: new Date(),
      },
    });

    return token;
  }

  /**
   * Hash token using SHA-256
   */
  private hashToken(token: string): string {
    return crypto.createHash('sha256').update(token).digest('hex');
  }

  /**
   * Handle failed login attempt
   */
  private async handleFailedLogin(
    userId: string | null,
    usernameOrEmail: string,
    ipAddress: string,
    userAgent: string,
    request: FastifyRequest,
  ): Promise<void> {
    try {
      await this.prisma.failedLoginAttempt.create({
        data: {
          id: uuidv4(),
          userId,
          ipAddress,
          userAgent,
          payload: JSON.stringify({
            usernameOrEmail,
            url: request.url,
            method: request.method,
          }),
          attemptedAt: new Date(),
        },
      });

      await this.auditService.logFailedLogin(request, usernameOrEmail);
    } catch (error) {
      this.logger.error('Error logging failed login attempt:', error);
    }
  }

  /**
   * Extract device name from user agent
   */
  private extractDeviceName(userAgent: string): string {
    if (userAgent.includes('Windows')) return 'Windows PC';
    if (userAgent.includes('Mac')) return 'Mac';
    if (userAgent.includes('Linux')) return 'Linux PC';
    if (userAgent.includes('Android')) return 'Android Device';
    if (userAgent.includes('iPhone')) return 'iPhone';
    if (userAgent.includes('iPad')) return 'iPad';
    return 'Unknown Device';
  }

  /**
   * Get IP address from request
   */
  private getIpAddress(request: FastifyRequest): string {
    return (
      (request.headers['x-forwarded-for'] as string)?.split(',')[0] ||
      (request.headers['x-real-ip'] as string) ||
      request.ip ||
      'unknown'
    );
  }

  /**
   * Send email verification link
   */
  async sendEmailVerification(
    email: string,
    request: FastifyRequest,
  ): Promise<{ message: string }> {
    // Check if user exists with this email
    const user = await this.prisma.user.findUnique({
      where: { email },
      select: { id: true, email: true, emailVerifiedAt: true, name: true },
    });

    if (!user) {
      throw new BadRequestException({
        message: 'Email not found',
        reason: 'sendEmailVerification.email_not_found',
      });
    }

    if (user.emailVerifiedAt) {
      throw new BadRequestException({
        message: 'Email already verified',
        reason: 'sendEmailVerification.email_already_verified',
      });
    }

    // Generate verification token
    const token = crypto.randomBytes(32).toString('hex');
    const expiresAt = new Date();
    expiresAt.setHours(expiresAt.getHours() + 1); // 1 hour expiration

    // Upsert token (replace if exists)
    await this.prisma.emailVerificationToken.upsert({
      where: { email },
      update: {
        token,
        expiresAt,
        createdAt: new Date(),
      },
      create: {
        email,
        token,
        expiresAt,
      },
    });

    // Send verification email
    await this.emailService.sendEmailVerification(user.name, email, token);

    // Audit log
    await this.auditService.logFromRequest(request, {
      userType: 'User',
      userId: user.id,
      event: 'send_email_verification',
      auditableTable: 'email_verification_tokens',
      auditableId: email,
      newValues: { email, expiresAt },
      tags: 'email,verification',
    });

    return {
      message: 'Verification email sent successfully',
    };
  }

  /**
   * Verify email with token
   */
  async verifyEmail(
    email: string,
    token: string,
    request: FastifyRequest,
  ): Promise<{ message: string }> {
    // Find verification token
    const verificationToken =
      await this.prisma.emailVerificationToken.findUnique({
        where: { email },
      });

    if (!verificationToken) {
      throw new BadRequestException({
        message: 'Invalid verification token',
        reason: 'verifyEmail.invalid_verification_token',
      });
    }

    if (verificationToken.token !== token) {
      throw new BadRequestException({
        message: 'Invalid verification token',
        reason: 'verifyEmail.invalid_verification_token',
      });
    }

    if (new Date() > verificationToken.expiresAt) {
      throw new BadRequestException({
        message: 'Verification token has expired',
        reason: 'verification_token_expired',
      });
    }

    // Update user email_verified_at
    const user = await this.prisma.user.update({
      where: { email },
      data: { emailVerifiedAt: new Date() },
      select: { id: true, email: true, name: true },
    });

    // Delete verification token
    await this.prisma.emailVerificationToken.delete({
      where: { email },
    });

    // Audit log
    await this.auditService.logFromRequest(request, {
      userType: 'User',
      userId: user.id,
      event: 'email_verified',
      auditableTable: 'users',
      auditableId: user.id,
      newValues: { email: user.email, verifiedAt: new Date() },
      tags: 'email,verification,success',
    });

    return {
      message: 'Email verified successfully',
    };
  }

  /**
   * Switch user to different tenant
   */
  async switchTenant(
    userId: string,
    tenantId: string,
    request: FastifyRequest,
  ): Promise<{
    message: string;
    tenant: any;
  }> {
    // Verify user has access to target tenant
    const tenantHasUser = await this.prisma.tenantHasUser.findFirst({
      where: {
        userId,
        tenantId,
      },
      select: {
        userId: true,
        tenantId: true,
        isActive: true,
        isOwner: true,
      },
    });

    if (!tenantHasUser) {
      throw new BadRequestException({
        message: 'You do not have access to this tenant',
        reason: 'switchTenant.tenant_access_denied',
      });
    }

    if (!tenantHasUser.isActive) {
      throw new BadRequestException({
        message: 'Your access to this tenant is inactive',
        reason: 'switchTenant.tenant_access_inactive',
      });
    }

    // Get tenant details
    const tenant = await this.prisma.tenant.findUnique({
      where: { id: tenantId },
      select: {
        id: true,
        name: true,
        code: true,
        logoPath: true,
        status: true,
        isActive: true,
        revokedAt: true,
      },
    });

    if (!tenant || !tenant.isActive || tenant.revokedAt) {
      throw new BadRequestException({
        message: 'This tenant is inactive or has been revoked',
        reason: 'switchTenant.tenant_inactive_or_revoked',
      });
    }

    // Update user's last tenant
    await this.prisma.user.update({
      where: { id: userId },
      data: { lastTenantId: tenantId },
    });

    // Note: No need to generate new JWT token since session_id remains the same
    // The updated lastTenantId will be fetched on next request via session lookup

    // Audit log
    await this.auditService.logFromRequest(request, {
      userType: 'User',
      userId,
      event: 'switch_tenant',
      auditableTable: 'users',
      auditableId: userId,
      newValues: { lastTenantId: tenantId },
      tags: 'tenant,switch',
    });

    return {
      message: 'Successfully switched to tenant',
      tenant: {
        id: tenant.id,
        name: tenant.name,
        code: tenant.code,
        logoPath: tenant.logoPath,
        status: tenant.status,
      },
    };
  }

  /**
   * Toggle user locked status (Owner only)
   */
  async toggleUserLocked(
    currentUserId: string,
    targetUserId: string,
    request: FastifyRequest,
  ): Promise<{
    message: string;
    userId: string;
    isLocked: boolean;
    lockedAt: Date | null;
  }> {
    // Get current user's tenant
    const currentUser = await this.prisma.user.findUnique({
      where: { id: currentUserId },
      select: { lastTenantId: true },
    });

    if (!currentUser?.lastTenantId) {
      throw new BadRequestException({
        message: 'No active tenant selected',
        reason: 'toggleUserLocked.no_active_tenant',
      });
    }

    // Check if current user is owner of the tenant
    const currentUserTenant = await this.prisma.tenantHasUser.findFirst({
      where: {
        userId: currentUserId,
        tenantId: currentUser.lastTenantId,
      },
      select: { isOwner: true },
    });

    if (!currentUserTenant?.isOwner) {
      throw new UnauthorizedException({
        message: 'Only tenant owners can lock/unlock users',
        reason: 'toggleUserLocked.owner_permission_required',
      });
    }

    // Get target user
    const targetUser = await this.prisma.user.findUnique({
      where: { id: targetUserId },
      select: { id: true, isLocked: true, lockedAt: true },
    });

    if (!targetUser) {
      throw new BadRequestException({
        message: 'User not found',
        reason: 'toggleUserLocked.user_not_found',
      });
    }

    // Toggle lock status
    const newLockStatus = !targetUser.isLocked;
    const updatedUser = await this.prisma.user.update({
      where: { id: targetUserId },
      data: {
        isLocked: newLockStatus,
        lockedAt: newLockStatus ? new Date() : null,
        // Reset lockout counters when unlocking
        ...(newLockStatus
          ? {}
          : {
              failedLoginCounter: 0,
              temporaryLockUntil: null,
              forceLogoutAt: null,
            }),
      },
      select: { id: true, isLocked: true, lockedAt: true },
    });

    // Revoke all sessions if locking (commented until Prisma generate)
    // TODO: Uncomment after running npx prisma generate
    if (newLockStatus) {
      await this.prisma.session.updateMany({
        where: { userId: targetUserId },
        data: { revokedAt: new Date() },
      });
    }

    // Audit log
    await this.auditService.logFromRequest(request, {
      userType: 'User',
      userId: currentUserId,
      event: newLockStatus ? 'user_locked' : 'user_unlocked',
      auditableTable: 'users',
      auditableId: targetUserId,
      oldValues: {
        isLocked: targetUser.isLocked,
        lockedAt: targetUser.lockedAt,
      },
      newValues: {
        isLocked: updatedUser.isLocked,
        lockedAt: updatedUser.lockedAt,
      },
      tags: 'user,lock,admin',
    });

    return {
      message: `User ${newLockStatus ? 'locked' : 'unlocked'} successfully`,
      userId: updatedUser.id,
      isLocked: updatedUser.isLocked,
      lockedAt: updatedUser.lockedAt,
    };
  }

  /**
   * Get all active sessions (devices) for current user
   */
  async getUserSessions(
    userId: string,
    currentSessionId: string,
  ): Promise<any[]> {
    const sessions = await this.prisma.session.findMany({
      where: {
        userId,
        revokedAt: null, // Only active sessions
      },
      select: {
        id: true,
        deviceName: true,
        ipAddress: true,
        userAgent: true,
        lastActivity: true,
        createdAt: true,
      },
      orderBy: {
        lastActivity: 'desc',
      },
    });

    return sessions.map((session) => ({
      ...session,
      isCurrent: session.id === currentSessionId,
    }));
  }

  /**
   * Revoke a specific session (force logout on that device)
   */
  async revokeSession(
    userId: string,
    sessionId: string,
    request: FastifyRequest,
  ): Promise<void> {
    // Verify session belongs to user
    const session = await this.prisma.session.findFirst({
      where: {
        id: sessionId,
        userId,
      },
    });

    if (!session) {
      throw new BadRequestException({
        message: 'Session not found or does not belong to you',
        reason: 'revokeSession.session_not_found',
      });
    }

    if (session.revokedAt) {
      throw new BadRequestException({
        message: 'Session already revoked',
        reason: 'revokeSession.session_already_revoked',
      });
    }

    // Revoke session
    await this.prisma.session.update({
      where: { id: sessionId },
      data: { revokedAt: new Date() },
    });

    // Revoke all refresh tokens for this session
    await this.prisma.refreshToken.updateMany({
      where: {
        sessionId,
        revoked: false,
      },
      data: {
        revoked: true,
        revokedAt: new Date(),
      },
    });

    // Audit log
    await this.auditService.logFromRequest(request, {
      userType: 'User',
      userId,
      event: 'session_revoked',
      auditableTable: 'sessions',
      auditableId: sessionId,
      tags: 'security,session,device_management',
    });

    this.logger.log(`Session ${sessionId} revoked by user ${userId}`);
  }

  /**
   * Get user configuration
   * Returns all configs defined in core_user_configs
   */
  async getUserConfig(userId: string): Promise<UserConfigResponseDto> {
    try {
      // Get core configs to know what configs are available
      const coreConfigs = await this.prisma.coreUserConfig.findMany({
        select: {
          key: true,
          defaultValue: true,
          configType: true,
        },
      });

      // Get user-specific configs
      const userConfigs = await this.prisma.userConfig.findMany({
        where: { userId },
        select: {
          configKey: true,
          configValue: true,
        },
      });

      // Build config map with defaults from core
      const configMap = new Map<string, any>();
      coreConfigs.forEach((coreConfig) => {
        configMap.set(coreConfig.key, coreConfig.defaultValue || '');
      });

      // Override with user-specific values
      userConfigs.forEach((config) => {
        configMap.set(config.configKey, config.configValue);
      });

      // Parse values based on type
      const response: UserConfigResponseDto = {
        theme: configMap.get('theme') || 'light',
        'content-width': configMap.get('content-width') || 'full',
        'menu-layout': configMap.get('menu-layout') || 'horizontal',
        language: configMap.get('language') || 'en',
        notifications_enabled:
          configMap.get('notifications_enabled') === 'true',
        items_per_page: parseInt(configMap.get('items_per_page') || '20', 10),
      };

      return response;
    } catch (error) {
      this.logger.error('Get user config error:', error);
      throw new BadRequestException(
        'An error occurred while fetching user configuration',
      );
    }
  }

  /**
   * Update user configuration
   * Only allows updating configs defined in core_user_configs
   */
  async updateUserConfig(
    userId: string,
    configDto: UserConfigDto,
    request: FastifyRequest,
  ): Promise<UserConfigResponseDto> {
    try {
      // Get valid config keys from core_user_configs
      const coreConfigs = await this.prisma.coreUserConfig.findMany({
        select: { key: true, configType: true },
      });

      const validConfigKeys = new Set(coreConfigs.map((c) => c.key));
      const configTypeMap = new Map(
        coreConfigs.map((c) => [c.key, c.configType]),
      );

      // Process updates
      const updates = Object.entries(configDto).filter(
        ([, value]) => value !== undefined,
      );

      for (const [key, value] of updates) {
        // Validate config key exists in core
        if (!validConfigKeys.has(key)) {
          this.logger.warn(`Skipping invalid config key: ${key}`);
          continue;
        }

        const configType = configTypeMap.get(key);
        let configValue: string;

        // Convert value to string based on type
        if (configType === 'boolean') {
          configValue = String(Boolean(value));
        } else if (configType === 'integer') {
          configValue = String(Number(value));
        } else {
          configValue = String(value);
        }

        // Upsert user config
        const existingConfig = await this.prisma.userConfig.findFirst({
          where: {
            userId,
            configKey: key,
          },
        });

        if (existingConfig) {
          await this.prisma.userConfig.update({
            where: { id: existingConfig.id },
            data: {
              configValue,
              updatedAt: new Date(),
            },
          });
        } else {
          await this.prisma.userConfig.create({
            data: {
              id: uuidv4(),
              userId,
              configKey: key,
              configValue,
              createdAt: new Date(),
              updatedAt: new Date(),
            },
          });
        }
      }

      // Audit log
      await this.auditService.logFromRequest(request, {
        userType: 'User',
        userId,
        event: 'user_config_updated',
        auditableTable: 'user_configs',
        auditableId: userId,
        newValues: configDto,
        tags: 'user,config,preferences',
      });

      this.logger.log(`User ${userId} updated configuration`);

      // Return updated config
      return this.getUserConfig(userId);
    } catch (error) {
      this.logger.error('Update user config error:', error);
      throw new BadRequestException(
        'An error occurred while updating user configuration',
      );
    }
  }
}

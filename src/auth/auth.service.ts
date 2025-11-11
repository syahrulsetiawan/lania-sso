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
    const { usernameOrEmail, password, deviceName, latitude, longitude } =
      loginDto;
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
          reason: 'invalid_credentials',
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
          reason: 'account_locked',
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
          reason: 'temporary_locked',
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
          reason: 'no_active_tenant',
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
          reason: 'tenant_inactive_or_revoked',
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
          reason: 'account_suspended',
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
              reason: '15_failed_attempts',
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
            reason: 'temporary_locked_15min',
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
            reason: 'temporary_locked_5min',
            lockedUntil: lockUntil,
            failedAttempts,
            minutesRemaining: 5,
          });
        }

        throw new UnauthorizedException({
          message: 'Invalid credentials',
          reason: 'invalid_credentials',
        });
      }

      // Reset failed login counter on successful login
      await this.prisma.user.update({
        where: { id: user.id },
        data: {
          failedLoginCounter: 0,
          temporaryLockUntil: null,
          lastLoginAt: new Date(),
          lastLoginIp: ipAddress,
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

      // Generate tokens
      const accessToken = await this.generateAccessToken(
        user.id,
        user.email,
        user.username,
      );
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
        user: {
          id: user.id,
          name: user.name,
          username: user.username,
          email: user.email,
          phone: user.phone,
          profilePhotoPath: user.profilePhotoPath,
          lastTenantId: user.lastTenantId,
          lastServiceKey: user.lastServiceKey,
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
          reason: 'invalid_refresh_token',
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
          reason: 'refresh_token_revoked',
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
          reason: 'refresh_token_expired',
        });
      }

      // Check if session is still active
      if (storedToken.session.revokedAt) {
        throw new UnauthorizedException({
          message: 'Session has been terminated',
          reason: 'session_terminated',
        });
      }

      // Revoke old refresh token (token rotation)
      await this.prisma.refreshToken.update({
        where: { id: storedToken.id },
        data: { revoked: true, revokedAt: new Date() },
      });

      // Generate new tokens
      const newAccessToken = await this.generateAccessToken(
        storedToken.user.id,
        storedToken.user.email,
        storedToken.user.username,
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
          reason: 'password_mismatch',
        });
      }

      // Find reset token
      const resetToken = await this.prisma.passwordResetToken.findUnique({
        where: { email },
      });

      if (!resetToken || resetToken.token !== token) {
        throw new BadRequestException({
          message: 'Invalid or expired reset token',
          reason: 'invalid_reset_token',
        });
      }

      // Check if token is expired
      if (new Date() > resetToken.expiresAt) {
        await this.prisma.passwordResetToken.delete({ where: { email } });
        throw new BadRequestException({
          message: 'Reset token has expired',
          reason: 'reset_token_expired',
        });
      }

      // Find user
      const user = await this.prisma.user.findUnique({
        where: { email, deletedAt: null },
      });

      if (!user) {
        throw new BadRequestException({
          message: 'User not found',
          reason: 'user_not_found',
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
          reason: 'no_authorization_header',
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
                },
              },
            },
          },
        },
      });

      if (!user) {
        throw new UnauthorizedException({
          message: 'User not found',
          reason: 'user_not_found',
        });
      }

      // Remove password from response
      const { password, ...userWithoutPassword } = user;

      return {
        ...userWithoutPassword,
        userConfigs: user.userConfigs,
        tenants: user.tenants,
      };
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
   */
  private async generateAccessToken(
    userId: string,
    email: string,
    username: string,
  ): Promise<string> {
    const payload = {
      sub: userId,
      email,
      username,
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
}

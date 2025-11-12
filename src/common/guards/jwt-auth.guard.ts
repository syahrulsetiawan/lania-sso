import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../../prisma/prisma.service';
import { FastifyRequest } from 'fastify';

/**
 * JWT Authentication Guard
 * Validates JWT tokens from Authorization header and attaches payload to request
 */
@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
    private readonly prisma: PrismaService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest<FastifyRequest>();
    const token = this.extractTokenFromHeader(request);

    if (!token) {
      throw new UnauthorizedException({
        message: 'Access token not provided',
        reason: 'no_token',
      });
    }

    try {
      const payload = await this.jwtService.verifyAsync(token, {
        secret: this.configService.get<string>('JWT_SECRET'),
      });

      // Extract session_id from JWT payload
      const sessionId = payload.session_id;
      if (!sessionId) {
        throw new UnauthorizedException({
          message: 'Invalid token format',
          reason: 'invalid_token_format',
        });
      }

      // Fetch session from database
      const session = await this.prisma.session.findUnique({
        where: { id: sessionId },
        include: {
          user: {
            select: {
              id: true,
              name: true,
              username: true,
              email: true,
              phone: true,
              profilePhotoPath: true,
              lastTenantId: true,
              lastServiceKey: true,
              isLocked: true,
              forceLogoutAt: true,
              temporaryLockUntil: true,
              deletedAt: true,
            },
          },
        },
      });

      if (!session) {
        throw new UnauthorizedException({
          message: 'Session not found',
          reason: 'session_not_found',
        });
      }

      // Check if session has been revoked
      if (session.revokedAt) {
        throw new UnauthorizedException({
          message: 'Session has been revoked. Please login again.',
          reason: 'session_revoked',
        });
      }

      const user = session.user;

      if (!user || user.deletedAt) {
        throw new UnauthorizedException({
          message: 'User not found or deleted',
          reason: 'user_not_found',
        });
      }

      // Check if account is permanently locked
      if (user.isLocked) {
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
        throw new UnauthorizedException({
          message: `Account temporarily locked. Try again in ${minutesRemaining} minute(s).`,
          reason: 'temporary_lock',
          lockedUntil: user.temporaryLockUntil,
        });
      }

      // Check if force logout is active
      if (user.forceLogoutAt && new Date(user.forceLogoutAt) > new Date()) {
        throw new UnauthorizedException({
          message: 'Your account is temporarily suspended.',
          reason: 'force_logout',
        });
      }

      // Attach full user data to request (fetched from session, not JWT)
      (request as any).user = {
        id: user.id,
        name: user.name,
        username: user.username,
        email: user.email,
        phone: user.phone,
        profilePhotoPath: user.profilePhotoPath,
        lastTenantId: user.lastTenantId,
        lastServiceKey: user.lastServiceKey,
        sessionId: session.id,
      };
    } catch (e) {
      if (e instanceof UnauthorizedException) {
        throw e;
      }
      throw new UnauthorizedException({
        message: 'Invalid or expired token',
        reason: 'invalid_token',
      });
    }

    return true;
  }

  private extractTokenFromHeader(request: FastifyRequest): string | undefined {
    const [type, token] = request.headers.authorization?.split(' ') ?? [];
    return type === 'Bearer' ? token : undefined;
  }
}

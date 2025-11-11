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

      // Check if user is locked or force logged out
      const user = await this.prisma.user.findUnique({
        where: { id: payload.sub, deletedAt: null },
        select: {
          id: true,
          isLocked: true,
          forceLogoutAt: true,
          temporaryLockUntil: true,
        },
      });

      if (!user) {
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

      // Attach user payload to request for use in controllers
      (request as any).user = payload;
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

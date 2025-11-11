import {
  Controller,
  Post,
  Get,
  Body,
  UseGuards,
  Req,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
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
 * Authentication Controller
 * Handles all authentication-related endpoints
 *
 * Endpoints:
 * - POST /api/v1/auth/login - User login with credentials
 * - POST /api/v1/auth/refresh - Refresh access token
 * - POST /api/v1/auth/forgot-password - Request password reset
 * - POST /api/v1/auth/reset-password - Reset password with token
 * - POST /api/v1/auth/logout - Logout from current device
 * - POST /api/v1/auth/logout-all - Logout from all devices
 * - GET /api/v1/auth/me - Get current user profile
 */
@ApiTags('Authentication')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  /**
   * GET /api/v1/auth/me
   *
   * Get current authenticated user profile
   * Returns user data, user configs, and tenants
   * Requires authentication (JWT token in Authorization header)
   *
   * @param request - Fastify request object with user info
   * @returns User profile with configs and tenants
   */
  @Get('me')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Get current user profile',
    description:
      'Returns authenticated user data including user configs and associated tenants',
  })
  @ApiResponse({
    status: 200,
    description: 'User profile retrieved successfully',
    type: UserMeResponseDto,
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized - Invalid or missing token',
  })
  @HttpCode(HttpStatus.OK)
  async getMe(@Req() request: any): Promise<UserMeResponseDto> {
    const userId = request.user.userId || request.user.sub;
    return this.authService.getMe(userId);
  }

  /**
   * POST /api/v1/auth/login
   *
   * User login with username/email and password
   * Returns access token (1 hour) and refresh token
   *
   * @param loginDto - Login credentials
   * @param request - Fastify request object
   * @returns Access token, refresh token, and user data
   */
  @Post('login')
  @ApiOperation({
    summary: 'User login',
    description:
      'Authenticate user with username/email and password. Returns access token (1h) and refresh token (7d)',
  })
  @ApiResponse({
    status: 200,
    description: 'Login successful',
    type: LoginResponseDto,
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized - Invalid credentials or account locked',
  })
  @HttpCode(HttpStatus.OK)
  async login(
    @Body() loginDto: LoginDto,
    @Req() request: FastifyRequest,
  ): Promise<LoginResponseDto> {
    return this.authService.login(loginDto, request);
  }

  /**
   * POST /api/v1/auth/refresh
   *
   * Refresh access token using refresh token
   * Implements token rotation (old refresh token is revoked)
   *
   * @param refreshTokenDto - Refresh token
   * @param request - Fastify request object
   * @returns New access token and new refresh token
   */
  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  async refresh(
    @Body() refreshTokenDto: RefreshTokenDto,
    @Req() request: FastifyRequest,
  ): Promise<RefreshTokenResponseDto> {
    return this.authService.refresh(refreshTokenDto, request);
  }

  /**
   * POST /api/v1/auth/forgot-password
   *
   * Request password reset link via email
   * Returns success message even if email doesn't exist (prevent email enumeration)
   *
   * @param forgotPasswordDto - Email address
   * @param request - Fastify request object
   * @returns Success message
   */
  @Post('forgot-password')
  @HttpCode(HttpStatus.OK)
  async forgotPassword(
    @Body() forgotPasswordDto: ForgotPasswordDto,
    @Req() request: FastifyRequest,
  ): Promise<PasswordResetResponseDto> {
    return this.authService.forgotPassword(forgotPasswordDto, request);
  }

  /**
   * POST /api/v1/auth/reset-password
   *
   * Reset password using token from email
   * Logs out user from all devices after successful password reset
   *
   * @param resetPasswordDto - Reset token and new password
   * @param request - Fastify request object
   * @returns Success message
   */
  @Post('reset-password')
  @HttpCode(HttpStatus.OK)
  async resetPassword(
    @Body() resetPasswordDto: ResetPasswordDto,
    @Req() request: FastifyRequest,
  ): Promise<PasswordResetResponseDto> {
    return this.authService.resetPassword(resetPasswordDto, request);
  }

  /**
   * POST /api/v1/auth/logout
   *
   * Logout from current device
   * Revokes current session and associated refresh tokens
   * Requires authentication (JWT token in Authorization header)
   *
   * @param request - Fastify request object with user info
   * @returns Success message
   */
  @Post('logout')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  async logout(@Req() request: any): Promise<LogoutResponseDto> {
    const userId = request.user.userId || request.user.sub;
    return this.authService.logout(userId, request);
  }

  /**
   * POST /api/v1/auth/logout-all
   *
   * Logout from all devices
   * Revokes all sessions and refresh tokens for the user
   * Useful for security purposes (e.g., after password change, suspicious activity)
   * Requires authentication (JWT token in Authorization header)
   *
   * @param request - Fastify request object with user info
   * @returns Success message and number of sessions terminated
   */
  @Post('logout-all')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  async logoutAll(@Req() request: any): Promise<LogoutAllResponseDto> {
    const userId = request.user.userId || request.user.sub;
    return this.authService.logoutAll(userId, request);
  }
}

import {
  Controller,
  Post,
  Get,
  Body,
  UseGuards,
  Req,
  HttpCode,
  HttpStatus,
  Param,
  Delete,
  Patch,
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
  SendEmailVerificationDto,
  VerifyEmailDto,
  EmailVerificationResponseDto,
  SwitchTenantDto,
  SwitchTenantResponseDto,
  ToggleUserLockedResponseDto,
  GetSessionsResponseDto,
  RevokeSessionResponseDto,
  UserConfigDto,
  UserConfigResponseDto,
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
    const userId = request.user.userId || request.user.sub || request.user.id;
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
    const userId = request.user.userId || request.user.sub || request.user.id;
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
    const userId = request.user.userId || request.user.sub || request.user.id;
    return this.authService.logoutAll(userId, request);
  }

  /**
   * POST /api/v1/auth/send-email-verification
   *
   * Send email verification link to user's email
   *
   * @param dto - Email to send verification to
   * @param request - Fastify request object
   * @returns Success message
   */
  @Post('send-email-verification')
  @ApiOperation({
    summary: 'Send email verification link',
    description: 'Sends a verification email with a token valid for 1 hour',
  })
  @ApiResponse({
    status: 200,
    description: 'Verification email sent successfully',
    type: EmailVerificationResponseDto,
  })
  @ApiResponse({
    status: 400,
    description: 'Bad request - Email not found or already verified',
  })
  @HttpCode(HttpStatus.OK)
  async sendEmailVerification(
    @Body() dto: SendEmailVerificationDto,
    @Req() request: FastifyRequest,
  ): Promise<EmailVerificationResponseDto> {
    return this.authService.sendEmailVerification(dto.email, request);
  }

  /**
   * POST /api/v1/auth/verify-email
   *
   * Verify user email with token from email
   *
   * @param dto - Email and verification token
   * @param request - Fastify request object
   * @returns Success message
   */
  @Post('verify-email')
  @ApiOperation({
    summary: 'Verify email address',
    description: 'Verifies email address using token sent via email',
  })
  @ApiResponse({
    status: 200,
    description: 'Email verified successfully',
    type: EmailVerificationResponseDto,
  })
  @ApiResponse({
    status: 400,
    description: 'Bad request - Invalid or expired token',
  })
  @HttpCode(HttpStatus.OK)
  async verifyEmail(
    @Body() dto: VerifyEmailDto,
    @Req() request: FastifyRequest,
  ): Promise<EmailVerificationResponseDto> {
    return this.authService.verifyEmail(dto.email, dto.token, request);
  }

  /**
   * POST /api/v1/auth/switch-tenant
   *
   * Switch user to different tenant
   * Returns new access token with tenant context
   * Requires authentication (JWT token in Authorization header)
   *
   * @param dto - Tenant ID to switch to
   * @param request - Fastify request object with user info
   * @returns New access token with tenant context
   */
  @Post('switch-tenant')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Switch to different tenant',
    description:
      'Switches user context to different tenant and returns new access token',
  })
  @ApiResponse({
    status: 200,
    description: 'Successfully switched tenant',
    type: SwitchTenantResponseDto,
  })
  @ApiResponse({
    status: 400,
    description: 'Bad request - Tenant access denied or inactive',
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized - Invalid or missing token',
  })
  @HttpCode(HttpStatus.OK)
  async switchTenant(
    @Body() dto: SwitchTenantDto,
    @Req() request: any,
  ): Promise<SwitchTenantResponseDto> {
    const userId = request.user.userId || request.user.sub || request.user.id;
    return this.authService.switchTenant(userId, dto.tenantId, request);
  }

  /**
   * POST /api/v1/auth/users/:id/toggle-locked
   *
   * Toggle user lock status (Owner only)
   * Only tenant owners can lock/unlock users
   * Requires authentication (JWT token in Authorization header)
   *
   * @param id - User ID to toggle lock status
   * @param request - Fastify request object with current user info
   * @returns Updated lock status
   */
  @Post('users/:id/toggle-locked')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Toggle user lock status (Owner only)',
    description:
      'Locks or unlocks a user account. Only tenant owners can perform this action.',
  })
  @ApiResponse({
    status: 200,
    description: 'User lock status updated successfully',
    type: ToggleUserLockedResponseDto,
  })
  @ApiResponse({
    status: 400,
    description: 'Bad request - User not found or no active tenant',
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized - Only tenant owners can lock/unlock users',
  })
  @HttpCode(HttpStatus.OK)
  async toggleUserLocked(
    @Param('id') id: string,
    @Req() request: any,
  ): Promise<ToggleUserLockedResponseDto> {
    const currentUserId =
      request.user.userId || request.user.sub || request.user.id;
    return this.authService.toggleUserLocked(currentUserId, id, request);
  }

  /**
   * GET /api/v1/auth/sessions
   *
   * Get all active sessions (devices) for current user
   * Requires authentication (JWT token in Authorization header)
   *
   * @param request - Fastify request object with current user info
   * @returns List of active sessions/devices
   */
  @Get('sessions')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Get active sessions',
    description:
      'Retrieve all active sessions (devices) for the current user. Useful for device management.',
  })
  @ApiResponse({
    status: 200,
    description: 'Active sessions retrieved successfully',
    type: GetSessionsResponseDto,
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized - Invalid or missing token',
  })
  @HttpCode(HttpStatus.OK)
  async getSessions(@Req() request: any): Promise<GetSessionsResponseDto> {
    const userId = request.user.id;
    const currentSessionId = request.user.sessionId;
    const sessions = await this.authService.getUserSessions(
      userId,
      currentSessionId,
    );
    return {
      message: 'Active sessions retrieved successfully',
      sessions,
    };
  }

  /**
   * DELETE /api/v1/auth/sessions/:id
   *
   * Revoke a specific session (force logout on that device)
   * Requires authentication (JWT token in Authorization header)
   *
   * @param id - Session ID to revoke
   * @param request - Fastify request object with current user info
   * @returns Success message
   */
  @Delete('sessions/:id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Revoke session',
    description:
      'Revoke a specific session to force logout on that device. User can only revoke their own sessions.',
  })
  @ApiResponse({
    status: 200,
    description: 'Session revoked successfully',
    type: RevokeSessionResponseDto,
  })
  @ApiResponse({
    status: 400,
    description: 'Bad request - Session not found or already revoked',
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized - Invalid or missing token',
  })
  @HttpCode(HttpStatus.OK)
  async revokeSession(
    @Param('id') id: string,
    @Req() request: any,
  ): Promise<RevokeSessionResponseDto> {
    const userId = request.user.id;
    await this.authService.revokeSession(userId, id, request);
    return {
      message: 'Session revoked successfully',
    };
  }

  /**
   * GET /api/v1/auth/users/config
   *
   * Get current user configuration/preferences
   * Returns user preferences for UI settings
   * Requires authentication (JWT token in Authorization header)
   *
   * @param request - Fastify request object with user info
   * @returns User configuration object
   */
  @Get('users/config')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Get user configuration',
    description:
      'Returns current user preferences including language, theme, layout settings',
  })
  @ApiResponse({
    status: 200,
    description: 'User configuration retrieved successfully',
    type: UserConfigResponseDto,
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized - Invalid or missing token',
  })
  @HttpCode(HttpStatus.OK)
  async getUserConfig(@Req() request: any): Promise<UserConfigResponseDto> {
    const userId = request.user.id;
    return this.authService.getUserConfig(userId);
  }

  /**
   * PATCH /api/v1/auth/users/config
   *
   * Update current user configuration/preferences
   * Updates user preferences for UI settings (partial update supported)
   * Requires authentication (JWT token in Authorization header)
   *
   * @param configDto - User configuration to update
   * @param request - Fastify request object with user info
   * @returns Updated user configuration object
   */
  @Patch('users/config')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Update user configuration',
    description:
      'Partially update user preferences including language, theme, layout settings. Only send the fields you want to update.',
  })
  @ApiResponse({
    status: 200,
    description: 'User configuration updated successfully',
    type: UserConfigResponseDto,
  })
  @ApiResponse({
    status: 400,
    description: 'Bad request - Invalid configuration data',
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized - Invalid or missing token',
  })
  @HttpCode(HttpStatus.OK)
  async updateUserConfig(
    @Body() configDto: UserConfigDto,
    @Req() request: any,
  ): Promise<UserConfigResponseDto> {
    const userId = request.user.id;
    return this.authService.updateUserConfig(userId, configDto, request);
  }
}

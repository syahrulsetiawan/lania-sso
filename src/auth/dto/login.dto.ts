import { IsString, IsNotEmpty, MinLength, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class LoginDto {
  @ApiProperty({
    description: 'Username or email for login',
    example: 'johndoe',
  })
  @IsString()
  @IsNotEmpty()
  usernameOrEmail: string;

  @ApiProperty({
    description: 'User password',
    example: 'SecurePassword123!',
    minLength: 6,
  })
  @IsString()
  @IsNotEmpty()
  @MinLength(6)
  password: string;

  @ApiProperty({
    description: 'Device name for session tracking',
    example: 'Chrome on Windows',
    required: false,
  })
  @IsString()
  @IsOptional()
  deviceName?: string;

  @ApiProperty({
    description: 'Latitude for geolocation tracking',
    example: '-6.200000',
    required: false,
  })
  @IsString()
  @IsOptional()
  latitude?: string;

  @ApiProperty({
    description: 'Longitude for geolocation tracking',
    example: '106.816666',
    required: false,
  })
  @IsString()
  @IsOptional()
  longitude?: string;
}

export class LoginResponseDto {
  @ApiProperty({
    description: 'JWT access token (valid for 1 hour)',
    example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
  })
  accessToken: string;

  @ApiProperty({
    description: 'Refresh token for obtaining new access tokens',
    example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
  })
  refreshToken: string;

  @ApiProperty({
    description: 'Access token expiration time in seconds',
    example: 3600,
  })
  expiresIn: number;

  @ApiProperty({
    description: 'Token type',
    example: 'Bearer',
  })
  tokenType: string;

  @ApiProperty({
    description: 'User information',
  })
  user: {
    id: string;
    name: string;
    username: string;
    email: string;
    phone: string | null;
    profilePhotoPath: string | null;
    lastTenantId: string | null;
    lastServiceKey: string | null;
  };
}

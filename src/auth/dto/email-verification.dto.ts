import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsNotEmpty } from 'class-validator';

export class SendEmailVerificationDto {
  @ApiProperty({
    description: 'Email address to verify',
    example: 'john@example.com',
  })
  @IsEmail()
  @IsNotEmpty()
  email: string;
}

export class VerifyEmailDto {
  @ApiProperty({
    description: 'Email address',
    example: 'john@example.com',
  })
  @IsEmail()
  @IsNotEmpty()
  email: string;

  @ApiProperty({
    description: 'Verification token from email',
    example: 'abc123def456...',
  })
  @IsNotEmpty()
  token: string;
}

export class EmailVerificationResponseDto {
  @ApiProperty({
    description: 'Response message',
    example: 'Verification email sent successfully',
  })
  message: string;
}

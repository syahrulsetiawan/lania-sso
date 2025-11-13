import { ApiProperty } from '@nestjs/swagger';

export class SessionDeviceDto {
  @ApiProperty({
    description: 'Session ID',
    example: '550e8400-e29b-41d4-a716-446655440000',
  })
  id: string;

  @ApiProperty({
    description: 'Device name',
    example: 'Chrome on Windows',
  })
  deviceName: string | null;

  @ApiProperty({
    description: 'IP address',
    example: '192.168.1.100',
  })
  ipAddress: string | null;

  @ApiProperty({
    description: 'User agent string',
    example: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36...',
  })
  userAgent: string | null;

  @ApiProperty({
    description: 'Last activity timestamp',
    example: '2025-11-12T14:30:00Z',
  })
  lastActivity: Date;

  @ApiProperty({
    description: 'Session created timestamp',
    example: '2025-11-10T08:00:00Z',
  })
  createdAt: Date;

  @ApiProperty({
    description: 'Is this the current session',
    example: true,
  })
  isCurrent: boolean;
}

export class GetSessionsResponseDto {
  @ApiProperty({
    description: 'Response message',
    example: 'Active sessions retrieved successfully',
  })
  message: string;

  @ApiProperty({
    description: 'List of active sessions',
    type: [SessionDeviceDto],
  })
  sessions: SessionDeviceDto[];
}

export class RevokeSessionResponseDto {
  @ApiProperty({
    description: 'Response message',
    example: 'Session revoked successfully',
  })
  message: string;
}

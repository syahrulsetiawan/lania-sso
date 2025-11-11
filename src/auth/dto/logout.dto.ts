import { ApiProperty } from '@nestjs/swagger';

export class LogoutResponseDto {
  @ApiProperty({
    description: 'Success message',
    example: 'Successfully logged out',
  })
  message: string;
}

export class LogoutAllResponseDto {
  @ApiProperty({
    description: 'Success message',
    example: 'Successfully logged out from all devices',
  })
  message: string;

  @ApiProperty({
    description: 'Number of sessions terminated',
    example: 3,
  })
  sessionsTerminated: number;
}

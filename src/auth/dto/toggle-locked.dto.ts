import { ApiProperty } from '@nestjs/swagger';

export class ToggleUserLockedResponseDto {
  @ApiProperty({
    description: 'Response message',
    example: 'User lock status updated successfully',
  })
  message: string;

  @ApiProperty({
    description: 'User ID',
    example: '550e8400-e29b-41d4-a716-446655440000',
  })
  userId: string;

  @ApiProperty({
    description: 'New lock status',
    example: true,
  })
  isLocked: boolean;

  @ApiProperty({
    description: 'Locked at timestamp (if locked)',
    nullable: true,
  })
  lockedAt: Date | null;
}

import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsUUID } from 'class-validator';

export class SwitchTenantDto {
  @ApiProperty({
    description: 'Tenant ID to switch to',
    example: '550e8400-e29b-41d4-a716-446655440000',
  })
  @IsUUID()
  @IsNotEmpty()
  tenantId: string;
}

export class SwitchTenantResponseDto {
  @ApiProperty({
    description: 'Response message',
    example: 'Successfully switched to tenant',
  })
  message: string;

  @ApiProperty({
    description: 'Current tenant information',
  })
  tenant: {
    id: string;
    name: string;
    code: string;
    logoPath: string | null;
    status: string;
  };
}

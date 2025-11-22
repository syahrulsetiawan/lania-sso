import { IsBoolean, IsInt, IsOptional, IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';

// Based on core_tenant_configs table
export class TenantConfigDto {
  @ApiProperty({
    description: 'Default currency for financial transactions',
    example: 'USD',
    required: false,
  })
  @IsOptional()
  @IsString()
  default_currency?: string;

  @ApiProperty({
    description: 'Default number format for the tenant',
    example: '{"thousands_separator": ",", "decimal_separator": "."}',
    required: false,
  })
  @IsOptional()
  @IsString()
  number_format?: string;

  @ApiProperty({
    description: 'Default number of decimal places for numbers',
    example: 2,
    required: false,
  })
  @IsOptional()
  @IsInt()
  @Type(() => Number)
  number_decimal?: number;

  @ApiProperty({
    description: 'Enable or disable multi-currency support',
    example: false,
    required: false,
  })
  @IsOptional()
  @IsBoolean()
  enabled_multi_currency?: boolean;

  @ApiProperty({
    description: 'Default timezone for the tenant',
    example: 'UTC',
    required: false,
  })
  @IsOptional()
  @IsString()
  timezone?: string;

  @ApiProperty({
    description: 'Default date format for the tenant',
    example: 'YYYY-MM-DD',
    required: false,
  })
  @IsOptional()
  @IsString()
  date_format?: string;
}

export class TenantConfigResponseDto {
  @ApiProperty({ description: 'Default currency', example: 'USD' })
  default_currency: string;

  @ApiProperty({
    description: 'Number format',
    example: '{"thousands_separator": ",", "decimal_separator": "."}',
  })
  number_format: string;

  @ApiProperty({ description: 'Number decimal places', example: 2 })
  number_decimal: number;

  @ApiProperty({ description: 'Multi-currency enabled', example: false })
  enabled_multi_currency: boolean;

  @ApiProperty({ description: 'Timezone', example: 'UTC' })
  timezone: string;

  @ApiProperty({ description: 'Date format', example: 'YYYY-MM-DD' })
  date_format: string;
}

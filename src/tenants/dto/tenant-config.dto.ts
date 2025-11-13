import {
  IsBoolean,
  IsEmail,
  IsNumber,
  IsOptional,
  IsString,
} from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class TenantConfigDto {
  @ApiProperty({
    description: 'Company name',
    example: 'PT Laniakea Technology',
    required: false,
  })
  @IsOptional()
  @IsString()
  company_name?: string;

  @ApiProperty({
    description: 'Company address',
    example: 'Jl. Sudirman No. 123',
    required: false,
  })
  @IsOptional()
  @IsString()
  company_address?: string;

  @ApiProperty({
    description: 'Company logo/photo path',
    example: '/uploads/company/logo.png',
    required: false,
  })
  @IsOptional()
  @IsString()
  company_photo?: string;

  @ApiProperty({
    description: 'Company phone number',
    example: '+62 21 1234567',
    required: false,
  })
  @IsOptional()
  @IsString()
  company_phone?: string;

  @ApiProperty({
    description: 'Company email',
    example: 'info@laniakea.tech',
    required: false,
  })
  @IsOptional()
  @IsEmail()
  company_email?: string;

  @ApiProperty({
    description: 'Company website',
    example: 'https://laniakea.tech',
    required: false,
  })
  @IsOptional()
  @IsString()
  company_website?: string;

  @ApiProperty({
    description: 'Company tax number (NPWP)',
    example: '01.234.567.8-901.000',
    required: false,
  })
  @IsOptional()
  @IsString()
  company_tax_number?: string;

  @ApiProperty({
    description: 'Company country',
    example: 'Indonesia',
    required: false,
  })
  @IsOptional()
  @IsString()
  company_country?: string;

  @ApiProperty({
    description: 'Company province',
    example: 'DKI Jakarta',
    required: false,
  })
  @IsOptional()
  @IsString()
  company_province?: string;

  @ApiProperty({
    description: 'Company city',
    example: 'Jakarta Selatan',
    required: false,
  })
  @IsOptional()
  @IsString()
  company_city?: string;

  @ApiProperty({
    description: 'Company postal code',
    example: '12190',
    required: false,
  })
  @IsOptional()
  @IsString()
  company_postal_code?: string;

  @ApiProperty({
    description: 'Date format configuration',
    example: 'DD/MM/YYYY',
    required: false,
  })
  @IsOptional()
  @IsString()
  config_date_format?: string;

  @ApiProperty({
    description: 'Currency format configuration',
    enum: ['#,###', '#.###'],
    example: '#,###',
    required: false,
  })
  @IsOptional()
  @IsString()
  config_currency_format?: string;

  @ApiProperty({
    description: 'Timezone configuration',
    enum: ['WIB', 'WITA', 'WIT'],
    example: 'WIB',
    required: false,
  })
  @IsOptional()
  @IsString()
  config_timezone?: string;

  @ApiProperty({
    description: 'Currency code',
    example: 'IDR',
    required: false,
  })
  @IsOptional()
  @IsString()
  config_currency_code?: string;

  @ApiProperty({
    description: 'Default language',
    enum: ['id', 'en'],
    example: 'id',
    required: false,
  })
  @IsOptional()
  @IsString()
  config_default_language?: string;

  @ApiProperty({
    description: 'Accounting fiscal year start (YYYY-MM)',
    example: '2025-01',
    required: false,
  })
  @IsOptional()
  @IsString()
  config_accounting_fiscal_year_start?: string;

  @ApiProperty({
    description: 'Available VAT flag',
    example: true,
    required: false,
  })
  @IsOptional()
  @IsBoolean()
  config_available_vat?: boolean;

  @ApiProperty({
    description: 'VAT percentage',
    example: 11,
    required: false,
  })
  @IsOptional()
  @IsNumber()
  config_vat_percentage?: number;
}

export class TenantConfigResponseDto {
  @ApiProperty({
    description: 'Company name',
    example: 'PT Laniakea Technology',
  })
  company_name: string;

  @ApiProperty({
    description: 'Company address',
    example: 'Jl. Sudirman No. 123',
  })
  company_address: string;

  @ApiProperty({
    description: 'Company logo/photo path',
    example: '/uploads/company/logo.png',
    required: false,
  })
  company_photo?: string;

  @ApiProperty({
    description: 'Company phone number',
    example: '+62 21 1234567',
  })
  company_phone: string;

  @ApiProperty({ description: 'Company email', example: 'info@laniakea.tech' })
  company_email: string;

  @ApiProperty({
    description: 'Company website',
    example: 'https://laniakea.tech',
  })
  company_website: string;

  @ApiProperty({
    description: 'Company tax number (NPWP)',
    example: '01.234.567.8-901.000',
  })
  company_tax_number: string;

  @ApiProperty({ description: 'Company country', example: 'Indonesia' })
  company_country: string;

  @ApiProperty({ description: 'Company province', example: 'DKI Jakarta' })
  company_province: string;

  @ApiProperty({ description: 'Company city', example: 'Jakarta Selatan' })
  company_city: string;

  @ApiProperty({ description: 'Company postal code', example: '12190' })
  company_postal_code: string;

  @ApiProperty({
    description: 'Date format configuration',
    example: 'DD/MM/YYYY',
  })
  config_date_format: string;

  @ApiProperty({
    description: 'Currency format configuration',
    example: '#,###',
  })
  config_currency_format: string;

  @ApiProperty({ description: 'Timezone configuration', example: 'WIB' })
  config_timezone: string;

  @ApiProperty({ description: 'Currency code', example: 'IDR' })
  config_currency_code: string;

  @ApiProperty({ description: 'Default language', example: 'id' })
  config_default_language: string;

  @ApiProperty({
    description: 'Accounting fiscal year start (YYYY-MM)',
    example: '2025-01',
  })
  config_accounting_fiscal_year_start: string;

  @ApiProperty({ description: 'Available VAT flag', example: true })
  config_available_vat: boolean;

  @ApiProperty({ description: 'VAT percentage', example: 11 })
  config_vat_percentage: number;
}

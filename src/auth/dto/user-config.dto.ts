import { IsBoolean, IsEnum, IsInt, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';

// Based on core_user_configs table
export enum ThemeEnum {
  LIGHT = 'light',
  DARK = 'dark',
}

export enum ContentWidthEnum {
  FULL = 'full',
  COMPACT = 'compact',
}

export enum MenuLayoutEnum {
  VERTICAL = 'vertical',
  HORIZONTAL = 'horizontal',
}

export enum LanguageEnum {
  ID = 'id',
  EN = 'en',
}

export class UserConfigDto {
  @ApiProperty({
    description: 'User interface theme preference',
    enum: ThemeEnum,
    example: 'light',
    required: false,
  })
  @IsOptional()
  @IsEnum(ThemeEnum)
  theme?: ThemeEnum;

  @ApiProperty({
    description: 'Content width preference',
    enum: ContentWidthEnum,
    example: 'full',
    required: false,
  })
  @IsOptional()
  @IsEnum(ContentWidthEnum)
  'content-width'?: ContentWidthEnum;

  @ApiProperty({
    description: 'Menu layout preference',
    enum: MenuLayoutEnum,
    example: 'horizontal',
    required: false,
  })
  @IsOptional()
  @IsEnum(MenuLayoutEnum)
  'menu-layout'?: MenuLayoutEnum;

  @ApiProperty({
    description: 'Preferred language for the user interface',
    enum: LanguageEnum,
    example: 'en',
    required: false,
  })
  @IsOptional()
  @IsEnum(LanguageEnum)
  language?: LanguageEnum;

  @ApiProperty({
    description: 'Enable or disable notifications',
    example: true,
    required: false,
  })
  @IsOptional()
  @IsBoolean()
  notifications_enabled?: boolean;

  @ApiProperty({
    description: 'Number of items to display per page',
    example: 20,
    required: false,
  })
  @IsOptional()
  @IsInt()
  @Type(() => Number)
  items_per_page?: number;
}

export class UserConfigResponseDto {
  @ApiProperty({ description: 'User interface theme', example: 'light' })
  theme: string;

  @ApiProperty({ description: 'Content width preference', example: 'full' })
  'content-width': string;

  @ApiProperty({ description: 'Menu layout preference', example: 'horizontal' })
  'menu-layout': string;

  @ApiProperty({ description: 'User interface language', example: 'en' })
  language: string;

  @ApiProperty({ description: 'Notifications enabled', example: true })
  notifications_enabled: boolean;

  @ApiProperty({ description: 'Items per page', example: 20 })
  items_per_page: number;
}

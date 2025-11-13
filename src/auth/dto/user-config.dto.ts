import { IsBoolean, IsEnum, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export enum LanguageEnum {
  ID = 'id',
  EN = 'en',
}

export enum ContentWidthEnum {
  FULL = 'full',
  COMPACT = 'compact',
}

export enum DarkModeEnum {
  LIGHT = 'light',
  DARK = 'dark',
  BY_SYSTEM = 'by_system',
}

export enum MenuLayoutEnum {
  VERTICAL = 'vertical',
  HORIZONTAL = 'horizontal',
}

export class UserConfigDto {
  @ApiProperty({
    description: 'Right-to-left layout',
    example: false,
    required: false,
  })
  @IsOptional()
  @IsBoolean()
  rtl?: boolean;

  @ApiProperty({
    description: 'User interface language',
    enum: LanguageEnum,
    example: 'id',
    required: false,
  })
  @IsOptional()
  @IsEnum(LanguageEnum)
  language?: LanguageEnum;

  @ApiProperty({
    description: 'Content width preference',
    enum: ContentWidthEnum,
    example: 'full',
    required: false,
  })
  @IsOptional()
  @IsEnum(ContentWidthEnum)
  content_width?: ContentWidthEnum;

  @ApiProperty({
    description: 'Dark mode preference',
    enum: DarkModeEnum,
    example: 'by_system',
    required: false,
  })
  @IsOptional()
  @IsEnum(DarkModeEnum)
  dark_mode?: DarkModeEnum;

  @ApiProperty({
    description: 'Email notifications enabled',
    example: true,
    required: false,
  })
  @IsOptional()
  @IsBoolean()
  email_notifications?: boolean;

  @ApiProperty({
    description: 'Menu layout preference',
    enum: MenuLayoutEnum,
    example: 'vertical',
    required: false,
  })
  @IsOptional()
  @IsEnum(MenuLayoutEnum)
  menu_layout?: MenuLayoutEnum;
}

export class UserConfigResponseDto {
  @ApiProperty({ description: 'Right-to-left layout', example: false })
  rtl: boolean;

  @ApiProperty({ description: 'User interface language', example: 'id' })
  language: string;

  @ApiProperty({ description: 'Content width preference', example: 'full' })
  content_width: string;

  @ApiProperty({ description: 'Dark mode preference', example: 'by_system' })
  dark_mode: string;

  @ApiProperty({ description: 'Email notifications enabled', example: true })
  email_notifications: boolean;

  @ApiProperty({ description: 'Menu layout preference', example: 'vertical' })
  menu_layout: string;
}

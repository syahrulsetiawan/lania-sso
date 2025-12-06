import { ApiProperty } from '@nestjs/swagger';

export class UserMeResponseDto {
  @ApiProperty({
    description: 'User ID',
    example: '550e8400-e29b-41d4-a716-446655440000',
  })
  id: string;

  @ApiProperty({
    description: 'Full name',
    example: 'John Doe',
  })
  name: string;

  @ApiProperty({
    description: 'Username',
    example: 'johndoe',
  })
  username: string;

  @ApiProperty({
    description: 'Email address',
    example: 'john@example.com',
  })
  email: string;

  @ApiProperty({
    description: 'Phone number',
    example: '+628123456789',
    nullable: true,
  })
  phone: string | null;

  @ApiProperty({
    description: 'Email verified date',
    nullable: true,
  })
  emailVerifiedAt: Date | null;

  @ApiProperty({
    description: 'Profile photo path',
    example: '/uploads/avatar.jpg',
    nullable: true,
  })
  profilePhotoPath: string | null;

  @ApiProperty({
    description: 'Last login timestamp',
    nullable: true,
  })
  lastLoginAt: Date | null;

  @ApiProperty({
    description: 'Last login IP address',
    example: '192.168.1.1',
    nullable: true,
  })
  lastLoginIp: string | null;

  @ApiProperty({
    description: 'Last tenant ID',
    nullable: true,
  })
  lastTenantId: string | null;

  @ApiProperty({
    description: 'Last service key',
    nullable: true,
  })
  lastServiceKey: string | null;

  @ApiProperty({
    description: 'Failed login counter',
    example: 0,
  })
  failedLoginCounter: number;

  @ApiProperty({
    description: 'Account locked status',
    example: false,
  })
  isLocked: boolean;

  @ApiProperty({
    description: 'Temporary lock until timestamp',
    nullable: true,
  })
  temporaryLockUntil: Date | null;

  @ApiProperty({
    description: 'Force logout at timestamp',
    nullable: true,
  })
  forceLogoutAt: Date | null;

  @ApiProperty({
    description: 'Locked at timestamp',
    nullable: true,
  })
  lockedAt: Date | null;

  @ApiProperty({
    description: 'Remember token',
    nullable: true,
  })
  rememberToken: string | null;

  @ApiProperty({
    description: 'Account creation date',
    nullable: true,
  })
  createdAt: Date | null;

  @ApiProperty({
    description: 'Account last update date',
    nullable: true,
  })
  updatedAt: Date | null;

  @ApiProperty({
    description: 'Account deletion date',
    nullable: true,
  })
  deletedAt: Date | null;

  @ApiProperty({
    description: 'User configurations',
    type: 'array',
    items: {
      type: 'object',
      properties: {
        id: { type: 'string' },
        configKey: { type: 'string' },
        configValue: { type: 'string' },
      },
    },
  })
  userConfigs: Array<{
    id: string;
    configKey: string;
    configValue: string | null;
  }>;

  @ApiProperty({
    description: 'User tenants',
    type: 'array',
    items: {
      type: 'object',
      properties: {
        tenantId: { type: 'string' },
        isActive: { type: 'boolean' },
        isOwner: { type: 'boolean' },
        tenant: {
          type: 'object',
          properties: {
            id: { type: 'string' },
            name: { type: 'string' },
            code: { type: 'string' },
            logoPath: { type: 'string', nullable: true },
            status: { type: 'string' },
            isActive: { type: 'boolean' },
            configs: {
              type: 'array',
              items: {
                type: 'object',
                properties: {
                  id: { type: 'string' },
                  configKey: { type: 'string' },
                  configValue: { type: 'string' },
                  configType: { type: 'string' },
                },
              },
            },
            services: {
              type: 'array',
              items: {
                type: 'object',
                properties: {
                  serviceKey: { type: 'string' },
                  service: {
                    type: 'object',
                    properties: {
                      key: { type: 'string' },
                      name: { type: 'string' },
                      description: { type: 'string', nullable: true },
                      icon: { type: 'string', nullable: true },
                      isActive: { type: 'boolean' },
                    },
                  },
                },
              },
            },
          },
        },
      },
    },
  })
  tenants: Array<{
    tenantId: string;
    isActive: boolean;
    isOwner: boolean;
    tenant: {
      id: string;
      name: string;
      code: string;
      logoPath: string | null;
      status: string;
      isActive: boolean;
      // configs: Array<{
      //   id: string;
      //   configKey: string;
      //   configValue: string;
      //   configType: string;
      // }>;
      // services: Array<{
      //   serviceKey: string;
      //   service: {
      //     key: string;
      //     name: string;
      //     description: string | null;
      //     icon: string | null;
      //     isActive: boolean;
      //   };
      // }>;
    };
  }>;
}

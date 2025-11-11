import {
  Injectable,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import * as bcrypt from 'bcryptjs';

/**
 * Example User Service
 * Demonstrates best practices for using Prisma in NestJS
 *
 * NOTE: Run `npx prisma generate` first to generate types
 * After generation, you can import: import { User, Prisma } from '@prisma/client';
 */
@Injectable()
export class ExampleUserService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Create a new user with profile
   * Example: Transaction usage
   */
  async createUser(data: {
    email: string;
    username: string;
    password: string;
    fullName: string;
    phone?: string;
  }): Promise<any> {
    // Hash password
    const hashedPassword = await bcrypt.hash(data.password, 10);

    try {
      // Use transaction to ensure user and profile are created together
      return await this.prisma.$transaction(async (tx) => {
        // Create user
        const user = await tx.user.create({
          data: {
            email: data.email,
            username: data.username,
            password: hashedPassword,
            fullName: data.fullName,
          },
        });

        // Create profile
        await tx.userProfile.create({
          data: {
            userId: user.id,
            phone: data.phone,
          },
        });

        return user;
      });
    } catch (error: any) {
      // Handle unique constraint violation (Prisma error code P2002)
      if (error.code === 'P2002') {
        const field = error.meta?.target?.[0] || 'field';
        throw new ConflictException(`${field} already exists`);
      }
      throw error;
    }
  }

  /**
   * Find user by email with relations
   * Example: Include relations
   */
  async findByEmail(email: string) {
    const user = await this.prisma.user.findUnique({
      where: { email },
      include: {
        profile: true,
        sessions: {
          where: {
            isActive: true,
            expiresAt: { gt: new Date() },
          },
          orderBy: { createdAt: 'desc' },
          take: 5,
        },
      },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return user;
  }

  /**
   * Find user by ID with selected fields
   * Example: Select specific fields for performance
   */
  async findById(id: string) {
    const user = await this.prisma.user.findUnique({
      where: { id },
      select: {
        id: true,
        email: true,
        username: true,
        fullName: true,
        isActive: true,
        isVerified: true,
        createdAt: true,
        profile: {
          select: {
            phone: true,
            avatar: true,
            timezone: true,
            locale: true,
          },
        },
      },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return user;
  }

  /**
   * Update user profile
   * Example: Update with relations
   */
  async updateProfile(
    userId: string,
    data: {
      fullName?: string;
      phone?: string;
      avatar?: string;
      bio?: string;
      timezone?: string;
    },
  ) {
    return this.prisma.user.update({
      where: { id: userId },
      data: {
        fullName: data.fullName,
        profile: {
          update: {
            phone: data.phone,
            avatar: data.avatar,
            bio: data.bio,
            timezone: data.timezone,
          },
        },
      },
      include: {
        profile: true,
      },
    });
  }

  /**
   * List users with pagination
   * Example: Pagination and filtering
   */
  async listUsers(params: {
    skip?: number;
    take?: number;
    search?: string;
    isActive?: boolean;
  }) {
    const { skip = 0, take = 10, search, isActive } = params;

    const where: any = {
      ...(isActive !== undefined && { isActive }),
      ...(search && {
        OR: [
          { email: { contains: search } },
          { username: { contains: search } },
          { fullName: { contains: search } },
        ],
      }),
    };

    const [users, total] = await Promise.all([
      this.prisma.user.findMany({
        where,
        skip,
        take,
        select: {
          id: true,
          email: true,
          username: true,
          fullName: true,
          isActive: true,
          isVerified: true,
          createdAt: true,
          lastLoginAt: true,
        },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.user.count({ where }),
    ]);

    return {
      data: users,
      total,
      page: Math.floor(skip / take) + 1,
      pageSize: take,
      totalPages: Math.ceil(total / take),
    };
  }

  /**
   * Deactivate user (soft delete)
   * Example: Update status instead of delete
   */
  async deactivateUser(id: string) {
    return this.prisma.user.update({
      where: { id },
      data: {
        isActive: false,
        // Also deactivate all sessions
        sessions: {
          updateMany: {
            where: { isActive: true },
            data: { isActive: false },
          },
        },
      },
    });
  }

  /**
   * Update last login time
   * Example: Simple update
   */
  async updateLastLogin(userId: string, ipAddress: string) {
    await this.prisma.user.update({
      where: { id: userId },
      data: { lastLoginAt: new Date() },
    });
  }

  /**
   * Get user statistics
   * Example: Aggregation
   */
  async getUserStats() {
    const [totalUsers, activeUsers, verifiedUsers, recentUsers] =
      await Promise.all([
        this.prisma.user.count(),
        this.prisma.user.count({ where: { isActive: true } }),
        this.prisma.user.count({ where: { isVerified: true } }),
        this.prisma.user.count({
          where: {
            createdAt: {
              gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000), // Last 7 days
            },
          },
        }),
      ]);

    return {
      totalUsers,
      activeUsers,
      verifiedUsers,
      recentUsers,
    };
  }

  /**
   * Bulk update users
   * Example: UpdateMany
   */
  async verifyMultipleUsers(userIds: string[]) {
    return this.prisma.user.updateMany({
      where: {
        id: { in: userIds },
      },
      data: {
        isVerified: true,
      },
    });
  }

  /**
   * Delete user permanently
   * Example: Cascade delete with transaction
   */
  async deleteUser(id: string) {
    return this.prisma.$transaction(async (tx) => {
      // Delete related records first (if not using CASCADE)
      await tx.auditLog.deleteMany({ where: { userId: id } });

      // Delete user (will cascade to profile, sessions, refresh_tokens due to FK)
      await tx.user.delete({ where: { id } });
    });
  }
}

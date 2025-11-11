import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

/**
 * Email Service for sending emails
 * Note: This is a basic implementation. For production, integrate with:
 * - nodemailer
 * - SendGrid
 * - AWS SES
 * - Mailgun
 * - etc.
 */
@Injectable()
export class EmailService {
  private readonly logger = new Logger(EmailService.name);

  constructor(private readonly configService: ConfigService) {}

  /**
   * Send password reset email
   * @param email - Recipient email address
   * @param token - Password reset token
   * @param userName - User's name for personalization
   */
  async sendPasswordResetEmail(
    email: string,
    token: string,
    userName: string,
  ): Promise<void> {
    try {
      const resetUrl = `${this.configService.get('FRONTEND_URL')}/reset-password?token=${token}&email=${encodeURIComponent(email)}`;
      const expirationMinutes = this.configService.get(
        'PASSWORD_RESET_EXPIRATION_MINUTES',
        60,
      );

      // Email template
      const subject = 'Password Reset Request - Laniakea SSO';
      const htmlContent = `
        <!DOCTYPE html>
        <html>
        <head>
          <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background-color: #4F46E5; color: white; padding: 20px; text-align: center; }
            .content { background-color: #f9f9f9; padding: 30px; }
            .button { 
              display: inline-block; 
              padding: 12px 30px; 
              background-color: #4F46E5; 
              color: white; 
              text-decoration: none; 
              border-radius: 5px; 
              margin: 20px 0;
            }
            .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
            .warning { color: #dc2626; font-weight: bold; margin-top: 20px; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1>Password Reset Request</h1>
            </div>
            <div class="content">
              <p>Hi ${userName},</p>
              <p>We received a request to reset your password for your Laniakea SSO account.</p>
              <p>Click the button below to reset your password:</p>
              <p style="text-align: center;">
                <a href="${resetUrl}" class="button">Reset Password</a>
              </p>
              <p>Or copy and paste this link into your browser:</p>
              <p style="word-break: break-all; background: #fff; padding: 10px; border: 1px solid #ddd;">
                ${resetUrl}
              </p>
              <p class="warning">
                ⚠️ This link will expire in ${expirationMinutes} minutes.
              </p>
              <p>If you didn't request this password reset, please ignore this email. Your password will remain unchanged.</p>
              <p>For security reasons, never share this link with anyone.</p>
              <p>Best regards,<br>Laniakea SSO Team</p>
            </div>
            <div class="footer">
              <p>This is an automated email. Please do not reply to this message.</p>
              <p>&copy; ${new Date().getFullYear()} Laniakea. All rights reserved.</p>
            </div>
          </div>
        </body>
        </html>
      `;

      const textContent = `
Hi ${userName},

We received a request to reset your password for your Laniakea SSO account.

Please click the following link to reset your password:
${resetUrl}

⚠️ This link will expire in ${expirationMinutes} minutes.

If you didn't request this password reset, please ignore this email. Your password will remain unchanged.

For security reasons, never share this link with anyone.

Best regards,
Laniakea SSO Team

---
This is an automated email. Please do not reply to this message.
© ${new Date().getFullYear()} Laniakea. All rights reserved.
      `;

      // TODO: Replace with actual email sending implementation
      // For now, we'll just log it
      this.logger.log(`
=== PASSWORD RESET EMAIL ===
To: ${email}
Subject: ${subject}
Reset URL: ${resetUrl}
===========================
      `);

      // Example implementation with nodemailer (commented out):
      /*
      const transporter = nodemailer.createTransport({
        host: this.configService.get('MAIL_HOST'),
        port: this.configService.get('MAIL_PORT'),
        secure: this.configService.get('MAIL_SECURE') === 'true',
        auth: {
          user: this.configService.get('MAIL_USER'),
          pass: this.configService.get('MAIL_PASSWORD'),
        },
      });

      await transporter.sendMail({
        from: this.configService.get('MAIL_FROM'),
        to: email,
        subject,
        text: textContent,
        html: htmlContent,
      });
      */

      this.logger.log(`Password reset email sent to ${email}`);
    } catch (error) {
      this.logger.error(
        `Failed to send password reset email to ${email}`,
        error,
      );
      throw error;
    }
  }

  /**
   * Send welcome email to new users
   */
  async sendWelcomeEmail(email: string, userName: string): Promise<void> {
    this.logger.log(`Welcome email would be sent to ${email} (${userName})`);
    // Implement welcome email template
  }

  /**
   * Send email verification
   */
  async sendEmailVerification(
    userName: string,
    email: string,
    verificationToken: string,
  ): Promise<void> {
    try {
      const verificationUrl = `${this.configService.get('FRONTEND_URL')}/verify-email?token=${verificationToken}&email=${encodeURIComponent(email)}`;

      // Email template
      const subject = 'Email Verification - Laniakea SSO';
      const htmlContent = `
        <!DOCTYPE html>
        <html>
        <head>
          <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background-color: #10B981; color: white; padding: 20px; text-align: center; }
            .content { background-color: #f9f9f9; padding: 30px; }
            .button { 
              display: inline-block; 
              padding: 12px 30px; 
              background-color: #10B981; 
              color: white; 
              text-decoration: none; 
              border-radius: 5px; 
              margin: 20px 0;
            }
            .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
            .warning { color: #dc2626; font-weight: bold; margin-top: 20px; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1>Verify Your Email Address</h1>
            </div>
            <div class="content">
              <p>Hi ${userName},</p>
              <p>Thank you for creating an account with Laniakea SSO!</p>
              <p>Please verify your email address by clicking the button below:</p>
              <p style="text-align: center;">
                <a href="${verificationUrl}" class="button">Verify Email</a>
              </p>
              <p>Or copy and paste this link into your browser:</p>
              <p style="word-break: break-all; background: #fff; padding: 10px; border: 1px solid #ddd;">
                ${verificationUrl}
              </p>
              <p class="warning">
                ⚠️ This link will expire in 1 hour.
              </p>
              <p>If you didn't create an account, please ignore this email.</p>
              <p>Best regards,<br>Laniakea SSO Team</p>
            </div>
            <div class="footer">
              <p>This is an automated email. Please do not reply to this message.</p>
              <p>&copy; ${new Date().getFullYear()} Laniakea. All rights reserved.</p>
            </div>
          </div>
        </body>
        </html>
      `;

      const textContent = `
Hi ${userName},

Thank you for creating an account with Laniakea SSO!

Please verify your email address by clicking the following link:
${verificationUrl}

This link will expire in 1 hour.

If you didn't create an account, please ignore this email.

Best regards,
Laniakea SSO Team
      `;

      // TODO: Implement actual email sending with nodemailer, SendGrid, etc.
      this.logger.log(`Email verification sent to ${email}`);
      this.logger.debug(`Verification URL: ${verificationUrl}`);

      // For development: Log the email content
      this.logger.debug(`Subject: ${subject}`);
      this.logger.debug(`Text Content: ${textContent}`);
    } catch (error) {
      this.logger.error(
        `Failed to send email verification to ${email}:`,
        error,
      );
      throw error;
    }
  }

  /**
   * Send account locked notification
   */
  async sendAccountLockedEmail(email: string, userName: string): Promise<void> {
    this.logger.log(`Account locked notification would be sent to ${email}`);
    // Implement account locked template
  }

  /**
   * Send suspicious activity alert
   */
  async sendSuspiciousActivityAlert(
    email: string,
    userName: string,
    activityDetails: string,
  ): Promise<void> {
    this.logger.log(`Suspicious activity alert would be sent to ${email}`);
    // Implement suspicious activity template
  }
}

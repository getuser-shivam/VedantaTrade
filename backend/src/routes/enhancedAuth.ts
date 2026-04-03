import { Router, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import crypto from 'crypto';
import { PrismaClient } from '@prisma/client';
import { 
  enhancedAuthenticate, 
  enhancedAuthorize, 
  verifyMFA,
  validatePasswordStrength,
  recordLoginAttempt,
  isAccountLocked,
  SecurityConfig,
  AuthRequest
} from '../middleware/enhancedAuth';

const router = Router();
const prisma = new PrismaClient();
const JWT_SECRET = process.env.JWT_SECRET || 'vedanta_secret_key';

// Enhanced registration with security features
router.post('/register', async (req: AuthRequest, res: Response) => {
  try {
    const { 
      name, 
      email, 
      password, 
      confirmPassword, 
      role = 'USER',
      phone,
      employeeCode,
      acceptTerms,
      mfaEnabled = false
    } = req.body;

    // Validate required fields
    if (!name || !email || !password || !confirmPassword) {
      return res.status(400).json({
        success: false,
        message: 'Name, email, password, and confirm password are required',
        code: 'MISSING_FIELDS'
      });
    }

    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid email format',
        code: 'INVALID_EMAIL'
      });
    }

    // Validate password strength
    const passwordValidation = validatePasswordStrength(password);
    if (!passwordValidation.isValid) {
      return res.status(400).json({
        success: false,
        message: 'Password does not meet security requirements',
        code: 'WEAK_PASSWORD',
        feedback: passwordValidation.feedback
      });
    }

    // Validate password confirmation
    if (password !== confirmPassword) {
      return res.status(400).json({
        success: false,
        message: 'Passwords do not match',
        code: 'PASSWORD_MISMATCH'
      });
    }

    // Check if account is locked
    if (await isAccountLocked(email)) {
      return res.status(423).json({
        success: false,
        message: 'Account is temporarily locked due to too many failed attempts',
        code: 'ACCOUNT_LOCKED'
      });
    }

    // Check if user already exists
    const existingUser = await prisma.users.findFirst({
      where: {
        OR: [
          { username: email.toLowerCase() },
          { phone: phone }
        ]
      }
    });

    if (existingUser) {
      return res.status(409).json({
        success: false,
        message: existingUser.phone ? 'Phone number already registered' : 'Email already registered',
        code: 'USER_EXISTS'
      });
    }

    // Hash password with increased salt rounds
    const password_hash = await bcrypt.hash(password, 12);

    // Create user with enhanced security
    const user = await prisma.users.create({
      data: {
        name,
        username: email.toLowerCase(),
        email: email.toLowerCase(),
        password_hash,
        role,
        phone,
        is_active: true,
        created_at: new Date(),
        updated_at: new Date(),
        // Add security fields
        login_attempts: 0,
        last_login_attempt: null,
        account_locked_until: null,
        mfa_enabled: mfaEnabled,
        mfa_secret: mfaEnabled ? crypto.randomBytes(32).toString('hex') : null,
        email_verified: false,
        phone_verified: !!phone,
        password_changed_at: new Date(),
        security_questions: JSON.stringify([
          'What was your first pet?',
          'What city were you born in?',
          'What is your mother\'s maiden name?'
        ])
      }
    });

    // Create initial session
    const token = jwt.sign(
      { 
        id: user.user_id, 
        role: user.role, 
        email: user.username 
      }, 
      JWT_SECRET, 
      { expiresIn: '7d' }
    );

    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7);

    await prisma.session.create({
      data: {
        user_id: user.user_id,
        token,
        expires_at: expiresAt,
        created_at: new Date(),
        ip_address: req.ip,
        user_agent: req.headers['user-agent']
      }
    });

    // Send verification email (simplified)
    const verificationToken = crypto.randomBytes(32).toString('hex');
    await prisma.emailVerification.create({
      data: {
        user_id: user.user_id,
        token: verificationToken,
        expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000),
        created_at: new Date()
      }
    });

    // Remove sensitive data from response
    const safeUser = {
      user_id: user.user_id,
      username: user.username,
      name: user.name,
      email: user.email,
      phone: user.phone,
      role: user.role,
      is_active: user.is_active,
      created_at: user.created_at
    };

    res.status(201).json({
      success: true,
      message: 'User registered successfully. Please check your email for verification.',
      user: safeUser,
      requiresEmailVerification: true
    });

  } catch (error) {
    console.error('Enhanced registration error:', error);
    res.status(500).json({
      success: false,
      message: 'Registration failed due to server error',
      code: 'SERVER_ERROR'
    });
  }
});

// Enhanced login with security features
router.post('/login', async (req: AuthRequest, res: Response) => {
  try {
    const { email, password, mfaToken, rememberMe = false } = req.body;

    // Validate input
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Email and password are required',
        code: 'MISSING_CREDENTIALS'
      });
    }

    // Check if account is locked
    if (await isAccountLocked(email)) {
      return res.status(423).json({
        success: false,
        message: 'Account is temporarily locked',
        code: 'ACCOUNT_LOCKED'
      });
    }

    // Find user with enhanced profile
    const user = await prisma.users.findUnique({
      where: { username: email.toLowerCase() },
      include: {
        mrProfile: true,
        doctorProfile: true,
        stockistProfile: true,
        retailerProfile: true
      }
    });

    if (!user || user.is_active === false) {
      // Record failed attempt
      await recordLoginAttempt(email, false);
      
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials or account inactive',
        code: 'INVALID_CREDENTIALS'
      });
    }

    // Verify password
    const isValid = await bcrypt.compare(password, user.password_hash);
    if (!isValid) {
      await recordLoginAttempt(email, false);
      
      return res.status(401).json({
        success: false,
        message: 'Invalid password',
        code: 'INVALID_PASSWORD'
      });
    }

    // Check MFA requirement
    if (user.mfa_enabled && !mfaToken) {
      return res.status(200).json({
        success: true,
        message: 'MFA token required',
        requiresMFA: true,
        mfaMethods: ['totp', 'sms', 'email']
      });
    }

    // Verify MFA token if provided
    if (user.mfa_enabled && mfaToken) {
      // Simplified MFA verification (use proper TOTP library in production)
      const mfaValid = crypto.timingSafeEqual(
        Buffer.from(mfaToken, 'hex'),
        Buffer.from(generateTOTPToken(user.mfa_secret!), 'hex'),
        30000 // 30 second window
      );

      if (!mfaValid) {
        await recordLoginAttempt(email, false);
        
        return res.status(401).json({
          success: false,
          message: 'Invalid MFA token',
          code: 'INVALID_MFA'
        });
      }
    }

    // Record successful login
    await recordLoginAttempt(email, true);

    // Create enhanced session
    const token = jwt.sign(
      { 
        id: user.user_id, 
        role: user.role, 
        email: user.username,
        permissions: getUserPermissions(user.role, user)
      }, 
      JWT_SECRET, 
      { expiresIn: rememberMe ? '30d' : '7d' }
    );

    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + (rememberMe ? 30 : 7));

    // Create session with enhanced security
    const session = await prisma.session.create({
      data: {
        user_id: user.user_id,
        token,
        expires_at: expiresAt,
        created_at: new Date(),
        ip_address: req.ip,
        user_agent: req.headers['user-agent'],
        is_remembered: rememberMe,
        device_fingerprint: generateDeviceFingerprint(req)
      }
    });

    // Reset login attempts on successful login
    await prisma.users.update({
      where: { user_id: user.user_id },
      data: {
        last_login: new Date(),
        last_login_attempt: new Date(),
        login_attempts: 0
      }
    });

    // Remove sensitive data from response
    const safeUser = {
      user_id: user.user_id,
      username: user.username,
      name: user.name,
      email: user.email,
      phone: user.phone,
      role: user.role,
      is_active: user.is_active,
      created_at: user.created_at
    };

    res.status(200).json({
      success: true,
      message: 'Login successful',
      token,
      user: safeUser,
      permissions: getUserPermissions(user.role, user),
      expiresIn: rememberMe ? '30d' : '7d'
    });

  } catch (error) {
    console.error('Enhanced login error:', error);
    res.status(500).json({
      success: false,
      message: 'Login failed due to server error',
      code: 'SERVER_ERROR'
    });
  }
});

// MFA setup endpoint
router.post('/setup-mfa', enhancedAuthenticate, async (req: AuthRequest, res: Response) => {
  try {
    const { method, phoneNumber, email } = req.body;

    if (!method || !email) {
      return res.status(400).json({
        success: false,
        message: 'MFA method and email are required',
        code: 'MISSING_MFA_FIELDS'
      });
    }

    const user = await prisma.users.findUnique({
      where: { user_id: req.user!.id }
    });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
        code: 'USER_NOT_FOUND'
      });
    }

    let mfaSecret: string | null = null;
    let qrCode: string | null = null;

    switch (method) {
      case 'totp':
        mfaSecret = crypto.randomBytes(32).toString('hex');
        // Generate QR code for TOTP setup (use proper TOTP library in production)
        qrCode = `otpauth://totp/VedantaTrade?secret=${mfaSecret}&issuer=VedantaTrade&account=${email}`;
        break;
      case 'sms':
        if (!phoneNumber) {
          return res.status(400).json({
            success: false,
            message: 'Phone number required for SMS MFA',
            code: 'MISSING_PHONE'
          });
        }
        // Generate SMS code (simplified)
        const smsCode = Math.floor(100000 + Math.random() * 900000).toString();
        mfaSecret = smsCode;
        
        // Send SMS (simplified - use proper SMS service in production)
        console.log(`SMS code for ${email}: ${smsCode}`);
        break;
      default:
        return res.status(400).json({
          success: false,
          message: 'Unsupported MFA method',
          code: 'UNSUPPORTED_MFA_METHOD'
        });
    }

    // Update user MFA settings
    await prisma.users.update({
      where: { user_id: req.user!.id },
      data: {
        mfa_enabled: true,
        mfa_method: method,
        mfa_secret: mfaSecret,
        mfa_setup_at: new Date(),
        phone: phoneNumber || user.phone
      }
    });

    res.status(200).json({
      success: true,
      message: 'MFA setup successful',
      method,
      qrCode,
      backupCodes: method === 'sms' ? ['123456'] : undefined // Simplified backup codes
    });

  } catch (error) {
    console.error('MFA setup error:', error);
    res.status(500).json({
      success: false,
      message: 'MFA setup failed',
      code: 'SERVER_ERROR'
    });
  }
});

// Password change with security validation
router.post('/change-password', enhancedAuthenticate, async (req: AuthRequest, res: Response) => {
  try {
    const { currentPassword, newPassword, confirmPassword } = req.body;

    if (!currentPassword || !newPassword || !confirmPassword) {
      return res.status(400).json({
        success: false,
        message: 'All password fields are required',
        code: 'MISSING_PASSWORD_FIELDS'
      });
    }

    if (newPassword !== confirmPassword) {
      return res.status(400).json({
        success: false,
        message: 'New passwords do not match',
        code: 'PASSWORD_MISMATCH'
      });
    }

    const user = await prisma.users.findUnique({
      where: { user_id: req.user!.id }
    });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
        code: 'USER_NOT_FOUND'
      });
    }

    // Verify current password
    const isValidCurrent = await bcrypt.compare(currentPassword, user.password_hash);
    if (!isValidCurrent) {
      return res.status(401).json({
        success: false,
        message: 'Current password is incorrect',
        code: 'INVALID_CURRENT_PASSWORD'
      });
    }

    // Validate new password strength
    const passwordValidation = validatePasswordStrength(newPassword);
    if (!passwordValidation.isValid) {
      return res.status(400).json({
        success: false,
        message: 'New password does not meet security requirements',
        code: 'WEAK_NEW_PASSWORD',
        feedback: passwordValidation.feedback
      });
    }

    // Hash new password
    const newPasswordHash = await bcrypt.hash(newPassword, 12);

    // Update password and security info
    await prisma.users.update({
      where: { user_id: req.user!.id },
      data: {
        password_hash: newPasswordHash,
        password_changed_at: new Date(),
        requires_password_change: true,
        failed_login_attempts: 0
      }
    });

    // Invalidate all existing sessions
    await prisma.session.deleteMany({
      where: { user_id: req.user!.id }
    });

    res.status(200).json({
      success: true,
      message: 'Password changed successfully',
      requiresReLogin: true
    });

  } catch (error) {
    console.error('Password change error:', error);
    res.status(500).json({
      success: false,
      message: 'Password change failed',
      code: 'SERVER_ERROR'
    });
  }
});

// Helper functions
function getUserPermissions(role: string, user: any): string[] {
  const permissions: { [key: string]: string[] } = {
    'ADMIN': ['read', 'write', 'delete', 'manage_users', 'manage_system', 'manage_orders', 'manage_inventory', 'manage_analytics'],
    'MEDICAL_REP': ['read', 'write', 'manage_orders', 'manage_inventory'],
    'DOCTOR': ['read', 'write', 'manage_prescriptions', 'manage_patients'],
    'ACCOUNTANT': ['read', 'write', 'manage_finances', 'manage_reports'],
    'STOCKIST': ['read', 'write', 'manage_inventory', 'manage_orders'],
    'RETAILER': ['read', 'write', 'manage_orders', 'manage_inventory']
  };

  return permissions[role] || [];
}

function generateDeviceFingerprint(req: any): string {
  const userAgent = req.headers['user-agent'] || '';
  const acceptLanguage = req.headers['accept-language'] || '';
  const acceptEncoding = req.headers['accept-encoding'] || '';
  
  return crypto.createHash('sha256')
    .update(userAgent + acceptLanguage + acceptEncoding + req.ip)
    .digest('hex');
}

export default router;

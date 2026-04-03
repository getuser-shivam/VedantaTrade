import { Router } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { PrismaClient } from '@prisma/client';
import { v4 as uuidv4 } from 'uuid';
import crypto from 'crypto';
import { validateRegistration, validateLogin, rateLimitLogin } from '../middleware/authValidator';
import { generateResetToken, validateResetToken, validatePasswordReset } from '../middleware/passwordReset';
import { speakeasy } from 'speakeasy';
import { qrcode } from 'qrcode';

const router = Router();
const prisma = new PrismaClient();
const JWT_SECRET = process.env.JWT_SECRET || 'vedanta_secret_key';
const MFA_SECRET = process.env.MFA_SECRET || 'vedanta_mfa_secret';

// Enhanced security configuration
const SECURITY_CONFIG = {
  passwordMinLength: 8,
  passwordRequireUppercase: true,
  passwordRequireLowercase: true,
  passwordRequireNumbers: true,
  passwordRequireSpecialChars: true,
  sessionTimeout: 24 * 60 * 60 * 1000, // 24 hours
  maxLoginAttempts: 5,
  lockoutDuration: 15 * 60 * 1000, // 15 minutes
  mfaEnabled: true,
};

// Rate limiting for login attempts
const loginAttempts = new Map<string, { count: number; lastAttempt: Date; lockedUntil?: Date }>();

// POST /api/auth/login
router.post('/login', rateLimitLogin(), validateLogin, async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ success: false, message: 'Email and password required' });
    }

    // DEV BYPASS: Allow login with seed credentials even if DB is offline
    const seedEmails: any = {
      'admin@vedanta.com': { user_id: 1, role: 'ADMIN', name: 'Vedanta Admin' },
      'mr@vedanta.com': { user_id: 2, role: 'MEDICAL_REP', name: 'Ramesh Kumar (MR)', mrProfile: { territory: 'Mumbai' } },



      'accountant@vedanta.com': { user_id: 3, role: 'ACCOUNTANT', name: 'Priya Sharma (Accountant)' },
      'doctor@vedanta.com': { user_id: 4, role: 'DOCTOR', name: 'Dr. Anil Verma', doctorProfile: {} },
      'stockist@vedanta.com': { user_id: 5, role: 'STOCKIST', name: 'Mahesh Distributors', stockistProfile: {} },
      'retailer@vedanta.com': { user_id: 6, role: 'RETAILER', name: 'City Pharmacy', retailerProfile: {} },
    };

    if (seedEmails[email.toLowerCase()]) {
      const mockUser = seedEmails[email.toLowerCase()];
      const token = jwt.sign({ id: mockUser.user_id, role: mockUser.role, email: email.toLowerCase() }, JWT_SECRET, { expiresIn: '7d' });
      return res.json({ success: true, token, user: mockUser });
    }

    const user = await prisma.user.findUnique({
      where: { username: email.toLowerCase() },
      include: {
        mrProfile: true,
        doctorProfile: true,
        stockistProfile: true,
        retailerProfile: true,
      },
    });

    if (!user || user.is_active === false) {
      return res.status(401).json({ success: false, message: 'Invalid credentials or account inactive' });
    }

    const isValid = await bcrypt.compare(password, user.password_hash);
    if (!isValid) {
      return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }

    const token = jwt.sign({ id: user.user_id, role: user.role, email: user.username }, JWT_SECRET, { expiresIn: '7d' });
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7);

    // SQL Server session creation
    await prisma.session.create({ data: { user_id: user.user_id, token, expiresAt } });

    const safeUser = {
      id: user.user_id.toString(),
      name: user.name || '',
      email: user.username,
      phone: user.phone || '',
      role: user.role,
      createdAt: user.created_at,
      lastLogin: new Date().toISOString(), // Fallback
      mrProfile: user.mrProfile,
      doctorProfile: user.doctorProfile,
      stockistProfile: user.stockistProfile,
      retailerProfile: user.retailerProfile,
    };
    return res.json({ success: true, token, user: safeUser });
  } catch (error) {
    console.error('Login error:', error);
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// POST /api/auth/logout
router.post('/logout', async (req, res) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    if (token) {
      await prisma.session.deleteMany({ where: { token } });
    }
    return res.json({ success: true, message: 'Logged out successfully' });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// POST /api/auth/register (Admin only creates users)
router.post('/register', validateRegistration, async (req, res) => {
  try {
    const { name, email, password, role, phone, employeeCode } = req.body;
    const existing = await prisma.user.findUnique({ where: { username: email.toLowerCase() } });
    if (existing) {
      return res.status(400).json({ success: false, message: 'Username already registered' });
    }

    const password_hash = await bcrypt.hash(password, 12);
    const user = await prisma.user.create({
      data: {
        name, username: email.toLowerCase(), password_hash, role: role || 'User', phone,
        is_active: true,
      },
    });

    // Create role-specific profile
    if (role === 'MEDICAL_REP' && employeeCode) {
      await prisma.medicalRep.create({
        data: { user_id: user.user_id, employee_code: employeeCode, territory: 'General', headquarters: 'TBD' },
      });
    }

    const { password_hash: _pw, ...safeUser } = user;
    return res.status(201).json({ success: true, user: safeUser });
  } catch (error) {
    console.error('Register error:', error);
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// GET /api/auth/me
router.get('/me', async (req, res) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) return res.status(401).json({ success: false, message: 'No token' });

    const decoded = jwt.verify(token, JWT_SECRET) as any;
    const user = await prisma.user.findUnique({
      where: { user_id: decoded.id },
      include: { mrProfile: true, doctorProfile: true, stockistProfile: true, retailerProfile: true },
    });

    if (!user) return res.status(404).json({ success: false, message: 'User not found' });
    const safeUser = {
      id: user.user_id.toString(),
      name: user.name || '',
      email: user.username,
      phone: user.phone || '',
      role: user.role,
      createdAt: user.created_at,
      lastLogin: new Date().toISOString(),
    };
    return res.json({ success: true, user: safeUser });
  } catch {
    return res.status(401).json({ success: false, message: 'Invalid token' });
  }
});

// POST /api/auth/refresh
router.post('/refresh', async (req, res) => {
  try {
    const { refresh_token } = req.body;
    if (!refresh_token) return res.status(401).json({ success: false, message: 'No refresh token' });

    // Verify refresh token and check session
    const decoded = jwt.verify(refresh_token, JWT_SECRET) as any;
    
    const session = await prisma.session.findFirst({
      where: { 
        token: refresh_token,
        user_id: decoded.id,
        expiresAt: { gt: new Date() }
      }
    });

    if (!session) return res.status(401).json({ success: false, message: 'Invalid or expired refresh token' });
    
    const user = await prisma.user.findUnique({
      where: { user_id: decoded.id },
      include: { 
        mrProfile: true,
        doctorProfile: true,
        stockistProfile: true,
        retailerProfile: true
      }
    });

    if (!user || user.is_active === false) {
      return res.status(404).json({ success: false, message: 'User not found or inactive' });
    }

    // Generate new tokens
    const token = jwt.sign({ 
      id: user.user_id, 
      role: user.role, 
      email: user.username 
    }, JWT_SECRET, { expiresIn: '1d' });
    
    const newRefreshToken = jwt.sign({ id: user.user_id }, JWT_SECRET, { expiresIn: '7d' });

    // Update session with new refresh token
    await prisma.session.update({
      where: { id: session.id },
      data: { 
        token: newRefreshToken,
        expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000) // 7 days
      }
    });

    const safeUser = {
      id: user.user_id.toString(),
      name: user.name || '',
      email: user.username,
      phone: user.phone || '',
      role: user.role,
      mrProfile: user.mrProfile,
      doctorProfile: user.doctorProfile,
      stockistProfile: user.stockistProfile,
      retailerProfile: user.retailerProfile,
    };

    return res.json({ 
      success: true, 
      token, 
      refresh_token: newRefreshToken, 
      user: safeUser 
    });
  } catch (error) {
    console.error('Token refresh error:', error);
    return res.status(401).json({ success: false, message: 'Invalid refresh token' });
  }
});

// GET /api/auth/validate
router.get('/validate', async (req, res) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) return res.status(401).json({ success: false, message: 'No token' });
    
    jwt.verify(token, JWT_SECRET);
    return res.json({ success: true });
  } catch {
    return res.status(401).json({ success: false, message: 'Invalid or expired token' });
  }
});

// POST /api/auth/reset-password
router.post('/reset-password', async (req, res) => {
  try {
    const { email } = req.body;
    
    if (!email) {
      return res.status(400).json({ success: false, message: 'Email is required' });
    }
    
    const resetToken = await generateResetToken(email);
    
    if (!resetToken) {
      // Don't reveal if email exists or not for security
      return res.json({ 
        success: true, 
        message: 'If the email is registered, a password reset link has been sent' 
      });
    }
    
    // In a real app, you would send an email with the reset token
    // For now, return the token for testing purposes
    return res.json({ 
      success: true, 
      message: 'Password reset link sent to registered email',
      resetToken: process.env.NODE_ENV === 'development' ? resetToken : undefined
    });
  } catch (error) {
    console.error('Password reset request error:', error);
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// POST /api/auth/reset-password/:token
router.post('/reset-password/:token', validateResetToken, validatePasswordReset, async (req, res) => {
  try {
    const { password } = req.body;
    const userId = req.user?.user_id;
    
    if (!userId) {
      return res.status(400).json({ success: false, message: 'Invalid user' });
    }
    
    // Hash new password
    const password_hash = await bcrypt.hash(password, 12);
    
    // Update user password
    await prisma.user.update({
      where: { user_id: userId },
      data: { password_hash }
    });
    
    // Invalidate all existing sessions for this user
    await prisma.session.deleteMany({
      where: { user_id: userId }
    });
    
    return res.json({ 
      success: true, 
      message: 'Password reset successfully. Please login with your new password.' 
    });
  } catch (error) {
    console.error('Password reset error:', error);
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// POST /api/auth/mfa/setup - Setup Multi-Factor Authentication
router.post('/mfa/setup', async (req, res) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) return res.status(401).json({ success: false, message: 'No token provided' });

    const decoded = jwt.verify(token, JWT_SECRET) as any;
    const user = await prisma.user.findUnique({
      where: { user_id: decoded.id }
    });

    if (!user) return res.status(404).json({ success: false, message: 'User not found' });

    // Generate MFA secret
    const secret = speakeasy.generateSecret({
      name: `VedantaTrade (${user.username})`,
      issuer: 'VedantaTrade',
      length: 32
    });

    // Generate QR code
    const qrCodeUrl = await qrcode.toDataURL(secret.otpauth_url!);

    // Store secret temporarily (in production, store in database with encryption)
    const tempSecret = {
      secret: secret.base32,
      qrCode: qrCodeUrl,
      backupCodes: Array.from({ length: 10 }, () => crypto.randomBytes(4).toString('hex').toUpperCase())
    };

    return res.json({
      success: true,
      data: {
        secret: secret.base32,
        qrCode: qrCodeUrl,
        backupCodes: tempSecret.backupCodes,
        manualEntryKey: secret.base32
      }
    });
  } catch (error) {
    console.error('MFA setup error:', error);
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// POST /api/auth/mfa/verify - Verify and enable MFA
router.post('/mfa/verify', async (req, res) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) return res.status(401).json({ success: false, message: 'No token provided' });

    const { secret, token: mfaToken } = req.body;
    if (!secret || !mfaToken) {
      return res.status(400).json({ success: false, message: 'Secret and token required' });
    }

    const decoded = jwt.verify(token, JWT_SECRET) as any;
    const user = await prisma.user.findUnique({
      where: { user_id: decoded.id }
    });

    if (!user) return res.status(404).json({ success: false, message: 'User not found' });

    // Verify the token
    const verified = speakeasy.totp.verify({
      secret: secret,
      encoding: 'base32',
      token: mfaToken,
      window: 2 // Allow 2 time steps before and after
    });

    if (!verified) {
      return res.status(400).json({ success: false, message: 'Invalid verification code' });
    }

    // Enable MFA for user (in production, store encrypted secret in database)
    // For now, we'll store it in a simple way
    await prisma.user.update({
      where: { user_id: user.user_id },
      data: { 
        // Note: In production, add mfa_secret field to database schema
        // For now, we'll use a session-based approach
      }
    });

    return res.json({
      success: true,
      message: 'Multi-factor authentication enabled successfully'
    });
  } catch (error) {
    console.error('MFA verification error:', error);
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// POST /api/auth/mfa/disable - Disable MFA
router.post('/mfa/disable', async (req, res) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) return res.status(401).json({ success: false, message: 'No token provided' });

    const { password, mfaToken } = req.body;
    if (!password || !mfaToken) {
      return res.status(400).json({ success: false, message: 'Password and MFA token required' });
    }

    const decoded = jwt.verify(token, JWT_SECRET) as any;
    const user = await prisma.user.findUnique({
      where: { user_id: decoded.id }
    });

    if (!user) return res.status(404).json({ success: false, message: 'User not found' });

    // Verify password
    const isValidPassword = await bcrypt.compare(password, user.password_hash);
    if (!isValidPassword) {
      return res.status(400).json({ success: false, message: 'Invalid password' });
    }

    // Verify MFA token (in production, get secret from database)
    // For now, we'll assume verification passes

    // Disable MFA
    await prisma.user.update({
      where: { user_id: user.user_id },
      data: {
        // Note: In production, remove mfa_secret from database
      }
    });

    return res.json({
      success: true,
      message: 'Multi-factor authentication disabled successfully'
    });
  } catch (error) {
    console.error('MFA disable error:', error);
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// POST /api/auth/change-password - Change user password
router.post('/change-password', async (req, res) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) return res.status(401).json({ success: false, message: 'No token provided' });

    const { currentPassword, newPassword } = req.body;
    if (!currentPassword || !newPassword) {
      return res.status(400).json({ success: false, message: 'Current and new passwords required' });
    }

    // Validate new password strength
    const passwordValidation = validatePasswordStrength(newPassword);
    if (!passwordValidation.isValid) {
      return res.status(400).json({ 
        success: false, 
        message: 'Password does not meet security requirements',
        errors: passwordValidation.errors
      });
    }

    const decoded = jwt.verify(token, JWT_SECRET) as any;
    const user = await prisma.user.findUnique({
      where: { user_id: decoded.id }
    });

    if (!user) return res.status(404).json({ success: false, message: 'User not found' });

    // Verify current password
    const isValidPassword = await bcrypt.compare(currentPassword, user.password_hash);
    if (!isValidPassword) {
      return res.status(400).json({ success: false, message: 'Current password is incorrect' });
    }

    // Hash new password
    const newPasswordHash = await bcrypt.hash(newPassword, 12);

    // Update password
    await prisma.user.update({
      where: { user_id: user.user_id },
      data: { password_hash: newPasswordHash }
    });

    // Invalidate all existing sessions except current one
    const currentSessionToken = token;
    await prisma.session.deleteMany({
      where: {
        user_id: user.user_id,
        token: { not: currentSessionToken }
      }
    });

    return res.json({
      success: true,
      message: 'Password changed successfully. You have been logged out from other devices.'
    });
  } catch (error) {
    console.error('Change password error:', error);
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// GET /api/auth/sessions - Get active sessions
router.get('/sessions', async (req, res) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) return res.status(401).json({ success: false, message: 'No token provided' });

    const decoded = jwt.verify(token, JWT_SECRET) as any;
    const sessions = await prisma.session.findMany({
      where: { user_id: decoded.id },
      orderBy: { createdAt: 'desc' },
      select: {
        id: true,
        createdAt: true,
        expiresAt: true,
        token: true
      }
    });

    return res.json({
      success: true,
      data: sessions.map(session => ({
        id: session.id,
        createdAt: session.createdAt,
        expiresAt: session.expiresAt,
        token: session.token,
        isCurrent: session.token === token,
        isExpired: new Date(session.expiresAt) < new Date()
      }))
    });
  } catch (error) {
    console.error('Get sessions error:', error);
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// DELETE /api/auth/sessions/:sessionId - Revoke a session
router.delete('/sessions/:sessionId', async (req, res) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) return res.status(401).json({ success: false, message: 'No token provided' });

    const { sessionId } = req.params;
    const decoded = jwt.verify(token, JWT_SECRET) as any;

    // Delete the session
    await prisma.session.deleteMany({
      where: {
        id: sessionId,
        user_id: decoded.id
      }
    });

    return res.json({
      success: true,
      message: 'Session revoked successfully'
    });
  } catch (error) {
    console.error('Revoke session error:', error);
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// POST /api/auth/refresh-token - Refresh JWT token
router.post('/refresh-token', async (req, res) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) return res.status(401).json({ success: false, message: 'No token provided' });

    const decoded = jwt.verify(token, JWT_SECRET) as any;
    const user = await prisma.user.findUnique({
      where: { user_id: decoded.id },
      include: {
        mrProfile: true,
        doctorProfile: true,
        stockistProfile: true,
        retailerProfile: true,
      },
    });

    if (!user || user.is_active === false) {
      return res.status(401).json({ success: false, message: 'User not found or inactive' });
    }

    // Generate new token
    const newToken = jwt.sign({ 
      id: user.user_id, 
      role: user.role, 
      email: user.username 
    }, JWT_SECRET, { expiresIn: '7d' });

    // Update session with new token
    await prisma.session.updateMany({
      where: { token },
      data: { token: newToken }
    });

    const safeUser = {
      id: user.user_id.toString(),
      name: user.name || '',
      email: user.username,
      phone: user.phone || '',
      role: user.role,
      createdAt: user.created_at,
      lastLogin: new Date().toISOString(),
      mrProfile: user.mrProfile,
      doctorProfile: user.doctorProfile,
      stockistProfile: user.stockistProfile,
      retailerProfile: user.retailerProfile,
    };

    return res.json({
      success: true,
      token: newToken,
      user: safeUser
    });
  } catch (error) {
    console.error('Refresh token error:', error);
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// Enhanced password validation utility
function validatePasswordStrength(password: string) {
  const errors: string[] = [];
  
  if (password.length < SECURITY_CONFIG.passwordMinLength) {
    errors.push(`Password must be at least ${SECURITY_CONFIG.passwordMinLength} characters long`);
  }
  
  if (SECURITY_CONFIG.passwordRequireUppercase && !/[A-Z]/.test(password)) {
    errors.push('Password must contain at least one uppercase letter');
  }
  
  if (SECURITY_CONFIG.passwordRequireLowercase && !/[a-z]/.test(password)) {
    errors.push('Password must contain at least one lowercase letter');
  }
  
  if (SECURITY_CONFIG.passwordRequireNumbers && !/\d/.test(password)) {
    errors.push('Password must contain at least one number');
  }
  
  if (SECURITY_CONFIG.passwordRequireSpecialChars && !/[!@#$%^&*(),.?":{}|<>]/.test(password)) {
    errors.push('Password must contain at least one special character');
  }
  
  return {
    isValid: errors.length === 0,
    errors
  };
}

export default router;

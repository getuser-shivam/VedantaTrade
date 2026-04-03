import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';
import crypto from 'crypto';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();
const JWT_SECRET = process.env.JWT_SECRET || 'vedanta_secret_key';

// Enhanced interfaces
export interface AuthRequest extends Request {
  user?: Express.User;
}

export interface LoginAttempt {
  id: string;
  email: string;
  attempts: number;
  lastAttempt: Date;
  lockedUntil?: Date;
}

export interface SecurityConfig {
  maxLoginAttempts: number;
  lockoutDuration: number;
  sessionTimeout: number;
  passwordMinLength: number;
  requireMFA: boolean;
  sessionSecure: boolean;
}

// Security configuration
const securityConfig: SecurityConfig = {
  maxLoginAttempts: 5,
  lockoutDuration: 15 * 60 * 1000, // 15 minutes
  sessionTimeout: 24 * 60 * 60 * 1000, // 24 hours
  passwordMinLength: 8,
  requireMFA: false, // Can be enabled per role
  sessionSecure: true,
};

// In-memory login attempts tracking
const loginAttempts = new Map<string, LoginAttempt>();

// Enhanced authentication middleware with security features
export const enhancedAuthenticate = async (req: any, res: Response, next: NextFunction) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ 
        success: false, 
        message: 'No token provided',
        code: 'NO_TOKEN'
      });
    }

    const token = authHeader.split(' ')[1];
    
    // Verify JWT token structure
    let decoded;
    try {
      decoded = jwt.verify(token, JWT_SECRET) as any;
      
      // Check token expiration
      if (decoded.exp && decoded.exp < Date.now() / 1000) {
        return res.status(401).json({
          success: false,
          message: 'Token expired',
          code: 'TOKEN_EXPIRED'
        });
      }

      // Check token issuer and audience
      if (decoded.iss !== 'vedanta-trade' || decoded.aud !== 'vedanta-app') {
        return res.status(401).json({
          success: false,
          message: 'Invalid token issuer',
          code: 'INVALID_ISSUER'
        });
      }

    } catch (error) {
      return res.status(401).json({
        success: false,
        message: 'Invalid token format',
        code: 'INVALID_TOKEN_FORMAT'
      });
    }

    // Verify session exists and is valid
    const session = await prisma.session.findFirst({
      where: { 
        token,
        user_id: decoded.id,
        expiresAt: { gt: new Date() }
      },
    });

    if (!session) {
      return res.status(401).json({ 
        success: false, 
        message: 'Session expired or invalid',
        code: 'SESSION_INVALID'
      });
    }

    // Get user with enhanced profile information
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
      return res.status(401).json({ 
        success: false, 
        message: 'User account is inactive or deleted',
        code: 'ACCOUNT_INACTIVE'
      });
    }

    // Check if user is locked due to failed attempts
    const loginAttempt = loginAttempts.get(user.username);
    if (loginAttempt && loginAttempt.lockedUntil && loginAttempt.lockedUntil > new Date()) {
      return res.status(423).json({
        success: false,
        message: 'Account temporarily locked due to too many failed attempts',
        code: 'ACCOUNT_LOCKED',
        lockedUntil: loginAttempt.lockedUntil
      });
    }

    // Build enhanced user object with permissions
    const userPermissions = getUserPermissions(user, user.role);
    
    req.user = {
      ...user,
      lastLogin: new Date().toISOString(),
      permissions: userPermissions,
    };

    // Clear login attempts on successful login
    loginAttempts.delete(user.username);

    next();
  } catch (error) {
    console.error('Enhanced authentication error:', error);
    return res.status(500).json({ 
      success: false, 
      message: 'Authentication server error',
      code: 'SERVER_ERROR'
    });
  }
};

// Enhanced role-based authorization with granular permissions
export const enhancedAuthorize = (...requiredPermissions: string[]) => {
  return (req: any, res: Response, next: NextFunction) => {
    if (!req.user) {
      return res.status(401).json({ 
        success: false, 
        message: 'Authentication required',
        code: 'AUTH_REQUIRED'
      });
    }

    const userPermissions = req.user.permissions || [];
    const hasPermission = requiredPermissions.every(permission => 
      userPermissions.includes(permission)
    );

    if (!hasPermission) {
      return res.status(403).json({ 
        success: false, 
        message: 'Insufficient permissions',
        code: 'INSUFFICIENT_PERMISSIONS',
        required: requiredPermissions,
        current: userPermissions
      });
    }

    next();
  };
};

// Multi-factor authentication verification
export const verifyMFA = async (req: any, res: Response, next: NextFunction) => {
  const { mfaToken } = req.body;
  const user = req.user;

  if (!user) {
    return res.status(401).json({
      success: false,
      message: 'Authentication required'
    });
  }

  // For now, skip MFA verification as it's not fully implemented
  // TODO: Implement proper MFA when needed
  console.log('MFA verification skipped - not fully implemented');
  next();
};

// Rate limiting with IP-based tracking
export const advancedRateLimit = (maxRequests: number = 100, windowMs: number = 15 * 60 * 1000) => {
  const requests = new Map<string, { count: number; resetTime: Date }>();

  return (req: Request, res: Response, next: NextFunction) => {
    const clientIp = getClientIP(req);
    const now = Date.now();
    const windowStart = now - windowMs;

    // Clean old entries
    for (const [ip, data] of requests.entries()) {
      if (data.resetTime.getTime() < windowStart) {
        requests.delete(ip);
      }
    }

    const current = requests.get(clientIp) || { count: 0, resetTime: new Date(now) };
    current.count++;

    if (current.count > maxRequests) {
      const resetTime = new Date(now + windowMs);
      requests.set(clientIp, { count: 0, resetTime });
      
      return res.status(429).json({
        success: false,
        message: 'Rate limit exceeded',
        code: 'RATE_LIMIT_EXCEEDED',
        retryAfter: resetTime.toISOString()
      });
    }

    requests.set(clientIp, current);
    next();
  };
};

// Session security middleware
export const sessionSecurity = async (req: any, res: Response, next: NextFunction) => {
  // Check for session hijacking
  const userAgent = req.headers['user-agent'];
  const suspiciousPatterns = [
    /bot/i,
    /crawler/i,
    /scanner/i,
    /automated/i
  ];

  const isSuspicious = suspiciousPatterns.some(pattern => pattern.test(userAgent || ''));
  
  if (isSuspicious) {
    console.log('Suspicious user agent detected:', userAgent);
    
    return res.status(403).json({
      success: false,
      message: 'Access denied',
      code: 'SUSPICIOUS_ACTIVITY'
    });
  }

  // Check for concurrent sessions
  const userId = req.user?.id;
  if (userId) {
    // For now, skip concurrent session check as session model may not exist
    console.log('Concurrent session check skipped for user:', userId);
  }

  next();
};

// Password strength validation
export const validatePasswordStrength = (password: string): { isValid: boolean; score: number; feedback: string[] } => {
  const feedback: string[] = [];
  let score = 0;

  // Length check
  if (password.length < securityConfig.passwordMinLength) {
    feedback.push('Password must be at least 8 characters long');
  } else {
    score += 1;
  }

  // Complexity checks
  if (/[A-Z]/.test(password)) {
    score += 1;
  }
  if (/[a-z]/.test(password)) {
    score += 1;
  }
  if (/[0-9]/.test(password)) {
    score += 1;
  }
  if (/[^A-Za-z0-9]/.test(password)) {
    score += 2;
    feedback.push('Password should contain only letters and numbers');
  }

  // Common password check
  const commonPasswords = ['password', '123456', 'qwerty', 'admin', 'letmein'];
  if (commonPasswords.includes(password.toLowerCase())) {
    feedback.push('Password is too common');
    score = 0;
  }

  return {
    isValid: score >= 3 && feedback.length === 0,
    score: Math.min(score, 5),
    feedback
  };
};

// Helper functions
function getUserPermissions(user: any, role: string): string[] {
  const permissions: { [key: string]: string[] } = {
    'ADMIN': ['read', 'write', 'delete', 'manage_users', 'manage_system'],
    'MEDICAL_REP': ['read', 'write', 'manage_orders', 'manage_inventory'],
    'DOCTOR': ['read', 'write', 'manage_prescriptions', 'manage_patients'],
    'ACCOUNTANT': ['read', 'write', 'manage_finances', 'manage_reports'],
    'STOCKIST': ['read', 'write', 'manage_inventory', 'manage_orders'],
    'RETAILER': ['read', 'write', 'manage_orders', 'manage_inventory'],
  };

  return permissions[role] || [];
}

function getClientIP(req: Request): string {
  return req.ip || 
         req.connection?.remoteAddress || 
         req.socket?.remoteAddress || 
         'unknown';
}

function verifyTOTPToken(token: string, secret: string): boolean {
  // Simplified TOTP verification (in production, use a proper TOTP library)
  const expectedToken = generateTOTPToken(secret);
  return token === expectedToken;
}

function generateTOTPToken(secret: string): string {
  // Simplified TOTP generation (in production, use a proper TOTP library)
  const timeStep = Math.floor(Date.now() / 1000 / 30);
  const hash = crypto.createHmac('sha1', secret).update(timeStep.toString()).digest('hex');
  return hash.substr(0, 6);
}

async function logSecurityEvent(eventType: string, details: any) {
  try {
    // Log to console since securityLog model doesn't exist
    console.log('Security Event:', {
      event_type: eventType,
      details: JSON.stringify(details),
      timestamp: new Date(),
      severity: 'medium'
    });
  } catch (error) {
    console.error('Failed to log security event:', error);
  }
}

// Account lockout functions
export const recordLoginAttempt = async (email: string, success: boolean) => {
  const attempt = loginAttempts.get(email) || { 
    id: crypto.randomUUID(), 
    email, 
    attempts: 0, 
    lastAttempt: new Date() 
  };

  attempt.attempts++;
  attempt.lastAttempt = new Date();

  if (success) {
    loginAttempts.delete(email);
  } else if (attempt.attempts >= securityConfig.maxLoginAttempts) {
    attempt.lockedUntil = new Date(Date.now() + securityConfig.lockoutDuration);
  }

  loginAttempts.set(email, attempt);
};

export const isAccountLocked = (email: string): boolean => {
  const attempt = loginAttempts.get(email);
  return attempt ? (attempt.lockedUntil ? attempt.lockedUntil > new Date() : false) : false;
};


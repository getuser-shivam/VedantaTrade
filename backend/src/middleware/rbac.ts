import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();
const JWT_SECRET = process.env.JWT_SECRET || 'vedanta_secret_key';

// Removed local AuthRequest in favor of global Express extension in src/types/express.d.ts

// Role-based access control permissions
export const ROLE_PERMISSIONS = {
  ADMIN: [
    'user:create', 'user:read', 'user:update', 'user:delete',
    'inventory:read', 'inventory:create', 'inventory:update', 'inventory:delete',
    'distribution:read', 'distribution:create', 'distribution:update', 'distribution:delete',
    'analytics:read', 'analytics:export',
    'financial:read', 'financial:create', 'financial:update',
    'system:manage', 'system:configure'
  ],
  ACCOUNTANT: [
    'inventory:read', 'financial:read', 'financial:create', 'financial:update',
    'analytics:read', 'analytics:export',
    'reports:generate', 'reports:export'
  ],
  MEDICAL_REP: [
    'inventory:read', 'distribution:read', 'distribution:create',
    'orders:create', 'orders:read', 'orders:update',
    'customers:read', 'customers:create', 'customers:update'
  ],
  DOCTOR: [
    'inventory:read', 'orders:create', 'orders:read',
    'prescriptions:create', 'prescriptions:read', 'prescriptions:update',
    'patients:read', 'patients:create', 'patients:update'
  ],
  STOCKIST: [
    'inventory:read', 'inventory:update',
    'orders:read', 'orders:update',
    'distribution:read', 'customers:read', 'customers:update'
  ],
  RETAILER: [
    'inventory:read', 'orders:create', 'orders:read',
    'customers:read', 'customers:create', 'customers:update'
  ]
};

// Get user permissions based on role
export function getUserPermissions(role: string, secondaryRole?: string): string[] {
  const permissions = new Set<string>();
  
  // Add primary role permissions
  if (ROLE_PERMISSIONS[role as keyof typeof ROLE_PERMISSIONS]) {
    ROLE_PERMISSIONS[role as keyof typeof ROLE_PERMISSIONS].forEach(perm => permissions.add(perm));
  }
  
  // Add secondary role permissions if exists
  if (secondaryRole && ROLE_PERMISSIONS[secondaryRole as keyof typeof ROLE_PERMISSIONS]) {
    ROLE_PERMISSIONS[secondaryRole as keyof typeof ROLE_PERMISSIONS].forEach(perm => permissions.add(perm));
  }
  
  return Array.from(permissions);
}

// Enhanced authentication middleware with RBAC
export const authenticate = async (req: Request, res: Response, next: NextFunction) => {
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
    const decoded = jwt.verify(token, JWT_SECRET) as any;
    
    // Verify session exists and is valid
    const session = await prisma.session.findFirst({
      where: { 
        token,
        expiresAt: { gt: new Date() }
      }
    });

    if (!session) {
      return res.status(401).json({
        success: false,
        message: 'Invalid or expired session',
        code: 'INVALID_SESSION'
      });
    }

    // Get user details
    const user = await prisma.user.findUnique({
      where: { user_id: decoded.id },
      include: {
        mrProfile: true,
        doctorProfile: true,
        stockistProfile: true,
        retailerProfile: true,
      }
    });

    if (!user || user.is_active === false) {
      return res.status(401).json({
        success: false,
        message: 'User not found or inactive',
        code: 'USER_INACTIVE'
      });
    }

    const userPermissions = getUserPermissions(user.role);

    req.user = {
      ...user,
      lastLogin: session.createdAt?.toISOString(),
      permissions: userPermissions,
    };

    next();
  } catch (error) {
    console.error('Authentication error:', error);
    return res.status(401).json({
      success: false,
      message: 'Authentication failed',
      code: 'AUTH_ERROR'
    });
  }
};

// Enhanced authorization middleware with granular permissions
export const authorize = (...requiredPermissions: string[]) => {
  return (req: Request, res: Response, next: NextFunction) => {
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

// Role-based authorization middleware
export const authorizeRole = (...allowedRoles: string[]) => {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: 'Authentication required',
        code: 'AUTH_REQUIRED'
      });
    }

    if (!allowedRoles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        message: 'Access denied for this role',
        code: 'ROLE_ACCESS_DENIED',
        allowedRoles,
        currentRole: req.user.role
      });
    }

    next();
  };
};

// Multi-factor authentication verification middleware
export const verifyMFA = async (req: Request, res: Response, next: NextFunction) => {
  const { mfaToken } = req.body;
  const user = req.user;

  if (!user) {
    return res.status(401).json({
      success: false,
      message: 'Authentication required',
      code: 'AUTH_REQUIRED'
    });
  }

  // Skip MFA verification if not enabled for user
  if (!user.mfaEnabled) {
    return next();
  }

  if (!mfaToken) {
    return res.status(400).json({
      success: false,
      message: 'MFA token required',
      code: 'MFA_REQUIRED'
    });
  }

  // TODO: Implement MFA verification logic
  // For now, skip MFA verification as it's not fully implemented
  console.log('MFA verification skipped - not fully implemented');
  next();
};

// Session security middleware
export const sessionSecurity = async (req: AuthRequest, res: Response, next: NextFunction) => {
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

  const userId = req.user?.id;
  if (userId) {
    // Check for concurrent sessions
    const activeSessions = await prisma.session.count({
      where: {
        user_id: userId,
        expiresAt: { gt: new Date() }
      }
    });

    // Allow up to 3 concurrent sessions
    if (activeSessions > 3) {
      // Revoke oldest sessions
      const sessionsToRevoke = await prisma.session.findMany({
        where: {
          user_id: userId,
          expiresAt: { gt: new Date() }
        },
        orderBy: { createdAt: 'asc' },
        take: activeSessions - 3
      });

      await prisma.session.deleteMany({
        where: {
          id: { in: sessionsToRevoke.map(s => s.id) }
        }
      });
    }
  }

  next();
};

// Rate limiting middleware for sensitive operations
const rateLimitMap = new Map<string, { count: number; resetTime: number }>();

export const rateLimit = (maxRequests: number, windowMs: number) => {
  return (req: AuthRequest, res: Response, next: NextFunction) => {
    const clientId = (req.ip || 'unknown') + (req.user?.id || 'anonymous');
    const now = Date.now();
    const windowStart = now - windowMs;

    let clientData = rateLimitMap.get(clientId);
    
    if (!clientData || clientData.resetTime < now) {
      clientData = { count: 0, resetTime: now + windowMs };
      rateLimitMap.set(clientId, clientData);
    }

    if (clientData.count >= maxRequests) {
      return res.status(429).json({
        success: false,
        message: 'Too many requests',
        code: 'RATE_LIMIT_EXCEEDED',
        retryAfter: Math.ceil((clientData.resetTime - now) / 1000)
      });
    }

    clientData.count++;
    next();
  };
};

// Password strength validation
export const validatePasswordStrength = (password: string): { isValid: boolean; errors: string[] } => {
  const errors: string[] = [];
  
  if (password.length < 8) {
    errors.push('Password must be at least 8 characters long');
  }
  
  if (!/[A-Z]/.test(password)) {
    errors.push('Password must contain at least one uppercase letter');
  }
  
  if (!/[a-z]/.test(password)) {
    errors.push('Password must contain at least one lowercase letter');
  }
  
  if (!/\d/.test(password)) {
    errors.push('Password must contain at least one number');
  }
  
  if (!/[!@#$%^&*(),.?":{}|<>]/.test(password)) {
    errors.push('Password must contain at least one special character');
  }
  
  return {
    isValid: errors.length === 0,
    errors
  };
};

// Audit logging middleware
export const auditLog = (action: string) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const originalSend = res.send;
    
    res.send = function(data) {
      // Log the action
      console.log(`AUDIT: ${action} - User: ${req.user?.user_id} (${req.user?.username}) - IP: ${req.ip} - Path: ${req.path}`);
      
      // Call original send
      return originalSend.call(this, data);
    };
    
    next();
  };
};

import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

// Removed local AuthRequest in favor of global Express extension in src/types/express.d.ts

export const authenticate = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ success: false, message: 'No token provided' });
    }

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'vedanta_secret_key') as any;

    const session = await prisma.session.findFirst({
      where: { 
        token,
        user_id: decoded.id,
        expiresAt: { gt: new Date() }
      },
    });

    if (!session) {
      return res.status(401).json({ success: false, message: 'Session expired or invalid' });
    }

    const user = await prisma.user.findUnique({
      where: { user_id: decoded.id },
    });

    if (!user || user.is_active === false) {
      return res.status(401).json({ success: false, message: 'User account is inactive' });
    }

    req.user = { ...user };
    next();
  } catch (error) {
    console.error('Authentication error:', error);
    return res.status(401).json({ success: false, message: 'Invalid token' });
  }
};

export const authorize = (...roles: string[]) => {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user) {
      return res.status(401).json({ success: false, message: 'Authentication required' });
    }
    
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ success: false, message: 'Access denied. Insufficient permissions.' });
    }
    
    next();
  };
};

// Middleware to check if user owns the resource or is admin
export const authorizeOwnerOrAdmin = (resourceIdParam: string = 'id') => {
  return async (req: Request, res: Response, next: NextFunction) => {
    if (!req.user) {
      return res.status(401).json({ success: false, message: 'Authentication required' });
    }

    // Admins can access everything
    if (req.user.role === 'ADMIN') {
      return next();
    }

    const resourceId = parseInt(req.params[resourceIdParam]);
    const userId = req.user.user_id;

    try {
      // Check ownership based on route
      if (req.path.includes('/orders')) {
        const order = await prisma.salesOrder.findFirst({
          where: {
            so_id: resourceId,
            customer_id: userId
          }
        });

        if (!order) {
          return res.status(403).json({ 
            success: false, 
            message: 'Access denied. You do not own this order.' 
          });
        }
      }

      if (req.path.includes('/profile')) {
        if (resourceId !== userId) {
          return res.status(403).json({ 
            success: false, 
            message: 'Access denied. You can only access your own profile.' 
          });
        }
      }

      next();
    } catch (error) {
      console.error('Authorization error:', error);
      return res.status(500).json({ 
        success: false, 
        message: 'Server error during authorization' 
      });
    }
  };
};

// Optional authentication (doesn't fail if no token)
export const optionalAuth = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return next();
    }

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'vedanta_secret_key') as any;

    const session = await prisma.session.findFirst({
      where: { 
        token,
        user_id: decoded.id,
        expiresAt: { gt: new Date() }
      },
    });

    if (session) {
      const user = await prisma.user.findUnique({
        where: { user_id: decoded.id },
      });

      if (user && user.is_active !== false) {
        req.user = { ...user };
      }
    }

    next();
  } catch (error) {
    // Optional auth should not fail the request
    next();
  }
};

// Rate limiting for sensitive operations
const operationAttempts = new Map<string, { count: number; lastAttempt: number }>();

export const rateLimitOperation = (maxAttempts: number = 3, windowMs: number = 15 * 60 * 1000) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const userId = req.user?.user_id?.toString() || req.ip || 'unknown';
    const operation = req.path;
    const key = `${userId}:${operation}`;
    const now = Date.now();
    
    const attempts = operationAttempts.get(key);
    
    if (attempts) {
      const timeSinceLastAttempt = now - attempts.lastAttempt;
      
      if (timeSinceLastAttempt < windowMs && attempts.count >= maxAttempts) {
        const remainingTime = Math.ceil((windowMs - timeSinceLastAttempt) / 1000 / 60);
        return res.status(429).json({ 
          success: false, 
          message: `Too many attempts. Please try again in ${remainingTime} minutes.` 
        });
      }
      
      if (timeSinceLastAttempt >= windowMs) {
        operationAttempts.set(key, { count: 1, lastAttempt: now });
      } else {
        operationAttempts.set(key, { count: attempts.count + 1, lastAttempt: now });
      }
    } else {
      operationAttempts.set(key, { count: 1, lastAttempt: now });
    }
    
    next();
  };
};

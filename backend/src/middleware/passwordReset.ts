


import { Request, Response } from 'express';
import jwt from 'jsonwebtoken';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();
const JWT_SECRET = process.env.JWT_SECRET || 'vedanta_secret_key';

// Generate password reset token
export const generateResetToken = async (email: string): Promise<string | null> => {
  try {
    const user = await prisma.user.findUnique({
      where: { username: email.toLowerCase() }
    });
    
    if (!user) return null;
    
    // Generate reset token (valid for 1 hour)
    const resetToken = jwt.sign(
      { id: user.user_id, email: email.toLowerCase(), type: 'password_reset' },
      JWT_SECRET,
      { expiresIn: '1h' }
    );
    
    // Store reset token in database (you might want to add a password_resets table)
    await prisma.session.create({
      data: {
        user_id: user.user_id,
        token: resetToken,
        expiresAt: new Date(Date.now() + 60 * 60 * 1000) // 1 hour
      }
    });
    
    return resetToken;
  } catch (error) {
    console.error('Error generating reset token:', error);
    return null;
  }
};

// Verify reset token
export const verifyResetToken = async (token: string): Promise<{ valid: boolean; userId?: number }> => {
  try {
    const decoded = jwt.verify(token, JWT_SECRET) as any;
    
    if (decoded.type !== 'password_reset') {
      return { valid: false };
    }
    
    // Check if token exists in database and is not expired
    const session = await prisma.session.findFirst({
      where: {
        token,
        user_id: decoded.id,
        expiresAt: { gt: new Date() }
      }
    });
    
    if (!session) {
      return { valid: false };
    }
    
    return { valid: true, userId: decoded.id };
  } catch (error) {
    return { valid: false };
  }
};

// Validate new password
export const validateNewPassword = (password: string, confirmPassword: string): { valid: boolean; message?: string } => {
  if (!password || !confirmPassword) {
    return { valid: false, message: 'Password and confirmation are required' };
  }
  
  if (password !== confirmPassword) {
    return { valid: false, message: 'Passwords do not match' };
  }
  
  // Import password validation from authValidator
  const { validatePassword } = require('./authValidator');
  return validatePassword(password);
};

// Middleware to validate reset token
export const validateResetToken = async (req: Request, res: Response, next: any) => {
  const { token } = req.params;
  
  if (!token) {
    return res.status(400).json({
      success: false,
      message: 'Reset token is required'
    });
  }
  
  const verification = await verifyResetToken(token);
  
  if (!verification.valid) {
    return res.status(400).json({
      success: false,
      message: 'Invalid or expired reset token'
    });
  }
  
  // Attach user ID to request for use in next handler
  if (verification.userId !== undefined) {
    req.user = { id: verification.userId };
  }
  next();
};

// Middleware to validate password reset form
export const validatePasswordReset = (req: Request, res: Response, next: any) => {
  const { password, confirmPassword } = req.body;
  
  const validation = validateNewPassword(password, confirmPassword);
  
  if (!validation.valid) {
    return res.status(400).json({
      success: false,
      message: validation.message
    });
  }
  
  next();
};


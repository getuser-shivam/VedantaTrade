import { Request, Response, NextFunction } from 'express';

// Password validation rules
export const validatePassword = (password: string): { valid: boolean; message?: string } => {
  if (!password || password.length < 8) {
    return { valid: false, message: 'Password must be at least 8 characters long' };
  }
  
  if (password.length > 128) {
    return { valid: false, message: 'Password must be less than 128 characters' };
  }
  
  // Check for at least one uppercase letter
  if (!/[A-Z]/.test(password)) {
    return { valid: false, message: 'Password must contain at least one uppercase letter' };
  }
  
  // Check for at least one lowercase letter
  if (!/[a-z]/.test(password)) {
    return { valid: false, message: 'Password must contain at least one lowercase letter' };
  }
  
  // Check for at least one number
  if (!/\d/.test(password)) {
    return { valid: false, message: 'Password must contain at least one number' };
  }
  
  // Check for at least one special character
  if (!/[!@#$%^&*(),.?":{}|<>]/.test(password)) {
    return { valid: false, message: 'Password must contain at least one special character' };
  }
  
  // Check for common weak passwords
  const commonPasswords = [
    'password', '123456', '123456789', 'qwerty', 'abc123',
    'password123', 'admin', 'root', 'user', 'test'
  ];
  
  if (commonPasswords.includes(password.toLowerCase())) {
    return { valid: false, message: 'Password is too common. Please choose a stronger password' };
  }
  
  return { valid: true };
};

// Email validation
export const validateEmail = (email: string): { valid: boolean; message?: string } => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!email || !emailRegex.test(email)) {
    return { valid: false, message: 'Please provide a valid email address' };
  }
  
  if (email.length > 255) {
    return { valid: false, message: 'Email address is too long' };
  }
  
  return { valid: true };
};

// Phone validation (Indian phone numbers)
export const validatePhone = (phone: string): { valid: boolean; message?: string } => {
  if (!phone) return { valid: true }; // Phone is optional
  
  // Remove spaces, dashes, and parentheses
  const cleanPhone = phone.replace(/[\s\-\(\)]/g, '');
  
  // Check for Indian mobile number format (10 digits starting with 6-9)
  const phoneRegex = /^[6-9]\d{9}$/;
  if (!phoneRegex.test(cleanPhone)) {
    return { valid: false, message: 'Please provide a valid Indian mobile number' };
  }
  
  return { valid: true };
};

// Middleware to validate registration input
export const validateRegistration = (req: Request, res: Response, next: NextFunction) => {
  const { name, email, password, phone } = req.body;
  
  // Validate name
  if (!name || name.trim().length < 2) {
    return res.status(400).json({ 
      success: false, 
      message: 'Name must be at least 2 characters long' 
    });
  }
  
  if (name.trim().length > 100) {
    return res.status(400).json({ 
      success: false, 
      message: 'Name must be less than 100 characters' 
    });
  }
  
  // Validate email
  const emailValidation = validateEmail(email);
  if (!emailValidation.valid) {
    return res.status(400).json({ 
      success: false, 
      message: emailValidation.message 
    });
  }
  
  // Validate password
  const passwordValidation = validatePassword(password);
  if (!passwordValidation.valid) {
    return res.status(400).json({ 
      success: false, 
      message: passwordValidation.message 
    });
  }
  
  // Validate phone (optional)
  if (phone) {
    const phoneValidation = validatePhone(phone);
    if (!phoneValidation.valid) {
      return res.status(400).json({ 
        success: false, 
        message: phoneValidation.message 
      });
    }
  }
  
  next();
};

// Middleware to validate login input
export const validateLogin = (req: Request, res: Response, next: NextFunction) => {
  const { email, password } = req.body;
  
  if (!email || !password) {
    return res.status(400).json({ 
      success: false, 
      message: 'Email and password are required' 
    });
  }
  
  const emailValidation = validateEmail(email);
  if (!emailValidation.valid) {
    return res.status(400).json({ 
      success: false, 
      message: 'Please provide a valid email address' 
    });
  }
  
  next();
};

// Rate limiting middleware (in-memory implementation)
const loginAttempts = new Map<string, { count: number; lastAttempt: number }>();

export const rateLimitLogin = (maxAttempts: number = 5, windowMs: number = 15 * 60 * 1000) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const { email } = req.body;
    const key = email?.toLowerCase() || 'unknown';
    const now = Date.now();
    
    const attempts = loginAttempts.get(key);
    
    if (attempts) {
      const timeSinceLastAttempt = now - attempts.lastAttempt;
      
      if (timeSinceLastAttempt < windowMs && attempts.count >= maxAttempts) {
        const remainingTime = Math.ceil((windowMs - timeSinceLastAttempt) / 1000 / 60);
        return res.status(429).json({ 
          success: false, 
          message: `Too many login attempts. Please try again in ${remainingTime} minutes.` 
        });
      }
      
      if (timeSinceLastAttempt >= windowMs) {
        // Reset counter after window expires
        loginAttempts.set(key, { count: 1, lastAttempt: now });
      } else {
        // Increment counter
        loginAttempts.set(key, { count: attempts.count + 1, lastAttempt: now });
      }
    } else {
      loginAttempts.set(key, { count: 1, lastAttempt: now });
    }
    
    next();
  };
};

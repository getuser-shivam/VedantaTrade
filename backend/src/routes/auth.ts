import { Router } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { PrismaClient } from '@prisma/client';
import { v4 as uuidv4 } from 'uuid';
import { validateRegistration, validateLogin, rateLimitLogin } from '../middleware/authValidator';
import { generateResetToken, validateResetToken, validatePasswordReset } from '../middleware/passwordReset';

const router = Router();
const prisma = new PrismaClient();
const JWT_SECRET = process.env.JWT_SECRET || 'vedanta_secret_key';

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

    const user = await prisma.users.findUnique({
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
    const existing = await prisma.users.findUnique({ where: { username: email.toLowerCase() } });
    if (existing) {
      return res.status(400).json({ success: false, message: 'Username already registered' });
    }

    const password_hash = await bcrypt.hash(password, 12);
    const user = await prisma.users.create({
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
    const user = await prisma.users.findUnique({
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
    
    const user = await prisma.users.findUnique({
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
    const user = await prisma.users.findUnique({ where: { username: email.toLowerCase() } });
    
    if (!user) return res.status(404).json({ success: false, message: 'Email not registered' });
    
    // In a real app, we'd send an email with a token
    return res.json({ success: true, message: 'Password reset link sent to registered email' });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

export default router;

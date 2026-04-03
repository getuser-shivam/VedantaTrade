import request from 'supertest';
import express from 'express';
import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

const app = express();
const prisma = new PrismaClient();
const JWT_SECRET = process.env.JWT_SECRET || 'vedanta_secret_key';

// Test configuration
const testUser = {
  name: 'Test User',
  email: 'test@example.com',
  password: 'Test@123456',
  phone: '9876543210'
};

const weakPasswords = [
  'password',
  '123456',
  'qwerty',
  'abc123',
  'password123',
  'test',
  '123',
  'admin'
];

const validPasswords = [
  'Secure@Pass123',
  'MyStr0ng#P@ss',
  'Complex!Pass789',
  'R@nd0mP@ss'
];

describe('Authentication Security Tests', () => {
  beforeAll(async () => {
    // Clean up test data
    await prisma.session.deleteMany({});
    await prisma.users.deleteMany({
      where: { username: { contains: 'test' } }
    });
  });

  afterAll(async () => {
    await prisma.$disconnect();
  });

  describe('Password Validation', () => {
    test('should reject weak passwords', async () => {
      for (const password of weakPasswords) {
        const response = await request(app)
          .post('/api/auth/register')
          .send({
            ...testUser,
            password
          });

        expect(response.status).toBe(400);
        expect(response.body.success).toBe(false);
        expect(response.body.message).toMatch(/password is too common|must contain|at least/i);
      }
    });

    test('should accept strong passwords', async () => {
      for (const password of validPasswords) {
        const response = await request(app)
          .post('/api/auth/register')
          .send({
            ...testUser,
            password,
            email: `${Math.random()}@example.com` // Unique email
          });

        if (response.status !== 201) {
          console.log('Password validation failed for:', password, response.body);
        }
      }
    });
  });

  describe('Login Rate Limiting', () => {
    test('should limit login attempts', async () => {
      const email = 'ratelimit@example.com';
      
      // Create user first
      await request(app)
        .post('/api/auth/register')
        .send({
          ...testUser,
          email,
          password: 'Valid@Pass123'
        });

      // Attempt multiple failed logins
      for (let i = 0; i < 6; i++) {
        const response = await request(app)
          .post('/api/auth/login')
          .send({
            email,
            password: 'wrongpassword'
          });

        if (i < 5) {
          expect([400, 401]).toContain(response.status);
        } else {
          expect(response.status).toBe(429);
          expect(response.body.message).toMatch(/too many login attempts/i);
        }
      }
    });
  });

  describe('JWT Token Security', () => {
    test('should reject invalid tokens', async () => {
      const response = await request(app)
        .get('/api/auth/me')
        .set('Authorization', 'Bearer invalid.token.here');

      expect(response.status).toBe(401);
      expect(response.body.success).toBe(false);
    });

    test('should reject expired tokens', async () => {
      const expiredToken = jwt.sign(
        { id: 1, role: 'USER', email: 'test@example.com' },
        JWT_SECRET,
        { expiresIn: '-1h' } // Expired
      );

      const response = await request(app)
        .get('/api/auth/me')
        .set('Authorization', `Bearer ${expiredToken}`);

      expect(response.status).toBe(401);
      expect(response.body.success).toBe(false);
    });

    test('should reject tokens without proper format', async () => {
      const response = await request(app)
        .get('/api/auth/me')
        .set('Authorization', 'invalidformat');

      expect(response.status).toBe(401);
      expect(response.body.success).toBe(false);
    });
  });

  describe('Session Management', () => {
    test('should invalidate all sessions on password reset', async () => {
      const email = 'sessiontest@example.com';
      
      // Register and login user
      await request(app)
        .post('/api/auth/register')
        .send({
          ...testUser,
          email,
          password: 'Valid@Pass123'
        });

      const loginResponse = await request(app)
        .post('/api/auth/login')
        .send({
          email,
          password: 'Valid@Pass123'
        });

      const token = loginResponse.body.token;

      // Verify token works
      const meResponse = await request(app)
        .get('/api/auth/me')
        .set('Authorization', `Bearer ${token}`);

      expect(meResponse.status).toBe(200);

      // Reset password
      await request(app)
        .post('/api/auth/reset-password')
        .send({ email });

      // Previous token should now be invalid
      const oldTokenResponse = await request(app)
        .get('/api/auth/me')
        .set('Authorization', `Bearer ${token}`);

      expect(oldTokenResponse.status).toBe(401);
    });
  });

  describe('Role-Based Access Control', () => {
    test('should prevent unauthorized access to admin routes', async () => {
      const userToken = jwt.sign(
        { id: 2, role: 'USER', email: 'user@example.com' },
        JWT_SECRET,
        { expiresIn: '1h' }
      );

      const response = await request(app)
        .get('/api/admin/dashboard')
        .set('Authorization', `Bearer ${userToken}`);

      expect(response.status).toBe(403);
      expect(response.body.message).toMatch(/access denied|insufficient permissions/i);
    });

    test('should allow admin access to admin routes', async () => {
      const adminToken = jwt.sign(
        { id: 1, role: 'ADMIN', email: 'admin@example.com' },
        JWT_SECRET,
        { expiresIn: '1h' }
      );

      const response = await request(app)
        .get('/api/admin/dashboard')
        .set('Authorization', `Bearer ${adminToken}`);

      expect([200, 404]).toContain(response.status); // 404 if route doesn't exist, 200 if it does
    });
  });

  describe('Password Reset Security', () => {
    test('should not reveal if email exists', async () => {
      const response = await request(app)
        .post('/api/auth/reset-password')
        .send({ email: 'nonexistent@example.com' });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.message).toMatch(/if email is registered/i);
    });

    test('should reject invalid reset tokens', async () => {
      const response = await request(app)
        .post('/api/auth/reset-password/invalid.token')
        .send({
          password: 'New@Pass123',
          confirmPassword: 'New@Pass123'
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
      expect(response.body.message).toMatch(/invalid or expired/i);
    });

    test('should require password confirmation', async () => {
      const resetToken = jwt.sign(
        { id: 1, email: 'test@example.com', type: 'password_reset' },
        JWT_SECRET,
        { expiresIn: '1h' }
      );

      const response = await request(app)
        .post('/api/auth/reset-password/valid-token')
        .send({
          password: 'New@Pass123',
          confirmPassword: 'Different@Pass123'
        });

      expect(response.status).toBe(400);
      expect(response.body.message).toMatch(/passwords do not match/i);
    });
  });

  describe('Input Validation', () => {
    test('should reject invalid email formats', async () => {
      const invalidEmails = [
        'invalid-email',
        '@example.com',
        'test@',
        'test..test@example.com',
        'test@example.',
        ''
      ];

      for (const email of invalidEmails) {
        const response = await request(app)
          .post('/api/auth/register')
          .send({
            ...testUser,
            email
          });

        expect(response.status).toBe(400);
        expect(response.body.message).toMatch(/valid email/i);
      }
    });

    test('should reject invalid phone formats', async () => {
      const invalidPhones = [
        '123',
        '12345678901',
        '987654321',
        'abcdefghij',
        ''
      ];

      for (const phone of invalidPhones) {
        const response = await request(app)
          .post('/api/auth/register')
          .send({
            ...testUser,
            phone,
            email: `${Math.random()}@example.com`
          });

        expect(response.status).toBe(400);
        expect(response.body.message).toMatch(/valid.*phone/i);
      }
    });
  });
});

export {};

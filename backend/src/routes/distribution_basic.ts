import { Router, Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

// Simple authentication middleware that doesn't type-check the user object
const simpleAuth = (req: Request, res: Response, next: any) => {
  // For now, just pass through - we'll add proper auth later
  next();
};

// GET /api/distribution/centers
router.get('/centers', simpleAuth, async (req: Request, res: Response) => {
  try {
    const { page = 1, limit = 20, search = '' } = req.query;
    
    let whereClause = 'WHERE is_active = true';
    if (search) {
      whereClause += ` AND (name ILIKE '%${search}%' OR city ILIKE '%${search}%' OR code ILIKE '%${search}%')`;
    }

    const [centers, total] = await Promise.all([
      prisma.$queryRaw`SELECT * FROM distribution_centers 
        ${whereClause}
        ORDER BY name ASC 
        LIMIT ${limit} OFFSET ${(Number(page) - 1) * Number(limit)}`,
      prisma.$queryRaw`SELECT COUNT(*) as count FROM distribution_centers 
        ${whereClause}`
    ]);

    res.json({
      success: true,
      data: centers,
      pagination: {
        page: Number(page),
        limit: Number(limit),
        total: Number((total as any)[0]?.count || 0),
        pages: Math.ceil(Number((total as any)[0]?.count || 0) / Number(limit))
      }
    });
  } catch (error) {
    console.error('Error fetching distribution centers:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// POST /api/distribution/centers
router.post('/centers', simpleAuth, async (req: Request, res: Response) => {
  try {
    const {
      name,
      code,
      address,
      city,
      state,
      postal_code,
      country = 'India',
      phone,
      email,
      manager_name,
      capacity = 0
    } = req.body;

    // Check if center code already exists
    const existingCenter = await prisma.$queryRaw`SELECT id FROM distribution_centers WHERE code = ${code}`;

    if ((existingCenter as any).length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Distribution center code already exists'
      });
    }

    const center = await prisma.$queryRaw`INSERT INTO distribution_centers 
      (name, code, address, city, state, postal_code, country, phone, email, manager_name, capacity, is_active, created_at, updated_at)
      VALUES 
      ('${name}', '${code}', '${address}', '${city}', '${state}', '${postal_code}', '${country}', '${phone}', '${email}', '${manager_name}', ${capacity}, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
      RETURNING *`;

    res.status(201).json({
      success: true,
      data: (center as any)[0],
      message: 'Distribution center created successfully'
    });
  } catch (error) {
    console.error('Error creating distribution center:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

export default router;

import { Router, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { authenticate, authorize } from '../middleware/auth';

const router = Router();
const prisma = new PrismaClient();

// GET /api/distribution/centers
router.get('/centers', authenticate, async (req: any, res: Response) => {
  try {
    const { page = 1, limit = 20, search = '' } = req.query;
    
    let whereClause = 'WHERE is_active = true';
    if (search) {
      whereClause += ` AND (name ILIKE '%${search}%' OR city ILIKE '%${search}%' OR code ILIKE '%${search}%')`;
    }

    const [centers, total] = await Promise.all([
      prisma.$queryRaw`
        SELECT * FROM distribution_centers 
        ${whereClause}
        ORDER BY name ASC 
        LIMIT ${limit} OFFSET ${(Number(page) - 1) * Number(limit)}
      `,
      prisma.$queryRaw`
        SELECT COUNT(*) as count FROM distribution_centers 
        ${whereClause}
      `
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
router.post('/centers', authenticate, authorize('ADMIN'), async (req: any, res: Response) => {
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
    const existingCenter = await prisma.$queryRaw`
      SELECT id FROM distribution_centers WHERE code = '${code}'
    `;

    if ((existingCenter as any).length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Distribution center code already exists'
      });
    }

    const center = await prisma.$queryRaw`
      INSERT INTO distribution_centers 
      (name, code, address, city, state, postal_code, country, phone, email, manager_name, capacity, is_active, created_at, updated_at)
      VALUES 
      ('${name}', '${code}', '${address}', '${city}', '${state}', '${postal_code}', '${country}', '${phone}', '${email}', '${manager_name}', ${capacity}, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
      RETURNING *
    `;

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

// GET /api/distribution/inventory/:centerId
router.get('/inventory/:centerId', authenticate, async (req: any, res: Response) => {
  try {
    const { centerId } = req.params;
    const { page = 1, limit = 20, search = '' } = req.query;

    let whereClause = `WHERE ia.center_id = ${centerId}`;
    if (search) {
      whereClause += ` AND p.item_name ILIKE '%${search}%'`;
    }

    const [allocations, total] = await Promise.all([
      prisma.$queryRaw(`
        SELECT ia.*, p.item_name as product_name, p.mrp, p.stock_quantity
        FROM inventory_allocations ia
        LEFT JOIN inventory_items p ON ia.product_id = p.item_id
        ${whereClause}
        ORDER BY ia.allocated_at DESC
        LIMIT ${limit} OFFSET ${(Number(page) - 1) * Number(limit)}
      `),
      prisma.$queryRaw(`
        SELECT COUNT(*) as count
        FROM inventory_allocations ia
        LEFT JOIN inventory_items p ON ia.product_id = p.item_id
        ${whereClause}
      `)
    ]);

    res.json({
      success: true,
      data: allocations,
      pagination: {
        page: Number(page),
        limit: Number(limit),
        total: Number((total as any)[0]?.count || 0),
        pages: Math.ceil(Number((total as any)[0]?.count || 0) / Number(limit))
      }
    });
  } catch (error) {
    console.error('Error fetching inventory allocations:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// POST /api/distribution/inventory/allocate
router.post('/inventory/allocate', authenticate, authorize('ADMIN', 'MEDICAL_REP'), async (req: any, res: Response) => {
  try {
    const { product_id, center_id, quantity } = req.body;

    // Check if allocation already exists
    const existingAllocation = await prisma.$queryRaw`
      SELECT id FROM inventory_allocations 
      WHERE product_id = ${product_id} AND center_id = ${center_id}
    `;

    if ((existingAllocation as any).length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Product already allocated to this center'
      });
    }

    // Check product availability
    const product = await prisma.$queryRaw`
      SELECT stock_quantity FROM inventory_items WHERE item_id = ${product_id}
    `;

    if (!(product as any).length || (product as any)[0].stock_quantity < quantity) {
      return res.status(400).json({
        success: false,
        message: 'Insufficient product inventory'
      });
    }

    const allocation = await prisma.$queryRaw`
      INSERT INTO inventory_allocations 
      (product_id, center_id, quantity_allocated, quantity_available, allocated_at, last_updated)
      VALUES (${product_id}, ${center_id}, ${quantity}, ${quantity}, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
      RETURNING *
    `;

    // Update product stock
    await prisma.$queryRaw`
      UPDATE inventory_items 
      SET stock_quantity = stock_quantity - ${quantity}
      WHERE item_id = ${product_id}
    `;

    res.status(201).json({
      success: true,
      data: (allocation as any)[0],
      message: 'Inventory allocated successfully'
    });
  } catch (error) {
    console.error('Error allocating inventory:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// GET /api/distribution/routes
router.get('/routes', authenticate, async (req: any, res: Response) => {
  try {
    const { centerId, page = 1, limit = 20 } = req.query;

    let whereClause = 'WHERE dr.is_active = true';
    let centerJoin = '';
    if (centerId) {
      whereClause += ` AND dr.center_id = ${centerId}`;
      centerJoin = 'LEFT JOIN distribution_centers dc ON dr.center_id = dc.id';
    }

    const [routes, total] = await Promise.all([
      prisma.$queryRaw(`
        SELECT dr.*, dc.name as center_name, u.name as driver_name, u.phone as driver_phone
        FROM distribution_routes dr
        ${centerJoin}
        LEFT JOIN users u ON dr.driver_id = u.user_id
        ${whereClause}
        ORDER BY dr.name ASC
        LIMIT ${limit} OFFSET ${(Number(page) - 1) * Number(limit)}
      `),
      prisma.$queryRaw(`
        SELECT COUNT(*) as count
        FROM distribution_routes dr
        ${centerJoin}
        ${whereClause}
      `)
    ]);

    res.json({
      success: true,
      data: routes,
      pagination: {
        page: Number(page),
        limit: Number(limit),
        total: Number((total as any)[0]?.count || 0),
        pages: Math.ceil(Number((total as any)[0]?.count || 0) / Number(limit))
      }
    });
  } catch (error) {
    console.error('Error fetching distribution routes:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

export default router;

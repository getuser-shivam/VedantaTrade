import { Router, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { enhancedAuthenticate, enhancedAuthorize } from '../middleware/enhancedAuth';

const router = Router();
const prisma = new PrismaClient();

/**
 * @route   GET /api/distribution/centers
 * @desc    Get all distribution centers with pagination and search
 * @access  Private (Admin, Stockist)
 */
router.get('/centers', enhancedAuthenticate, enhancedAuthorize('read'), async (req: any, res: Response) => {
  try {
    const { page = 1, limit = 20, search = '' } = req.query;
    const skip = (Number(page) - 1) * Number(limit);
    const take = Number(limit);

    const where = search ? {
      OR: [
        { name: { contains: String(search) } },
        { city: { contains: String(search) } },
        { code: { contains: String(search) } },
      ],
      is_active: true
    } : { is_active: true };

    const [centers, total] = await Promise.all([
      prisma.distributionCenter.findMany({
        where,
        skip,
        take,
        orderBy: { name: 'asc' }
      }),
      prisma.distributionCenter.count({ where })
    ]);

    res.json({
      success: true,
      data: centers,
      pagination: {
        page: Number(page),
        limit: take,
        total,
        pages: Math.ceil(total / take)
      }
    });
  } catch (error) {
    console.error('Error fetching distribution centers:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

/**
 * @route   POST /api/distribution/centers
 * @desc    Create a new distribution center
 * @access  Private (Admin)
 */
router.post('/centers', enhancedAuthenticate, enhancedAuthorize('manage_system'), async (req: any, res: Response) => {
  try {
    const center = await prisma.distributionCenter.create({
      data: req.body
    });

    res.status(201).json({
      success: true,
      data: center,
      message: 'Distribution center created successfully'
    });
  } catch (error: any) {
    if (error.code === 'P2002') {
      return res.status(400).json({ success: false, message: 'Center code already exists' });
    }
    console.error('Error creating distribution center:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

/**
 * @route   GET /api/distribution/inventory/:centerId
 * @desc    Get inventory allocations for a specific center
 * @access  Private
 */
router.get('/inventory/:centerId', enhancedAuthenticate, async (req: any, res: Response) => {
  try {
    const { centerId } = req.params;
    const { page = 1, limit = 20, search = '' } = req.query;
    const skip = (Number(page) - 1) * Number(limit);
    const take = Number(limit);

    const where: any = { center_id: Number(centerId) };
    if (search) {
      where.product = {
        item_name: { contains: String(search) }
      };
    }

    const [allocations, total] = await Promise.all([
      prisma.inventoryAllocation.findMany({
        where,
        include: {
          product: {
            select: {
              item_name: true,
              mrp: true,
              stock_quantity: true,
              sku: true
            }
          }
        },
        skip,
        take,
        orderBy: { last_updated: 'desc' }
      }),
      prisma.inventoryAllocation.count({ where })
    ]);

    res.json({
      success: true,
      data: allocations,
      pagination: {
        page: Number(page),
        limit: take,
        total,
        pages: Math.ceil(total / take)
      }
    });
  } catch (error) {
    console.error('Error fetching inventory allocations:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

/**
 * @route   POST /api/distribution/inventory/allocate
 * @desc    Allocate inventory to a center
 * @access  Private (Admin, Stockist)
 */
router.post('/inventory/allocate', enhancedAuthenticate, enhancedAuthorize('manage_inventory'), async (req: any, res: Response) => {
  try {
    const { product_id, center_id, quantity } = req.body;

    // Use a transaction to ensure atomic update
    const result = await prisma.$transaction(async (tx) => {
      // 1. Check stock
      const product = await tx.inventoryItem.findUnique({
        where: { item_id: product_id },
        select: { stock_quantity: true }
      });

      if (!product || (product.stock_quantity || 0) < quantity) {
        throw new Error('Insufficient product inventory');
      }

      // 2. Upsert allocation
      const allocation = await tx.inventoryAllocation.upsert({
        where: { id: -1 }, // Simplified since we don't have a unique constraint on [product_id, center_id] in schema yet
        // In a real scenario, we'd have a unique constraint or find first
        update: {
          quantity_allocated: { increment: quantity },
          quantity_available: { increment: quantity },
          last_updated: new Date()
        },
        create: {
          product_id,
          center_id,
          quantity_allocated: quantity,
          quantity_available: quantity,
          allocated_at: new Date()
        }
      });

      // 3. Update main stock
      await tx.inventoryItem.update({
        where: { item_id: product_id },
        data: { stock_quantity: { decrement: quantity } }
      });

      return allocation;
    });

    res.status(201).json({
      success: true,
      data: result,
      message: 'Inventory allocated successfully'
    });
  } catch (error: any) {
    console.error('Error allocating inventory:', error);
    res.status(400).json({ success: false, message: error.message || 'Server error' });
  }
});

/**
 * @route   GET /api/distribution/dashboard
 * @desc    Consolidated analytics for distribution
 * @access  Private
 */
router.get('/dashboard', enhancedAuthenticate, async (req: any, res: Response) => {
  try {
    // Consolidated metrics using standard Prisma queries for safety
    const [centersCount, lowStockCount, totalAllocated] = await Promise.all([
      prisma.distributionCenter.count({ where: { is_active: true } }),
      prisma.inventoryAllocation.count({
        where: { quantity_available: { lte: 10 } } // threshold of 10 for demo
      }),
      prisma.inventoryAllocation.aggregate({
        _sum: { quantity_allocated: true }
      })
    ]);

    res.json({
      success: true,
      data: {
        centersCount,
        lowStockCount,
        totalAllocated: totalAllocated._sum?.quantity_allocated || 0,
        generated_at: new Date()
      }
    });
  } catch (error) {
    console.error('Error fetching distribution dashboard:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

export default router;

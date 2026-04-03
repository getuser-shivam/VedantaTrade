import { Router, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { enhancedAuthenticate as authenticate } from '../middleware/enhancedAuth';

const router = Router();
const prisma = new PrismaClient();

/**
 * @route   GET /api/products/catalog
 * @desc    Get advanced product catalog with pagination and filters
 * @access  Private
 */
router.get('/catalog', authenticate, async (req: any, res: Response) => {
  try {
    const {
      search = '',
      category_id,
      manufacturer,
      min_price,
      max_price,
      in_stock_only = 'false',
      page = '1',
      limit = '20',
      sort_by = 'name',
      sort_order = 'asc'
    } = req.query;

    const pageNum = parseInt(page as string);
    const limitNum = parseInt(limit as string);

    // Build Prisma where clause
    const where: any = { is_active: true };

    if (search) {
      where.OR = [
        { item_name: { contains: String(search) } },
        { generic_name: { contains: String(search) } },
        { description: { contains: String(search) } },
        { sku: { contains: String(search) } },
      ];
    }

    if (category_id) {
      where.category_id = Number(category_id);
    }

    if (manufacturer) {
      where.manufacturer = { contains: String(manufacturer) };
    }

    if (min_price || max_price) {
      where.mrp = {};
      if (min_price) where.mrp.gte = parseFloat(min_price as string);
      if (max_price) where.mrp.lte = parseFloat(max_price as string);
    }

    if (in_stock_only === 'true') {
      where.stock_quantity = { gt: 0 };
    }

    // Sort mapping
    let orderBy: any = {};
    const direction = sort_order === 'desc' ? 'desc' : 'asc';
    
    switch (sort_by) {
      case 'price':
        orderBy.mrp = direction;
        break;
      case 'stock':
        orderBy.stock_quantity = direction;
        break;
      case 'created_at':
        orderBy.created_at = direction;
        break;
      case 'name':
      default:
        orderBy.item_name = direction;
        break;
    }

    // Execute queries
    const [products, total, categories, manufacturersRaw] = await Promise.all([
      prisma.inventoryItem.findMany({
        where,
        include: { category: true },
        orderBy,
        skip: (pageNum - 1) * limitNum,
        take: limitNum,
      }),
      prisma.inventoryItem.count({ where }),
      prisma.category.findMany({
        where: { is_active: true },
        select: { id: true, name: true, _count: { select: { products: true } } }
      }),
      prisma.inventoryItem.findMany({
        where: { is_active: true },
        distinct: ['manufacturer'],
        select: { manufacturer: true }
      })
    ]);

    // Transform categories to match frontend expectation
    const transformedCategories = categories.map(c => ({
      id: c.id,
      name: c.name,
      productCount: c._count.products,
      subcategoryCount: 0, // Simplified for now
      created_at: new Date().toISOString()
    }));

    // Transform manufacturers list
    const manufacturers = manufacturersRaw
      .filter(m => m.manufacturer)
      .map((m, idx) => ({
        id: idx + 1,
        name: m.manufacturer,
        productCount: 0, // Calculated correctly would be expensive here
        createdAt: new Date().toISOString()
      }));

    res.json({
      success: true,
      data: {
        products,
        categories: transformedCategories,
        manufacturers,
        pagination: {
          total,
          current_page: pageNum,
          total_pages: Math.ceil(total / limitNum),
          has_next: pageNum * limitNum < total,
          has_prev: pageNum > 1
        },
        filters: {
          search,
          category_id,
          manufacturer,
          min_price,
          max_price,
          in_stock_only,
          sort_by,
          sort_order
        }
      }
    });
  } catch (error) {
    console.error('Error fetching product catalog:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch product catalog' });
  }
});

/**
 * @route   GET /api/products/categories
 * @desc    Simplified categories for the catalog
 * @access  Private
 */
router.get('/categories', authenticate, async (req: any, res: Response) => {
  try {
    const categories = await prisma.category.findMany({
      where: { is_active: true },
      include: { _count: { select: { products: true } } }
    });
    
    res.json({
      success: true,
      data: categories.map(c => ({
        id: c.id,
        name: c.name,
        description: c.description,
        productCount: c._count.products,
        created_at: c.created_at
      }))
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

export default router;

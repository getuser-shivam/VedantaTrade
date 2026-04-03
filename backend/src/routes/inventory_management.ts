import { Router, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { authenticate, authorize } from '../middleware/auth';

const router = Router();
const prisma = new PrismaClient();

// GET /api/inventory/allocations - Get all inventory allocations with filtering
router.get('/allocations', authenticate, async (req: any, res: Response) => {
  try {
    const { 
      page = 1, 
      limit = 20, 
      search = '', 
      center_id, 
      product_id,
      low_stock_only = false 
    } = req.query;
    
    // Build where clause
    let whereClause = '';
    const params: any[] = [];
    
    if (search) {
      whereClause += ' WHERE (p.item_name LIKE ? OR p.generic_name LIKE ? OR dc.name LIKE ?)';
      params.push(`%${search}%`, `%${search}%`, `%${search}%`);
    }
    
    if (center_id) {
      whereClause += whereClause ? ' AND ia.center_id = ?' : ' WHERE ia.center_id = ?';
      params.push(center_id);
    }
    
    if (product_id) {
      whereClause += whereClause ? ' AND ia.product_id = ?' : ' WHERE ia.product_id = ?';
      params.push(product_id);
    }
    
    if (low_stock_only === 'true') {
      whereClause += whereClause ? ' AND ia.quantity_available <= ia.quantity_allocated * 0.2' : ' WHERE ia.quantity_available <= ia.quantity_allocated * 0.2';
    }
    
    // Get allocations with product and center details
    const allocations = await prisma.$queryRaw`
      SELECT 
        ia.*,
        p.item_name as product_name,
        p.generic_name,
        p.mrp,
        p.stock_quantity as total_stock,
        dc.name as center_name,
        dc.city,
        dc.state,
        CASE 
          WHEN ia.quantity_available = 0 THEN 'OUT_OF_STOCK'
          WHEN ia.quantity_available <= ia.quantity_allocated * 0.2 THEN 'LOW_STOCK'
          WHEN ia.quantity_available <= ia.quantity_allocated * 0.5 THEN 'MEDIUM_STOCK'
          ELSE 'GOOD_STOCK'
        END as stock_status
      FROM inventory_allocations ia
      LEFT JOIN inventory_items p ON ia.product_id = p.item_id
      LEFT JOIN distribution_centers dc ON ia.center_id = dc.id
      ${whereClause}
      ORDER BY ia.allocated_at DESC
      LIMIT ${Number(limit)} OFFSET ${(Number(page) - 1) * Number(limit)}
    `;
    
    // Get total count
    const totalResult = await prisma.$queryRaw`
      SELECT COUNT(*) as count 
      FROM inventory_allocations ia
      LEFT JOIN inventory_items p ON ia.product_id = p.item_id
      LEFT JOIN distribution_centers dc ON ia.center_id = dc.id
      ${whereClause}
    `;
    const total = (totalResult as any)[0].count;
    
    // Calculate stock statistics
    const stockStats = await prisma.$queryRaw`
      SELECT 
        COUNT(*) as total_allocations,
        SUM(CASE WHEN quantity_available = 0 THEN 1 ELSE 0 END) as out_of_stock,
        SUM(CASE WHEN quantity_available <= quantity_allocated * 0.2 THEN 1 ELSE 0 END) as low_stock,
        SUM(CASE WHEN quantity_available > quantity_allocated * 0.2 THEN 1 ELSE 0 END) as good_stock
      FROM inventory_allocations
    `;
    
    res.json({
      success: true,
      data: {
        allocations,
        pagination: {
          page: Number(page),
          limit: Number(limit),
          total,
          pages: Math.ceil(total / Number(limit))
        },
        statistics: (stockStats as any)[0]
      }
    });
  } catch (error) {
    console.error('Error fetching inventory allocations:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch inventory allocations'
    });
  }
});

// GET /api/inventory/movements - Get inventory movement history
router.get('/movements', authenticate, async (req: any, res: Response) => {
  try {
    const { 
      page = 1, 
      limit = 20, 
      movement_type, 
      product_id, 
      center_id,
      start_date,
      end_date 
    } = req.query;
    
    // Build where clause
    let whereClause = '';
    const params: any[] = [];
    
    if (movement_type) {
      whereClause += ' WHERE im.movement_type = ?';
      params.push(movement_type);
    }
    
    if (product_id) {
      whereClause += whereClause ? ' AND im.product_id = ?' : ' WHERE im.product_id = ?';
      params.push(product_id);
    }
    
    if (center_id) {
      whereClause += whereClause ? ' AND (im.from_center_id = ? OR im.to_center_id = ?)' : ' WHERE (im.from_center_id = ? OR im.to_center_id = ?)';
      params.push(center_id, center_id);
    }
    
    if (start_date) {
      whereClause += whereClause ? ' AND im.movement_date >= ?' : ' WHERE im.movement_date >= ?';
      params.push(start_date);
    }
    
    if (end_date) {
      whereClause += whereClause ? ' AND im.movement_date <= ?' : ' WHERE im.movement_date <= ?';
      params.push(end_date);
    }
    
    // Get movements with details
    const movements = await prisma.$queryRaw`
      SELECT 
        im.*,
        p.item_name as product_name,
        p.generic_name,
        from_center.name as from_center_name,
        to_center.name as to_center_name,
        u.name as created_by_name
      FROM inventory_movements im
      LEFT JOIN inventory_items p ON im.product_id = p.item_id
      LEFT JOIN distribution_centers from_center ON im.from_center_id = from_center.id
      LEFT JOIN distribution_centers to_center ON im.to_center_id = to_center.id
      LEFT JOIN users u ON im.created_by = u.user_id
      ${whereClause}
      ORDER BY im.movement_date DESC
      LIMIT ${Number(limit)} OFFSET ${(Number(page) - 1) * Number(limit)}
    `;
    
    // Get total count
    const totalResult = await prisma.$queryRaw`
      SELECT COUNT(*) as count FROM inventory_movements im
      LEFT JOIN inventory_items p ON im.product_id = p.item_id
      LEFT JOIN distribution_centers from_center ON im.from_center_id = from_center.id
      LEFT JOIN distribution_centers to_center ON im.to_center_id = to_center.id
      ${whereClause}
    `;
    const total = (totalResult as any)[0].count;
    
    res.json({
      success: true,
      data: {
        movements,
        pagination: {
          page: Number(page),
          limit: Number(limit),
          total,
          pages: Math.ceil(total / Number(limit))
        }
      }
    });
  } catch (error) {
    console.error('Error fetching inventory movements:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch inventory movements'
    });
  }
});

// POST /api/inventory/adjust - Adjust inventory quantities
router.post('/adjust', authenticate, authorize('manage_inventory'), async (req: any, res: Response) => {
  try {
    const { allocation_id, adjustment_type, quantity, reason } = req.body;
    
    // Validate input
    if (!allocation_id || !adjustment_type || !quantity || quantity <= 0) {
      return res.status(400).json({
        success: false,
        message: 'Allocation ID, adjustment type, and positive quantity are required'
      });
    }
    
    if (!['INCREASE', 'DECREASE', 'SET'].includes(adjustment_type)) {
      return res.status(400).json({
        success: false,
        message: 'Adjustment type must be INCREASE, DECREASE, or SET'
      });
    }
    
    // Get current allocation
    const allocation = await prisma.$queryRaw`
      SELECT ia.*, p.item_name, dc.name as center_name
      FROM inventory_allocations ia
      LEFT JOIN inventory_items p ON ia.product_id = p.item_id
      LEFT JOIN distribution_centers dc ON ia.center_id = dc.id
      WHERE ia.id = ${allocation_id}
    `;
    
    if ((allocation as any[]).length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Inventory allocation not found'
      });
    }
    
    const currentAllocation = (allocation as any)[0];
    let newAvailable = currentAllocation.quantity_available;
    
    switch (adjustment_type) {
      case 'INCREASE':
        newAvailable += quantity;
        break;
      case 'DECREASE':
        if (newAvailable < quantity) {
          return res.status(400).json({
            success: false,
            message: 'Cannot decrease below available quantity'
          });
        }
        newAvailable -= quantity;
        break;
      case 'SET':
        newAvailable = quantity;
        break;
    }
    
    // Update allocation
    await prisma.$queryRaw`
      UPDATE inventory_allocations 
      SET quantity_available = ${newAvailable}, last_updated = GETDATE()
      WHERE id = ${allocation_id}
    `;
    
    // Record adjustment movement
    await prisma.$queryRaw`
      INSERT INTO inventory_movements 
      (product_id, from_center_id, to_center_id, movement_type, quantity, created_by, movement_date, notes)
      VALUES (${currentAllocation.product_id}, ${currentAllocation.center_id}, NULL, 'ADJUSTMENT', ${quantity}, ${req.user.id}, GETDATE(), ${reason})
    `;
    
    res.status(201).json({
      success: true,
      message: 'Inventory adjusted successfully',
      data: {
        previous_quantity: currentAllocation.quantity_available,
        new_quantity: newAvailable,
        adjustment: quantity,
        adjustment_type
      }
    });
  } catch (error) {
    console.error('Error adjusting inventory:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to adjust inventory'
    });
  }
});

// GET /api/inventory/summary - Get inventory summary statistics
router.get('/summary', authenticate, async (req: any, res: Response) => {
  try {
    const { center_id, date_range = '30d' } = req.query;
    
    // Calculate date range
    let dateFilter = '';
    if (date_range === '7d') {
      dateFilter = "AND movement_date >= DATEADD(day, -7, GETDATE())";
    } else if (date_range === '30d') {
      dateFilter = "AND movement_date >= DATEADD(day, -30, GETDATE())";
    } else if (date_range === '90d') {
      dateFilter = "AND movement_date >= DATEADD(day, -90, GETDATE())";
    }
    
    // Build center filter
    const centerFilter = center_id ? `AND center_id = ${center_id}` : '';
    
    // Get overall statistics
    const overallStats = await prisma.$queryRaw`
      SELECT 
        COUNT(DISTINCT product_id) as unique_products,
        COUNT(DISTINCT center_id) as active_centers,
        SUM(quantity_allocated) as total_allocated,
        SUM(quantity_available) as total_available,
        AVG(quantity_available) as avg_available_per_product
      FROM inventory_allocations
      WHERE 1=1 ${centerFilter}
    `;
    
    // Get stock status distribution
    const stockStatus = await prisma.$queryRaw`
      SELECT 
        CASE 
          WHEN quantity_available = 0 THEN 'OUT_OF_STOCK'
          WHEN quantity_available <= quantity_allocated * 0.2 THEN 'LOW_STOCK'
          WHEN quantity_available <= quantity_allocated * 0.5 THEN 'MEDIUM_STOCK'
          ELSE 'GOOD_STOCK'
        END as stock_status,
        COUNT(*) as count
      FROM inventory_allocations
      WHERE 1=1 ${centerFilter}
      GROUP BY 
        CASE 
          WHEN quantity_available = 0 THEN 'OUT_OF_STOCK'
          WHEN quantity_available <= quantity_allocated * 0.2 THEN 'LOW_STOCK'
          WHEN quantity_available <= quantity_allocated * 0.5 THEN 'MEDIUM_STOCK'
          ELSE 'GOOD_STOCK'
        END
    `;
    
    // Get recent movements
    const recentMovements = await prisma.$queryRaw`
      SELECT 
        movement_type,
        COUNT(*) as count,
        SUM(quantity) as total_quantity
      FROM inventory_movements
      WHERE 1=1 ${dateFilter} ${centerFilter}
      GROUP BY movement_type
      ORDER BY count DESC
    `;
    
    // Get top products by allocation
    const topProducts = await prisma.$queryRaw`
      SELECT TOP 10
        p.item_name,
        SUM(ia.quantity_allocated) as total_allocated,
        SUM(ia.quantity_available) as total_available,
        COUNT(DISTINCT ia.center_id) as center_count
      FROM inventory_allocations ia
      LEFT JOIN inventory_items p ON ia.product_id = p.item_id
      WHERE 1=1 ${centerFilter}
      GROUP BY p.item_name, p.item_id
      ORDER BY total_allocated DESC
    `;
    
    res.json({
      success: true,
      data: {
        overall: (overallStats as any)[0],
        stock_status: stockStatus,
        recent_movements: recentMovements,
        top_products: topProducts
      }
    });
  } catch (error) {
    console.error('Error fetching inventory summary:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch inventory summary'
    });
  }
});

// GET /api/inventory/alerts - Get inventory alerts
router.get('/alerts', authenticate, async (req: any, res: Response) => {
  try {
    const { center_id, alert_type = 'all' } = req.query;
    
    // Build filters
    const centerFilter = center_id ? `AND ia.center_id = ${center_id}` : '';
    
    let alerts = [];
    
    if (alert_type === 'all' || alert_type === 'low_stock') {
      // Low stock alerts
      const lowStockAlerts = await prisma.$queryRaw`
        SELECT 
          ia.id as allocation_id,
          p.item_name as product_name,
          dc.name as center_name,
          ia.quantity_available,
          ia.quantity_allocated,
          ia.quantity_allocated * 0.2 as threshold,
          'LOW_STOCK' as alert_type,
          ia.last_updated as last_activity
        FROM inventory_allocations ia
        LEFT JOIN inventory_items p ON ia.product_id = p.item_id
        LEFT JOIN distribution_centers dc ON ia.center_id = dc.id
        WHERE ia.quantity_available <= ia.quantity_allocated * 0.2 
          AND ia.quantity_available > 0
          ${centerFilter}
        ORDER BY ia.quantity_available ASC
      `;
      alerts.push(...(lowStockAlerts as any[]));
    }
    
    if (alert_type === 'all' || alert_type === 'out_of_stock') {
      // Out of stock alerts
      const outOfStockAlerts = await prisma.$queryRaw`
        SELECT 
          ia.id as allocation_id,
          p.item_name as product_name,
          dc.name as center_name,
          ia.quantity_available,
          ia.quantity_allocated,
          'OUT_OF_STOCK' as alert_type,
          ia.last_updated as last_activity
        FROM inventory_allocations ia
        LEFT JOIN inventory_items p ON ia.product_id = p.item_id
        LEFT JOIN distribution_centers dc ON ia.center_id = dc.id
        WHERE ia.quantity_available = 0
          ${centerFilter}
        ORDER BY ia.last_updated DESC
      `;
      alerts.push(...(outOfStockAlerts as any[]));
    }
    
    if (alert_type === 'all' || alert_type === 'overstock') {
      // Overstock alerts (more than 150% of allocated)
      const overstockAlerts = await prisma.$queryRaw`
        SELECT 
          ia.id as allocation_id,
          p.item_name as product_name,
          dc.name as center_name,
          ia.quantity_available,
          ia.quantity_allocated,
          ia.quantity_allocated * 1.5 as threshold,
          'OVERSTOCK' as alert_type,
          ia.last_updated as last_activity
        FROM inventory_allocations ia
        LEFT JOIN inventory_items p ON ia.product_id = p.item_id
        LEFT JOIN distribution_centers dc ON ia.center_id = dc.id
        WHERE ia.quantity_available > ia.quantity_allocated * 1.5
          ${centerFilter}
        ORDER BY ia.quantity_available DESC
      `;
      alerts.push(...(overstockAlerts as any[]));
    }
    
    res.json({
      success: true,
      data: {
        alerts,
        summary: {
          total_alerts: alerts.length,
          low_stock: alerts.filter(a => a.alert_type === 'LOW_STOCK').length,
          out_of_stock: alerts.filter(a => a.alert_type === 'OUT_OF_STOCK').length,
          overstock: alerts.filter(a => a.alert_type === 'OVERSTOCK').length
        }
      }
    });
  } catch (error) {
    console.error('Error fetching inventory alerts:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch inventory alerts'
    });
  }
});

export default router;

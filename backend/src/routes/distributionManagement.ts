import { Router, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { authenticate, authorize } from '../middleware/rbac';

const router = Router();
const prisma = new PrismaClient();

// GET /api/distribution/sales/overview - Get sales overview
router.get('/sales/overview', authenticate, authorize('sales:read'), async (req: any, res: Response) => {
  try {
    const { period = '30d', center_id } = req.query;
    
    // Calculate date range
    let dateFilter = '';
    if (period === '7d') {
      dateFilter = "AND created_at >= DATEADD(day, -7, GETDATE())";
    } else if (period === '30d') {
      dateFilter = "AND created_at >= DATEADD(day, -30, GETDATE())";
    } else if (period === '90d') {
      dateFilter = "AND created_at >= DATEADD(day, -90, GETDATE())";
    } else if (period === '1y') {
      dateFilter = "AND created_at >= DATEADD(year, -1, GETDATE())";
    }

    const centerFilter = center_id ? `AND center_id = ${center_id}` : '';

    // Get sales overview data
    const [salesData, topProducts, topCustomers] = await Promise.all([
      // Total sales and revenue
      prisma.$queryRaw`
        SELECT 
          COUNT(*) as total_orders,
          SUM(total_amount) as total_revenue,
          SUM(quantity) as total_quantity,
          AVG(total_amount) as avg_order_value,
          COUNT(DISTINCT customer_id) as unique_customers
        FROM orders 
        WHERE status = 'completed' ${dateFilter} ${centerFilter}
      ` as any[],
      
      // Top selling products
      prisma.$queryRaw`
        SELECT TOP 10
          p.item_name as product_name,
          SUM(oi.quantity) as total_quantity,
          SUM(oi.quantity * oi.unit_price) as total_revenue,
          COUNT(DISTINCT oi.order_id) as order_count
        FROM order_items oi
        JOIN orders o ON oi.order_id = o.order_id
        JOIN inventory_items p ON oi.product_id = p.item_id
        WHERE o.status = 'completed' ${dateFilter} ${centerFilter}
        GROUP BY p.item_name, p.item_id
        ORDER BY total_quantity DESC
      ` as any[],
      
      // Top customers
      prisma.$queryRaw`
        SELECT TOP 10
          c.name as customer_name,
          c.email,
          COUNT(o.order_id) as order_count,
          SUM(o.total_amount) as total_spent,
          MAX(o.created_at) as last_order_date
        FROM orders o
        JOIN customers c ON o.customer_id = c.customer_id
        WHERE o.status = 'completed' ${dateFilter} ${centerFilter}
        GROUP BY c.customer_id, c.name, c.email
        ORDER BY total_spent DESC
      ` as any[]
    ]);

    // Get daily sales trend
    const salesTrend = await prisma.$queryRaw`
      SELECT 
        CAST(created_at AS DATE) as date,
        COUNT(*) as orders,
        SUM(total_amount) as revenue,
        SUM(quantity) as quantity
      FROM orders
      WHERE status = 'completed' ${dateFilter} ${centerFilter}
      GROUP BY CAST(created_at AS DATE)
      ORDER BY date ASC
    ` as any[];

    res.json({
      success: true,
      data: {
        overview: salesData[0] || {},
        topProducts,
        topCustomers,
        salesTrend
      }
    });
  } catch (error) {
    console.error('Error fetching sales overview:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// GET /api/distribution/inventory/status - Get inventory distribution status
router.get('/inventory/status', authenticate, authorize('inventory:read'), async (req: any, res: Response) => {
  try {
    const { center_id } = req.query;
    
    const centerFilter = center_id ? `AND ia.center_id = ${center_id}` : '';

    // Get inventory status across all centers
    const inventoryStatus = await prisma.$queryRaw`
      SELECT 
        dc.name as center_name,
        dc.id as center_id,
        COUNT(ia.product_id) as total_products,
        SUM(ia.quantity_available) as total_available,
        SUM(ia.quantity_allocated) as total_allocated,
        SUM(CASE WHEN ia.quantity_available <= ia.min_stock_level THEN 1 ELSE 0 END) as low_stock_items,
        SUM(CASE WHEN ia.quantity_available = 0 THEN 1 ELSE 0 END) as out_of_stock_items
      FROM distribution_centers dc
      LEFT JOIN inventory_allocations ia ON dc.id = ia.center_id
      ${center_id ? 'WHERE dc.id = ' + center_id : 'WHERE 1=1'}
      GROUP BY dc.id, dc.name
      ORDER BY dc.name
    ` as any[];

    // Get products needing restock
    const restockAlerts = await prisma.$queryRaw`
      SELECT 
        p.item_name as product_name,
        dc.name as center_name,
        ia.quantity_available,
        ia.min_stock_level,
        ia.max_stock_level,
        CASE 
          WHEN ia.quantity_available = 0 THEN 'OUT_OF_STOCK'
          WHEN ia.quantity_available <= ia.min_stock_level THEN 'LOW_STOCK'
          ELSE 'IN_STOCK'
        END as stock_status
      FROM inventory_allocations ia
      JOIN inventory_items p ON ia.product_id = p.item_id
      JOIN distribution_centers dc ON ia.center_id = dc.id
      WHERE ia.quantity_available <= ia.min_stock_level OR ia.quantity_available = 0
        ${centerFilter}
      ORDER BY ia.quantity_available ASC
    ` as any[];

    // Get inventory turnover rate
    const turnoverData = await prisma.$queryRaw`
      SELECT 
        p.item_name as product_name,
        ia.quantity_available as current_stock,
        ia.quantity_allocated as allocated_stock,
        COALESCE(SUM(oi.quantity), 0) as total_sold,
        CASE 
          WHEN ia.quantity_allocated > 0 THEN 
            CAST(COALESCE(SUM(oi.quantity), 0) * 1.0 / ia.quantity_allocated * 100 AS DECIMAL(10,2))
          ELSE 0 
        END as turnover_rate
      FROM inventory_items p
      JOIN inventory_allocations ia ON p.item_id = ia.product_id
      LEFT JOIN order_items oi ON p.item_id = oi.product_id
      LEFT JOIN orders o ON oi.order_id = o.order_id AND o.status = 'completed'
        AND o.created_at >= DATEADD(month, -3, GETDATE())
      ${centerFilter}
      GROUP BY p.item_name, p.item_id, ia.quantity_available, ia.quantity_allocated
      HAVING COALESCE(SUM(oi.quantity), 0) > 0
      ORDER BY turnover_rate DESC
    ` as any[];

    res.json({
      success: true,
      data: {
        inventoryStatus,
        restockAlerts,
        turnoverData
      }
    });
  } catch (error) {
    console.error('Error fetching inventory status:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// GET /api/distribution/performance - Get distribution performance metrics
router.get('/performance', authenticate, authorize('analytics:read'), async (req: any, res: Response) => {
  try {
    const { period = '30d', medical_rep_id } = req.query;
    
    // Calculate date range
    let dateFilter = '';
    if (period === '7d') {
      dateFilter = "AND o.created_at >= DATEADD(day, -7, GETDATE())";
    } else if (period === '30d') {
      dateFilter = "AND o.created_at >= DATEADD(day, -30, GETDATE())";
    } else if (period === '90d') {
      dateFilter = "AND o.created_at >= DATEADD(day, -90, GETDATE())";
    }

    const repFilter = medical_rep_id ? `AND o.medical_rep_id = ${medical_rep_id}` : '';

    // Get medical rep performance
    const repPerformance = await prisma.$queryRaw`
      SELECT 
        u.name as rep_name,
        u.user_id as rep_id,
        COUNT(DISTINCT o.order_id) as total_orders,
        SUM(o.total_amount) as total_revenue,
        AVG(o.total_amount) as avg_order_value,
        COUNT(DISTINCT o.customer_id) as unique_customers,
        COUNT(DISTINCT CASE WHEN o.created_at >= DATEADD(day, -7, GETDATE()) THEN o.order_id END) as orders_this_week,
        SUM(CASE WHEN o.created_at >= DATEADD(day, -7, GETDATE()) THEN o.total_amount ELSE 0 END) as revenue_this_week
      FROM orders o
      JOIN users u ON o.medical_rep_id = u.user_id
      WHERE o.status = 'completed' ${dateFilter} ${repFilter}
      GROUP BY u.user_id, u.name
      ORDER BY total_revenue DESC
    ` as any[];

    // Get distribution center performance
    const centerPerformance = await prisma.$queryRaw`
      SELECT 
        dc.name as center_name,
        dc.id as center_id,
        COUNT(DISTINCT o.order_id) as total_orders,
        SUM(o.total_amount) as total_revenue,
        COUNT(DISTINCT o.customer_id) as unique_customers,
        AVG(DATEDIFF(day, o.created_at, o.delivered_at)) as avg_delivery_days
      FROM orders o
      JOIN distribution_centers dc ON o.center_id = dc.id
      WHERE o.status = 'completed' ${dateFilter}
      GROUP BY dc.id, dc.name
      ORDER BY total_revenue DESC
    ` as any[];

    // Get product performance by category
    const categoryPerformance = await prisma.$queryRaw`
      SELECT 
        pc.name as category_name,
        COUNT(DISTINCT oi.order_id) as total_orders,
        SUM(oi.quantity) as total_quantity,
        SUM(oi.quantity * oi.unit_price) as total_revenue,
        AVG(oi.unit_price) as avg_price
      FROM order_items oi
      JOIN orders o ON oi.order_id = o.order_id
      JOIN inventory_items p ON oi.product_id = p.item_id
      JOIN product_categories pc ON p.category_id = pc.id
      WHERE o.status = 'completed' ${dateFilter}
      GROUP BY pc.id, pc.name
      ORDER BY total_revenue DESC
    ` as any[];

    // Get delivery performance metrics
    const deliveryMetrics = await prisma.$queryRaw`
      SELECT 
        COUNT(*) as total_deliveries,
        AVG(DATEDIFF(day, o.created_at, o.delivered_at)) as avg_delivery_time,
        COUNT(CASE WHEN DATEDIFF(day, o.created_at, o.delivered_at) <= 2 THEN 1 END) as on_time_deliveries,
        COUNT(CASE WHEN DATEDIFF(day, o.created_at, o.delivered_at) > 5 THEN 1 END) as delayed_deliveries,
        CAST(COUNT(CASE WHEN DATEDIFF(day, o.created_at, o.delivered_at) <= 2 THEN 1 END) * 100.0 / COUNT(*) AS DECIMAL(10,2)) as on_time_percentage
      FROM orders o
      WHERE o.status = 'completed' AND o.delivered_at IS NOT NULL ${dateFilter}
    ` as any[];

    res.json({
      success: true,
      data: {
        repPerformance,
        centerPerformance,
        categoryPerformance,
        deliveryMetrics: deliveryMetrics[0] || {}
      }
    });
  } catch (error) {
    console.error('Error fetching performance metrics:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// POST /api/distribution/orders - Create new distribution order
router.post('/orders', authenticate, authorize('orders:create'), async (req: any, res: Response) => {
  try {
    const {
      customer_id,
      center_id,
      medical_rep_id,
      items,
      delivery_address,
      notes,
      priority = 'normal'
    } = req.body;

    // Validate required fields
    if (!customer_id || !center_id || !items || items.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Customer ID, center ID, and items are required'
      });
    }

    // Check inventory availability
    const inventoryChecks = await Promise.all(
      items.map(async (item: any) => {
        const allocation = await prisma.$queryRaw`
          SELECT quantity_available, min_stock_level
          FROM inventory_allocations 
          WHERE product_id = ${item.product_id} AND center_id = ${center_id}
        ` as any[];
        
        return {
          product_id: item.product_id,
          available: allocation[0]?.quantity_available || 0,
          requested: item.quantity,
          can_fulfill: (allocation[0]?.quantity_available || 0) >= item.quantity
        };
      })
    );

    const insufficientStock = inventoryChecks.find(check => !check.can_fulfill);
    if (insufficientStock) {
      return res.status(400).json({
        success: false,
        message: `Insufficient stock for product ID ${insufficientStock.product_id}. Available: ${insufficientStock.available}, Requested: ${insufficientStock.requested}`
      });
    }

    // Calculate total amount
    const totalAmount = items.reduce((sum: number, item: any) => sum + (item.quantity * item.unit_price), 0);

    // Create order
    const order = await prisma.orders.create({
      data: {
        customer_id,
        center_id,
        medical_rep_id,
        total_amount: totalAmount,
        status: 'pending',
        priority,
        delivery_address,
        notes,
        created_at: new Date()
      }
    });

    // Create order items and update inventory
    await Promise.all(
      items.map(async (item: any) => {
        // Create order item
        await prisma.order_items.create({
          data: {
            order_id: order.order_id,
            product_id: item.product_id,
            quantity: item.quantity,
            unit_price: item.unit_price,
            total_price: item.quantity * item.unit_price
          }
        });

        // Update inventory allocation
        await prisma.$queryRaw`
          UPDATE inventory_allocations 
          SET quantity_available = quantity_available - ${item.quantity},
              quantity_allocated = quantity_allocated + ${item.quantity},
              last_updated = GETDATE()
          WHERE product_id = ${item.product_id} AND center_id = ${center_id}
        `;
      })
    );

    // Create order tracking
    await prisma.order_tracking.create({
      data: {
        order_id: order.order_id,
        status: 'pending',
        location: 'Processing Center',
        timestamp: new Date(),
        notes: 'Order created and inventory allocated'
      }
    });

    res.status(201).json({
      success: true,
      data: {
        order,
        items,
        inventoryChecks
      },
      message: 'Distribution order created successfully'
    });
  } catch (error) {
    console.error('Error creating distribution order:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// GET /api/distribution/orders/:id - Get order details with tracking
router.get('/orders/:id', authenticate, authorize('orders:read'), async (req: any, res: Response) => {
  try {
    const { id } = req.params;

    const [order, items, tracking] = await Promise.all([
      prisma.orders.findUnique({
        where: { order_id: parseInt(id) },
        include: {
          customer: true,
          center: true,
          medical_rep: true
        }
      }),
      
      prisma.order_items.findMany({
        where: { order_id: parseInt(id) },
        include: {
          product: true
        }
      }),
      
      prisma.order_tracking.findMany({
        where: { order_id: parseInt(id) },
        orderBy: { timestamp: 'desc' }
      })
    ]);

    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }

    res.json({
      success: true,
      data: {
        order,
        items,
        tracking
      }
    });
  } catch (error) {
    console.error('Error fetching order details:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// PUT /api/distribution/orders/:id/status - Update order status
router.put('/orders/:id/status', authenticate, authorize('orders:update'), async (req: any, res: Response) => {
  try {
    const { id } = req.params;
    const { status, notes, location } = req.body;

    const validStatuses = ['pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid status'
      });
    }

    // Update order
    const order = await prisma.orders.update({
      where: { order_id: parseInt(id) },
      data: {
        status,
        updated_at: new Date(),
        ...(status === 'delivered' && { delivered_at: new Date() })
      }
    });

    // Create tracking entry
    await prisma.order_tracking.create({
      data: {
        order_id: parseInt(id),
        status,
        location: location || 'Unknown',
        timestamp: new Date(),
        notes: notes || `Status updated to ${status}`
      }
    });

    // If order is cancelled, restore inventory
    if (status === 'cancelled') {
      const orderItems = await prisma.order_items.findMany({
        where: { order_id: parseInt(id) }
      });

      await Promise.all(
        orderItems.map(async (item) => {
          await prisma.$queryRaw`
            UPDATE inventory_allocations 
            SET quantity_available = quantity_available + ${item.quantity},
                quantity_allocated = quantity_allocated - ${item.quantity},
                last_updated = GETDATE()
            WHERE product_id = ${item.product_id} AND center_id = (
              SELECT center_id FROM orders WHERE order_id = ${id}
            )
          `;
        })
      );
    }

    res.json({
      success: true,
      data: order,
      message: 'Order status updated successfully'
    });
  } catch (error) {
    console.error('Error updating order status:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

export default router;

import { Router, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { authenticate, authorize } from '../middleware/rbac';

const router = Router();
const prisma = new PrismaClient();

// GET /api/dashboard/overview - Get comprehensive dashboard overview
router.get('/overview', authenticate, authorize('analytics:read'), async (req: any, res: Response) => {
  try {
    const { period = '30d', role = req.user.role } = req.query;

    // Calculate date range
    let dateFilter = '';
    if (period === '7d') {
      dateFilter = "AND created_at >= DATEADD(day, -7, GETDATE())";
    } else if (period === '30d') {
      dateFilter = "AND created_at >= DATEADD(day, -30, GETDATE())";
    } else if (period === '90d') {
      dateFilter = "AND created_at >= DATEADD(day, -90, GETDATE())";
    }

    // Get role-specific data
    let roleFilter = '';
    if (role === 'MEDICAL_REP') {
      roleFilter = `AND o.medical_rep_id = ${req.user.id}`;
    } else if (role === 'ADMIN') {
      // Admin sees all data
    } else {
      // Other roles see their relevant data
      roleFilter = `AND o.medical_rep_id = ${req.user.id}`;
    }

    // Get comprehensive dashboard data
    const [
      salesMetrics,
      inventoryMetrics,
      marketingMetrics,
      performanceMetrics,
      alerts
    ] = await Promise.all([
      // Sales and revenue metrics
      prisma.$queryRaw`
        SELECT 
          COUNT(DISTINCT o.order_id) as total_orders,
          SUM(o.total_amount) as total_revenue,
          AVG(o.total_amount) as avg_order_value,
          COUNT(DISTINCT o.customer_id) as unique_customers,
          SUM(CASE WHEN o.created_at >= DATEADD(day, -7, GETDATE()) THEN 1 ELSE 0 END) as orders_this_week,
          SUM(CASE WHEN o.created_at >= DATEADD(day, -7, GETDATE()) THEN o.total_amount ELSE 0 END) as revenue_this_week,
          SUM(CASE WHEN o.created_at >= DATEADD(month, -1, GETDATE()) THEN 1 ELSE 0 END) as orders_this_month,
          SUM(CASE WHEN o.created_at >= DATEADD(month, -1, GETDATE()) THEN o.total_amount ELSE 0 END) as revenue_this_month
        FROM orders o
        WHERE o.status = 'completed' ${dateFilter} ${roleFilter}
      ` as any[],

      // Inventory and distribution metrics
      prisma.$queryRaw`
        SELECT 
          COUNT(DISTINCT ia.product_id) as total_products_managed,
          SUM(ia.quantity_available) as total_available_stock,
          SUM(ia.quantity_allocated) as total_allocated_stock,
          COUNT(CASE WHEN ia.quantity_available <= ia.min_stock_level THEN 1 END) as low_stock_alerts,
          COUNT(CASE WHEN ia.quantity_available = 0 THEN 1 END) as out_of_stock_items,
          AVG(CASE WHEN ia.quantity_allocated > 0 THEN (ia.quantity_available * 100.0 / ia.quantity_allocated) ELSE 0 END) as avg_stock_level
        FROM inventory_allocations ia
        ${role === 'MEDICAL_REP' ? `JOIN orders o ON ia.center_id = o.center_id WHERE o.medical_rep_id = ${req.user.id}` : 'WHERE 1=1'}
      ` as any[],

      // Marketing and campaign metrics
      prisma.$queryRaw`
        SELECT 
          COUNT(DISTINCT mc.id) as active_campaigns,
          COUNT(DISTINCT cl.lead_id) as total_leads,
          COUNT(CASE WHEN cl.status = 'converted' THEN 1 END) as converted_leads,
          AVG(CASE WHEN cl.status = 'converted' THEN 1 ELSE 0 END) as conversion_rate,
          SUM(mc.budget) as total_marketing_budget,
          SUM(cc.spent_amount) as total_marketing_spent
        FROM marketing_campaigns mc
        LEFT JOIN campaign_leads cl ON mc.id = cl.campaign_id
        LEFT JOIN campaign_costs cc ON mc.id = cc.campaign_id
        WHERE mc.status = 'active' ${dateFilter}
      ` as any[],

      // Performance and efficiency metrics
      prisma.$queryRaw`
        SELECT 
          COUNT(DISTINCT o.medical_rep_id) as active_reps,
          AVG(DATEDIFF(day, o.created_at, o.delivered_at)) as avg_delivery_time,
          COUNT(CASE WHEN DATEDIFF(day, o.created_at, o.delivered_at) <= 2 THEN 1 END) as on_time_deliveries,
          COUNT(CASE WHEN o.status = 'completed' THEN 1 END) as completed_orders,
          CAST(COUNT(CASE WHEN DATEDIFF(day, o.created_at, o.delivered_at) <= 2 THEN 1 END) * 100.0 / 
               NULLIF(COUNT(o.order_id), 0) AS DECIMAL(10,2)) as on_time_delivery_rate
        FROM orders o
        WHERE o.status = 'completed' AND o.delivered_at IS NOT NULL ${dateFilter} ${roleFilter}
      ` as any[],

      // Alerts and notifications
      prisma.$queryRaw`
        SELECT 
          'Low Stock' as alert_type,
          COUNT(*) as count,
          'warning' as severity
        FROM inventory_allocations ia
        WHERE ia.quantity_available <= ia.min_stock_level
        
        UNION ALL
        
        SELECT 
          'Overdue Orders' as alert_type,
          COUNT(*) as count,
          'error' as severity
        FROM orders o
        WHERE o.status = 'confirmed' 
          AND DATEDIFF(day, created_at, GETDATE()) > 3
        
        UNION ALL
        
        SELECT 
          'Pending Approvals' as alert_type,
          COUNT(*) as count,
          'info' as severity
        FROM orders o
        WHERE o.status = 'pending'
        
        UNION ALL
        
        SELECT 
          'High Value Orders' as alert_type,
          COUNT(*) as count,
          'success' as severity
        FROM orders o
        WHERE o.total_amount > 50000 AND o.status = 'pending'
      ` as any[]
    ]);

    // Get trend data for charts
    const [salesTrend, inventoryTrend, performanceTrend] = await Promise.all([
      // Sales trend
      prisma.$queryRaw`
        SELECT 
          CAST(created_at AS DATE) as date,
          COUNT(*) as orders,
          SUM(total_amount) as revenue,
          COUNT(DISTINCT customer_id) as customers
        FROM orders
        WHERE status = 'completed' ${dateFilter} ${roleFilter}
        GROUP BY CAST(created_at AS DATE)
        ORDER BY date ASC
      ` as any[],

      // Inventory trend
      prisma.$queryRaw`
        SELECT 
          CAST(last_updated AS DATE) as date,
          SUM(quantity_available) as available,
          SUM(quantity_allocated) as allocated,
          COUNT(CASE WHEN quantity_available <= min_stock_level THEN 1 END) as low_stock
        FROM inventory_allocations
        WHERE last_updated >= DATEADD(day, -30, GETDATE())
        GROUP BY CAST(last_updated AS DATE)
        ORDER BY date ASC
      ` as any[],

      // Performance trend
      prisma.$queryRaw`
        SELECT 
          CAST(created_at AS DATE) as date,
          COUNT(*) as orders,
          AVG(total_amount) as avg_order_value,
          COUNT(DISTINCT medical_rep_id) as active_reps
        FROM orders
        WHERE status = 'completed' ${dateFilter} ${roleFilter}
        GROUP BY CAST(created_at AS DATE)
        ORDER BY date ASC
      ` as any[]
    ]);

    // Get top performers
    const [topProducts, topCustomers, topReps] = await Promise.all([
      // Top products
      prisma.$queryRaw`
        SELECT TOP 5
          p.item_name as name,
          SUM(oi.quantity) as quantity,
          SUM(oi.quantity * oi.unit_price) as revenue,
          COUNT(DISTINCT oi.order_id) as orders
        FROM order_items oi
        JOIN orders o ON oi.order_id = o.order_id
        JOIN inventory_items p ON oi.product_id = p.item_id
        WHERE o.status = 'completed' ${dateFilter} ${roleFilter}
        GROUP BY p.item_name, p.item_id
        ORDER BY revenue DESC
      ` as any[],

      // Top customers
      prisma.$queryRaw`
        SELECT TOP 5
          c.name as name,
          COUNT(o.order_id) as orders,
          SUM(o.total_amount) as revenue,
          MAX(o.created_at) as last_order
        FROM customers c
        JOIN orders o ON c.customer_id = o.customer_id
        WHERE o.status = 'completed' ${dateFilter} ${roleFilter}
        GROUP BY c.customer_id, c.name
        ORDER BY revenue DESC
      ` as any[],

      // Top medical reps (if not a medical rep themselves)
      ...(role !== 'MEDICAL_REP' ? [prisma.$queryRaw`
        SELECT TOP 5
          u.name as name,
          COUNT(o.order_id) as orders,
          SUM(o.total_amount) as revenue,
          COUNT(DISTINCT o.customer_id) as customers
        FROM users u
        JOIN orders o ON u.user_id = o.medical_rep_id
        WHERE o.status = 'completed' ${dateFilter}
        GROUP BY u.user_id, u.name
        ORDER BY revenue DESC
      ` as any[]] : [Promise.resolve([])])
    ]);

    res.json({
      success: true,
      data: {
        metrics: {
          sales: salesMetrics[0] || {},
          inventory: inventoryMetrics[0] || {},
          marketing: marketingMetrics[0] || {},
          performance: performanceMetrics[0] || {},
          alerts
        },
        trends: {
          sales: salesTrend,
          inventory: inventoryTrend,
          performance: performanceTrend
        },
        topPerformers: {
          products: topProducts,
          customers: topCustomers,
          reps: topReps
        },
        metadata: {
          period,
          role,
          generated_at: new Date()
        }
      }
    });
  } catch (error) {
    console.error('Error fetching dashboard overview:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// GET /api/dashboard/kpi - Get key performance indicators
router.get('/kpi', authenticate, authorize('analytics:read'), async (req: any, res: Response) => {
  try {
    const { period = '30d', role = req.user.role } = req.query;

    // Calculate date ranges for comparison
    let currentFilter = '';
    let previousFilter = '';
    
    if (period === '7d') {
      currentFilter = "AND created_at >= DATEADD(day, -7, GETDATE())";
      previousFilter = "AND created_at >= DATEADD(day, -14, GETDATE()) AND created_at < DATEADD(day, -7, GETDATE())";
    } else if (period === '30d') {
      currentFilter = "AND created_at >= DATEADD(day, -30, GETDATE())";
      previousFilter = "AND created_at >= DATEADD(day, -60, GETDATE()) AND created_at < DATEADD(day, -30, GETDATE())";
    } else if (period === '90d') {
      currentFilter = "AND created_at >= DATEADD(day, -90, GETDATE())";
      previousFilter = "AND created_at >= DATEADD(day, -180, GETDATE()) AND created_at < DATEADD(day, -90, GETDATE())";
    }

    let roleFilter = '';
    if (role === 'MEDICAL_REP') {
      roleFilter = `AND medical_rep_id = ${req.user.id}`;
    }

    // Get current and previous period data
    const [currentData, previousData] = await Promise.all([
      prisma.$queryRaw`
        SELECT 
          COUNT(DISTINCT order_id) as orders,
          SUM(total_amount) as revenue,
          COUNT(DISTINCT customer_id) as customers,
          AVG(total_amount) as avg_order_value
        FROM orders
        WHERE status = 'completed' ${currentFilter} ${roleFilter}
      ` as any[],
      
      prisma.$queryRaw`
        SELECT 
          COUNT(DISTINCT order_id) as orders,
          SUM(total_amount) as revenue,
          COUNT(DISTINCT customer_id) as customers,
          AVG(total_amount) as avg_order_value
        FROM orders
        WHERE status = 'completed' ${previousFilter} ${roleFilter}
      ` as any[]
    ]);

    const current = currentData[0] || {};
    const previous = previousData[0] || {};

    // Calculate growth rates
    const kpiData = [
      {
        name: 'Total Orders',
        current: current.orders || 0,
        previous: previous.orders || 0,
        growth: previous.orders ? ((current.orders - previous.orders) / previous.orders * 100) : 0,
        unit: 'orders',
        trend: current.orders > previous.orders ? 'up' : 'down'
      },
      {
        name: 'Revenue',
        current: current.revenue || 0,
        previous: previous.revenue || 0,
        growth: previous.revenue ? ((current.revenue - previous.revenue) / previous.revenue * 100) : 0,
        unit: '₹',
        trend: current.revenue > previous.revenue ? 'up' : 'down'
      },
      {
        name: 'Customers',
        current: current.customers || 0,
        previous: previous.customers || 0,
        growth: previous.customers ? ((current.customers - previous.customers) / previous.customers * 100) : 0,
        unit: 'customers',
        trend: current.customers > previous.customers ? 'up' : 'down'
      },
      {
        name: 'Avg Order Value',
        current: current.avg_order_value || 0,
        previous: previous.avg_order_value || 0,
        growth: previous.avg_order_value ? ((current.avg_order_value - previous.avg_order_value) / previous.avg_order_value * 100) : 0,
        unit: '₹',
        trend: current.avg_order_value > previous.avg_order_value ? 'up' : 'down'
      }
    ];

    // Get target achievement data
    const targets = await prisma.$queryRaw`
      SELECT 
        target_name,
        target_value,
        actual_value,
        (actual_value * 100.0 / target_value) as achievement_percentage,
        CASE 
          WHEN actual_value >= target_value THEN 'Achieved'
          WHEN actual_value >= target_value * 0.8 THEN 'On Track'
          ELSE 'Behind'
        END as status
      FROM (
        SELECT 
          'Monthly Revenue' as target_name,
          1000000 as target_value,
          COALESCE(SUM(total_amount), 0) as actual_value
        FROM orders
        WHERE status = 'completed' 
          AND created_at >= DATEADD(month, -1, GETDATE())
          ${roleFilter}
        
        UNION ALL
        
        SELECT 
          'Monthly Orders' as target_name,
          500 as target_value,
          COALESCE(COUNT(*), 0) as actual_value
        FROM orders
        WHERE status = 'completed' 
          AND created_at >= DATEADD(month, -1, GETDATE())
          ${roleFilter}
        
        UNION ALL
        
        SELECT 
          'New Customers' as target_name,
          100 as target_value,
          COALESCE(COUNT(DISTINCT customer_id), 0) as actual_value
        FROM orders
        WHERE status = 'completed' 
          AND created_at >= DATEADD(month, -1, GETDATE())
          ${roleFilter}
      ) target_data
    ` as any[];

    res.json({
      success: true,
      data: {
        kpis: kpiData,
        targets,
        metadata: {
          period,
          role,
          generated_at: new Date()
        }
      }
    });
  } catch (error) {
    console.error('Error fetching KPI data:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// GET /api/dashboard/alerts - Get system alerts and notifications
router.get('/alerts', authenticate, authorize('analytics:read'), async (req: any, res: Response) => {
  try {
    const { severity = 'all', limit = 50 } = req.query;

    let severityFilter = '';
    if (severity !== 'all') {
      severityFilter = `AND severity = '${severity}'`;
    }

    const alerts = await prisma.$queryRaw`
      SELECT 
        'Low Stock Alert' as title,
        'warning' as severity,
        'inventory' as category,
        CONCAT(p.item_name, ' at ', dc.name, ' - Only ', ia.quantity_available, ' units remaining') as description,
        ia.last_updated as created_at,
        CONCAT('/inventory/products/', ia.product_id) as action_url
      FROM inventory_allocations ia
      JOIN inventory_items p ON ia.product_id = p.item_id
      JOIN distribution_centers dc ON ia.center_id = dc.id
      WHERE ia.quantity_available <= ia.min_stock_level
        ${severityFilter}
      
      UNION ALL
      
      SELECT 
        'Order Overdue' as title,
        'error' as severity,
        'orders' as category,
        CONCAT('Order #', o.order_id, ' is overdue by ', DATEDIFF(day, o.created_at, GETDATE()), ' days') as description,
        o.created_at as created_at,
        CONCAT('/orders/', o.order_id) as action_url
      FROM orders o
      WHERE o.status = 'confirmed' 
        AND DATEDIFF(day, o.created_at, GETDATE()) > 3
        ${severityFilter}
      
      UNION ALL
      
      SELECT 
        'High Value Order' as title,
        'info' as severity,
        'orders' as category,
        CONCAT('Order #', o.order_id, ' worth ₹', o.total_amount, ' requires approval') as description,
        o.created_at as created_at,
        CONCAT('/orders/', o.order_id) as action_url
      FROM orders o
      WHERE o.total_amount > 50000 AND o.status = 'pending'
        ${severityFilter}
      
      UNION ALL
      
      SELECT 
        'Commission Pending' as title,
        'success' as severity,
        'commissions' as category,
        CONCAT('₹', SUM(c.commission_amount), ' in pending commissions for ', u.name) as description,
        MAX(c.created_at) as created_at,
        CONCAT('/commissions/rep/', u.user_id) as action_url
      FROM commissions c
      JOIN users u ON c.medical_rep_id = u.user_id
      WHERE c.status = 'pending'
        ${severityFilter}
      GROUP BY u.user_id, u.name
      
      ORDER BY 
        CASE severity
          WHEN 'error' THEN 1
          WHEN 'warning' THEN 2
          WHEN 'info' THEN 3
          WHEN 'success' THEN 4
        END,
        created_at DESC
      LIMIT ${limit}
    ` as any[];

    // Get alert counts by severity
    const alertCounts = await prisma.$queryRaw`
      SELECT 
        severity,
        COUNT(*) as count
      FROM (
        SELECT 'warning' as severity
        FROM inventory_allocations ia
        WHERE ia.quantity_available <= ia.min_stock_level
        
        UNION ALL
        
        SELECT 'error' as severity
        FROM orders o
        WHERE o.status = 'confirmed' AND DATEDIFF(day, o.created_at, GETDATE()) > 3
        
        UNION ALL
        
        SELECT 'info' as severity
        FROM orders o
        WHERE o.total_amount > 50000 AND o.status = 'pending'
        
        UNION ALL
        
        SELECT 'success' as severity
        FROM commissions c
        WHERE c.status = 'pending'
      ) alert_data
      GROUP BY severity
    ` as any[];

    res.json({
      success: true,
      data: {
        alerts,
        counts: alertCounts,
        metadata: {
          total: alerts.length,
          severity,
          generated_at: new Date()
        }
      }
    });
  } catch (error) {
    console.error('Error fetching alerts:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

export default router;

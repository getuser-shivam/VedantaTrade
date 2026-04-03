import { Router, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { authenticate, authorize } from '../middleware/rbac';

const router = Router();
const prisma = new PrismaClient();

// GET /api/analytics/sales/dashboard - Get comprehensive sales dashboard
router.get('/sales/dashboard', authenticate, authorize('analytics:read'), async (req: any, res: Response) => {
  try {
    const { period = '30d', center_id, medical_rep_id } = req.query;

    // Calculate date range
    let dateFilter = '';
    if (period === '7d') {
      dateFilter = "AND o.created_at >= DATEADD(day, -7, GETDATE())";
    } else if (period === '30d') {
      dateFilter = "AND o.created_at >= DATEADD(day, -30, GETDATE())";
    } else if (period === '90d') {
      dateFilter = "AND o.created_at >= DATEADD(day, -90, GETDATE())";
    } else if (period === '1y') {
      dateFilter = "AND o.created_at >= DATEADD(year, -1, GETDATE())";
    }

    const centerFilter = center_id ? `AND o.center_id = ${center_id}` : '';
    const repFilter = medical_rep_id ? `AND o.medical_rep_id = ${medical_rep_id}` : '';

    // Get key metrics
    const [keyMetrics, salesTrend, topProducts, regionalSales, customerSegments] = await Promise.all([
      // Key performance indicators
      prisma.$queryRaw`
        SELECT 
          COUNT(DISTINCT o.order_id) as total_orders,
          SUM(o.total_amount) as total_revenue,
          AVG(o.total_amount) as avg_order_value,
          COUNT(DISTINCT o.customer_id) as unique_customers,
          COUNT(DISTINCT o.medical_rep_id) as active_reps,
          SUM(CASE WHEN o.created_at >= DATEADD(day, -7, GETDATE()) THEN 1 ELSE 0 END) as orders_this_week,
          SUM(CASE WHEN o.created_at >= DATEADD(day, -7, GETDATE()) THEN o.total_amount ELSE 0 END) as revenue_this_week,
          SUM(CASE WHEN o.created_at >= DATEADD(day, -30, GETDATE()) THEN 1 ELSE 0 END) as orders_this_month,
          SUM(CASE WHEN o.created_at >= DATEADD(day, -30, GETDATE()) THEN o.total_amount ELSE 0 END) as revenue_this_month
        FROM orders o
        WHERE o.status = 'completed' ${dateFilter} ${centerFilter} ${repFilter}
      ` as any[],

      // Sales trend over time
      prisma.$queryRaw`
        SELECT 
          CAST(o.created_at AS DATE) as date,
          COUNT(*) as orders,
          SUM(o.total_amount) as revenue,
          COUNT(DISTINCT o.customer_id) as customers,
          AVG(o.total_amount) as avg_order_value
        FROM orders o
        WHERE o.status = 'completed' ${dateFilter} ${centerFilter} ${repFilter}
        GROUP BY CAST(o.created_at AS DATE)
        ORDER BY date ASC
      ` as any[],

      // Top performing products
      prisma.$queryRaw`
        SELECT TOP 10
          p.item_name as product_name,
          p.category_id,
          COUNT(DISTINCT oi.order_id) as order_count,
          SUM(oi.quantity) as total_quantity,
          SUM(oi.quantity * oi.unit_price) as total_revenue,
          AVG(oi.unit_price) as avg_price,
          SUM(oi.quantity * oi.unit_price) * 100.0 / (
            SELECT SUM(oi2.quantity * oi2.unit_price) 
            FROM order_items oi2 
            JOIN orders o2 ON oi2.order_id = o2.order_id 
            WHERE o2.status = 'completed' ${dateFilter} ${centerFilter} ${repFilter}
          ) as revenue_percentage
        FROM order_items oi
        JOIN orders o ON oi.order_id = o.order_id
        JOIN inventory_items p ON oi.product_id = p.item_id
        WHERE o.status = 'completed' ${dateFilter} ${centerFilter} ${repFilter}
        GROUP BY p.item_name, p.item_id, p.category_id
        ORDER BY total_revenue DESC
      ` as any[],

      // Regional sales performance
      prisma.$queryRaw`
        SELECT 
          dc.name as region,
          dc.id as center_id,
          COUNT(DISTINCT o.order_id) as orders,
          SUM(o.total_amount) as revenue,
          COUNT(DISTINCT o.customer_id) as customers,
          AVG(o.total_amount) as avg_order_value,
          COUNT(DISTINCT o.medical_rep_id) as active_reps
        FROM orders o
        JOIN distribution_centers dc ON o.center_id = dc.id
        WHERE o.status = 'completed' ${dateFilter}
        GROUP BY dc.id, dc.name
        ORDER BY revenue DESC
      ` as any[],

      // Customer segment analysis
      prisma.$queryRaw`
        SELECT 
          CASE 
            WHEN total_spent >= 100000 THEN 'Enterprise'
            WHEN total_spent >= 50000 THEN 'Large'
            WHEN total_spent >= 10000 THEN 'Medium'
            ELSE 'Small'
          END as segment,
          COUNT(*) as customer_count,
          SUM(total_spent) as total_revenue,
          AVG(total_spent) as avg_customer_value,
          SUM(order_count) as total_orders
        FROM (
          SELECT 
            c.customer_id,
            c.name,
            SUM(o.total_amount) as total_spent,
            COUNT(o.order_id) as order_count
          FROM customers c
          JOIN orders o ON c.customer_id = o.customer_id
          WHERE o.status = 'completed' ${dateFilter} ${centerFilter} ${repFilter}
          GROUP BY c.customer_id, c.name
        ) customer_data
        GROUP BY 
          CASE 
            WHEN total_spent >= 100000 THEN 'Enterprise'
            WHEN total_spent >= 50000 THEN 'Large'
            WHEN total_spent >= 10000 THEN 'Medium'
            ELSE 'Small'
          END
        ORDER BY total_revenue DESC
      ` as any[]
    ]);

    // Get growth metrics
    const growthMetrics = await prisma.$queryRaw`
      SELECT 
        'Revenue Growth' as metric,
        CAST(
          (SUM(CASE WHEN created_at >= DATEADD(day, -30, GETDATE()) THEN total_amount ELSE 0 END) * 100.0 / 
           NULLIF(SUM(CASE WHEN created_at >= DATEADD(day, -60, GETDATE()) AND created_at < DATEADD(day, -30, GETDATE()) THEN total_amount ELSE 0 END), 0) - 100
        AS DECIMAL(10,2)) as growth_rate
      
      UNION ALL
      
      SELECT 
        'Order Growth' as metric,
        CAST(
          (COUNT(CASE WHEN created_at >= DATEADD(day, -30, GETDATE()) THEN 1 END) * 100.0 / 
           NULLIF(COUNT(CASE WHEN created_at >= DATEADD(day, -60, GETDATE()) AND created_at < DATEADD(day, -30, GETDATE()) THEN 1 END), 0) - 100
        AS DECIMAL(10,2)) as growth_rate
      
      UNION ALL
      
      SELECT 
        'Customer Growth' as metric,
        CAST(
          (COUNT(DISTINCT CASE WHEN created_at >= DATEADD(day, -30, GETDATE()) THEN customer_id END) * 100.0 / 
           NULLIF(COUNT(DISTINCT CASE WHEN created_at >= DATEADD(day, -60, GETDATE()) AND created_at < DATEADD(day, -30, GETDATE()) THEN customer_id END), 0) - 100
        AS DECIMAL(10,2)) as growth_rate
      FROM orders
      WHERE status = 'completed'
        AND created_at >= DATEADD(day, -60, GETDATE())
        ${centerFilter} ${repFilter}
    ` as any[];

    res.json({
      success: true,
      data: {
        keyMetrics: keyMetrics[0] || {},
        salesTrend,
        topProducts,
        regionalSales,
        customerSegments,
        growthMetrics
      }
    });
  } catch (error) {
    console.error('Error fetching sales dashboard:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// GET /api/analytics/sales/performance - Get detailed performance analysis
router.get('/sales/performance', authenticate, authorize('analytics:read'), async (req: any, res: Response) => {
  try {
    const { period = '30d', group_by = 'medical_rep' } = req.query;

    // Calculate date range
    let dateFilter = '';
    if (period === '7d') {
      dateFilter = "AND o.created_at >= DATEADD(day, -7, GETDATE())";
    } else if (period === '30d') {
      dateFilter = "AND o.created_at >= DATEADD(day, -30, GETDATE())";
    } else if (period === '90d') {
      dateFilter = "AND o.created_at >= DATEADD(day, -90, GETDATE())";
    }

    let performanceData;

    switch (group_by) {
      case 'medical_rep':
        performanceData = await prisma.$queryRaw`
          SELECT 
            u.user_id as rep_id,
            u.name as rep_name,
            u.email as rep_email,
            COUNT(DISTINCT o.order_id) as total_orders,
            SUM(o.total_amount) as total_revenue,
            AVG(o.total_amount) as avg_order_value,
            COUNT(DISTINCT o.customer_id) as unique_customers,
            COUNT(DISTINCT CASE WHEN o.created_at >= DATEADD(day, -7, GETDATE()) THEN o.order_id END) as orders_this_week,
            SUM(CASE WHEN o.created_at >= DATEADD(day, -7, GETDATE()) THEN o.total_amount ELSE 0 END) as revenue_this_week,
            DENSE_RANK() OVER (ORDER BY SUM(o.total_amount) DESC) as revenue_rank,
            DENSE_RANK() OVER (ORDER BY COUNT(DISTINCT o.order_id) DESC) as orders_rank,
            DENSE_RANK() OVER (ORDER BY COUNT(DISTINCT o.customer_id) DESC) as customers_rank
          FROM orders o
          JOIN users u ON o.medical_rep_id = u.user_id
          WHERE o.status = 'completed' ${dateFilter}
          GROUP BY u.user_id, u.name, u.email
          ORDER BY total_revenue DESC
        ` as any[];
        break;

      case 'product':
        performanceData = await prisma.$queryRaw`
          SELECT 
            p.item_name as product_name,
            p.category_id,
            pc.name as category_name,
            COUNT(DISTINCT oi.order_id) as total_orders,
            SUM(oi.quantity) as total_quantity,
            SUM(oi.quantity * oi.unit_price) as total_revenue,
            AVG(oi.unit_price) as avg_price,
            COUNT(DISTINCT o.customer_id) as unique_customers,
            COUNT(DISTINCT o.medical_rep_id) as selling_reps,
            DENSE_RANK() OVER (ORDER BY SUM(oi.quantity * oi.unit_price) DESC) as revenue_rank,
            DENSE_RANK() OVER (ORDER BY SUM(oi.quantity) DESC) as quantity_rank
          FROM order_items oi
          JOIN orders o ON oi.order_id = o.order_id
          JOIN inventory_items p ON oi.product_id = p.item_id
          JOIN product_categories pc ON p.category_id = pc.id
          WHERE o.status = 'completed' ${dateFilter}
          GROUP BY p.item_name, p.item_id, p.category_id, pc.name
          ORDER BY total_revenue DESC
        ` as any[];
        break;

      case 'region':
        performanceData = await prisma.$queryRaw`
          SELECT 
            dc.name as region_name,
            dc.id as center_id,
            dc.city,
            dc.state,
            COUNT(DISTINCT o.order_id) as total_orders,
            SUM(o.total_amount) as total_revenue,
            AVG(o.total_amount) as avg_order_value,
            COUNT(DISTINCT o.customer_id) as unique_customers,
            COUNT(DISTINCT o.medical_rep_id) as active_reps,
            DENSE_RANK() OVER (ORDER BY SUM(o.total_amount) DESC) as revenue_rank,
            DENSE_RANK() OVER (ORDER BY COUNT(DISTINCT o.order_id) DESC) as orders_rank
          FROM orders o
          JOIN distribution_centers dc ON o.center_id = dc.id
          WHERE o.status = 'completed' ${dateFilter}
          GROUP BY dc.id, dc.name, dc.city, dc.state
          ORDER BY total_revenue DESC
        ` as any[];
        break;

      default:
        performanceData = [];
    }

    // Get performance targets and achievements
    const targets = await prisma.$queryRaw`
      SELECT 
        target_type,
        target_value,
        actual_value,
        (actual_value * 100.0 / target_value) as achievement_percentage,
        CASE 
          WHEN actual_value >= target_value THEN 'Achieved'
          WHEN actual_value >= target_value * 0.8 THEN 'On Track'
          ELSE 'Behind'
        END as status
      FROM performance_targets pt
      LEFT JOIN (
        SELECT 
          'monthly_revenue' as target_type,
          SUM(total_amount) as actual_value
        FROM orders
        WHERE status = 'completed' 
          AND created_at >= DATEADD(month, -1, GETDATE())
        
        UNION ALL
        
        SELECT 
          'monthly_orders' as target_type,
          COUNT(*) as actual_value
        FROM orders
        WHERE status = 'completed' 
          AND created_at >= DATEADD(month, -1, GETDATE())
        
        UNION ALL
        
        SELECT 
          'new_customers' as target_type,
          COUNT(DISTINCT customer_id) as actual_value
        FROM orders
        WHERE status = 'completed' 
          AND created_at >= DATEADD(month, -1, GETDATE())
      ) actual_data ON pt.target_type = actual_data.target_type
      WHERE pt.is_active = 1
    ` as any[];

    res.json({
      success: true,
      data: {
        performanceData,
        targets,
        groupBy: group_by
      }
    });
  } catch (error) {
    console.error('Error fetching performance analysis:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// GET /api/analytics/sales/funnel - Get sales funnel analysis
router.get('/sales/funnel', authenticate, authorize('analytics:read'), async (req: any, res: Response) => {
  try {
    const { period = '30d' } = req.query;

    // Calculate date range
    let dateFilter = '';
    if (period === '7d') {
      dateFilter = "AND created_at >= DATEADD(day, -7, GETDATE())";
    } else if (period === '30d') {
      dateFilter = "AND created_at >= DATEADD(day, -30, GETDATE())";
    } else if (period === '90d') {
      dateFilter = "AND created_at >= DATEADD(day, -90, GETDATE())";
    }

    // Get funnel stages
    const [funnelData, conversionRates, funnelTrend] = await Promise.all([
      // Current funnel data
      prisma.$queryRaw`
        SELECT 
          'Leads' as stage,
          COUNT(*) as count,
          100.0 as percentage
        FROM campaign_leads
        WHERE 1=1 ${dateFilter}
        
        UNION ALL
        
        SELECT 
          'Qualified Leads' as stage,
          COUNT(*) as count,
          (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM campaign_leads WHERE 1=1 ${dateFilter})) as percentage
        FROM campaign_leads
        WHERE status = 'qualified' ${dateFilter}
        
        UNION ALL
        
        SELECT 
          'Opportunities' as stage,
          COUNT(DISTINCT o.order_id) as count,
          (COUNT(DISTINCT o.order_id) * 100.0 / (SELECT COUNT(*) FROM campaign_leads WHERE 1=1 ${dateFilter})) as percentage
        FROM orders o
        WHERE o.status IN ('pending', 'confirmed') ${dateFilter}
        
        UNION ALL
        
        SELECT 
          'Proposals' as stage,
          COUNT(DISTINCT o.order_id) as count,
          (COUNT(DISTINCT o.order_id) * 100.0 / (SELECT COUNT(*) FROM campaign_leads WHERE 1=1 ${dateFilter})) as percentage
        FROM orders o
        WHERE o.status = 'confirmed' ${dateFilter}
        
        UNION ALL
        
        SELECT 
          'Closed Won' as stage,
          COUNT(DISTINCT o.order_id) as count,
          (COUNT(DISTINCT o.order_id) * 100.0 / (SELECT COUNT(*) FROM campaign_leads WHERE 1=1 ${dateFilter})) as percentage
        FROM orders o
        WHERE o.status = 'completed' ${dateFilter}
        
        UNION ALL
        
        SELECT 
          'Closed Lost' as stage,
          COUNT(DISTINCT o.order_id) as count,
          (COUNT(DISTINCT o.order_id) * 100.0 / (SELECT COUNT(*) FROM campaign_leads WHERE 1=1 ${dateFilter})) as percentage
        FROM orders o
        WHERE o.status = 'cancelled' ${dateFilter}
        ORDER BY 
          CASE stage
            WHEN 'Leads' THEN 1
            WHEN 'Qualified Leads' THEN 2
            WHEN 'Opportunities' THEN 3
            WHEN 'Proposals' THEN 4
            WHEN 'Closed Won' THEN 5
            WHEN 'Closed Lost' THEN 6
          END
      ` as any[],

      // Conversion rates between stages
      prisma.$queryRaw`
        SELECT 
          'Lead to Qualified' as conversion_type,
          CAST(COUNT(CASE WHEN status = 'qualified' THEN 1 END) * 100.0 / COUNT(*) AS DECIMAL(10,2)) as conversion_rate
        FROM campaign_leads
        WHERE 1=1 ${dateFilter}
        
        UNION ALL
        
        SELECT 
          'Qualified to Opportunity' as conversion_type,
          CAST(COUNT(DISTINCT o.order_id) * 100.0 / NULLIF((
            SELECT COUNT(*) FROM campaign_leads 
            WHERE status = 'qualified' ${dateFilter}
          ), 0) AS DECIMAL(10,2)) as conversion_rate
        FROM orders o
        WHERE o.status IN ('pending', 'confirmed', 'completed', 'cancelled') ${dateFilter}
        
        UNION ALL
        
        SELECT 
          'Opportunity to Closed Won' as conversion_type,
          CAST(COUNT(DISTINCT CASE WHEN o.status = 'completed' THEN o.order_id END) * 100.0 / 
               NULLIF(COUNT(DISTINCT o.order_id), 0) AS DECIMAL(10,2)) as conversion_rate
        FROM orders o
        WHERE o.status IN ('pending', 'confirmed', 'completed', 'cancelled') ${dateFilter}
      ` as any[],

      // Funnel trend over time
      prisma.$queryRaw`
        SELECT 
          CAST(created_at AS DATE) as date,
          COUNT(*) as leads,
          COUNT(CASE WHEN status = 'qualified' THEN 1 END) as qualified_leads,
          COUNT(DISTINCT o.order_id) as opportunities,
          COUNT(DISTINCT CASE WHEN o.status = 'completed' THEN o.order_id END) as closed_won
        FROM campaign_leads cl
        LEFT JOIN orders o ON cl.customer_id = o.customer_id
        WHERE 1=1 ${dateFilter}
        GROUP BY CAST(created_at AS DATE)
        ORDER BY date ASC
      ` as any[]
    ]);

    // Get average time in each stage
    const stageDurations = await prisma.$queryRaw`
      SELECT 
        'Lead to Qualified' as stage,
        AVG(DATEDIFF(day, cl.created_at, 
          (SELECT MIN(created_at) FROM campaign_leads cl2 
           WHERE cl2.customer_id = cl.customer_id AND cl2.status = 'qualified')
        )) as avg_days
      FROM campaign_leads cl
      WHERE cl.status = 'qualified' ${dateFilter}
      
      UNION ALL
      
      SELECT 
        'Qualified to Order' as stage,
        AVG(DATEDIFF(day, 
          (SELECT MIN(created_at) FROM campaign_leads cl2 
           WHERE cl2.customer_id = cl.customer_id AND cl2.status = 'qualified'),
          o.created_at
        )) as avg_days
      FROM orders o
      JOIN campaign_leads cl ON o.customer_id = cl.customer_id
      WHERE cl.status = 'qualified' ${dateFilter}
      
      UNION ALL
      
      SELECT 
        'Order to Completion' as stage,
        AVG(DATEDIFF(day, o.created_at, o.delivered_at)) as avg_days
      FROM orders o
      WHERE o.status = 'completed' AND o.delivered_at IS NOT NULL ${dateFilter}
    ` as any[];

    res.json({
      success: true,
      data: {
        funnelData,
        conversionRates,
        funnelTrend,
        stageDurations
      }
    });
  } catch (error) {
    console.error('Error fetching sales funnel:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// GET /api/analytics/sales/reports - Generate sales reports
router.get('/sales/reports', authenticate, authorize('analytics:export'), async (req: any, res: Response) => {
  try {
    const { 
      report_type = 'summary', 
      format = 'json',
      start_date,
      end_date,
      center_id,
      medical_rep_id 
    } = req.query;

    const dateFilter = start_date && end_date 
      ? `AND o.created_at >= '${start_date}' AND o.created_at <= '${end_date}'`
      : "AND o.created_at >= DATEADD(day, -30, GETDATE())";

    const centerFilter = center_id ? `AND o.center_id = ${center_id}` : '';
    const repFilter = medical_rep_id ? `AND o.medical_rep_id = ${medical_rep_id}` : '';

    let reportData;

    switch (report_type) {
      case 'summary':
        reportData = await prisma.$queryRaw`
          SELECT 
            'Sales Summary' as report_type,
            GETDATE() as generated_at,
            '${start_date || '30 days ago'}' as period_start,
            '${end_date || 'Today'}' as period_end,
            COUNT(DISTINCT o.order_id) as total_orders,
            SUM(o.total_amount) as total_revenue,
            AVG(o.total_amount) as avg_order_value,
            COUNT(DISTINCT o.customer_id) as unique_customers,
            COUNT(DISTINCT o.medical_rep_id) as active_reps
          FROM orders o
          WHERE o.status = 'completed' ${dateFilter} ${centerFilter} ${repFilter}
        ` as any[];
        break;

      case 'detailed':
        reportData = await prisma.$queryRaw`
          SELECT 
            o.order_id,
            o.created_at,
            o.total_amount,
            o.status,
            c.name as customer_name,
            c.email as customer_email,
            u.name as medical_rep_name,
            dc.name as distribution_center,
            pc.name as product_category,
            COUNT(oi.order_item_id) as item_count,
            STRING_AGG(p.item_name, ', ') as products
          FROM orders o
          JOIN customers c ON o.customer_id = c.customer_id
          JOIN users u ON o.medical_rep_id = u.user_id
          JOIN distribution_centers dc ON o.center_id = dc.id
          JOIN order_items oi ON o.order_id = oi.order_id
          JOIN inventory_items p ON oi.product_id = p.item_id
          JOIN product_categories pc ON p.category_id = pc.id
          WHERE o.status = 'completed' ${dateFilter} ${centerFilter} ${repFilter}
          GROUP BY o.order_id, o.created_at, o.total_amount, o.status, 
                   c.name, c.email, u.name, dc.name, pc.name
          ORDER BY o.created_at DESC
        ` as any[];
        break;

      case 'commission':
        reportData = await prisma.$queryRaw`
          SELECT 
            u.user_id as rep_id,
            u.name as rep_name,
            COUNT(DISTINCT o.order_id) as total_orders,
            SUM(o.total_amount) as total_sales,
            SUM(c.commission_amount) as total_commission,
            AVG(c.commission_rate) as avg_commission_rate,
            COUNT(CASE WHEN c.status = 'paid' THEN 1 END) as paid_commissions,
            COUNT(CASE WHEN c.status = 'pending' THEN 1 END) as pending_commissions
          FROM users u
          LEFT JOIN orders o ON u.user_id = o.medical_rep_id AND o.status = 'completed'
          LEFT JOIN commissions c ON o.order_id = c.order_id
          WHERE u.role = 'MEDICAL_REP' ${repFilter} ${dateFilter}
          GROUP BY u.user_id, u.name
          ORDER BY total_commission DESC
        ` as any[];
        break;

      default:
        reportData = [];
    }

    // Export to different formats if needed
    if (format === 'csv') {
      // Convert to CSV format (simplified)
      const csvHeaders = Object.keys(reportData[0] || {}).join(',');
      const csvRows = reportData.map(row => 
        Object.values(row).map(val => `"${val}"`).join(',')
      );
      const csvContent = [csvHeaders, ...csvRows].join('\n');
      
      res.setHeader('Content-Type', 'text/csv');
      res.setHeader('Content-Disposition', `attachment; filename=sales_report_${report_type}.csv`);
      return res.send(csvContent);
    }

    res.json({
      success: true,
      data: reportData,
      metadata: {
        report_type,
        generated_at: new Date(),
        filters: { start_date, end_date, center_id, medical_rep_id }
      }
    });
  } catch (error) {
    console.error('Error generating sales report:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

export default router;

import { Router, Response, Request } from 'express';
import { PrismaClient } from '@prisma/client';
import { enhancedAuthenticate as authenticate, enhancedAuthorize as authorize } from '../middleware/enhancedAuth';
import { AuthRequest } from '../middleware/enhancedAuth';

const router = Router();
const prisma = new PrismaClient();

// GET /api/analytics/sales - Get sales analytics with filtering
router.get('/sales', authenticate, async (req: any, res: Response) => {
  try {
    const { 
      period = '30d', 
      center_id, 
      campaign_id, 
      product_id,
      group_by = 'date'
    } = req.query;
    
    // Calculate date range
    let dateFilter = '';
    if (period === '7d') {
      dateFilter = "AND DATE(sa.analytics_date) >= DATEADD(day, -7, GETDATE())";
    } else if (period === '30d') {
      dateFilter = "AND DATE(sa.analytics_date) >= DATEADD(day, -30, GETDATE())";
    } else if (period === '90d') {
      dateFilter = "AND DATE(sa.analytics_date) >= DATEADD(day, -90, GETDATE())";
    } else if (period === '1y') {
      dateFilter = "AND DATE(sa.analytics_date) >= DATEADD(year, -1, GETDATE())";
    }
    
    // Build additional filters
    let additionalFilters = '';
    if (center_id) {
      additionalFilters += ` AND sa.center_id = ${center_id}`;
    }
    if (campaign_id) {
      additionalFilters += ` AND sa.campaign_id = ${campaign_id}`;
    }
    if (product_id) {
      additionalFilters += ` AND sa.product_id = ${product_id}`;
    }
    
    // Get sales data with grouping
    let groupByClause = '';
    let selectFields = '';
    
    switch (group_by) {
      case 'date':
        groupByClause = 'GROUP BY DATE(sa.analytics_date)';
        selectFields = 'DATE(sa.analytics_date) as date_key';
        break;
      case 'week':
        groupByClause = 'GROUP BY DATEPART(week, sa.analytics_date), YEAR(sa.analytics_date)';
        selectFields = 'DATEPART(week, sa.analytics_date) as week_key, YEAR(sa.analytics_date) as year_key';
        break;
      case 'month':
        groupByClause = 'GROUP BY MONTH(sa.analytics_date), YEAR(sa.analytics_date)';
        selectFields = 'MONTH(sa.analytics_date) as month_key, YEAR(sa.analytics_date) as year_key';
        break;
      case 'product':
        groupByClause = 'GROUP BY sa.product_id, p.item_name';
        selectFields = 'sa.product_id, p.item_name as product_name';
        break;
      case 'center':
        groupByClause = 'GROUP BY sa.center_id, dc.name';
        selectFields = 'sa.center_id, dc.name as center_name';
        break;
      case 'campaign':
        groupByClause = 'GROUP BY sa.campaign_id, mc.name';
        selectFields = 'sa.campaign_id, mc.name as campaign_name';
        break;
    }
    
    const salesData = await prisma.$queryRaw`
      SELECT 
        ${selectFields},
        SUM(sa.sales_quantity) as total_sales,
        SUM(sa.revenue) as total_revenue,
        SUM(sa.cost) as total_cost,
        SUM(sa.profit) as total_profit,
        AVG(sa.profit) as avg_profit_per_sale,
        COUNT(DISTINCT sa.product_id) as unique_products,
        COUNT(*) as transaction_count
      FROM sales_analytics sa
      LEFT JOIN inventory_items p ON sa.product_id = p.item_id
      LEFT JOIN distribution_centers dc ON sa.center_id = dc.id
      LEFT JOIN marketing_campaigns mc ON sa.campaign_id = mc.id
      WHERE 1=1 ${dateFilter} ${additionalFilters}
      ${groupByClause}
      ORDER BY total_revenue DESC
    `;
    
    // Get summary statistics
    const summary = await prisma.$queryRaw`
      SELECT 
        SUM(sa.sales_quantity) as total_sales,
        SUM(sa.revenue) as total_revenue,
        SUM(sa.cost) as total_cost,
        SUM(sa.profit) as total_profit,
        AVG(sa.profit) as avg_profit_per_sale,
        COUNT(DISTINCT sa.product_id) as unique_products,
        COUNT(*) as total_transactions,
        MAX(sa.revenue) as best_day_revenue,
        MIN(sa.revenue) as worst_day_revenue
      FROM sales_analytics sa
      WHERE 1=1 ${dateFilter} ${additionalFilters}
    `;
    
    // Get top products
    const topProducts = await prisma.$queryRaw`
      SELECT TOP 10
        p.item_name as product_name,
        SUM(sa.sales_quantity) as total_sales,
        SUM(sa.revenue) as total_revenue,
        SUM(sa.profit) as total_profit,
        COUNT(*) as transaction_count
      FROM sales_analytics sa
      LEFT JOIN inventory_items p ON sa.product_id = p.item_id
      WHERE 1=1 ${dateFilter} ${additionalFilters}
      GROUP BY p.item_name, sa.product_id
      ORDER BY total_revenue DESC
    `;
    
    // Get top centers
    const topCenters = await prisma.$queryRaw`
      SELECT TOP 10
        dc.name as center_name,
        dc.city,
        SUM(sa.sales_quantity) as total_sales,
        SUM(sa.revenue) as total_revenue,
        SUM(sa.profit) as total_profit,
        COUNT(*) as transaction_count
      FROM sales_analytics sa
      LEFT JOIN distribution_centers dc ON sa.center_id = dc.id
      WHERE 1=1 ${dateFilter}
      GROUP BY dc.name, dc.city, sa.center_id
      ORDER BY total_revenue DESC
    `;
    
    res.json({
      success: true,
      data: {
        sales_data: salesData,
        summary: (summary as any)[0],
        top_products: topProducts,
        top_centers: topCenters,
        period,
        filters: {
          center_id,
          campaign_id,
          product_id
        }
      }
    });
  } catch (error) {
    console.error('Error fetching sales analytics:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch sales analytics'
    });
  }
});

// GET /api/analytics/inventory - Get inventory analytics
router.get('/inventory', authenticate, async (req: any, res: Response) => {
  try {
    const { 
      center_id, 
      period = '30d',
      alert_type = 'all'
    } = req.query;
    
    // Build filters
    let centerFilter = center_id ? `AND ia.center_id = ${center_id}` : '';
    
    // Get inventory status distribution
    const inventoryStatus = await prisma.$queryRaw`
      SELECT 
        CASE 
          WHEN ia.quantity_available = 0 THEN 'OUT_OF_STOCK'
          WHEN ia.quantity_available <= ia.quantity_allocated * 0.2 THEN 'LOW_STOCK'
          WHEN ia.quantity_available <= ia.quantity_allocated * 0.5 THEN 'MEDIUM_STOCK'
          ELSE 'GOOD_STOCK'
        END as stock_status,
        COUNT(*) as count,
        SUM(ia.quantity_allocated) as total_allocated,
        SUM(ia.quantity_available) as total_available,
        AVG(ia.quantity_available) as avg_available
      FROM inventory_allocations ia
      WHERE 1=1 ${centerFilter}
      GROUP BY 
        CASE 
          WHEN ia.quantity_available = 0 THEN 'OUT_OF_STOCK'
          WHEN ia.quantity_available <= ia.quantity_allocated * 0.2 THEN 'LOW_STOCK'
          WHEN ia.quantity_available <= ia.quantity_allocated * 0.5 THEN 'MEDIUM_STOCK'
          ELSE 'GOOD_STOCK'
        END
    `;
    
    // Get inventory movements in the period
    let dateFilter = '';
    if (period === '7d') {
      dateFilter = "AND DATE(im.movement_date) >= DATEADD(day, -7, GETDATE())";
    } else if (period === '30d') {
      dateFilter = "AND DATE(im.movement_date) >= DATEADD(day, -30, GETDATE())";
    } else if (period === '90d') {
      dateFilter = "AND DATE(im.movement_date) >= DATEADD(day, -90, GETDATE())";
    }
    
    const movements = await prisma.$queryRaw`
      SELECT 
        im.movement_type,
        COUNT(*) as count,
        SUM(im.quantity) as total_quantity,
        COUNT(DISTINCT im.product_id) as unique_products
      FROM inventory_movements im
      WHERE 1=1 ${dateFilter} ${centerFilter}
      GROUP BY im.movement_type
      ORDER BY total_quantity DESC
    `;
    
    // Get low stock alerts
    let alerts = [];
    if (alert_type === 'all' || alert_type === 'low_stock') {
      const lowStockAlerts = await prisma.$queryRaw`
        SELECT 
          p.item_name as product_name,
          dc.name as center_name,
          ia.quantity_available,
          ia.quantity_allocated,
          ia.quantity_allocated * 0.2 as threshold,
          ia.last_updated,
          'LOW_STOCK' as alert_type
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
      const outOfStockAlerts = await prisma.$queryRaw`
        SELECT 
          p.item_name as product_name,
          dc.name as center_name,
          ia.quantity_available,
          ia.quantity_allocated,
          ia.last_updated,
          'OUT_OF_STOCK' as alert_type
        FROM inventory_allocations ia
        LEFT JOIN inventory_items p ON ia.product_id = p.item_id
        LEFT JOIN distribution_centers dc ON ia.center_id = dc.id
        WHERE ia.quantity_available = 0
          ${centerFilter}
        ORDER BY ia.last_updated DESC
      `;
      alerts.push(...(outOfStockAlerts as any[]));
    }
    
    // Get inventory turnover
    const turnover = await prisma.$queryRaw`
      SELECT 
        p.item_name as product_name,
        ia.quantity_allocated,
        ia.quantity_available,
        COALESCE(SUM(CASE WHEN im.movement_type = 'SALE' THEN im.quantity ELSE 0 END), 0) as total_sold,
        CASE 
          WHEN ia.quantity_allocated > 0 
          THEN COALESCE(SUM(CASE WHEN im.movement_type = 'SALE' THEN im.quantity ELSE 0 END), 0) / ia.quantity_allocated
          ELSE 0
        END as turnover_ratio
      FROM inventory_allocations ia
      LEFT JOIN inventory_items p ON ia.product_id = p.item_id
      LEFT JOIN inventory_movements im ON ia.product_id = im.product_id
        ${dateFilter}
      WHERE 1=1 ${centerFilter}
      GROUP BY p.item_name, ia.product_id, ia.quantity_allocated, ia.quantity_available
      ORDER BY turnover_ratio DESC
    `;
    
    res.json({
      success: true,
      data: {
        inventory_status: inventoryStatus,
        movements: movements,
        alerts: alerts,
        turnover: turnover,
        period
      }
    });
  } catch (error) {
    console.error('Error fetching inventory analytics:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch inventory analytics'
    });
  }
});

// GET /api/analytics/performance - Get overall performance metrics
router.get('/performance', authenticate, async (req: any, res: Response) => {
  try {
    const { period = '30d' } = req.query;
    
    // Calculate date range
    let dateFilter = '';
    if (period === '7d') {
      dateFilter = "WHERE DATE(sa.analytics_date) >= DATEADD(day, -7, GETDATE())";
    } else if (period === '30d') {
      dateFilter = "WHERE DATE(sa.analytics_date) >= DATEADD(day, -30, GETDATE())";
    } else if (period === '90d') {
      dateFilter = "WHERE DATE(sa.analytics_date) >= DATEADD(day, -90, GETDATE())";
    }
    
    // Get key performance indicators
    const kpis = await prisma.$queryRaw`
      SELECT 
        SUM(sa.sales_quantity) as total_sales,
        SUM(sa.revenue) as total_revenue,
        SUM(sa.cost) as total_cost,
        SUM(sa.profit) as total_profit,
        COUNT(*) as total_transactions,
        AVG(sa.profit) as avg_profit_per_transaction,
        COUNT(DISTINCT sa.product_id) as unique_products_sold,
        COUNT(DISTINCT sa.center_id) as active_centers,
        COUNT(DISTINCT sa.campaign_id) as active_campaigns,
        MAX(sa.revenue) as best_day_revenue,
        MIN(sa.revenue) as worst_day_revenue,
        CASE 
          WHEN LAG(SUM(sa.revenue)) OVER (ORDER BY DATE(sa.analytics_date)) IS NOT NULL
          THEN (SUM(sa.revenue) - LAG(SUM(sa.revenue)) OVER (ORDER BY DATE(sa.analytics_date))) / 
               LAG(SUM(sa.revenue)) OVER (ORDER BY DATE(sa.analytics_date)) * 100
          ELSE 0
        END as revenue_growth_rate
      FROM sales_analytics sa
      ${dateFilter}
      GROUP BY DATE(sa.analytics_date)
      ORDER BY DATE(sa.analytics_date) DESC
    `;
    
    // Get campaign performance
    const campaignPerformance = await prisma.$queryRaw`
      SELECT 
        mc.name as campaign_name,
        mc.status,
        mc.budget,
        SUM(sa.revenue) as generated_revenue,
        SUM(sa.profit) as generated_profit,
        COUNT(DISTINCT sa.product_id) as products_sold,
        CASE 
          WHEN mc.budget > 0 
          THEN (SUM(sa.revenue) / mc.budget) * 100
          ELSE 0
        END as roi_percentage,
        DATEDIFF(day, mc.start_date, GETDATE()) as days_active
      FROM marketing_campaigns mc
      LEFT JOIN sales_analytics sa ON mc.id = sa.campaign_id
      WHERE mc.status = 'ACTIVE'
      GROUP BY mc.name, mc.status, mc.budget, mc.start_date
      ORDER BY generated_revenue DESC
    `;
    
    // Get center performance
    const centerPerformance = await prisma.$queryRaw`
      SELECT 
        dc.name as center_name,
        dc.city,
        dc.capacity,
        COUNT(DISTINCT ia.product_id) as unique_products,
        SUM(ia.quantity_available) as total_available,
        SUM(ia.quantity_allocated) as total_allocated,
        CASE 
          WHEN dc.capacity > 0 
          THEN (SUM(ia.quantity_available) / dc.capacity) * 100
          ELSE 0
        END as capacity_utilization,
        SUM(sa.revenue) as total_revenue,
        COUNT(DISTINCT sa.product_id) as products_sold
      FROM distribution_centers dc
      LEFT JOIN inventory_allocations ia ON dc.id = ia.center_id
      LEFT JOIN sales_analytics sa ON dc.id = sa.center_id
      WHERE dc.is_active = 1
      GROUP BY dc.name, dc.city, dc.capacity, dc.id
      ORDER BY total_revenue DESC
    `;
    
    // Calculate trends
    const trends = await prisma.$queryRaw`
      SELECT 
        DATE(sa.analytics_date) as date,
        SUM(sa.revenue) as daily_revenue,
        SUM(sa.sales_quantity) as daily_sales,
        COUNT(*) as daily_transactions,
        LAG(SUM(sa.revenue)) OVER (ORDER BY DATE(sa.analytics_date)) as prev_day_revenue,
        CASE 
          WHEN LAG(SUM(sa.revenue)) OVER (ORDER BY DATE(sa.analytics_date)) IS NOT NULL
          THEN (SUM(sa.revenue) - LAG(SUM(sa.revenue)) OVER (ORDER BY DATE(sa.analytics_date))) / 
               LAG(SUM(sa.revenue)) OVER (ORDER BY DATE(sa.analytics_date)) * 100
          ELSE 0
        END as revenue_change_percentage
      FROM sales_analytics sa
      ${dateFilter}
      GROUP BY DATE(sa.analytics_date)
      ORDER BY DATE(sa.analytics_date) DESC
    `;
    
    res.json({
      success: true,
      data: {
        kpis: kpis,
        campaign_performance: campaignPerformance,
        center_performance: centerPerformance,
        trends: trends,
        period
      }
    });
  } catch (error) {
    console.error('Error fetching performance analytics:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch performance analytics'
    });
  }
});

// GET /api/analytics/export - Export analytics data
router.get('/export', authenticate, async (req: any, res: Response) => {
  try {
    const { 
      type = 'sales', 
      format = 'csv',
      start_date,
      end_date,
      center_id,
      campaign_id 
    } = req.query;
    
    // Build filters
    let whereClause = '';
    const params: any[] = [];
    
    if (start_date) {
      whereClause += ' WHERE DATE(sa.analytics_date) >= ?';
      params.push(start_date);
    }
    
    if (end_date) {
      whereClause += whereClause ? ' AND DATE(sa.analytics_date) <= ?' : ' WHERE DATE(sa.analytics_date) <= ?';
      params.push(end_date);
    }
    
    if (center_id) {
      whereClause += whereClause ? ' AND sa.center_id = ?' : ' WHERE sa.center_id = ?';
      params.push(center_id);
    }
    
    if (campaign_id) {
      whereClause += whereClause ? ' AND sa.campaign_id = ?' : ' WHERE sa.campaign_id = ?';
      params.push(campaign_id);
    }
    
    let data = [];
    
    switch (type) {
      case 'sales':
        data = await prisma.$queryRaw`
          SELECT 
            sa.analytics_date,
            p.item_name as product_name,
            dc.name as center_name,
            mc.name as campaign_name,
            sa.sales_quantity,
            sa.revenue,
            sa.cost,
            sa.profit
          FROM sales_analytics sa
          LEFT JOIN inventory_items p ON sa.product_id = p.item_id
          LEFT JOIN distribution_centers dc ON sa.center_id = dc.id
          LEFT JOIN marketing_campaigns mc ON sa.campaign_id = mc.id
          ${whereClause}
          ORDER BY sa.analytics_date DESC
        ` as any[];
        break;
        
      case 'inventory':
        data = await prisma.$queryRaw`
          SELECT 
            ia.allocated_at,
            p.item_name as product_name,
            dc.name as center_name,
            ia.quantity_allocated,
            ia.quantity_available,
            ia.last_updated
          FROM inventory_allocations ia
          LEFT JOIN inventory_items p ON ia.product_id = p.item_id
          LEFT JOIN distribution_centers dc ON ia.center_id = dc.id
          WHERE 1=1 ${center_id}
          ORDER BY ia.last_updated DESC
        ` as any[];
        break;
        
      case 'campaigns':
        data = await prisma.$queryRaw`
          SELECT 
            mc.created_at,
            mc.name as campaign_name,
            mc.status,
            mc.budget,
            mc.start_date,
            mc.end_date,
            u.name as created_by,
            COUNT(cp.product_id) as product_count
          FROM marketing_campaigns mc
          LEFT JOIN users u ON mc.created_by = u.user_id
          LEFT JOIN campaign_products cp ON mc.id = cp.campaign_id
          WHERE 1=1 ${campaign_id}
          GROUP BY mc.created_at, mc.name, mc.status, mc.budget, mc.start_date, mc.end_date, u.name, mc.id
          ORDER BY mc.created_at DESC
        ` as any[];
        break;
    }
    
    // Format data based on requested format
    if (format === 'csv') {
      const csv = convertToCSV(data);
      res.setHeader('Content-Type', 'text/csv');
      res.setHeader('Content-Disposition', `attachment; filename=${type}_analytics_${Date.now()}.csv`);
      res.send(csv);
    } else if (format === 'json') {
      res.setHeader('Content-Type', 'application/json');
      res.setHeader('Content-Disposition', `attachment; filename=${type}_analytics_${Date.now()}.json`);
      res.json({
        success: true,
        data: data,
        exported_at: new Date(),
        filters: {
          type,
          start_date,
          end_date,
          center_id,
          campaign_id
        }
      });
    } else {
      res.status(400).json({
        success: false,
        message: 'Unsupported export format',
        supported_formats: ['csv', 'json']
      });
    }
  } catch (error) {
    console.error('Error exporting analytics:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to export analytics'
    });
  }
});

// Helper function to convert data to CSV
function convertToCSV(data: any[]): string {
  if (data.length === 0) return '';
  
  const headers = Object.keys(data[0]);
  const csvHeaders = headers.join(',');
  
  const csvRows = data.map(row => 
    headers.map(header => {
      const value = row[header];
      return typeof value === 'string' && value.includes(',') ? `"${value}"` : value;
    }).join(',')
  );
  
  return csvHeaders + '\n' + csvRows.join('\n');
}

export default router;

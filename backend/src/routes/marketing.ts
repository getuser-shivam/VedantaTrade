import { Router, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { authenticate, authorize } from '../middleware/auth';

const router = Router();
const prisma = new PrismaClient();

// GET /api/marketing/campaigns
router.get('/campaigns', authenticate, async (req: any, res: Response) => {
  try {
    const { page = 1, limit = 20, status = '', search = '' } = req.query;
    
    let whereClause = 'WHERE 1=1';
    if (status) {
      whereClause += ` AND status = '${status}'`;
    }
    if (search) {
      whereClause += ` AND (name ILIKE '%${search}%' OR description ILIKE '%${search}%')`;
    }

    const [campaigns, total] = await Promise.all([
      prisma.$queryRaw(`
        SELECT 
          mc.*,
          u.name as created_by_name,
          COUNT(DISTINCT cp.product_id) as product_count
        FROM marketing_campaigns mc
        LEFT JOIN users u ON mc.created_by = u.user_id
        LEFT JOIN campaign_products cp ON mc.id = cp.campaign_id
        ${whereClause}
        GROUP BY mc.id, u.name
        ORDER BY mc.created_at DESC
        LIMIT ${limit} OFFSET ${(Number(page) - 1) * Number(limit)}
      `),
      prisma.$queryRaw(`
        SELECT COUNT(*) as count 
        FROM marketing_campaigns mc
        ${whereClause}
      `)
    ]);

    res.json({
      success: true,
      data: campaigns,
      pagination: {
        page: Number(page),
        limit: Number(limit),
        total: Number(total[0]?.count || 0),
        pages: Math.ceil(Number(total[0]?.count || 0) / Number(limit))
      }
    });
  } catch (error) {
    console.error('Error fetching marketing campaigns:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// POST /api/marketing/campaigns
router.post('/campaigns', authenticate, authorize('ADMIN'), async (req: any, res: Response) => {
  try {
    const {
      name,
      description,
      campaign_type = 'PROMOTION',
      start_date,
      end_date,
      budget = 0,
      target_audience = []
    } = req.body;

    const campaign = await prisma.$queryRaw`
      INSERT INTO marketing_campaigns 
      (name, description, campaign_type, status, start_date, end_date, budget, actual_cost, target_audience, created_by, created_at, updated_at)
      VALUES 
      ('${name}', '${description}', '${campaign_type}', 'DRAFT', '${start_date}', '${end_date}', ${budget}, 0, '${JSON.stringify(target_audience)}', ${req.user.id}, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
      RETURNING *
    `;

    res.status(201).json({
      success: true,
      data: campaign[0],
      message: 'Marketing campaign created successfully'
    });
  } catch (error) {
    console.error('Error creating marketing campaign:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// PUT /api/marketing/campaigns/:id
router.put('/campaigns/:id', authenticate, authorize('ADMIN'), async (req: any, res: Response) => {
  try {
    const { id } = req.params;
    const updateData = req.body;

    const campaign = await prisma.$queryRaw`
      UPDATE marketing_campaigns 
      SET ${Object.keys(updateData).map(key => `${key} = '${updateData[key]}'`).join(', ')}, updated_at = CURRENT_TIMESTAMP
      WHERE id = ${id}
      RETURNING *
    `;

    res.json({
      success: true,
      data: campaign[0],
      message: 'Marketing campaign updated successfully'
    });
  } catch (error) {
    console.error('Error updating marketing campaign:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// GET /api/marketing/campaigns/:id/products
router.get('/campaigns/:id/products', authenticate, async (req: any, res: Response) => {
  try {
    const { id } = req.params;
    const { page = 1, limit = 20 } = req.query;

    const [products, total] = await Promise.all([
      prisma.$queryRaw(`
        SELECT 
          cp.*,
          p.item_name as product_name,
          p.mrp,
          p.stock_quantity,
          p.image_urls
        FROM campaign_products cp
        LEFT JOIN inventory_items p ON cp.product_id = p.item_id
        WHERE cp.campaign_id = ${id}
        ORDER BY cp.created_at DESC
        LIMIT ${limit} OFFSET ${(Number(page) - 1) * Number(limit)}
      `),
      prisma.$queryRaw(`
        SELECT COUNT(*) as count
        FROM campaign_products cp
        WHERE cp.campaign_id = ${id}
      `)
    ]);

    res.json({
      success: true,
      data: products,
      pagination: {
        page: Number(page),
        limit: Number(limit),
        total: Number(total[0]?.count || 0),
        pages: Math.ceil(Number(total[0]?.count || 0) / Number(limit))
      }
    });
  } catch (error) {
    console.error('Error fetching campaign products:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// POST /api/marketing/campaigns/:id/products
router.post('/campaigns/:id/products', authenticate, authorize('ADMIN'), async (req: any, res: Response) => {
  try {
    const { id } = req.params;
    const { product_id, discount_percentage = 0, special_pricing, is_featured = false } = req.body;

    // Check if product already in campaign
    const existing = await prisma.$queryRaw`
      SELECT id FROM campaign_products 
      WHERE campaign_id = ${id} AND product_id = ${product_id}
    `;

    if (existing.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Product already added to this campaign'
      });
    }

    const campaignProduct = await prisma.$queryRaw`
      INSERT INTO campaign_products 
      (campaign_id, product_id, discount_percentage, special_pricing, is_featured, created_at)
      VALUES (${id}, ${product_id}, ${discount_percentage}, ${special_pricing || 'NULL'}, ${is_featured}, CURRENT_TIMESTAMP)
      RETURNING *
    `;

    res.status(201).json({
      success: true,
      data: campaignProduct[0],
      message: 'Product added to campaign successfully'
    });
  } catch (error) {
    console.error('Error adding product to campaign:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// GET /api/marketing/analytics/:campaignId
router.get('/analytics/:campaignId', authenticate, async (req: any, res: Response) => {
  try {
    const { campaignId } = req.params;
    const { start_date, end_date } = req.query;

    let dateClause = 'WHERE sa.campaign_id = ' + campaignId;
    if (start_date) {
      dateClause += ` AND sa.date >= '${start_date}'`;
    }
    if (end_date) {
      dateClause += ` AND sa.date <= '${end_date}'`;
    }

    const [analytics, summary] = await Promise.all([
      prisma.$queryRaw(`
        SELECT 
          sa.*,
          p.item_name as product_name,
          dc.name as center_name
        FROM sales_analytics sa
        LEFT JOIN inventory_items p ON sa.product_id = p.item_id
        LEFT JOIN distribution_centers dc ON sa.center_id = dc.id
        ${dateClause}
        ORDER BY sa.date DESC
        LIMIT 100
      `),
      prisma.$queryRaw(`
        SELECT 
          COUNT(*) as total_sales,
          SUM(units_sold) as total_units,
          SUM(revenue) as total_revenue,
          SUM(profit) as total_profit,
          AVG(profit) as avg_profit_per_sale
        FROM sales_analytics sa
        ${dateClause}
      `)
    ]);

    res.json({
      success: true,
      data: {
        analytics,
        summary: summary[0]
      }
    });
  } catch (error) {
    console.error('Error fetching marketing analytics:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// POST /api/marketing/metrics
router.post('/metrics', authenticate, authorize('ADMIN'), async (req: any, res: Response) => {
  try {
    const { campaign_id, metric_type, metric_value, recorded_date } = req.body;

    const metric = await prisma.$queryRaw`
      INSERT INTO marketing_metrics 
      (campaign_id, metric_type, metric_value, recorded_date, created_at)
      VALUES (${campaign_id}, '${metric_type}', ${metric_value}, '${recorded_date}', CURRENT_TIMESTAMP)
      RETURNING *
    `;

    res.status(201).json({
      success: true,
      data: metric[0],
      message: 'Marketing metric recorded successfully'
    });
  } catch (error) {
    console.error('Error recording marketing metric:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// GET /api/marketing/metrics/:campaignId
router.get('/metrics/:campaignId', authenticate, async (req: any, res: Response) => {
  try {
    const { campaignId } = req.params;
    const { metric_type, start_date, end_date } = req.query;

    let whereClause = `WHERE campaign_id = ${campaignId}`;
    if (metric_type) {
      whereClause += ` AND metric_type = '${metric_type}'`;
    }
    if (start_date) {
      whereClause += ` AND recorded_date >= '${start_date}'`;
    }
    if (end_date) {
      whereClause += ` AND recorded_date <= '${end_date}'`;
    }

    const metrics = await prisma.$queryRaw(`
      SELECT *
      FROM marketing_metrics
      ${whereClause}
      ORDER BY recorded_date DESC
      LIMIT 100
    `);

    res.json({
      success: true,
      data: metrics
    });
  } catch (error) {
    console.error('Error fetching marketing metrics:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// GET /api/marketing/roi/:campaignId
router.get('/roi/:campaignId', authenticate, async (req: any, res: Response) => {
  try {
    const { campaignId } = req.params;

    const [campaign, metrics, sales] = await Promise.all([
      prisma.$queryRaw(`
        SELECT * FROM marketing_campaigns WHERE id = ${campaignId}
      `),
      prisma.$queryRaw(`
        SELECT 
          metric_type,
          SUM(metric_value) as total_value
        FROM marketing_metrics
        WHERE campaign_id = ${campaignId}
        GROUP BY metric_type
      `),
      prisma.$queryRaw(`
        SELECT 
          SUM(units_sold) as total_units,
          SUM(revenue) as total_revenue,
          SUM(cost) as total_cost,
          SUM(profit) as total_profit
        FROM sales_analytics
        WHERE campaign_id = ${campaignId}
      `)
    ]);

    const budget = campaign[0]?.budget || 0;
    const actualCost = campaign[0]?.actual_cost || 0;
    const totalRevenue = Number(sales[0]?.total_revenue || 0);
    const totalCost = Number(sales[0]?.total_cost || 0);
    const totalProfit = Number(sales[0]?.total_profit || 0);

    const roi = totalCost > 0 ? ((totalProfit - actualCost) / actualCost) * 100 : 0;
    const roiWithMarketing = totalCost > 0 ? ((totalProfit - actualCost - budget) / (actualCost + budget)) * 100 : 0;

    res.json({
      success: true,
      data: {
        campaign: campaign[0],
        metrics: metrics,
        sales: sales[0],
        roi: {
          percentage: roi,
          roi_with_marketing: roiWithMarketing,
          total_revenue: totalRevenue,
          total_cost: totalCost,
          total_profit: totalProfit,
          marketing_cost: actualCost,
          budget: budget
        }
      }
    });
  } catch (error) {
    console.error('Error calculating ROI:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

export default router;

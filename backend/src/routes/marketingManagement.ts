import { Router, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { authenticate, authorize } from '../middleware/rbac';

const router = Router();
const prisma = new PrismaClient();

// GET /api/marketing/campaigns - Get all marketing campaigns
router.get('/campaigns', authenticate, authorize('marketing:read'), async (req: any, res: Response) => {
  try {
    const { 
      page = 1, 
      limit = 20, 
      status, 
      type, 
      start_date, 
      end_date,
      search = '' 
    } = req.query;

    let whereClause = 'WHERE 1=1';
    const params: any[] = [];

    if (status) {
      whereClause += ' AND mc.status = ?';
      params.push(status);
    }

    if (type) {
      whereClause += ' AND mc.campaign_type = ?';
      params.push(type);
    }

    if (start_date) {
      whereClause += ' AND mc.start_date >= ?';
      params.push(start_date);
    }

    if (end_date) {
      whereClause += ' AND mc.end_date <= ?';
      params.push(end_date);
    }

    if (search) {
      whereClause += ' AND (mc.name LIKE ? OR mc.description LIKE ?)';
      params.push(`%${search}%`, `%${search}%`);
    }

    const offset = (Number(page) - 1) * Number(limit);

    const [campaigns, total] = await Promise.all([
      prisma.$queryRaw(`
        SELECT 
          mc.*,
          u.name as created_by_name,
          COUNT(DISTINCT cp.product_id) as product_count,
          COUNT(DISTINCT ce.event_id) as event_count,
          SUM(cc.budget) as total_budget,
          SUM(cc.spent_amount) as total_spent
        FROM marketing_campaigns mc
        LEFT JOIN users u ON mc.created_by = u.user_id
        LEFT JOIN campaign_products cp ON mc.id = cp.campaign_id
        LEFT JOIN campaign_events ce ON mc.id = ce.campaign_id
        LEFT JOIN campaign_costs cc ON mc.id = cc.campaign_id
        ${whereClause}
        GROUP BY mc.id, mc.name, mc.description, mc.status, mc.campaign_type, 
                 mc.start_date, mc.end_date, mc.budget, mc.created_by, mc.created_at,
                 u.name
        ORDER BY mc.created_at DESC
        LIMIT ? OFFSET ?
      `) as any[],
      
      prisma.$queryRaw(`
        SELECT COUNT(*) as count
        FROM marketing_campaigns mc
        ${whereClause}
      `) as any[]
    ]);

    res.json({
      success: true,
      data: campaigns,
      pagination: {
        page: Number(page),
        limit: Number(limit),
        total: Number((total as any)[0]?.count || 0),
        pages: Math.ceil(Number((total as any)[0]?.count || 0) / Number(limit))
      }
    });
  } catch (error) {
    console.error('Error fetching campaigns:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// POST /api/marketing/campaigns - Create new marketing campaign
router.post('/campaigns', authenticate, authorize('marketing:create'), async (req: any, res: Response) => {
  try {
    const {
      name,
      description,
      campaign_type,
      start_date,
      end_date,
      budget,
      target_audience,
      product_ids,
      notes
    } = req.body;

    // Validate required fields
    if (!name || !campaign_type || !start_date || !end_date) {
      return res.status(400).json({
        success: false,
        message: 'Name, campaign type, start date, and end date are required'
      });
    }

    // Create campaign
    const campaign = await prisma.marketing_campaigns.create({
      data: {
        name,
        description,
        campaign_type,
        start_date: new Date(start_date),
        end_date: new Date(end_date),
        budget: budget || 0,
        target_audience,
        status: 'planned',
        created_by: req.user.id,
        created_at: new Date()
      }
    });

    // Add products to campaign if provided
    if (product_ids && product_ids.length > 0) {
      await Promise.all(
        product_ids.map((product_id: number) =>
          prisma.campaign_products.create({
            data: {
              campaign_id: campaign.id,
              product_id
            }
          })
        )
      );
    }

    res.status(201).json({
      success: true,
      data: campaign,
      message: 'Marketing campaign created successfully'
    });
  } catch (error) {
    console.error('Error creating campaign:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// GET /api/marketing/campaigns/:id/performance - Get campaign performance metrics
router.get('/campaigns/:id/performance', authenticate, authorize('analytics:read'), async (req: any, res: Response) => {
  try {
    const { id } = req.params;

    // Get campaign details
    const campaign = await prisma.marketing_campaigns.findUnique({
      where: { id: parseInt(id) },
      include: {
        products: {
          include: {
            product: true
          }
        }
      }
    });

    if (!campaign) {
      return res.status(404).json({
        success: false,
        message: 'Campaign not found'
      });
    }

    // Get performance metrics
    const [salesData, leadData, costData, roiData] = await Promise.all([
      // Sales performance
      prisma.$queryRaw`
        SELECT 
          COUNT(DISTINCT o.order_id) as total_orders,
          SUM(o.total_amount) as total_revenue,
          COUNT(DISTINCT o.customer_id) as unique_customers,
          AVG(o.total_amount) as avg_order_value
        FROM orders o
        JOIN campaign_products cp ON o.product_id = cp.product_id
        WHERE cp.campaign_id = ${id} 
          AND o.status = 'completed'
          AND o.created_at >= '${campaign.start_date}'
          AND o.created_at <= '${campaign.end_date}'
      ` as any[],

      // Lead generation
      prisma.$queryRaw`
        SELECT 
          COUNT(*) as total_leads,
          COUNT(CASE WHEN status = 'converted' THEN 1 END) as converted_leads,
          COUNT(CASE WHEN status = 'qualified' THEN 1 END) as qualified_leads,
          AVG(CASE WHEN status = 'converted' THEN 1 ELSE 0 END) as conversion_rate
        FROM campaign_leads
        WHERE campaign_id = ${id}
      ` as any[],

      // Cost analysis
      prisma.$queryRaw`
        SELECT 
          SUM(budget) as total_budget,
          SUM(spent_amount) as total_spent,
          SUM(CASE WHEN cost_type = 'advertising' THEN spent_amount ELSE 0 END) as ad_spend,
          SUM(CASE WHEN cost_type = 'events' THEN spent_amount ELSE 0 END) as event_spend,
          SUM(CASE WHEN cost_type = 'materials' THEN spent_amount ELSE 0 END) as material_spend
        FROM campaign_costs
        WHERE campaign_id = ${id}
      ` as any[],

      // ROI by product
      prisma.$queryRaw`
        SELECT 
          p.item_name as product_name,
          COUNT(DISTINCT o.order_id) as orders,
          SUM(o.total_amount) as revenue,
          SUM(oi.quantity) as quantity_sold,
          (SUM(o.total_amount) - COALESCE(cc.spent_amount, 0)) as profit
        FROM campaign_products cp
        JOIN inventory_items p ON cp.product_id = p.item_id
        LEFT JOIN orders o ON p.item_id = o.product_id 
          AND o.status = 'completed'
          AND o.created_at >= '${campaign.start_date}'
          AND o.created_at <= '${campaign.end_date}'
        LEFT JOIN order_items oi ON o.order_id = oi.order_id AND oi.product_id = p.item_id
        LEFT JOIN campaign_costs cc ON cp.campaign_id = cc.campaign_id 
          AND cc.product_id = p.item_id
        WHERE cp.campaign_id = ${id}
        GROUP BY p.item_name, p.item_id
        ORDER BY revenue DESC
      ` as any[]
    ]);

    // Get daily performance trend
    const performanceTrend = await prisma.$queryRaw`
      SELECT 
        CAST(created_at AS DATE) as date,
        COUNT(*) as orders,
        SUM(total_amount) as revenue,
        COUNT(DISTINCT customer_id) as customers
      FROM orders o
      JOIN campaign_products cp ON o.product_id = cp.product_id
      WHERE cp.campaign_id = ${id} 
        AND o.status = 'completed'
        AND o.created_at >= '${campaign.start_date}'
        AND o.created_at <= '${campaign.end_date}'
      GROUP BY CAST(created_at AS DATE)
      ORDER BY date ASC
    ` as any[];

    res.json({
      success: true,
      data: {
        campaign,
        salesMetrics: salesData[0] || {},
        leadMetrics: leadData[0] || {},
        costMetrics: costData[0] || {},
        productRoi: roiData,
        performanceTrend
      }
    });
  } catch (error) {
    console.error('Error fetching campaign performance:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// POST /api/marketing/campaigns/:id/leads - Add leads to campaign
router.post('/campaigns/:id/leads', authenticate, authorize('marketing:create'), async (req: any, res: Response) => {
  try {
    const { id } = req.params;
    const { leads } = req.body;

    if (!leads || leads.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Leads data is required'
      });
    }

    // Validate campaign exists
    const campaign = await prisma.marketing_campaigns.findUnique({
      where: { id: parseInt(id) }
    });

    if (!campaign) {
      return res.status(404).json({
        success: false,
        message: 'Campaign not found'
      });
    }

    // Create leads
    const createdLeads = await Promise.all(
      leads.map(async (lead: any) => {
        return await prisma.campaign_leads.create({
          data: {
            campaign_id: parseInt(id),
            name: lead.name,
            email: lead.email,
            phone: lead.phone,
            company: lead.company,
            position: lead.position,
            source: lead.source || 'manual',
            status: 'new',
            notes: lead.notes,
            created_at: new Date()
          }
        });
      })
    );

    res.status(201).json({
      success: true,
      data: createdLeads,
      message: 'Leads added to campaign successfully'
    });
  } catch (error) {
    console.error('Error adding leads:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// GET /api/marketing/analytics/overview - Get marketing analytics overview
router.get('/analytics/overview', authenticate, authorize('analytics:read'), async (req: any, res: Response) => {
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

    const [overview, campaignTypes, topCampaigns, leadSources] = await Promise.all([
      // Overall metrics
      prisma.$queryRaw`
        SELECT 
          COUNT(*) as total_campaigns,
          COUNT(CASE WHEN status = 'active' THEN 1 END) as active_campaigns,
          SUM(budget) as total_budget,
          SUM(spent_amount) as total_spent,
          COUNT(CASE WHEN end_date >= GETDATE() THEN 1 END) as upcoming_campaigns
        FROM marketing_campaigns mc
        LEFT JOIN campaign_costs cc ON mc.id = cc.campaign_id
        WHERE 1=1 ${dateFilter}
      ` as any[],

      // Campaign performance by type
      prisma.$queryRaw`
        SELECT 
          campaign_type,
          COUNT(*) as campaign_count,
          AVG(budget) as avg_budget,
          SUM(spent_amount) as total_spent,
          AVG(CASE WHEN cc.spent_amount > 0 THEN (cc.spent_amount * 100.0 / cc.budget) ELSE 0 END) as budget_utilization
        FROM marketing_campaigns mc
        LEFT JOIN campaign_costs cc ON mc.id = cc.campaign_id
        WHERE 1=1 ${dateFilter}
        GROUP BY campaign_type
        ORDER BY total_spent DESC
      ` as any[],

      // Top performing campaigns
      prisma.$queryRaw`
        SELECT TOP 10
          mc.name,
          mc.campaign_type,
          COUNT(DISTINCT o.order_id) as orders_generated,
          SUM(o.total_amount) as revenue_generated,
          SUM(cc.spent_amount) as cost,
          (SUM(o.total_amount) - SUM(cc.spent_amount)) as roi
        FROM marketing_campaigns mc
        LEFT JOIN campaign_products cp ON mc.id = cp.campaign_id
        LEFT JOIN orders o ON cp.product_id = o.product_id AND o.status = 'completed'
        LEFT JOIN campaign_costs cc ON mc.id = cc.campaign_id
        WHERE 1=1 ${dateFilter}
        GROUP BY mc.id, mc.name, mc.campaign_type
        HAVING revenue_generated > 0
        ORDER BY roi DESC
      ` as any[],

      // Lead sources
      prisma.$queryRaw`
        SELECT 
          source,
          COUNT(*) as lead_count,
          COUNT(CASE WHEN status = 'converted' THEN 1 END) as converted_count,
          AVG(CASE WHEN status = 'converted' THEN 1 ELSE 0 END) as conversion_rate
        FROM campaign_leads
        WHERE 1=1 ${dateFilter}
        GROUP BY source
        ORDER BY lead_count DESC
      ` as any[]
    ]);

    // Get marketing funnel data
    const funnelData = await prisma.$queryRaw`
      SELECT 
        'Leads' as stage,
        COUNT(*) as count
      FROM campaign_leads
      WHERE 1=1 ${dateFilter}
      
      UNION ALL
      
      SELECT 
        'Qualified' as stage,
        COUNT(*) as count
      FROM campaign_leads
      WHERE status = 'qualified' ${dateFilter}
      
      UNION ALL
      
      SELECT 
        'Converted' as stage,
        COUNT(*) as count
      FROM campaign_leads
      WHERE status = 'converted' ${dateFilter}
    ` as any[];

    res.json({
      success: true,
      data: {
        overview: overview[0] || {},
        campaignTypes,
        topCampaigns,
        leadSources,
        funnelData
      }
    });
  } catch (error) {
    console.error('Error fetching marketing analytics:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// GET /api/marketing/commissions - Get commission tracking for medical reps
router.get('/commissions', authenticate, authorize('financial:read'), async (req: any, res: Response) => {
  try {
    const { 
      period = '30d', 
      medical_rep_id,
      status 
    } = req.query;

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
    const statusFilter = status ? `AND c.status = '${status}'` : '';

    // Get commission data
    const commissionData = await prisma.$queryRaw`
      SELECT 
        u.user_id as rep_id,
        u.name as rep_name,
        COUNT(DISTINCT o.order_id) as total_orders,
        SUM(o.total_amount) as total_sales,
        SUM(c.commission_amount) as total_commission,
        AVG(c.commission_rate) as avg_commission_rate,
        COUNT(CASE WHEN c.status = 'paid' THEN 1 END) as paid_commissions,
        COUNT(CASE WHEN c.status = 'pending' THEN 1 END) as pending_commissions,
        SUM(CASE WHEN c.status = 'paid' THEN c.commission_amount ELSE 0 END) as paid_amount,
        SUM(CASE WHEN c.status = 'pending' THEN c.commission_amount ELSE 0 END) as pending_amount
      FROM users u
      LEFT JOIN orders o ON u.user_id = o.medical_rep_id AND o.status = 'completed'
      LEFT JOIN commissions c ON o.order_id = c.order_id
      WHERE u.role = 'MEDICAL_REP' ${repFilter} ${dateFilter} ${statusFilter}
      GROUP BY u.user_id, u.name
      ORDER BY total_commission DESC
    ` as any[];

    // Get commission details
    const commissionDetails = await prisma.$queryRaw`
      SELECT 
        c.*,
        o.order_id,
        o.total_amount as order_amount,
        u.name as rep_name,
        p.item_name as product_name,
        mc.name as campaign_name
      FROM commissions c
      JOIN orders o ON c.order_id = o.order_id
      JOIN users u ON o.medical_rep_id = u.user_id
      JOIN order_items oi ON o.order_id = oi.order_id
      JOIN inventory_items p ON oi.product_id = p.item_id
      LEFT JOIN campaign_products cp ON p.item_id = cp.product_id
      LEFT JOIN marketing_campaigns mc ON cp.campaign_id = mc.id
      WHERE 1=1 ${repFilter} ${dateFilter} ${statusFilter}
      ORDER BY c.created_at DESC
    ` as any[];

    // Get commission tiers
    const commissionTiers = await prisma.$queryRaw`
      SELECT 
        tier_name,
        min_sales_amount,
        max_sales_amount,
        commission_rate,
        bonus_amount
      FROM commission_tiers
      ORDER BY min_sales_amount ASC
    ` as any[];

    res.json({
      success: true,
      data: {
        commissionData,
        commissionDetails,
        commissionTiers
      }
    });
  } catch (error) {
    console.error('Error fetching commission data:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// POST /api/marketing/commissions/calculate - Calculate commissions for orders
router.post('/commissions/calculate', authenticate, authorize('financial:create'), async (req: any, res: Response) => {
  try {
    const { order_ids } = req.body;

    if (!order_ids || order_ids.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Order IDs are required'
      });
    }

    // Get commission tiers
    const tiers = await prisma.commission_tiers.findMany({
      orderBy: { min_sales_amount: 'asc' }
    });

    // Calculate commissions for each order
    const calculatedCommissions = await Promise.all(
      order_ids.map(async (order_id: number) => {
        const order = await prisma.orders.findUnique({
          where: { order_id },
          include: {
            medical_rep: true
          }
        });

        if (!order || order.status !== 'completed') {
          return null;
        }

        // Get rep's total sales for the period
        const repSales = await prisma.$queryRaw`
          SELECT SUM(total_amount) as total_sales
          FROM orders
          WHERE medical_rep_id = ${order.medical_rep_id}
            AND status = 'completed'
            AND created_at >= DATEADD(month, -1, GETDATE())
        ` as any[];

        const totalSales = Number((repSales as any)[0]?.total_sales || 0);

        // Find applicable commission tier
        const applicableTier = tiers.find(tier => 
          totalSales >= tier.min_sales_amount && 
          (!tier.max_sales_amount || totalSales <= tier.max_sales_amount)
        ) || tiers[0];

        const commissionRate = applicableTier?.commission_rate || 0.05; // Default 5%
        const commissionAmount = order.total_amount * commissionRate;
        const bonusAmount = applicableTier?.bonus_amount || 0;

        // Create or update commission record
        const commission = await prisma.commissions.upsert({
          where: { order_id },
          update: {
            commission_amount: commissionAmount + bonusAmount,
            commission_rate: commissionRate,
            bonus_amount: bonusAmount,
            tier_id: applicableTier?.id,
            updated_at: new Date()
          },
          create: {
            order_id,
            medical_rep_id: order.medical_rep_id,
            commission_amount: commissionAmount + bonusAmount,
            commission_rate: commissionRate,
            bonus_amount: bonusAmount,
            tier_id: applicableTier?.id,
            status: 'pending',
            created_at: new Date()
          }
        });

        return commission;
      })
    );

    const validCommissions = calculatedCommissions.filter(c => c !== null);

    res.json({
      success: true,
      data: validCommissions,
      message: 'Commissions calculated successfully'
    });
  } catch (error) {
    console.error('Error calculating commissions:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

export default router;

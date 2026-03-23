import { Router } from 'express';
import { PrismaClient } from '@prisma/client';
import { authenticate, authorize } from '../middleware/auth';

const router = Router();
const prisma = new PrismaClient();

// POST /api/scraper/run - Trigger a scrape job
router.post('/run', authenticate, authorize('ADMIN'), async (req, res) => {
  try {
    const { source, targetType, city, query } = req.body;
    const job = await prisma.scraperJob.create({
      data: { source, targetType, city, query, status: 'PENDING' },
    });
    // In production, this would dispatch to a job queue. For now, return job ID.
    return res.status(201).json({ success: true, data: job, message: 'Scraper job queued. Run Python scraper with this job ID.' });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// GET /api/scraper/jobs - List all scraper jobs
router.get('/jobs', authenticate, authorize('ADMIN'), async (req, res) => {
  try {
    const jobs = await prisma.scraperJob.findMany({
      orderBy: { createdAt: 'desc' },
      include: { _count: { select: { leads: true } } },
    });
    return res.json({ success: true, data: jobs });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// GET /api/scraper/leads - View scraped leads pending review
router.get('/leads', authenticate, authorize('ADMIN'), async (req, res) => {
  try {
    const { status = 'RAW', leadType, page = 1, limit = 50 } = req.query;
    const where: any = {};
    if (status) where.status = status;
    if (leadType) where.leadType = leadType;
    const [leads, total] = await Promise.all([
      prisma.scrapedLead.findMany({ where, skip: (Number(page)-1)*Number(limit), take: Number(limit), orderBy: { createdAt: 'desc' } }),
      prisma.scrapedLead.count({ where }),
    ]);
    return res.json({ success: true, data: leads, pagination: { page: Number(page), limit: Number(limit), total } });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// POST /api/scraper/leads/:id/approve - Approve and convert a lead
router.post('/leads/:id/approve', authenticate, authorize('ADMIN'), async (req: any, res) => {
  try {
    const lead = await prisma.scrapedLead.findUnique({ where: { id: Number(req.params.id) } });
    if (!lead) return res.status(404).json({ success: false, message: 'Lead not found' });

    let convertedId: number | null = null;
    if (lead.leadType === 'DOCTOR') {
      const doctor = await prisma.doctor.create({
        data: { name: lead.name, phone: lead.phone, email: lead.email, clinicName: lead.clinicName, address: lead.address, city: lead.city, state: lead.state, specialization: lead.specialization, sourceType: lead.job ? 'PRACTO' : 'MANUAL' },
      });
      convertedId = doctor.id;
    } else if (lead.leadType === 'STOCKIST') {
      const stockist = await prisma.stockist.create({
        data: { firmName: lead.firmName || lead.name, phone: lead.phone, email: lead.email, address: lead.address, city: lead.city, state: lead.state },
      });
      convertedId = stockist.id;
    } else if (lead.leadType === 'RETAILER') {
      const retailer = await prisma.retailer.create({
        data: { firmName: lead.firmName || lead.name, phone: lead.phone, email: lead.email, address: lead.address, city: lead.city, state: lead.state },
      });
      convertedId = retailer.id;
    } else if (lead.leadType === 'HOSPITAL') {
      const hospital = await prisma.hospital.create({
        data: { name: lead.name, phone: lead.phone, email: lead.email, address: lead.address, city: lead.city, state: lead.state },
      });
      convertedId = hospital.id;
    }

    await prisma.scrapedLead.update({
      where: { id: Number(req.params.id) },
      data: { status: 'CONVERTED', convertedId, reviewedBy: req.user.id, reviewedAt: new Date() },
    });

    return res.json({ success: true, message: `Lead converted to ${lead.leadType}`, convertedId });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// POST /api/scraper/leads/:id/reject
router.post('/leads/:id/reject', authenticate, authorize('ADMIN'), async (req: any, res) => {
  try {
    await prisma.scrapedLead.update({
      where: { id: Number(req.params.id) },
      data: { status: 'REJECTED', reviewedBy: req.user.id, reviewedAt: new Date() },
    });
    return res.json({ success: true, message: 'Lead rejected' });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// POST /api/scraper/leads/bulk-ingest - Used by Python scraper to upload results
router.post('/bulk-ingest', async (req, res) => {
  try {
    const { jobId, leads, apiKey } = req.body;
    if (apiKey !== (process.env.SCRAPER_API_KEY || 'vedanta_scraper_key')) {
      return res.status(401).json({ success: false, message: 'Invalid API key' });
    }
    const created = await prisma.scrapedLead.createMany({
      data: leads.map((lead: any) => ({ ...lead, jobId: Number(jobId) })),
      skipDuplicates: true,
    });
    await prisma.scraperJob.update({
      where: { id: Number(jobId) }, data: { status: 'COMPLETED', totalFound: created.count, completedAt: new Date() },
    });
    return res.json({ success: true, inserted: created.count });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

export default router;

import { Router } from 'express';
import { PrismaClient } from '@prisma/client';
import { authenticate, authorize } from '../middleware/auth';

const router = Router();
const prisma = new PrismaClient();

// GET all retailers
router.get('/', authenticate, async (req, res) => {
  try {
    const { city, search } = req.query;
    const where: any = {};
    if (city) where.city = { contains: city as string, mode: 'insensitive' };
    if (search) where.OR = [{ firmName: { contains: search as string, mode: 'insensitive' } }, { ownerName: { contains: search as string, mode: 'insensitive' } }];
    const retailers = await prisma.retailer.findMany({ where, include: { inventory: { include: { product: true }, take: 5 } }, orderBy: { firmName: 'asc' } });
    return res.json({ success: true, data: retailers });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// POST create retailer
router.post('/', authenticate, authorize('ADMIN', 'STOCKIST'), async (req, res) => {
  try {
    const retailer = await prisma.retailer.create({ data: req.body });
    return res.status(201).json({ success: true, data: retailer });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// GET retailer dashboard
router.get('/dashboard', authenticate, authorize('RETAILER', 'ADMIN'), async (req: any, res) => {
  try {
    const retailerProfile = await prisma.retailer.findUnique({ where: { userId: req.user.id } });
    if (!retailerProfile) return res.status(404).json({ success: false, message: 'Retailer profile not found' });
    const [pendingOrders, inventoryCount, pendingInvoices] = await Promise.all([
      prisma.order.count({ where: { retailerId: retailerProfile.id, status: 'PENDING' } }),
      prisma.inventory.count({ where: { retailerId: retailerProfile.id } }),
      prisma.invoice.count({ where: { retailerId: retailerProfile.id, status: { in: ['PENDING', 'OVERDUE'] } } }),
    ]);
    return res.json({ success: true, data: { pendingOrders, inventoryCount, pendingInvoices, profile: retailerProfile } });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

export default router;

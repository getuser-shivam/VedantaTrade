import { Router } from 'express';
import { PrismaClient } from '@prisma/client';
import { authenticate, authorize } from '../middleware/auth';

const router = Router();
const prisma = new PrismaClient();

// GET all stockists
router.get('/', authenticate, async (req, res) => {
  try {
    const { city, search } = req.query;
    const where: any = {};
    if (city) where.city = { contains: city as string, mode: 'insensitive' };
    if (search) where.OR = [{ firmName: { contains: search as string, mode: 'insensitive' } }, { ownerName: { contains: search as string, mode: 'insensitive' } }];

    const stockists = await prisma.stockist.findMany({ where, include: { retailers: { include: { retailer: true } }, inventory: { include: { product: true }, take: 5 } }, orderBy: { firmName: 'asc' } });
    return res.json({ success: true, data: stockists });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// POST create stockist
router.post('/', authenticate, authorize('ADMIN'), async (req, res) => {
  try {
    const stockist = await prisma.stockist.create({ data: req.body });
    return res.status(201).json({ success: true, data: stockist });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// PUT update stockist inventory
router.put('/:id/inventory', authenticate, authorize('ADMIN', 'STOCKIST'), async (req: any, res) => {
  try {
    const { productId, quantity, batchNo, expiryDate } = req.body;
    const existing = await prisma.inventory.findFirst({ where: { stockistId: Number(req.params.id), productId: Number(productId) } });
    let inventoryItem;
    if (existing) {
      inventoryItem = await prisma.inventory.update({ where: { id: existing.id }, data: { quantity: Number(quantity), batchNo, expiryDate: expiryDate ? new Date(expiryDate) : null } });
    } else {
      inventoryItem = await prisma.inventory.create({ data: { stockistId: Number(req.params.id), productId: Number(productId), quantity: Number(quantity), batchNo, expiryDate: expiryDate ? new Date(expiryDate) : null } });
    }
    return res.json({ success: true, data: inventoryItem });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// GET stockist dashboard
router.get('/dashboard', authenticate, authorize('STOCKIST', 'ADMIN'), async (req: any, res) => {
  try {
    const stockistProfile = await prisma.stockist.findUnique({ where: { userId: req.user.id } });
    if (!stockistProfile) return res.status(404).json({ success: false, message: 'Stockist profile not found' });

    const [pendingOrders, totalInventoryItems, overduePayments, outstandingAmount] = await Promise.all([
      prisma.order.count({ where: { stockistId: stockistProfile.id, status: 'PENDING' } }),
      prisma.inventory.count({ where: { stockistId: stockistProfile.id } }),
      prisma.invoice.count({ where: { stockistId: stockistProfile.id, status: 'OVERDUE' } }),
      prisma.invoice.aggregate({ where: { stockistId: stockistProfile.id, status: { in: ['PENDING', 'PARTIAL', 'OVERDUE'] } }, _sum: { totalAmount: true } }),
    ]);
    return res.json({ success: true, data: { pendingOrders, totalInventoryItems, overduePayments, outstandingAmount: outstandingAmount._sum.totalAmount || 0, profile: stockistProfile } });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

export default router;

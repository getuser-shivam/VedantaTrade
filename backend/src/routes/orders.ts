import { Router } from 'express';
import { PrismaClient } from '@prisma/client';
import { authenticate, authorize } from '../middleware/auth';

const router = Router();
const prisma = new PrismaClient();

router.get('/', authenticate, async (req: any, res) => {
  try {
    const { status, page = 1, limit = 20 } = req.query;
    const where: any = {};
    if (status) where.status = status;
    const orders = await prisma.order.findMany({
      where, skip: (Number(page)-1)*Number(limit), take: Number(limit),
      include: { items: { include: { product: true } }, stockist: true, retailer: true, doctor: true, invoices: true },
      orderBy: { createdAt: 'desc' },
    });
    const total = await prisma.order.count({ where });
    return res.json({ success: true, data: orders, pagination: { page: Number(page), limit: Number(limit), total } });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

router.post('/', authenticate, async (req, res) => {
  try {
    const { orderType, stockistId, retailerId, doctorId, items, notes } = req.body;
    const count = await prisma.order.count();
    const orderNumber = `VTL-ORD-${Date.now()}-${count + 1}`;
    
    const subtotal = items.reduce((sum: number, item: any) => sum + (item.unitPrice * item.quantity), 0);
    const gstAmount = subtotal * 0.12;
    const totalAmount = subtotal + gstAmount;

    const order = await prisma.order.create({
      data: {
        orderNumber, orderType,
        stockistId: stockistId ? Number(stockistId) : null,
        retailerId: retailerId ? Number(retailerId) : null,
        doctorId: doctorId ? Number(doctorId) : null,
        subtotal, gstAmount, totalAmount, notes,
        items: { create: items.map((item: any) => ({
          productId: Number(item.productId), productName: item.productName,
          quantity: Number(item.quantity), unitPrice: Number(item.unitPrice),
          discount: Number(item.discount || 0), gstPercent: Number(item.gstPercent || 12),
          totalPrice: Number(item.unitPrice) * Number(item.quantity),
        })) },
      },
      include: { items: { include: { product: true } }, stockist: true, retailer: true },
    });
    return res.status(201).json({ success: true, data: order });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

router.put('/:id/status', authenticate, authorize('ADMIN', 'STOCKIST'), async (req, res) => {
  try {
    const order = await prisma.order.update({
      where: { id: Number(req.params.id) },
      data: { status: req.body.status, updatedAt: new Date() },
    });
    return res.json({ success: true, data: order });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

export default router;

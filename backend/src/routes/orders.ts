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
    const orders = await prisma.salesOrder.findMany({
      where, skip: (Number(page) - 1) * Number(limit), take: Number(limit),
      include: { 
        SalesOrderItems: { include: { InventoryItem: true } }, 
        Customer: true, 
        Currency: true 
      },
      orderBy: { order_date: 'desc' },
    });
    const total = await prisma.salesOrder.count({ where });
    return res.json({ success: true, data: orders, pagination: { page: Number(page), limit: Number(limit), total } });
  } catch (error) {
    console.error('Orders fetch error:', error);
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

router.post('/', authenticate, async (req, res) => {
  try {
    const { customerId, items, notes, currencyId = 1 } = req.body;
    const count = await prisma.salesOrder.count();
    const referenceNumber = `VTL-ORD-${Date.now()}-${count + 1}`;
    
    let totalAmount = 0;
    const orderItemsData = [];

    for (const item of items) {
      const product = await prisma.inventoryItem.findFirst({
        where: { item_id: Number(item.productId) }
      });

      if (!product) continue;

      const itemTotal = (product.mrp || 0) * Number(item.quantity);
      totalAmount += itemTotal;

      orderItemsData.push({
        item_id: product.item_id,
        quantity: Number(item.quantity),
        unit_price: product.mrp || 0,
      });
    }

    const order = await prisma.salesOrder.create({
      data: {
        reference_number: referenceNumber,
        customer_id: Number(customerId),
        order_date: new Date().toISOString(),
        total_amount: totalAmount,
        currency_id: Number(currencyId),
        status: 'PENDING',
        SalesOrderItems: {
          create: orderItemsData
        }
      },
      include: { SalesOrderItems: { include: { InventoryItem: true } }, Customer: true },
    });
    return res.status(201).json({ success: true, data: order });
  } catch (error) {
    console.error('Order creation error:', error);
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

router.put('/:id/status', authenticate, authorize('ADMIN', 'ACCOUNTANT'), async (req, res) => {
  try {
    const order = await prisma.salesOrder.update({
      where: { so_id: Number(req.params.id) },
      data: { status: req.body.status },
    });
    return res.json({ success: true, data: order });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

export default router;

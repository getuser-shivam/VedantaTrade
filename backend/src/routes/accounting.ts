import { Router } from 'express';
import { PrismaClient } from '@prisma/client';
import { authenticate, authorize } from '../middleware/auth';

const router = Router();
const prisma = new PrismaClient();

// GET /api/accounting/dashboard
router.get('/dashboard', authenticate, authorize('ACCOUNTANT', 'ADMIN'), async (req, res) => {
  try {
    const today = new Date();
    const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);
    const [totalReceivables, totalPayables, paidThisMonth, overdueInvoices] = await Promise.all([
      prisma.invoice.aggregate({ where: { invoiceType: 'SALE', status: { in: ['PENDING', 'PARTIAL'] } }, _sum: { totalAmount: true } }),
      prisma.invoice.aggregate({ where: { invoiceType: 'PURCHASE', status: { in: ['PENDING', 'PARTIAL'] } }, _sum: { totalAmount: true } }),
      prisma.payment.aggregate({ where: { paidDate: { gte: startOfMonth } }, _sum: { amount: true } }),
      prisma.invoice.count({ where: { status: 'OVERDUE' } }),
    ]);
    return res.json({ success: true, data: {
      totalReceivables: totalReceivables._sum.totalAmount || 0,
      totalPayables: totalPayables._sum.totalAmount || 0,
      paidThisMonth: paidThisMonth._sum.amount || 0,
      overdueInvoices,
    }});
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// GET /api/accounting/invoices
router.get('/invoices', authenticate, authorize('ACCOUNTANT', 'ADMIN', 'STOCKIST', 'RETAILER'), async (req: any, res) => {
  try {
    const { type, status, page = 1, limit = 20 } = req.query;
    const where: any = {};
    if (type) where.invoiceType = type;
    if (status) where.status = status;

    const invoices = await prisma.invoice.findMany({
      where, skip: (Number(page) - 1) * Number(limit), take: Number(limit),
      include: { order: true, stockist: true, retailer: true },
      orderBy: { createdAt: 'desc' },
    });
    const total = await prisma.invoice.count({ where });
    return res.json({ success: true, data: invoices, pagination: { page: Number(page), limit: Number(limit), total } });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// POST /api/accounting/invoices
router.post('/invoices', authenticate, authorize('ACCOUNTANT', 'ADMIN'), async (req, res) => {
  try {
    const { invoiceType, orderId, stockistId, retailerId, subtotal, discountAmount, gstAmount, totalAmount, dueDate, notes } = req.body;
    const count = await prisma.invoice.count();
    const invoiceNumber = `VTL-${new Date().getFullYear()}-${String(count + 1).padStart(5, '0')}`;
    
    const invoice = await prisma.invoice.create({
      data: {
        invoiceNumber, invoiceType, orderId: orderId ? Number(orderId) : null,
        stockistId: stockistId ? Number(stockistId) : null, retailerId: retailerId ? Number(retailerId) : null,
        subtotal: Number(subtotal), discountAmount: Number(discountAmount || 0),
        gstAmount: Number(gstAmount || 0), totalAmount: Number(totalAmount),
        dueDate: dueDate ? new Date(dueDate) : null, notes,
      },
    });
    return res.status(201).json({ success: true, data: invoice });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// GET /api/accounting/ledger
router.get('/ledger', authenticate, authorize('ACCOUNTANT', 'ADMIN'), async (req, res) => {
  try {
    const { accountHead, startDate, endDate } = req.query;
    const where: any = {};
    if (accountHead) where.accountHead = accountHead;
    if (startDate) where.entryDate = { gte: new Date(startDate as string) };
    if (endDate) where.entryDate = { ...where.entryDate, lte: new Date(endDate as string) };
    
    const entries = await prisma.ledgerEntry.findMany({
      where, include: { invoice: true }, orderBy: { entryDate: 'desc' },
    });
    return res.json({ success: true, data: entries });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// POST /api/accounting/payments
router.post('/payments', authenticate, authorize('ACCOUNTANT', 'ADMIN', 'STOCKIST', 'RETAILER'), async (req, res) => {
  try {
    const { invoiceId, orderId, amount, paymentMode, referenceNo, paidDate, notes } = req.body;
    const payment = await prisma.payment.create({
      data: {
        invoiceId: invoiceId ? Number(invoiceId) : null, orderId: orderId ? Number(orderId) : null,
        amount: Number(amount), paymentMode, referenceNo, paidDate: new Date(paidDate), notes,
      },
    });
    // Update invoice status
    if (invoiceId) {
      const invoice = await prisma.invoice.findUnique({ where: { id: Number(invoiceId) } });
      if (invoice) {
        const totalPaid = await prisma.payment.aggregate({ where: { invoiceId: Number(invoiceId) }, _sum: { amount: true } });
        const paid = totalPaid._sum.amount || 0;
        const status = paid >= invoice.totalAmount ? 'PAID' : 'PARTIAL';
        await prisma.invoice.update({ where: { id: Number(invoiceId) }, data: { status, paidAt: status === 'PAID' ? new Date() : null } });
      }
    }
    return res.status(201).json({ success: true, data: payment });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// GET /api/accounting/gst-report
router.get('/gst-report', authenticate, authorize('ACCOUNTANT', 'ADMIN'), async (req, res) => {
  try {
    const { month, year } = req.query;
    const records = await prisma.gstRecord.findMany({
      where: { month: Number(month), year: Number(year) },
      include: { invoice: true },
    });
    const summary = {
      totalTaxable: records.reduce((a, r) => a + Number(r.taxableAmount), 0),
      totalCgst: records.reduce((a, r) => a + Number(r.cgst), 0),
      totalSgst: records.reduce((a, r) => a + Number(r.sgst), 0),
      totalIgst: records.reduce((a, r) => a + Number(r.igst), 0),
      totalGst: records.reduce((a, r) => a + Number(r.totalGst), 0),
    };
    return res.json({ success: true, data: { records, summary } });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

export default router;

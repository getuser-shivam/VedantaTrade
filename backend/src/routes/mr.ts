import { Router } from 'express';
import { PrismaClient } from '@prisma/client';
import { authenticate, authorize } from '../middleware/auth';

const router = Router();
const prisma = new PrismaClient();

// GET /api/mr/visits - List all visits for current MR
router.get('/visits', authenticate, authorize('MEDICAL_REP', 'ADMIN'), async (req: any, res) => {
  try {
    const { startDate, endDate, doctorId } = req.query;
    const mrProfile = await prisma.medicalRep.findUnique({ where: { userId: req.user.id } });
    if (!mrProfile && req.user.role !== 'ADMIN') return res.status(404).json({ success: false, message: 'MR profile not found' });

    const where: any = {};
    if (mrProfile) where.mrId = mrProfile.id;
    if (startDate) where.visitDate = { gte: new Date(startDate as string) };
    if (endDate) where.visitDate = { ...where.visitDate, lte: new Date(endDate as string) };
    if (doctorId) where.doctorId = Number(doctorId);

    const visits = await prisma.mrVisit.findMany({
      where,
      include: { doctor: true, samples: { include: { product: true } } },
      orderBy: { visitDate: 'desc' },
    });
    return res.json({ success: true, data: visits });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// POST /api/mr/visits - Log a new visit
router.post('/visits', authenticate, authorize('MEDICAL_REP', 'ADMIN'), async (req: any, res) => {
  try {
    const { doctorId, visitType, visitDate, notes, nextFollowUp, latitude, longitude, samplesGiven, ordersBooked } = req.body;
    const mrProfile = await prisma.medicalRep.findUnique({ where: { userId: req.user.id } });
    if (!mrProfile) return res.status(404).json({ success: false, message: 'MR profile not found' });

    const visit = await prisma.mrVisit.create({
      data: {
        mrId: mrProfile.id, userId: req.user.id, doctorId: Number(doctorId),
        visitType, visitDate: new Date(visitDate), notes, nextFollowUp: nextFollowUp ? new Date(nextFollowUp) : null,
        latitude: latitude ? Number(latitude) : null, longitude: longitude ? Number(longitude) : null,
        samplesGiven: samplesGiven || 0, ordersBooked: ordersBooked || 0,
      },
      include: { doctor: true },
    });
    return res.status(201).json({ success: true, data: visit });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// GET /api/mr/tour-plans - Get tour plans
router.get('/tour-plans', authenticate, authorize('MEDICAL_REP', 'ADMIN'), async (req: any, res) => {
  try {
    const mrProfile = await prisma.medicalRep.findUnique({ where: { userId: req.user.id } });
    const plans = await prisma.tourPlan.findMany({
      where: mrProfile ? { mrId: mrProfile.id } : {},
      orderBy: { planDate: 'desc' },
    });
    return res.json({ success: true, data: plans });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// POST /api/mr/tour-plans - Create tour plan
router.post('/tour-plans', authenticate, authorize('MEDICAL_REP', 'ADMIN'), async (req: any, res) => {
  try {
    const { planDate, headquarters, plannedVisits } = req.body;
    const mrProfile = await prisma.medicalRep.findUnique({ where: { userId: req.user.id } });
    if (!mrProfile) return res.status(404).json({ success: false, message: 'MR profile not found' });

    const plan = await prisma.tourPlan.create({
      data: { mrId: mrProfile.id, planDate: new Date(planDate), headquarters, plannedVisits: plannedVisits || [] },
    });
    return res.status(201).json({ success: true, data: plan });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// GET /api/mr/expenses - Get expenses
router.get('/expenses', authenticate, authorize('MEDICAL_REP', 'ADMIN', 'ACCOUNTANT'), async (req: any, res) => {
  try {
    const where: any = req.user.role === 'MEDICAL_REP' ? { userId: req.user.id } : {};
    const expenses = await prisma.expense.findMany({
      where,
      include: { user: { select: { name: true, employeeCode: true } } },
      orderBy: { expenseDate: 'desc' },
    });
    return res.json({ success: true, data: expenses });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// POST /api/mr/expenses - Submit expense
router.post('/expenses', authenticate, authorize('MEDICAL_REP', 'ADMIN'), async (req: any, res) => {
  try {
    const { category, amount, description, expenseDate } = req.body;
    const expense = await prisma.expense.create({
      data: { userId: req.user.id, category, amount: Number(amount), description, expenseDate: new Date(expenseDate) },
    });
    return res.status(201).json({ success: true, data: expense });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// PUT /api/mr/expenses/:id/approve - Approve expense
router.put('/expenses/:id/approve', authenticate, authorize('ADMIN', 'ACCOUNTANT'), async (req: any, res) => {
  try {
    const { approve } = req.body;
    const expense = await prisma.expense.update({
      where: { id: Number(req.params.id) },
      data: { status: approve ? 'APPROVED' : 'REJECTED', approvedBy: req.user.id, approvedAt: new Date() },
    });
    return res.json({ success: true, data: expense });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// GET /api/mr/targets - Get targets
router.get('/targets', authenticate, authorize('MEDICAL_REP', 'ADMIN'), async (req: any, res) => {
  try {
    const mrProfile = await prisma.medicalRep.findUnique({ where: { userId: req.user.id } });
    const targets = await prisma.mrTarget.findMany({
      where: mrProfile ? { mrId: mrProfile.id } : {},
      include: { products: { include: { product: true } } },
      orderBy: [{ year: 'desc' }, { month: 'desc' }],
    });
    return res.json({ success: true, data: targets });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// GET /api/mr/dashboard - MR dashboard stats
router.get('/dashboard', authenticate, authorize('MEDICAL_REP', 'ADMIN'), async (req: any, res) => {
  try {
    const mrProfile = await prisma.medicalRep.findUnique({ where: { userId: req.user.id } });
    if (!mrProfile) return res.status(404).json({ success: false, message: 'MR profile not found' });

    const today = new Date();
    const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);

    const [visitsThisMonth, visitsToday, pendingExpenses, samplesDistributed] = await Promise.all([
      prisma.mrVisit.count({ where: { mrId: mrProfile.id, visitDate: { gte: startOfMonth } } }),
      prisma.mrVisit.count({ where: { mrId: mrProfile.id, visitDate: { gte: new Date(today.setHours(0,0,0,0)) } } }),
      prisma.expense.count({ where: { userId: req.user.id, status: 'SUBMITTED' } }),
      prisma.sampleDistribution.aggregate({ where: { mrId: mrProfile.id, givenDate: { gte: startOfMonth } }, _sum: { quantity: true } }),
    ]);

    return res.json({ success: true, data: { visitsThisMonth, visitsToday, pendingExpenses, samplesDistributed: samplesDistributed._sum.quantity || 0, mrProfile } });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

export default router;

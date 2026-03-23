import { Router } from 'express';
import { PrismaClient } from '@prisma/client';
import { authenticate, authorize } from '../middleware/auth';

const router = Router();
const prisma = new PrismaClient();

// GET all doctors
router.get('/', authenticate, async (req, res) => {
  try {
    const { city, specialization, search, page = 1, limit = 20 } = req.query;
    const where: any = {};
    if (city) where.city = { contains: city as string, mode: 'insensitive' };
    if (specialization) where.specialization = { contains: specialization as string, mode: 'insensitive' };
    if (search) where.OR = [
      { name: { contains: search as string, mode: 'insensitive' } },
      { clinicName: { contains: search as string, mode: 'insensitive' } },
      { city: { contains: search as string, mode: 'insensitive' } },
    ];

    const [doctors, total] = await Promise.all([
      prisma.doctor.findMany({ where, skip: (Number(page) - 1) * Number(limit), take: Number(limit), include: { hospitals: { include: { hospital: true } } }, orderBy: { potentialScore: 'desc' } }),
      prisma.doctor.count({ where }),
    ]);
    return res.json({ success: true, data: doctors, pagination: { page: Number(page), limit: Number(limit), total } });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// GET doctor by ID
router.get('/:id', authenticate, async (req, res) => {
  try {
    const doctor = await prisma.doctor.findUnique({
      where: { id: Number(req.params.id) },
      include: { hospitals: { include: { hospital: true } }, visits: { take: 5, orderBy: { visitDate: 'desc' }, include: { mr: { include: { user: true } } } } },
    });
    if (!doctor) return res.status(404).json({ success: false, message: 'Doctor not found' });
    return res.json({ success: true, data: doctor });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// POST create doctor
router.post('/', authenticate, authorize('ADMIN', 'MEDICAL_REP'), async (req, res) => {
  try {
    const doctor = await prisma.doctor.create({ data: req.body });
    return res.status(201).json({ success: true, data: doctor });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// PUT update doctor
router.put('/:id', authenticate, authorize('ADMIN', 'MEDICAL_REP'), async (req, res) => {
  try {
    const doctor = await prisma.doctor.update({ where: { id: Number(req.params.id) }, data: req.body });
    return res.json({ success: true, data: doctor });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// GET doctor visit history
router.get('/:id/visits', authenticate, async (req, res) => {
  try {
    const visits = await prisma.mrVisit.findMany({
      where: { doctorId: Number(req.params.id) },
      include: { user: { select: { name: true } }, samples: { include: { product: true } } },
      orderBy: { visitDate: 'desc' },
    });
    return res.json({ success: true, data: visits });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

export default router;

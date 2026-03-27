import { Router } from 'express';
import { PrismaClient } from '@prisma/client';
import { authenticate, authorize } from '../middleware/auth';
import bcrypt from 'bcryptjs';

const router = Router();
const prisma = new PrismaClient();

// GET all users (Admin only)
router.get('/', authenticate, authorize('ADMIN'), async (req, res) => {
  try {
    const users = await prisma.user.findMany({
      select: { id: true, name: true, email: true, role: true, phone: true, isActive: true, territory: true, employeeCode: true, createdAt: true, lastLogin: true },
      orderBy: { createdAt: 'desc' },
    });
    return res.json({ success: true, data: users });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// GET user by ID
router.get('/:id', authenticate, async (req, res) => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: Number(req.params.id) },
      include: { mrProfile: true, doctorProfile: true, stockistProfile: true, retailerProfile: true },
    });
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });
    const { passwordHash, ...safeUser } = user;
    return res.json({ success: true, data: safeUser });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// PUT update user
router.put('/:id', authenticate, authorize('ADMIN'), async (req, res) => {
  try {
    const { name, phone, role, isActive, territory } = req.body;
    const user = await prisma.user.update({
      where: { id: Number(req.params.id) },
      data: { name, phone, role, isActive, territory, updatedAt: new Date() },
    });
    const { passwordHash, ...safeUser } = user;
    return res.json({ success: true, data: safeUser });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// PUT change password
router.put('/:id/password', authenticate, async (req, res) => {
  try {
    const { newPassword } = req.body;
    const passwordHash = await bcrypt.hash(newPassword, 12);
    await prisma.user.update({ where: { id: Number(req.params.id) }, data: { passwordHash } });
    return res.json({ success: true, message: 'Password updated' });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// DELETE user
router.delete('/:id', authenticate, authorize('ADMIN'), async (req, res) => {
  try {
    await prisma.user.update({ where: { id: Number(req.params.id) }, data: { isActive: false } });
    return res.json({ success: true, message: 'User deactivated' });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// GET dashboard summary (Admin)
router.get('/admin/dashboard', authenticate, authorize('ADMIN'), async (req, res) => {
  try {
    const [totalUsers, totalMRs, totalDoctors, totalStockists, totalRetailers, totalOrders, pendingLeads] = await Promise.all([
      prisma.user.count({ where: { isActive: true } }),
      prisma.user.count({ where: { role: 'MEDICAL_REP', isActive: true } }),
      prisma.doctor.count(),
      prisma.stockist.count(),
      prisma.retailer.count(),
      prisma.order.count(),
      prisma.scrapedLead.count({ where: { status: 'RAW' } }),
    ]);
    return res.json({ success: true, data: { totalUsers, totalMRs, totalDoctors, totalStockists, totalRetailers, totalOrders, pendingLeads } });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});
// GET map data for Janakpur (Admin)
router.get('/admin/map-data', authenticate, authorize('ADMIN'), async (req, res) => {
  try {
    const doctors = await prisma.doctor.findMany({ where: { lat: { not: null }, lng: { not: null } } });
    const stockists = await prisma.stockist.findMany({ where: { lat: { not: null }, lng: { not: null } } });
    const retailers = await prisma.retailer.findMany({ where: { lat: { not: null }, lng: { not: null } } });
    const mrVisits = await prisma.mrVisit.findMany({ 
      where: { lat: { not: null }, lng: { not: null } },
      include: { mr: { include: { user: true } } },
      orderBy: { visit_date: 'desc' },
      take: 20
    });

    const data: any[] = [];
    doctors.forEach(d => data.push({ type: 'DOCTOR', name: d.clinic_name ? `${d.name} (${d.clinic_name})` : d.name, lat: d.lat, lng: d.lng }));
    stockists.forEach(s => data.push({ type: 'STOCKIST', name: s.firm_name, lat: s.lat, lng: s.lng }));
    retailers.forEach(r => data.push({ type: 'RETAILER', name: r.firm_name, lat: r.lat, lng: r.lng }));
    mrVisits.forEach(v => data.push({ type: 'MR_VISIT', name: `MR: ${v.mr.user.name || 'Unknown'} (Visit)`, lat: v.lat, lng: v.lng }));

    return res.json({ success: true, data });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

export default router;

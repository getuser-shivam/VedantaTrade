import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function seed() {
  console.log('🌱 Seeding VedantaTrade SQL Server database (Definitively Snake_Case)...');

  // Clear existing pharma data
  await prisma.sampleDistribution.deleteMany();
  await prisma.mrTarget.deleteMany();
  await prisma.mrVisit.deleteMany();
  await prisma.scrapedLead.deleteMany();
  await prisma.scraperJob.deleteMany();
  await prisma.medicalRep.deleteMany();
  await prisma.doctor.deleteMany();
  await prisma.stockist.deleteMany();
  await prisma.retailer.deleteMany();
  await prisma.session.deleteMany();
  await prisma.users.deleteMany();
  await prisma.category.deleteMany();

  console.log('Sweep complete');

  // Create categories
  const catAntibiotics = await prisma.category.create({ data: { name: 'Antibiotics', description: 'Anti-bacterial medications' } });
  
  console.log('✅ Categories created');

  // Create sample products (InventoryItems - plural)
  await prisma.inventoryItems.create({
    data: {
      item_name: 'Amoxicillin 500mg', generic_name: 'Amoxicillin', sku: 'VTL-AMX-500',
      category_id: catAntibiotics.id, manufacturer: 'Vedanta Labs',
      composition: 'Amoxicillin Trihydrate 500mg', pack_size: '10 capsules/strip',
      mrp: 85.00, ptr: 68.00, pts: 60.00, gst_percent: 12,
      stock_quantity: 500, requires_prescription: true,
      is_active: true,
    },
  });
  console.log('✅ Inventory Items created');

  const adminPw = await bcrypt.hash('Admin@123', 12);
  const mrPw = await bcrypt.hash('MR@123', 12);
  const docPw = await bcrypt.hash('Doc@123', 12);

  const admin = await prisma.users.create({
    data: { name: 'Vedanta Admin', username: 'admin@vedanta.com', password_hash: adminPw, role: 'ADMIN', phone: '9800000001', is_active: true },
  });

  const mrUser = await prisma.users.create({
    data: { name: 'Ramesh Kumar (MR)', username: 'mr@vedanta.com', password_hash: mrPw, role: 'MEDICAL_REP', phone: '9800000002', is_active: true },
  });

  const doctorUser = await prisma.users.create({
    data: { name: 'Dr. Anil Verma', username: 'doctor@vedanta.com', password_hash: docPw, role: 'DOCTOR', phone: '9800000004', is_active: true },
  });

  console.log('✅ Users created');

  // Create profiles
  const mrProfile = await prisma.medicalRep.create({
    data: { user_id: mrUser.user_id, employee_code: 'MR001', territory: 'Mumbai Central', headquarters: 'Mumbai', joining_date: new Date('2023-01-15') },
  });

  const doctorProfile = await prisma.doctor.create({
    data: {
      user_id: doctorUser.user_id, name: 'Dr. Anil Verma', registration_no: 'MH-12345',
      specialization: 'General Physician', clinic_name: 'Verma Clinic',
      clinic_address: '302, Linking Road, Bandra West', city: 'Mumbai',
      potential_score: 8,
    },
  });

  // Sample MR visit
  await prisma.mrVisit.create({
    data: {
      mr_id: mrProfile.id, user_id: mrUser.user_id, doctor_id: doctorProfile.id,
      visit_date: new Date(), visit_type: 'FOLLOW_UP', notes: 'Discussed new cardiovascular product line.',
      checkin_time: new Date(Date.now() - 60 * 60 * 1000), checkout_time: new Date(),
      samples_given: 2, orders_booked: 5000,
    },
  });

  console.log('✅ Profiles and visits created');
  console.log('\n✅ SQL Server Seeded (Snake_Case) Successfully!');
}

seed().catch((e) => { console.error(e); process.exit(1); }).finally(() => prisma.$disconnect());

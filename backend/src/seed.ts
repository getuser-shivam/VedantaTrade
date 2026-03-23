import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function seed() {
  console.log('🌱 Seeding VedantaTrade database...');

  // Create categories
  const categories = await Promise.all([
    prisma.category.upsert({ where: { name: 'Antibiotics' }, update: {}, create: { name: 'Antibiotics', description: 'Anti-bacterial medications' } }),
    prisma.category.upsert({ where: { name: 'Cardiovascular' }, update: {}, create: { name: 'Cardiovascular', description: 'Heart and blood pressure medications' } }),
    prisma.category.upsert({ where: { name: 'Diabetes' }, update: {}, create: { name: 'Diabetes', description: 'Diabetes management medications' } }),
    prisma.category.upsert({ where: { name: 'Analgesics' }, update: {}, create: { name: 'Analgesics', description: 'Pain relief medications' } }),
    prisma.category.upsert({ where: { name: 'Vitamins & Supplements' }, update: {}, create: { name: 'Vitamins & Supplements', description: 'Nutritional supplements' } }),
  ]);
  console.log('✅ Categories created');

  // Create sample products
  await prisma.product.upsert({
    where: { sku: 'VTL-AMX-500' },
    update: {},
    create: {
      name: 'Amoxicillin 500mg', genericName: 'Amoxicillin', sku: 'VTL-AMX-500',
      categoryId: categories[0].id, manufacturer: 'Vedanta Labs',
      composition: 'Amoxicillin Trihydrate 500mg', packSize: '10 capsules/strip',
      mrp: 85.00, ptr: 68.00, pts: 60.00, gstPercent: 12,
      stockQuantity: 500, requiresPrescription: true,
    },
  });
  await prisma.product.upsert({
    where: { sku: 'VTL-MET-500' },
    update: {},
    create: {
      name: 'Metformin 500mg', genericName: 'Metformin HCl', sku: 'VTL-MET-500',
      categoryId: categories[2].id, manufacturer: 'Vedanta Labs',
      composition: 'Metformin Hydrochloride 500mg', packSize: '10 tablets/strip',
      mrp: 45.00, ptr: 36.00, pts: 30.00, gstPercent: 12,
      stockQuantity: 1000, requiresPrescription: true,
    },
  });
  await prisma.product.upsert({
    where: { sku: 'VTL-VIT-D3' },
    update: {},
    create: {
      name: 'Vitamin D3 60000 IU', genericName: 'Cholecalciferol', sku: 'VTL-VIT-D3',
      categoryId: categories[4].id, manufacturer: 'Vedanta Labs',
      composition: 'Vitamin D3 60000 IU', packSize: '4 capsules/pack',
      mrp: 120.00, ptr: 95.00, pts: 80.00, gstPercent: 5,
      stockQuantity: 800, requiresPrescription: false,
    },
  });
  console.log('✅ Products created');

  const adminPw = await bcrypt.hash('Admin@123', 12);
  const mrPw = await bcrypt.hash('MR@123', 12);
  const accPw = await bcrypt.hash('Acc@123', 12);
  const docPw = await bcrypt.hash('Doc@123', 12);
  const stockPw = await bcrypt.hash('Stock@123', 12);
  const retailPw = await bcrypt.hash('Retail@123', 12);

  const admin = await prisma.user.upsert({
    where: { email: 'admin@vedanta.com' },
    update: {},
    create: { name: 'Vedanta Admin', email: 'admin@vedanta.com', passwordHash: adminPw, role: 'ADMIN', phone: '9800000001', isActive: true, emailVerified: true },
  });

  const mr = await prisma.user.upsert({
    where: { email: 'mr@vedanta.com' },
    update: {},
    create: { name: 'Ramesh Kumar (MR)', email: 'mr@vedanta.com', passwordHash: mrPw, role: 'MEDICAL_REP', phone: '9800000002', territory: 'Mumbai Central', employeeCode: 'MR001', isActive: true },
  });

  await prisma.user.upsert({
    where: { email: 'accountant@vedanta.com' },
    update: {},
    create: { name: 'Priya Sharma (Accountant)', email: 'accountant@vedanta.com', passwordHash: accPw, role: 'ACCOUNTANT', phone: '9800000003', isActive: true },
  });

  const doctorUser = await prisma.user.upsert({
    where: { email: 'doctor@vedanta.com' },
    update: {},
    create: { name: 'Dr. Anil Verma', email: 'doctor@vedanta.com', passwordHash: docPw, role: 'DOCTOR', phone: '9800000004', isActive: true },
  });

  const stockistUser = await prisma.user.upsert({
    where: { email: 'stockist@vedanta.com' },
    update: {},
    create: { name: 'Mahesh Distributors', email: 'stockist@vedanta.com', passwordHash: stockPw, role: 'STOCKIST', phone: '9800000005', isActive: true },
  });

  const retailerUser = await prisma.user.upsert({
    where: { email: 'retailer@vedanta.com' },
    update: {},
    create: { name: 'City Pharmacy', email: 'retailer@vedanta.com', passwordHash: retailPw, role: 'RETAILER', phone: '9800000006', isActive: true },
  });
  console.log('✅ Users created');

  // Create MR profile
  const mrProfile = await prisma.medicalRep.upsert({
    where: { userId: mr.id },
    update: {},
    create: { userId: mr.id, employeeCode: 'MR001', territory: 'Mumbai Central', headquarters: 'Mumbai', monthlySalary: 35000, joiningDate: new Date('2023-01-15') },
  });

  // Create doctor profile
  const doctorProfile = await prisma.doctor.upsert({
    where: { registrationNo: 'MH-12345' },
    update: {},
    create: {
      userId: doctorUser.id, name: 'Dr. Anil Verma', registrationNo: 'MH-12345',
      specialization: 'General Physician', qualification: 'MBBS, MD',
      phone: '9800000004', email: 'doctor@vedanta.com', clinicName: 'Verma Clinic',
      clinicAddress: '302, Linking Road, Bandra West', city: 'Mumbai', state: 'Maharashtra',
      potentialScore: 8, prescribingIndex: 50, isVerified: true,
    },
  });

  // Create stockist profile
  const stockistProfile = await prisma.stockist.upsert({
    where: { userId: stockistUser.id },
    update: {},
    create: {
      userId: stockistUser.id, firmName: 'Mahesh Distributors', ownerName: 'Mahesh Patel',
      phone: '9800000005', email: 'stockist@vedanta.com',
      address: '14, Industrial Area, Andheri East', city: 'Mumbai', state: 'Maharashtra',
      creditLimit: 500000, paymentTerms: 30, isVerified: true,
    },
  });

  // Create retailer profile
  const retailerProfile = await prisma.retailer.upsert({
    where: { userId: retailerUser.id },
    update: {},
    create: {
      userId: retailerUser.id, firmName: 'City Pharmacy', ownerName: 'Suresh Shah',
      phone: '9800000006', email: 'retailer@vedanta.com',
      address: '8, MG Road, Bandra', city: 'Mumbai', state: 'Maharashtra',
      creditLimit: 100000, paymentTerms: 15, isVerified: true,
    },
  });

  // Link stockist and retailer
  await prisma.stockistRetailer.upsert({
    where: { stockistId_retailerId: { stockistId: stockistProfile.id, retailerId: retailerProfile.id } },
    update: {},
    create: { stockistId: stockistProfile.id, retailerId: retailerProfile.id },
  });

  // Sample MR visit
  await prisma.mrVisit.create({
    data: {
      mrId: mrProfile.id, userId: mr.id, doctorId: doctorProfile.id,
      visitDate: new Date(), visitType: 'FOLLOW_UP', notes: 'Discussed new cardiovascular product line. Doctor showed interest in Amoxicillin 500mg for walk-in patients.',
      nextFollowUp: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
      checkinTime: new Date(Date.now() - 60 * 60 * 1000), checkoutTime: new Date(),
      samplesGiven: 2, ordersBooked: 5000,
    },
  });

  // Set MR target
  const now = new Date();
  await prisma.mrTarget.upsert({
    where: { mrId_month_year: { mrId: mrProfile.id, month: now.getMonth() + 1, year: now.getFullYear() } },
    update: {},
    create: { mrId: mrProfile.id, month: now.getMonth() + 1, year: now.getFullYear(), visitTarget: 60, orderTarget: 250000, achievedVisits: 15, achievedOrders: 75000 },
  });

  console.log('✅ Profiles, visits, and targets created');
  console.log('\n✅ Database seeded successfully!');
  console.log('\n🔑 Test Credentials:');
  console.log('  Admin:      admin@vedanta.com / Admin@123');
  console.log('  MR:         mr@vedanta.com / MR@123');
  console.log('  Accountant: accountant@vedanta.com / Acc@123');
  console.log('  Doctor:     doctor@vedanta.com / Doc@123');
  console.log('  Stockist:   stockist@vedanta.com / Stock@123');
  console.log('  Retailer:   retailer@vedanta.com / Retail@123');
}

seed().catch((e) => { console.error(e); process.exit(1); }).finally(() => prisma.$disconnect());

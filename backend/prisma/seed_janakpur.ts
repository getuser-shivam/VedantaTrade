import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

// Janakpur coordinates: 26.7288° N, 85.9260° E
const BaseLat = 26.7288;
const BaseLng = 85.9260;

// Helper to generate a random coordinate within roughly 5km of Janakpur central
const randomOffset = () => (Math.random() - 0.5) * 0.05;

const HOSPITALS = [
  'Janaki Medical College Teaching Hospital',
  'Janakpur City Hospital',
  'Janaki Health Care and Teaching Hospital Pvt. Ltd.',
  'Kavya Hospital Janakpur',
  'Nepal Apollo Hospital',
  'Janakpur Zonal Hospital',
  'Binaytara Foundation Cancer Center',
  'Reiyukai Eiko Masunaga Eye Hospital'
];

const CLINICS = [
  'Janakpur ENT Care Center',
  'UroCare Clinic',
  'Care Medical Centre',
  'Janakpur Dermatology and Cosmetic Clinic',
  'Kavya Clinic',
  'Mihilal CT Scan and Polyclinic'
];

const DOCTORS = [
  { name: 'Dr. Sujeet Kumar Shah', spec: 'General Medicine', exp: 12 },
  { name: 'Dr. Apurva Gupta', spec: 'Cardiology', exp: 8 },
  { name: 'Dr. Ambrish Yadav', spec: 'Pediatrics', exp: 15 },
  { name: 'Dr. Nagendra Sah', spec: 'Orthopedics', exp: 20 },
  { name: 'Dr. Rashmi Jha', spec: 'Gynaecology', exp: 10 },
  { name: 'Dr. Vishwanath Mishra', spec: 'Internal Medicine', exp: 18 },
  { name: 'Dr. Rabin P Shah', spec: 'General Surgery', exp: 14 },
  { name: 'Dr. Sandeep Sharma', spec: 'Anesthesiology', exp: 9 },
  { name: 'Dr. Anand Nayak', spec: 'Pathology', exp: 11 },
  { name: 'Dr. Shambhu Shah', spec: 'Radiology', exp: 16 },
  { name: 'Dr. Sunil Kumar Singh', spec: 'ENT', exp: 22 },
  { name: 'Dr. Surendra Kumar Yadav', spec: 'Hospital Director', exp: 25 },
];

const STOCKISTS = [
  'Janakpur Pharma Distributors',
  'Mithila Medical Suppliers',
  'Madhesh Healthcare Logistics',
  'Ramjanki Medical Hub'
];

const RETAILERS = [
  'Shree Ram Pharmacy',
  'Janaki Medico',
  'Sita Medical Hall',
  'Dhanusha Pharmacy',
  'Central Care Chemists'
];

async function main() {
  console.log('🗺️ Generating Janakpur Geospatial Data...');
  
  // Create Doctors
  console.log('🩺 Inserting Janakpur Doctors and Hospitals/Clinics...');
  for (const doc of DOCTORS) {
    const isHospital = Math.random() > 0.5;
    const workPlace = isHospital 
      ? HOSPITALS[Math.floor(Math.random() * HOSPITALS.length)]
      : CLINICS[Math.floor(Math.random() * CLINICS.length)];
    
    const regNo = `NMC-${doc.name.replace(/\s+/g, '')}`;
    const existing = await prisma.doctor.findFirst({ where: { registration_no: regNo } });
    
    if (!existing) {
      // Must create User to avoid SQL Server NULL unique constraint
      const createdUser = await prisma.users.create({
        data: {
          name: doc.name,
          username: `${doc.name.replace(/[^a-zA-Z]/g, '').toLowerCase()}@vedantatrade.com`,
          password_hash: 'seeded',
          role: 'DOCTOR',
          is_active: true
        }
      });
      await prisma.doctor.create({
        data: {
          name: doc.name,
          specialization: doc.spec,
          registration_no: regNo,
          clinic_name: workPlace,
          city: 'Janakpur',
          clinic_address: `Hospital Road, Janakpur`,
          lat: BaseLat + randomOffset(),
          lng: BaseLng + randomOffset(),
          user_id: createdUser.user_id
        }
      });
    } else {
      await prisma.doctor.update({
        where: { id: existing.id },
        data: { lat: BaseLat + randomOffset(), lng: BaseLng + randomOffset() }
      });
    }
  }

  // Create Stockists
  console.log('📦 Inserting Janakpur Stockists...');
  for (const st of STOCKISTS) {
    // Check if exists
    const existing = await prisma.stockist.findFirst({ where: { firm_name: st } });
    if (!existing) {
      const createdUser = await prisma.users.create({
        data: {
          name: st,
          username: `${st.replace(/[^a-zA-Z]/g, '').toLowerCase()}@vedantatrade.com`,
          password_hash: 'seeded',
          role: 'STOCKIST',
          is_active: true
        }
      });
      await prisma.stockist.create({
        data: {
          firm_name: st,
          phone: `+977-980000${Math.floor(Math.random() * 9999)}`,
          address: 'Station Road, Janakpur',
          city: 'Janakpur',
          credit_limit: 500000,
          lat: BaseLat + randomOffset(),
          lng: BaseLng + randomOffset(),
          user_id: createdUser.user_id
        }
      });
    }
  }

  // Create Retailers
  console.log('🏪 Inserting Janakpur Retailers...');
  for (const rt of RETAILERS) {
    const existing = await prisma.retailer.findFirst({ where: { firm_name: rt } });
    if (!existing) {
      const createdUser = await prisma.users.create({
        data: {
          name: rt,
          username: `${rt.replace(/[^a-zA-Z]/g, '').toLowerCase()}@vedantatrade.com`,
          password_hash: 'seeded',
          role: 'RETAILER',
          is_active: true
        }
      });
      await prisma.retailer.create({
        data: {
          firm_name: rt,
          phone: `+977-981110${Math.floor(Math.random() * 9999)}`,
          address: 'Mills Area, Janakpur',
          city: 'Janakpur',
          credit_limit: 100000,
          lat: BaseLat + randomOffset(),
          lng: BaseLng + randomOffset(),
          user_id: createdUser.user_id
        }
      });
    }
  }

  console.log('✅ Janakpur GPS Ecosystem Seeded Successfully!');
}

main()
  .catch(e => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

const BRANDS = [
  'Vatave Healthcare', 'Bio Foods Nepal', 'Jiri Nutrition', 'Global Oriens', 
  'Muscleblaze', 'Optimum Nutrition', 'Centrum', 'Nature Made', 'Himalayan Organics',
  'Patanjali', 'Dabur', 'GNC', 'Fast&Up', 'Nutrabay', 'Sunova', 'Baidyanath',
  'Nature\'s Bounty', 'Vital Proteins', 'BiotechUSA'
];

const CATEGORIES = [
  { name: 'Vitamins & Minerals', desc: 'Essential daily vitamins and minerals.' },
  { name: 'Sports Nutrition', desc: 'Protein powders, BCAAs, and pre-workouts.' },
  { name: 'Herbal & Ayurvedic', desc: 'Traditional herbs and wellness extracts.' },
  { name: 'Bone & Joint Health', desc: 'Calcium, glucosamine, and bone support.' },
  { name: 'Immunity & Wellness', desc: 'Antioxidants and immune boosters.' },
  { name: 'Weight Management', desc: 'Fat burners and metabolism support.' }
];

const BASES = {
  'Vitamins & Minerals': [
    { name: 'Multivitamin Gold', comp: 'Multivitamins + Minerals + Ginseng' },
    { name: 'Vitamin C 1000mg', comp: 'Vitamin C (Ascorbic Acid) + Zinc' },
    { name: 'Vitamin D3 60000 IU', comp: 'Cholecalciferol 60000 IU' },
    { name: 'B-Complex Plus', comp: 'Vitamins B1, B2, B3, B5, B6, B12' },
    { name: 'Iron & Folic Acid', comp: 'Ferrous Ascorbate + Folic Acid' },
    { name: 'Zinc Picolinate 50mg', comp: 'Zinc Picolinate' },
    { name: 'Magnesium Glycinate', comp: 'Magnesium Glycinate 400mg' },
    { name: 'Vitamin E 400 IU', comp: 'Tocopheryl Acetate' },
  ],
  'Sports Nutrition': [
    { name: 'Whey Protein Isolate', comp: '100% Whey Protein Isolate (25g Protein)' },
    { name: 'Mass Gainer Pro', comp: 'Carb Blend + Whey Protein Concentrate' },
    { name: 'BCAA 2:1:1', comp: 'L-Leucine, L-Isoleucine, L-Valine' },
    { name: 'Creatine Monohydrate', comp: 'Micronized Creatine Monohydrate 3g' },
    { name: 'Pre-Workout Explosive', comp: 'Caffeine, Beta-Alanine, Citrulline' },
    { name: 'L-Glutamine Recovery', comp: 'Pure L-Glutamine 5g' },
  ],
  'Herbal & Ayurvedic': [
    { name: 'Ashwagandha Extract', comp: 'Withania Somnifera Extract 500mg' },
    { name: 'Shilajit Resin', comp: 'Purified Shilajit with Fulvic Acid' },
    { name: 'Curcumin 95%', comp: 'Turmeric Extract + Piperine' },
    { name: 'Amla Power', comp: 'Emblica Officinalis 1000mg' },
    { name: 'Triphala Detox', comp: 'Amla, Haritaki, Bahera' },
    { name: 'Giloy Tulsi Juice', comp: 'Tinospora Cordifolia + Holy Basil' },
    { name: 'Brahmi Focus', comp: 'Bacopa Monnieri Extract' },
  ],
  'Bone & Joint Health': [
    { name: 'Calcium + D3 + K2', comp: 'Calcium Citrate + Vit D3 + Vit K2' },
    { name: 'Glucosamine Chondroitin', comp: 'Glucosamine Sulfate + Chondroitin' },
    { name: 'Collagen Peptides', comp: 'Type I & III Hydrolyzed Collagen' },
    { name: 'Cissus Quadrangularis', comp: 'Hadjod Extract 500mg' },
  ],
  'Immunity & Wellness': [
    { name: 'Omega-3 Fish Oil', comp: 'EPA 180mg + DHA 120mg' },
    { name: 'Probiotics 50 Billion CFU', comp: '10 Strains Lactobacillus & Bifidobacterium' },
    { name: 'CoQ10 100mg', comp: 'Coenzyme Q10' },
    { name: 'Melatonin Sleep Support', comp: 'Melatonin 3mg + Tagara' },
    { name: 'Spirulina Superfood', comp: 'Spirulina Powder 500mg' },
  ],
  'Weight Management': [
    { name: 'L-Carnitine L-Tartrate', comp: 'L-Carnitine 1000mg' },
    { name: 'Apple Cider Vinegar', comp: 'Raw ACV with Mother 500mg' },
    { name: 'Garcinia Cambogia', comp: 'Garcinia Extract 60% HCA' },
    { name: 'Green Tea Extract', comp: 'EGCG 50% Extract' }
  ]
};

const PACK_SIZES = ['30 Tablets', '60 Capsules', '90 Capsules', '120 Tablets', '250g Powder', '500g Powder', '1kg Tub', '2kg Tub', '200ml Syrup', '50ml Resin'];

// Nepal realistic pricing functions (in NPR)
const randomInt = (min: number, max: number) => Math.floor(Math.random() * (max - min + 1)) + min;
function generatePrice() {
  const isPremium = Math.random() > 0.7;
  // MRP in NPR
  const mrp = isPremium ? randomInt(3000, 15000) : randomInt(500, 2500); 
  const ptr = Math.round(mrp * 0.7); // Price to Retailer
  const pts = Math.round(mrp * 0.6); // Price to Stockist
  return { mrp, ptr, pts };
}

async function main() {
  console.log('🌱 Truncating previous Inventory items to prevent duplicates...');
  // Be careful with foreign keys in production; fine for seeding.
  await prisma.inventoryItems.deleteMany({});
  await prisma.category.deleteMany({});

  console.log('📂 Creating Categories...');
  const categoryMap: Record<string, number> = {};
  for (const cat of CATEGORIES) {
    const c = await prisma.category.create({
      data: { name: cat.name, description: cat.desc, is_active: true }
    });
    categoryMap[cat.name] = c.id;
  }

  const itemsToInsert: any[] = [];
  let codeCounter = 10000;

  console.log('🧬 Generating thousands of Nutraceutical SKUs for Nepal market...');

  for (const brand of BRANDS) {
    for (const [catName, products] of Object.entries(BASES)) {
      for (const product of products) {
        // Select 3 random pack sizes for variety
        const sizes = [...PACK_SIZES].sort(() => 0.5 - Math.random()).slice(0, 3);
        
        for (const size of sizes) {
          const { mrp, ptr, pts } = generatePrice();
          codeCounter++;
          
          itemsToInsert.push({
            item_name: `${brand} ${product.name} - ${size}`,
            generic_name: product.name,
            sku: `NEP-${brand.substring(0,3).toUpperCase()}-${codeCounter}`,
            manufacturer: brand,
            composition: product.comp,
            pack_size: size,
            mrp,
             ptr,
             pts,
            gst_percent: 13, // Nepal VAT is 13% typically
            stock_quantity: randomInt(10, 500),
            requires_prescription: false,
            is_active: true,
            category_id: categoryMap[catName],
            description: `High-quality ${product.name} by ${brand}. Formulated with ${product.comp}. Perfect for the Nepali market.`
          });
        }
      }
    }
  }

  console.log(`🚀 Bulk inserting ${itemsToInsert.length} Nutraceutical products into the Database...`);
  
  // Chunking to avoid command size limits
  const chunkSize = 500;
  for (let i = 0; i < itemsToInsert.length; i += chunkSize) {
    const chunk = itemsToInsert.slice(i, i + chunkSize);
    await prisma.inventoryItems.createMany({
      data: chunk
    });
    console.log(`✅ Inserted chunk ${Math.floor(i/chunkSize) + 1} of ${Math.ceil(itemsToInsert.length/chunkSize)}`);
  }

  console.log('✨ Seed completed successfully! Database now contains thousands of Nepal-specific nutraceuticals.');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

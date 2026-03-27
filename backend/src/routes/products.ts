import { Router } from 'express';
import { PrismaClient } from '@prisma/client';
import { authenticate, authorize } from '../middleware/auth';

const router = Router();
const prisma = new PrismaClient();

router.get('/', authenticate, async (req, res) => {
  try {
    const { category, page = 1, limit = 20 } = req.query as any;
    const where: any = { isActive: true };
    if (category) where.categoryId = Number(category);
    const [products, total] = await Promise.all([
      prisma.inventoryItem.findMany({ 
        where, 
        skip: (Number(page) - 1) * Number(limit), 
        take: Number(limit), 
        include: { category: true }, 
        orderBy: { itemName: 'asc' } 
      }),
      prisma.inventoryItem.count({ where }),
    ]);

    const transformedProducts = products.map((p: any) => ({
      id: p.itemId.toString(),
      name: p.itemName,
      category: p.category?.name || 'Uncategorized',
      price: p.mrp || 0,
      imageUrl: p.imageUrls ? p.imageUrls.split(',')[0].trim() : '',
      description: p.description || '',
      sku: p.sku || '',
      manufacturer: p.manufacturer || '',
      composition: p.composition || '',
      packSize: p.packSize || '',
      stockQuantity: p.stockQuantity || 0,
      featured: false,
    }));

    return res.json({ success: true, data: transformedProducts, pagination: { page: Number(page), limit: Number(limit), total } });
  } catch (error) {
    console.error('Products fetch error:', error);
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

router.post('/', authenticate, authorize('ADMIN'), async (req, res) => {
  try {
    const product = await prisma.inventoryItem.create({ data: req.body });
    return res.status(201).json({ success: true, data: product });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

router.put('/:id', authenticate, authorize('ADMIN'), async (req, res) => {
  try {
    const product = await prisma.inventoryItem.update({ where: { itemId: Number(req.params.id) }, data: req.body });
    return res.json({ success: true, data: product });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

router.get('/categories', authenticate, async (req, res) => {
  try {
    const categories = await prisma.category.findMany({ where: { isActive: true } });
    const transformedCategories = categories.map(c => ({
      id: c.id.toString(),
      name: c.name,
      imageUrl: c.imageUrl || '',
      description: c.description || '',
    }));
    return res.json({ success: true, data: transformedCategories });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

import multer from 'multer';
import path from 'path';
import fs from 'fs';

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const dir = 'uploads/products';
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    cb(null, dir);
  },
  filename: (req, file, cb) => {
    cb(null, `product-${Date.now()}${path.extname(file.originalname)}`);
  },
});

const upload = multer({ storage });

router.post('/upload', authenticate, authorize('ADMIN'), upload.array('files'), async (req: any, res) => {
  try {
    const files = req.files as Express.Multer.File[];
    const urls = files.map(f => `/uploads/products/${f.filename}`);
    return res.json({ success: true, data: { urls } });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Upload failed' });
  }
});

export default router;

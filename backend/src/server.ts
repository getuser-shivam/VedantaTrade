import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import dotenv from 'dotenv';

import { errorHandler } from './middleware/errorHandler';
import authRoutes from './routes/auth';
import userRoutes from './routes/users';
import productRoutes from './routes/products';
import productCatalogRoutes from './routes/product_catalog';
import orderRoutes from './routes/orders';
import mrRoutes from './routes/mr';
import accountingRoutes from './routes/accounting';
import doctorRoutes from './routes/doctors';
import stockistRoutes from './routes/stockists';
import retailerRoutes from './routes/retailers';
import scraperRoutes from './routes/scraper';
import notificationRoutes from './routes/notifications';
import distributionRoutes from './routes/distribution';
import marketingRoutes from './routes/marketing';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3001;

// Security middleware
app.use(helmet());
app.use(cors({ origin: '*', credentials: true }));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 500,
  message: 'Too many requests from this IP, please try again later.',
});
app.use('/api/', limiter);

// Body parsing
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// Static files
app.use('/uploads', express.static('uploads'));

// Health check
app.get('/api/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    service: 'VedantaTrade Enterprise API',
    version: '2.0.0',
  });
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/products', productRoutes);
app.use('/api/products', productCatalogRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/mr', mrRoutes);
app.use('/api/accounting', accountingRoutes);
app.use('/api/doctors', doctorRoutes);
app.use('/api/stockists', stockistRoutes);
app.use('/api/retailers', retailerRoutes);
app.use('/api/scraper', scraperRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/distribution', distributionRoutes);
app.use('/api/marketing', marketingRoutes);

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({ success: false, message: 'API endpoint not found' });
});

// Error handler
app.use(errorHandler);

app.listen(PORT, () => {
  console.log(`🚀 VedantaTrade Enterprise API running on port ${PORT}`);
  console.log(`📊 Health: http://localhost:${PORT}/api/health`);
  console.log(`🔐 Auth: http://localhost:${PORT}/api/auth`);
});

process.on('SIGTERM', () => { console.log('Shutting down gracefully'); process.exit(0); });
process.on('SIGINT', () => { console.log('Shutting down gracefully'); process.exit(0); });

export default app;

import request from 'supertest';
import express from 'express';
import { PrismaClient } from '@prisma/client';

const app = express();
const prisma = new PrismaClient();

describe('Distribution System Integration Tests', () => {
  let server: any;

  beforeAll(async () => {
    // Start test server
    server = app.listen(3002);
    
    // Setup test data
    await setupTestData();
  });

  afterAll(async () => {
    // Cleanup
    await prisma.$disconnect();
    if (server) {
      server.close();
    }
  });

  describe('Distribution Centers API', () => {
    test('GET /api/distribution/centers - should return centers list', async () => {
      const response = await request(app)
        .get('/api/distribution/centers')
        .set('Authorization', 'Bearer test-token')
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toBeDefined();
      expect(Array.isArray(response.body.data.centers)).toBe(true);
    });

    test('POST /api/distribution/centers - should create new center', async () => {
      const centerData = {
        name: 'Test Center',
        code: 'TEST001',
        address: '123 Test Street',
        city: 'Test City',
        state: 'Test State',
        postal_code: '12345',
        country: 'India',
        phone: '+1234567890',
        email: 'test@example.com',
        manager_name: 'Test Manager',
        capacity: 1000
      };

      const response = await request(app)
        .post('/api/distribution/centers')
        .set('Authorization', 'Bearer test-token')
        .send(centerData)
        .expect(201);

      expect(response.body.success).toBe(true);
      expect(response.body.data.name).toBe(centerData.name);
      expect(response.body.data.code).toBe(centerData.code);
    });

    test('GET /api/distribution/centers with search - should filter centers', async () => {
      const response = await request(app)
        .get('/api/distribution/centers?search=Test')
        .set('Authorization', 'Bearer test-token')
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.centers.length).toBeGreaterThan(0);
    });
  });

  describe('Inventory Management API', () => {
    test('GET /api/distribution/inventory/:centerId - should return inventory allocations', async () => {
      const response = await request(app)
        .get('/api/distribution/inventory/1')
        .set('Authorization', 'Bearer test-token')
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.allocations).toBeDefined();
    });

    test('POST /api/distribution/inventory/allocate - should allocate inventory', async () => {
      const allocationData = {
        product_id: 1,
        center_id: 1,
        quantity: 100
      };

      const response = await request(app)
        .post('/api/distribution/inventory/allocate')
        .set('Authorization', 'Bearer test-token')
        .send(allocationData)
        .expect(201);

      expect(response.body.success).toBe(true);
      expect(response.body.data.quantity_allocated).toBe(allocationData.quantity);
    });
  });

  describe('Distribution Routes API', () => {
    test('GET /api/distribution/routes - should return routes list', async () => {
      const response = await request(app)
        .get('/api/distribution/routes')
        .set('Authorization', 'Bearer test-token')
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.routes).toBeDefined();
    });

    test('GET /api/distribution/routes with center filter - should filter routes', async () => {
      const response = await request(app)
        .get('/api/distribution/routes?centerId=1')
        .set('Authorization', 'Bearer test-token')
        .expect(200);

      expect(response.body.success).toBe(true);
    });
  });

  describe('Marketing Campaigns API', () => {
    test('GET /api/marketing/campaigns - should return campaigns list', async () => {
      const response = await request(app)
        .get('/api/marketing/campaigns')
        .set('Authorization', 'Bearer test-token')
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.campaigns).toBeDefined();
    });

    test('POST /api/marketing/campaigns - should create new campaign', async () => {
      const campaignData = {
        name: 'Test Campaign',
        description: 'Test campaign description',
        start_date: new Date().toISOString(),
        end_date: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(),
        budget: 5000,
        target_audience: 'All Customers',
        created_by: 1
      };

      const response = await request(app)
        .post('/api/marketing/campaigns')
        .set('Authorization', 'Bearer test-token')
        .send(campaignData)
        .expect(201);

      expect(response.body.success).toBe(true);
      expect(response.body.data.name).toBe(campaignData.name);
    });

    test('GET /api/marketing/campaigns/:id/products - should return campaign products', async () => {
      const response = await request(app)
        .get('/api/marketing/campaigns/1/products')
        .set('Authorization', 'Bearer test-token')
        .expect(200);

      expect(response.body.success).toBe(true);
    });
  });

  describe('Real-time Updates', () => {
    test('WebSocket connection - should establish connection', async () => {
      // Test WebSocket connection establishment
      const WebSocket = require('ws');
      const ws = new WebSocket('ws://localhost:3001/ws/inventory?token=test-token&userId=1');

      const connected = await new Promise((resolve) => {
        ws.on('open', () => {
          resolve(true);
        });
      });

      expect(connected).toBe(true);
      ws.close();
    });

    test('Inventory update broadcast - should receive updates', async () => {
      const WebSocket = require('ws');
      const ws = new WebSocket('ws://localhost:3001/ws/inventory?token=test-token&userId=1');

      const messageReceived = await new Promise((resolve) => {
        ws.on('message', (data) => {
          const message = JSON.parse(data);
          if (message.type === 'inventory_update') {
            resolve(message.data);
          }
        });
      });

      expect(messageReceived).toBeDefined();
      expect(messageReceived.center_id).toBe(1);
      ws.close();
    });
  });

  describe('Analytics API', () => {
    test('GET /api/analytics/sales - should return sales analytics', async () => {
      const response = await request(app)
        .get('/api/analytics/sales?period=Last%2030%20Days')
        .set('Authorization', 'Bearer test-token')
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.summary).toBeDefined();
      expect(response.body.data.chart_data).toBeDefined();
    });

    test('GET /api/analytics/marketing - should return marketing analytics', async () => {
      const response = await request(app)
        .get('/api/analytics/marketing?period=Last%2030%20Days')
        .set('Authorization', 'Bearer test-token')
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.campaigns).toBeDefined();
    });
  });

  describe('Error Handling', () => {
    test('Invalid authentication - should return 401', async () => {
      const response = await request(app)
        .get('/api/distribution/centers')
        .expect(401);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('authentication');
    });

    test('Invalid data - should return 400', async () => {
      const invalidData = {
        name: '',
        code: '',
        // Missing required fields
      };

      const response = await request(app)
        .post('/api/distribution/centers')
        .set('Authorization', 'Bearer test-token')
        .send(invalidData)
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toBeDefined();
    });

    test('Database error - should return 500', async () => {
      // Mock database error
      jest.spyOn(prisma, '$queryRaw').mockRejectedValue(new Error('Database connection failed'));

      const response = await request(app)
        .get('/api/distribution/centers')
        .set('Authorization', 'Bearer test-token')
        .expect(500);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('Server error');
    });
  });

  describe('Performance Tests', () => {
    test('Large dataset - should handle pagination efficiently', async () => {
      const startTime = Date.now();
      
      const response = await request(app)
        .get('/api/distribution/centers?page=1&limit=100')
        .set('Authorization', 'Bearer test-token')
        .expect(200);

      const endTime = Date.now();
      const responseTime = endTime - startTime;

      expect(responseTime).toBeLessThan(2000); // Should respond within 2 seconds
      expect(response.body.data.centers.length).toBeLessThanOrEqual(100);
    });

    test('Concurrent requests - should handle multiple requests', async () => {
      const requests = Array(10).fill(null).map(() =>
        request(app)
          .get('/api/distribution/centers')
          .set('Authorization', 'Bearer test-token')
      );

      const responses = await Promise.all(requests);

      responses.forEach((response) => {
        expect(response.status).toBe(200);
        expect(response.body.success).toBe(true);
      });
    });
  });

  describe('Data Integrity', () => {
    test('Foreign key constraints - should maintain referential integrity', async () => {
      // Create center
      const centerResponse = await request(app)
        .post('/api/distribution/centers')
        .set('Authorization', 'Bearer test-token')
        .send({
          name: 'Test Center',
          code: 'FK_TEST',
          address: '123 Test Street',
          city: 'Test City',
          state: 'Test State',
          postal_code: '12345',
          capacity: 1000
        })
        .expect(201);

      const centerId = centerResponse.body.data.id;

      // Create inventory allocation referencing the center
      const allocationResponse = await request(app)
        .post('/api/distribution/inventory/allocate')
        .set('Authorization', 'Bearer test-token')
        .send({
          product_id: 1,
          center_id: centerId,
          quantity: 100
        })
        .expect(201);

      // Verify allocation references the correct center
      const getAllocationResponse = await request(app)
        .get(`/api/distribution/inventory/${centerId}`)
        .set('Authorization', 'Bearer test-token')
        .expect(200);

      expect(getAllocationResponse.body.data.allocations[0].center_id).toBe(centerId);
    });

    test('Data validation - should enforce business rules', async () => {
      // Test negative quantity
      const invalidAllocation = {
        product_id: 1,
        center_id: 1,
        quantity: -100
      };

      const response = await request(app)
        .post('/api/distribution/inventory/allocate')
        .set('Authorization', 'Bearer test-token')
        .send(invalidAllocation)
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('quantity');
    });
  });

  async function setupTestData() {
    // Create test distribution center
    await prisma.$queryRaw`
      INSERT INTO distribution_centers (name, code, address, city, state, postal_code, country, capacity, is_active, created_at, updated_at)
      VALUES ('Test Center', 'TEST001', '123 Test Street', 'Test City', 'Test State', '12345', 'India', 1000, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
    `;

    // Create test inventory item
    await prisma.$queryRaw`
      INSERT INTO inventory_items (item_name, mrp, stock_quantity, is_active, created_at, updated_at)
      VALUES ('Test Product', 100.0, 1000, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
    `;

    console.log('Test data setup completed');
  }
});

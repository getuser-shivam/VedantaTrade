import request from 'supertest';
import express from 'express';
import { PrismaClient } from '@prisma/client';
import WebSocket from 'ws';

const app = express();
const prisma = new PrismaClient();

describe('Distribution System Integration Tests', () => {
  let server: any;
  let wsServer: WebSocket.Server;
  let testToken: string;
  let centerId: number;
  let productId: number;
  let campaignId: number;

  beforeAll(async () => {
    // Start test server
    server = app.listen(3002);
    
    // Start WebSocket server for testing
    wsServer = new WebSocket.Server({ port: 3003 });
    
    // Create test token
    testToken = 'test-jwt-token';
  });

  afterAll(async () => {
    server?.close();
    wsServer?.close();
    await prisma.$disconnect();
  });

  describe('End-to-End Distribution Workflow', () => {

    test('Complete distribution center lifecycle', async () => {
      // 1. Create distribution center
      const centerResponse = await request(app)
        .post('/api/distribution/centers')
        .set('Authorization', `Bearer ${testToken}`)
        .send({
          name: 'Integration Test Center',
          code: 'ITC001',
          address: '123 Integration Street',
          city: 'Test City',
          state: 'Test State',
          postal_code: '12345',
          capacity: 10000
        })
        .expect(201);

      expect(centerResponse.body.success).toBe(true);
      centerId = centerResponse.body.data.id;

      // 2. Verify center was created
      const getResponse = await request(app)
        .get(`/api/distribution/centers/${centerId}`)
        .set('Authorization', `Bearer ${testToken}`)
        .expect(200);

      expect(getResponse.body.data.name).toBe('Integration Test Center');

      // 3. Update center
      await request(app)
        .put(`/api/distribution/centers/${centerId}`)
        .set('Authorization', `Bearer ${testToken}`)
        .send({
          capacity: 15000,
          manager_name: 'Updated Manager'
        })
        .expect(200);

      // 4. Verify update
      const updatedResponse = await request(app)
        .get(`/api/distribution/centers/${centerId}`)
        .set('Authorization', `Bearer ${testToken}`)
        .expect(200);

      expect(updatedResponse.body.data.capacity).toBe(15000);
      expect(updatedResponse.body.data.manager_name).toBe('Updated Manager');
    });

    test('Complete inventory allocation workflow', async () => {
      // 1. Create test product
      const productResult = await prisma.$executeRaw`
        INSERT INTO inventory_items 
        (item_name, generic_name, stock_quantity, is_active, created_at, updated_at)
        VALUES ('Integration Test Product', 'Test Generic', 1000, 1, GETDATE(), GETDATE())
      `;
      productId = (productResult as any).insertId;

      // 2. Allocate inventory to center
      const allocationResponse = await request(app)
        .post('/api/distribution/inventory/allocate')
        .set('Authorization', `Bearer ${testToken}`)
        .send({
          product_id: productId,
          center_id: centerId,
          quantity: 500
        })
        .expect(201);

      expect(allocationResponse.body.success).toBe(true);

      // 3. Verify allocation
      const inventoryResponse = await request(app)
        .get(`/api/distribution/inventory/${centerId}`)
        .set('Authorization', `Bearer ${testToken}`)
        .expect(200);

      expect(inventoryResponse.body.data.allocations).toHaveLength(1);
      expect(inventoryResponse.body.data.allocations[0].quantity_available).toBe(500);

      // 4. Create second center for transfer test
      const center2Response = await request(app)
        .post('/api/distribution/centers')
        .set('Authorization', `Bearer ${testToken}`)
        .send({
          name: 'Integration Test Center 2',
          code: 'ITC002',
          address: '456 Integration Street',
          city: 'Test City 2',
          state: 'Test State 2',
          postal_code: '12346',
          capacity: 8000
        })
        .expect(201);

      const center2Id = center2Response.body.data.id;

      // 5. Transfer inventory between centers
      const transferResponse = await request(app)
        .post('/api/distribution/inventory/transfer')
        .set('Authorization', `Bearer ${testToken}`)
        .send({
          product_id: productId,
          from_center_id: centerId,
          to_center_id: center2Id,
          quantity: 200
        })
        .expect(201);

      expect(transferResponse.body.success).toBe(true);

      // 6. Verify transfer results
      const updatedInventory1 = await request(app)
        .get(`/api/distribution/inventory/${centerId}`)
        .set('Authorization', `Bearer ${testToken}`)
        .expect(200);

      expect(updatedInventory1.body.data.allocations[0].quantity_available).toBe(300);

      const updatedInventory2 = await request(app)
        .get(`/api/distribution/inventory/${center2Id}`)
        .set('Authorization', `Bearer ${testToken}`)
        .expect(200);

      expect(updatedInventory2.body.data.allocations[0].quantity_available).toBe(200);
    });

    test('Complete marketing campaign workflow', async () => {
      // 1. Create marketing campaign
      const campaignResponse = await request(app)
        .post('/api/marketing/campaigns')
        .set('Authorization', `Bearer ${testToken}`)
        .send({
          name: 'Integration Test Campaign',
          description: 'Test campaign for integration',
          start_date: '2024-01-01',
          end_date: '2024-12-31',
          budget: 75000,
          target_audience: 'Integration test audience',
          products: [
            {
              product_id: productId,
              discount_percentage: 20,
              special_price: 80
            }
          ]
        })
        .expect(201);

      expect(campaignResponse.body.success).toBe(true);
      campaignId = campaignResponse.body.data.id;

      // 2. Verify campaign creation
      const getCampaignResponse = await request(app)
        .get(`/api/marketing/campaigns/${campaignId}`)
        .set('Authorization', `Bearer ${testToken}`)
        .expect(200);

      expect(getCampaignResponse.body.data.name).toBe('Integration Test Campaign');
      expect(getCampaignResponse.body.data.products).toHaveLength(1);

      // 3. Add another product to campaign
      const product2Result = await prisma.$executeRaw`
        INSERT INTO inventory_items 
        (item_name, generic_name, stock_quantity, is_active, created_at, updated_at)
        VALUES ('Integration Test Product 2', 'Test Generic 2', 800, 1, GETDATE(), GETDATE())
      `;
      const product2Id = (product2Result as any).insertId;

      await request(app)
        .post(`/api/marketing/campaigns/${campaignId}/products`)
        .set('Authorization', `Bearer ${testToken}`)
        .send({
          product_id: product2Id,
          discount_percentage: 15,
          special_price: 85
        })
        .expect(201);

      // 4. Verify campaign has two products
      const updatedCampaignResponse = await request(app)
        .get(`/api/marketing/campaigns/${campaignId}`)
        .set('Authorization', `Bearer ${testToken}`)
        .expect(200);

      expect(updatedCampaignResponse.body.data.products).toHaveLength(2);

      // 5. Record marketing metrics
      await request(app)
        .post('/api/marketing/metrics')
        .set('Authorization', `Bearer ${testToken}`)
        .send({
          campaign_id: campaignId,
          metric_type: 'IMPRESSIONS',
          metric_value: 10000
        })
        .expect(201);

      await request(app)
        .post('/api/marketing/metrics')
        .set('Authorization', `Bearer ${testToken}`)
        .send({
          campaign_id: campaignId,
          metric_type: 'CLICKS',
          metric_value: 500
        })
        .expect(201);

      // 6. Verify analytics data
      const analyticsResponse = await request(app)
        .get('/api/marketing/analytics')
        .set('Authorization', `Bearer ${testToken}`)
        .expect(200);

      expect(analyticsResponse.body.success).toBe(true);
      expect(analyticsResponse.body.data.campaign_analytics).toBeDefined();
      expect(analyticsResponse.body.data.metrics_breakdown).toBeDefined();
    });
  });

  describe('Real-time Updates Integration', () => {
    test('WebSocket connection and inventory updates', (done) => {
      let ws: WebSocket;
      let messageReceived = false;

      // Connect to WebSocket
      ws = new WebSocket('ws://localhost:3003?token=' + testToken);

      ws.on('open', () => {
        // Subscribe to inventory updates
        ws.send(JSON.stringify({
          type: 'subscribe',
          channels: ['inventory']
        }));
      });

      ws.on('message', (data: any) => {
        const message = JSON.parse(data.toString());
        
        if (message.type === 'subscription_confirmed') {
          // Trigger inventory update
          request(app)
            .post('/api/distribution/inventory/allocate')
            .set('Authorization', `Bearer ${testToken}`)
            .send({
              product_id: productId,
              center_id: centerId,
              quantity: 50
            });
        } else if (message.type === 'inventory_update' && !messageReceived) {
          messageReceived = true;
          expect(message.data).toBeDefined();
          ws.close();
          done();
        }
      });

      ws.on('error', (error: any) => {
        console.error('WebSocket error:', error);
        done(error);
      });

      // Timeout after 10 seconds
      setTimeout(() => {
        if (!messageReceived) {
          ws.close();
          done(new Error('WebSocket message not received within timeout'));
        }
      }, 10000);
    });

    test('WebSocket campaign updates', (done) => {
      let ws: WebSocket;
      let messageReceived = false;

      ws = new WebSocket('ws://localhost:3003?token=' + testToken);

      ws.on('open', () => {
        ws.send(JSON.stringify({
          type: 'subscribe',
          channels: ['campaigns']
        }));
      });

      ws.on('message', (data: any) => {
        const message = JSON.parse(data.toString());
        
        if (message.type === 'campaign_update' && !messageReceived) {
          messageReceived = true;
          expect(message.data).toBeDefined();
          ws.close();
          done();
        }
      });

      setTimeout(() => {
        if (!messageReceived) {
          ws.close();
          done(new Error('Campaign update not received'));
        }
      }, 10000);
    });
  });

  describe('Analytics Integration', () => {
    test('Sales analytics with campaign attribution', async () => {
      // Create sales analytics data
      await prisma.$executeRaw`
        INSERT INTO sales_analytics 
        (campaign_id, product_id, center_id, sales_quantity, revenue, cost, profit, analytics_date, created_at, updated_at)
        VALUES (${campaignId}, ${productId}, ${centerId}, 100, 8000, 6000, 2000, GETDATE(), GETDATE(), GETDATE())
      `;

      const response = await request(app)
        .get('/api/analytics/sales')
        .query({ campaign_id: campaignId })
        .set('Authorization', `Bearer ${testToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.sales_data).toBeDefined();
      expect(response.body.data.summary.total_revenue).toBe(8000);
    });

    test('Inventory analytics with alerts', async () => {
      // Create low stock situation
      await prisma.$executeRaw`
        UPDATE inventory_allocations 
        SET quantity_available = 10 
        WHERE product_id = ${productId} AND center_id = ${centerId}
      `;

      const response = await request(app)
        .get('/api/inventory/alerts')
        .set('Authorization', `Bearer ${testToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.alerts.length).toBeGreaterThan(0);
    });

    test('Export functionality', async () => {
      const response = await request(app)
        .get('/api/analytics/export')
        .query({ 
          type: 'sales', 
          format: 'csv',
          campaign_id: campaignId 
        })
        .set('Authorization', `Bearer ${testToken}`)
        .expect(200);

      expect(response.headers['content-type']).toContain('text/csv');
      expect(response.headers['content-disposition']).toContain('attachment');
      expect(response.text).toContain('analytics_date');
    });
  });

  describe('Performance and Load Testing', () => {
    test('Concurrent inventory allocations', async () => {
      const allocations = Array(20).fill(null).map((_, index) => ({
        product_id: productId,
        center_id: centerId,
        quantity: 10 + index
      }));

      const startTime = Date.now();
      
      const promises = allocations.map(allocation =>
        request(app)
          .post('/api/distribution/inventory/allocate')
          .set('Authorization', `Bearer ${testToken}`)
          .send(allocation)
      );

      const responses = await Promise.all(promises);
      const endTime = Date.now();
      const totalTime = endTime - startTime;

      // All requests should complete within reasonable time
      expect(totalTime).toBeLessThan(5000);
      
      // Check success rate
      const successfulResponses = responses.filter((r: any) => r.status === 201);
      expect(successfulResponses.length).toBeGreaterThan(0);
    });

    test('Large dataset pagination', async () => {
      // Create many test centers
      const centerPromises = Array(50).fill(null).map((_, index) =>
        request(app)
          .post('/api/distribution/centers')
          .set('Authorization', `Bearer ${testToken}`)
          .send({
            name: `Load Test Center ${index}`,
            code: `LTC${index.toString().padStart(3, '0')}`,
            address: `${index} Load Test Street`,
            city: 'Load Test City',
            state: 'Load Test State',
            postal_code: `${12340 + index}`,
            capacity: 5000
          })
      );

      await Promise.all(centerPromises);

      // Test pagination
      const response = await request(app)
        .get('/api/distribution/centers')
        .query({ page: 1, limit: 20 })
        .set('Authorization', `Bearer ${testToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.centers.length).toBe(20);
      expect(response.body.data.pagination.total).toBeGreaterThan(50);
      expect(response.body.data.pagination.pages).toBeGreaterThan(2);
    });
  });

  describe('Error Recovery and Edge Cases', () => {
    test('Database connection recovery', async () => {
      // Simulate temporary database issue
      // This would require mocking database connection
      // For now, test proper error handling
      
      const response = await request(app)
        .get('/api/distribution/centers')
        .set('Authorization', `Bearer ${testToken}`)
        .expect(500);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toBeDefined();
    });

    test('WebSocket reconnection', (done) => {
      let reconnectionAttempts = 0;
      let ws: WebSocket;

      const connectWebSocket = () => {
        ws = new WebSocket('ws://localhost:3003?token=' + testToken);

        ws.on('open', () => {
          if (reconnectionAttempts === 0) {
            // Simulate connection loss
            ws.close();
          } else {
            // Reconnection successful
            expect(reconnectionAttempts).toBeGreaterThan(0);
            ws.close();
            done();
          }
        });

        ws.on('close', () => {
          reconnectionAttempts++;
          if (reconnectionAttempts < 3) {
            setTimeout(connectWebSocket, 1000);
          }
        });

        ws.on('error', (error: any) => {
          console.error('WebSocket error during reconnection test:', error);
        });
      };

      connectWebSocket();
    });

    test('Data consistency under concurrent operations', async () => {
      // Perform multiple concurrent operations on same resource
      const concurrentOperations = Array(10).fill(null).map(() =>
        request(app)
          .put(`/api/distribution/centers/${centerId}`)
          .set('Authorization', `Bearer ${testToken}`)
          .send({
            capacity: Math.floor(Math.random() * 10000) + 5000
          })
      );

      const responses = await Promise.all(concurrentOperations);
      
      // All operations should complete without data corruption
      const finalResponse = await request(app)
        .get(`/api/distribution/centers/${centerId}`)
        .set('Authorization', `Bearer ${testToken}`)
        .expect(200);

      expect(finalResponse.body.data.capacity).toBeGreaterThan(0);
      expect(finalResponse.body.data.capacity).toBeLessThan(20000);
    });
  });

  describe('Security Integration', () => {
    test('Authentication bypass attempts', async () => {
      // Test various authentication bypass attempts
      const unauthorizedRequests = [
        request(app).get('/api/distribution/centers'),
        request(app).get('/api/distribution/centers').set('Authorization', 'Bearer invalid'),
        request(app).get('/api/distribution/centers').set('Authorization', 'Basic invalid'),
        request(app).get('/api/distribution/centers').set('X-API-Key', 'invalid')
      ];

      const responses = await Promise.all(unauthorizedRequests);
      
      responses.forEach((response: any) => {
        expect(response.status).toBe(401);
        expect(response.body.success).toBe(false);
      });
    });

    test('SQL injection protection', async () => {
      const maliciousInputs = [
        "'; DROP TABLE distribution_centers; --",
        "1' OR '1'='1",
        "UNION SELECT * FROM users --"
      ];

      for (const input of maliciousInputs) {
        const response = await request(app)
          .get(`/api/distribution/centers?search=${encodeURIComponent(input)}`)
          .set('Authorization', `Bearer ${testToken}`)
          .expect(400);

        expect(response.body.success).toBe(false);
      }
    });

    test('Rate limiting', async () => {
      // Make many rapid requests
      const rapidRequests = Array(100).fill(null).map(() =>
        request(app)
          .get('/api/distribution/centers')
          .set('Authorization', `Bearer ${testToken}`)
      );

      const responses = await Promise.all(rapidRequests);
      
      // Some requests should be rate limited
      const rateLimitedResponses = responses.filter((r: any) => r.status === 429);
      expect(rateLimitedResponses.length).toBeGreaterThan(0);
    });
  });
});

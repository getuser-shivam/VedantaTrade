import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:vedanta_trade/features/distribution/data/models/sales_model.dart';
import 'package:vedanta_trade/features/distribution/data/models/inventory_model.dart';
import 'package:vedanta_trade/features/distribution/data/models/marketing_model.dart';
import 'package:vedanta_trade/features/distribution/data/models/crm_model.dart';
import 'package:vedanta_trade/features/distribution/data/models/distribution_model.dart';

// Generate mocks
@GenerateMocks([
  SalesService,
  InventoryService,
  MarketingService,
  CRMService,
  DistributionService,
  ReportService,
])
import 'distribution_system_test.mocks.dart';

void main() {
  group('Distribution System Tests', () {
    group('Sales Model Tests', () {
      test('SalesOrder should create from JSON correctly', () {
        final json = {
          'id': '1',
          'orderNumber': 'ORD-001',
          'customerId': 'CUST-001',
          'customerName': 'Test Customer',
          'customerEmail': 'test@example.com',
          'customerPhone': '+977-1234567890',
          'items': [
            {
              'id': '1',
              'productId': 'PROD-001',
              'productName': 'Test Product',
              'productGenericName': 'Test Generic',
              'productManufacturer': 'Test Manufacturer',
              'productCategory': 'Test Category',
              'productStrength': '500mg',
              'productDosageForm': 'Tablet',
              'unitPrice': 100.0,
              'quantity': 10,
              'discountAmount': 10.0,
              'taxRate': 13.0,
              'taxAmount': 117.0,
              'totalPrice': 1070.0,
              'batchNumber': 'BATCH001',
              'expiryDate': '2024-12-31T00:00:00.000Z',
              'isPrescriptionRequired': false,
            }
          ],
          'totalAmount': 1000.0,
          'discountAmount': 10.0,
          'taxAmount': 117.0,
          'finalAmount': 1107.0,
          'status': 'confirmed',
          'paymentStatus': 'paid',
          'paymentMethod': 'bank_transfer',
          'orderDate': '2024-01-01T00:00:00.000Z',
          'shippingAddress': 'Test Address',
          'billingAddress': 'Test Address',
          'salesRepresentativeName': 'Test Rep',
          'distributionChannel': 'wholesale',
          'deliveryMethod': 'standard',
          'deliveryCost': 50.0,
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        };

        final order = SalesOrder.fromJson(json);

        expect(order.id, '1');
        expect(order.orderNumber, 'ORD-001');
        expect(order.customerName, 'Test Customer');
        expect(order.finalAmount, 1107.0);
        expect(order.status, 'confirmed');
        expect(order.items.length, 1);
        expect(order.items.first.productName, 'Test Product');
      });

      test('SalesOrder should compute properties correctly', () {
        final order = SalesOrder(
          id: '1',
          orderNumber: 'ORD-001',
          customerId: 'CUST-001',
          customerName: 'Test Customer',
          customerEmail: 'test@example.com',
          customerPhone: '+977-1234567890',
          items: [],
          totalAmount: 1000.0,
          discountAmount: 10.0,
          taxAmount: 117.0,
          finalAmount: 1107.0,
          status: 'pending',
          paymentStatus: 'pending',
          paymentMethod: 'bank_transfer',
          orderDate: DateTime.now(),
          expectedDeliveryDate: DateTime.now().subtract(const Duration(days: 1)),
          shippingAddress: 'Test Address',
          billingAddress: 'Test Address',
          salesRepresentativeName: 'Test Rep',
          distributionChannel: 'wholesale',
          deliveryMethod: 'standard',
          deliveryCost: 50.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(order.isPending, true);
        expect(order.isConfirmed, false);
        expect(order.isOverdue, true);
        expect(order.totalQuantity, 0);
      });

      test('SalesOrderItem should create from JSON correctly', () {
        final json = {
          'id': '1',
          'productId': 'PROD-001',
          'productName': 'Test Product',
          'productGenericName': 'Test Generic',
          'productManufacturer': 'Test Manufacturer',
          'productCategory': 'Test Category',
          'productStrength': '500mg',
          'productDosageForm': 'Tablet',
          'unitPrice': 100.0,
          'quantity': 10,
          'discountPercentage': 10.0,
          'discountAmount': 100.0,
          'taxRate': 13.0,
          'taxAmount': 117.0,
          'totalPrice': 1017.0,
          'batchNumber': 'BATCH001',
          'expiryDate': '2024-12-31T00:00:00.000Z',
          'isPrescriptionRequired': false,
        };

        final item = SalesOrderItem.fromJson(json);

        expect(item.id, '1');
        expect(item.productName, 'Test Product');
        expect(item.quantity, 10);
        expect(item.totalPrice, 1017.0);
        expect(item.isPrescriptionRequired, false);
      });

      test('SalesAnalytics should create from JSON correctly', () {
        final json = {
          'id': '1',
          'period': '2024-01-01T00:00:00.000Z',
          'periodType': 'monthly',
          'totalRevenue': 100000.0,
          'totalOrders': 100.0,
          'averageOrderValue': 1000.0,
          'totalCustomers': 50,
          'newCustomers': 10,
          'returningCustomers': 40,
          'revenueByCategory': {'Analgesics': 50000.0, 'Antibiotics': 50000.0},
          'revenueByChannel': {'wholesale': 60000.0, 'retail': 40000.0},
          'ordersByStatus': {'confirmed': 80, 'processing': 20},
          'topSellingProducts': ['Product A', 'Product B'],
          'topCustomers': ['Customer A', 'Customer B'],
          'conversionRate': 5.0,
          'customerRetentionRate': 80.0,
          'averageOrderProcessingTime': 2.5,
          'onTimeDeliveryRate': 95.0,
          'customerSatisfactionScore': 4.5,
          'salesByRegion': {'Kathmandu': 60000.0, 'Pokhara': 40000.0},
          'salesBySalesRep': {'Rep A': 60000.0, 'Rep B': 40000.0},
          'totalDiscounts': 5000.0,
          'totalReturns': 1000.0,
          'returnRate': 1.0,
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        };

        final analytics = SalesAnalytics.fromJson(json);

        expect(analytics.totalRevenue, 100000.0);
        expect(analytics.totalOrders, 100.0);
        expect(analytics.averageOrderValue, 1000.0);
        expect(analytics.conversionRate, 5.0);
        expect(analytics.revenueByCategory['Analgesics'], 50000.0);
      });
    });

    group('Inventory Model Tests', () {
      test('Inventory should create from JSON correctly', () {
        final json = {
          'id': '1',
          'productId': 'PROD-001',
          'productName': 'Test Product',
          'productGenericName': 'Test Generic',
          'productCategory': 'Test Category',
          'productManufacturer': 'Test Manufacturer',
          'productStrength': '500mg',
          'productDosageForm': 'Tablet',
          'warehouseId': 'WH-001',
          'warehouseName': 'Main Warehouse',
          'warehouseLocation': 'Kathmandu',
          'currentStock': 100,
          'reservedStock': 10,
          'availableStock': 90,
          'minimumStock': 20,
          'maximumStock': 500,
          'reorderPoint': 25,
          'reorderQuantity': 100,
          'unitCost': 50.0,
          'totalValue': 5000.0,
          'batchNumber': 'BATCH001',
          'manufactureDate': '2024-01-01T00:00:00.000Z',
          'expiryDate': '2024-12-31T00:00:00.000Z',
          'storageConditions': 'Room temperature',
          'storageLocation': 'A1-B2',
          'supplierId': 'SUP-001',
          'supplierName': 'Test Supplier',
          'lastRestockDate': '2024-01-01T00:00:00.000Z',
          'daysOfStock': 30,
          'turnoverRate': 2.5,
          'status': 'active',
          'transactions': [],
          'stockMovements': [],
          'qualityCheckStatus': 'passed',
          'lastQualityCheck': '2024-01-01T00:00:00.000Z',
          'alerts': [],
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        };

        final inventory = Inventory.fromJson(json);

        expect(inventory.id, '1');
        expect(inventory.productName, 'Test Product');
        expect(inventory.currentStock, 100);
        expect(inventory.availableStock, 90);
        expect(inventory.unitCost, 50.0);
        expect(inventory.totalValue, 5000.0);
      });

      test('Inventory should compute properties correctly', () {
        final inventory = Inventory(
          id: '1',
          productId: 'PROD-001',
          productName: 'Test Product',
          productGenericName: 'Test Generic',
          productCategory: 'Test Category',
          productManufacturer: 'Test Manufacturer',
          productStrength: '500mg',
          productDosageForm: 'Tablet',
          warehouseId: 'WH-001',
          warehouseName: 'Main Warehouse',
          warehouseLocation: 'Kathmandu',
          currentStock: 15,
          reservedStock: 5,
          availableStock: 10,
          minimumStock: 20,
          maximumStock: 500,
          reorderPoint: 25,
          reorderQuantity: 100,
          unitCost: 50.0,
          totalValue: 750.0,
          batchNumber: 'BATCH001',
          manufactureDate: DateTime.now().subtract(const Duration(days: 30)),
          expiryDate: DateTime.now().subtract(const Duration(days: 1)),
          storageConditions: 'Room temperature',
          storageLocation: 'A1-B2',
          supplierId: 'SUP-001',
          supplierName: 'Test Supplier',
          lastRestockDate: DateTime.now(),
          daysOfStock: 30,
          turnoverRate: 2.5,
          status: 'active',
          transactions: [],
          stockMovements: [],
          qualityCheckStatus: 'passed',
          lastQualityCheck: DateTime.now(),
          alerts: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(inventory.isLowStock, true);
        expect(inventory.isOutOfStock, false);
        expect(inventory.isExpired, true);
        expect(inventory.needsReorder, true);
        expect(inventory.hasQualityIssues, false);
      });

      test('InventoryTransaction should create from JSON correctly', () {
        final json = {
          'id': '1',
          'inventoryId': 'INV-001',
          'transactionType': 'in',
          'quantity': 100,
          'unitCost': 50.0,
          'totalCost': 5000.0,
          'referenceType': 'purchase',
          'referenceId': 'PO-001',
          'referenceNumber': 'PO-001',
          'reason': 'Stock replenishment',
          'performedBy': 'USER-001',
          'performedByName': 'Test User',
          'transactionDate': '2024-01-01T00:00:00.000Z',
          'fromLocation': 'Supplier',
          'toLocation': 'Warehouse',
          'batchNumber': 'BATCH001',
          'expiryDate': '2024-12-31T00:00:00.000Z',
          'status': 'completed',
          'createdAt': '2024-01-01T00:00:00.000Z',
        };

        final transaction = InventoryTransaction.fromJson(json);

        expect(transaction.id, '1');
        expect(transaction.transactionType, 'in');
        expect(transaction.quantity, 100);
        expect(transaction.totalCost, 5000.0);
        expect(transaction.status, 'completed');
      });

      test('Warehouse should create from JSON correctly', () {
        final json = {
          'id': '1',
          'name': 'Main Warehouse',
          'code': 'WH-001',
          'type': 'main',
          'location': 'Kathmandu',
          'address': 'Test Address',
          'city': 'Kathmandu',
          'state': 'Bagmati',
          'country': 'Nepal',
          'postalCode': '44600',
          'capacity': 10000.0,
          'currentUtilization': 7500.0,
          'managerId': 'MGR-001',
          'managerName': 'Test Manager',
          'managerEmail': 'manager@test.com',
          'managerPhone': '+977-1234567890',
          'operatingHours': ['9:00-17:00'],
          'isActive': true,
          'isClimateControlled': true,
          'temperature': 25.0,
          'humidity': 60.0,
          'certifications': ['ISO 9001'],
          'specializations': ['Pharmaceuticals'],
          'establishedDate': '2020-01-01T00:00:00.000Z',
          'status': 'active',
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        };

        final warehouse = Warehouse.fromJson(json);

        expect(warehouse.id, '1');
        expect(warehouse.name, 'Main Warehouse');
        expect(warehouse.capacity, 10000.0);
        expect(warehouse.currentUtilization, 7500.0);
        expect(warehouse.isActive, true);
        expect(warehouse.utilizationRate, 75.0);
      });
    });

    group('Marketing Model Tests', () {
      test('MarketingCampaign should create from JSON correctly', () {
        final json = {
          'id': '1',
          'name': 'Test Campaign',
          'description': 'Test Description',
          'type': 'email',
          'category': 'promotional',
          'status': 'active',
          'startDate': '2024-01-01T00:00:00.000Z',
          'endDate': '2024-01-31T00:00:00.000Z',
          'targetAudience': 'General',
          'targetRegions': ['Kathmandu'],
          'targetProducts': ['PROD-001'],
          'targetCustomerSegments': ['Retail'],
          'budget': 10000.0,
          'actualCost': 8500.0,
          'currency': 'NPR',
          'objectives': [],
          'keyMessages': ['Test Message'],
          'creativeAssets': ['Asset1'],
          'channels': ['Email'],
          'campaignManagerId': 'MGR-001',
          'campaignManagerName': 'Test Manager',
          'teamMembers': ['TEAM-001'],
          'performanceMetrics': {'impressions': 10000},
          'milestones': [],
          'approvalStatus': 'approved',
          'approvedBy': 'APPROVER-001',
          'approvedDate': '2024-01-01T00:00:00.000Z',
          'tags': ['test'],
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        };

        final campaign = MarketingCampaign.fromJson(json);

        expect(campaign.id, '1');
        expect(campaign.name, 'Test Campaign');
        expect(campaign.type, 'email');
        expect(campaign.status, 'active');
        expect(campaign.budget, 10000.0);
        expect(campaign.actualCost, 8500.0);
      });

      test('MarketingCampaign should compute properties correctly', () {
        final campaign = MarketingCampaign(
          id: '1',
          name: 'Test Campaign',
          description: 'Test Description',
          type: 'email',
          category: 'promotional',
          status: 'active',
          startDate: DateTime.now().subtract(const Duration(days: 5)),
          endDate: DateTime.now().add(const Duration(days: 25)),
          targetAudience: 'General',
          targetRegions: ['Kathmandu'],
          targetProducts: ['PROD-001'],
          targetCustomerSegments: ['Retail'],
          budget: 10000.0,
          actualCost: 8500.0,
          objectives: [],
          keyMessages: ['Test Message'],
          creativeAssets: ['Asset1'],
          channels: ['Email'],
          campaignManagerId: 'MGR-001',
          campaignManagerName: 'Test Manager',
          teamMembers: ['TEAM-001'],
          performanceMetrics: {'impressions': 10000},
          milestones: [],
          approvalStatus: 'approved',
          approvedBy: 'APPROVER-001',
          approvedDate: DateTime.now(),
          tags: ['test'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(campaign.isActive, true);
        expect(campaign.isRunning, true);
        expect(campaign.isOverBudget, false);
        expect(campaign.budgetUtilization, 85.0);
        expect(campaign.daysRemaining, 25);
        expect(campaign.daysElapsed, 5);
      });

      test('Promotion should create from JSON correctly', () {
        final json = {
          'id': '1',
          'name': 'Test Promotion',
          'description': 'Test Description',
          'type': 'discount',
          'discountType': 'percentage',
          'discountValue': 10.0,
          'currency': 'NPR',
          'applicableProducts': ['PROD-001'],
          'applicableCategories': ['Analgesics'],
          'applicableCustomers': ['CUST-001'],
          'excludedProducts': [],
          'startDate': '2024-01-01T00:00:00.000Z',
          'endDate': '2024-01-31T00:00:00.000Z',
          'minimumQuantity': 5,
          'minimumAmount': 100.0,
          'maximumUses': 100,
          'currentUses': 25,
          'status': 'active',
          'promoCode': 'TEST10',
          'isAutoApplied': false,
          'isStackable': false,
          'maxDiscountAmount': 500.0,
          'conditions': ['Minimum purchase 100 NPR'],
          'createdBy': 'USER-001',
          'createdByName': 'Test User',
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        };

        final promotion = Promotion.fromJson(json);

        expect(promotion.id, '1');
        expect(promotion.name, 'Test Promotion');
        expect(promotion.type, 'discount');
        expect(promotion.discountValue, 10.0);
        expect(promotion.currentUses, 25);
        expect(promotion.isActive, true);
      });

      test('Promotion should calculate discount correctly', () {
        final promotion = Promotion(
          id: '1',
          name: 'Test Promotion',
          description: 'Test Description',
          type: 'discount',
          discountType: 'percentage',
          discountValue: 10.0,
          applicableProducts: ['PROD-001'],
          applicableCategories: ['Analgesics'],
          applicableCustomers: ['CUST-001'],
          excludedProducts: [],
          startDate: DateTime.now().subtract(const Duration(days: 5)),
          endDate: DateTime.now().add(const Duration(days: 25)),
          minimumQuantity: 5,
          minimumAmount: 100.0,
          maximumUses: 100,
          currentUses: 25,
          status: 'active',
          promoCode: 'TEST10',
          isAutoApplied: false,
          isStackable: false,
          maxDiscountAmount: 500.0,
          conditions: ['Minimum purchase 100 NPR'],
          createdBy: 'USER-001',
          createdByName: 'Test User',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Test valid discount
        final discount1 = promotion.calculateDiscount(1000.0, 10);
        expect(discount1, 100.0);

        // Test below minimum quantity
        final discount2 = promotion.calculateDiscount(1000.0, 3);
        expect(discount2, 0.0);

        // Test below minimum amount
        final discount3 = promotion.calculateDiscount(50.0, 10);
        expect(discount3, 0.0);

        // Test max discount limit
        final discount4 = promotion.calculateDiscount(10000.0, 10);
        expect(discount4, 500.0);
      });
    });

    group('CRM Model Tests', () {
      test('Customer should create from JSON correctly', () {
        final json = {
          'id': '1',
          'customerCode': 'CUST-001',
          'businessName': 'Test Business',
          'businessType': 'pharmacy',
          'legalName': 'Test Legal Name',
          'tradeLicenseNumber': 'TL-001',
          'taxRegistrationNumber': 'TRN-001',
          'drugLicenseNumber': 'DLN-001',
          'contactPerson': 'Test Contact',
          'contactEmail': 'contact@test.com',
          'contactPhone': '+977-1234567890',
          'address': 'Test Address',
          'city': 'Kathmandu',
          'state': 'Bagmati',
          'country': 'Nepal',
          'postalCode': '44600',
          'region': 'Central',
          'territory': 'Kathmandu',
          'specializations': ['General'],
          'productCategories': ['Analgesics'],
          'customerTier': 'gold',
          'status': 'active',
          'registrationDate': '2024-01-01T00:00:00.000Z',
          'lastPurchaseDate': '2024-01-15T00:00:00.000Z',
          'lastContactDate': '2024-01-10T00:00:00.000Z',
          'totalPurchases': 10000.0,
          'totalOrders': 10,
          'averageOrderValue': 1000.0,
          'creditLimit': 5000.0,
          'currentCredit': 2000.0,
          'paymentTerms': 'NET 30',
          'paymentMethod': 'bank_transfer',
          'paymentMethods': ['bank_transfer'],
          'outstandingBalance': 500.0,
          'overdueDays': 0,
          'creditRating': 'good',
          'contacts': [],
          'documents': [],
          'notes': [],
          'tags': ['vip'],
          'assignedSalesRepId': 'REP-001',
          'assignedSalesRepName': 'Test Rep',
          'preferences': {},
          'preferredProducts': ['PROD-001'],
          'blacklistedProducts': [],
          'discountRate': 5.0,
          'isTaxExempt': false,
          'deliveryInstructions': 'Test Instructions',
          'operatingHours': '9:00-17:00',
          'certifications': ['ISO 9001'],
          'licenses': ['Drug License'],
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        };

        final customer = Customer.fromJson(json);

        expect(customer.id, '1');
        expect(customer.businessName, 'Test Business');
        expect(customer.businessType, 'pharmacy');
        expect(customer.customerTier, 'gold');
        expect(customer.totalPurchases, 10000.0);
        expect(customer.isActive, true);
      });

      test('Customer should compute properties correctly', () {
        final customer = Customer(
          id: '1',
          customerCode: 'CUST-001',
          businessName: 'Test Business',
          businessType: 'pharmacy',
          legalName: 'Test Legal Name',
          tradeLicenseNumber: 'TL-001',
          taxRegistrationNumber: 'TRN-001',
          drugLicenseNumber: 'DLN-001',
          contactPerson: 'Test Contact',
          contactEmail: 'contact@test.com',
          contactPhone: '+977-1234567890',
          address: 'Test Address',
          city: 'Kathmandu',
          state: 'Bagmati',
          country: 'Nepal',
          postalCode: '44600',
          region: 'Central',
          territory: 'Kathmandu',
          specializations: ['General'],
          productCategories: ['Analgesics'],
          customerTier: 'gold',
          status: 'active',
          registrationDate: DateTime.now().subtract(const Duration(days: 30)),
          lastPurchaseDate: DateTime.now().subtract(const Duration(days: 5)),
          lastContactDate: DateTime.now().subtract(const Duration(days: 10)),
          totalPurchases: 10000.0,
          totalOrders: 10,
          averageOrderValue: 1000.0,
          creditLimit: 5000.0,
          currentCredit: 2000.0,
          paymentTerms: 'NET 30',
          paymentMethod: 'bank_transfer',
          paymentMethods: ['bank_transfer'],
          outstandingBalance: 500.0,
          overdueDays: 5,
          creditRating: 'good',
          contacts: [],
          documents: [],
          notes: [],
          tags: ['vip'],
          assignedSalesRepId: 'REP-001',
          assignedSalesRepName: 'Test Rep',
          preferences: {},
          preferredProducts: ['PROD-001'],
          blacklistedProducts: [],
          discountRate: 5.0,
          isTaxExempt: false,
          deliveryInstructions: 'Test Instructions',
          operatingHours: '9:00-17:00',
          certifications: ['ISO 9001'],
          licenses: ['Drug License'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(customer.isActive, true);
        expect(customer.isOverdue, true);
        expect(customer.hasOutstandingBalance, true);
        expect(customer.isCreditLimitReached, false);
        expect(customer.creditUtilization, 40.0);
        expect(customer.isRecentCustomer, false);
        expect(customer.isRegularCustomer, true);
        expect(customer.isVIPCustomer, true);
        expect(customer.daysSinceLastPurchase, 5);
        expect(customer.daysSinceLastContact, 10);
        expect(customer.needsFollowUp, false);
      });

      test('Lead should create from JSON correctly', () {
        final json = {
          'id': '1',
          'leadNumber': 'LEAD-001',
          'companyName': 'Test Company',
          'contactPerson': 'Test Contact',
          'contactEmail': 'contact@test.com',
          'contactPhone': '+977-1234567890',
          'businessType': 'pharmacy',
          'source': 'website',
          'status': 'new',
          'priority': 'high',
          'assignedTo': 'REP-001',
          'assignedToName': 'Test Rep',
          'productInterest': 'Analgesics',
          'productCategories': ['Analgesics'],
          'estimatedValue': 5000.0,
          'budgetRange': '5000-10000',
          'timeline': 'within_1_month',
          'decisionMaker': 'Test Decision Maker',
          'decisionMakerContact': '+977-0987654321',
          'requirements': 'Test Requirements',
          'painPoints': 'Test Pain Points',
          'currentSolution': 'Test Current Solution',
          'activities': [],
          'notes': [],
          'creationDate': '2024-01-01T00:00:00.000Z',
          'lastContactDate': '2024-01-05T00:00:00.000Z',
          'followUpDate': '2024-01-10T00:00:00.000Z',
          'conversionProbability': 75.0,
          'tags': ['hot_lead'],
          'customFields': {},
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        };

        final lead = Lead.fromJson(json);

        expect(lead.id, '1');
        expect(lead.companyName, 'Test Company');
        expect(lead.status, 'new');
        expect(lead.priority, 'high');
        expect(lead.estimatedValue, 5000.0);
        expect(lead.conversionProbability, 75.0);
      });

      test('Lead should compute properties correctly', () {
        final lead = Lead(
          id: '1',
          leadNumber: 'LEAD-001',
          companyName: 'Test Company',
          contactPerson: 'Test Contact',
          contactEmail: 'contact@test.com',
          contactPhone: '+977-1234567890',
          businessType: 'pharmacy',
          source: 'website',
          status: 'new',
          priority: 'high',
          assignedTo: 'REP-001',
          assignedToName: 'Test Rep',
          productInterest: 'Analgesics',
          productCategories: ['Analgesics'],
          estimatedValue: 5000.0,
          budgetRange: '5000-10000',
          timeline: 'within_1_month',
          decisionMaker: 'Test Decision Maker',
          decisionMakerContact: '+977-0987654321',
          requirements: 'Test Requirements',
          painPoints: 'Test Pain Points',
          currentSolution: 'Test Current Solution',
          activities: [],
          notes: [],
          creationDate: DateTime.now().subtract(const Duration(days: 10)),
          lastContactDate: DateTime.now().subtract(const Duration(days: 5)),
          followUpDate: DateTime.now().subtract(const Duration(days: 1)),
          conversionProbability: 75.0,
          tags: ['hot_lead'],
          customFields: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(lead.isNew, true);
        expect(lead.isHotLead, true);
        expect(lead.needsFollowUp, true);
        expect(lead.isStale, false);
        expect(lead.daysSinceCreation, 10);
        expect(lead.daysSinceLastContact, 5);
      });
    });

    group('Distribution Model Tests', () {
      test('DistributionNetwork should create from JSON correctly', () {
        final json = {
          'id': '1',
          'name': 'Test Network',
          'type': 'direct',
          'tier': 'primary',
          'status': 'active',
          'region': 'Central',
          'territory': 'Kathmandu',
          'address': 'Test Address',
          'city': 'Kathmandu',
          'state': 'Bagmati',
          'country': 'Nepal',
          'postalCode': '44600',
          'contactPerson': 'Test Contact',
          'contactEmail': 'contact@test.com',
          'contactPhone': '+977-1234567890',
          'distributorId': 'DIST-001',
          'distributorName': 'Test Distributor',
          'distributorType': 'wholesaler',
          'specializations': ['General'],
          'productCategories': ['Analgesics'],
          'capacity': 1000,
          'currentLoad': 750,
          'marketShare': 25.0,
          'performanceRating': 'good',
          'creditLimit': 10000.0,
          'currentCredit': 3000.0,
          'paymentTerms': 'NET 30',
          'paymentMethods': ['bank_transfer'],
          'contractStartDate': '2024-01-01T00:00:00.000Z',
          'contractType': 'exclusive',
          'exclusiveProducts': ['PROD-001'],
          'targetMarkets': ['Kathmandu'],
          'distributionCenters': [],
          'salesRepresentatives': [],
          'performanceMetrics': {'sales': 10000.0},
          'certifications': ['ISO 9001'],
          'licenses': ['Drug License'],
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        };

        final network = DistributionNetwork.fromJson(json);

        expect(network.id, '1');
        expect(network.name, 'Test Network');
        expect(network.type, 'direct');
        expect(network.status, 'active');
        expect(network.capacity, 1000);
        expect(network.currentLoad, 750);
        expect(network.marketShare, 25.0);
      });

      test('DistributionNetwork should compute properties correctly', () {
        final network = DistributionNetwork(
          id: '1',
          name: 'Test Network',
          type: 'direct',
          tier: 'primary',
          status: 'active',
          region: 'Central',
          territory: 'Kathmandu',
          address: 'Test Address',
          city: 'Kathmandu',
          state: 'Bagmati',
          country: 'Nepal',
          postalCode: '44600',
          contactPerson: 'Test Contact',
          contactEmail: 'contact@test.com',
          contactPhone: '+977-1234567890',
          distributorId: 'DIST-001',
          distributorName: 'Test Distributor',
          distributorType: 'wholesaler',
          specializations: ['General'],
          productCategories: ['Analgesics'],
          capacity: 1000,
          currentLoad: 750,
          marketShare: 25.0,
          performanceRating: 'good',
          creditLimit: 10000.0,
          currentCredit: 3000.0,
          paymentTerms: 'NET 30',
          paymentMethods: ['bank_transfer'],
          contractStartDate: DateTime.now().subtract(const Duration(days: 30)),
          contractType: 'exclusive',
          exclusiveProducts: ['PROD-001'],
          targetMarkets: ['Kathmandu'],
          distributionCenters: [],
          salesRepresentatives: [],
          performanceMetrics: {'sales': 10000.0},
          certifications: ['ISO 9001'],
          licenses: ['Drug License'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(network.isActive, true);
        expect(network.utilizationRate, 75.0);
        expect(network.isAtCapacity, false);
        expect(network.hasCapacity, true);
        expect(network.creditUtilization, 30.0);
        expect(network.isCreditLimitReached, false);
        expect(network.hasAvailableCredit, true);
        expect(network.isContractExpired, false);
        expect(network.isContractExpiringSoon, false);
      });

      test('SalesRepresentative should create from JSON correctly', () {
        final json = {
          'id': '1',
          'employeeId': 'EMP-001',
          'firstName': 'Test',
          'lastName': 'Rep',
          'email': 'rep@test.com',
          'phone': '+977-1234567890',
          'region': 'Central',
          'territory': 'Kathmandu',
          'distributorId': 'DIST-001',
          'distributorName': 'Test Distributor',
          'position': 'Sales Representative',
          'department': 'Sales',
          'hireDate': '2024-01-01T00:00:00.000Z',
          'status': 'active',
          'productCategories': ['Analgesics'],
          'targetCustomers': ['Pharmacies'],
          'salesTarget': 10000.0,
          'currentSales': 8500.0,
          'commissionRate': 5.0,
          'performanceRating': 'good',
          'skills': ['Communication'],
          'certifications': ['Sales Certification'],
          'education': 'Bachelor Degree',
          'experience': '5 years',
          'managerId': 'MGR-001',
          'managerName': 'Test Manager',
          'performanceMetrics': {'calls': 100},
          'achievements': ['Top Performer'],
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        };

        final rep = SalesRepresentative.fromJson(json);

        expect(rep.id, '1');
        expect(rep.fullName, 'Test Rep');
        expect(rep.position, 'Sales Representative');
        expect(rep.salesTarget, 10000.0);
        expect(rep.currentSales, 8500.0);
        expect(rep.isActive, true);
      });

      test('SalesRepresentative should compute properties correctly', () {
        final rep = SalesRepresentative(
          id: '1',
          employeeId: 'EMP-001',
          firstName: 'Test',
          lastName: 'Rep',
          email: 'rep@test.com',
          phone: '+977-1234567890',
          region: 'Central',
          territory: 'Kathmandu',
          distributorId: 'DIST-001',
          distributorName: 'Test Distributor',
          position: 'Sales Representative',
          department: 'Sales',
          hireDate: DateTime.now().subtract(const Duration(days: 365)),
          status: 'active',
          productCategories: ['Analgesics'],
          targetCustomers: ['Pharmacies'],
          salesTarget: 10000.0,
          currentSales: 11000.0,
          commissionRate: 5.0,
          performanceRating: 'good',
          skills: ['Communication'],
          certifications: ['Sales Certification'],
          education: 'Bachelor Degree',
          experience: '5 years',
          managerId: 'MGR-001',
          managerName: 'Test Manager',
          performanceMetrics: {'calls': 100},
          achievements: ['Top Performer'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(rep.isActive, true);
        expect(rep.isMeetingTarget, true);
        expect(rep.isExceedingTarget, true);
        expect(rep.isBelowTarget, false);
        expect(rep.salesAchievement, 110.0);
        expect(rep.yearsOfExperience, 1);
      });
    });

    group('Integration Tests', () {
      test('Sales order should link with inventory items', () {
        final order = SalesOrder(
          id: '1',
          orderNumber: 'ORD-001',
          customerId: 'CUST-001',
          customerName: 'Test Customer',
          customerEmail: 'test@example.com',
          customerPhone: '+977-1234567890',
          items: [
            SalesOrderItem(
              id: '1',
              productId: 'PROD-001',
              productName: 'Test Product',
              productGenericName: 'Test Generic',
              productManufacturer: 'Test Manufacturer',
              productCategory: 'Analgesics',
              productStrength: '500mg',
              productDosageForm: 'Tablet',
              unitPrice: 100.0,
              quantity: 10,
              discountAmount: 0.0,
              taxRate: 13.0,
              taxAmount: 130.0,
              totalPrice: 1130.0,
              batchNumber: 'BATCH001',
              expiryDate: DateTime.now().add(const Duration(days: 180)),
              isPrescriptionRequired: false,
            )
          ],
          totalAmount: 1000.0,
          discountAmount: 0.0,
          taxAmount: 130.0,
          finalAmount: 1130.0,
          status: 'confirmed',
          paymentStatus: 'paid',
          paymentMethod: 'bank_transfer',
          orderDate: DateTime.now(),
          shippingAddress: 'Test Address',
          billingAddress: 'Test Address',
          salesRepresentativeName: 'Test Rep',
          distributionChannel: 'wholesale',
          deliveryMethod: 'standard',
          deliveryCost: 50.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final inventory = Inventory(
          id: '1',
          productId: 'PROD-001',
          productName: 'Test Product',
          productGenericName: 'Test Generic',
          productCategory: 'Analgesics',
          productManufacturer: 'Test Manufacturer',
          productStrength: '500mg',
          productDosageForm: 'Tablet',
          warehouseId: 'WH-001',
          warehouseName: 'Main Warehouse',
          warehouseLocation: 'Kathmandu',
          currentStock: 100,
          reservedStock: 10,
          availableStock: 90,
          minimumStock: 20,
          maximumStock: 500,
          reorderPoint: 25,
          reorderQuantity: 100,
          unitCost: 50.0,
          totalValue: 5000.0,
          batchNumber: 'BATCH001',
          manufactureDate: DateTime.now().subtract(const Duration(days: 30)),
          expiryDate: DateTime.now().add(const Duration(days: 180)),
          storageConditions: 'Room temperature',
          storageLocation: 'A1-B2',
          supplierId: 'SUP-001',
          supplierName: 'Test Supplier',
          lastRestockDate: DateTime.now(),
          daysOfStock: 30,
          turnoverRate: 2.5,
          status: 'active',
          transactions: [],
          stockMovements: [],
          qualityCheckStatus: 'passed',
          lastQualityCheck: DateTime.now(),
          alerts: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Verify the order and inventory are linked by product ID
        expect(order.items.first.productId, inventory.productId);
        expect(order.items.first.productName, inventory.productName);
        expect(order.items.first.batchNumber, inventory.batchNumber);
        expect(order.items.first.expiryDate, inventory.expiryDate);
        
        // Verify inventory has sufficient stock
        expect(inventory.availableStock, greaterThanOrEqualTo(order.items.first.quantity));
      });

      test('Customer should be linked with sales orders', () {
        final customer = Customer(
          id: 'CUST-001',
          customerCode: 'CUST-001',
          businessName: 'Test Customer',
          businessType: 'pharmacy',
          legalName: 'Test Legal Name',
          tradeLicenseNumber: 'TL-001',
          taxRegistrationNumber: 'TRN-001',
          drugLicenseNumber: 'DLN-001',
          contactPerson: 'Test Contact',
          contactEmail: 'test@example.com',
          contactPhone: '+977-1234567890',
          address: 'Test Address',
          city: 'Kathmandu',
          state: 'Bagmati',
          country: 'Nepal',
          postalCode: '44600',
          region: 'Central',
          territory: 'Kathmandu',
          specializations: ['General'],
          productCategories: ['Analgesics'],
          customerTier: 'gold',
          status: 'active',
          registrationDate: DateTime.now().subtract(const Duration(days: 30)),
          lastPurchaseDate: DateTime.now().subtract(const Duration(days: 5)),
          lastContactDate: DateTime.now().subtract(const Duration(days: 10)),
          totalPurchases: 10000.0,
          totalOrders: 10,
          averageOrderValue: 1000.0,
          creditLimit: 5000.0,
          currentCredit: 2000.0,
          paymentTerms: 'NET 30',
          paymentMethod: 'bank_transfer',
          paymentMethods: ['bank_transfer'],
          outstandingBalance: 500.0,
          overdueDays: 0,
          creditRating: 'good',
          contacts: [],
          documents: [],
          notes: [],
          tags: ['vip'],
          assignedSalesRepId: 'REP-001',
          assignedSalesRepName: 'Test Rep',
          preferences: {},
          preferredProducts: ['PROD-001'],
          blacklistedProducts: [],
          discountRate: 5.0,
          isTaxExempt: false,
          deliveryInstructions: 'Test Instructions',
          operatingHours: '9:00-17:00',
          certifications: ['ISO 9001'],
          licenses: ['Drug License'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final order = SalesOrder(
          id: '1',
          orderNumber: 'ORD-001',
          customerId: customer.id,
          customerName: customer.businessName,
          customerEmail: customer.contactEmail,
          customerPhone: customer.contactPhone,
          items: [],
          totalAmount: 1000.0,
          discountAmount: 0.0,
          taxAmount: 130.0,
          finalAmount: 1130.0,
          status: 'confirmed',
          paymentStatus: 'paid',
          paymentMethod: customer.paymentMethod,
          orderDate: customer.lastPurchaseDate!,
          shippingAddress: customer.address,
          billingAddress: customer.address,
          salesRepresentativeName: customer.assignedSalesRepName,
          distributionChannel: 'wholesale',
          deliveryMethod: 'standard',
          deliveryCost: 50.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Verify customer and order are linked
        expect(order.customerId, customer.id);
        expect(order.customerName, customer.businessName);
        expect(order.customerEmail, customer.contactEmail);
        expect(order.customerPhone, customer.contactPhone);
        expect(order.paymentMethod, customer.paymentMethod);
        expect(order.salesRepresentativeName, customer.assignedSalesRepName);
        expect(order.orderDate, customer.lastPurchaseDate);
      });
    });

    group('Data Validation Tests', () {
      test('SalesOrder should validate required fields', () {
        expect(() {
          SalesOrder(
            id: '',
            orderNumber: '',
            customerId: '',
            customerName: '',
            customerEmail: '',
            customerPhone: '',
            items: [],
            totalAmount: 0.0,
            discountAmount: 0.0,
            taxAmount: 0.0,
            finalAmount: 0.0,
            status: '',
            paymentStatus: '',
            paymentMethod: '',
            orderDate: DateTime.now(),
            shippingAddress: '',
            billingAddress: '',
            salesRepresentativeName: '',
            distributionChannel: '',
            deliveryMethod: '',
            deliveryCost: 0.0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }, throwsA(anything));
      });

      test('Customer should validate email format', () {
        expect(() {
          Customer(
            id: '1',
            customerCode: 'CUST-001',
            businessName: 'Test Customer',
            businessType: 'pharmacy',
            legalName: 'Test Legal Name',
            tradeLicenseNumber: 'TL-001',
            taxRegistrationNumber: 'TRN-001',
            drugLicenseNumber: 'DLN-001',
            contactPerson: 'Test Contact',
            contactEmail: 'invalid-email',
            contactPhone: '+977-1234567890',
            address: 'Test Address',
            city: 'Kathmandu',
            state: 'Bagmati',
            country: 'Nepal',
            postalCode: '44600',
            region: 'Central',
            territory: 'Kathmandu',
            specializations: ['General'],
            productCategories: ['Analgesics'],
            customerTier: 'gold',
            status: 'active',
            registrationDate: DateTime.now(),
            totalPurchases: 10000.0,
            totalOrders: 10,
            averageOrderValue: 1000.0,
            creditLimit: 5000.0,
            currentCredit: 2000.0,
            paymentTerms: 'NET 30',
            paymentMethod: 'bank_transfer',
            paymentMethods: ['bank_transfer'],
            outstandingBalance: 500.0,
            overdueDays: 0,
            creditRating: 'good',
            contacts: [],
            documents: [],
            notes: [],
            tags: ['vip'],
            assignedSalesRepId: 'REP-001',
            assignedSalesRepName: 'Test Rep',
            preferences: {},
            preferredProducts: ['PROD-001'],
            blacklistedProducts: [],
            discountRate: 5.0,
            isTaxExempt: false,
            deliveryInstructions: 'Test Instructions',
            operatingHours: '9:00-17:00',
            certifications: ['ISO 9001'],
            licenses: ['Drug License'],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }, throwsA(anything));
      });

      test('Inventory should validate stock levels', () {
        expect(() {
          Inventory(
            id: '1',
            productId: 'PROD-001',
            productName: 'Test Product',
            productGenericName: 'Test Generic',
            productCategory: 'Test Category',
            productManufacturer: 'Test Manufacturer',
            productStrength: '500mg',
            productDosageForm: 'Tablet',
            warehouseId: 'WH-001',
            warehouseName: 'Main Warehouse',
            warehouseLocation: 'Kathmandu',
            currentStock: -10,
            reservedStock: 5,
            availableStock: -15,
            minimumStock: 20,
            maximumStock: 500,
            reorderPoint: 25,
            reorderQuantity: 100,
            unitCost: 50.0,
            totalValue: -500.0,
            batchNumber: 'BATCH001',
            manufactureDate: DateTime.now(),
            expiryDate: DateTime.now(),
            storageConditions: 'Room temperature',
            storageLocation: 'A1-B2',
            supplierId: 'SUP-001',
            supplierName: 'Test Supplier',
            lastRestockDate: DateTime.now(),
            daysOfStock: 30,
            turnoverRate: 2.5,
            status: 'active',
            transactions: [],
            stockMovements: [],
            qualityCheckStatus: 'passed',
            lastQualityCheck: DateTime.now(),
            alerts: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }, throwsA(anything));
      });
    });
  });
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sales_model.dart';
import '../models/inventory_model.dart';
import '../models/marketing_model.dart';

class SalesService {
  static const String _baseUrl = 'https://api.vedantatrade.com';
  static const String _apiKey = 'your-api-key-here';

  // Sales Orders
  Future<List<SalesOrder>> getOrders({
    String? period,
    String? region,
    DateTimeRange? dateRange,
    String? status,
    String? customerId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (period != null) queryParams['period'] = period;
      if (region != null) queryParams['region'] = region;
      if (status != null) queryParams['status'] = status;
      if (customerId != null) queryParams['customerId'] = customerId;
      
      if (dateRange != null) {
        queryParams['startDate'] = dateRange.start.toIso8601String();
        queryParams['endDate'] = dateRange.end.toIso8601String();
      }

      final uri = Uri.parse('$_baseUrl/sales/orders').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> ordersJson = data['orders'];
        return ordersJson.map((json) => SalesOrder.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock data for development
      return _getMockOrders();
    }
  }

  Future<SalesOrder?> getOrderById(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/sales/orders/$orderId'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return SalesOrder.fromJson(data);
      } else {
        throw Exception('Failed to load order: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock data for development
      final mockOrders = _getMockOrders();
      return mockOrders.firstWhere(
        (order) => order.id == orderId,
        orElse: () => mockOrders.first,
      );
    }
  }

  Future<SalesOrder> createOrder(SalesOrder order) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/sales/orders'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode(order.toJson()),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return SalesOrder.fromJson(data);
      } else {
        throw Exception('Failed to create order: ${response.statusCode}');
      }
    } catch (e) {
      // Mock creation for development
      final newOrder = order.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        orderNumber: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      return newOrder;
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/sales/orders/$orderId/status'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({'status': status}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update order status: ${response.statusCode}');
      }
    } catch (e) {
      // Mock update for development
      print('Mock update order status: $orderId to $status');
    }
  }

  Future<void> cancelOrder(String orderId, String reason) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/sales/orders/$orderId/cancel'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({'reason': reason}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to cancel order: ${response.statusCode}');
      }
    } catch (e) {
      // Mock cancellation for development
      print('Mock cancel order: $orderId, reason: $reason');
    }
  }

  // Sales Analytics
  Future<SalesAnalytics?> getSalesAnalytics({
    String? period,
    String? region,
    DateTimeRange? dateRange,
  }) async {
    try {
      final queryParams = <String, String>{};
      
      if (period != null) queryParams['period'] = period;
      if (region != null) queryParams['region'] = region;
      
      if (dateRange != null) {
        queryParams['startDate'] = dateRange.start.toIso8601String();
        queryParams['endDate'] = dateRange.end.toIso8601String();
      }

      final uri = Uri.parse('$_baseUrl/sales/analytics').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return SalesAnalytics.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      // Return mock analytics for development
      return _getMockAnalytics();
    }
  }

  // Top Selling Products
  Future<List<ProductSales>> getTopSellingProducts({
    String? period,
    String? region,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
      };
      
      if (period != null) queryParams['period'] = period;
      if (region != null) queryParams['region'] = region;

      final uri = Uri.parse('$_baseUrl/sales/top-products').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> productsJson = data['products'];
        return productsJson.map((json) {
          return ProductSales(
            productId: json['productId'],
            productName: json['productName'],
            productCategory: json['productCategory'],
            quantitySold: json['quantitySold'],
            totalRevenue: json['totalRevenue'].toDouble(),
            averagePrice: json['averagePrice'].toDouble(),
            orderCount: json['orderCount'],
          );
        }).toList();
      } else {
        throw Exception('Failed to load top products: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock data for development
      return _getMockTopProducts();
    }
  }

  // Export functionality
  Future<void> exportSalesReport({
    required String format,
    required List<SalesOrder> orders,
    required Map<String, dynamic> metrics,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/sales/export'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'format': format,
          'orders': orders.map((order) => order.toJson()).toList(),
          'metrics': metrics,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to export report: ${response.statusCode}');
      }
    } catch (e) {
      // Mock export for development
      print('Mock export sales report in $format format');
      print('Orders: ${orders.length}');
      print('Metrics: $metrics');
    }
  }

  // Mock data for development
  List<SalesOrder> _getMockOrders() {
    return [
      SalesOrder(
        id: '1',
        orderNumber: 'ORD-2024-001',
        customerId: 'CUST-001',
        customerName: 'Kathmandu Medical Store',
        customerEmail: 'info@kathmandumedical.com',
        customerPhone: '+977-1-1234567',
        items: [
          SalesOrderItem(
            id: '1',
            productId: 'PROD-001',
            productName: 'Paracetamol 500mg',
            productGenericName: 'Acetaminophen',
            productManufacturer: 'Nepal Pharmaceutical Ltd',
            productCategory: 'Analgesics',
            productStrength: '500mg',
            productDosageForm: 'Tablet',
            unitPrice: 25.50,
            quantity: 100,
            discountAmount: 255.0,
            taxRate: 13.0,
            taxAmount: 331.5,
            totalPrice: 2831.5,
            batchNumber: 'BATCH001',
            expiryDate: DateTime.now().add(const Duration(days: 180)),
            isPrescriptionRequired: false,
          ),
          SalesOrderItem(
            id: '2',
            productId: 'PROD-002',
            productName: 'Amoxicillin 250mg',
            productGenericName: 'Amoxicillin',
            productManufacturer: 'Biosphere Nepal',
            productCategory: 'Antibiotics',
            productStrength: '250mg',
            productDosageForm: 'Capsule',
            unitPrice: 85.75,
            quantity: 50,
            discountAmount: 428.75,
            taxRate: 13.0,
            taxAmount: 557.51,
            totalPrice: 4736.26,
            batchNumber: 'BATCH002',
            expiryDate: DateTime.now().add(const Duration(days: 365)),
            isPrescriptionRequired: true,
            prescriptionNumber: 'RX-001',
            doctorName: 'Dr. Sharma',
            doctorRegistration: 'NMC-12345',
          ),
        ],
        totalAmount: 7567.76,
        discountAmount: 683.75,
        taxAmount: 889.01,
        finalAmount: 8456.77,
        status: 'confirmed',
        paymentStatus: 'paid',
        paymentMethod: 'bank_transfer',
        orderDate: DateTime.now().subtract(const Duration(hours: 2)),
        expectedDeliveryDate: DateTime.now().add(const Duration(days: 2)),
        shippingAddress: 'Kathmandu Medical Store, Thamel, Kathmandu',
        billingAddress: 'Kathmandu Medical Store, Thamel, Kathmandu',
        salesRepresentativeName: 'Ramesh Kumar',
        distributionChannel: 'wholesale',
        deliveryMethod: 'standard',
        deliveryCost: 150.0,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      SalesOrder(
        id: '2',
        orderNumber: 'ORD-2024-002',
        customerId: 'CUST-002',
        customerName: 'Pokhara Pharmacy',
        customerEmail: 'contact@pokharapharmacy.com',
        customerPhone: '+977-61-123456',
        items: [
          SalesOrderItem(
            id: '3',
            productId: 'PROD-003',
            productName: 'Omeprazole 20mg',
            productGenericName: 'Omeprazole',
            productManufacturer: 'Deurali-Janta Pharmaceuticals',
            productCategory: 'Gastrointestinal',
            productStrength: '20mg',
            productDosageForm: 'Capsule',
            unitPrice: 120.00,
            quantity: 75,
            discountAmount: 900.0,
            taxRate: 13.0,
            taxAmount: 1170.0,
            totalPrice: 9370.0,
            batchNumber: 'BATCH003',
            expiryDate: DateTime.now().add(const Duration(days: 120)),
            isPrescriptionRequired: true,
            prescriptionNumber: 'RX-002',
            doctorName: 'Dr. Gurung',
            doctorRegistration: 'NMC-67890',
          ),
        ],
        totalAmount: 9000.0,
        discountAmount: 900.0,
        taxAmount: 1170.0,
        finalAmount: 9270.0,
        status: 'processing',
        paymentStatus: 'paid',
        paymentMethod: 'cash',
        orderDate: DateTime.now().subtract(const Duration(days: 1)),
        expectedDeliveryDate: DateTime.now().add(const Duration(days: 1)),
        shippingAddress: 'Pokhara Pharmacy, Lakeside, Pokhara',
        billingAddress: 'Pokhara Pharmacy, Lakeside, Pokhara',
        salesRepresentativeName: 'Sita Thapa',
        distributionChannel: 'retail',
        deliveryMethod: 'express',
        deliveryCost: 200.0,
        isUrgent: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ];
  }

  SalesAnalytics _getMockAnalytics() {
    return SalesAnalytics(
      id: '1',
      period: DateTime.now(),
      periodType: 'daily',
      totalRevenue: 17726.77,
      totalOrders: 2,
      averageOrderValue: 8863.39,
      totalCustomers: 2,
      newCustomers: 1,
      returningCustomers: 1,
      revenueByCategory: {
        'Analgesics': 2831.5,
        'Antibiotics': 4736.26,
        'Gastrointestinal': 9370.0,
      },
      revenueByChannel: {
        'wholesale': 8456.77,
        'retail': 9270.0,
      },
      ordersByStatus: {
        'confirmed': 1,
        'processing': 1,
      },
      topSellingProducts: ['Omeprazole 20mg', 'Amoxicillin 250mg', 'Paracetamol 500mg'],
      topCustomers: ['Pokhara Pharmacy', 'Kathmandu Medical Store'],
      conversionRate: 3.5,
      customerRetentionRate: 50.0,
      averageOrderProcessingTime: 2.5,
      onTimeDeliveryRate: 95.0,
      customerSatisfactionScore: 4.2,
      salesByRegion: {
        'Kathmandu': 8456.77,
        'Pokhara': 9270.0,
      },
      salesBySalesRep: {
        'Ramesh Kumar': 8456.77,
        'Sita Thapa': 9270.0,
      },
      totalDiscounts: 1583.75,
      totalReturns: 0.0,
      returnRate: 0.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  List<ProductSales> _getMockTopProducts() {
    return [
      ProductSales(
        productId: 'PROD-003',
        productName: 'Omeprazole 20mg',
        productCategory: 'Gastrointestinal',
        quantitySold: 75,
        totalRevenue: 9370.0,
        averagePrice: 120.0,
        orderCount: 1,
      ),
      ProductSales(
        productId: 'PROD-002',
        productName: 'Amoxicillin 250mg',
        productCategory: 'Antibiotics',
        quantitySold: 50,
        totalRevenue: 4736.26,
        averagePrice: 85.75,
        orderCount: 1,
      ),
      ProductSales(
        productId: 'PROD-001',
        productName: 'Paracetamol 500mg',
        productCategory: 'Analgesics',
        quantitySold: 100,
        totalRevenue: 2831.5,
        averagePrice: 25.50,
        orderCount: 1,
      ),
    ];
  }
}

class ProductSales {
  final String productId;
  final String productName;
  final String productCategory;
  final int quantitySold;
  final double totalRevenue;
  final double averagePrice;
  final int orderCount;

  ProductSales({
    required this.productId,
    required this.productName,
    required this.productCategory,
    required this.quantitySold,
    required this.totalRevenue,
    required this.averagePrice,
    required this.orderCount,
  });
}

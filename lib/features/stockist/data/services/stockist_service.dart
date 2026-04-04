import 'package:dio/dio.dart';
import 'package:vedanta_trade/core/services/api_service.dart';

class StockistService {
  final ApiService _apiService;
  late final Dio _dio;

  StockistService({ApiService? apiService})
      : _apiService = apiService ?? ApiService() {
    _dio = _apiService.dio;
  }

  /// Get inventory for the stockist
  Future<List<Map<String, dynamic>>> getInventory() async {
    try {
      final response = await _dio.get('/api/stockist/inventory');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load inventory: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Fallback to mock data for development
      return _getMockInventory();
    }
  }

  /// Get orders for the stockist
  Future<List<Map<String, dynamic>>> getOrders() async {
    try {
      final response = await _dio.get('/api/stockist/orders');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Fallback to mock data for development
      return _getMockOrders();
    }
  }

  /// Get retailers for the stockist
  Future<List<Map<String, dynamic>>> getRetailers() async {
    try {
      final response = await _dio.get('/api/stockist/retailers');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load retailers: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Fallback to mock data for development
      return _getMockRetailers();
    }
  }

  /// Update stock quantity
  Future<void> updateStockQuantity(String productId, int newQuantity) async {
    try {
      final response = await _dio.put('/api/stockist/inventory/$productId', data: {
        'stockQuantity': newQuantity,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      
      if (response.statusCode != 200) {
        throw Exception('Failed to update stock: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Simulate API call for development
      debugPrint('Updating stock for $productId to $newQuantity');
    }
  }

  /// Create new order
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await _dio.post('/api/stockist/orders', data: {
        ...orderData,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      
      if (response.statusCode == 201) {
        return response.data['data'];
      } else {
        throw Exception('Failed to create order: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Simulate API call for development
      final newOrder = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        ...orderData,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'status': 'pending',
      };
      debugPrint('Creating order: ${newOrder['id']}');
      return newOrder;
    }
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final response = await _dio.patch('/api/stockist/orders/$orderId', data: {
        'status': newStatus,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      
      if (response.statusCode != 200) {
        throw Exception('Failed to update order status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Simulate API call for development
      debugPrint('Updating order $orderId to status: $newStatus');
    }
  }

  /// Add new product to inventory
  Future<Map<String, dynamic>> addProduct(Map<String, dynamic> productData) async {
    try {
      final response = await _dio.post('/api/stockist/inventory', data: {
        ...productData,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      
      if (response.statusCode == 201) {
        return response.data['data'];
      } else {
        throw Exception('Failed to add product: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Simulate API call for development
      final newProduct = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        ...productData,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
      debugPrint('Adding product: ${newProduct['id']}');
      return newProduct;
    }
  }

  /// Update product information
  Future<void> updateProduct(String productId, Map<String, dynamic> updates) async {
    try {
      final response = await _dio.put('/api/stockist/inventory/$productId', data: {
        ...updates,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      
      if (response.statusCode != 200) {
        throw Exception('Failed to update product: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Simulate API call for development
      debugPrint('Updating product $productId with: $updates');
    }
  }

  /// Remove product from inventory
  Future<void> removeProduct(String productId) async {
    try {
      final response = await _dio.delete('/api/stockist/inventory/$productId');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to remove product: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Simulate API call for development
      debugPrint('Removing product: $productId');
    }
  }

  /// Get inventory analytics
  Future<Map<String, dynamic>> getInventoryAnalytics() async {
    try {
      final response = await _dio.get('/api/stockist/analytics/inventory');
      
      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        throw Exception('Failed to get analytics: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Simulate API call for development
      return _getMockAnalytics();
    }
  }

  /// Mock data for development
  List<Map<String, dynamic>> _getMockInventory() {
    return [
      {
        'id': '1',
        'sku': 'VT-001',
        'name': 'Paracetamol 500mg',
        'category': 'Pain Relief',
        'manufacturer': 'Vedanta Pharma',
        'price': 25.50,
        'stockQuantity': 150,
        'lowStockThreshold': 50,
        'expiryDate': DateTime.now().add(Duration(days: 365)).toIso8601String(),
        'batchNumber': 'BATCH-001',
        'description': 'Paracetamol tablets 500mg',
        'isActive': true,
        'createdAt': DateTime.now().subtract(Duration(days: 30)).toIso8601String(),
        'updatedAt': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
      },
      {
        'id': '2',
        'sku': 'VT-002',
        'name': 'Amoxicillin 250mg',
        'category': 'Antibiotics',
        'manufacturer': 'Vedanta Pharma',
        'price': 45.75,
        'stockQuantity': 25, // Low stock
        'lowStockThreshold': 50,
        'expiryDate': DateTime.now().add(Duration(days: 180)).toIso8601String(),
        'batchNumber': 'BATCH-002',
        'description': 'Amoxicillin capsules 250mg',
        'isActive': true,
        'createdAt': DateTime.now().subtract(Duration(days: 45)).toIso8601String(),
        'updatedAt': DateTime.now().subtract(Duration(days: 2)).toIso8601String(),
      },
      {
        'id': '3',
        'sku': 'VT-003',
        'name': 'Ibuprofen 400mg',
        'category': 'Pain Relief',
        'manufacturer': 'Vedanta Pharma',
        'price': 35.25,
        'stockQuantity': 200,
        'lowStockThreshold': 30,
        'expiryDate': DateTime.now().add(Duration(days: 270)).toIso8601String(),
        'batchNumber': 'BATCH-003',
        'description': 'Ibuprofen tablets 400mg',
        'isActive': true,
        'createdAt': DateTime.now().subtract(Duration(days: 60)).toIso8601String(),
        'updatedAt': DateTime.now().subtract(Duration(days: 3)).toIso8601String(),
      },
      {
        'id': '4',
        'sku': 'VT-004',
        'name': 'Cetirizine 10mg',
        'category': 'Allergy',
        'manufacturer': 'Vedanta Pharma',
        'price': 15.50,
        'stockQuantity': 0, // Out of stock
        'lowStockThreshold': 25,
        'expiryDate': DateTime.now().add(Duration(days: 90)).toIso8601String(),
        'batchNumber': 'BATCH-004',
        'description': 'Cetirizine tablets 10mg',
        'isActive': true,
        'createdAt': DateTime.now().subtract(Duration(days: 90)).toIso8601String(),
        'updatedAt': DateTime.now().subtract(Duration(days: 5)).toIso8601String(),
      },
      {
        'id': '5',
        'sku': 'VT-005',
        'name': 'Omeprazole 20mg',
        'category': 'Gastrointestinal',
        'manufacturer': 'Vedanta Pharma',
        'price': 55.00,
        'stockQuantity': 75,
        'lowStockThreshold': 40,
        'expiryDate': DateTime.now().subtract(Duration(days: 10)).toIso8601String(), // Expired
        'batchNumber': 'BATCH-005',
        'description': 'Omeprazole capsules 20mg',
        'isActive': true,
        'createdAt': DateTime.now().subtract(Duration(days: 120)).toIso8601String(),
        'updatedAt': DateTime.now().subtract(Duration(days: 7)).toIso8601String(),
      },
    ];
  }

  List<Map<String, dynamic>> _getMockOrders() {
    return [
      {
        'id': 'ORD-001',
        'retailerId': 'RET-001',
        'retailerName': 'Janakpur Medical Store',
        'orderDate': DateTime.now().subtract(Duration(days: 2)).toIso8601String(),
        'totalAmount': 2500.00,
        'status': 'pending',
        'items': [
          {'productId': '1', 'productName': 'Paracetamol 500mg', 'quantity': 50, 'price': 25.50},
          {'productId': '2', 'productName': 'Amoxicillin 250mg', 'quantity': 30, 'price': 45.75},
        ],
        'deliveryAddress': 'Bhanu Chowk, Janakpur',
        'contactNumber': '+977-1234567890',
        'notes': 'Urgent delivery required',
        'createdAt': DateTime.now().subtract(Duration(days: 2)).toIso8601String(),
        'updatedAt': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
      },
      {
        'id': 'ORD-002',
        'retailerId': 'RET-002',
        'retailerName': 'City Care Pharmacy',
        'orderDate': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
        'totalAmount': 1800.00,
        'status': 'approved',
        'items': [
          {'productId': '3', 'productName': 'Ibuprofen 400mg', 'quantity': 40, 'price': 35.25},
          {'productId': '4', 'productName': 'Cetirizine 10mg', 'quantity': 20, 'price': 15.50},
        ],
        'deliveryAddress': 'Ram Chowk, Janakpur',
        'contactNumber': '+977-9876543210',
        'notes': 'Standard delivery',
        'createdAt': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
        'updatedAt': DateTime.now().subtract(Duration(hours: 12)).toIso8601String(),
      },
      {
        'id': 'ORD-003',
        'retailerId': 'RET-003',
        'retailerName': 'Shree Medical Hall',
        'orderDate': DateTime.now().subtract(Duration(days: 3)).toIso8601String(),
        'totalAmount': 3200.00,
        'status': 'dispatched',
        'items': [
          {'productId': '1', 'productName': 'Paracetamol 500mg', 'quantity': 80, 'price': 25.50},
          {'productId': '5', 'productName': 'Omeprazole 20mg', 'quantity': 25, 'price': 55.00},
        ],
        'deliveryAddress': 'Jaleshwor Road, Janakpur',
        'contactNumber': '+977-1122334455',
        'notes': 'Bulk order',
        'createdAt': DateTime.now().subtract(Duration(days: 3)).toIso8601String(),
        'updatedAt': DateTime.now().subtract(Duration(hours: 6)).toIso8601String(),
      },
    ];
  }

  List<Map<String, dynamic>> _getMockRetailers() {
    return [
      {
        'id': 'RET-001',
        'name': 'Janakpur Medical Store',
        'ownerName': 'Ramesh Sharma',
        'area': 'Bhanu Chowk',
        'address': 'Bhanu Chowk, Janakpur',
        'contactNumber': '+977-1234567890',
        'email': 'ramesh@janakpumedical.com',
        'licenseNumber': 'PHARM-001',
        'totalOrders': 45,
        'pendingOrders': 3,
        'totalRevenue': 125000.00,
        'isActive': true,
        'createdAt': DateTime.now().subtract(Duration(days: 180)).toIso8601String(),
        'updatedAt': DateTime.now().subtract(Duration(days: 5)).toIso8601String(),
      },
      {
        'id': 'RET-002',
        'name': 'City Care Pharmacy',
        'ownerName': 'Sita Devi',
        'area': 'Ram Chowk',
        'address': 'Ram Chowk, Janakpur',
        'contactNumber': '+977-9876543210',
        'email': 'sita@citycare.com',
        'licenseNumber': 'PHARM-002',
        'totalOrders': 32,
        'pendingOrders': 1,
        'totalRevenue': 89000.00,
        'isActive': true,
        'createdAt': DateTime.now().subtract(Duration(days: 120)).toIso8601String(),
        'updatedAt': DateTime.now().subtract(Duration(days: 3)).toIso8601String(),
      },
      {
        'id': 'RET-003',
        'name': 'Shree Medical Hall',
        'ownerName': 'Krishna Prasad',
        'area': 'Jaleshwor Road',
        'address': 'Jaleshwor Road, Janakpur',
        'contactNumber': '+977-1122334455',
        'email': 'krishna@shreemedical.com',
        'licenseNumber': 'PHARM-003',
        'totalOrders': 28,
        'pendingOrders': 2,
        'totalRevenue': 76000.00,
        'isActive': true,
        'createdAt': DateTime.now().subtract(Duration(days: 90)).toIso8601String(),
        'updatedAt': DateTime.now().subtract(Duration(days: 7)).toIso8601String(),
      },
      {
        'id': 'RET-004',
        'name': 'New Life Pharmacy',
        'ownerName': 'Anita Singh',
        'area': 'Mahendra Chowk',
        'address': 'Mahendra Chowk, Janakpur',
        'contactNumber': '+977-5544332211',
        'email': 'anita@newlife.com',
        'licenseNumber': 'PHARM-004',
        'totalOrders': 15,
        'pendingOrders': 0,
        'totalRevenue': 35000.00,
        'isActive': false, // Inactive retailer
        'createdAt': DateTime.now().subtract(Duration(days: 60)).toIso8601String(),
        'updatedAt': DateTime.now().subtract(Duration(days: 10)).toIso8601String(),
      },
    ];
  }

  Map<String, dynamic> _getMockAnalytics() {
    return {
      'totalProducts': 156,
      'totalValue': 456750.00,
      'lowStockCount': 12,
      'lowStockValue': 12500.00,
      'expiredCount': 3,
      'expiredValue': 2500.00,
      'pendingOrders': 8,
      'activeRetailers': 12,
      'totalOrders': 156,
      'totalRevenue': 890000.00,
      'averageOrderValue': 5705.13,
      'topSellingProducts': [
        {'productId': '1', 'productName': 'Paracetamol 500mg', 'totalSold': 1250, 'revenue': 31875.00},
        {'productId': '3', 'productName': 'Ibuprofen 400mg', 'totalSold': 890, 'revenue': 31372.50},
        {'productId': '2', 'productName': 'Amoxicillin 250mg', 'totalSold': 450, 'revenue': 20587.50},
      ],
      'topRetailers': [
        {'retailerId': 'RET-001', 'retailerName': 'Janakpur Medical Store', 'totalOrders': 45, 'revenue': 125000.00},
        {'retailerId': 'RET-002', 'retailerName': 'City Care Pharmacy', 'totalOrders': 32, 'revenue': 89000.00},
        {'retailerId': 'RET-003', 'retailerName': 'Shree Medical Hall', 'totalOrders': 28, 'revenue': 76000.00},
      ],
    };
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:async';
import '../../../shared/widgets/premium_glassmorphic_theme.dart';
import '../models/distribution_models.dart';
import '../models/inventory_models.dart';
import '../models/sales_models.dart';

class DistributionManagementService {
  static final DistributionManagementService _instance = DistributionManagementService._internal();
  factory DistributionManagementService() => _instance;
  DistributionManagementService._internal();

  late final Dio _dio;
  final StreamController<List<DistributionCenter>> _centersController = 
      StreamController<List<DistributionCenter>>.broadcast();
  final StreamController<List<InventoryItem>> _inventoryController = 
      StreamController<List<InventoryItem>>.broadcast();
  final StreamController<List<SalesRecord>> _salesController = 
      StreamController<List<SalesRecord>>.broadcast();
  final StreamController<List<StockAlert>> _alertsController = 
      StreamController<List<StockAlert>>.broadcast();
  final StreamController<DistributionMetrics> _metricsController = 
      StreamController<DistributionMetrics>.broadcast();

  List<DistributionCenter> _centers = [];
  List<InventoryItem> _inventory = [];
  List<SalesRecord> _sales = [];
  List<StockAlert> _alerts = [];
  DistributionMetrics _metrics = DistributionMetrics();
  
  Timer? _realtimeTimer;
  String? _currentStockistId;

  // Stream getters
  Stream<List<DistributionCenter>> get centersStream => _centersController.stream;
  Stream<List<InventoryItem>> get inventoryStream => _inventoryController.stream;
  Stream<List<SalesRecord>> get salesStream => _salesController.stream;
  Stream<List<StockAlert>> get alertsStream => _alertsController.stream;
  Stream<DistributionMetrics> get metricsStream => _metricsController.stream;

  // Data getters
  List<DistributionCenter> get centers => List.unmodifiable(_centers);
  List<InventoryItem> get inventory => List.unmodifiable(_inventory);
  List<SalesRecord> get sales => List.unmodifiable(_sales);
  List<StockAlert> get alerts => List.unmodifiable(_alerts);
  DistributionMetrics get metrics => _metrics;

  void initialize({String? stockistId}) {
    try {
      debugPrint('🚀 Initializing Distribution Management Service...');
      
      _currentStockistId = stockistId;
      _setupDioClient();
      _loadInitialData();
      _startRealtimeUpdates();
      
      debugPrint('✅ Distribution Management Service initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize Distribution Management Service: $e');
      _centersController.addError(e);
    }
  }

  void _setupDioClient() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://api.vedantatrade.com.np',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'X-Country': 'NP',
        'X-Currency': 'NPR',
        'X-Timezone': 'Asia/Kathmandu',
      },
    ));

    // Add request interceptor for authentication
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          // final token = await _getAuthToken();
          // if (token != null) {
          //   options.headers['Authorization'] = 'Bearer $token';
          // }
          handler.next(options);
        },
        onError: (error, handler) {
          debugPrint('Distribution API Error: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  Future<void> _loadInitialData() async {
    try {
      debugPrint('📂 Loading initial distribution data...');
      
      // Load distribution centers
      await _loadDistributionCenters();
      
      // Load inventory
      await _loadInventory();
      
      // Load sales data
      await _loadSalesData();
      
      // Load stock alerts
      await _loadStockAlerts();
      
      // Calculate metrics
      _calculateMetrics();
      
      debugPrint('✅ Initial data loaded successfully');
    } catch (e) {
      debugPrint('❌ Failed to load initial data: $e');
      // Load mock data as fallback
      await _loadMockData();
    }
  }

  Future<void> _loadDistributionCenters() async {
    try {
      final response = await _dio.get('/api/distribution/centers');
      if (response.statusCode == 200) {
        _centers = (response.data['centers'] as List)
            .map((json) => DistributionCenter.fromJson(json))
            .toList();
        _centersController.add(_centers);
      }
    } catch (e) {
      debugPrint('Failed to load distribution centers: $e');
      rethrow;
    }
  }

  Future<void> _loadInventory() async {
    try {
      final response = await _dio.get('/api/inventory/stockist/$_currentStockistId');
      if (response.statusCode == 200) {
        _inventory = (response.data['inventory'] as List)
            .map((json) => InventoryItem.fromJson(json))
            .toList();
        _inventoryController.add(_inventory);
      }
    } catch (e) {
      debugPrint('Failed to load inventory: $e');
      rethrow;
    }
  }

  Future<void> _loadSalesData() async {
    try {
      final response = await _dio.get('/api/sales/stockist/$_currentStockistId');
      if (response.statusCode == 200) {
        _sales = (response.data['sales'] as List)
            .map((json) => SalesRecord.fromJson(json))
            .toList();
        _salesController.add(_sales);
      }
    } catch (e) {
      debugPrint('Failed to load sales data: $e');
      rethrow;
    }
  }

  Future<void> _loadStockAlerts() async {
    try {
      final response = await _dio.get('/api/inventory/alerts/stockist/$_currentStockistId');
      if (response.statusCode == 200) {
        _alerts = (response.data['alerts'] as List)
            .map((json) => StockAlert.fromJson(json))
            .toList();
        _alertsController.add(_alerts);
      }
    } catch (e) {
      debugPrint('Failed to load stock alerts: $e');
      rethrow;
    }
  }

  void _startRealtimeUpdates() {
    debugPrint('🔄 Starting real-time updates...');
    
    _realtimeTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _refreshData();
    });
    
    debugPrint('✅ Real-time updates started');
  }

  Future<void> _refreshData() async {
    try {
      await Future.wait([
        _loadInventory(),
        _loadSalesData(),
        _loadStockAlerts(),
      ]);
      _calculateMetrics();
    } catch (e) {
      debugPrint('Failed to refresh data: $e');
    }
  }

  void _calculateMetrics() {
    _metrics = DistributionMetrics(
      totalProducts: _inventory.length,
      lowStockItems: _inventory.where((item) => item.currentStock <= item.minStock).length,
      outOfStockItems: _inventory.where((item) => item.currentStock == 0).length,
      totalSalesValue: _sales.fold(0.0, (sum, sale) => sum + sale.totalAmount),
      todaySales: _sales.where((sale) => 
        sale.date.isAtSameMomentAs(DateTime.now()) || 
        sale.date.isAfter(DateTime.now().subtract(const Duration(days: 1)))
      ).length,
      pendingOrders: _sales.where((sale) => sale.status == SalesStatus.pending).length,
      criticalAlerts: _alerts.where((alert) => alert.severity == AlertSeverity.critical).length,
      averageOrderValue: _sales.isNotEmpty 
          ? _sales.fold(0.0, (sum, sale) => sum + sale.totalAmount) / _sales.length 
          : 0.0,
    );
    _metricsController.add(_metrics);
  }

  Future<void> _loadMockData() async {
    debugPrint('📋 Loading mock distribution data...');
    
    // Mock distribution centers
    _centers = [
      DistributionCenter(
        id: '1',
        name: 'Kathmandu Main Warehouse',
        location: 'Kathmandu, Nepal',
        address: 'Balkhu, Kathmandu',
        phone: '+977-1-1234567',
        email: 'kathmandu@vedantatrade.com',
        manager: 'Ramesh Sharma',
        capacity: 10000,
        currentStock: 7500,
        isActive: true,
        coordinates: GeoCoordinates(27.7172, 85.3240),
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
      ),
      DistributionCenter(
        id: '2',
        name: 'Pokhara Distribution Center',
        location: 'Pokhara, Nepal',
        address: 'Lakeside, Pokhara',
        phone: '+977-61-123456',
        email: 'pokhara@vedantatrade.com',
        manager: 'Sita K.C.',
        capacity: 5000,
        currentStock: 3200,
        isActive: true,
        coordinates: GeoCoordinates(28.2096, 83.9856),
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
      ),
      DistributionCenter(
        id: '3',
        name: 'Biratnagar Regional Hub',
        location: 'Biratnagar, Nepal',
        address: 'Industrial Area, Biratnagar',
        phone: '+977-21-123456',
        email: 'biratnagar@vedantatrade.com',
        manager: 'Prakash Thapa',
        capacity: 7500,
        currentStock: 5800,
        isActive: true,
        coordinates: GeoCoordinates(26.4525, 87.2718),
        createdAt: DateTime.now().subtract(const Duration(days: 150)),
      ),
    ];
    
    // Mock inventory
    _inventory = [
      InventoryItem(
        id: '1',
        sku: 'VT-001',
        productName: 'Paracetamol 500mg',
        brand: 'Vedanta Pharma',
        category: 'Analgesics',
        description: 'Paracetamol tablets 500mg',
        unitPrice: 2.50,
        currentStock: 1500,
        minStock: 500,
        maxStock: 5000,
        reorderLevel: 750,
        batchNumber: 'BT-2024-001',
        expiryDate: DateTime.now().add(const Duration(days: 730)),
        manufacturer: 'Vedanta Pharmaceuticals',
        storageConditions: 'Store below 25°C',
        lastUpdated: DateTime.now(),
      ),
      InventoryItem(
        id: '2',
        sku: 'VT-002',
        productName: 'Amoxicillin 250mg',
        brand: 'Vedanta Pharma',
        category: 'Antibiotics',
        description: 'Amoxicillin capsules 250mg',
        unitPrice: 8.75,
        currentStock: 800,
        minStock: 300,
        maxStock: 3000,
        reorderLevel: 500,
        batchNumber: 'BT-2024-002',
        expiryDate: DateTime.now().add(const Duration(days: 540)),
        manufacturer: 'Vedanta Pharmaceuticals',
        storageConditions: 'Store below 30°C',
        lastUpdated: DateTime.now(),
      ),
      InventoryItem(
        sku: 'VT-003',
        productName: 'Ibuprofen 400mg',
        brand: 'Vedanta Pharma',
        category: 'Analgesics',
        description: 'Ibuprofen tablets 400mg',
        unitPrice: 4.25,
        currentStock: 200,
        minStock: 400,
        maxStock: 2000,
        reorderLevel: 600,
        batchNumber: 'BT-2024-003',
        expiryDate: DateTime.now().add(const Duration(days: 600)),
        manufacturer: 'Vedanta Pharmaceuticals',
        storageConditions: 'Store below 25°C',
        lastUpdated: DateTime.now(),
      ),
      InventoryItem(
        sku: 'VT-004',
        productName: 'Omeprazole 20mg',
        brand: 'Vedanta Pharma',
        category: 'Gastrointestinal',
        description: 'Omeprazole capsules 20mg',
        unitPrice: 12.50,
        currentStock: 1200,
        minStock: 350,
        maxStock: 4000,
        reorderLevel: 700,
        batchNumber: 'BT-2024-004',
        expiryDate: DateTime.now().add(const Duration(days: 800)),
        manufacturer: 'Vedanta Pharmaceuticals',
        storageConditions: 'Store below 30°C',
        lastUpdated: DateTime.now(),
      ),
    ];
    
    // Mock sales data
    _sales = [
      SalesRecord(
        id: '1',
        orderId: 'ORD-001',
        retailerId: 'RET-001',
        retailerName: 'City Pharmacy',
        retailerLocation: 'Kathmandu',
        items: [
          SalesItem(
            sku: 'VT-001',
            productName: 'Paracetamol 500mg',
            quantity: 100,
            unitPrice: 2.50,
            totalPrice: 250.0,
          ),
          SalesItem(
            sku: 'VT-002',
            productName: 'Amoxicillin 250mg',
            quantity: 50,
            unitPrice: 8.75,
            totalPrice: 437.5,
          ),
        ],
        totalAmount: 687.5,
        vatAmount: 89.38,
        finalAmount: 776.88,
        status: SalesStatus.completed,
        paymentStatus: PaymentStatus.paid,
        date: DateTime.now().subtract(const Duration(hours: 2)),
        deliveryDate: DateTime.now().add(const Duration(days: 1)),
        notes: 'Regular order',
        createdBy: 'MR Kumar',
      ),
      SalesRecord(
        id: '2',
        orderId: 'ORD-002',
        retailerId: 'RET-002',
        retailerName: 'Health Plus Pharmacy',
        retailerLocation: 'Pokhara',
        items: [
          SalesItem(
            sku: 'VT-003',
            productName: 'Ibuprofen 400mg',
            quantity: 200,
            unitPrice: 4.25,
            totalPrice: 850.0,
          ),
        ],
        totalAmount: 850.0,
        vatAmount: 110.5,
        finalAmount: 960.5,
        status: SalesStatus.pending,
        paymentStatus: PaymentStatus.pending,
        date: DateTime.now().subtract(const Duration(hours: 6)),
        deliveryDate: DateTime.now().add(const Duration(days: 2)),
        notes: 'Urgent delivery required',
        createdBy: 'MR Sharma',
      ),
    ];
    
    // Mock stock alerts
    _alerts = [
      StockAlert(
        id: '1',
        sku: 'VT-003',
        productName: 'Ibuprofen 400mg',
        currentStock: 200,
        minStock: 400,
        maxStock: 2000,
        severity: AlertSeverity.critical,
        message: 'Critical: Stock below minimum level',
        recommendation: 'Reorder immediately - Current stock: 200, Min stock: 400',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        acknowledged: false,
      ),
      StockAlert(
        id: '2',
        sku: 'VT-002',
        productName: 'Amoxicillin 250mg',
        currentStock: 800,
        minStock: 300,
        maxStock: 3000,
        severity: AlertSeverity.warning,
        message: 'Warning: Stock approaching reorder level',
        recommendation: 'Consider reordering soon - Current stock: 800, Reorder at: 500',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        acknowledged: false,
      ),
    ];
    
    // Update streams
    _centersController.add(_centers);
    _inventoryController.add(_inventory);
    _salesController.add(_sales);
    _alertsController.add(_alerts);
    _calculateMetrics();
    
    debugPrint('✅ Mock data loaded successfully');
  }

  // Inventory Management Methods
  Future<bool> updateInventory(String sku, int newStock) async {
    try {
      final response = await _dio.put('/api/inventory/update', data: {
        'sku': sku,
        'stock': newStock,
        'stockistId': _currentStockistId,
      });

      if (response.statusCode == 200) {
        // Update local inventory
        final index = _inventory.indexWhere((item) => item.sku == sku);
        if (index != -1) {
          _inventory[index] = _inventory[index].copyWith(
            currentStock: newStock,
            lastUpdated: DateTime.now(),
          );
          _inventoryController.add(_inventory);
          _calculateMetrics();
        }
        return true;
      }
    } catch (e) {
      debugPrint('Failed to update inventory: $e');
    }
    return false;
  }

  Future<bool> transferStock(String sku, int quantity, String fromCenter, String toCenter) async {
    try {
      final response = await _dio.post('/api/inventory/transfer', data: {
        'sku': sku,
        'quantity': quantity,
        'fromCenter': fromCenter,
        'toCenter': toCenter,
        'stockistId': _currentStockistId,
      });

      if (response.statusCode == 200) {
        // Update local inventory
        await _loadInventory();
        return true;
      }
    } catch (e) {
      debugPrint('Failed to transfer stock: $e');
    }
    return false;
  }

  // Sales Management Methods
  Future<bool> createSalesOrder(SalesOrder order) async {
    try {
      final response = await _dio.post('/api/sales/create', data: order.toJson());

      if (response.statusCode == 201) {
        final newSales = SalesRecord.fromJson(response.data['sales']);
        _sales.insert(0, newSales);
        _salesController.add(_sales);
        _calculateMetrics();
        return true;
      }
    } catch (e) {
      debugPrint('Failed to create sales order: $e');
    }
    return false;
  }

  Future<bool> updateSalesStatus(String salesId, SalesStatus status) async {
    try {
      final response = await _dio.put('/api/sales/$salesId/status', data: {
        'status': status.toString(),
      });

      if (response.statusCode == 200) {
        final index = _sales.indexWhere((sale) => sale.id == salesId);
        if (index != -1) {
          _sales[index] = _sales[index].copyWith(status: status);
          _salesController.add(_sales);
          _calculateMetrics();
        }
        return true;
      }
    } catch (e) {
      debugPrint('Failed to update sales status: $e');
    }
    return false;
  }

  // Analytics Methods
  List<SalesRecord> getSalesByDateRange(DateTime startDate, DateTime endDate) {
    return _sales.where((sale) =>
        sale.date.isAfter(startDate) && sale.date.isBefore(endDate)
    ).toList();
  }

  List<SalesRecord> getSalesByStatus(SalesStatus status) {
    return _sales.where((sale) => sale.status == status).toList();
  }

  List<InventoryItem> getLowStockItems() {
    return _inventory.where((item) => item.currentStock <= item.minStock).toList();
  }

  List<InventoryItem> getOutOfStockItems() {
    return _inventory.where((item) => item.currentStock == 0).toList();
  }

  Map<String, double> getSalesByCategory() {
    final Map<String, double> categorySales = {};
    
    for (final sale in _sales) {
      for (final item in sale.items) {
        final inventoryItem = _inventory.firstWhere(
          (inv) => inv.sku == item.sku,
          orElse: () => InventoryItem(
            id: '',
            sku: item.sku,
            productName: item.productName,
            brand: '',
            category: 'Unknown',
            description: '',
            unitPrice: item.unitPrice,
            currentStock: 0,
            minStock: 0,
            maxStock: 0,
            reorderLevel: 0,
            batchNumber: '',
            expiryDate: DateTime.now(),
            manufacturer: '',
            storageConditions: '',
            lastUpdated: DateTime.now(),
          ),
        );
        
        final currentTotal = categorySales[inventoryItem.category] ?? 0.0;
        categorySales[inventoryItem.category] = currentTotal + item.totalPrice;
      }
    }
    
    return categorySales;
  }

  Map<String, int> getTopSellingProducts({int limit = 10}) {
    final Map<String, int> productSales = {};
    
    for (final sale in _sales) {
      for (final item in sale.items) {
        final currentQuantity = productSales[item.productName] ?? 0;
        productSales[item.productName] = currentQuantity + item.quantity;
      }
    }
    
    // Sort and return top products
    final sortedProducts = Map.fromEntries(
      productSales.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value))
    );
    
    return Map.fromEntries(
      sortedProducts.entries.take(limit)
    );
  }

  // Alert Management
  Future<bool> acknowledgeAlert(String alertId) async {
    try {
      final response = await _dio.put('/api/alerts/$alertId/acknowledge');

      if (response.statusCode == 200) {
        final index = _alerts.indexWhere((alert) => alert.id == alertId);
        if (index != -1) {
          _alerts[index] = _alerts[index].copyWith(acknowledged: true);
          _alertsController.add(_alerts);
        }
        return true;
      }
    } catch (e) {
      debugPrint('Failed to acknowledge alert: $e');
    }
    return false;
  }

  Future<bool> resolveAlert(String alertId) async {
    try {
      final response = await _dio.delete('/api/alerts/$alertId');

      if (response.statusCode == 200) {
        _alerts.removeWhere((alert) => alert.id == alertId);
        _alertsController.add(_alerts);
        return true;
      }
    } catch (e) {
      debugPrint('Failed to resolve alert: $e');
    }
    return false;
  }

  // Reporting Methods
  Future<Map<String, dynamic>> generateInventoryReport() async {
    final report = {
      'generatedAt': DateTime.now().toIso8601String(),
      'totalProducts': _inventory.length,
      'totalValue': _inventory.fold(0.0, (sum, item) => sum + (item.currentStock * item.unitPrice)),
      'lowStockItems': getLowStockItems().length,
      'outOfStockItems': getOutOfStockItems().length,
      'categories': _inventory.map((item) => item.category).toSet().toList(),
      'items': _inventory.map((item) => item.toJson()).toList(),
    };
    
    return report;
  }

  Future<Map<String, dynamic>> generateSalesReport({DateTime? startDate, DateTime? endDate}) async {
    final filteredSales = startDate != null && endDate != null
        ? getSalesByDateRange(startDate, endDate)
        : _sales;
    
    final report = {
      'generatedAt': DateTime.now().toIso8601String(),
      'period': startDate != null && endDate != null
          ? '${startDate.toIso8601String()} - ${endDate.toIso8601String()}'
          : 'All time',
      'totalOrders': filteredSales.length,
      'totalRevenue': filteredSales.fold(0.0, (sum, sale) => sum + sale.finalAmount),
      'totalVAT': filteredSales.fold(0.0, (sum, sale) => sum + sale.vatAmount),
      'averageOrderValue': filteredSales.isNotEmpty
          ? filteredSales.fold(0.0, (sum, sale) => sum + sale.finalAmount) / filteredSales.length
          : 0.0,
      'statusBreakdown': {
        'pending': filteredSales.where((s) => s.status == SalesStatus.pending).length,
        'processing': filteredSales.where((s) => s.status == SalesStatus.processing).length,
        'completed': filteredSales.where((s) => s.status == SalesStatus.completed).length,
        'cancelled': filteredSales.where((s) => s.status == SalesStatus.cancelled).length,
      },
      'topProducts': getTopSellingProducts(limit: 5),
      'categoryBreakdown': getSalesByCategory(),
      'sales': filteredSales.map((sale) => sale.toJson()).toList(),
    };
    
    return report;
  }

  void dispose() {
    debugPrint('🗑️ Disposing Distribution Management Service...');
    
    _realtimeTimer?.cancel();
    _centersController.close();
    _inventoryController.close();
    _salesController.close();
    _alertsController.close();
    _metricsController.close();
    
    debugPrint('✅ Distribution Management Service disposed');
  }
}

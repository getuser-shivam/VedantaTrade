import 'package:flutter/foundation.dart';
import 'package:vedanta_trade/features/stockist/data/services/stockist_service.dart';

class StockistProvider extends ChangeNotifier {
  final StockistService _stockistService;
  
  StockistProvider({StockistService? stockistService})
      : _stockistService = stockistService ?? StockistService();

  // State variables
  List<Map<String, dynamic>> _inventory = [];
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _retailers = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Map<String, dynamic>> get inventory => _inventory;
  List<Map<String, dynamic>> get orders => _orders;
  List<Map<String, dynamic>> get retailers => _retailers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Computed properties
  int get totalProducts => _inventory.length;
  int get lowStockCount => _inventory.where((item) => 
      item['stockQuantity'] <= item['lowStockThreshold']).length;
  int get pendingOrders => _orders.where((order) => 
      order['status'] == 'pending').length;
  int get activeRetailers => _retailers.where((retailer) => 
      retailer['isActive']).length;
  List<Map<String, dynamic>> get lowStockItems => _inventory.where((item) => 
      item['stockQuantity'] <= item['lowStockThreshold']).toList();
  List<Map<String, dynamic>> get expiredItems => _inventory.where((item) => 
      item['expiryDate'] != null && 
      DateTime.parse(item['expiryDate']).isBefore(DateTime.now())).toList();

  /// Load inventory data
  Future<void> loadInventory() async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      final inventory = await _stockistService.getInventory();
      _inventory = inventory.map((item) => {
        ...item,
        'lowStockThreshold': item['lowStockThreshold'] ?? 20,
        'stockQuantity': item['stockQuantity'] ?? 0,
      }).toList();
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load inventory: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load orders data
  Future<void> loadOrders() async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      final orders = await _stockistService.getOrders();
      _orders = orders;
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load orders: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load retailers data
  Future<void> loadRetailers() async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      final retailers = await _stockistService.getRetailers();
      _retailers = retailers.map((retailer) => {
        ...retailer,
        'totalOrders': retailer['totalOrders'] ?? 0,
        'pendingOrders': retailer['pendingOrders'] ?? 0,
        'totalRevenue': retailer['totalRevenue'] ?? 0.0,
        'isActive': retailer['isActive'] ?? true,
      }).toList();
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load retailers: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Update stock quantity
  Future<void> updateStockQuantity(String productId, int newQuantity) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      await _stockistService.updateStockQuantity(productId, newQuantity);
      
      // Update local state
      final index = _inventory.indexWhere((item) => item['id'] == productId);
      if (index != -1) {
        _inventory[index]['stockQuantity'] = newQuantity;
        notifyListeners();
      }
      
      // Check for low stock alerts
      if (newQuantity <= _inventory[index]['lowStockThreshold']) {
        _showLowStockAlert(_inventory[index]);
      }
      
    } catch (e) {
      _setError('Failed to update stock: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Create new order
  Future<void> createOrder(Map<String, dynamic> orderData) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      final order = await _stockistService.createOrder(orderData);
      _orders.insert(0, order);
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to create order: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      await _stockistService.updateOrderStatus(orderId, newStatus);
      
      // Update local state
      final index = _orders.indexWhere((order) => order['id'] == orderId);
      if (index != -1) {
        _orders[index]['status'] = newStatus;
        _orders[index]['updatedAt'] = DateTime.now().toIso8601String();
        notifyListeners();
      }
      
    } catch (e) {
      _setError('Failed to update order status: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Add new product to inventory
  Future<void> addProduct(Map<String, dynamic> productData) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      final product = await _stockistService.addProduct(productData);
      _inventory.add(product);
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to add product: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Update product information
  Future<void> updateProduct(String productId, Map<String, dynamic> updates) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      await _stockistService.updateProduct(productId, updates);
      
      // Update local state
      final index = _inventory.indexWhere((item) => item['id'] == productId);
      if (index != -1) {
        _inventory[index] = {..._inventory[index], ...updates};
        notifyListeners();
      }
      
    } catch (e) {
      _setError('Failed to update product: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Remove product from inventory
  Future<void> removeProduct(String productId) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      await _stockistService.removeProduct(productId);
      
      _inventory.removeWhere((item) => item['id'] == productId);
      notifyListeners();
      
    } catch (e) {
      _setError('Failed to remove product: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Get inventory analytics
  Map<String, dynamic> getInventoryAnalytics() {
    final totalValue = _inventory.fold<double>(
      0.0, (sum, item) => sum + (item['stockQuantity'] * item['price'] as double));
    
    final lowStockValue = lowStockItems.fold<double>(
      0.0, (sum, item) => sum + (item['stockQuantity'] * item['price'] as double));
    
    final expiredValue = expiredItems.fold<double>(
      0.0, (sum, item) => sum + (item['stockQuantity'] * item['price'] as double));

    return {
      'totalProducts': totalProducts,
      'totalValue': totalValue,
      'lowStockCount': lowStockCount,
      'lowStockValue': lowStockValue,
      'expiredCount': expiredItems.length,
      'expiredValue': expiredValue,
      'pendingOrders': pendingOrders,
      'activeRetailers': activeRetailers,
    };
  }

  /// Get order statistics
  Map<String, dynamic> getOrderStatistics() {
    final totalOrders = _orders.length;
    final pendingOrders = _orders.where((o) => o['status'] == 'pending').length;
    final approvedOrders = _orders.where((o) => o['status'] == 'approved').length;
    final dispatchedOrders = _orders.where((o) => o['status'] == 'dispatched').length;
    final completedOrders = _orders.where((o) => o['status'] == 'completed').length;
    
    final totalRevenue = _orders
        .where((o) => o['status'] == 'completed')
        .fold<double>(0.0, (sum, order) => sum + (order['totalAmount'] as double));

    return {
      'totalOrders': totalOrders,
      'pendingOrders': pendingOrders,
      'approvedOrders': approvedOrders,
      'dispatchedOrders': dispatchedOrders,
      'completedOrders': completedOrders,
      'totalRevenue': totalRevenue,
      'averageOrderValue': completedOrders > 0 ? totalRevenue / completedOrders : 0.0,
    };
  }

  /// Search inventory
  List<Map<String, dynamic>> searchInventory(String query) {
    if (query.isEmpty) return _inventory;
    
    return _inventory.where((item) {
      final name = item['name'].toString().toLowerCase();
      final sku = item['sku'].toString().toLowerCase();
      final manufacturer = item['manufacturer'].toString().toLowerCase();
      final searchQuery = query.toLowerCase();
      
      return name.contains(searchQuery) || 
             sku.contains(searchQuery) || 
             manufacturer.contains(searchQuery);
    }).toList();
  }

  /// Filter inventory by category
  List<Map<String, dynamic>> filterInventoryByCategory(String category) {
    if (category.isEmpty) return _inventory;
    
    return _inventory.where((item) => 
        item['category'].toString().toLowerCase() == category.toLowerCase()).toList();
  }

  /// Get low stock alerts
  List<Map<String, dynamic>> getLowStockAlerts() {
    return lowStockItems.map((item) => {
      'productId': item['id'],
      'productName': item['name'],
      'sku': item['sku'],
      'currentStock': item['stockQuantity'],
      'threshold': item['lowStockThreshold'],
      'urgency': _getUrgencyLevel(item['stockQuantity'], item['lowStockThreshold']),
      'recommendedOrder': _calculateRecommendedOrder(item),
    }).toList();
  }

  String _getUrgencyLevel(int currentStock, int threshold) {
    if (currentStock == 0) return 'critical';
    if (currentStock <= threshold * 0.5) return 'high';
    if (currentStock <= threshold) return 'medium';
    return 'low';
  }

  int _calculateRecommendedOrder(Map<String, dynamic> item) {
    final threshold = item['lowStockThreshold'] as int;
    final currentStock = item['stockQuantity'] as int;
    
    // Recommended order = threshold * 2 - currentStock
    return (threshold * 2 - currentStock).clamp(0, 999);
  }

  void _showLowStockAlert(Map<String, dynamic> item) {
    // TODO: Implement notification system
    debugPrint('Low stock alert for ${item['name']}: ${item['stockQuantity']} units');
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

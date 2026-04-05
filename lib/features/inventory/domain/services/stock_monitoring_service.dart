import 'dart:async';
import 'dart:math';
import 'package:dartz/dartz.dart';
import '../entities/stock_alert_entity.dart';
import '../repositories/stock_monitoring_repository.dart';
import '../../../../shared/utils/app_utils.dart';

/// Stock Monitoring Service
/// Real-time stock level monitoring and alert generation
class StockMonitoringService {
  final StockMonitoringRepository _repository;
  final AppUtils _appUtils;
  
  StreamSubscription<List<StockLevelHistory>>? _historySubscription;
  StreamSubscription<List<StockMonitoringConfig>>? _configSubscription;
  Timer? _monitoringTimer;
  Timer? _expiryCheckTimer;
  Timer? _cleanupTimer;
  
  StockMonitoringService({
    required StockMonitoringRepository repository,
    AppUtils? appUtils,
  }) : _repository = repository,
       _appUtils = appUtils ?? AppUtils();
  
  /// Start real-time stock monitoring
  Future<Either<String, void>> startMonitoring() async {
    try {
      // Stop any existing monitoring
      await stopMonitoring();
      
      // Start monitoring stock level changes
      _historySubscription = _repository
          .getStockLevelHistoryStream()
          .listen(_onStockLevelChanged);
      
      // Start monitoring configuration changes
      _configSubscription = _repository
          .getMonitoringConfigStream()
          .listen(_onConfigChanged);
      
      // Start periodic monitoring
      _startPeriodicMonitoring();
      
      // Start expiry monitoring
      _startExpiryMonitoring();
      
      // Start cleanup process
      _startCleanupProcess();
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to start stock monitoring: ${e.toString()}');
    }
  }
  
  /// Stop stock monitoring
  Future<Either<String, void>> stopMonitoring() async {
    try {
      await _historySubscription?.cancel();
      await _configSubscription?.cancel();
      _monitoringTimer?.cancel();
      _expiryCheckTimer?.cancel();
      _cleanupTimer?.cancel();
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to stop stock monitoring: ${e.toString()}');
    }
  }
  
  /// Handle stock level changes
  void _onStockLevelChanged(List<StockLevelHistory> changes) {
    for (final change in changes) {
      _processStockChange(change);
    }
  }
  
  /// Handle configuration changes
  void _onConfigChanged(List<StockMonitoringConfig> configs) {
    for (final config in configs) {
      _updateMonitoringConfig(config);
    }
  }
  
  /// Process individual stock change
  Future<void> _processStockChange(StockLevelHistory change) async {
    try {
      // Get current stock level
      final currentStockResult = await _repository.getCurrentStock(
        change.productId,
        change.warehouseId,
      );
      
      if (currentStockResult.isLeft()) return;
      
      final currentStock = currentStockResult.getOrElse(() => 0.0);
      
      // Get monitoring configuration
      final configResult = await _repository.getMonitoringConfig(
        change.productId,
        change.warehouseId,
      );
      
      if (configResult.isLeft()) return;
      
      final config = configResult.getOrElse(() => StockMonitoringConfig(
        id: '',
        productId: change.productId,
        warehouseId: change.warehouseId,
        isEnabled: true,
        minThreshold: 0.0,
        maxThreshold: double.infinity,
        reorderLevel: 0.0,
        reorderQuantity: 0.0,
        expiryWarningDays: 30,
        enableLowStockAlerts: true,
        enableOverstockAlerts: true,
        enableExpiryAlerts: true,
        enableMovementAlerts: false,
        enableQualityAlerts: false,
        notificationEmails: [],
        notificationPhones: [],
        alertFrequency: 'immediate',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      
      if (!config.isEnabled) return;
      
      // Check for different alert conditions
      await _checkLowStockAlert(currentStock, config, change);
      await _checkOverstockAlert(currentStock, config, change);
      await _checkReorderPointAlert(currentStock, config, change);
      await _checkMovementAlert(change);
      
    } catch (e) {
// print('Error processing stock change: $e'); // Removed for production
    }
  }
  
  /// Check for low stock alert
  Future<void> _checkLowStockAlert(
    double currentStock,
    StockMonitoringConfig config,
    StockLevelHistory change,
  ) async {
    if (!config.enableLowStockAlerts) return;
    
    if (currentStock <= config.minThreshold) {
      final severity = _calculateLowStockSeverity(currentStock, config);
      final alertType = currentStock == 0 
          ? StockAlertType.outOfStock 
          : StockAlertType.lowStock;
      
      await _createStockAlert(
        productId: config.productId,
        warehouseId: config.warehouseId,
        alertType: alertType,
        severity: severity,
        currentStock: currentStock,
        minThreshold: config.minThreshold,
        maxThreshold: config.maxThreshold,
        reorderLevel: config.reorderLevel,
        reorderQuantity: config.reorderQuantity,
        message: _generateLowStockMessage(currentStock, config, alertType),
        description: 'Stock level has fallen below minimum threshold',
        change: change,
      );
    }
  }
  
  /// Check for overstock alert
  Future<void> _checkOverstockAlert(
    double currentStock,
    StockMonitoringConfig config,
    StockLevelHistory change,
  ) async {
    if (!config.enableOverstockAlerts) return;
    
    if (currentStock >= config.maxThreshold) {
      await _createStockAlert(
        productId: config.productId,
        warehouseId: config.warehouseId,
        alertType: StockAlertType.overstock,
        severity: StockAlertSeverity.medium,
        currentStock: currentStock,
        minThreshold: config.minThreshold,
        maxThreshold: config.maxThreshold,
        reorderLevel: config.reorderLevel,
        reorderQuantity: config.reorderQuantity,
        message: _generateOverstockMessage(currentStock, config),
        description: 'Stock level has exceeded maximum threshold',
        change: change,
      );
    }
  }
  
  /// Check for reorder point alert
  Future<void> _checkReorderPointAlert(
    double currentStock,
    StockMonitoringConfig config,
    StockLevelHistory change,
  ) async {
    if (currentStock <= config.reorderLevel && currentStock > config.minThreshold) {
      await _createStockAlert(
        productId: config.productId,
        warehouseId: config.warehouseId,
        alertType: StockAlertType.reorderPoint,
        severity: StockAlertSeverity.high,
        currentStock: currentStock,
        minThreshold: config.minThreshold,
        maxThreshold: config.maxThreshold,
        reorderLevel: config.reorderLevel,
        reorderQuantity: config.reorderQuantity,
        message: _generateReorderMessage(currentStock, config),
        description: 'Stock has reached reorder point',
        change: change,
      );
    }
  }
  
  /// Check for movement alert
  Future<void> _checkMovementAlert(StockLevelHistory change) async {
    // Check for unusual stock movements
    final isUnusualMovement = _isUnusualMovement(change);
    
    if (isUnusualMovement) {
      await _createStockAlert(
        productId: change.productId,
        warehouseId: change.warehouseId,
        alertType: StockAlertType.stockMovement,
        severity: StockAlertSeverity.medium,
        currentStock: change.newStock,
        minThreshold: 0.0,
        maxThreshold: double.infinity,
        reorderLevel: 0.0,
        reorderQuantity: 0.0,
        message: _generateMovementMessage(change),
        description: 'Unusual stock movement detected',
        change: change,
      );
    }
  }
  
  /// Start periodic monitoring
  void _startPeriodicMonitoring() {
    _monitoringTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      await _performPeriodicCheck();
    });
  }
  
  /// Start expiry monitoring
  void _startExpiryMonitoring() {
    _expiryCheckTimer = Timer.periodic(const Duration(hours: 6), (timer) async {
      await _performExpiryCheck();
    });
  }
  
  /// Start cleanup process
  void _startCleanupProcess() {
    _cleanupTimer = Timer.periodic(const Duration(hours: 24), (timer) async {
      await _performCleanup();
    });
  }
  
  /// Perform periodic check
  Future<void> _performPeriodicCheck() async {
    try {
      // Get all active monitoring configurations
      final configsResult = await _repository.getAllMonitoringConfigs();
      
      if (configsResult.isLeft()) return;
      
      final configs = configsResult.getOrElse(() => []);
      
      for (final config in configs) {
        if (!config.isEnabled) continue;
        
        // Get current stock
        final stockResult = await _repository.getCurrentStock(
          config.productId,
          config.warehouseId,
        );
        
        if (stockResult.isLeft()) continue;
        
        final currentStock = stockResult.getOrElse(() => 0.0);
        
        // Check all alert conditions
        await _checkLowStockAlert(currentStock, config, StockLevelHistory(
          id: _appUtils.generateId(),
          productId: config.productId,
          warehouseId: config.warehouseId,
          previousStock: currentStock,
          newStock: currentStock,
          changeAmount: 0.0,
          changeType: StockChangeType.audit,
          timestamp: DateTime.now(),
        ));
        
        await _checkOverstockAlert(currentStock, config, StockLevelHistory(
          id: _appUtils.generateId(),
          productId: config.productId,
          warehouseId: config.warehouseId,
          previousStock: currentStock,
          newStock: currentStock,
          changeAmount: 0.0,
          changeType: StockChangeType.audit,
          timestamp: DateTime.now(),
        ));
      }
    } catch (e) {
// print('Error in periodic check: $e'); // Removed for production
    }
  }
  
  /// Perform expiry check
  Future<void> _performExpiryCheck() async {
    try {
      // Get products with expiry dates
      final expiringProductsResult = await _repository.getExpiringProducts();
      
      if (expiringProductsResult.isLeft()) return;
      
      final expiringProducts = expiringProductsResult.getOrElse(() => []);
      
      for (final product in expiringProducts) {
        final daysToExpiry = product.expiryDate != null
            ? product.expiryDate!.difference(DateTime.now()).inDays
            : -1;
        
        if (daysToExpiry >= 0 && daysToExpiry <= product.expiryWarningDays) {
          final severity = _calculateExpirySeverity(daysToExpiry);
          
          await _createStockAlert(
            productId: product.productId,
            warehouseId: product.warehouseId,
            alertType: StockAlertType.expiryAlert,
            severity: severity,
            currentStock: product.currentStock,
            minThreshold: 0.0,
            maxThreshold: double.infinity,
            reorderLevel: 0.0,
            reorderQuantity: 0.0,
            batchNumber: product.batchNumber,
            expiryDate: product.expiryDate,
            daysToExpiry: daysToExpiry,
            message: _generateExpiryMessage(product, daysToExpiry),
            description: 'Product is approaching expiry date',
          );
        }
      }
    } catch (e) {
// print('Error in expiry check: $e'); // Removed for production
    }
  }
  
  /// Perform cleanup
  Future<void> _performCleanup() async {
    try {
      // Clean up old resolved alerts
      await _repository.cleanupOldAlerts();
      
      // Clean up old history records
      await _repository.cleanupOldHistory();
      
      // Archive old alerts
      await _repository.archiveOldAlerts();
    } catch (e) {
// print('Error in cleanup: $e'); // Removed for production
    }
  }
  
  /// Create stock alert
  Future<void> _createStockAlert({
    required String productId,
    required String warehouseId,
    required StockAlertType alertType,
    required StockAlertSeverity severity,
    required double currentStock,
    required double minThreshold,
    required double maxThreshold,
    required double reorderLevel,
    required double reorderQuantity,
    String? batchNumber,
    DateTime? expiryDate,
    int daysToExpiry = 0,
    required String message,
    required String description,
    StockLevelHistory? change,
  }) async {
    try {
      // Check if similar alert already exists and is not resolved
      final existingAlertResult = await _repository.getUnresolvedAlert(
        productId,
        warehouseId,
        alertType,
      );
      
      if (existingAlertResult.isRight()) {
        final existingAlert = existingAlertResult.getOrElse(() => null);
        if (existingAlert != null) {
          // Update existing alert instead of creating new one
          await _updateExistingAlert(existingAlert, currentStock, message);
          return;
        }
      }
      
      // Get product and warehouse details
      final productResult = await _repository.getProductDetails(productId);
      final warehouseResult = await _repository.getWarehouseDetails(warehouseId);
      
      final product = productResult.getOrElse(() => ProductDetails(
        id: productId,
        name: 'Unknown Product',
        sku: '',
        category: '',
        supplierId: '',
        supplierName: '',
      ));
      
      final warehouse = warehouseResult.getOrElse(() => WarehouseDetails(
        id: warehouseId,
        name: 'Unknown Warehouse',
      ));
      
      // Create new alert
      final alert = StockAlertEntity(
        id: _appUtils.generateId(),
        productId: productId,
        productName: product.name,
        productSku: product.sku,
        productCategory: product.category,
        warehouseId: warehouseId,
        warehouseName: warehouse.name,
        alertType: alertType,
        severity: severity,
        currentStock: currentStock,
        minThreshold: minThreshold,
        maxThreshold: maxThreshold,
        reorderLevel: reorderLevel,
        reorderQuantity: reorderQuantity,
        supplierId: product.supplierId,
        supplierName: product.supplierName,
        batchNumber: batchNumber,
        expiryDate: expiryDate,
        daysToExpiry: daysToExpiry,
        message: message,
        description: description,
        isAcknowledged: false,
        isResolved: false,
        actions: _generateDefaultActions(alertType),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Save alert
      await _repository.createStockAlert(alert);
      
      // Send notifications
      await _sendNotifications(alert, product, warehouse);
      
    } catch (e) {
// print('Error creating stock alert: $e'); // Removed for production
    }
  }
  
  /// Update existing alert
  Future<void> _updateExistingAlert(
    StockAlertEntity existingAlert,
    double currentStock,
    String message,
  ) async {
    final updatedAlert = existingAlert.copyWith(
      currentStock: currentStock,
      message: message,
      updatedAt: DateTime.now(),
    );
    
    await _repository.updateStockAlert(updatedAlert);
  }
  
  /// Update monitoring configuration
  Future<void> _updateMonitoringConfig(StockMonitoringConfig config) async {
    await _repository.updateMonitoringConfig(config);
  }
  
  /// Send notifications for alert
  Future<void> _sendNotifications(
    StockAlertEntity alert,
    ProductDetails product,
    WarehouseDetails warehouse,
  ) async {
    try {
      // Get notification preferences
      final configResult = await _repository.getMonitoringConfig(
        alert.productId,
        alert.warehouseId,
      );
      
      if (configResult.isLeft()) return;
      
      final config = configResult.getOrElse(() => StockMonitoringConfig(
        id: '',
        productId: alert.productId,
        warehouseId: alert.warehouseId,
        isEnabled: true,
        minThreshold: 0.0,
        maxThreshold: double.infinity,
        reorderLevel: 0.0,
        reorderQuantity: 0.0,
        expiryWarningDays: 30,
        enableLowStockAlerts: true,
        enableOverstockAlerts: true,
        enableExpiryAlerts: true,
        enableMovementAlerts: false,
        enableQualityAlerts: false,
        notificationEmails: [],
        notificationPhones: [],
        alertFrequency: 'immediate',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      
      // Send email notifications
      for (final email in config.notificationEmails) {
        await _sendEmailNotification(alert, product, warehouse, email);
      }
      
      // Send SMS notifications
      for (final phone in config.notificationPhones) {
        await _sendSmsNotification(alert, product, warehouse, phone);
      }
      
      // Send push notifications
      await _sendPushNotification(alert, product, warehouse);
      
    } catch (e) {
// print('Error sending notifications: $e'); // Removed for production
    }
  }
  
  /// Send email notification
  Future<void> _sendEmailNotification(
    StockAlertEntity alert,
    ProductDetails product,
    WarehouseDetails warehouse,
    String email,
  ) async {
    // TODO: Implement email notification
// print('Sending email notification to $email for ${alert.alertType}'); // Removed for production
  }
  
  /// Send SMS notification
  Future<void> _sendSmsNotification(
    StockAlertEntity alert,
    ProductDetails product,
    WarehouseDetails warehouse,
    String phone,
  ) async {
    // TODO: Implement SMS notification
// print('Sending SMS notification to $phone for ${alert.alertType}'); // Removed for production
  }
  
  /// Send push notification
  Future<void> _sendPushNotification(
    StockAlertEntity alert,
    ProductDetails product,
    WarehouseDetails warehouse,
  ) async {
    // TODO: Implement push notification
// print('Sending push notification for ${alert.alertType}'); // Removed for production
  }
  
  /// Generate default actions for alert type
  List<StockAlertAction> _generateDefaultActions(StockAlertType alertType) {
    final actions = <StockAlertAction>[];
    
    switch (alertType) {
      case StockAlertType.lowStock:
      case StockAlertType.outOfStock:
      case StockAlertType.reorderPoint:
        actions.add(StockAlertAction(
          id: _appUtils.generateId(),
          alertId: '', // Will be set when alert is created
          actionType: StockAlertActionType.reorder,
          description: 'Reorder Product',
          isCompleted: false,
          createdAt: DateTime.now(),
        ));
        break;
      case StockAlertType.overstock:
        actions.add(StockAlertAction(
          id: _appUtils.generateId(),
          alertId: '', // Will be set when alert is created
          actionType: StockAlertActionType.transfer,
          description: 'Transfer Stock',
          isCompleted: false,
          createdAt: DateTime.now(),
        ));
        break;
      case StockAlertType.expiryAlert:
      case StockAlertType.batchExpiry:
        actions.add(StockAlertAction(
          id: _appUtils.generateId(),
          alertId: '', // Will be set when alert is created
          actionType: StockAlertActionType.dispose,
          description: 'Dispose Expired Stock',
          isCompleted: false,
          createdAt: DateTime.now(),
        ));
        break;
      default:
        actions.add(StockAlertAction(
          id: _appUtils.generateId(),
          alertId: '', // Will be set when alert is created
          actionType: StockAlertActionType.investigate,
          description: 'Investigate Issue',
          isCompleted: false,
          createdAt: DateTime.now(),
        ));
        break;
    }
    
    return actions;
  }
  
  /// Calculate low stock severity
  StockAlertSeverity _calculateLowStockSeverity(
    double currentStock,
    StockMonitoringConfig config,
  ) {
    if (currentStock == 0) {
      return StockAlertSeverity.critical;
    } else if (currentStock <= config.minThreshold * 0.5) {
      return StockAlertSeverity.high;
    } else if (currentStock <= config.minThreshold * 0.8) {
      return StockAlertSeverity.medium;
    } else {
      return StockAlertSeverity.low;
    }
  }
  
  /// Calculate expiry severity
  StockAlertSeverity _calculateExpirySeverity(int daysToExpiry) {
    if (daysToExpiry <= 0) {
      return StockAlertSeverity.critical;
    } else if (daysToExpiry <= 7) {
      return StockAlertSeverity.high;
    } else if (daysToExpiry <= 30) {
      return StockAlertSeverity.medium;
    } else {
      return StockAlertSeverity.low;
    }
  }
  
  /// Check if movement is unusual
  bool _isUnusualMovement(StockLevelHistory change) {
    // Simple heuristic: if change amount is more than 50% of current stock
    final changePercentage = (change.changeAmount.abs() / change.newStock) * 100;
    return changePercentage > 50;
  }
  
  /// Generate low stock message
  String _generateLowStockMessage(
    double currentStock,
    StockMonitoringConfig config,
    StockAlertType alertType,
  ) {
    if (alertType == StockAlertType.outOfStock) {
      return 'Product is OUT OF STOCK in ${config.warehouseId}';
    } else {
      return 'LOW STOCK: ${currentStock.toStringAsFixed(0)} units remaining (min: ${config.minThreshold.toStringAsFixed(0)})';
    }
  }
  
  /// Generate overstock message
  String _generateOverstockMessage(double currentStock, StockMonitoringConfig config) {
    return 'OVERSTOCK: ${currentStock.toStringAsFixed(0)} units (max: ${config.maxThreshold.toStringAsFixed(0)})';
  }
  
  /// Generate reorder message
  String _generateReorderMessage(double currentStock, StockMonitoringConfig config) {
    return 'REORDER POINT: ${currentStock.toStringAsFixed(0)} units (reorder at: ${config.reorderLevel.toStringAsFixed(0)})';
  }
  
  /// Generate movement message
  String _generateMovementMessage(StockLevelHistory change) {
    final direction = change.changeAmount > 0 ? 'increase' : 'decrease';
    return 'Unusual stock $direction: ${change.changeAmount.abs().toStringAsFixed(0)} units';
  }
  
  /// Generate expiry message
  String _generateExpiryMessage(ProductDetails product, int daysToExpiry) {
    if (daysToExpiry <= 0) {
      return 'EXPIRED: ${product.name} has expired';
    } else {
      return 'EXPIRING SOON: ${product.name} expires in $daysToExpiry days';
    }
  }
}

/// Product Details for notifications
class ProductDetails {
  final String id;
  final String name;
  final String sku;
  final String category;
  final String supplierId;
  final String supplierName;
  
  const ProductDetails({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.supplierId,
    required this.supplierName,
  });
}

/// Warehouse Details for notifications
class WarehouseDetails {
  final String id;
  final String name;
  
  const WarehouseDetails({
    required this.id,
    required this.name,
  });
}

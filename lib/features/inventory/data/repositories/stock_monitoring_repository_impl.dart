import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/stock_alert_entity.dart';
import '../../domain/repositories/stock_monitoring_repository.dart';
import '../../../../shared/services/storage_service.dart';
import '../../../../shared/utils/app_utils.dart';

/// Stock Monitoring Repository Implementation
/// Handles data persistence and retrieval for stock monitoring
class StockMonitoringRepositoryImpl implements StockMonitoringRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final StorageService _storageService;
  final AppUtils _appUtils;
  
  StockMonitoringRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    StorageService? storageService,
    AppUtils? appUtils,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance,
       _storageService = storageService ?? StorageService(),
       _appUtils = appUtils ?? AppUtils();
  
  @override
  Stream<List<StockLevelHistory>> getStockLevelHistoryStream() {
    return _firestore
        .collection('stock_level_history')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StockLevelHistory.fromMap(doc.data()!))
            .toList());
  }
  
  @override
  Stream<List<StockMonitoringConfig>> getMonitoringConfigStream() {
    return _firestore
        .collection('stock_monitoring_configs')
        .where('isEnabled', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StockMonitoringConfig.fromMap(doc.data()!))
            .toList());
  }
  
  @override
  Future<Either<String, double>> getCurrentStock(String productId, String warehouseId) async {
    try {
      // Get latest stock level from history
      final query = await _firestore
          .collection('stock_level_history')
          .where('productId', isEqualTo: productId)
          .where('warehouseId', isEqualTo: warehouseId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();
      
      if (query.docs.isEmpty) {
        return const Right(0.0);
      }
      
      final latestRecord = StockLevelHistory.fromMap(query.docs.first.data());
      return Right(latestRecord.newStock);
    } catch (e) {
      return Left('Failed to get current stock: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, StockMonitoringConfig>> getMonitoringConfig(
    String productId,
    String warehouseId,
  ) async {
    try {
      final doc = await _firestore
          .collection('stock_monitoring_configs')
          .where('productId', isEqualTo: productId)
          .where('warehouseId', isEqualTo: warehouseId)
          .limit(1)
          .get();
      
      if (doc.docs.isEmpty) {
        // Return default config
        return Right(StockMonitoringConfig(
          id: _appUtils.generateId(),
          productId: productId,
          warehouseId: warehouseId,
          isEnabled: true,
          minThreshold: 10.0,
          maxThreshold: 1000.0,
          reorderLevel: 50.0,
          reorderQuantity: 100.0,
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
      }
      
      final config = StockMonitoringConfig.fromMap(doc.docs.first.data());
      return Right(config);
    } catch (e) {
      return Left('Failed to get monitoring config: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, List<StockMonitoringConfig>>> getAllMonitoringConfigs() async {
    try {
      final query = await _firestore
          .collection('stock_monitoring_configs')
          .where('isEnabled', isEqualTo: true)
          .get();
      
      final configs = query.docs
          .map((doc) => StockMonitoringConfig.fromMap(doc.data()!))
          .toList();
      
      return Right(configs);
    } catch (e) {
      return Left('Failed to get all monitoring configs: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, void>> updateMonitoringConfig(StockMonitoringConfig config) async {
    try {
      await _firestore
          .collection('stock_monitoring_configs')
          .doc(config.id)
          .update(config.toMap());
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to update monitoring config: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, void>> createStockAlert(StockAlertEntity alert) async {
    try {
      // Create alert in Firestore
      await _firestore
          .collection('stock_alerts')
          .doc(alert.id)
          .set(alert.toMap());
      
      // Cache locally
      await _storageService.saveStockAlert(alert);
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to create stock alert: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, void>> updateStockAlert(StockAlertEntity alert) async {
    try {
      // Update in Firestore
      await _firestore
          .collection('stock_alerts')
          .doc(alert.id)
          .update(alert.toMap());
      
      // Update cache
      await _storageService.saveStockAlert(alert);
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to update stock alert: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, StockAlertEntity>> getUnresolvedAlert(
    String productId,
    String warehouseId,
    StockAlertType alertType,
  ) async {
    try {
      final query = await _firestore
          .collection('stock_alerts')
          .where('productId', isEqualTo: productId)
          .where('warehouseId', isEqualTo: warehouseId)
          .where('alertType', isEqualTo: alertType.name)
          .where('isResolved', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();
      
      if (query.docs.isEmpty) {
        return const Left('No unresolved alert found');
      }
      
      final alert = StockAlertEntity.fromMap(query.docs.first.data());
      return Right(alert);
    } catch (e) {
      return Left('Failed to get unresolved alert: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, List<StockAlertEntity>>> getActiveAlerts({
    String? productId,
    String? warehouseId,
    StockAlertType? alertType,
    StockAlertSeverity? severity,
  }) async {
    try {
      Query query = _firestore
          .collection('stock_alerts')
          .where('isResolved', isEqualTo: false);
      
      if (productId != null) {
        query = query.where('productId', isEqualTo: productId);
      }
      
      if (warehouseId != null) {
        query = query.where('warehouseId', isEqualTo: warehouseId);
      }
      
      if (alertType != null) {
        query = query.where('alertType', isEqualTo: alertType!.name);
      }
      
      if (severity != null) {
        query = query.where('severity', isEqualTo: severity!.name);
      }
      
      final snapshot = await query
          .orderBy('createdAt', descending: true)
          .get();
      
      final alerts = snapshot.docs
          .map((doc) => StockAlertEntity.fromMap(doc.data()!))
          .toList();
      
      return Right(alerts);
    } catch (e) {
      return Left('Failed to get active alerts: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, List<StockAlertEntity>>> getAlertHistory({
    String? productId,
    String? warehouseId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection('stock_alerts');
      
      if (productId != null) {
        query = query.where('productId', isEqualTo: productId);
      }
      
      if (warehouseId != null) {
        query = query.where('warehouseId', isEqualTo: warehouseId);
      }
      
      if (startDate != null) {
        query = query.where('createdAt', isGreaterThanOrEqualTo: startDate);
      }
      
      if (endDate != null) {
        query = query.where('createdAt', isLessThanOrEqualTo: endDate);
      }
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final snapshot = await query
          .orderBy('createdAt', descending: true)
          .get();
      
      final alerts = snapshot.docs
          .map((doc) => StockAlertEntity.fromMap(doc.data()!))
          .toList();
      
      return Right(alerts);
    } catch (e) {
      return Left('Failed to get alert history: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, void>> acknowledgeAlert(String alertId, String userId) async {
    try {
      await _firestore
          .collection('stock_alerts')
          .doc(alertId)
          .update({
            'isAcknowledged': true,
            'acknowledgedBy': userId,
            'acknowledgedAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          });
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to acknowledge alert: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, void>> resolveAlert(
    String alertId,
    String userId,
    String resolutionNotes,
  ) async {
    try {
      await _firestore
          .collection('stock_alerts')
          .doc(alertId)
          .update({
            'isResolved': true,
            'resolvedBy': userId,
            'resolvedAt': DateTime.now().toIso8601String(),
            'resolutionNotes': resolutionNotes,
            'updatedAt': DateTime.now().toIso8601String(),
          });
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to resolve alert: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, List<ExpiringProduct>>> getExpiringProducts() async {
    try {
      final thirtyDaysFromNow = DateTime.now().add(const Duration(days: 30));
      
      final query = await _firestore
          .collection('products')
          .where('expiryDate', isLessThanOrEqualTo: thirtyDaysFromNow)
          .where('expiryDate', isGreaterThan: DateTime.now())
          .get();
      
      final products = query.docs
          .map((doc) {
            final data = doc.data()!;
            final currentStock = data['currentStock'] ?? 0.0;
            final expiryDate = DateTime.parse(data['expiryDate']);
            final daysToExpiry = expiryDate.difference(DateTime.now()).inDays;
            
            return ExpiringProduct(
              productId: doc.id,
              warehouseId: data['warehouseId'] ?? '',
              currentStock: currentStock,
              batchNumber: data['batchNumber'],
              expiryDate: expiryDate,
              daysToExpiry: daysToExpiry,
              expiryWarningDays: data['expiryWarningDays'] ?? 30,
            );
          })
          .toList();
      
      return Right(products);
    } catch (e) {
      return Left('Failed to get expiring products: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, ProductDetails>> getProductDetails(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      
      if (!doc.exists) {
        return const Left('Product not found');
      }
      
      final data = doc.data()!;
      final product = ProductDetails(
        id: doc.id,
        name: data['name'] ?? '',
        sku: data['sku'] ?? '',
        category: data['category'] ?? '',
        supplierId: data['supplierId'] ?? '',
        supplierName: data['supplierName'] ?? '',
      );
      
      return Right(product);
    } catch (e) {
      return Left('Failed to get product details: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, WarehouseDetails>> getWarehouseDetails(String warehouseId) async {
    try {
      final doc = await _firestore.collection('warehouses').doc(warehouseId).get();
      
      if (!doc.exists) {
        return const Left('Warehouse not found');
      }
      
      final data = doc.data()!;
      final warehouse = WarehouseDetails(
        id: doc.id,
        name: data['name'] ?? '',
      );
      
      return Right(warehouse);
    } catch (e) {
      return Left('Failed to get warehouse details: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, void>> cleanupOldAlerts() async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      
      await _firestore
          .collection('stock_alerts')
          .where('isResolved', isEqualTo: true)
          .where('resolvedAt', isLessThan: thirtyDaysAgo)
          .get()
          .then((snapshot) {
        for (final doc in snapshot.docs) {
          doc.reference.delete();
        }
      });
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to cleanup old alerts: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, void>> cleanupOldHistory() async {
    try {
      final ninetyDaysAgo = DateTime.now().subtract(const Duration(days: 90));
      
      await _firestore
          .collection('stock_level_history')
          .where('timestamp', isLessThan: ninetyDaysAgo)
          .get()
          .then((snapshot) {
        for (final doc in snapshot.docs) {
          doc.reference.delete();
        }
      });
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to cleanup old history: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, void>> archiveOldAlerts() async {
    try {
      final ninetyDaysAgo = DateTime.now().subtract(const Duration(days: 90));
      
      await _firestore
          .collection('stock_alerts')
          .where('isResolved', isEqualTo: true)
          .where('resolvedAt', isLessThan: ninetyDaysAgo)
          .get()
          .then((snapshot) {
        for (final doc in snapshot.docs) {
          // Move to archive collection
          final archiveData = doc.data();
          archiveData['archivedAt'] = DateTime.now().toIso8601String();
          
          _firestore.collection('stock_alerts_archive').add(archiveData);
          doc.reference.delete();
        }
      });
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to archive old alerts: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, Map<String, dynamic>>> getStockMonitoringStatistics() async {
    try {
      // Get active alerts count
      final activeAlertsQuery = await _firestore
          .collection('stock_alerts')
          .where('isResolved', isEqualTo: false)
          .get();
      
      final activeAlertsCount = activeAlertsQuery.docs.length;
      
      // Get alerts by severity
      final criticalAlertsQuery = await _firestore
          .collection('stock_alerts')
          .where('isResolved', isEqualTo: false)
          .where('severity', isEqualTo: StockAlertSeverity.critical.name)
          .get();
      
      final criticalAlertsCount = criticalAlertsQuery.docs.length;
      
      // Get alerts by type
      final lowStockAlertsQuery = await _firestore
          .collection('stock_alerts')
          .where('isResolved', isEqualTo: false)
          .where('alertType', whereIn: [
            StockAlertType.lowStock.name,
            StockAlertType.outOfStock.name,
          ])
          .get();
      
      final lowStockAlertsCount = lowStockAlertsQuery.docs.length;
      
      // Get expiring products count
      final expiringProductsQuery = await _firestore
          .collection('products')
          .where('expiryDate', isLessThanOrEqualTo: DateTime.now().add(const Duration(days: 30)))
          .where('expiryDate', isGreaterThan: DateTime.now())
          .get();
      
      final expiringProductsCount = expiringProductsQuery.docs.length;
      
      // Get monitoring configs count
      final configsQuery = await _firestore
          .collection('stock_monitoring_configs')
          .where('isEnabled', isEqualTo: true)
          .get();
      
      final monitoredProductsCount = configsQuery.docs.length;
      
      final statistics = {
        'activeAlerts': activeAlertsCount,
        'criticalAlerts': criticalAlertsCount,
        'lowStockAlerts': lowStockAlertsCount,
        'expiringProducts': expiringProductsCount,
        'monitoredProducts': monitoredProductsCount,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      
      return Right(statistics);
    } catch (e) {
      return Left('Failed to get stock monitoring statistics: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, List<StockAlertEntity>>> getAlertsByDateRange(
    DateTime startDate,
    DateTime endDate,
    {String? productId, String? warehouseId}
  ) async {
    try {
      Query query = _firestore.collection('stock_alerts')
          .where('createdAt', isGreaterThanOrEqualTo: startDate)
          .where('createdAt', isLessThanOrEqualTo: endDate);
      
      if (productId != null) {
        query = query.where('productId', isEqualTo: productId);
      }
      
      if (warehouseId != null) {
        query = query.where('warehouseId', isEqualTo: warehouseId);
      }
      
      final snapshot = await query
          .orderBy('createdAt', descending: true)
          .get();
      
      final alerts = snapshot.docs
          .map((doc) => StockAlertEntity.fromMap(doc.data()!))
          .toList();
      
      return Right(alerts);
    } catch (e) {
      return Left('Failed to get alerts by date range: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, void>> createStockLevelHistory(StockLevelHistory history) async {
    try {
      await _firestore
          .collection('stock_level_history')
          .doc(history.id)
          .set(history.toMap());
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to create stock level history: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, List<StockLevelHistory>>> getStockLevelHistory(
    String productId,
    String warehouseId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      Query query = _firestore
          .collection('stock_level_history')
          .where('productId', isEqualTo: productId)
          .where('warehouseId', isEqualTo: warehouseId);
      
      if (startDate != null) {
        query = query.where('timestamp', isGreaterThanOrEqualTo: startDate);
      }
      
      if (endDate != null) {
        query = query.where('timestamp', isLessThanOrEqualTo: endDate);
      }
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final snapshot = await query
          .orderBy('timestamp', descending: true)
          .get();
      
      final history = snapshot.docs
          .map((doc) => StockLevelHistory.fromMap(doc.data()!))
          .toList();
      
      return Right(history);
    } catch (e) {
      return Left('Failed to get stock level history: ${e.toString()}');
    }
  }
}

/// Expiring Product for monitoring
class ExpiringProduct {
  final String productId;
  final String warehouseId;
  final double currentStock;
  final String? batchNumber;
  final DateTime expiryDate;
  final int daysToExpiry;
  final int expiryWarningDays;
  
  const ExpiringProduct({
    required this.productId,
    required this.warehouseId,
    required this.currentStock,
    this.batchNumber,
    required this.expiryDate,
    required this.daysToExpiry,
    required this.expiryWarningDays,
  });
}

import 'package:flutter/foundation.dart';
import '../../domain/entities/wishlist_entity.dart';
import '../models/product_model.dart';
import 'product_catalog_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Wishlist Service
/// Manages wishlist persistence and operations
class WishlistService {
  final ProductCatalogService _productService = ProductCatalogService();
  static const String _wishlistsKey = 'wishlists';
  static const String _alertsKey = 'wishlist_alerts';

  /// Get all wishlists
  Future<List<WishlistEntity>> getWishlists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistsJson = prefs.getString(_wishlistsKey);
      
      if (wishlistsJson == null) {
        // Create default wishlist if none exists
        final defaultWishlist = WishlistEntity(
          id: 'default',
          name: 'My Wishlist',
          description: 'Default wishlist',
          productIds: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isDefault: true,
        );
        await saveWishlist(defaultWishlist);
        return [defaultWishlist];
      }

      final List<dynamic> decoded = json.decode(wishlistsJson);
      return decoded
          .map((json) => WishlistEntity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading wishlists: $e');
      return [];
    }
  }

  /// Save wishlist
  Future<void> saveWishlist(WishlistEntity wishlist) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlists = await getWishlists();
      
      // Check if wishlist already exists
      final existingIndex = wishlists.indexWhere((w) => w.id == wishlist.id);
      if (existingIndex != -1) {
        wishlists[existingIndex] = wishlist;
      } else {
        wishlists.add(wishlist);
      }

      final wishlistsJson = json.encode(
        wishlists.map((w) => w.toJson()).toList(),
      );
      await prefs.setString(_wishlistsKey, wishlistsJson);
    } catch (e) {
      debugPrint('Error saving wishlist: $e');
      rethrow;
    }
  }

  /// Delete wishlist
  Future<void> deleteWishlist(String wishlistId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlists = await getWishlists();
      
      wishlists.removeWhere((w) => w.id == wishlistId);

      final wishlistsJson = json.encode(
        wishlists.map((w) => w.toJson()).toList(),
      );
      await prefs.setString(_wishlistsKey, wishlistsJson);
    } catch (e) {
      debugPrint('Error deleting wishlist: $e');
      rethrow;
    }
  }

  /// Get wishlist alerts
  Future<List<WishlistAlertEntity>> getAlerts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alertsJson = prefs.getString(_alertsKey);
      
      if (alertsJson == null) {
        return [];
      }

      final List<dynamic> decoded = json.decode(alertsJson);
      return decoded
          .map((json) => WishlistAlertEntity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading alerts: $e');
      return [];
    }
  }

  /// Save alert
  Future<void> saveAlert(WishlistAlertEntity alert) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alerts = await getAlerts();
      
      // Check if alert already exists
      final existingIndex = alerts.indexWhere((a) => a.id == alert.id);
      if (existingIndex != -1) {
        alerts[existingIndex] = alert;
      } else {
        alerts.add(alert);
      }

      final alertsJson = json.encode(
        alerts.map((a) => a.toJson()).toList(),
      );
      await prefs.setString(_alertsKey, alertsJson);
    } catch (e) {
      debugPrint('Error saving alert: $e');
      rethrow;
    }
  }

  /// Delete alert
  Future<void> deleteAlert(String alertId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alerts = await getAlerts();
      
      alerts.removeWhere((a) => a.id == alertId);

      final alertsJson = json.encode(
        alerts.map((a) => a.toJson()).toList(),
      );
      await prefs.setString(_alertsKey, alertsJson);
    } catch (e) {
      debugPrint('Error deleting alert: $e');
      rethrow;
    }
  }

  /// Get products for wishlist
  Future<List<Product>> getWishlistProducts(List<String> productIds) async {
    try {
      final allProducts = await _productService.loadRegisteredProducts();
      return allProducts.where((p) => productIds.contains(p.id)).toList();
    } catch (e) {
      debugPrint('Error loading wishlist products: $e');
      return [];
    }
  }

  /// Check price drops for wishlist products
  Future<List<WishlistAlertEntity>> checkPriceDrops(
    List<Product> wishlistProducts,
    List<WishlistAlertEntity> alerts,
  ) async {
    final triggeredAlerts = <WishlistAlertEntity>[];

    for (final alert in alerts) {
      if (!alert.isActive || alert.isTriggered) continue;

      final product = wishlistProducts.firstWhere(
        (p) => p.id == alert.productId,
        orElse: () => Product(
          id: '',
          name: '',
          genericName: '',
          manufacturer: '',
          brand: '',
          category: '',
          dosageForm: '',
          strength: '',
          price: 0,
          stockQuantity: 0,
          expiryDate: DateTime.now(),
          description: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      if (alert.type == AlertType.priceDrop && alert.thresholdPrice != null) {
        if (product.finalPrice < alert.thresholdPrice!) {
          final updatedAlert = alert.copyWith(
            triggeredAt: DateTime.now(),
          );
          await saveAlert(updatedAlert);
          triggeredAlerts.add(updatedAlert);
        }
      }
    }

    return triggeredAlerts;
  }

  /// Check stock status for wishlist products
  Future<List<WishlistAlertEntity>> checkStockStatus(
    List<Product> wishlistProducts,
    List<WishlistAlertEntity> alerts,
  ) async {
    final triggeredAlerts = <WishlistAlertEntity>[];

    for (final alert in alerts) {
      if (!alert.isActive || alert.isTriggered) continue;

      final product = wishlistProducts.firstWhere(
        (p) => p.id == alert.productId,
        orElse: () => Product(
          id: '',
          name: '',
          genericName: '',
          manufacturer: '',
          brand: '',
          category: '',
          dosageForm: '',
          strength: '',
          price: 0,
          stockQuantity: 0,
          expiryDate: DateTime.now(),
          description: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      if (alert.type == AlertType.stockAvailable && product.stockQuantity > 0) {
        final updatedAlert = alert.copyWith(
          triggeredAt: DateTime.now(),
        );
        await saveAlert(updatedAlert);
        triggeredAlerts.add(updatedAlert);
      } else if (alert.type == AlertType.lowStock && product.isLowStock) {
        final updatedAlert = alert.copyWith(
          triggeredAt: DateTime.now(),
        );
        await saveAlert(updatedAlert);
        triggeredAlerts.add(updatedAlert);
      } else if (alert.type == AlertType.outOfStock && product.stockQuantity == 0) {
        final updatedAlert = alert.copyWith(
          triggeredAt: DateTime.now(),
        );
        await saveAlert(updatedAlert);
        triggeredAlerts.add(updatedAlert);
      }
    }

    return triggeredAlerts;
  }
}

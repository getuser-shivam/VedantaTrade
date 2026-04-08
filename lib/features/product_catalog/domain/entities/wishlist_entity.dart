import 'package:equatable/equatable.dart';
import '../../data/models/product_model.dart';

/// Wishlist Entity
/// Represents a user's wishlist with products
class WishlistEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final List<String> productIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDefault;
  final bool isShared;
  final String? sharedWith;
  final bool enablePriceAlerts;
  final bool enableStockAlerts;

  const WishlistEntity({
    required this.id,
    required this.name,
    this.description,
    required this.productIds,
    required this.createdAt,
    required this.updatedAt,
    this.isDefault = false,
    this.isShared = false,
    this.sharedWith,
    this.enablePriceAlerts = true,
    this.enableStockAlerts = true,
  });

  /// Create copy with updated values
  WishlistEntity copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? productIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDefault,
    bool? isShared,
    String? sharedWith,
    bool? enablePriceAlerts,
    bool? enableStockAlerts,
  }) {
    return WishlistEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      productIds: productIds ?? this.productIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDefault: isDefault ?? this.isDefault,
      isShared: isShared ?? this.isShared,
      sharedWith: sharedWith ?? this.sharedWith,
      enablePriceAlerts: enablePriceAlerts ?? this.enablePriceAlerts,
      enableStockAlerts: enableStockAlerts ?? this.enableStockAlerts,
    );
  }

  /// Get product count
  int get productCount => productIds.length;

  /// Check if wishlist contains product
  bool containsProduct(String productId) => productIds.contains(productId);

  /// Add product to wishlist
  WishlistEntity addProduct(String productId) {
    if (productIds.contains(productId)) return this;
    return copyWith(
      productIds: [...productIds, productId],
      updatedAt: DateTime.now(),
    );
  }

  /// Remove product from wishlist
  WishlistEntity removeProduct(String productId) {
    return copyWith(
      productIds: productIds.where((id) => id != productId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'productIds': productIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDefault': isDefault,
      'isShared': isShared,
      'sharedWith': sharedWith,
      'enablePriceAlerts': enablePriceAlerts,
      'enableStockAlerts': enableStockAlerts,
    };
  }

  /// Create from JSON
  factory WishlistEntity.fromJson(Map<String, dynamic> json) {
    return WishlistEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      productIds: List<String>.from(json['productIds'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isDefault: json['isDefault'] as bool? ?? false,
      isShared: json['isShared'] as bool? ?? false,
      sharedWith: json['sharedWith'] as String?,
      enablePriceAlerts: json['enablePriceAlerts'] as bool? ?? true,
      enableStockAlerts: json['enableStockAlerts'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        productIds,
        createdAt,
        updatedAt,
        isDefault,
        isShared,
        sharedWith,
        enablePriceAlerts,
        enableStockAlerts,
      ];
}

/// Wishlist Alert Entity
/// Represents an alert for a wishlist product
class WishlistAlertEntity extends Equatable {
  final String id;
  final String wishlistId;
  final String productId;
  final AlertType type;
  final double? thresholdPrice;
  final DateTime createdAt;
  final bool isActive;
  final DateTime? triggeredAt;

  const WishlistAlertEntity({
    required this.id,
    required this.wishlistId,
    required this.productId,
    required this.type,
    this.thresholdPrice,
    required this.createdAt,
    this.isActive = true,
    this.triggeredAt,
  });

  /// Create copy with updated values
  WishlistAlertEntity copyWith({
    String? id,
    String? wishlistId,
    String? productId,
    AlertType? type,
    double? thresholdPrice,
    DateTime? createdAt,
    bool? isActive,
    DateTime? triggeredAt,
  }) {
    return WishlistAlertEntity(
      id: id ?? this.id,
      wishlistId: wishlistId ?? this.wishlistId,
      productId: productId ?? this.productId,
      type: type ?? this.type,
      thresholdPrice: thresholdPrice ?? this.thresholdPrice,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      triggeredAt: triggeredAt ?? this.triggeredAt,
    );
  }

  /// Check if alert has been triggered
  bool get isTriggered => triggeredAt != null;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wishlistId': wishlistId,
      'productId': productId,
      'type': type.toString(),
      'thresholdPrice': thresholdPrice,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'triggeredAt': triggeredAt?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory WishlistAlertEntity.fromJson(Map<String, dynamic> json) {
    return WishlistAlertEntity(
      id: json['id'] as String,
      wishlistId: json['wishlistId'] as String,
      productId: json['productId'] as String,
      type: AlertType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => AlertType.priceDrop,
      ),
      thresholdPrice: json['thresholdPrice']?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      triggeredAt: json['triggeredAt'] != null
          ? DateTime.parse(json['triggeredAt'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        wishlistId,
        productId,
        type,
        thresholdPrice,
        createdAt,
        isActive,
        triggeredAt,
      ];
}

/// Alert Type
enum AlertType {
  priceDrop,
  priceIncrease,
  stockAvailable,
  lowStock,
  outOfStock,
}

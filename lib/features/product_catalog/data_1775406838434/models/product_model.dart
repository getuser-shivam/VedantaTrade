import 'package:flutter/material.dart';

/// Product Model for VedantaTrade Catalog
class Product {
  final String id;
  final String name;
  final String description;
  final String category;
  final String manufacturer;
  final String sku;
  final double price;
  final double? discountedPrice;
  final int stockQuantity;
  final int minOrderQuantity;
  final String unit;
  final List<String> images;
  final List<ProductSpecification> specifications;
  final ProductStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? batchNumber;
  final DateTime? expiryDate;
  final double? weight;
  final double? volume;
  final String? storageConditions;
  final List<String> tags;
  final bool isPrescription;
  final bool isControlled;
  final String? regulatoryInfo;
  final double? vatRate;
  final String? hsnCode;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.manufacturer,
    required this.sku,
    required this.price,
    required this.stockQuantity,
    required this.minOrderQuantity,
    required this.unit,
    required this.images,
    required this.specifications,
    required this.status,
    required this.createdAt,
    this.discountedPrice,
    this.updatedAt,
    this.batchNumber,
    this.expiryDate,
    this.weight,
    this.volume,
    this.storageConditions,
    this.tags = const [],
    this.isPrescription = false,
    this.isControlled = false,
    this.regulatoryInfo,
    this.vatRate,
    this.hsnCode,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      manufacturer: json['manufacturer'] as String,
      sku: json['sku'] as String,
      price: (json['price'] as num).toDouble(),
      discountedPrice: json['discountedPrice'] != null 
          ? (json['discountedPrice'] as num).toDouble() 
          : null,
      stockQuantity: json['stockQuantity'] as int,
      minOrderQuantity: json['minOrderQuantity'] as int,
      unit: json['unit'] as String,
      images: List<String>.from(json['images'] as List),
      specifications: (json['specifications'] as List)
          .map((spec) => ProductSpecification.fromJson(spec as Map<String, dynamic>))
          .toList(),
      status: ProductStatus.values.firstWhere(
        (status) => status.toString() == json['status'],
        orElse: () => ProductStatus.active,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
      batchNumber: json['batchNumber'] as String?,
      expiryDate: json['expiryDate'] != null 
          ? DateTime.parse(json['expiryDate'] as String) 
          : null,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      volume: json['volume'] != null ? (json['volume'] as num).toDouble() : null,
      storageConditions: json['storageConditions'] as String?,
      tags: List<String>.from(json['tags'] as List? ?? []),
      isPrescription: json['isPrescription'] as bool? ?? false,
      isControlled: json['isControlled'] as bool? ?? false,
      regulatoryInfo: json['regulatoryInfo'] as String?,
      vatRate: json['vatRate'] != null ? (json['vatRate'] as num).toDouble() : null,
      hsnCode: json['hsnCode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'manufacturer': manufacturer,
      'sku': sku,
      'price': price,
      'discountedPrice': discountedPrice,
      'stockQuantity': stockQuantity,
      'minOrderQuantity': minOrderQuantity,
      'unit': unit,
      'images': images,
      'specifications': specifications.map((spec) => spec.toJson()).toList(),
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'batchNumber': batchNumber,
      'expiryDate': expiryDate?.toIso8601String(),
      'weight': weight,
      'volume': volume,
      'storageConditions': storageConditions,
      'tags': tags,
      'isPrescription': isPrescription,
      'isControlled': isControlled,
      'regulatoryInfo': regulatoryInfo,
      'vatRate': vatRate,
      'hsnCode': hsnCode,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? manufacturer,
    String? sku,
    double? price,
    double? discountedPrice,
    int? stockQuantity,
    int? minOrderQuantity,
    String? unit,
    List<String>? images,
    List<ProductSpecification>? specifications,
    ProductStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? batchNumber,
    DateTime? expiryDate,
    double? weight,
    double? volume,
    String? storageConditions,
    List<String>? tags,
    bool? isPrescription,
    bool? isControlled,
    String? regulatoryInfo,
    double? vatRate,
    String? hsnCode,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      manufacturer: manufacturer ?? this.manufacturer,
      sku: sku ?? this.sku,
      price: price ?? this.price,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minOrderQuantity: minOrderQuantity ?? this.minOrderQuantity,
      unit: unit ?? this.unit,
      images: images ?? this.images,
      specifications: specifications ?? this.specifications,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      weight: weight ?? this.weight,
      volume: volume ?? this.volume,
      storageConditions: storageConditions ?? this.storageConditions,
      tags: tags ?? this.tags,
      isPrescription: isPrescription ?? this.isPrescription,
      isControlled: isControlled ?? this.isControlled,
      regulatoryInfo: regulatoryInfo ?? this.regulatoryInfo,
      vatRate: vatRate ?? this.vatRate,
      hsnCode: hsnCode ?? this.hsnCode,
    );
  }

  /// Get effective price (discounted price if available, otherwise regular price)
  double get effectivePrice => discountedPrice ?? price;

  /// Check if product is in stock
  bool get isInStock => stockQuantity > 0;

  /// Check if product is low in stock
  bool get isLowStock => stockQuantity <= minOrderQuantity * 2;

  /// Check if product is expired
  bool get isExpired => expiryDate != null && expiryDate!.isBefore(DateTime.now());

  /// Check if product is expiring soon (within 30 days)
  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final thirtyDaysFromNow = DateTime.now().add(const Duration(days: 30));
    return expiryDate!.isBefore(thirtyDaysFromNow);
  }

  /// Get formatted price with NPR currency
  String get formattedPrice => 'NPR ${effectivePrice.toStringAsFixed(2)}';

  /// Get formatted discounted price
  String get formattedDiscountedPrice => discountedPrice != null 
      ? 'NPR ${discountedPrice!.toStringAsFixed(2)}' 
      : '';

  /// Get discount percentage
  double get discountPercentage => discountedPrice != null 
      ? ((price - discountedPrice!) / price * 100) 
      : 0.0;
}

/// Product Specification Model
class ProductSpecification {
  final String name;
  final String value;
  final String? unit;
  final String? type;

  ProductSpecification({
    required this.name,
    required this.value,
    this.unit,
    this.type,
  });

  factory ProductSpecification.fromJson(Map<String, dynamic> json) {
    return ProductSpecification(
      name: json['name'] as String,
      value: json['value'] as String,
      unit: json['unit'] as String?,
      type: json['type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      'unit': unit,
      'type': type,
    };
  }
}

/// Product Status Enum
enum ProductStatus {
  active,
  inactive,
  discontinued,
  outOfStock,
  limited,
  prescriptionOnly,
  controlled,
}

/// Product Category Enum
enum ProductCategory {
  medicines,
  medicalDevices,
  consumables,
  surgical,
  diagnostics,
  wellness,
  generic,
  otc,
}

/// Product Filter Options
class ProductFilter {
  final String? category;
  final String? manufacturer;
  final String? status;
  final double? minPrice;
  final double? maxPrice;
  final bool? inStock;
  final bool? prescriptionOnly;
  final List<String>? tags;
  final String? searchQuery;

  ProductFilter({
    this.category,
    this.manufacturer,
    this.status,
    this.minPrice,
    this.maxPrice,
    this.inStock,
    this.prescriptionOnly,
    this.tags,
    this.searchQuery,
  });

  bool matches(Product product) {
    if (category != null && product.category != category) return false;
    if (manufacturer != null && !product.manufacturer.toLowerCase().contains(manufacturer!.toLowerCase())) return false;
    if (status != null && product.status.toString() != status) return false;
    if (minPrice != null && product.price < minPrice!) return false;
    if (maxPrice != null && product.price > maxPrice!) return false;
    if (inStock != null && product.isInStock != inStock) return false;
    if (prescriptionOnly != null && product.isPrescription != prescriptionOnly) return false;
    if (searchQuery != null && !product.name.toLowerCase().contains(searchQuery!.toLowerCase())) return false;
    if (tags != null && !tags!.any((tag) => product.tags.contains(tag))) return false;
    
    return true;
  }
}

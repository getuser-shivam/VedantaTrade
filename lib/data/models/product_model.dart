class Product {
  final int id;
  final String name;
  final String genericName;
  final String description;
  final double price;
  final int stock;
  final int minStockLevel;
  final int maxStockLevel;
  final int reorderPoint;
  final String? imageUrl;
  final String productCode;
  final String? batchNumber;
  final DateTime? expiryDate;
  final DateTime? manufacturingDate;
  final String? storageConditions;
  final String? dosageForm;
  final String? strength;
  final String? packaging;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? categoryId;
  final String? categoryName;
  final int? subcategoryId;
  final String? subcategoryName;
  final int? manufacturerId;
  final String? manufacturerName;
  final String stockStatus;
  final int transactionCount;
  final double? avgSalePrice;

  Product({
    required this.id,
    required this.name,
    required this.genericName,
    required this.description,
    required this.price,
    required this.stock,
    required this.minStockLevel,
    required this.maxStockLevel,
    required this.reorderPoint,
    this.imageUrl,
    required this.productCode,
    this.batchNumber,
    this.expiryDate,
    this.manufacturingDate,
    this.storageConditions,
    this.dosageForm,
    this.strength,
    this.packaging,
    required this.createdAt,
    required this.updatedAt,
    this.categoryId,
    this.categoryName,
    this.subcategoryId,
    this.subcategoryName,
    this.manufacturerId,
    this.manufacturerName,
    required this.stockStatus,
    required this.transactionCount,
    this.avgSalePrice,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['item_id'] ?? json['id'],
      name: json['item_name'] ?? json['name'] ?? '',
      genericName: json['generic_name'] ?? '',
      description: json['description'] ?? '',
      price: (json['mrp'] ?? json['unit_price'] ?? json['price'] ?? 0).toDouble(),
      stock: json['stock_quantity'] ?? json['current_stock'] ?? json['stock'] ?? 0,
      minStockLevel: json['min_stock_level'] ?? 0,
      maxStockLevel: json['max_stock_level'] ?? 0,
      reorderPoint: json['reorder_point'] ?? 0,
      imageUrl: json['image_url'],
      productCode: json['product_code'] ?? '',
      batchNumber: json['batch_number'],
      expiryDate: json['expiry_date'] != null ? DateTime.parse(json['expiry_date']) : null,
      manufacturingDate: json['manufacturing_date'] != null ? DateTime.parse(json['manufacturing_date']) : null,
      storageConditions: json['storage_conditions'],
      dosageForm: json['dosage_form'],
      strength: json['strength'],
      packaging: json['packaging'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      subcategoryId: json['subcategory_id'],
      subcategoryName: json['subcategory_name'],
      manufacturerId: json['manufacturer_id'],
      manufacturerName: json['manufacturer_name'],
      stockStatus: json['stock_status'] ?? 'unknown',
      transactionCount: json['transaction_count'] ?? 0,
      avgSalePrice: json['avg_sale_price']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'generic_name': genericName,
      'description': description,
      'price': price,
      'stock': stock,
      'min_stock_level': minStockLevel,
      'max_stock_level': maxStockLevel,
      'reorder_point': reorderPoint,
      'image_url': imageUrl,
      'product_code': productCode,
      'batch_number': batchNumber,
      'expiry_date': expiryDate?.toIso8601String(),
      'manufacturing_date': manufacturingDate?.toIso8601String(),
      'storage_conditions': storageConditions,
      'dosage_form': dosageForm,
      'strength': strength,
      'packaging': packaging,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'category_id': categoryId,
      'category_name': categoryName,
      'subcategory_id': subcategoryId,
      'subcategory_name': subcategoryName,
      'manufacturer_id': manufacturerId,
      'manufacturer_name': manufacturerName,
      'stock_status': stockStatus,
      'transaction_count': transactionCount,
      'avg_sale_price': avgSalePrice,
    };
  }

  Product copyWith({
    int? id,
    String? name,
    String? genericName,
    String? description,
    double? price,
    int? stock,
    int? minStockLevel,
    int? maxStockLevel,
    int? reorderPoint,
    String? imageUrl,
    String? productCode,
    String? batchNumber,
    DateTime? expiryDate,
    DateTime? manufacturingDate,
    String? storageConditions,
    String? dosageForm,
    String? strength,
    String? packaging,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? categoryId,
    String? categoryName,
    int? subcategoryId,
    String? subcategoryName,
    int? manufacturerId,
    String? manufacturerName,
    String? stockStatus,
    int? transactionCount,
    double? avgSalePrice,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      genericName: genericName ?? this.genericName,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      maxStockLevel: maxStockLevel ?? this.maxStockLevel,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      imageUrl: imageUrl ?? this.imageUrl,
      productCode: productCode ?? this.productCode,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      manufacturingDate: manufacturingDate ?? this.manufacturingDate,
      storageConditions: storageConditions ?? this.storageConditions,
      dosageForm: dosageForm ?? this.dosageForm,
      strength: strength ?? this.strength,
      packaging: packaging ?? this.packaging,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      subcategoryName: subcategoryName ?? this.subcategoryName,
      manufacturerId: manufacturerId ?? this.manufacturerId,
      manufacturerName: manufacturerName ?? this.manufacturerName,
      stockStatus: stockStatus ?? this.stockStatus,
      transactionCount: transactionCount ?? this.transactionCount,
      avgSalePrice: avgSalePrice ?? this.avgSalePrice,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Product{id: $id, name: $name, price: $price, stock: $stock}';
  }

  // Helper methods
  bool get isLowStock => stock <= minStockLevel && stock > 0;
  bool get isOutOfStock => stock == 0;
  bool get isInStock => stock > minStockLevel;
  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final now = DateTime.now();
    final threeMonthsFromNow = now.add(const Duration(days: 90));
    return expiryDate!.isBefore(threeMonthsFromNow);
  }

  String get formattedPrice => 'NPR ${price.toStringAsFixed(2)}';
  String get formattedStock => '$stock units';
  
  String get stockStatusText {
    switch (stockStatus) {
      case 'in_stock':
        return 'In Stock';
      case 'low_stock':
        return 'Low Stock';
      case 'out_of_stock':
        return 'Out of Stock';
      default:
        return 'Unknown';
    }
  }
}

class Category {
  final int id;
  final String name;
  final String? description;
  final int? parentId;
  final String? imageUrl;
  final DateTime createdAt;
  final int productCount;
  final int subcategoryCount;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.parentId,
    this.imageUrl,
    required this.createdAt,
    required this.productCount,
    required this.subcategoryCount,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      parentId: json['parent_id'],
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']),
      productCount: json['product_count'] ?? 0,
      subcategoryCount: json['subcategory_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'parent_id': parentId,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'product_count': productCount,
      'subcategory_count': subcategoryCount,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Category{id: $id, name: $name, productCount: $productCount}';
  }
}

class Manufacturer {
  final int id;
  final String name;
  final String? description;
  final String? address;
  final String? phone;
  final String? email;
  final String? website;
  final String? licenseNumber;
  final DateTime createdAt;
  final int productCount;

  Manufacturer({
    required this.id,
    required this.name,
    this.description,
    this.address,
    this.phone,
    this.email,
    this.website,
    this.licenseNumber,
    required this.createdAt,
    required this.productCount,
  });

  factory Manufacturer.fromJson(Map<String, dynamic> json) {
    return Manufacturer(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      licenseNumber: json['license_number'],
      createdAt: DateTime.parse(json['created_at']),
      productCount: json['product_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'phone': phone,
      'email': email,
      'website': website,
      'license_number': licenseNumber,
      'created_at': createdAt.toIso8601String(),
      'product_count': productCount,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Manufacturer && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Manufacturer{id: $id, name: $name, productCount: $productCount}';
  }
}

class ProductSearchResult {
  final List<Product> products;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;
  final Map<String, dynamic> filters;
  final Map<String, dynamic> searchMetadata;

  ProductSearchResult({
    required this.products,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
    required this.filters,
    required this.searchMetadata,
  });

  factory ProductSearchResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final pagination = data['pagination'];
    
    return ProductSearchResult(
      products: (data['products'] as List).map((p) => Product.fromJson(p)).toList(),
      totalCount: pagination['total'] ?? 0,
      currentPage: pagination['current_page'] ?? 1,
      totalPages: pagination['total_pages'] ?? 1,
      hasNextPage: pagination['has_next'] ?? false,
      hasPreviousPage: pagination['has_prev'] ?? false,
      filters: data['filters'] ?? {},
      searchMetadata: data['search_metadata'] ?? {},
    );
  }
}

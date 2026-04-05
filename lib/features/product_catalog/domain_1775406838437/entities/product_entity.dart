import 'package:equatable/equatable.dart';

/// Product Entity - Domain layer entity for product data
class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String category;
  final String description;
  final List<String> images;
  final double price; // This maps to MRP
  final String form;
  final List<String> ingredients;
  final String dosage;
  final String packaging;
  final bool featured;
  
  // Future-proofing / Inventory fields
  final int stockQuantity;
  final double? ptr; // Price to Retailer
  final double? pts; // Price to Stockist
  final String manufacturer;
  final String? genericName;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.category,
    this.description = '',
    this.images = const [],
    required this.price,
    this.form = '',
    this.ingredients = const [],
    this.dosage = '',
    this.packaging = '',
    this.featured = false,
    this.stockQuantity = 0,
    this.ptr,
    this.pts,
    this.manufacturer = '',
    this.genericName,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        description,
        images,
        price,
        form,
        ingredients,
        dosage,
        packaging,
        featured,
        stockQuantity,
        ptr,
        pts,
        manufacturer,
        genericName,
        isActive,
        createdAt,
        updatedAt,
      ];

  ProductEntity copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    List<String>? images,
    double? price,
    String? form,
    List<String>? ingredients,
    String? dosage,
    String? packaging,
    bool? featured,
    int? stockQuantity,
    double? ptr,
    double? pts,
    String? manufacturer,
    String? genericName,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      images: images ?? this.images,
      price: price ?? this.price,
      form: form ?? this.form,
      ingredients: ingredients ?? this.ingredients,
      dosage: dosage ?? this.dosage,
      packaging: packaging ?? this.packaging,
      featured: featured ?? this.featured,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      ptr: ptr ?? this.ptr,
      pts: pts ?? this.pts,
      manufacturer: manufacturer ?? this.manufacturer,
      genericName: genericName ?? this.genericName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ProductEntity(id: $id, name: $name, category: $category, manufacturer: $manufacturer)';
  }

  /// Get formatted price
  String get formattedPrice => '₹${price.toStringAsFixed(2)}';

  /// Get formatted PTR
  String get formattedPtr => ptr != null ? '₹${ptr!.toStringAsFixed(2)}' : 'N/A';

  /// Get formatted PTS
  String get formattedPts => pts != null ? '₹${pts!.toStringAsFixed(2)}' : 'N/A';

  /// Check if product is in stock
  bool get isInStock => stockQuantity > 0;

  /// Check if product has low stock
  bool get hasLowStock => stockQuantity > 0 && stockQuantity <= 10;

  /// Check if product is out of stock
  bool get isOutOfStock => stockQuantity <= 0;
} 

  factory ProductEntity.fromJson(Map<String, dynamic> json) {
    // Handling both products.json format and potential API format
    return ProductEntity(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['item_name'] ?? '',
      category: json['category']?.toString() ?? 'Uncategorized',
      description: json['description']?.toString() ?? '',
      images: json['images'] != null 
          ? List<String>.from(json['images']) 
          : (json['imageUrl'] != null ? [json['imageUrl']] : (json['image_url'] != null ? [json['image_url']] : [])),
      price: (json['price']?.toDouble() ?? 0.0),
      form: json['form']?.toString() ?? '',
      ingredients: json['ingredients'] != null ? List<String>.from(json['ingredients']) : [],
      dosage: json['dosage']?.toString() ?? '',
      packaging: json['packaging']?.toString() ?? json['packaging']?.toString() ?? '',
      featured: json['featured'] ?? false,
      stockQuantity: json['stock_quantity']?.toInt() ?? 0,
      ptr: json['ptr']?.toDouble(),
      pts: json['pts']?.toDouble(),
      manufacturer: json['manufacturer']?.toString() ?? 'Vedanta TradeLink',
      genericName: json['generic_name']?.toString(),
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'images': images,
      'price': price,
      'form': form,
      'ingredients': ingredients,
      'dosage': dosage,
      'packaging': packaging,
      'featured': featured,
      'stockQuantity': stockQuantity,
      'ptr': ptr,
      'pts': pts,
      'manufacturer': manufacturer,
      'genericName': genericName,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // UI Helpers
  String get firstImage => images.isNotEmpty ? images.first : 'assets/images/placeholder.png';
  
  String get searchableText {
    return [
      name,
      category,
      description,
      manufacturer,
      genericName ?? '',
      ...ingredients,
      form,
      packaging,
    ].join(' ').toLowerCase();
  }

  String get formattedPrice => 'NPR ${price.toStringAsFixed(2)}';
  
  bool get isLowStock => stockQuantity > 0 && stockQuantity <= 10;
  bool get isOutOfStock => stockQuantity == 0;
  bool get isInStock => stockQuantity > 10;

  String get stockStatus {
    if (isOutOfStock) return 'out_of_stock';
    if (isLowStock) return 'low_stock';
    return 'in_stock';
  }
}

class Category {
  final String name;
  final String? description;
  final String? imageUrl;
  final int productCount;

  Category({
    required this.name,
    this.description,
    this.imageUrl,
    this.productCount = 0,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'] ?? json['category'] ?? '',
      description: json['description'],
      imageUrl: json['imageUrl'] ?? json['image_url'],
      productCount: json['product_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'product_count': productCount,
    };
  }
}

class Manufacturer {
  final String name;
  final String? description;
  final String? licenseNumber;

  Manufacturer({
    required this.name,
    this.description,
    this.licenseNumber,
  });

  factory Manufacturer.fromJson(Map<String, dynamic> json) {
    return Manufacturer(
      name: json['name'] ?? json['manufacturer'] ?? '',
      description: json['description'],
      licenseNumber: json['license_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'license_number': licenseNumber,
    };
  }
}

class ProductSearchResult {
  final List<Product> products;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool hasNextPage;

  ProductSearchResult({
    required this.products,
    required this.totalCount,
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasNextPage = false,
  });

  factory ProductSearchResult.fromJson(Map<String, dynamic> json) {
    final productsList = (json['products'] as List?)
            ?.map((p) => Product.fromJson(p))
            .toList() ??
        [];
    return ProductSearchResult(
      products: productsList,
      totalCount: json['total'] ?? productsList.length,
      currentPage: json['current_page'] ?? 1,
      totalPages: json['total_pages'] ?? 1,
      hasNextPage: json['has_next'] ?? false,
    );
  }
}

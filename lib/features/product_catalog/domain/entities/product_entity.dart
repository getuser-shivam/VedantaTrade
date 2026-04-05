import 'package:equatable/equatable.dart';

/// Product Entity
/// Represents a pharmaceutical product in the system
class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String category;
  final String brand;
  final String manufacturer;
  final String dosage;
  final String formulation;
  final String imageUrl;
  final double price;
  final double discountedPrice;
  final int stockQuantity;
  final int minOrderQuantity;
  final String sku;
  final List<String> tags;
  final bool isActive;
  final bool requiresPrescription;
  final DateTime? expiryDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? rating;
  final int? reviewCount;
  final ProductAvailability availability;
  final List<ProductVariant> variants;
  final Map<String, dynamic> metadata;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.brand,
    required this.manufacturer,
    required this.dosage,
    required this.formulation,
    required this.imageUrl,
    required this.price,
    this.discountedPrice = 0.0,
    required this.stockQuantity,
    this.minOrderQuantity = 1,
    required this.sku,
    this.tags = const [],
    this.isActive = true,
    this.requiresPrescription = false,
    this.expiryDate,
    required this.createdAt,
    required this.updatedAt,
    this.rating,
    this.reviewCount,
    this.availability = ProductAvailability.inStock,
    this.variants = const [],
    this.metadata = const {},
  });

  /// Get effective price (discounted if available)
  double get effectivePrice => discountedPrice > 0 ? discountedPrice : price;

  /// Get discount percentage
  double get discountPercentage {
    if (discountedPrice <= 0 || price <= 0) return 0.0;
    return ((price - discountedPrice) / price) * 100;
  }

  /// Check if product is on sale
  bool get isOnSale => discountedPrice > 0 && discountedPrice < price;

  /// Check if product is in stock
  bool get isInStock => stockQuantity > 0 && availability == ProductAvailability.inStock;

  /// Check if product is low on stock
  bool get isLowStock => stockQuantity > 0 && stockQuantity <= minOrderQuantity * 2;

  /// Check if product is out of stock
  bool get isOutOfStock => stockQuantity <= 0 || availability == ProductAvailability.outOfStock;

  /// Check if product is expiring soon (within 30 days)
  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final now = DateTime.now();
    final thirtyDaysFromNow = now.add(const Duration(days: 30));
    return expiryDate!.isBefore(thirtyDaysFromNow);
  }

  /// Check if product has expired
  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }

  /// Get formatted price with currency
  String get formattedPrice => 'NPR ${effectivePrice.toStringAsFixed(2)}';

  /// Get formatted original price
  String get formattedOriginalPrice => 'NPR ${price.toStringAsFixed(2)}';

  /// Get formatted discount percentage
  String get formattedDiscount => '${discountPercentage.toStringAsFixed(0)}% OFF';

  /// Get stock status text
  String get stockStatus {
    if (isExpired) return 'Expired';
    if (isOutOfStock) return 'Out of Stock';
    if (isLowStock) return 'Low Stock';
    return 'In Stock';
  }

  /// Get stock status color
  String get stockStatusColor {
    if (isExpired) return '#FF5252'; // Red
    if (isOutOfStock) return '#FF5252'; // Red
    if (isLowStock) return '#FFA726'; // Orange
    return '#52C41A'; // Green
  }

  /// Create copy with updated values
  ProductEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? brand,
    String? manufacturer,
    String? dosage,
    String? formulation,
    String? imageUrl,
    double? price,
    double? discountedPrice,
    int? stockQuantity,
    int? minOrderQuantity,
    String? sku,
    List<String>? tags,
    bool? isActive,
    bool? requiresPrescription,
    DateTime? expiryDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? rating,
    int? reviewCount,
    ProductAvailability? availability,
    List<ProductVariant>? variants,
    Map<String, dynamic>? metadata,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      manufacturer: manufacturer ?? this.manufacturer,
      dosage: dosage ?? this.dosage,
      formulation: formulation ?? this.formulation,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minOrderQuantity: minOrderQuantity ?? this.minOrderQuantity,
      sku: sku ?? this.sku,
      tags: tags ?? this.tags,
      isActive: isActive ?? this.isActive,
      requiresPrescription: requiresPrescription ?? this.requiresPrescription,
      expiryDate: expiryDate ?? this.expiryDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      availability: availability ?? this.availability,
      variants: variants ?? this.variants,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        brand,
        manufacturer,
        dosage,
        formulation,
        imageUrl,
        price,
        discountedPrice,
        stockQuantity,
        minOrderQuantity,
        sku,
        tags,
        isActive,
        requiresPrescription,
        expiryDate,
        createdAt,
        updatedAt,
        rating,
        reviewCount,
        availability,
        variants,
        metadata,
      ];

  @override
  String toString() {
    return 'ProductEntity(id: $id, name: $name, sku: $sku, price: $effectivePrice)';
  }
}

/// Product Variant
/// Represents different variants of a product (e.g., different sizes, colors)
class ProductVariant extends Equatable {
  final String id;
  final String name;
  final String? value;
  final double? priceAdjustment;
  final int? stockQuantity;
  final String? imageUrl;

  const ProductVariant({
    required this.id,
    required this.name,
    this.value,
    this.priceAdjustment,
    this.stockQuantity,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, name, value, priceAdjustment, stockQuantity, imageUrl];
}

/// Product Availability
enum ProductAvailability {
  inStock,
  lowStock,
  outOfStock,
  discontinued,
  preOrder,
}

/// Product Category
class ProductCategory extends Equatable {
  final String id;
  final String name;
  final String? parentId;
  final String? iconUrl;
  final int productCount;
  final List<ProductCategory> subcategories;
  final bool isActive;

  const ProductCategory({
    required this.id,
    required this.name,
    this.parentId,
    this.iconUrl,
    this.productCount = 0,
    this.subcategories = const [],
    this.isActive = true,
  });

  bool get hasSubcategories => subcategories.isNotEmpty;

  bool get isRootCategory => parentId == null;

  @override
  List<Object?> get props => [
        id,
        name,
        parentId,
        iconUrl,
        productCount,
        subcategories,
        isActive,
      ];
}

/// Product Filter Options
class ProductFilterOptions extends Equatable {
  final List<String> categories;
  final List<String> brands;
  final List<String> manufacturers;
  final List<String> dosageForms;
  final List<String> tags;
  final double? minPrice;
  final double? maxPrice;
  final bool? inStockOnly;
  final bool? onSaleOnly;
  final bool? requiresPrescription;
  final ProductAvailability? availability;
  final double? minRating;
  final String? sortBy;
  final String? sortOrder;

  const ProductFilterOptions({
    this.categories = const [],
    this.brands = const [],
    this.manufacturers = const [],
    this.dosageForms = const [],
    this.tags = const [],
    this.minPrice,
    this.maxPrice,
    this.inStockOnly,
    this.onSaleOnly,
    this.requiresPrescription,
    this.availability,
    this.minRating,
    this.sortBy,
    this.sortOrder,
  });

  bool get hasActiveFilters =>
      categories.isNotEmpty ||
      brands.isNotEmpty ||
      manufacturers.isNotEmpty ||
      dosageForms.isNotEmpty ||
      tags.isNotEmpty ||
      minPrice != null ||
      maxPrice != null ||
      inStockOnly == true ||
      onSaleOnly == true ||
      requiresPrescription != null ||
      availability != null ||
      minRating != null ||
      sortBy != null ||
      sortOrder != null;

  int get activeFilterCount {
    int count = 0;
    if (categories.isNotEmpty) count++;
    if (brands.isNotEmpty) count++;
    if (manufacturers.isNotEmpty) count++;
    if (dosageForms.isNotEmpty) count++;
    if (tags.isNotEmpty) count++;
    if (minPrice != null) count++;
    if (maxPrice != null) count++;
    if (inStockOnly == true) count++;
    if (onSaleOnly == true) count++;
    if (requiresPrescription != null) count++;
    if (availability != null) count++;
    if (minRating != null) count++;
    if (sortBy != null) count++;
    if (sortOrder != null) count++;
    return count;
  }

  ProductFilterOptions copyWith({
    List<String>? categories,
    List<String>? brands,
    List<String>? manufacturers,
    List<String>? dosageForms,
    List<String>? tags,
    double? minPrice,
    double? maxPrice,
    bool? inStockOnly,
    bool? onSaleOnly,
    bool? requiresPrescription,
    ProductAvailability? availability,
    double? minRating,
    String? sortBy,
    String? sortOrder,
  }) {
    return ProductFilterOptions(
      categories: categories ?? this.categories,
      brands: brands ?? this.brands,
      manufacturers: manufacturers ?? this.manufacturers,
      dosageForms: dosageForms ?? this.dosageForms,
      tags: tags ?? this.tags,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      inStockOnly: inStockOnly ?? this.inStockOnly,
      onSaleOnly: onSaleOnly ?? this.onSaleOnly,
      requiresPrescription: requiresPrescription ?? this.requiresPrescription,
      availability: availability ?? this.availability,
      minRating: minRating ?? this.minRating,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object?> get props => [
        categories,
        brands,
        manufacturers,
        dosageForms,
        tags,
        minPrice,
        maxPrice,
        inStockOnly,
        onSaleOnly,
        requiresPrescription,
        availability,
        minRating,
        sortBy,
        sortOrder,
      ];
}

/// Product Sort Options
enum ProductSortOption {
  nameAsc('name', 'asc'),
  nameDesc('name', 'desc'),
  priceAsc('price', 'asc'),
  priceDesc('price', 'desc'),
  ratingAsc('rating', 'asc'),
  ratingDesc('rating', 'desc'),
  newest('createdAt', 'desc'),
  oldest('createdAt', 'asc'),
  stockAsc('stockQuantity', 'asc'),
  stockDesc('stockQuantity', 'desc');

  const ProductSortOption(this.field, this.order);
  final String field;
  final String order;
}

/// Product Search Result
class ProductSearchResult extends Equatable {
  final List<ProductEntity> products;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;
  final ProductFilterOptions appliedFilters;
  final ProductSortOption? appliedSort;
  final Duration searchTime;

  const ProductSearchResult({
    required this.products,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    this.hasNextPage = false,
    this.hasPreviousPage = false,
    required this.appliedFilters,
    this.appliedSort,
    required this.searchTime,
  });

  bool get hasResults => products.isNotEmpty;

  bool get hasMoreResults => hasNextPage;

  @override
  List<Object?> get props => [
        products,
        totalCount,
        currentPage,
        totalPages,
        hasNextPage,
        hasPreviousPage,
        appliedFilters,
        appliedSort,
        searchTime,
      ];
}

import 'package:equatable/equatable.dart';

/// Product Filter Entity
/// Represents filtering options for product catalog
class ProductFilterEntity extends Equatable {
  final String? searchQuery;
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
  final bool? isActiveOnly;
  final DateTime? expiryDateRangeStart;
  final DateTime? expiryDateRangeEnd;

  const ProductFilterEntity({
    this.searchQuery,
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
    this.isActiveOnly,
    this.expiryDateRangeStart,
    this.expiryDateRangeEnd,
  });

  /// Check if any filters are active
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
      sortOrder != null ||
      isActiveOnly == true ||
      expiryDateRangeStart != null ||
      expiryDateRangeEnd != null ||
      (searchQuery != null && searchQuery!.isNotEmpty);

  /// Get count of active filters
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
    if (isActiveOnly == true) count++;
    if (expiryDateRangeStart != null) count++;
    if (expiryDateRangeEnd != null) count++;
    if (searchQuery != null && searchQuery!.isNotEmpty) count++;
    return count;
  }

  /// Check if price range is active
  bool get hasPriceRange => minPrice != null || maxPrice != null;

  /// Check if expiry date range is active
  bool get hasExpiryDateRange => expiryDateRangeStart != null || expiryDateRangeEnd != null;

  /// Get formatted price range
  String get formattedPriceRange {
    if (minPrice == null && maxPrice == null) return 'Any Price';
    if (minPrice != null && maxPrice != null) {
      return 'NPR ${minPrice!.toStringAsFixed(0)} - NPR ${maxPrice!.toStringAsFixed(0)}';
    }
    if (minPrice != null) {
      return 'NPR ${minPrice!.toStringAsFixed(0)} and above';
    }
    if (maxPrice != null) {
      return 'Up to NPR ${maxPrice!.toStringAsFixed(0)}';
    }
    return 'Any Price';
  }

  /// Get formatted expiry date range
  String get formattedExpiryDateRange {
    if (expiryDateRangeStart == null && expiryDateRangeEnd == null) return 'Any Date';
    if (expiryDateRangeStart != null && expiryDateRangeEnd != null) {
      return '${_formatDate(expiryDateRangeStart!)} - ${_formatDate(expiryDateRangeEnd!)}';
    }
    if (expiryDateRangeStart != null) {
      return 'From ${_formatDate(expiryDateRangeStart!)}';
    }
    if (expiryDateRangeEnd != null) {
      return 'Until ${_formatDate(expiryDateRangeEnd!)}';
    }
    return 'Any Date';
  }

  /// Create copy with updated values
  ProductFilterEntity copyWith({
    String? searchQuery,
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
    bool? isActiveOnly,
    DateTime? expiryDateRangeStart,
    DateTime? expiryDateRangeEnd,
  }) {
    return ProductFilterEntity(
      searchQuery: searchQuery ?? this.searchQuery,
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
      isActiveOnly: isActiveOnly ?? this.isActiveOnly,
      expiryDateRangeStart: expiryDateRangeStart ?? this.expiryDateRangeStart,
      expiryDateRangeEnd: expiryDateRangeEnd ?? this.expiryDateRangeEnd,
    );
  }

  /// Clear all filters
  ProductFilterEntity clearAll() {
    return const ProductFilterEntity();
  }

  /// Clear specific filter category
  ProductFilterEntity clearCategory(String category) {
    switch (category) {
      case 'search':
        return copyWith(searchQuery: null);
      case 'categories':
        return copyWith(categories: const []);
      case 'brands':
        return copyWith(brands: const []);
      case 'manufacturers':
        return copyWith(manufacturers: const []);
      case 'dosageForms':
        return copyWith(dosageForms: const []);
      case 'tags':
        return copyWith(tags: const []);
      case 'price':
        return copyWith(minPrice: null, maxPrice: null);
      case 'stock':
        return copyWith(inStockOnly: null);
      case 'sale':
        return copyWith(onSaleOnly: null);
      case 'prescription':
        return copyWith(requiresPrescription: null);
      case 'availability':
        return copyWith(availability: null);
      case 'rating':
        return copyWith(minRating: null);
      case 'sort':
        return copyWith(sortBy: null, sortOrder: null);
      case 'active':
        return copyWith(isActiveOnly: null);
      case 'expiry':
        return copyWith(expiryDateRangeStart: null, expiryDateRangeEnd: null);
      default:
        return this;
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'searchQuery': searchQuery,
      'categories': categories,
      'brands': brands,
      'manufacturers': manufacturers,
      'dosageForms': dosageForms,
      'tags': tags,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'inStockOnly': inStockOnly,
      'onSaleOnly': onSaleOnly,
      'requiresPrescription': requiresPrescription,
      'availability': availability?.name,
      'minRating': minRating,
      'sortBy': sortBy,
      'sortOrder': sortOrder,
      'isActiveOnly': isActiveOnly,
      'expiryDateRangeStart': expiryDateRangeStart?.toIso8601String(),
      'expiryDateRangeEnd': expiryDateRangeEnd?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory ProductFilterEntity.fromJson(Map<String, dynamic> json) {
    return ProductFilterEntity(
      searchQuery: json['searchQuery'],
      categories: List<String>.from(json['categories'] ?? []),
      brands: List<String>.from(json['brands'] ?? []),
      manufacturers: List<String>.from(json['manufacturers'] ?? []),
      dosageForms: List<String>.from(json['dosageForms'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      minPrice: json['minPrice']?.toDouble(),
      maxPrice: json['maxPrice']?.toDouble(),
      inStockOnly: json['inStockOnly'],
      onSaleOnly: json['onSaleOnly'],
      requiresPrescription: json['requiresPrescription'],
      availability: json['availability'] != null 
          ? ProductAvailability.values.firstWhere(
              (e) => e.name == json['availability'],
              orElse: () => ProductAvailability.inStock,
            )
          : null,
      minRating: json['minRating']?.toDouble(),
      sortBy: json['sortBy'],
      sortOrder: json['sortOrder'],
      isActiveOnly: json['isActiveOnly'],
      expiryDateRangeStart: json['expiryDateRangeStart'] != null
          ? DateTime.parse(json['expiryDateRangeStart'])
          : null,
      expiryDateRangeEnd: json['expiryDateRangeEnd'] != null
          ? DateTime.parse(json['expiryDateRangeEnd'])
          : null,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  List<Object?> get props => [
        searchQuery,
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
        isActiveOnly,
        expiryDateRangeStart,
        expiryDateRangeEnd,
      ];

  @override
  String toString() {
    return 'ProductFilterEntity(searchQuery: $searchQuery, categories: $categories, brands: $brands)';
  }
}

/// Product Sort Options
enum ProductSortOption {
  nameAsc('name', 'asc', 'Name A-Z'),
  nameDesc('name', 'desc', 'Name Z-A'),
  priceAsc('price', 'asc', 'Price Low to High'),
  priceDesc('price', 'desc', 'Price High to Low'),
  ratingAsc('rating', 'asc', 'Rating Low to High'),
  ratingDesc('rating', 'desc', 'Rating High to Low'),
  newest('createdAt', 'desc', 'Newest First'),
  oldest('createdAt', 'asc', 'Oldest First'),
  stockAsc('stockQuantity', 'asc', 'Stock Low to High'),
  stockDesc('stockQuantity', 'desc', 'Stock High to Low'),
  popularity('popularity', 'desc', 'Most Popular');

  const ProductSortOption(this.field, this.order, this.displayName);
  final String field;
  final String order;
  final String displayName;
}

/// Product Availability
enum ProductAvailability {
  inStock,
  lowStock,
  outOfStock,
  discontinued,
  preOrder;

  String get displayName {
    switch (this) {
      case ProductAvailability.inStock:
        return 'In Stock';
      case ProductAvailability.lowStock:
        return 'Low Stock';
      case ProductAvailability.outOfStock:
        return 'Out of Stock';
      case ProductAvailability.discontinued:
        return 'Discontinued';
      case ProductAvailability.preOrder:
        return 'Pre-Order';
    }
  }

  String get color {
    switch (this) {
      case ProductAvailability.inStock:
        return '#52C41A'; // Green
      case ProductAvailability.lowStock:
        return '#FFA726'; // Orange
      case ProductAvailability.outOfStock:
        return '#FF5252'; // Red
      case ProductAvailability.discontinued:
        return '#9E9E9E'; // Grey
      case ProductAvailability.preOrder:
        return '#2196F3'; // Blue
    }
  }
}

/// Product Filter Category
enum FilterCategory {
  search('Search', Icons.search),
  categories('Categories', Icons.category),
  brands('Brands', Icons.business),
  manufacturers('Manufacturers', Icons.factory),
  dosageForms('Dosage Forms', Icons.medication),
  tags('Tags', Icons.label),
  price('Price Range', Icons.attach_money),
  stock('Stock Status', Icons.inventory),
  sale('On Sale', Icons.local_offer),
  prescription('Prescription', Icons.prescription),
  availability('Availability', Icons.check_circle),
  rating('Rating', Icons.star),
  sort('Sort', Icons.sort),
  active('Active Only', Icons.toggle_on),
  expiry('Expiry Date', Icons.date_range);

  const FilterCategory(this.displayName, this.icon);
  final String displayName;
  final IconData icon;
}

/// Filter Option Value
class FilterOptionValue extends Equatable {
  final String value;
  final String label;
  final int? count;
  final bool isSelected;

  const FilterOptionValue({
    required this.value,
    required this.label,
    this.count,
    this.isSelected = false,
  });

  FilterOptionValue copyWith({
    String? value,
    String? label,
    int? count,
    bool? isSelected,
  }) {
    return FilterOptionValue(
      value: value ?? this.value,
      label: label ?? this.label,
      count: count ?? this.count,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  List<Object?> get props => [value, label, count, isSelected];
}

/// Filter Category with Options
class FilterCategoryWithOptions extends Equatable {
  final FilterCategory category;
  final List<FilterOptionValue> options;
  final bool isExpanded;
  final String? selectedValue;

  const FilterCategoryWithOptions({
    required this.category,
    required this.options,
    this.isExpanded = false,
    this.selectedValue,
  });

  FilterCategoryWithOptions copyWith({
    FilterCategory? category,
    List<FilterOptionValue>? options,
    bool? isExpanded,
    String? selectedValue,
  }) {
    return FilterCategoryWithOptions(
      category: category ?? this.category,
      options: options ?? this.options,
      isExpanded: isExpanded ?? this.isExpanded,
      selectedValue: selectedValue ?? this.selectedValue,
    );
  }

  /// Get selected options count
  int get selectedCount => options.where((option) => option.isSelected).length;

  /// Check if has any selected options
  bool get hasSelectedOptions => selectedCount > 0;

  @override
  List<Object?> get props => [category, options, isExpanded, selectedValue];
}

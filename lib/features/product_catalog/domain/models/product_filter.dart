import 'package:equatable/equatable.dart';

enum ProductSortOption {
  nameAsc,
  nameDesc,
  priceAsc,
  priceDesc,
  newest,
  oldest,
  stockAsc,
  stockDesc,
}

enum ProductCategory {
  all,
  medicines,
  medicalDevices,
  consumables,
  equipment,
  supplements,
}

class ProductFilter extends Equatable {
  final String? searchQuery;
  final ProductCategory? category;
  final double? minPrice;
  final double? maxPrice;
  final bool? inStock;
  final bool? hasDiscount;
  final bool? prescriptionRequired;
  final String? manufacturer;
  final List<String>? tags;
  final ProductSortOption sortBy;
  final bool? expiringSoon;
  final String? unit;

  const ProductFilter({
    this.searchQuery,
    this.category,
    this.minPrice,
    this.maxPrice,
    this.inStock,
    this.hasDiscount,
    this.prescriptionRequired,
    this.manufacturer,
    this.tags,
    this.sortBy = ProductSortOption.nameAsc,
    this.expiringSoon,
    this.unit,
  });

  ProductFilter copyWith({
    String? searchQuery,
    ProductCategory? category,
    double? minPrice,
    double? maxPrice,
    bool? inStock,
    bool? hasDiscount,
    bool? prescriptionRequired,
    String? manufacturer,
    List<String>? tags,
    ProductSortOption? sortBy,
    bool? expiringSoon,
    String? unit,
  }) {
    return ProductFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      category: category ?? this.category,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      inStock: inStock ?? this.inStock,
      hasDiscount: hasDiscount ?? this.hasDiscount,
      prescriptionRequired: prescriptionRequired ?? this.prescriptionRequired,
      manufacturer: manufacturer ?? this.manufacturer,
      tags: tags ?? this.tags,
      sortBy: sortBy ?? this.sortBy,
      expiringSoon: expiringSoon ?? this.expiringSoon,
      unit: unit ?? this.unit,
    );
  }

  ProductFilter copyWithSearch(String searchQuery) {
    return copyWith(searchQuery: searchQuery);
  }

  ProductFilter copyWithCategory(ProductCategory category) {
    return copyWith(category: category);
  }

  ProductFilter copyWithPriceRange(double minPrice, double maxPrice) {
    return copyWith(minPrice: minPrice, maxPrice: maxPrice);
  }

  ProductFilter copyWithSort(ProductSortOption sortBy) {
    return copyWith(sortBy: sortBy);
  }

  ProductFilter clear() {
    return const ProductFilter(
      sortBy: ProductSortOption.nameAsc,
    );
  }

  bool get hasActiveFilters => 
      searchQuery?.isNotEmpty == true ||
      category != null && category != ProductCategory.all ||
      minPrice != null ||
      maxPrice != null ||
      inStock != null ||
      hasDiscount != null ||
      prescriptionRequired != null ||
      manufacturer?.isNotEmpty == true ||
      (tags?.isNotEmpty == true) ||
      expiringSoon == true ||
      unit?.isNotEmpty == true;

  @override
  List<Object?> get props => [
        searchQuery,
        category,
        minPrice,
        maxPrice,
        inStock,
        hasDiscount,
        prescriptionRequired,
        manufacturer,
        tags,
        sortBy,
        expiringSoon,
        unit,
      ];

  @override
  String toString() {
    return 'ProductFilter(searchQuery: $searchQuery, category: $category, price: $minPrice-$maxPrice)';
  }
}

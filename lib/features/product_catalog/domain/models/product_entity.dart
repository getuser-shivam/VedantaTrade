import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final String category;
  final String manufacturer;
  final String sku;
  final double price;
  final String currency;
  final int stockQuantity;
  final int minOrderQuantity;
  final String unit;
  final List<String> images;
  final List<String> tags;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? batchNumber;
  final DateTime? expiryDate;
  final String? storageConditions;
  final String? dosageForm;
  final String? strength;
  final String? prescriptionRequired;
  final Map<String, dynamic> specifications;
  final double? discountPrice;
  final String? discountType;
  final DateTime? discountValidUntil;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.manufacturer,
    required this.sku,
    required this.price,
    required this.currency,
    required this.stockQuantity,
    required this.minOrderQuantity,
    required this.unit,
    required this.images,
    required this.tags,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.batchNumber,
    this.expiryDate,
    this.storageConditions,
    this.dosageForm,
    this.strength,
    this.prescriptionRequired,
    this.specifications = const {},
    this.discountPrice,
    this.discountType,
    this.discountValidUntil,
  });

  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? manufacturer,
    String? sku,
    double? price,
    String? currency,
    int? stockQuantity,
    int? minOrderQuantity,
    String? unit,
    List<String>? images,
    List<String>? tags,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? batchNumber,
    DateTime? expiryDate,
    String? storageConditions,
    String? dosageForm,
    String? strength,
    String? prescriptionRequired,
    Map<String, dynamic>? specifications,
    double? discountPrice,
    String? discountType,
    DateTime? discountValidUntil,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      manufacturer: manufacturer ?? this.manufacturer,
      sku: sku ?? this.sku,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minOrderQuantity: minOrderQuantity ?? this.minOrderQuantity,
      unit: unit ?? this.unit,
      images: images ?? this.images,
      tags: tags ?? this.tags,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      storageConditions: storageConditions ?? this.storageConditions,
      dosageForm: dosageForm ?? this.dosageForm,
      strength: strength ?? this.strength,
      prescriptionRequired: prescriptionRequired ?? this.prescriptionRequired,
      specifications: specifications ?? this.specifications,
      discountPrice: discountPrice ?? this.discountPrice,
      discountType: discountType ?? this.discountType,
      discountValidUntil: discountValidUntil ?? this.discountValidUntil,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        manufacturer,
        sku,
        price,
        currency,
        stockQuantity,
        minOrderQuantity,
        unit,
        images,
        tags,
        isActive,
        createdAt,
        updatedAt,
        batchNumber,
        expiryDate,
        storageConditions,
        dosageForm,
        strength,
        prescriptionRequired,
        specifications,
        discountPrice,
        discountType,
        discountValidUntil,
      ];

  @override
  String toString() {
    return 'Product(id: $id, name: $name, category: $category, price: $price $currency)';
  }

  bool get isLowStock => stockQuantity <= minOrderQuantity;
  bool get isExpiringSoon => expiryDate != null && 
      expiryDate!.isBefore(DateTime.now().add(const Duration(days: 30)));
  bool get hasDiscount => discountPrice != null && 
      discountPrice! < price && 
      (discountValidUntil == null || discountValidUntil!.isAfter(DateTime.now()));
  bool get requiresPrescription => prescriptionRequired?.toLowerCase() == 'yes';
  
  double get effectivePrice => hasDiscount ? discountPrice! : price;
  double get discountPercentage => hasDiscount ? 
      ((price - discountPrice!) / price * 100) : 0.0;
  
  String get formattedPrice => '$currency ${effectivePrice.toStringAsFixed(2)}';
  String get formattedOriginalPrice => '$currency ${price.toStringAsFixed(2)}';
  String get stockStatus => isLowStock ? 'Low Stock' : 'In Stock';
  String get expiryStatus => isExpiringSoon ? 'Expiring Soon' : 'Good';
}

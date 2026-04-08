import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String genericName;
  final String manufacturer;
  final String brand;
  final String category;
  final String dosageForm;
  final String strength;
  final double price;
  final String currency;
  final int stockQuantity;
  final String batchNumber;
  final DateTime expiryDate;
  final String description;
  final List<String> indications;
  final List<String> contraindications;
  final List<String> sideEffects;
  final String prescriptionRequired;
  final String storageConditions;
  final List<String> images;
  final String formulation;
  final String packaging;
  final String dosage;
  final List<String> ingredients;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String regulatoryStatus;
  final String ndcNumber;
  final String irdNumber;
  final double discountPercentage;
  final double taxRate;
  final List<String> tags;
  final double rating;
  final int reviewCount;
  final String sku;
  final int minOrderQuantity;
  final String unit;

  const Product({
    required this.id,
    required this.name,
    required this.genericName,
    required this.manufacturer,
    required this.brand,
    required this.category,
    required this.dosageForm,
    required this.strength,
    required this.price,
    this.currency = 'NPR',
    required this.stockQuantity,
    this.batchNumber = 'N/A',
    required this.expiryDate,
    required this.description,
    this.indications = const [],
    this.contraindications = const [],
    this.sideEffects = const [],
    this.prescriptionRequired = 'Yes',
    this.storageConditions = 'Store at room temperature',
    this.images = const [],
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.regulatoryStatus = 'Approved',
    this.ndcNumber = '',
    this.irdNumber = '',
    this.discountPercentage = 0.0,
    this.taxRate = 13.0,
    this.tags = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.formulation = '',
    this.packaging = '',
    this.dosage = '',
    this.ingredients = const [],
    this.sku = '',
    this.minOrderQuantity = 1,
    this.unit = 'unit',
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    List<String> imagesList = [];
    if (json['images'] != null) {
      imagesList = List<String>.from(json['images']);
    } else if (json['imageUrl'] != null && json['imageUrl'].toString().isNotEmpty) {
      imagesList = [json['imageUrl']];
    } else if (json['image'] != null && json['image'].toString().isNotEmpty) {
      imagesList = [json['image']];
    }

    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      genericName: json['genericName'] ?? json['name'] ?? '',
      manufacturer: json['manufacturer'] ?? 'Vedanta TradeLink',
      brand: json['brand'] ?? 'Vedanta',
      category: json['category'] ?? 'Uncategorized',
      dosageForm: json['dosageForm'] ?? json['form'] ?? 'Not Specified',
      strength: json['strength'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'NPR',
      stockQuantity: json['stockQuantity'] ?? 100,
      batchNumber: json['batchNumber'] ?? 'N/A',
      expiryDate: DateTime.tryParse(json['expiryDate'] ?? '') ?? DateTime.now().add(const Duration(days: 365)),
      description: json['description'] ?? '',
      indications: List<String>.from(json['indications'] ?? []),
      contraindications: List<String>.from(json['contraindications'] ?? []),
      sideEffects: List<String>.from(json['sideEffects'] ?? []),
      prescriptionRequired: json['prescriptionRequired'] ?? 'Yes',
      storageConditions: json['storageConditions'] ?? 'Store at room temperature',
      images: imagesList,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      regulatoryStatus: json['regulatoryStatus'] ?? 'Approved',
      ndcNumber: json['ndcNumber'] ?? '',
      irdNumber: json['irdNumber'] ?? '',
      discountPercentage: (json['discountPercentage'] ?? json['discount'] ?? 0.0).toDouble(),
      taxRate: (json['taxRate'] ?? 13.0).toDouble(),
      tags: List<String>.from(json['tags'] ?? []),
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      formulation: json['formulation'] ?? '',
      packaging: json['packaging'] ?? '',
      dosage: json['dosage'] ?? '',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      sku: json['sku'] ?? '',
      minOrderQuantity: json['minOrderQuantity'] ?? 1,
      unit: json['unit'] ?? 'unit',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'genericName': genericName,
      'manufacturer': manufacturer,
      'brand': brand,
      'category': category,
      'dosageForm': dosageForm,
      'strength': strength,
      'price': price,
      'currency': currency,
      'stockQuantity': stockQuantity,
      'minOrderQuantity': minOrderQuantity,
      'unit': unit,
      'batchNumber': batchNumber,
      'expiryDate': expiryDate.toIso8601String(),
      'description': description,
      'indications': indications,
      'contraindications': contraindications,
      'sideEffects': sideEffects,
      'prescriptionRequired': prescriptionRequired,
      'storageConditions': storageConditions,
      'images': images,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'regulatoryStatus': regulatoryStatus,
      'ndcNumber': ndcNumber,
      'irdNumber': irdNumber,
      'discountPercentage': discountPercentage,
      'taxRate': taxRate,
      'tags': tags,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? genericName,
    String? manufacturer,
    String? brand,
    String? category,
    String? dosageForm,
    String? strength,
    double? price,
    String? currency,
    int? stockQuantity,
    String? batchNumber,
    DateTime? expiryDate,
    String? description,
    List<String>? indications,
    List<String>? contraindications,
    List<String>? sideEffects,
    String? prescriptionRequired,
    String? storageConditions,
    List<String>? images,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? regulatoryStatus,
    String? ndcNumber,
    String? irdNumber,
    double? discountPercentage,
    double? taxRate,
    List<String>? tags,
    double? rating,
    int? reviewCount,
    String? formulation,
    String? packaging,
    String? dosage,
    List<String>? ingredients,
    String? sku,
    int? minOrderQuantity,
    String? unit,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      genericName: genericName ?? this.genericName,
      manufacturer: manufacturer ?? this.manufacturer,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      dosageForm: dosageForm ?? this.dosageForm,
      strength: strength ?? this.strength,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      description: description ?? this.description,
      indications: indications ?? this.indications,
      contraindications: contraindications ?? this.contraindications,
      sideEffects: sideEffects ?? this.sideEffects,
      prescriptionRequired: prescriptionRequired ?? this.prescriptionRequired,
      storageConditions: storageConditions ?? this.storageConditions,
      images: images ?? this.images,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      regulatoryStatus: regulatoryStatus ?? this.regulatoryStatus,
      ndcNumber: ndcNumber ?? this.ndcNumber,
      irdNumber: irdNumber ?? this.irdNumber,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      taxRate: taxRate ?? this.taxRate,
      tags: tags ?? this.tags,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      formulation: formulation ?? this.formulation,
      packaging: packaging ?? this.packaging,
      dosage: dosage ?? this.dosage,
      ingredients: ingredients ?? this.ingredients,
      sku: sku ?? this.sku,
      minOrderQuantity: minOrderQuantity ?? this.minOrderQuantity,
      unit: unit ?? this.unit,
    );
  }

  // Computed Properties for UI/UX
  bool get isOnSale => discountPercentage > 0;
  double get discountedPrice => price * (1 - (discountPercentage / 100));
  double get finalPrice => (discountedPrice * (1 + (taxRate / 100)));
  
  String get formattedPrice => '$currency ${discountedPrice.toStringAsFixed(2)}';
  String get formattedOriginalPrice => '$currency ${price.toStringAsFixed(2)}';
  String get formattedDiscount => '${discountPercentage.toStringAsFixed(0)}% OFF';
  
  String get imageUrl => images.isNotEmpty ? images.first : '';
  
  bool get isLowStock => stockQuantity > 0 && stockQuantity < 10;
  bool get isExpiringSoon => expiryDate.isBefore(DateTime.now().add(const Duration(days: 90))) && !isExpired;
  bool get isExpired => expiryDate.isBefore(DateTime.now());
  
  String get stockStatus {
    if (stockQuantity <= 0) return 'Out of Stock';
    if (isLowStock) return 'Low Stock';
    return 'In Stock';
  }
  
  bool get requiresPrescription => prescriptionRequired.toLowerCase() == 'yes';

  @override
  List<Object?> get props => [
        id,
        name,
        genericName,
        manufacturer,
        brand,
        category,
        dosageForm,
        strength,
        price,
        currency,
        stockQuantity,
        batchNumber,
        expiryDate,
        description,
        indications,
        contraindications,
        sideEffects,
        prescriptionRequired,
        storageConditions,
        images,
        isActive,
        createdAt,
        updatedAt,
        regulatoryStatus,
        ndcNumber,
        irdNumber,
        discountPercentage,
        taxRate,
        tags,
        rating,
        reviewCount,
        formulation,
        packaging,
        dosage,
        ingredients,
        sku,
        minOrderQuantity,
        unit,
      ];
}

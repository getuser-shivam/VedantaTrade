import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String genericName;
  final String manufacturer;
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
  final String imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String regulatoryStatus;
  final String ndcNumber; // National Drug Code
  final String irdNumber; // Nepal IRD Registration
  final double discountPercentage;
  final double taxRate;
  final List<String> tags;
  final double rating;
  final int reviewCount;

  const Product({
    required this.id,
    required this.name,
    required this.genericName,
    required this.manufacturer,
    required this.category,
    required this.dosageForm,
    required this.strength,
    required this.price,
    this.currency = 'NPR',
    required this.stockQuantity,
    required this.batchNumber,
    required this.expiryDate,
    required this.description,
    this.indications = const [],
    this.contraindications = const [],
    this.sideEffects = const [],
    this.prescriptionRequired = 'Yes',
    this.storageConditions = 'Store at room temperature',
    this.imageUrl = '',
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
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      genericName: json['genericName'] ?? '',
      manufacturer: json['manufacturer'] ?? '',
      category: json['category'] ?? '',
      dosageForm: json['dosageForm'] ?? '',
      strength: json['strength'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'NPR',
      stockQuantity: json['stockQuantity'] ?? 0,
      batchNumber: json['batchNumber'] ?? '',
      expiryDate: DateTime.parse(json['expiryDate'] ?? DateTime.now().toIso8601String()),
      description: json['description'] ?? '',
      indications: List<String>.from(json['indications'] ?? []),
      contraindications: List<String>.from(json['contraindications'] ?? []),
      sideEffects: List<String>.from(json['sideEffects'] ?? []),
      prescriptionRequired: json['prescriptionRequired'] ?? 'Yes',
      storageConditions: json['storageConditions'] ?? 'Store at room temperature',
      imageUrl: json['imageUrl'] ?? '',
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      regulatoryStatus: json['regulatoryStatus'] ?? 'Approved',
      ndcNumber: json['ndcNumber'] ?? '',
      irdNumber: json['irdNumber'] ?? '',
      discountPercentage: (json['discountPercentage'] ?? 0.0).toDouble(),
      taxRate: (json['taxRate'] ?? 13.0).toDouble(),
      tags: List<String>.from(json['tags'] ?? []),
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'genericName': genericName,
      'manufacturer': manufacturer,
      'category': category,
      'dosageForm': dosageForm,
      'strength': strength,
      'price': price,
      'currency': currency,
      'stockQuantity': stockQuantity,
      'batchNumber': batchNumber,
      'expiryDate': expiryDate.toIso8601String(),
      'description': description,
      'indications': indications,
      'contraindications': contraindications,
      'sideEffects': sideEffects,
      'prescriptionRequired': prescriptionRequired,
      'storageConditions': storageConditions,
      'imageUrl': imageUrl,
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
    String? imageUrl,
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
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      genericName: genericName ?? this.genericName,
      manufacturer: manufacturer ?? this.manufacturer,
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
      imageUrl: imageUrl ?? this.imageUrl,
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
    );
  }

  // Computed properties
  bool get isLowStock => stockQuantity < 10;
  bool get isExpiringSoon => expiryDate.difference(DateTime.now()).inDays <= 30;
  bool get isExpired => expiryDate.isBefore(DateTime.now());
  bool get requiresPrescription => prescriptionRequired.toLowerCase() == 'yes';
  double get discountedPrice => price * (1 - discountPercentage / 100);
  double get finalPrice => discountedPrice * (1 + taxRate / 100);

  @override
  List<Object?> get props => [
        id,
        name,
        genericName,
        manufacturer,
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
        imageUrl,
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
      ];
}

class ProductCategory extends Equatable {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final int productCount;
  final List<String> subcategories;

  const ProductCategory({
    required this.id,
    required this.name,
    required this.description,
    this.iconUrl = '',
    this.productCount = 0,
    this.subcategories = const [],
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      iconUrl: json['iconUrl'] ?? '',
      productCount: json['productCount'] ?? 0,
      subcategories: List<String>.from(json['subcategories'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'productCount': productCount,
      'subcategories': subcategories,
    };
  }

  @override
  List<Object?> get props => [id, name, description, iconUrl, productCount, subcategories];
}

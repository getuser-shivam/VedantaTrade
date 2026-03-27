class Product {
  final String id;
  final String name;
  final String category;
  final String description;
  final String imageUrl;
  final double mrp; // Maximum Retail Price
  final double? ptr; // Price to Retailer
  final double? pts; // Price to Stockist
  final bool featured;
  final String sku;
  final String manufacturer;
  final String composition;
  final String packSize;
  final int stockQuantity;
  final bool isActive;
  final String? genericName;
  final String? unitOfMeasure;
  final double? gstPercent;
  final bool? requiresPrescription;

  Product({
    required this.id,
    required this.name,
    required this.category,
    this.description = '',
    this.imageUrl = '',
    required this.mrp,
    this.ptr,
    this.pts,
    this.featured = false,
    this.sku = '',
    this.manufacturer = 'Vedanta TradeLink',
    this.composition = '',
    this.packSize = '',
    this.stockQuantity = 0,
    this.isActive = true,
    this.genericName,
    this.unitOfMeasure,
    this.gstPercent,
    this.requiresPrescription,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Uncategorized',
      description: json['description']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      mrp: (json['price'] as num?)?.toDouble() ?? 0.0,
      ptr: (json['ptr'] as num?)?.toDouble(),
      pts: (json['pts'] as num?)?.toDouble(),
      featured: json['featured'] ?? false,
      sku: json['sku']?.toString() ?? '',
      manufacturer: json['manufacturer']?.toString() ?? 'Vedanta TradeLink',
      composition: json['composition']?.toString() ?? '',
      packSize: json['packSize']?.toString() ?? '',
      stockQuantity: (json['stockQuantity'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] ?? true,
      genericName: json['genericName']?.toString(),
      unitOfMeasure: json['unitOfMeasure']?.toString(),
      gstPercent: (json['gstPercent'] as num?)?.toDouble(),
      requiresPrescription: json['requiresPrescription'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'imageUrl': imageUrl,
      'price': mrp,
      'ptr': ptr,
      'pts': pts,
      'featured': featured,
      'sku': sku,
      'manufacturer': manufacturer,
      'composition': composition,
      'packSize': packSize,
      'stockQuantity': stockQuantity,
      'isActive': isActive,
      'genericName': genericName,
      'unitOfMeasure': unitOfMeasure,
      'gstPercent': gstPercent,
      'requiresPrescription': requiresPrescription,
    };
  }

  // Helper method to get searchable text for filtering
  String get searchableText {
    return [
      name,
      category,
      description,
      manufacturer,
      composition,
      packSize,
      sku,
      genericName ?? '',
      unitOfMeasure ?? '',
    ].join(' ').toLowerCase();
  }

  // Helper method to get ingredients from composition
  List<String> get ingredients {
    if (composition.isEmpty) return [];
    // Split composition by common separators and clean up
    return composition
        .split(RegExp(r'[,+&]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  // Helper method to get form (tablet, capsule, etc.) from packSize
  String get form {
    if (packSize.isEmpty) return '';
    
    // Common pharmaceutical forms
    final forms = ['tablet', 'capsule', 'syrup', 'injection', 'ointment', 'cream', 'gel', 'drops', 'spray'];
    
    for (final form in forms) {
      if (packSize.toLowerCase().contains(form)) {
        return form;
      }
    }
    
    // Default fallback
    return packSize;
  }
}

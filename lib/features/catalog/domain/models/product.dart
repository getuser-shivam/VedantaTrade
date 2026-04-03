class Product {
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

  Product({
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
    this.manufacturer = 'Vedanta TradeLink',
    this.genericName,
    this.isActive = true,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Handling both products.json format and potential API format
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['item_name'] ?? '',
      category: json['category']?.toString() ?? 'Uncategorized',
      description: json['description']?.toString() ?? '',
      images: json['images'] != null 
          ? List<String>.from(json['images']) 
          : (json['imageUrl'] != null ? [json['imageUrl']] : (json['image_url'] != null ? [json['image_url']] : [])),
      price: (json['price'] ?? json['mrp'] ?? json['unit_price'] ?? 0.0).toDouble(),
      form: json['form']?.toString() ?? '',
      ingredients: json['ingredients'] != null ? List<String>.from(json['ingredients']) : [],
      dosage: json['dosage']?.toString() ?? '',
      packaging: json['packaging']?.toString() ?? '',
      featured: json['featured'] ?? false,
      stockQuantity: (json['stockQuantity'] ?? json['stock'] ?? json['current_stock'] ?? 0).toInt(),
      ptr: (json['ptr'] as num?)?.toDouble(),
      pts: (json['pts'] as num?)?.toDouble(),
      manufacturer: json['manufacturer']?.toString() ?? 'Vedanta TradeLink',
      genericName: json['genericName']?.toString() ?? json['generic_name'],
      isActive: json['isActive'] ?? true,
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

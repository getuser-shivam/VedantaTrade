import '../../domain/models/product_entity.dart';
import '../../domain/models/product_filter.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final List<Product> _mockProducts = _generateMockProducts();

  @override
  Future<List<Product>> getProducts({
    ProductFilter? filter,
    int page = 1,
    int limit = 20,
  }) async {
    List<Product> products = List.from(_mockProducts);
    
    if (filter != null) {
      products = _applyFilters(products, filter!);
    }
    
    products = _applySorting(products, filter?.sortBy ?? ProductSortOption.nameAsc);
    
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;
    
    return products.take(endIndex).skip(startIndex).toList();
  }

  @override
  Future<Product?> getProductById(String id) async {
    try {
      return _mockProducts.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Product>> getProductsByCategory(String category) async {
    return _mockProducts
        .where((product) => product.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    if (query.isEmpty) return [];
    
    final lowerQuery = query.toLowerCase();
    return _mockProducts
        .where((product) =>
            product.name.toLowerCase().contains(lowerQuery) ||
            product.description.toLowerCase().contains(lowerQuery) ||
            product.manufacturer.toLowerCase().contains(lowerQuery) ||
            product.sku.toLowerCase().contains(lowerQuery) ||
            product.tags.any((tag) => tag.toLowerCase().contains(lowerQuery)))
        .toList();
  }

  @override
  Future<List<Product>> getFeaturedProducts() async {
    return _mockProducts
        .where((product) => product.isActive && product.hasDiscount)
        .take(10)
        .toList();
  }

  @override
  Future<List<Product>> getDiscountedProducts() async {
    return _mockProducts
        .where((product) => product.hasDiscount)
        .toList();
  }

  @override
  Future<List<Product>> getExpiringSoonProducts() async {
    return _mockProducts
        .where((product) => product.isExpiringSoon)
        .take(10)
        .toList();
  }

  @override
  Future<List<Product>> getLowStockProducts() async {
    return _mockProducts
        .where((product) => product.isLowStock)
        .take(10)
        .toList();
  }

  @override
  Future<List<String>> getCategories() async {
    final categories = _mockProducts
        .map((product) => product.category)
        .toSet()
        .toList();
    categories.insert(0, 'All');
    return categories;
  }

  @override
  Future<List<String>> getManufacturers() async {
    return _mockProducts
        .map((product) => product.manufacturer)
        .toSet()
        .toList();
  }

  @override
  Future<List<String>> getTags() async {
    final allTags = <String>{};
    for (final product in _mockProducts) {
      allTags.addAll(product.tags);
    }
    return allTags.toList();
  }

  @override
  Future<List<Product>> getRelatedProducts(String productId) async {
    final currentProduct = await getProductById(productId);
    if (currentProduct == null) return [];
    
    return _mockProducts
        .where((product) =>
            product.id != productId &&
            (product.category == currentProduct!.category ||
             product.manufacturer == currentProduct!.manufacturer))
        .take(5)
        .toList();
  }

  @override
  Future<void> addToFavorites(String productId) async {
    // Implementation would integrate with local storage or backend
  }

  @override
  Future<void> removeFromFavorites(String productId) async {
    // Implementation would integrate with local storage or backend
  }

  @override
  Future<List<Product>> getFavoriteProducts() async {
    return _mockProducts.take(5).toList(); // Mock implementation
  }

  @override
  Future<bool> isFavorite(String productId) async {
    return false; // Mock implementation
  }

  @override
  Future<void> addToRecentlyViewed(String productId) async {
    // Implementation would integrate with local storage
  }

  @override
  Future<List<Product>> getRecentlyViewedProducts() async {
    return _mockProducts.take(8).toList(); // Mock implementation
  }

  @override
  Future<void> rateProduct(String productId, double rating, String? review) async {
    // Implementation would send rating to backend
  }

  @override
  Future<List<Product>> getProductsByManufacturer(String manufacturer) async {
    return _mockProducts
        .where((product) => product.manufacturer.toLowerCase() == manufacturer.toLowerCase())
        .toList();
  }

  @override
  Future<void> trackProductView(String productId) async {
    // Implementation would track view analytics
  }

  @override
  Future<Map<String, dynamic>> getProductAnalytics() async {
    return {
      'totalProducts': _mockProducts.length,
      'activeProducts': _mockProducts.where((p) => p.isActive).length,
      'discountedProducts': _mockProducts.where((p) => p.hasDiscount).length,
      'lowStockProducts': _mockProducts.where((p) => p.isLowStock).length,
      'expiringSoonProducts': _mockProducts.where((p) => p.isExpiringSoon).length,
      'categories': (await getCategories()).length - 1, // Excluding 'All'
      'manufacturers': (await getManufacturers()).length,
    };
  }

  List<Product> _applyFilters(List<Product> products, ProductFilter filter) {
    if (filter.searchQuery?.isNotEmpty == true) {
      products = _applySearchFilter(products, filter.searchQuery!);
    }
    
    if (filter.category != null && filter.category != ProductCategory.all) {
      products = products.where((p) => p.category == filter.category!.name).toList();
    }
    
    if (filter.minPrice != null) {
      products = products.where((p) => p.price >= filter.minPrice!).toList();
    }
    
    if (filter.maxPrice != null) {
      products = products.where((p) => p.price <= filter.maxPrice!).toList();
    }
    
    if (filter.inStock != null) {
      products = products.where((p) => 
          filter.inStock! ? p.stockQuantity > 0 : p.stockQuantity <= 0).toList();
    }
    
    if (filter.hasDiscount != null) {
      products = products.where((p) => p.hasDiscount == filter.hasDiscount).toList();
    }
    
    if (filter.prescriptionRequired != null) {
      products = products.where((p) => 
          p.requiresPrescription == (filter.prescriptionRequired! ? 'yes' : 'no')).toList();
    }
    
    if (filter.manufacturer?.isNotEmpty == true) {
      products = products.where((p) => 
          p.manufacturer.toLowerCase().contains(filter.manufacturer!.toLowerCase())).toList();
    }
    
    if (filter.tags?.isNotEmpty == true) {
      products = products.where((p) => 
          filter.tags!.any((tag) => p.tags.contains(tag))).toList();
    }
    
    if (filter.expiringSoon == true) {
      products = products.where((p) => p.isExpiringSoon).toList();
    }
    
    if (filter.unit?.isNotEmpty == true) {
      products = products.where((p) => 
          p.unit.toLowerCase() == filter.unit!.toLowerCase()).toList();
    }
    
    return products;
  }

  List<Product> _applySearchFilter(List<Product> products, String query) {
    final lowerQuery = query.toLowerCase();
    return products.where((product) =>
        product.name.toLowerCase().contains(lowerQuery) ||
        product.description.toLowerCase().contains(lowerQuery) ||
        product.manufacturer.toLowerCase().contains(lowerQuery) ||
        product.sku.toLowerCase().contains(lowerQuery) ||
        product.tags.any((tag) => tag.toLowerCase().contains(lowerQuery))
    ).toList();
  }

  List<Product> _applySorting(List<Product> products, ProductSortOption sortBy) {
    switch (sortBy) {
      case ProductSortOption.nameAsc:
        return products..sort((a, b) => a.name.compareTo(b.name));
      case ProductSortOption.nameDesc:
        return products..sort((a, b) => b.name.compareTo(a.name));
      case ProductSortOption.priceAsc:
        return products..sort((a, b) => a.effectivePrice.compareTo(b.effectivePrice));
      case ProductSortOption.priceDesc:
        return products..sort((a, b) => b.effectivePrice.compareTo(a.effectivePrice));
      case ProductSortOption.newest:
        return products..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      case ProductSortOption.oldest:
        return products..sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
      case ProductSortOption.stockAsc:
        return products..sort((a, b) => a.stockQuantity.compareTo(b.stockQuantity));
      case ProductSortOption.stockDesc:
        return products..sort((a, b) => b.stockQuantity.compareTo(a.stockQuantity));
    }
    return products;
  }

  List<Product> _generateMockProducts() {
    final now = DateTime.now();
    return [
      Product(
        id: '1',
        name: 'Paracetamol 500mg',
        description: 'Paracetamol tablets for pain relief and fever reduction',
        category: 'Medicines',
        manufacturer: 'Nepal Pharmaceuticals',
        sku: 'PAR-500-100',
        price: 45.50,
        currency: 'NPR',
        stockQuantity: 150,
        minOrderQuantity: 10,
        unit: 'tablets',
        images: ['https://example.com/paracetamol1.jpg', 'https://example.com/paracetamol2.jpg'],
        tags: ['pain relief', 'fever', 'tablet'],
        isActive: true,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 5)),
        dosageForm: 'Tablet',
        strength: '500mg',
        prescriptionRequired: 'no',
        specifications: {'composition': 'Paracetamol 500mg', 'packaging': '10 tablets per strip'},
        discountPrice: 38.00,
        discountType: 'Bulk Order',
        discountValidUntil: now.add(const Duration(days: 15)),
      ),
      Product(
        id: '2',
        name: 'Amoxicillin 250mg',
        description: 'Antibiotic for bacterial infections',
        category: 'Medicines',
        manufacturer: 'Asian Pharmaceuticals',
        sku: 'AMOX-250-50',
        price: 120.00,
        currency: 'NPR',
        stockQuantity: 80,
        minOrderQuantity: 20,
        unit: 'capsules',
        images: ['https://example.com/amoxicillin1.jpg'],
        tags: ['antibiotic', 'infection', 'capsule'],
        isActive: true,
        createdAt: now.subtract(const Duration(days: 25)),
        updatedAt: now.subtract(const Duration(days: 3)),
        dosageForm: 'Capsule',
        strength: '250mg',
        prescriptionRequired: 'yes',
        specifications: {'composition': 'Amoxicillin 250mg', 'packaging': '20 capsules per bottle'},
        expiryDate: now.add(const Duration(days: 60)),
      ),
      Product(
        id: '3',
        name: 'Digital Blood Pressure Monitor',
        description: 'Automatic blood pressure monitoring device',
        category: 'Medical Devices',
        manufacturer: 'MedTech Solutions',
        sku: 'DBPM-001',
        price: 2500.00,
        currency: 'NPR',
        stockQuantity: 25,
        minOrderQuantity: 5,
        unit: 'device',
        images: ['https://example.com/bp-monitor1.jpg', 'https://example.com/bp-monitor2.jpg'],
        tags: ['blood pressure', 'monitoring', 'digital'],
        isActive: true,
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 2)),
        specifications: {'display': 'Digital LCD', 'accuracy': '+/- 3mmHg', 'battery': 'AAA x2'},
      ),
      Product(
        id: '4',
        name: 'Surgical Gloves',
        description: 'Disposable surgical gloves for medical procedures',
        category: 'Consumables',
        manufacturer: 'Safety First Medical',
        sku: 'SG-L-100',
        price: 15.75,
        currency: 'NPR',
        stockQuantity: 500,
        minOrderQuantity: 50,
        unit: 'pairs',
        images: ['https://example.com/gloves1.jpg'],
        tags: ['surgical', 'disposable', 'protection'],
        isActive: true,
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 1)),
        specifications: {'material': 'Latex', 'size': 'Large', 'sterile': 'Yes'},
      ),
      Product(
        id: '5',
        name: 'Vitamin C Tablets',
        description: 'Vitamin C supplement for immune system support',
        category: 'Supplements',
        manufacturer: 'NutriHealth Nepal',
        sku: 'VITC-500-60',
        price: 28.90,
        currency: 'NPR',
        stockQuantity: 200,
        minOrderQuantity: 30,
        unit: 'tablets',
        images: ['https://example.com/vitaminc1.jpg'],
        tags: ['vitamin', 'supplement', 'immune'],
        isActive: true,
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 1)),
        dosageForm: 'Tablet',
        strength: '500mg',
        prescriptionRequired: 'no',
        specifications: {'composition': 'Vitamin C 500mg', 'packaging': '60 tablets per bottle'},
        discountPrice: 25.00,
        discountType: 'Special Offer',
        discountValidUntil: now.add(const Duration(days: 7)),
      ),
    ];
  }
}

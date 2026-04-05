import 'package:vedanta_trade/features/catalog/domain/models/product.dart';
import 'package:vedanta_trade/features/catalog/domain/repositories/product_repository.dart';
import 'package:vedanta_trade/features/catalog/data/services/product_catalog_service.dart';

/// Repository implementation for product catalog
/// Following Clean Architecture - Data Layer
class ProductRepositoryImpl implements ProductRepository {
  final ProductCatalogService _catalogService;

  ProductRepositoryImpl({ProductCatalogService? catalogService})
      : _catalogService = catalogService ?? ProductCatalogService();

  @override
  Future<List<Product>> getProducts({String? category, String? token}) async {
    return await _catalogService.loadRegisteredProducts(
      category: category,
      token: token,
    );
  }

  @override
  Future<List<Product>> getFeaturedProducts({String? token}) async {
// final products = await _catalogService.loadRegisteredProducts(token: token); // TODO: Move to environment variables
    return products.where((p) => p.featured).toList();
  }

  @override
  Future<Product?> getProductById(String id, {String? token}) async {
// final products = await _catalogService.loadRegisteredProducts(token: token); // TODO: Move to environment variables
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Product>> searchProducts(String query, {String? token}) async {
// final products = await _catalogService.loadRegisteredProducts(token: token); // TODO: Move to environment variables
    final searchLower = query.toLowerCase();
    return products.where((p) {
      return p.name.toLowerCase().contains(searchLower) ||
          p.category.toLowerCase().contains(searchLower) ||
          p.description.toLowerCase().contains(searchLower) ||
          p.manufacturer.toLowerCase().contains(searchLower) ||
          (p.genericName?.toLowerCase().contains(searchLower) ?? false);
    }).toList();
  }

  @override
  Future<List<Category>> getCategories({String? token}) async {
    return await _catalogService.loadCategories(token: token);
  }

  @override
  Future<List<Manufacturer>> getManufacturers({String? token}) async {
    return await _catalogService.loadManufacturers(token: token);
  }

  @override
  Future<List<Product>> getProductsByCategory(String category, {String? token}) async {
    return await _catalogService.loadRegisteredProducts(
      category: category,
      token: token,
    );
  }

  @override
  Future<List<Product>> getLowStockProducts({String? token}) async {
// final products = await _catalogService.loadRegisteredProducts(token: token); // TODO: Move to environment variables
    return products.where((p) => p.isLowStock || p.isOutOfStock).toList();
  }

  @override
  Future<List<Product>> filterProducts({
    String? category,
    String? manufacturer,
    double? minPrice,
    double? maxPrice,
    bool? inStock,
    String? token,
  }) async {
// var products = await _catalogService.loadRegisteredProducts(token: token); // TODO: Move to environment variables
    
    if (category != null && category != 'All') {
      products = products.where((p) => p.category == category).toList();
    }
    
    if (manufacturer != null) {
      products = products.where((p) => p.manufacturer == manufacturer).toList();
    }
    
    if (minPrice != null) {
      products = products.where((p) => p.price >= minPrice).toList();
    }
    
    if (maxPrice != null) {
      products = products.where((p) => p.price <= maxPrice).toList();
    }
    
    if (inStock != null) {
      if (inStock) {
        products = products.where((p) => p.stockQuantity > 0).toList();
      } else {
        products = products.where((p) => p.stockQuantity == 0).toList();
      }
    }
    
    return products;
  }
}

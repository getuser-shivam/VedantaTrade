import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';

import 'package:vedanta_trade/features/product_catalog/data/models/product_model.dart';
import 'package:vedanta_trade/features/product_catalog/data/services/product_service.dart';
import 'package:vedanta_trade/features/product_catalog/presentation/providers/product_catalog_provider.dart';

// Generate mocks
@GenerateMocks([ProductService])
import 'product_catalog_test.mocks.dart';

void main() {
  group('Product Catalog Tests', () {
    late MockProductService mockProductService;
    late ProductCatalogProvider provider;

    setUp(() {
      mockProductService = MockProductService();
      provider = ProductCatalogProvider();
    });

    test('Product model should create from JSON correctly', () {
      final json = {
        'id': '1',
        'name': 'Test Product',
        'genericName': 'Test Generic',
        'manufacturer': 'Test Manufacturer',
        'category': 'Test Category',
        'dosageForm': 'Tablet',
        'strength': '500mg',
        'price': 100.0,
        'stockQuantity': 50,
        'batchNumber': 'BATCH001',
        'expiryDate': '2024-12-31T00:00:00.000Z',
        'description': 'Test description',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-01T00:00:00.000Z',
      };

      final product = Product.fromJson(json);

      expect(product.id, '1');
      expect(product.name, 'Test Product');
      expect(product.genericName, 'Test Generic');
      expect(product.manufacturer, 'Test Manufacturer');
      expect(product.category, 'Test Category');
      expect(product.dosageForm, 'Tablet');
      expect(product.strength, '500mg');
      expect(product.price, 100.0);
      expect(product.stockQuantity, 50);
      expect(product.batchNumber, 'BATCH001');
      expect(product.description, 'Test description');
    });

    test('Product should compute properties correctly', () {
      final product = Product(
        id: '1',
        name: 'Test Product',
        genericName: 'Test Generic',
        manufacturer: 'Test Manufacturer',
        category: 'Test Category',
        dosageForm: 'Tablet',
        strength: '500mg',
        price: 100.0,
        stockQuantity: 5,
        batchNumber: 'BATCH001',
        expiryDate: DateTime.now().add(const Duration(days: 20)),
        description: 'Test description',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        discountPercentage: 10.0,
        taxRate: 13.0,
        prescriptionRequired: 'Yes',
      );

      expect(product.isLowStock, true);
      expect(product.isExpiringSoon, true);
      expect(product.requiresPrescription, true);
      expect(product.discountedPrice, 90.0);
      expect(product.finalPrice, 101.7);
    });

    test('ProductCategory model should create from JSON correctly', () {
      final json = {
        'id': '1',
        'name': 'Test Category',
        'description': 'Test category description',
        'iconUrl': 'https://example.com/icon.png',
        'productCount': 25,
        'subcategories': ['Sub1', 'Sub2'],
      };

      final category = ProductCategory.fromJson(json);

      expect(category.id, '1');
      expect(category.name, 'Test Category');
      expect(category.description, 'Test category description');
      expect(category.iconUrl, 'https://example.com/icon.png');
      expect(category.productCount, 25);
      expect(category.subcategories, ['Sub1', 'Sub2']);
    });

    test('Product copyWith should work correctly', () {
      final originalProduct = Product(
        id: '1',
        name: 'Original Product',
        genericName: 'Original Generic',
        manufacturer: 'Original Manufacturer',
        category: 'Original Category',
        dosageForm: 'Tablet',
        strength: '500mg',
        price: 100.0,
        stockQuantity: 50,
        batchNumber: 'BATCH001',
        expiryDate: DateTime.now(),
        description: 'Original description',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updatedProduct = originalProduct.copyWith(
        name: 'Updated Product',
        price: 150.0,
      );

      expect(updatedProduct.id, '1');
      expect(updatedProduct.name, 'Updated Product');
      expect(updatedProduct.genericName, 'Original Generic');
      expect(updatedProduct.price, 150.0);
    });

    test('Product equality should work correctly', () {
      final product1 = Product(
        id: '1',
        name: 'Test Product',
        genericName: 'Test Generic',
        manufacturer: 'Test Manufacturer',
        category: 'Test Category',
        dosageForm: 'Tablet',
        strength: '500mg',
        price: 100.0,
        stockQuantity: 50,
        batchNumber: 'BATCH001',
        expiryDate: DateTime.now(),
        description: 'Test description',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final product2 = Product(
        id: '1',
        name: 'Test Product',
        genericName: 'Test Generic',
        manufacturer: 'Test Manufacturer',
        category: 'Test Category',
        dosageForm: 'Tablet',
        strength: '500mg',
        price: 100.0,
        stockQuantity: 50,
        batchNumber: 'BATCH001',
        expiryDate: DateTime.now(),
        description: 'Test description',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final product3 = Product(
        id: '2',
        name: 'Different Product',
        genericName: 'Test Generic',
        manufacturer: 'Test Manufacturer',
        category: 'Test Category',
        dosageForm: 'Tablet',
        strength: '500mg',
        price: 100.0,
        stockQuantity: 50,
        batchNumber: 'BATCH001',
        expiryDate: DateTime.now(),
        description: 'Test description',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(product1, equals(product2));
      expect(product1, isNot(equals(product3)));
    });

    test('Product category equality should work correctly', () {
      final category1 = ProductCategory(
        id: '1',
        name: 'Test Category',
        description: 'Test description',
        productCount: 25,
      );

      final category2 = ProductCategory(
        id: '1',
        name: 'Test Category',
        description: 'Test description',
        productCount: 25,
      );

      final category3 = ProductCategory(
        id: '2',
        name: 'Different Category',
        description: 'Test description',
        productCount: 25,
      );

      expect(category1, equals(category2));
      expect(category1, isNot(equals(category3)));
    });

    test('Product JSON serialization should work correctly', () {
      final product = Product(
        id: '1',
        name: 'Test Product',
        genericName: 'Test Generic',
        manufacturer: 'Test Manufacturer',
        category: 'Test Category',
        dosageForm: 'Tablet',
        strength: '500mg',
        price: 100.0,
        stockQuantity: 50,
        batchNumber: 'BATCH001',
        expiryDate: DateTime(2024, 12, 31),
        description: 'Test description',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final json = product.toJson();

      expect(json['id'], '1');
      expect(json['name'], 'Test Product');
      expect(json['genericName'], 'Test Generic');
      expect(json['price'], 100.0);
      expect(json['expiryDate'], '2024-12-31T00:00:00.000Z');
    });

    test('Product category JSON serialization should work correctly', () {
      final category = ProductCategory(
        id: '1',
        name: 'Test Category',
        description: 'Test description',
        iconUrl: 'https://example.com/icon.png',
        productCount: 25,
        subcategories: ['Sub1', 'Sub2'],
      );

      final json = category.toJson();

      expect(json['id'], '1');
      expect(json['name'], 'Test Category');
      expect(json['description'], 'Test description');
      expect(json['iconUrl'], 'https://example.com/icon.png');
      expect(json['productCount'], 25);
      expect(json['subcategories'], ['Sub1', 'Sub2']);
    });
  });

  group('Product Catalog Provider Tests', () {
    late ProductCatalogProvider provider;

    setUp(() {
      provider = ProductCatalogProvider();
    });

    test('Initial state should be correct', () {
      expect(provider.products, isEmpty);
      expect(provider.categories, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.searchQuery, '');
      expect(provider.filterByCategory, '');
      expect(provider.sortBy, 'name');
      expect(provider.showInStockOnly, false);
      expect(provider.showExpiringSoonOnly, false);
    });

    test('Search query should update correctly', () {
      provider.searchProducts('Paracetamol');
      expect(provider.searchQuery, 'Paracetamol');
    });

    test('Category filter should update correctly', () {
      provider.filterByCategory('Analgesics');
      expect(provider.filterByCategory, 'Analgesics');
    });

    test('Sort by should update correctly', () {
      provider.sortByProducts('price');
      expect(provider.sortBy, 'price');
    });

    test('In stock filter should toggle correctly', () {
      provider.toggleInStockFilter();
      expect(provider.showInStockOnly, true);
      
      provider.toggleInStockFilter();
      expect(provider.showInStockOnly, false);
    });

    test('Expiring soon filter should toggle correctly', () {
      provider.toggleExpiringSoonFilter();
      expect(provider.showExpiringSoonOnly, true);
      
      provider.toggleExpiringSoonFilter();
      expect(provider.showExpiringSoonOnly, false);
    });

    test('Clear filters should reset all filters', () {
      provider.searchProducts('Test');
      provider.filterByCategory('Test Category');
      provider.sortByProducts('price');
      provider.toggleInStockFilter();
      provider.toggleExpiringSoonFilter();
      
      provider.clearFilters();
      
      expect(provider.searchQuery, '');
      expect(provider.filterByCategory, '');
      expect(provider.sortBy, 'name');
      expect(provider.showInStockOnly, false);
      expect(provider.showExpiringSoonOnly, false);
    });
  });

  group('Product Service Tests', () {
    late ProductService productService;

    setUp(() {
      productService = ProductService();
    });

    test('Should return mock products', () async {
      final products = await productService.getProducts();
      expect(products, isNotEmpty);
      expect(products.first.name, isNotEmpty);
      expect(products.first.price, greaterThan(0));
    });

    test('Should return mock categories', () async {
      final categories = await productService.getCategories();
      expect(categories, isNotEmpty);
      expect(categories.first.name, isNotEmpty);
      expect(categories.first.productCount, greaterThan(0));
    });

    test('Should search products', () async {
      final searchResults = await productService.searchProducts('Paracetamol');
      expect(searchResults, isNotEmpty);
    });

    test('Should get products by category', () async {
      final categoryProducts = await productService.getProductsByCategory('Analgesics');
      expect(categoryProducts, isNotEmpty);
    });

    test('Should get featured products', () async {
      final featuredProducts = await productService.getFeaturedProducts();
      expect(featuredProducts, isNotEmpty);
    });

    test('Should get low stock products', () async {
      final lowStockProducts = await productService.getLowStockProducts();
      expect(lowStockProducts, isNotEmpty);
    });

    test('Should get expiring soon products', () async {
      final expiringSoonProducts = await productService.getExpiringSoonProducts();
      expect(expiringSoonProducts, isNotEmpty);
    });
  });
}

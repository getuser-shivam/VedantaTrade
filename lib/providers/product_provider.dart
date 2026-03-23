import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:vedanta_trade/core/api_config.dart';

class Product {
  final int id;
  final String name;
  final String? genericName;
  final String sku;
  final String? manufacturer;
  final double mrp;
  final int stockQuantity;
  final String? categoryName;
  final List<String> images;

  Product({
    required this.id,
    required this.name,
    this.genericName,
    required this.sku,
    this.manufacturer,
    required this.mrp,
    required this.stockQuantity,
    this.categoryName,
    required this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      genericName: json['genericName'],
      sku: json['sku'],
      manufacturer: json['manufacturer'],
      mrp: (json['mrp'] as num).toDouble(),
      stockQuantity: json['stockQuantity'],
      categoryName: json['category']?['name'],
      images: List<String>.from(json['images'] ?? []),
    );
  }
}

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  List<dynamic> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  List<dynamic> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final Dio _dio = Dio();

  Future<void> fetchProducts({int? categoryId, String? search}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final Map<String, dynamic> query = {};
      if (categoryId != null) query['category'] = categoryId;
      if (search != null) query['search'] = search;

      final res = await _dio.get('${ApiConfig.baseUrl}/products', queryParameters: query);
      if (res.data['success']) {
        _products = (res.data['data'] as List).map((p) => Product.fromJson(p)).toList();
      }
    } catch (e) {
      _error = 'Failed to load products: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCategories() async {
    try {
      final res = await _dio.get('${ApiConfig.baseUrl}/products/categories');
      if (res.data['success']) {
        _categories = res.data['data'];
      }
    } catch (_) {
      // Fail silently for categories
    } finally {
      notifyListeners();
    }
  }
}

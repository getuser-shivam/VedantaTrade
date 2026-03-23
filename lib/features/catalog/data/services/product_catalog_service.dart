import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:neutralitical_app/features/catalog/domain/models/product.dart';

class ProductCatalogService {
  const ProductCatalogService();

  Future<List<Product>> loadRegisteredProducts() async {
    final jsonString = await rootBundle.loadString('assets/data/products.json');
    final List<dynamic> decoded = json.decode(jsonString) as List<dynamic>;

    return decoded
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

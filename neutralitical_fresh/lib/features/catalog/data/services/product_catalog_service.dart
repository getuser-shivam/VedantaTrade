import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/models/product.dart';

abstract class ProductCatalogService {
  Future<List<Product>> loadRegisteredProducts();
}

class AssetProductCatalogService implements ProductCatalogService {
  const AssetProductCatalogService({
    this.assetPath = 'assets/data/products.json',
  });

  final String assetPath;

  @override
  Future<List<Product>> loadRegisteredProducts() async {
    final jsonString = await rootBundle.loadString(assetPath);
    final decoded = json.decode(jsonString) as List<dynamic>;

    return decoded
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

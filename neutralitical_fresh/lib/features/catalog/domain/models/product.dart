import 'product_media.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.form,
    required this.ingredients,
    required this.description,
    required this.imageUrl,
    required this.media,
    required this.price,
    required this.featured,
    this.dosage,
    this.packaging,
  });

  final String id;
  final String name;
  final String category;
  final String form;
  final List<String> ingredients;
  final String description;
  final String imageUrl;
  final List<ProductMedia> media;
  final double price;
  final bool featured;
  final String? dosage;
  final String? packaging;

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawIngredients = json['ingredients'];
    final ingredients = rawIngredients is List
        ? rawIngredients.map((ingredient) => ingredient.toString()).toList()
        : rawIngredients is String && rawIngredients.isNotEmpty
        ? rawIngredients
              .split(',')
              .map((ingredient) => ingredient.trim())
              .where((ingredient) => ingredient.isNotEmpty)
              .toList()
        : <String>[];
    final imageUrl = json['imageUrl']?.toString() ?? '';
    final rawMedia = json['media'];
    final media = rawMedia is List
        ? rawMedia
              .whereType<Map<String, dynamic>>()
              .map(
                (item) => ProductMedia.fromJson(
                  item,
                  productId: json['id'].toString(),
                ),
              )
              .where((item) => item.uri.trim().isNotEmpty)
              .toList()
        : <ProductMedia>[];
    if (imageUrl.trim().isNotEmpty &&
        media.every((item) => item.uri != imageUrl.trim())) {
      media.insert(
        0,
        ProductMedia(
          id: '${json['id']}_primary_image',
          productId: json['id'].toString(),
          type: ProductMediaType.image,
          origin: ProductMediaOrigin.curated,
          uri: imageUrl.trim(),
          title: '${json['name'] ?? 'Product'} image',
          isPrimary: true,
        ),
      );
    }

    return Product(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Uncategorized',
      form: json['form']?.toString() ?? 'Standard',
      ingredients: ingredients,
      description: json['description']?.toString() ?? '',
      imageUrl: imageUrl,
      media: media,
      price: ((json['price'] as num?) ?? 0).toDouble(),
      featured: json['featured'] == true,
      dosage: json['dosage']?.toString(),
      packaging: json['packaging']?.toString(),
    );
  }

  String get priceLabel => 'Rs ${price.toStringAsFixed(2)}';

  ProductMedia? get primaryMedia {
    if (media.isEmpty) {
      return null;
    }

    return media.cast<ProductMedia?>().firstWhere(
      (item) => item?.isPrimary == true,
      orElse: () => media.first,
    );
  }
}

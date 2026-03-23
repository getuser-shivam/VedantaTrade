class Product {
  final String id;
  final String name;
  final String category;
  final String form;
  final List<String> ingredients;
  final String description;
  final String imageUrl;
  final double price;
  final bool featured;
  final String? dosage;
  final String? packaging;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.form,
    required this.ingredients,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.featured = false,
    this.dosage,
    this.packaging,
  });

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

    return Product(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Uncategorized',
      form: json['form']?.toString() ?? 'Standard',
      ingredients: ingredients,
      description: json['description']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      price: (json['price'] as num).toDouble(),
      featured: json['featured'] ?? false,
      dosage: json['dosage']?.toString(),
      packaging: json['packaging']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'form': form,
      'ingredients': ingredients,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'featured': featured,
      'dosage': dosage,
      'packaging': packaging,
    };
  }
}

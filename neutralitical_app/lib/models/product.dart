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
    return Product(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      form: json['form'],
      ingredients: List<String>.from(json['ingredients']),
      description: json['description'],
      imageUrl: json['imageUrl'],
      price: json['price'].toDouble(),
      featured: json['featured'] ?? false,
      dosage: json['dosage'],
      packaging: json['packaging'],
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

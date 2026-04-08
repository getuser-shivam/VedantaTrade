import 'package:equatable/equatable.dart';

class ProductCategory extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final String? imageUrl;
  final int productCount;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductCategory({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.imageUrl,
    this.productCount = 0,
    this.isActive = true,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  ProductCategory copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    String? imageUrl,
    int? productCount,
    bool? isActive,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      imageUrl: imageUrl ?? this.imageUrl,
      productCount: productCount ?? this.productCount,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        icon,
        imageUrl,
        productCount,
        isActive,
        sortOrder,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'ProductCategory(id: $id, name: $name, productCount: $productCount)';
  }

  String get displayName => name;
  bool get hasProducts => productCount > 0;
}

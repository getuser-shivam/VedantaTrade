import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Sort Option Entity
/// Defines available sorting options for products
class SortOptionEntity extends Equatable {
  final String id;
  final String label;
  final String field;
  final String order;
  final IconData icon;
  final String description;

  const SortOptionEntity({
    required this.id,
    required this.label,
    required this.field,
    required this.order,
    required this.icon,
    required this.description,
  });

  /// Create copy with updated values
  SortOptionEntity copyWith({
    String? id,
    String? label,
    String? field,
    String? order,
    IconData? icon,
    String? description,
  }) {
    return SortOptionEntity(
      id: id ?? this.id,
      label: label ?? this.label,
      field: field ?? this.field,
      order: order ?? this.order,
      icon: icon ?? this.icon,
      description: description ?? this.description,
    );
  }

  /// Get sort query string
  String get sortQuery => '$field,$order';

  @override
  List<Object?> get props => [id, label, field, order, icon, description];
}

/// Predefined Sort Options
class PredefinedSortOptions {
  static const List<SortOptionEntity> options = [
    SortOptionEntity(
      id: 'relevance',
      label: 'Relevance',
      field: 'relevance',
      order: 'desc',
      icon: Icons.auto_awesome,
      description: 'Most relevant products first',
    ),
    SortOptionEntity(
      id: 'name_asc',
      label: 'Name A-Z',
      field: 'name',
      order: 'asc',
      icon: Icons.sort_by_alpha,
      description: 'Alphabetical order A to Z',
    ),
    SortOptionEntity(
      id: 'name_desc',
      label: 'Name Z-A',
      field: 'name',
      order: 'desc',
      icon: Icons.sort_by_alpha,
      description: 'Alphabetical order Z to A',
    ),
    SortOptionEntity(
      id: 'price_asc',
      label: 'Price: Low to High',
      field: 'price',
      order: 'asc',
      icon: Icons.attach_money,
      description: 'Lowest price first',
    ),
    SortOptionEntity(
      id: 'price_desc',
      label: 'Price: High to Low',
      field: 'price',
      order: 'desc',
      icon: Icons.attach_money,
      description: 'Highest price first',
    ),
    SortOptionEntity(
      id: 'rating_desc',
      label: 'Highest Rated',
      field: 'rating',
      order: 'desc',
      icon: Icons.star,
      description: 'Best rated products first',
    ),
    SortOptionEntity(
      id: 'newest',
      label: 'Newest First',
      field: 'createdAt',
      order: 'desc',
      icon: Icons.new_releases,
      description: 'Recently added products',
    ),
    SortOptionEntity(
      id: 'oldest',
      label: 'Oldest First',
      field: 'createdAt',
      order: 'asc',
      icon: Icons.history,
      description: 'Oldest products first',
    ),
    SortOptionEntity(
      id: 'stock_desc',
      label: 'Highest Stock',
      field: 'stockQuantity',
      order: 'desc',
      icon: Icons.inventory_2,
      description: 'Most available products',
    ),
    SortOptionEntity(
      id: 'popularity_desc',
      label: 'Most Popular',
      field: 'popularity',
      order: 'desc',
      icon: Icons.trending_up,
      description: 'Most viewed products',
    ),
    SortOptionEntity(
      id: 'discount_desc',
      label: 'Highest Discount',
      field: 'discountPercentage',
      order: 'desc',
      icon: Icons.local_offer,
      description: 'Biggest discounts first',
    ),
    SortOptionEntity(
      id: 'reviews_desc',
      label: 'Most Reviewed',
      field: 'reviewCount',
      order: 'desc',
      icon: Icons.reviews,
      description: 'Most reviewed products',
    ),
  ];

  /// Get sort option by ID
  static SortOptionEntity? getOptionById(String id) {
    try {
      return options.firstWhere((option) => option.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get sort option by field and order
  static SortOptionEntity? getOptionByFieldAndOrder(String field, String order) {
    try {
      return options.firstWhere((option) => option.field == field && option.order == order);
    } catch (e) {
      return null;
    }
  }

  /// Get default sort option
  static SortOptionEntity get defaultOption => options.first;

  /// Get all option IDs
  static List<String> get optionIds => options.map((o) => o.id).toList();
}

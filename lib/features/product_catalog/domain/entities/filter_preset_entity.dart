import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'product_filter_entity.dart';

/// Filter Preset Entity
/// Pre-defined filter combinations for quick access
class FilterPresetEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final ProductFilterEntity filter;
  final DateTime createdAt;
  final int usageCount;
  final bool isSystemPreset;

  const FilterPresetEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.filter,
    required this.createdAt,
    this.usageCount = 0,
    this.isSystemPreset = false,
  });

  /// Create copy with updated values
  FilterPresetEntity copyWith({
    String? id,
    String? name,
    String? description,
    IconData? icon,
    ProductFilterEntity? filter,
    DateTime? createdAt,
    int? usageCount,
    bool? isSystemPreset,
  }) {
    return FilterPresetEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      filter: filter ?? this.filter,
      createdAt: createdAt ?? this.createdAt,
      usageCount: usageCount ?? this.usageCount,
      isSystemPreset: isSystemPreset ?? this.isSystemPreset,
    );
  }

  /// Increment usage count
  FilterPresetEntity incrementUsage() {
    return copyWith(usageCount: usageCount + 1);
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon.codePoint,
      'filter': filter.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'usageCount': usageCount,
      'isSystemPreset': isSystemPreset,
    };
  }

  /// Create from JSON
  factory FilterPresetEntity.fromJson(Map<String, dynamic> json) {
    return FilterPresetEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: IconData(json['icon'] as int, fontFamily: 'MaterialIcons'),
      filter: ProductFilterEntity.fromJson(json['filter'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      usageCount: json['usageCount'] as int? ?? 0,
      isSystemPreset: json['isSystemPreset'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        icon,
        filter,
        createdAt,
        usageCount,
        isSystemPreset,
      ];
}

/// System Filter Presets
class SystemFilterPresets {
  static const List<FilterPresetEntity> presets = [
    FilterPresetEntity(
      id: 'all_products',
      name: 'All Products',
      description: 'Show all products',
      icon: Icons.apps,
      filter: ProductFilterEntity(),
      createdAt: null,
      isSystemPreset: true,
    ),
    FilterPresetEntity(
      id: 'in_stock',
      name: 'In Stock',
      description: 'Only available products',
      icon: Icons.inventory_2,
      filter: ProductFilterEntity(inStockOnly: true),
      createdAt: null,
      isSystemPreset: true,
    ),
    FilterPresetEntity(
      id: 'on_sale',
      name: 'On Sale',
      description: 'Products with discounts',
      icon: Icons.local_offer,
      filter: ProductFilterEntity(onSaleOnly: true),
      createdAt: null,
      isSystemPreset: true,
    ),
    FilterPresetEntity(
      id: 'new_arrivals',
      name: 'New Arrivals',
      description: 'Recently added products',
      icon: Icons.new_releases,
      filter: ProductFilterEntity(
        sortBy: 'createdAt',
        sortOrder: 'desc',
      ),
      createdAt: null,
      isSystemPreset: true,
    ),
    FilterPresetEntity(
      id: 'best_sellers',
      name: 'Best Sellers',
      description: 'Most popular products',
      icon: Icons.trending_up,
      filter: ProductFilterEntity(
        sortBy: 'popularity',
        sortOrder: 'desc',
      ),
      createdAt: null,
      isSystemPreset: true,
    ),
    FilterPresetEntity(
      id: 'low_price',
      name: 'Under NPR 100',
      description: 'Affordable products',
      icon: Icons.attach_money,
      filter: ProductFilterEntity(maxPrice: 100.0),
      createdAt: null,
      isSystemPreset: true,
    ),
    FilterPresetEntity(
      id: 'high_rated',
      name: '4+ Stars',
      description: 'Top-rated products',
      icon: Icons.star,
      filter: ProductFilterEntity(minRating: 4.0),
      createdAt: null,
      isSystemPreset: true,
    ),
    FilterPresetEntity(
      id: 'prescription',
      name: 'Prescription Required',
      description: 'Products requiring prescription',
      icon: Icons.medication,
      filter: ProductFilterEntity(requiresPrescription: true),
      createdAt: null,
      isSystemPreset: true,
    ),
  ];

  /// Get preset by ID
  static FilterPresetEntity? getPresetById(String id) {
    try {
      return presets.firstWhere((preset) => preset.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get all preset IDs
  static List<String> getPresetIds() {
    return presets.map((preset) => preset.id).toList();
  }
}

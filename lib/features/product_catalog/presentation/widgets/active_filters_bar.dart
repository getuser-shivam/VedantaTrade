import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/product_filter_entity.dart';
import '../providers/enhanced_filter_provider.dart';
import 'package:provider/provider.dart';

/// Active Filters Bar
/// Displays currently active filters with quick remove options
class ActiveFiltersBar extends StatelessWidget {
  const ActiveFiltersBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<EnhancedFilterProvider>();

    if (!provider.hasActiveFilters) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Filters (${provider.activeFilterCount})',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  provider.clearAllFilters();
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _buildFilterChips(context, provider, theme),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFilterChips(
    BuildContext context,
    EnhancedFilterProvider provider,
    ThemeData theme,
  ) {
    final filter = provider.currentFilter;
    final chips = <Widget>[];

    // Search query
    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      chips.add(_buildFilterChip(
        context,
        label: '"${filter.searchQuery}"',
        icon: Icons.search,
        onRemove: () => provider.clearFilterCategory('search'),
        theme: theme,
      ));
    }

    // Categories
    for (final category in filter.categories) {
      chips.add(_buildFilterChip(
        context,
        label: category,
        icon: Icons.category,
        onRemove: () {
          final updatedCategories = List<String>.from(filter.categories)
            ..remove(category);
          provider.updateFilterField(categories: updatedCategories);
        },
        theme: theme,
      ));
    }

    // Brands
    for (final brand in filter.brands) {
      chips.add(_buildFilterChip(
        context,
        label: brand,
        icon: Icons.business,
        onRemove: () {
          final updatedBrands = List<String>.from(filter.brands)..remove(brand);
          provider.updateFilterField(brands: updatedBrands);
        },
        theme: theme,
      ));
    }

    // Manufacturers
    for (final manufacturer in filter.manufacturers) {
      chips.add(_buildFilterChip(
        context,
        label: manufacturer,
        icon: Icons.factory,
        onRemove: () {
          final updatedManufacturers = List<String>.from(filter.manufacturers)
            ..remove(manufacturer);
          provider.updateFilterField(manufacturers: updatedManufacturers);
        },
        theme: theme,
      ));
    }

    // Price range
    if (filter.hasPriceRange) {
      chips.add(_buildFilterChip(
        context,
        label: filter.formattedPriceRange,
        icon: Icons.attach_money,
        onRemove: () => provider.clearFilterCategory('price'),
        theme: theme,
      ));
    }

    // Stock status
    if (filter.inStockOnly == true) {
      chips.add(_buildFilterChip(
        context,
        label: 'In Stock',
        icon: Icons.inventory_2,
        onRemove: () => provider.updateFilterField(inStockOnly: null),
        theme: theme,
      ));
    }

    // On sale
    if (filter.onSaleOnly == true) {
      chips.add(_buildFilterChip(
        context,
        label: 'On Sale',
        icon: Icons.local_offer,
        onRemove: () => provider.updateFilterField(onSaleOnly: null),
        theme: theme,
      ));
    }

    // Prescription
    if (filter.requiresPrescription != null) {
      chips.add(_buildFilterChip(
        context,
        label: 'Prescription',
        icon: Icons.medication,
        onRemove: () => provider.updateFilterField(requiresPrescription: null),
        theme: theme,
      ));
    }

    // Rating
    if (filter.minRating != null) {
      chips.add(_buildFilterChip(
        context,
        label: '${filter.minRating}+ Stars',
        icon: Icons.star,
        onRemove: () => provider.updateFilterField(minRating: null),
        theme: theme,
      ));
    }

    // Sort
    if (filter.sortBy != null) {
      chips.add(_buildFilterChip(
        context,
        label: _getSortLabel(filter.sortBy!, filter.sortOrder),
        icon: Icons.sort,
        onRemove: () => provider.updateFilterField(sortBy: null, sortOrder: null),
        theme: theme,
      ));
    }

    return chips;
  }

  Widget _buildFilterChip(
    BuildContext context,
    {
    required String label,
    required IconData icon,
    required VoidCallback onRemove,
    required ThemeData theme,
  }) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(
        label,
        style: TextStyle(fontSize: 13),
      ),
      deleteIcon: Icon(Icons.close, size: 16),
      onDeleted: () {
        HapticFeedback.lightImpact();
        onRemove();
      },
      backgroundColor: theme.colorScheme.primaryContainer,
      deleteIconColor: theme.colorScheme.onPrimaryContainer,
      labelStyle: TextStyle(color: theme.colorScheme.onPrimaryContainer),
    );
  }

  String _getSortLabel(String? sortBy, String? sortOrder) {
    if (sortBy == null) return '';
    
    switch (sortBy) {
      case 'price':
        return sortOrder == 'asc' ? 'Price: Low to High' : 'Price: High to Low';
      case 'rating':
        return 'Highest Rated';
      case 'createdAt':
        return 'Newest First';
      case 'name':
        return sortOrder == 'asc' ? 'Name A-Z' : 'Name Z-A';
      default:
        return sortBy;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../providers/product_provider.dart';
import '../domain/models/product_entity.dart';
import '../domain/models/product_filter.dart';
import 'product_card_widget.dart';

class ProductList extends StatelessWidget {
  final ProductProvider provider;
  final ScrollController? scrollController;

  const ProductList({
    Key? key,
    required this.provider,
    this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search and Filter Section
        _buildSearchAndFilterSection(context),
        const SizedBox(height: 16),
        // Sorting and View Options
        _buildSortAndViewOptions(context),
        const SizedBox(height: 16),
        // Products Grid
        Expanded(
          child: _buildProductsGrid(context),
        ),
        // Load More Button
        if (provider.hasNextPage)
          _buildLoadMoreButton(),
      ],
    );
  }

  Widget _buildSearchAndFilterSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: TextEditingController(),
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: provider.filter.searchQuery?.isNotEmpty == true
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => provider.updateSearchQuery(''),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) {
              provider.updateSearchQuery(value ?? '');
            },
          ),
          const SizedBox(height: 16),
          // Filter Chips
          _buildFilterChips(context),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Category Filter
        FilterChip(
          label: 'Category: ${_getCategoryDisplayName(provider.filter.category)}',
          selected: provider.filter.category != null && provider.filter.category != ProductCategory.all,
          onSelected: () => _showCategoryFilter(context),
          deleteIcon: provider.filter.category != null && provider.filter.category != ProductCategory.all
              ? const Icon(Icons.close, size: 16)
              : null,
        ),
        // Price Range Filter
        if (provider.filter.minPrice != null || provider.filter.maxPrice != null)
          FilterChip(
            label: 'Price: ${_getPriceRangeDisplay()}',
            selected: true,
            onSelected: () => _showPriceFilter(context),
            deleteIcon: const Icon(Icons.close, size: 16),
          ),
        // In Stock Filter
        if (provider.filter.inStock != null)
          FilterChip(
            label: provider.filter.inStock == true ? 'In Stock' : 'Out of Stock',
            selected: true,
            onSelected: () => provider.updateCategoryFilter(ProductCategory.all),
            deleteIcon: const Icon(Icons.close, size: 16),
          ),
        // Clear All Filters
        if (provider.filter.hasActiveFilters)
          FilterChip(
            label: 'Clear All',
            selected: false,
            onSelected: () => provider.clearFilters(),
            backgroundColor: Colors.red.withOpacity(0.1),
            labelStyle: TextStyle(color: Colors.red[700]),
          ),
      ],
    );
  }

  Widget _buildSortAndViewOptions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Sort Dropdown
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                value: provider.filter.sortBy,
                items: [
                  const DropdownMenuItem(
                    value: ProductSortOption.nameAsc,
                    child: Text('Name (A-Z)'),
                  ),
                  const DropdownMenuItem(
                    value: ProductSortOption.nameDesc,
                    child: Text('Name (Z-A)'),
                  ),
                  const DropdownMenuItem(
                    value: ProductSortOption.priceAsc,
                    child: Text('Price (Low to High)'),
                  ),
                  const DropdownMenuItem(
                    value: ProductSortOption.priceDesc,
                    child: Text('Price (High to Low)'),
                  ),
                  const DropdownMenuItem(
                    value: ProductSortOption.newest,
                    child: Text('Newest First'),
                  ),
                  const DropdownMenuItem(
                    value: ProductSortOption.stockAsc,
                    child: Text('Stock (Low to High)'),
                  ),
                ],
                onChanged: (ProductSortOption? value) {
                  if (value != null) {
                    provider.updateSortOption(value);
                  }
                },
                icon: const Icon(Icons.sort),
                iconSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // View Mode Toggle
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.grid_view),
                onPressed: () {
                  // Toggle to grid view
                },
                color: Theme.of(context).primaryColor,
              ),
              IconButton(
                icon: const Icon(Icons.list),
                onPressed: () {
                  // Toggle to list view
                },
                color: Colors.grey[600],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid(BuildContext context) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              provider.error!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.refreshProducts(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (provider.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or search terms',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return NotificationListener<ScrollEndNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter == notification.metrics.maxScrollExtent) {
          // Load more when reaching bottom
          provider.loadMoreProducts();
        }
      },
      child: RefreshIndicator(
        onRefresh: () => provider.refreshProducts(),
        child: MasonryGridView.count(
          crossAxisCount: _getCrossAxisCount(context),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          itemCount: provider.products.length,
          itemBuilder: (context, index) {
            final product = provider.products[index];
            return ProductCardWidget(
              product: product,
              onTap: () => _showProductDetails(context, product),
              onFavorite: () => provider.toggleFavorite(product.id),
              isFavorite: false, // Would come from provider
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ElevatedButton.icon(
          onPressed: provider.isLoading ? null : () => provider.loadMoreProducts(),
          icon: provider.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.add),
          label: Text(provider.isLoading ? 'Loading...' : 'Load More'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) return 4;
    if (screenWidth > 800) return 3;
    if (screenWidth > 600) return 2;
    return 1;
  }

  String _getCategoryDisplayName(ProductCategory? category) {
    if (category == null || category == ProductCategory.all) return 'All';
    return category!.name.replaceAll('_', ' ').split(' ').map((word) => 
        word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  String _getPriceRangeDisplay() {
    final minPrice = provider.filter.minPrice;
    final maxPrice = provider.filter.maxPrice;
    if (minPrice != null && maxPrice != null) {
      return 'NPR ${minPrice!.toStringAsFixed(0)} - ${maxPrice!.toStringAsFixed(0)}';
    } else if (minPrice != null) {
      return 'NPR ${minPrice!.toStringAsFixed(0)}+';
    } else if (maxPrice != null) {
      return 'NPR ${maxPrice!.toStringAsFixed(0)}-';
    }
    return 'Any Price';
  }

  void _showCategoryFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...ProductCategory.values.map((category) => ListTile(
              title: Text(_getCategoryDisplayName(category)),
              onTap: () {
                provider.updateCategoryFilter(category);
                Navigator.pop(context);
              },
              selected: provider.filter.category == category,
            )).toList(),
          ],
        ),
      ),
    );
  }

  void _showPriceFilter(BuildContext context) {
    final minController = TextEditingController(text: provider.filter.minPrice?.toString() ?? '');
    final maxController = TextEditingController(text: provider.filter.maxPrice?.toString() ?? '');
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Price Range',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: minController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Minimum Price (NPR)',
                prefixText: 'NPR ',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: maxController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Maximum Price (NPR)',
                prefixText: 'NPR ',
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final minPrice = double.tryParse(minController.text);
                      final maxPrice = double.tryParse(maxController.text);
                      if (minPrice != null && maxPrice != null) {
                        provider.updatePriceRangeFilter(minPrice!, maxPrice!);
                      }
                      Navigator.pop(context);
                    },
                    child: const Text('Apply'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showProductDetails(BuildContext context, ProductEntity product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }
}

class FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final Widget? deleteIcon;

  const FilterChip({
    Key? key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.deleteIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? Theme.of(context).primaryColor : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (deleteIcon != null) ...[
              const SizedBox(width: 8),
              deleteIcon!,
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../data/repositories/product_repository_impl.dart';
import '../widgets/product_list.dart';

class ProductCatalogScreen extends StatefulWidget {
  const ProductCatalogScreen({Key? key}) : super(key: key);

  @override
  State<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen> {
  late ProductProvider _productProvider;

  @override
  void initState() {
    super.initState();
    _productProvider = ProductProvider(
      repository: ProductRepositoryImpl(),
    );
    _productProvider.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _productProvider,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Product Catalog'),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFilterOptions(context),
              tooltip: 'Filter Options',
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _showSearchDialog(context),
              tooltip: 'Search Products',
            ),
          ],
        ),
        body: ProductList(provider: _productProvider),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _scrollToTop(),
          child: const Icon(Icons.keyboard_arrow_up),
          tooltip: 'Scroll to Top',
        ),
      ),
    );
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Filter Options Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Options',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              // Quick Filters
              _buildQuickFilters(context),
              const SizedBox(height: 24),
              // Advanced Filters
              _buildAdvancedFilters(context),
              const SizedBox(height: 24),
              // Apply Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Apply Filters'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickFilters(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Filters',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickFilterChip(context, 'In Stock', 'inventory_2', () {
              _productProvider.updateCategoryFilter(ProductCategory.all);
              _productProvider.applyFilter(const ProductFilter(inStock: true));
            }),
            _buildQuickFilterChip(context, 'Discounted', 'local_offer', () {
              _productProvider.updateCategoryFilter(ProductCategory.all);
              _productProvider.applyFilter(const ProductFilter(hasDiscount: true));
            }),
            _buildQuickFilterChip(context, 'Expiring Soon', 'access_time', () {
              _productProvider.updateCategoryFilter(ProductCategory.all);
              _productProvider.applyFilter(const ProductFilter(expiringSoon: true));
            }),
            _buildQuickFilterChip(context, 'Low Stock', 'warning', () {
              _productProvider.updateCategoryFilter(ProductCategory.all);
              _productProvider.applyFilter(const ProductFilter(inStock: false));
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickFilterChip(BuildContext context, String label, String icon, VoidCallback onTap) {
    return FilterChip(
      label: label,
      selected: false,
      onSelected: onTap,
      deleteIcon: const Icon(Icons.close, size: 16),
    );
  }

  Widget _buildAdvancedFilters(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Advanced Filters',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        // Category Filter
        ListTile(
          leading: const Icon(Icons.category),
          title: const Text('Category'),
          trailing: DropdownButton<ProductCategory>(
            value: _productProvider.filter.category,
            items: ProductCategory.values.map((category) => DropdownMenuItem(
              value: category,
              child: Text(_getCategoryDisplayName(category)),
            )).toList(),
            onChanged: (ProductCategory? value) {
              if (value != null) {
                _productProvider.updateCategoryFilter(value!);
              }
            },
          ),
        ),
        const SizedBox(height: 8),
        // Price Range Filter
        ListTile(
          leading: const Icon(Icons.attach_money),
          title: const Text('Price Range'),
          subtitle: Text(_getPriceRangeDisplay()),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showPriceRangeFilter(context),
        ),
        const SizedBox(height: 8),
        // Manufacturer Filter
        ListTile(
          leading: const Icon(Icons.business),
          title: const Text('Manufacturer'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showManufacturerFilter(context),
        ),
        const SizedBox(height: 8),
        // Sort Options
        ListTile(
          leading: const Icon(Icons.sort),
          title: const Text('Sort By'),
          trailing: DropdownButton<ProductSortOption>(
            value: _productProvider.filter.sortBy,
            items: const [
              DropdownMenuItem(value: ProductSortOption.nameAsc, child: Text('Name (A-Z)')),
              DropdownMenuItem(value: ProductSortOption.nameDesc, child: Text('Name (Z-A)')),
              DropdownMenuItem(value: ProductSortOption.priceAsc, child: Text('Price (Low to High)')),
              DropdownMenuItem(value: ProductSortOption.priceDesc, child: Text('Price (High to Low)')),
              DropdownMenuItem(value: ProductSortOption.newest, child: Text('Newest First')),
              DropdownMenuItem(value: ProductSortOption.oldest, child: Text('Oldest First')),
            ],
            onChanged: (ProductSortOption? value) {
              if (value != null) {
                _productProvider.updateSortOption(value!);
              }
            },
          ),
        ),
      ],
    );
  }

  String _getCategoryDisplayName(ProductCategory category) {
    switch (category) {
      case ProductCategory.all:
        return 'All';
      case ProductCategory.medicines:
        return 'Medicines';
      case ProductCategory.medicalDevices:
        return 'Medical Devices';
      case ProductCategory.consumables:
        return 'Consumables';
      case ProductCategory.equipment:
        return 'Equipment';
      case ProductCategory.supplements:
        return 'Supplements';
    }
  }

  String _getPriceRangeDisplay() {
    final minPrice = _productProvider.filter.minPrice;
    final maxPrice = _productProvider.filter.maxPrice;
    if (minPrice != null && maxPrice != null) {
      return 'NPR ${minPrice!.toStringAsFixed(0)} - ${maxPrice!.toStringAsFixed(0)}';
    } else if (minPrice != null) {
      return 'NPR ${minPrice!.toStringAsFixed(0)}+';
    } else if (maxPrice != null) {
      return 'NPR ${maxPrice!.toStringAsFixed(0)}-';
    }
    return 'Any Price';
  }

  void _showPriceRangeFilter(BuildContext context) {
    final minController = TextEditingController(text: _productProvider.filter.minPrice?.toString() ?? '');
    final maxController = TextEditingController(text: _productProvider.filter.maxPrice?.toString() ?? '');
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Price Range Filter',
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
                        _productProvider.updatePriceRangeFilter(minPrice!, maxPrice!);
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

  void _showManufacturerFilter(BuildContext context) {
    // Would show manufacturer selection dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Manufacturer filter coming soon'),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    final searchController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Products'),
        content: TextField(
          controller: searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter product name, category, or manufacturer...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _productProvider.updateSearchQuery(searchController.text);
              Navigator.pop(context);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _scrollToTop() {
    // Would scroll to top of product list
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Scrolled to top'),
      ),
    );
  }
}

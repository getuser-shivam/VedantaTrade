import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/premium_glassmorphic_theme.dart';
import '../providers/product_provider.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../widgets/search_filter_sheet.dart';
import '../widgets/product_comparison_sheet.dart';

class ProductCatalogScreen extends StatefulWidget {
  const ProductCatalogScreen({Key? key}) : super(key: key);

  @override
  State<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;

  bool _isSearching = false;
  int _selectedCategoryIndex = 0;
  String _searchQuery = '';
  List<Product> _selectedProducts = [];
  Map<String, dynamic> _filters = {};
  String _sortBy = 'name'; // name, price, category, manufacturer
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    
    _searchController.addListener(_onSearchChanged);
    
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    if (query != _searchQuery) {
      _searchQuery = query;
      Provider.of<ProductProvider>(context, listen: false).setSearchQuery(query);
    }
  }

  Future<void> _loadData() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    await Future.wait([
      productProvider.loadProducts(),
      productProvider.loadCategories(),
      productProvider.loadManufacturers(),
    ]);
  }

  void _selectCategory(int index, List<Category> categories) {
    setState(() {
      _selectedCategoryIndex = index;
    });
    
    final categoryName = index == 0 ? 'All' : categories[index - 1].name;
    final filters = Map<String, dynamic>.from(_filters);
    filters['category'] = categoryName;
    
    Provider.of<ProductProvider>(context, listen: false).applyFilters(filters);
  }

  void _toggleSort() {
    setState(() {
      if (_sortBy == 'name') {
        _sortBy = 'price';
      } else if (_sortBy == 'price') {
        _sortBy = 'category';
      } else if (_sortBy == 'category') {
        _sortBy = 'manufacturer';
      } else {
        _sortBy = 'name';
        _sortAscending = !_sortAscending;
      }
    });
    
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    productProvider.sortProducts(_sortBy, _sortAscending);
  }

  @override
  Widget build(BuildContext context) {
    return PremiumGlassmorphicTheme.glassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildSearchBar(),
            _buildCategoryTabs(),
            _buildSortOptions(),
            Expanded(
              child: Consumer<ProductProvider>(
                builder: (context, productProvider, child) {
                  if (productProvider.isLoading && productProvider.products.isEmpty) {
                    return const Center(
                      child: PremiumGlassmorphicTheme.glassLoading(),
                    );
                  }
                  
                  if (productProvider.products.isEmpty) {
                    return _buildEmptyState();
                  }

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildProductsGrid(productProvider.products),
                      _buildCategoriesGrid(productProvider.categories),
                      _buildManufacturersGrid(productProvider.manufacturers),
                      _buildComparisonView(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: _selectedProducts.isNotEmpty
            ? PremiumGlassmorphicTheme.glassFab(
                onPressed: _showComparisonSheet,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.compare),
                    const SizedBox(width: 8),
                    Text('Compare (${_selectedProducts.length})'),
                  ],
                ),
                extended: true,
              )
            : null,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PremiumGlassmorphicTheme.glassAppBar(
      title: 'Product Catalog',
      actions: [
        IconButton(
          onPressed: _toggleSearch,
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          color: PremiumGlassmorphicTheme.textPrimary,
        ),
        IconButton(
          onPressed: _showFilterSheet,
          icon: const Icon(Icons.filter_list),
          color: PremiumGlassmorphicTheme.textPrimary,
        ),
        IconButton(
          onPressed: _handleLogout,
          icon: const Icon(Icons.logout),
          color: PremiumGlassmorphicTheme.error,
        ),
      ],
      bottom: PremiumGlassmorphicTheme.glassTabBar(
        tabs: const [
          'Products',
          'Categories', 
          'Manufacturers',
          'Compare',
        ],
        selectedIndex: _tabController.index,
        onTap: (index) => _tabController.animateTo(index),
      ),
    );
  }

  Widget _buildSearchBar() {
    if (!_isSearching) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingMd),
      child: PremiumGlassmorphicTheme.getInputDecoration(
        hintText: 'Search products by name, category, or manufacturer...',
        prefixIcon: Icons.search,
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        final categories = provider.categories;
        return Container(
          height: 60,
          padding: const EdgeInsets.symmetric(
            vertical: PremiumGlassmorphicTheme.spacingSm,
            horizontal: PremiumGlassmorphicTheme.spacingMd,
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length + 1,
            itemBuilder: (context, index) {
              final isSelected = index == _selectedCategoryIndex;
              final name = index == 0 ? 'All' : categories[index - 1].name;
              
              return Padding(
                padding: const EdgeInsets.only(
                  right: PremiumGlassmorphicTheme.spacingSm,
                ),
                child: PremiumGlassmorphicTheme.glassChip(
                  label: name,
                  selected: isSelected,
                  onTap: () => _selectCategory(index, categories),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSortOptions() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PremiumGlassmorphicTheme.spacingMd,
        vertical: PremiumGlassmorphicTheme.spacingSm,
      ),
      child: Row(
        children: [
          Text(
            'Sort by:',
            style: TextStyle(
              color: PremiumGlassmorphicTheme.textSecondary,
              fontSize: PremiumGlassmorphicTheme.fontSizeSm,
            ),
          ),
          const SizedBox(width: PremiumGlassmorphicTheme.spacingSm),
          PremiumGlassmorphicTheme.glassChip(
            label: _sortBy == 'name' 
                ? 'Name ${_sortAscending ? '↑' : '↓'}'
                : _sortBy == 'price'
                    ? 'Price ${_sortAscending ? '↑' : '↓'}'
                    : _sortBy == 'category'
                        ? 'Category'
                        : 'Manufacturer',
            selected: true,
            onTap: _toggleSort,
          ),
          const Spacer(),
          Text(
            '${Provider.of<ProductProvider>(context).products.length} products',
            style: TextStyle(
              color: PremiumGlassmorphicTheme.textTertiary,
              fontSize: PremiumGlassmorphicTheme.fontSizeSm,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid(List<Product> products) {
    return RefreshIndicator(
      onRefresh: () => Provider.of<ProductProvider>(context, listen: false).refresh(),
      child: GridView.builder(
        padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingMd),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.68,
          crossAxisSpacing: PremiumGlassmorphicTheme.spacingMd,
          mainAxisSpacing: PremiumGlassmorphicTheme.spacingMd,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final isSelected = _selectedProducts.any((p) => p.id == product.id);
          
          return ProductCard(
            product: product,
            isSelected: isSelected,
            onTap: () => _navigateToProductDetails(product),
            onSelectionChanged: (selected) {
              setState(() {
                if (selected) {
                  _selectedProducts.add(product);
                } else {
                  _selectedProducts.removeWhere((p) => p.id == product.id);
                }
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoriesGrid(List<Category> categories) {
    return GridView.builder(
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingMd),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: PremiumGlassmorphicTheme.spacingMd,
        mainAxisSpacing: PremiumGlassmorphicTheme.spacingMd,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return PremiumGlassmorphicTheme.glassCard(
          child: InkWell(
            onTap: () => _selectCategory(index + 1, categories),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.category, size: 40, color: Colors.blue),
                const SizedBox(height: PremiumGlassmorphicTheme.spacingSm),
                Text(
                  category.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: PremiumGlassmorphicTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: PremiumGlassmorphicTheme.spacingXs),
                Text(
                  '${category.productCount} products',
                  style: const TextStyle(
                    color: PremiumGlassmorphicTheme.textSecondary,
                    fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildManufacturersGrid(List<Manufacturer> manufacturers) {
    return GridView.builder(
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingMd),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: PremiumGlassmorphicTheme.spacingMd,
        mainAxisSpacing: PremiumGlassmorphicTheme.spacingMd,
      ),
      itemCount: manufacturers.length,
      itemBuilder: (context, index) {
        final manufacturer = manufacturers[index];
        return PremiumGlassmorphicTheme.glassCard(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.business, size: 40, color: Colors.green),
              const SizedBox(height: PremiumGlassmorphicTheme.spacingSm),
              Text(
                manufacturer.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: PremiumGlassmorphicTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: PremiumGlassmorphicTheme.spacingXs),
              Text(
                '${manufacturer.productCount} products',
                style: const TextStyle(
                  color: PremiumGlassmorphicTheme.textSecondary,
                  fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildComparisonView() {
    if (_selectedProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.compare_arrows,
              size: 64,
              color: PremiumGlassmorphicTheme.textTertiary,
            ),
            const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
            Text(
              'No products selected for comparison',
              style: TextStyle(
                color: PremiumGlassmorphicTheme.textSecondary,
                fontSize: PremiumGlassmorphicTheme.fontSizeLg,
              ),
            ),
            const SizedBox(height: PremiumGlassmorphicTheme.spacingSm),
            Text(
              'Select products from the catalog to compare their features',
              style: TextStyle(
                color: PremiumGlassmorphicTheme.textTertiary,
                fontSize: PremiumGlassmorphicTheme.fontSizeSm,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingMd),
      itemCount: _selectedProducts.length,
      itemBuilder: (context, index) {
        final product = _selectedProducts[index];
        return PremiumGlassmorphicTheme.glassListItem(
          title: product.name,
          subtitle: '${product.category} • ${product.formattedPrice}',
          leadingIcon: Icons.medication,
          trailing: IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: () {
              setState(() {
                _selectedProducts.removeAt(index);
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: PremiumGlassmorphicTheme.textTertiary,
          ),
          const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
          Text(
            'No products found',
            style: TextStyle(
              color: PremiumGlassmorphicTheme.textSecondary,
              fontSize: PremiumGlassmorphicTheme.fontSizeLg,
            ),
          ),
          const SizedBox(height: PremiumGlassmorphicTheme.spacingSm),
          Text(
            'Try adjusting your filters or search criteria',
            style: TextStyle(
              color: PremiumGlassmorphicTheme.textTertiary,
              fontSize: PremiumGlassmorphicTheme.fontSizeSm,
            ),
          ),
          const SizedBox(height: PremiumGlassmorphicTheme.spacingLg),
          PremiumGlassmorphicTheme.glassButton(
            onPressed: _clearFilters,
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchFocusNode.unfocus();
      }
    });
  }

  void _clearFilters() {
    setState(() {
      _filters.clear();
      _selectedCategoryIndex = 0;
      _searchController.clear();
      _sortBy = 'name';
      _sortAscending = true;
    });
    Provider.of<ProductProvider>(context, listen: false).clearFilters();
  }

  void _showFilterSheet() {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchFilterSheet(
        categories: provider.categories,
        manufacturers: provider.manufacturers,
        currentFilters: _filters,
        onFiltersChanged: (filters) {
          setState(() => _filters = filters);
          provider.applyFilters(filters);
        },
      ),
    );
  }

  void _showComparisonSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductComparisonSheet(
        products: _selectedProducts,
        onProductRemoved: (product) {
          setState(() {
            _selectedProducts.removeWhere((p) => p.id == product.id);
          });
        },
      ),
    );
  }

  void _navigateToProductDetails(Product product) {
    context.push('/product/${product.id}');
  }

  void _handleLogout() {
    context.read<AuthProvider>().logout();
  }
}

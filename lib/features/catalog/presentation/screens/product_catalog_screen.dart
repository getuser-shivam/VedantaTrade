import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/glassmorphic_widgets.dart';
import '../providers/product_provider.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../widgets/search_filter_sheet.dart';
import '../widgets/product_comparison_sheet.dart';
import '../widgets/barcode_scanner_widget.dart';
import '../widgets/inventory_status_widget.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Handled by theme background
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryTabs(),
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                if (productProvider.isLoading && productProvider.products.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
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
          ? FloatingActionButton.extended(
              onPressed: _showComparisonSheet,
              label: Text('Compare (${_selectedProducts.length})'),
              icon: const Icon(Icons.compare),
              backgroundColor: Theme.of(context).colorScheme.primary,
            )
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Product Catalog'),
      actions: [
        IconButton(
          onPressed: _showBarcodeScanner,
          icon: const Icon(Icons.qr_code_scanner),
          tooltip: 'Scan Product Barcode',
        ),
        IconButton(
          onPressed: _toggleSearch,
          icon: Icon(_isSearching ? Icons.close : Icons.search),
        ),
        IconButton(
          onPressed: _showFilterSheet,
          icon: const Icon(Icons.filter_list),
        ),
        IconButton(
          onPressed: _handleLogout,
          icon: const Icon(Icons.logout, color: Colors.redAccent),
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Products', icon: Icon(Icons.inventory_2)),
          Tab(text: 'Categories', icon: Icon(Icons.category)),
          Tab(text: 'Manufacturers', icon: Icon(Icons.business)),
          Tab(text: 'Compare', icon: Icon(Icons.compare)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    if (!_isSearching) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassmorphicTextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        hintText: 'Search products...',
        prefixIcon: Icons.search,
        onChanged: (value) => _onSearchChanged(),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        final categories = provider.categories;
        return Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length + 1,
            itemBuilder: (context, index) {
              final isSelected = index == _selectedCategoryIndex;
              final name = index == 0 ? 'All' : categories[index - 1].name;
              
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: GlassmorphicChip(
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

  Widget _buildProductsGrid(List<Product> products) {
    return RefreshIndicator(
      onRefresh: () => Provider.of<ProductProvider>(context, listen: false).refresh(),
      child: Column(
        children: [
          // Inventory Status Overview
          Container(
            margin: const EdgeInsets.all(16),
            child: StockAlertWidget(
              lowStockProducts: ['ARGIVIT', 'MEGA-O'], // Example data
              outOfStockProducts: [], // Example data
            ),
          ),
          
          // Products Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
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
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid(List<Category> categories) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return GlassmorphicCard(
          child: InkWell(
            onTap: () => _selectCategory(index + 1, categories),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.category, size: 40, color: Colors.blue),
                const SizedBox(height: 12),
                Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildManufacturersGrid(List<Manufacturer> manufacturers) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: manufacturers.length,
      itemBuilder: (context, index) {
        final manufacturer = manufacturers[index];
        return GlassmorphicCard(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.business, size: 40, color: Colors.greenAccent),
              const SizedBox(height: 12),
              Text(manufacturer.name, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ],
          ),
        );
      },
    );
  }

  Widget _buildComparisonView() {
    if (_selectedProducts.isEmpty) {
      return const Center(child: Text('No products selected for comparison'));
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _selectedProducts.length,
      itemBuilder: (context, index) {
        final product = _selectedProducts[index];
        return GlassmorphicListItem(
          title: product.name,
          subtitle: product.formattedPrice,
          trailingIcon: Icons.remove_circle_outline,
          onTap: () {
            setState(() {
              _selectedProducts.removeAt(index);
            });
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.white24),
          const SizedBox(height: 16),
          const Text('No products found', style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 16),
          GlassmorphicButton(
            onPressed: _clearFilters,
            text: 'Clear Filters',
            width: 150,
          ),
        ],
      ),
    );
  }

  void _showBarcodeScanner() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BarcodeScannerScreen(
          onBarcodeDetected: (barcode) {
            _searchForProductByBarcode(barcode);
          },
        ),
      ),
    );
  }

  void _searchForProductByBarcode(String barcode) {
    // TODO: Implement barcode-based product search
    // For now, show a snackbar with the scanned barcode
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Searching for product with barcode: $barcode'),
        backgroundColor: AppTheme.primary,
        duration: const Duration(seconds: 2),
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

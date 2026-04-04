import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
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
  List<dynamic> _selectedProducts = [];
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

  void _selectCategory(int index, List<dynamic> categories) {
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
      backgroundColor: Colors.grey[100],
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
              backgroundColor: Colors.blue,
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
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search products...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            onPressed: () {
              _searchController.clear();
              _searchFocusNode.unfocus();
            },
            icon: const Icon(Icons.clear),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final categories = productProvider.categories;
        final tabs = ['All', ...categories.map((c) => c.toString()).toList()];
        
        return Container(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: tabs.length,
            itemBuilder: (context, index) {
              final isSelected = index == _selectedCategoryIndex;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: FilterChip(
                  label: Text(tabs[index]),
                  selected: isSelected,
                  onSelected: (selected) => _selectCategory(index, categories),
                  backgroundColor: Colors.white,
                  selectedColor: Colors.blue.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.blue : Colors.black,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProductsGrid(List<dynamic> products) {
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

  Widget _buildCategoriesGrid(List<dynamic> categories) {
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
        return Card(
          child: InkWell(
            onTap: () => _selectCategory(index + 1, categories),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.category, size: 40, color: Colors.blue),
                const SizedBox(height: 8),
                Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildManufacturersGrid(List<dynamic> manufacturers) {
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
        return Card(
          child: InkWell(
            onTap: () {
              // TODO: Filter by manufacturer
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.business, size: 40, color: Colors.greenAccent),
                const SizedBox(height: 12),
                Text(manufacturer.name, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              ],
            ),
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
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text(product.name),
            subtitle: Text(product.formattedPrice),
            trailing: const Icon(Icons.remove_circle_outline),
            onTap: () {
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
          const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No products found', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _clearFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear Filters'),
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
        backgroundColor: Colors.blue,
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
    // TODO: Implement filter sheet
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filter functionality coming soon')),
    );
  }

  void _showComparisonSheet() {
    // TODO: Implement comparison sheet
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comparison functionality coming soon')),
    );
  }

  void _navigateToProductDetails(dynamic product) {
    context.push('/product/${product.id}');
  }

  void _handleLogout() {
    // TODO: Implement logout functionality
    Navigator.of(context).pushReplacementNamed('/login');
  }
}

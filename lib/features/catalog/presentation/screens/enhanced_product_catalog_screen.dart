import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/enhanced_ui_components.dart';
import '../../../shared/widgets/lottie_animations.dart';
import '../../../shared/widgets/responsive_layout.dart';
import '../../../shared/widgets/skeleton_loading.dart';
import '../../../app/theme/enhanced_app_theme.dart';
import '../providers/product_provider.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../widgets/search_filter_sheet.dart';
import '../widgets/product_comparison_sheet.dart';
import '../widgets/product_detail_sheet.dart';
import '../widgets/advanced_filter_sheet.dart';

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
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isSearching = false;
  bool _isFiltering = false;
  bool _isComparing = false;
  int _selectedCategoryIndex = 0;
  String _searchQuery = '';
  List<Product> _selectedProducts = [];
  Map<String, dynamic> _filters = {};
  String _sortBy = 'name';
  bool _sortAscending = true;
  int _crossAxisCount = 2;

  final List<String> _categories = [
    'All Products',
    'Medicines',
    'Medical Supplies',
    'Equipment',
    'Supplements',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadData();
  }

  void _initializeControllers() {
    _tabController = TabController(length: _categories.length, vsync: this);
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _searchController.addListener(_onSearchChanged);
    _tabController.addListener(_onTabChanged);
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _isSearching = _searchQuery.isNotEmpty;
    });
    _filterProducts();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      _selectedCategoryIndex = _tabController.index;
    });
    _filterProducts();
  }

  Future<void> _loadData() async {
    final productProvider = context.read<ProductProvider>();
    await productProvider.loadProducts();
    await productProvider.loadCategories();
  }

  void _filterProducts() {
    final productProvider = context.read<ProductProvider>();
    productProvider.filterProducts(
      query: _searchQuery,
      category: _categories[_selectedCategoryIndex],
      filters: _filters,
      sortBy: _sortBy,
      sortAscending: _sortAscending,
    );
  }

  @override
  Widget build(BuildContext context) {
    _crossAxisCount = ResponsiveLayout.responsiveColumns(
      context: context,
      mobileColumns: 2,
      tabletColumns: 3,
      desktopColumns: 4,
      largeDesktopColumns: 5,
    );

    return Scaffold(
      backgroundColor: EnhancedAppTheme.backgroundColor,
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  _buildHeader(),
                  _buildSearchAndFilterBar(),
                  _buildCategoryTabs(),
                  Expanded(
                    child: _buildProductGrid(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: _buildFloatingActions(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: ResponsiveLayout.responsivePadding(
        context: context,
        mobilePadding: const EdgeInsets.all(16),
        tabletPadding: const EdgeInsets.all(20),
        desktopPadding: const EdgeInsets.all(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText(
                  text: 'Product Catalog',
                  style: TextStyle(
                    color: EnhancedAppTheme.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Consumer<ProductProvider>(
                  builder: (context, provider, child) {
                    return ResponsiveText(
                      text: '${provider.filteredProducts.length} products found',
                      style: TextStyle(
                        color: EnhancedAppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          if (_isComparing)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: EnhancedAppTheme.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.compare,
                    color: EnhancedAppTheme.primaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  ResponsiveText(
                    text: '${_selectedProducts.length}',
                    style: TextStyle(
                      color: EnhancedAppTheme.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: ResponsiveLayout.responsivePadding(
        context: context,
        mobilePadding: const EdgeInsets.symmetric(horizontal: 16),
        tabletPadding: const EdgeInsets.symmetric(horizontal: 20),
        desktopPadding: const EdgeInsets.symmetric(horizontal: 24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: EnhancedUIComponents.glassmorphicTextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  hintText: 'Search products...',
                  prefixIcon: Icons.search,
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: EnhancedAppTheme.textSecondary),
                          onPressed: () {
                            _searchController.clear();
                            _searchFocusNode.unfocus();
                          },
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              EnhancedUIComponents.glassmorphicButton(
                onPressed: _showFilterSheet,
                child: Icon(
                  Icons.tune,
                  color: _isFiltering ? EnhancedAppTheme.primaryColor : EnhancedAppTheme.textPrimary,
                ),
                backgroundColor: _isFiltering
                    ? EnhancedAppTheme.primaryColor.withOpacity(0.2)
                    : EnhancedAppTheme.surfaceColor,
              ),
              const SizedBox(width: 8),
              EnhancedUIComponents.glassmorphicButton(
                onPressed: _showSortOptions,
                child: Icon(
                  Icons.sort,
                  color: EnhancedAppTheme.textPrimary,
                ),
                backgroundColor: EnhancedAppTheme.surfaceColor,
              ),
            ],
          ),
          if (_isSearching || _isFiltering)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: EnhancedAppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    color: EnhancedAppTheme.primaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ResponsiveText(
                      text: _getActiveFiltersDescription(),
                      style: TextStyle(
                        color: EnhancedAppTheme.primaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  EnhancedUIComponents.glassmorphicButton(
                    onPressed: _clearFilters,
                    child: ResponsiveText(
                      text: 'Clear',
                      style: TextStyle(
                        color: EnhancedAppTheme.primaryColor,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 60,
      padding: ResponsiveLayout.responsivePadding(
        context: context,
        mobilePadding: const EdgeInsets.symmetric(horizontal: 16),
        tabletPadding: const EdgeInsets.symmetric(horizontal: 20),
        desktopPadding: const EdgeInsets.symmetric(horizontal: 24),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: EnhancedAppTheme.primaryColor,
        unselectedLabelColor: EnhancedAppTheme.textSecondary,
        indicatorColor: EnhancedAppTheme.primaryColor,
        indicatorWeight: 3,
        labelStyle: TextStyle(
          fontSize: ResponsiveLayout.responsiveFontSize(
            context: context,
            mobileSize: 14,
            tabletSize: 15,
            desktopSize: 16,
          ),
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: ResponsiveLayout.responsiveFontSize(
            context: context,
            mobileSize: 14,
            tabletSize: 15,
            desktopSize: 16,
          ),
          fontWeight: FontWeight.normal,
        ),
        tabs: _categories.map((category) {
          return Tab(
            text: category,
            icon: Icon(_getCategoryIcon(category)),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductGrid() {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildLoadingState();
        }

        if (provider.error != null) {
          return _buildErrorState(provider.error!);
        }

        if (provider.filteredProducts.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: _refreshProducts,
          color: EnhancedAppTheme.primaryColor,
          child: ResponsiveGrid(
            children: provider.filteredProducts.map((product) {
              return _buildProductCard(product);
            }).toList(),
            mobileColumns: _crossAxisCount,
            tabletColumns: _crossAxisCount + 1,
            desktopColumns: _crossAxisCount + 2,
            largeDesktopColumns: _crossAxisCount + 3,
            spacing: ResponsiveLayout.responsiveValue<double>(
              context: context,
              mobile: 12.0,
              tablet: 16.0,
              desktop: 20.0,
              largeDesktop: 24.0,
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductCard(Product product) {
    final isSelected = _selectedProducts.contains(product);
    
    return EnhancedUIComponents.glassmorphicCard(
      onTap: () => _showProductDetail(product),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        EnhancedAppTheme.primaryColor.withOpacity(0.1),
                        EnhancedAppTheme.secondaryColor.withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: product.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            product.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.medication,
                                color: EnhancedAppTheme.textSecondary,
                                size: 40,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.medication,
                          color: EnhancedAppTheme.textSecondary,
                          size: 40,
                        ),
                ),
                if (product.featured)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ResponsiveText(
                        text: 'Featured',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (product.stockQuantity <= 0)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: ResponsiveText(
                          text: 'Out of Stock',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ResponsiveText(
            text: product.name,
            style: TextStyle(
              color: EnhancedAppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          ResponsiveText(
            text: product.category,
            style: TextStyle(
              color: EnhancedAppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: ResponsiveText(
                  text: 'NPR ${NumberFormat('#,##0.00').format(product.price)}',
                  style: TextStyle(
                    color: EnhancedAppTheme.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (product.stockQuantity > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: product.stockQuantity <= 20
                        ? Colors.orange.withOpacity(0.2)
                        : Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ResponsiveText(
                    text: '${product.stockQuantity}',
                    style: TextStyle(
                      color: product.stockQuantity <= 20 ? Colors.orange : Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: EnhancedUIComponents.glassmorphicButton(
                  onPressed: () => _toggleProductSelection(product),
                  child: Icon(
                    isSelected ? Icons.check_circle : Icons.add_circle_outline,
                    color: isSelected ? EnhancedAppTheme.primaryColor : EnhancedAppTheme.textSecondary,
                    size: 20,
                  ),
                  backgroundColor: isSelected
                      ? EnhancedAppTheme.primaryColor.withOpacity(0.2)
                      : EnhancedAppTheme.surfaceColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: EnhancedUIComponents.glassmorphicButton(
                  onPressed: () => _addToCart(product),
                  child: Icon(
                    Icons.shopping_cart,
                    color: EnhancedAppTheme.primaryColor,
                    size: 20,
                  ),
                  backgroundColor: EnhancedAppTheme.primaryColor.withOpacity(0.2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return SkeletonLoading.grid(
      crossAxisCount: _crossAxisCount,
      childAspectRatio: 0.7,
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LottieAnimations.error(size: 100),
          const SizedBox(height: 16),
          ResponsiveText(
            text: 'Error loading products',
            style: TextStyle(
              color: EnhancedAppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ResponsiveText(
            text: error,
            style: TextStyle(
              color: EnhancedAppTheme.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          EnhancedUIComponents.glassmorphicButton(
            onPressed: _refreshProducts,
            child: ResponsiveText(
              text: 'Retry',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: EnhancedAppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LottieAnimations.search(size: 100),
          const SizedBox(height: 16),
          ResponsiveText(
            text: 'No products found',
            style: TextStyle(
              color: EnhancedAppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ResponsiveText(
            text: 'Try adjusting your search or filters',
            style: TextStyle(
              color: EnhancedAppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          EnhancedUIComponents.glassmorphicButton(
            onPressed: _clearFilters,
            child: ResponsiveText(
              text: 'Clear Filters',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: EnhancedAppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isComparing && _selectedProducts.isNotEmpty)
          FloatingActionButton.extended(
            onPressed: _showComparisonSheet,
            backgroundColor: EnhancedAppTheme.primaryColor,
            icon: Icon(Icons.compare, color: Colors.white),
            label: ResponsiveText(
              text: 'Compare (${_selectedProducts.length})',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        const SizedBox(height: 8),
        FloatingActionButton(
          onPressed: _refreshProducts,
          backgroundColor: EnhancedAppTheme.surfaceColor,
          child: Icon(Icons.refresh, color: EnhancedAppTheme.textPrimary),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EnhancedAppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ResponsiveText(
              text: '${_selectedProducts.length} selected',
              style: TextStyle(
                color: EnhancedAppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          if (_selectedProducts.isNotEmpty)
            Row(
              children: [
                EnhancedUIComponents.glassmorphicButton(
                  onPressed: _clearSelection,
                  child: ResponsiveText(
                    text: 'Clear',
                    style: TextStyle(
                      color: EnhancedAppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  backgroundColor: EnhancedAppTheme.surfaceColor,
                ),
                const SizedBox(width: 8),
                EnhancedUIComponents.glassmorphicButton(
                  onPressed: _bulkAddToCart,
                  child: ResponsiveText(
                    text: 'Add to Cart',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: EnhancedAppTheme.primaryColor,
                ),
              ],
            ),
        ],
      ),
    );
  }

  // Helper methods
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Medicines':
        return Icons.medication;
      case 'Medical Supplies':
        return Icons.healing;
      case 'Equipment':
        return Icons.medical_services;
      case 'Supplements':
        return Icons.vitamins;
      default:
        return Icons.category;
    }
  }

  String _getActiveFiltersDescription() {
    final filters = <String>[];
    if (_searchQuery.isNotEmpty) filters.add('Search: $_searchQuery');
    if (_selectedCategoryIndex > 0) filters.add('Category: ${_categories[_selectedCategoryIndex]}');
    if (_filters['priceRange'] != null) filters.add('Price range');
    if (_filters['inStock'] == true) filters.add('In stock');
    if (_filters['featured'] == true) filters.add('Featured');
    return filters.join(' • ');
  }

  // Action methods
  Future<void> _refreshProducts() async {
    HapticFeedback.lightImpact();
    await _loadData();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AdvancedFilterSheet(
        filters: _filters,
        onFiltersChanged: (filters) {
          setState(() {
            _filters = filters;
            _isFiltering = filters.isNotEmpty;
          });
          _filterProducts();
        },
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SortOptionsWidget(
        sortBy: _sortBy,
        sortAscending: _sortAscending,
        onSortChanged: (sortBy, ascending) {
          setState(() {
            _sortBy = sortBy;
            _sortAscending = ascending;
          });
          _filterProducts();
        },
      ),
    );
  }

  void _showProductDetail(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductDetailSheet(product: product),
    );
  }

  void _showComparisonSheet() {
    if (_selectedProducts.length < 2) {
      EnhancedUIComponents.showEnhancedSnackbar(
        context: context,
        message: 'Select at least 2 products to compare',
        icon: Icons.info,
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductComparisonSheet(
        products: _selectedProducts,
      ),
    );
  }

  void _toggleProductSelection(Product product) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_selectedProducts.contains(product)) {
        _selectedProducts.remove(product);
        if (_selectedProducts.isEmpty) {
          _isComparing = false;
        }
      } else {
        _selectedProducts.add(product);
        if (_selectedProducts.length >= 2) {
          _isComparing = true;
        }
      }
    });
  }

  void _addToCart(Product product) {
    HapticFeedback.mediumImpact();
    
    EnhancedUIComponents.showEnhancedSnackbar(
      context: context,
      message: '${product.name} added to cart',
      icon: Icons.check_circle,
    );
  }

  void _bulkAddToCart() {
    HapticFeedback.heavyImpact();
    
    EnhancedUIComponents.showEnhancedSnackbar(
      context: context,
      message: '${_selectedProducts.length} products added to cart',
      icon: Icons.check_circle,
    );
    _clearSelection();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _filters = {};
      _isFiltering = false;
      _selectedCategoryIndex = 0;
      _tabController.animateTo(0);
    });
    _filterProducts();
  }

  void _clearSelection() {
    setState(() {
      _selectedProducts.clear();
      _isComparing = false;
    });
  }
}
}

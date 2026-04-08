import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import '../providers/enhanced_product_catalog_provider.dart';
import '../widgets/enhanced_product_grid.dart';
import '../widgets/smart_search_bar.dart';
import '../widgets/advanced_filter_panel.dart';
import '../widgets/enhanced_product_card.dart';
import '../widgets/product_detail_sheet.dart';
import '../widgets/category_chips.dart';
import '../../domain/models/product_entity.dart';
import '../../domain/models/product_category.dart';
import '../../domain/entities/product_filter_entity.dart';
import '../../../shared/theme/enhanced_app_theme.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/pagination_loader.dart';
import '../../../shared/widgets/responsive/responsive_layout.dart';
import '../../../shared/widgets/responsive/responsive_grid.dart';
import '../../../shared/widgets/responsive/responsive_container.dart';
import '../../../shared/widgets/responsive/responsive_card.dart';

/// Enhanced Product Catalog Screen
/// Comprehensive product browsing with advanced filtering, searching, and sorting
class EnhancedProductCatalogScreen extends StatefulWidget {
  const EnhancedProductCatalogScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedProductCatalogScreen> createState() => _EnhancedProductCatalogScreenState();
}

class _EnhancedProductCatalogScreenState extends State<EnhancedProductCatalogScreen> 
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _fabController;
  late AnimationController _filterPanelController;
  late Animation<double> _fabScaleAnimation;
  late Animation<Offset> _filterPanelAnimation;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isFabVisible = true;
  bool _isFilterPanelOpen = false;
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _filterPanelController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fabScaleAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeOutBack,
    );
    
    _filterPanelAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _filterPanelController,
      curve: Curves.easeInOut,
    ));
    
    _fabController.forward();
    _setupScrollListener();
    _initializeData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fabController.dispose();
    _filterPanelController.dispose();
    super.dispose();
  }

  void _initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EnhancedProductCatalogProvider>().initialize();
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (_isFabVisible) {
          setState(() => _isFabVisible = false);
          _fabController.reverse();
        }
      } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
        if (!_isFabVisible) {
          setState(() => _isFabVisible = true);
          _fabController.forward();
        }
      }

      // Pagination check
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        context.read<EnhancedProductCatalogProvider>().loadMoreProducts();
      }
    });
  }

  void _onProductTap(Product product) {
    context.read<EnhancedProductCatalogProvider>().selectProduct(product);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductDetailSheet(product: product),
    );
  }

  void _onProductFavorite(Product product) {
    context.read<EnhancedProductCatalogProvider>().toggleFavorite(product);
  }

  void _onProductCompare(Product product) {
    context.read<EnhancedProductCatalogProvider>().toggleComparison(product);
  }

  void _onProductQuickView(Product product) {
    _onProductTap(product);
  }

  void _onSearch(String query) {
    context.read<EnhancedProductCatalogProvider>().searchProducts(query);
  }

  void _onSuggestionSelected(String suggestion) {
    context.read<EnhancedProductCatalogProvider>().searchProducts(suggestion);
  }

  void _toggleFilterPanel() {
    setState(() {
      _isFilterPanelOpen = !_isFilterPanelOpen;
    });
    
    if (_isFilterPanelOpen) {
      _filterPanelController.forward();
    } else {
      _filterPanelController.reverse();
    }
  }

  void _onFiltersChanged(ProductFilterEntity filters) {
    context.read<EnhancedProductCatalogProvider>().updateFilters(filters);
    _toggleFilterPanel();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<EnhancedProductCatalogProvider>();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Main Content
          ResponsiveLayout(
            mobile: _buildMobileLayout(theme, provider),
            tablet: _buildTabletLayout(theme, provider),
            desktop: _buildDesktopLayout(theme, provider),
          ),
          
          // Filter Panel Overlay
          if (_isFilterPanelOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleFilterPanel,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
          
          // Filter Panel
          if (_isFilterPanelOpen)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: SlideTransition(
                position: _filterPanelAnimation,
                child: AdvancedFilterPanel(
                  initialFilters: provider.filter,
                  onFiltersChanged: _onFiltersChanged,
                  onClose: _toggleFilterPanel,
                  isExpanded: true,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _buildFAB(theme, provider),
    );
  }

  Widget _buildMobileLayout(ThemeData theme, EnhancedProductCatalogProvider provider) {
    return SafeArea(
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: SmartSearchBar(
              onSearch: _onSearch,
              onSuggestionSelected: _onSuggestionSelected,
              enableVoiceSearch: true,
              enableBarcodeSearch: true,
              placeholder: 'Search medicines, brands, categories...',
            ),
          ),

          // Category Quick Switcher
          if (provider.categories.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CategoryChips(
                categories: provider.categories,
                selectedCategory: provider.selectedCategory?.name,
                onCategorySelected: (category) => provider.selectCategory(category ?? 'All'),
              ),
            ),

          // Results Summary and Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildResultsSummary(provider, theme),
          ),

          // Main Product View
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => provider.refresh(),
              child: _buildProductGrid(provider, theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(ThemeData theme, EnhancedProductCatalogProvider provider) {
    return SafeArea(
      child: Row(
        children: [
          // Sidebar
          SizedBox(
            width: 320,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  SmartSearchBar(
                    onSearch: _onSearch,
                    onSuggestionSelected: _onSuggestionSelected,
                    enableVoiceSearch: true,
                    enableBarcodeSearch: true,
                    placeholder: 'Search products...',
                    isCompact: true,
                  ),
                  const SizedBox(height: 16),
                  
                  // Category Quick Switcher
                  if (provider.categories.isNotEmpty) ...[
                    Text(
                      'Categories',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    CategoryChips(
                      categories: provider.categories,
                      selectedCategory: provider.selectedCategory?.name,
                      onCategorySelected: (category) => provider.selectCategory(category ?? 'All'),
                      isVertical: true,
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Filter Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _toggleFilterPanel,
                      icon: const Icon(Icons.tune),
                      label: const Text('Advanced Filters'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Results Summary
                  _buildResultsSummary(provider, theme),
                ],
              ),
            ),
          ),
          
          // Main Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Top Actions Bar
                  _buildTopActionsBar(provider, theme),
                  const SizedBox(height: 16),
                  
                  // Product Grid
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => provider.refresh(),
                      child: _buildProductGrid(provider, theme),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(ThemeData theme, EnhancedProductCatalogProvider provider) {
    return SafeArea(
      child: Row(
        children: [
          // Sidebar
          SizedBox(
            width: 380,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  SmartSearchBar(
                    onSearch: _onSearch,
                    onSuggestionSelected: _onSuggestionSelected,
                    enableVoiceSearch: true,
                    enableBarcodeSearch: true,
                    placeholder: 'Search medicines, brands, categories...',
                    isCompact: true,
                  ),
                  const SizedBox(height: 24),
                  
                  // Category Quick Switcher
                  if (provider.categories.isNotEmpty) ...[
                    Text(
                      'Categories',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    CategoryChips(
                      categories: provider.categories,
                      selectedCategory: provider.selectedCategory?.name,
                      onCategorySelected: (category) => provider.selectCategory(category ?? 'All'),
                      isVertical: true,
                    ),
                    const SizedBox(height: 32),
                  ],
                  
                  // Filter Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _toggleFilterPanel,
                      icon: const Icon(Icons.tune),
                      label: const Text('Advanced Filters'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Statistics Cards
                  _buildStatisticsCards(provider, theme),
                  
                  const Spacer(),
                  
                  // Results Summary
                  _buildResultsSummary(provider, theme),
                ],
              ),
            ),
          ),
          
          // Main Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Top Actions Bar
                  _buildTopActionsBar(provider, theme),
                  const SizedBox(height: 24),
                  
                  // Product Grid
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => provider.refresh(),
                      child: _buildProductGrid(provider, theme),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopActionsBar(EnhancedProductCatalogProvider provider, ThemeData theme) {
    return Row(
      children: [
        // View Mode Toggle
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              _buildViewModeButton(
                icon: Icons.grid_view,
                isSelected: provider.viewMode == ViewMode.grid,
                onTap: () => provider.setViewMode(ViewMode.grid),
              ),
              _buildViewModeButton(
                icon: Icons.list,
                isSelected: provider.viewMode == ViewMode.list,
                onTap: () => provider.setViewMode(ViewMode.list),
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Sort Dropdown
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: provider.filter.sortBy ?? 'name',
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'name', child: Text('Name (A-Z)')),
                  DropdownMenuItem(value: 'name_desc', child: Text('Name (Z-A)')),
                  DropdownMenuItem(value: 'price', child: Text('Price (Low to High)')),
                  DropdownMenuItem(value: 'price_desc', child: Text('Price (High to Low)')),
                  DropdownMenuItem(value: 'stock', child: Text('Stock (Low to High)')),
                  DropdownMenuItem(value: 'stock_desc', child: Text('Stock (High to Low)')),
                  DropdownMenuItem(value: 'popularity', child: Text('Most Popular')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    provider.updateFilters(provider.filter.copyWith(sortBy: value));
                  }
                },
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Compare Button
        if (provider.comparisonProducts.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {
                // Navigate to comparison screen
              },
              icon: Badge(
                label: Text('${provider.comparisonProducts.length}'),
                child: const Icon(Icons.compare, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildViewModeButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : theme.iconTheme.color,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildProductGrid(EnhancedProductCatalogProvider provider, ThemeData theme) {
    if (provider.products.isEmpty && !provider.isLoading) {
      return EmptyStateWidget(
        icon: Icons.inventory_2_outlined,
        title: 'No Products Found',
        subtitle: provider.hasActiveFilters 
            ? 'Try adjusting your filters or search criteria'
            : 'No products available at the moment',
        actionText: provider.hasActiveFilters ? 'Clear Filters' : null,
        onAction: provider.hasActiveFilters ? provider.clearFilters : null,
      );
    }

    return EnhancedProductGrid(
      products: provider.products,
      viewMode: provider.viewMode,
      isLoading: provider.isLoadingMore,
      hasMore: provider.hasMore,
      onLoadMore: provider.loadMoreProducts,
      onProductTap: _onProductTap,
      onProductFavorite: _onProductFavorite,
      onProductCompare: _onProductCompare,
      onProductQuickView: _onProductQuickView,
    );
  }

  Widget _buildResultsSummary(EnhancedProductCatalogProvider provider, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${provider.filteredProductsCount}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'products found',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
          if (provider.hasActiveFilters) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (provider.searchQuery.isNotEmpty)
                  _buildFilterChip(
                    label: 'Search: ${provider.searchQuery}',
                    onRemove: () {
                      provider.searchProducts('');
                    },
                  ),
                if (provider.selectedCategory != null)
                  _buildFilterChip(
                    label: 'Category: ${provider.selectedCategory!.name}',
                    onRemove: () {
                      provider.selectCategory('All');
                    },
                  ),
                ...provider.filter.categories.map((category) => _buildFilterChip(
                  label: category,
                  onRemove: () {
                    final newCategories = List<String>.from(provider.filter.categories)
                      ..remove(category);
                    provider.updateFilters(provider.filter.copyWith(categories: newCategories));
                  },
                )),
              ],
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: provider.clearFilters,
              child: const Text('Clear All Filters'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onRemove,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 14,
              color: theme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(EnhancedProductCatalogProvider provider, ThemeData theme) {
    final stats = provider.getProductStatistics();
    
    return Column(
      children: [
        _buildStatCard(
          title: 'Total Products',
          value: '${stats['totalProducts']}',
          icon: Icons.inventory,
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          title: 'In Stock',
          value: '${stats['inStockProducts']}',
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          title: 'On Sale',
          value: '${stats['onSaleProducts']}',
          icon: Icons.local_offer,
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(ThemeData theme, EnhancedProductCatalogProvider provider) {
    if (!_isFabVisible) return const SizedBox.shrink();
    
    return ScaleTransition(
      scale: _fabScaleAnimation,
      child: FloatingActionButton.extended(
        onPressed: _toggleFilterPanel,
        icon: const Icon(Icons.tune),
        label: const Text('Filters'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }
}

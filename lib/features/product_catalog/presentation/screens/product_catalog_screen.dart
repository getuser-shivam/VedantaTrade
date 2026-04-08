import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import '../providers/product_catalog_provider.dart';
import '../widgets/enhanced_product_card.dart';
import '../widgets/enhanced_search_filter_bar.dart';
import '../widgets/product_detail_sheet.dart';
import '../widgets/category_chips.dart';
import '../../data/models/product_model.dart';
import '../../../domain/entities/product_filter_entity.dart';
import '../../../shared/theme/enhanced_app_theme.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/pagination_loader.dart';
import '../../../shared/widgets/responsive/responsive_layout.dart';
import '../../../shared/widgets/responsive/responsive_grid.dart';
import '../../../shared/widgets/responsive/responsive_container.dart';
import '../../../shared/widgets/responsive/responsive_card.dart';

/// Product Catalog Screen
/// A high-performance, robust product catalog interface for VedantaTrade.
class ProductCatalogScreen extends StatefulWidget {
  const ProductCatalogScreen({Key? key}) : super(key: key);

  @override
  State<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _fabController;
  late Animation<double> _fabScaleAnimation;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabScaleAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeOutBack,
    );
    _fabController.forward();

    _setupScrollListener();
    _initializeData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  void _initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductCatalogProvider>().initialize();
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
        context.read<ProductCatalogProvider>().loadMoreProducts();
      }
    });
  }

  void _onProductTap(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductDetailSheet(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ProductCatalogProvider>();

    return ResponsiveLayout(
      mobile: _buildMobileLayout(theme, provider),
      tablet: _buildTabletLayout(theme, provider),
      desktop: _buildDesktopLayout(theme, provider),
    );
  }

  Widget _buildMobileLayout(ThemeData theme, ProductCatalogProvider provider) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme, provider),
      body: LoadingOverlay(
        isLoading: provider.isLoading && provider.products.isEmpty,
        child: Column(
          children: [
            // Search & Filter Bar
            EnhancedSearchFilterBar(
              initialFilters: provider.filter,
              onFiltersChanged: (filters) => provider.updateFilters(filters),
              onSearch: (query) => provider.updateFilters(provider.filter.copyWith(searchQuery: query)),
            ),

            // Category Quick Switcher
            if (provider.categories.isNotEmpty)
              CategoryChips(
                categories: provider.categories,
                selectedCategory: provider.filter.categories.isNotEmpty ? provider.filter.categories.first : null,
                onCategorySelected: (category) => provider.selectCategory(category ?? 'All'),
              ),

            // Results Summary
            _buildResultsSummary(provider, theme),

            // Main Product View
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => provider.refresh(),
                child: _buildMainContent(provider, theme),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(theme, provider),
    );
  }

  Widget _buildTabletLayout(ThemeData theme, ProductCatalogProvider provider) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme, provider),
      body: LoadingOverlay(
        isLoading: provider.isLoading && provider.products.isEmpty,
        child: Row(
          children: [
            // Sidebar for filters and categories
            SizedBox(
              width: 300,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar
                    EnhancedSearchFilterBar(
                      initialFilters: provider.filter,
                      onFiltersChanged: (filters) => provider.updateFilters(filters),
                      onSearch: (query) => provider.updateFilters(provider.filter.copyWith(searchQuery: query)),
                      isCompact: true,
                    ),
                    const SizedBox(height: 16),
                    
                    // Category Quick Switcher
                    if (provider.categories.isNotEmpty) ...[
                      Text(
                        'Categories',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      CategoryChips(
                        categories: provider.categories,
                        selectedCategory: provider.filter.categories.isNotEmpty ? provider.filter.categories.first : null,
                        onCategorySelected: (category) => provider.selectCategory(category ?? 'All'),
                        isVertical: true,
                      ),
                    ],
                    
                    const Spacer(),
                    
                    // Results Summary
                    _buildResultsSummary(provider, theme),
                  ],
                ),
              ),
            ),
            
            // Main Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => provider.refresh(),
                child: _buildMainContent(provider, theme),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(theme, provider),
    );
  }

  Widget _buildDesktopLayout(ThemeData theme, ProductCatalogProvider provider) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme, provider),
      body: LoadingOverlay(
        isLoading: provider.isLoading && provider.products.isEmpty,
        child: Row(
          children: [
            // Sidebar for filters and categories
            SizedBox(
              width: 350,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar
                    EnhancedSearchFilterBar(
                      initialFilters: provider.filter,
                      onFiltersChanged: (filters) => provider.updateFilters(filters),
                      onSearch: (query) => provider.updateFilters(provider.filter.copyWith(searchQuery: query)),
                      isCompact: true,
                    ),
                    const SizedBox(height: 24),
                    
                    // Category Quick Switcher
                    if (provider.categories.isNotEmpty) ...[
                      Text(
                        'Categories',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      CategoryChips(
                        categories: provider.categories,
                        selectedCategory: provider.filter.categories.isNotEmpty ? provider.filter.categories.first : null,
                        onCategorySelected: (category) => provider.selectCategory(category ?? 'All'),
                        isVertical: true,
                      ),
                    ],
                    
                    const Spacer(),
                    
                    // Results Summary
                    _buildResultsSummary(provider, theme),
                    
                    const SizedBox(height: 16),
                    
                    // View Mode Toggle
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => provider.setViewMode(ViewMode.grid),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: provider.viewMode == ViewMode.grid ? theme.primaryColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.grid_view,
                                  color: provider.viewMode == ViewMode.grid ? Colors.white : theme.iconTheme.color,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => provider.setViewMode(ViewMode.list),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: provider.viewMode == ViewMode.list ? theme.primaryColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.view_list,
                                  color: provider.viewMode == ViewMode.list ? Colors.white : theme.iconTheme.color,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Main Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => provider.refresh(),
                child: _buildMainContent(provider, theme),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(theme, provider),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, ProductCatalogProvider provider) {
    return AppBar(
      title: const Text('VedantaTrade Catalog', style: TextStyle(fontWeight: FontWeight.bold)),
      actions: [
        IconButton(
          icon: Icon(provider.viewMode == ViewMode.grid ? Icons.view_list : Icons.grid_view),
          onPressed: () => provider.setViewMode(
            provider.viewMode == ViewMode.grid ? ViewMode.list : ViewMode.grid,
          ),
          tooltip: 'Toggle View Mode',
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => provider.refresh(),
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildResultsSummary(ProductCatalogProvider provider, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: theme.cardColor.withOpacity(0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${provider.products.length} Products Found',
            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (provider.hasActiveFilters)
            GestureDetector(
              onTap: () => provider.clearFilters(),
              child: Text(
                'Clear Filters',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMainContent(ProductCatalogProvider provider, ThemeData theme) {
    if (provider.hasError) {
      return ErrorStateWidget(
        message: provider.errorMessage ?? 'Failed to load products',
        onRetry: () => provider.refresh(),
      );
    }

    if (provider.products.isEmpty && !provider.isLoading) {
      return const EmptyStateWidget(
        message: 'No products found. Try adjusting your filters.',
        icon: Icons.search_off,
      );
    }

    return provider.viewMode == ViewMode.grid
        ? _buildGrid(provider, theme)
        : _buildList(provider, theme);
  }

  Widget _buildGrid(ProductCatalogProvider provider, ThemeData theme) {
    return ResponsiveGrid(
      mobileColumns: 2,
      tabletColumns: 3,
      desktopColumns: 4,
      largeDesktopColumns: 5,
      spacing: 16,
      runSpacing: 16,
      padding: const EdgeInsets.all(16),
      children: provider.products.map((product) => EnhancedProductCard(
        product: product,
        onTap: () => _onProductTap(product),
        onFavorite: () => provider.toggleFavorite(product),
        onCompare: () => provider.toggleComparison(product),
      )).toList() + [
        if (provider.hasMore) const Center(child: PaginationLoader())
      ],
    );
  }

  Widget _buildList(ProductCatalogProvider provider, ThemeData theme) {
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: provider.products.length + (provider.hasMore ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == provider.products.length) {
          return const PaginationLoader();
        }
        final product = provider.products[index];
        return ProductListTile(
          product: product,
          onTap: () => _onProductTap(product),
        );
      },
    );
  }

  Widget _buildFAB(ThemeData theme, ProductCatalogProvider provider) {
    return ScaleTransition(
      scale: _fabScaleAnimation,
      child: FloatingActionButton.extended(
        onPressed: () {
          // Open comparison view or cart
        },
        label: Text('Saved (${provider.favoriteProductIds.length})'),
        icon: const Icon(Icons.favorite),
        backgroundColor: theme.primaryColor,
      ),
    );
  }
}

class ProductListTile extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductListTile({
    Key? key,
    required this.product,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ProductCatalogProvider>();
    final isFavorite = provider.isFavorite(product.id);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: theme.scaffoldBackgroundColor,
                image: DecorationImage(
                  image: NetworkImage(product.imageUrl.isNotEmpty ? product.imageUrl : 'https://via.placeholder.com/150'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    product.manufacturer,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        product.formattedPrice,
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (product.isOnSale) ...[
                        const SizedBox(width: 8),
                        Text(
                          product.formattedOriginalPrice,
                          style: theme.textTheme.bodySmall?.copyWith(
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            
            // Actions
            Column(
              children: [
                IconButton(
                  icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                  color: isFavorite ? Colors.red : theme.hintColor,
                  onPressed: () => provider.toggleFavorite(product),
                ),
                Text(
                  product.stockStatus,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: product.stockQuantity > 0 ? Colors.green : Colors.red,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_catalog_provider.dart';
import '../widgets/enhanced_product_card.dart';
import '../widgets/enhanced_search_filter_bar.dart';
import '../widgets/product_detail_bottom_sheet.dart';
import '../widgets/category_chips.dart';
import '../../../domain/entities/product_filter_entity.dart';
import '../../../shared/theme/enhanced_app_theme.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/pagination_loader.dart';

/// Enhanced Product Catalog Screen
/// Comprehensive product catalog with advanced filtering, sorting, and searching
class EnhancedProductCatalogScreen extends StatefulWidget {
  const EnhancedProductCatalogScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedProductCatalogScreen> createState() => _EnhancedProductCatalogScreenState();
}

class _EnhancedProductCatalogScreenState extends State<EnhancedProductCatalogScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  late AnimationController _fabController;
  late AnimationController _searchBarController;
  late Animation<double> _fabAnimation;
  late Animation<Offset> _searchBarAnimation;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSearching = false;
  bool _showFab = true;
  ProductFilterEntity _currentFilters = const ProductFilterEntity();

  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 4, vsync: this);
    _scrollController = ScrollController();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _searchBarController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fabAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeInOut,
    ));

    _searchBarAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -1),
    ).animate(CurvedAnimation(
      parent: _searchBarController,
      curve: Curves.easeInOut,
    ));

    _initializeData();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _fabController.dispose();
    _searchBarController.dispose();
    super.dispose();
  }

  void _initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductCatalogProvider>().initialize();
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final isScrollingDown = _scrollController.position.userScrollDirection == ScrollDirection.reverse;
      final shouldHideFab = isScrollingDown && _scrollController.offset > 100;
      
      if (shouldHideFab != !_showFab) {
        setState(() {
          _showFab = !shouldHideFab;
        });
        
        if (_showFab) {
          _fabController.forward();
        } else {
          _fabController.reverse();
        }
      }
    });
  }

  void _onSearch(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });
  }

  void _onFiltersChanged(ProductFilterEntity filters) {
    setState(() {
      _currentFilters = filters;
    });
  }

  void _onProductTap(ProductEntity product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductDetailBottomSheet(product: product),
    );
  }

  void _onProductFavorite(ProductEntity product) {
    context.read<ProductCatalogProvider>().toggleFavorite(product);
  }

  void _onProductCompare(ProductEntity product) {
    context.read<ProductCatalogProvider>().toggleComparison(product);
  }

  void _onProductQuickView(ProductEntity product) {
    _onProductTap(product);
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _openFilterDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme),
      body: Consumer<ProductCatalogProvider>(
        builder: (context, provider, child) {
          return LoadingOverlay(
            isLoading: provider.isLoading && provider.products.isEmpty,
            child: RefreshIndicator(
              onRefresh: () => provider.refreshProducts(),
              child: Column(
                children: [
                  // Search and Filter Bar
                  SlideTransition(
                    position: _searchBarAnimation,
                    child: EnhancedSearchFilterBar(
                      onSearch: _onSearch,
                      onFiltersChanged: _onFiltersChanged,
                      initialFilters: _currentFilters,
                      showAdvancedFilters: true,
                      enableVoiceSearch: true,
                      enableBarcodeSearch: true,
                      placeholder: 'Search medicines, brands, categories...',
                    ),
                  ),
                  
                  // Category Chips (if not searching)
                  if (!_isSearching)
                    CategoryChips(
                      categories: provider.categories,
                      selectedCategory: provider.selectedCategory?.name,
                      onCategorySelected: (category) {
                        provider.selectCategory(category);
                      },
                    ),
                  
                  // Products List/Grid
                  Expanded(
                    child: _buildProductsContent(provider, theme),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(theme),
      endDrawer: _buildFilterDrawer(theme),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Catalog',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_currentFilters.hasActiveFilters)
            Text(
              '${_currentFilters.activeFilterCount} filter${_currentFilters.activeFilterCount == 1 ? '' : 's'} applied',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.primaryColor,
              ),
            ),
        ],
      ),
      actions: [
        // Search Toggle
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
            });
            
            if (_isSearching) {
              _searchBarController.forward();
            } else {
              _searchBarController.reverse();
            }
          },
        ),
        
        // Filter Toggle
        IconButton(
          icon: Badge(
            label: _currentFilters.hasActiveFilters 
                ? Text('${_currentFilters.activeFilterCount}')
                : null,
            child: const Icon(Icons.tune),
          ),
          onPressed: _openFilterDrawer,
        ),
        
        // View Mode Toggle
        PopupMenuButton<ViewMode>(
          icon: const Icon(Icons.view_list),
          onSelected: (mode) {
            context.read<ProductCatalogProvider>().setViewMode(mode);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: ViewMode.grid,
              child: Row(
                children: [
                  Icon(Icons.grid_view),
                  SizedBox(width: 8),
                  Text('Grid View'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: ViewMode.list,
              child: Row(
                children: [
                  Icon(Icons.list),
                  SizedBox(width: 8),
                  Text('List View'),
                ],
              ),
            ),
          ],
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'All Products'),
          Tab(text: 'Featured'),
          Tab(text: 'On Sale'),
          Tab(text: 'New Arrivals'),
        ],
        onTap: (index) {
          context.read<ProductCatalogProvider>().setTab(index);
        },
      ),
    );
  }

  Widget _buildProductsContent(ProductCatalogProvider provider, ThemeData theme) {
    if (provider.hasError) {
      return CustomErrorWidget(
        message: provider.errorMessage ?? 'An error occurred',
        onRetry: () => provider.refreshProducts(),
      );
    }

    if (provider.products.isEmpty && !provider.isLoading) {
      return EmptyStateWidget(
        icon: Icons.inventory_2_outlined,
        title: 'No products found',
        subtitle: 'Try adjusting your filters or search terms',
        action: _currentFilters.hasActiveFilters
            ? ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentFilters = const ProductFilterEntity();
                  });
                  provider.clearFilters();
                },
                child: const Text('Clear Filters'),
              )
            : null,
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        // All Products Tab
        _buildProductGrid(provider, theme),
        
        // Featured Products Tab
        _buildFeaturedProducts(provider, theme),
        
        // On Sale Products Tab
        _buildOnSaleProducts(provider, theme),
        
        // New Arrivals Tab
        _buildNewArrivals(provider, theme),
      ],
    );
  }

  Widget _buildProductGrid(ProductCatalogProvider provider, ThemeData theme) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 200 &&
            provider.hasMore &&
            !provider.isLoadingMore) {
          provider.loadMoreProducts();
        }
        return false;
      },
      child: provider.viewMode == ViewMode.grid
          ? ProductCardGrid(
              products: provider.products,
              onProductTap: _onProductTap,
              onProductFavorite: _onProductFavorite,
              onProductCompare: _onProductCompare,
              onProductQuickView: _onProductQuickView,
              isLoading: provider.isLoading && provider.products.isEmpty,
            )
          : _buildProductList(provider, theme),
    );
  }

  Widget _buildProductList(ProductCatalogProvider provider, ThemeData theme) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      itemCount: provider.products.length + (provider.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == provider.products.length && provider.hasMore) {
          return const PaginationLoader();
        }

        final product = provider.products[index];
        return ProductListTile(
          product: product,
          onTap: () => _onProductTap(product),
          onFavorite: () => _onProductFavorite(product),
          onCompare: () => _onProductCompare(product),
          onQuickView: () => _onProductQuickView(product),
        );
      },
    );
  }

  Widget _buildFeaturedProducts(ProductCatalogProvider provider, ThemeData theme) {
    return FutureBuilder<List<ProductEntity>>(
      future: provider.getFeaturedProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return CustomErrorWidget(
            message: 'Failed to load featured products',
            onRetry: () => setState(() {}),
          );
        }

        final products = snapshot.data ?? [];
        
        if (products.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.star_outline,
            title: 'No featured products',
            subtitle: 'Check back later for featured items',
          );
        }

        return ProductCardGrid(
          products: products,
          onProductTap: _onProductTap,
          onProductFavorite: _onProductFavorite,
          onProductCompare: _onProductCompare,
          onProductQuickView: _onProductQuickView,
        );
      },
    );
  }

  Widget _buildOnSaleProducts(ProductCatalogProvider provider, ThemeData theme) {
    return FutureBuilder<List<ProductEntity>>(
      future: provider.getOnSaleProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return CustomErrorWidget(
            message: 'Failed to load products on sale',
            onRetry: () => setState(() {}),
          );
        }

        final products = snapshot.data ?? [];
        
        if (products.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.local_offer_outline,
            title: 'No products on sale',
            subtitle: 'Check back later for special offers',
          );
        }

        return ProductCardGrid(
          products: products,
          onProductTap: _onProductTap,
          onProductFavorite: _onProductFavorite,
          onProductCompare: _onProductCompare,
          onProductQuickView: _onProductQuickView,
        );
      },
    );
  }

  Widget _buildNewArrivals(ProductCatalogProvider provider, ThemeData theme) {
    return FutureBuilder<List<ProductEntity>>(
      future: provider.getNewArrivals(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return CustomErrorWidget(
            message: 'Failed to load new arrivals',
            onRetry: () => setState(() {}),
          );
        }

        final products = snapshot.data ?? [];
        
        if (products.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.new_releases_outlined,
            title: 'No new arrivals',
            subtitle: 'Check back later for new products',
          );
        }

        return ProductCardGrid(
          products: products,
          onProductTap: _onProductTap,
          onProductFavorite: _onProductFavorite,
          onProductCompare: _onProductCompare,
          onProductQuickView: _onProductQuickView,
        );
      },
    );
  }

  Widget _buildFloatingActionButton(ThemeData theme) {
    return ScaleTransition(
      scale: _fabAnimation,
      child: FloatingActionButton.extended(
        onPressed: _scrollToTop,
        icon: const Icon(Icons.keyboard_arrow_up),
        label: const Text('Scroll to Top'),
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildFilterDrawer(ThemeData theme) {
    return Drawer(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drawer Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            
            const Divider(),
            
            // Filter Options
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Categories
                    _buildFilterSection(
                      title: 'Categories',
                      child: _buildCategoryFilters(),
                    ),
                    
                    // Price Range
                    _buildFilterSection(
                      title: 'Price Range',
                      child: _buildPriceRangeFilter(),
                    ),
                    
                    // Stock Status
                    _buildFilterSection(
                      title: 'Stock Status',
                      child: _buildStockStatusFilter(),
                    ),
                    
                    // Rating
                    _buildFilterSection(
                      title: 'Rating',
                      child: _buildRatingFilter(),
                    ),
                    
                    // Sort Options
                    _buildFilterSection(
                      title: 'Sort By',
                      child: _buildSortFilter(),
                    ),
                  ],
                ),
              ),
            ),
            
            // Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        child,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCategoryFilters() {
    return Consumer<ProductCatalogProvider>(
      builder: (context, provider, child) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: provider.categories.map((category) {
            final isSelected = provider.selectedCategory?.id == category.id;
            return FilterChip(
              label: Text(category.name),
              selected: isSelected,
              onSelected: (_) {
                provider.selectCategory(isSelected ? null : category);
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildPriceRangeFilter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('NPR 0'),
            Text('NPR 10,000'),
          ],
        ),
        RangeSlider(
          values: const RangeValues(0, 10000),
          min: 0,
          max: 10000,
          divisions: 100,
          onChanged: (values) {
            // Handle price range change
          },
        ),
      ],
    );
  }

  Widget _buildStockStatusFilter() {
    return SwitchListTile(
      title: const Text('In Stock Only'),
      value: _currentFilters.inStockOnly ?? false,
      onChanged: (value) {
        setState(() {
          _currentFilters = _currentFilters.copyWith(inStockOnly: value);
        });
      },
    );
  }

  Widget _buildRatingFilter() {
    return Row(
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(Icons.star_border),
          onPressed: () {
            // Handle rating filter
          },
        );
      }),
    );
  }

  Widget _buildSortFilter() {
    return Column(
      children: [
        RadioListTile<String>(
          title: const Text('Name A-Z'),
          value: 'name_asc',
          groupValue: 'name_asc',
          onChanged: (value) {
            // Handle sort change
          },
        ),
        RadioListTile<String>(
          title: const Text('Name Z-A'),
          value: 'name_desc',
          groupValue: 'name_asc',
          onChanged: (value) {
            // Handle sort change
          },
        ),
        RadioListTile<String>(
          title: const Text('Price Low to High'),
          value: 'price_asc',
          groupValue: 'name_asc',
          onChanged: (value) {
            // Handle sort change
          },
        ),
        RadioListTile<String>(
          title: const Text('Price High to Low'),
          value: 'price_desc',
          groupValue: 'name_asc',
          onChanged: (value) {
            // Handle sort change
          },
        ),
      ],
    );
  }
}

/// Product List Tile
/// List view version of product card
class ProductListTile extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback onCompare;
  final VoidCallback onQuickView;

  const ProductListTile({
    Key? key,
    required this.product,
    required this.onTap,
    required this.onFavorite,
    required this.onCompare,
    required this.onQuickView,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12.0),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
            ),
            child: product.imageUrl.isNotEmpty
                ? Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.medication,
                        color: theme.hintColor,
                      );
                    },
                  )
                : Icon(
                    Icons.medication,
                    color: theme.hintColor,
                  ),
          ),
        ),
        title: Text(
          product.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${product.brand} • ${product.manufacturer}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              product.formulation,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  product.formattedPrice,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                if (product.isOnSale) ...[
                  const SizedBox(width: 8),
                  Text(
                    product.formattedOriginalPrice,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.favorite_border),
              onPressed: onFavorite,
            ),
            IconButton(
              icon: const Icon(Icons.compare_arrows),
              onPressed: onCompare,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

/// View Mode Enum
enum ViewMode {
  grid,
  list,
}

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import '../providers/product_catalog_provider.dart';
import '../../../shared/design_system/components/buttons/primary_button.dart';
import '../../../shared/design_system/components/cards/base_card.dart';
import '../../../shared/design_system/components/inputs/search_field.dart';
import '../../../shared/design_system/components/layout/section.dart';
import '../../../shared/design_system/components/typography/heading.dart';
import '../../../shared/design_system/components/typography/body_text.dart';
import '../../../shared/design_system/navigation/unified_navigation_bar.dart';
import '../../../shared/design_system/navigation/navigation_config.dart';
import '../../data/models/product_model.dart';
import '../../../domain/entities/product_filter_entity.dart';

/// Redesigned Product Catalog Screen
/// Modern, accessible, and responsive product catalog using new design system
class RedesignedProductCatalogScreen extends StatefulWidget {
  const RedesignedProductCatalogScreen({Key? key}) : super(key: key);

  @override
  State<RedesignedProductCatalogScreen> createState() => _RedesignedProductCatalogScreenState();
}

class _RedesignedProductCatalogScreenState extends State<RedesignedProductCatalogScreen> 
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _fabController;
  late Animation<double> _fabScaleAnimation;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isFabVisible = true;
  String _searchQuery = '';
  String _selectedCategory = 'All';

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
      builder: (context) => _buildProductDetailSheet(product),
    );
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
    // Trigger search in provider
  }

  void _onCategoryChanged(String category) {
    setState(() => _selectedCategory = category);
    // Filter products in provider
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 1200;
    final isTablet = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.colorScheme.background,
      body: Row(
        children: [
          if (isDesktop)
            UnifiedNavigationBar(
              currentIndex: 1,
              onTap: (index) => _navigateToIndex(index),
              items: NavigationConfig.getNavigationItemsForRole('RETAILER'),
              style: NavigationStyle.desktop,
            ),
          Expanded(
            child: Column(
              children: [
                if (isTablet && !isDesktop)
                  UnifiedNavigationBar(
                    currentIndex: 1,
                    onTap: (index) => _navigateToIndex(index),
                    items: NavigationConfig.getNavigationItemsForRole('RETAILER'),
                    style: NavigationStyle.tablet,
                  ),
                Expanded(
                  child: _buildContent(theme, isDesktop, isTablet),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(theme),
      bottomNavigationBar: !isDesktop && !isTablet
          ? UnifiedNavigationBar(
              currentIndex: 1,
              onTap: (index) => _navigateToIndex(index),
              items: NavigationConfig.getNavigationItemsForRole('RETAILER'),
              style: NavigationStyle.mobile,
            )
          : null,
    );
  }

  Widget _buildContent(ThemeData theme, bool isDesktop, bool isTablet) {
    return Consumer<ProductCatalogProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.products.isEmpty) {
          return _buildLoadingState(theme);
        }

        if (provider.hasError) {
          return _buildErrorState(theme, provider.error ?? 'An error occurred');
        }

        if (provider.products.isEmpty) {
          return _buildEmptyState(theme);
        }

        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              expandedHeight: isDesktop ? 120 : 160,
              floating: true,
              pinned: true,
              backgroundColor: theme.colorScheme.surface,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.only(
                  left: isDesktop ? 300 : 16,
                  bottom: 16,
                ),
                title: const Heading(
                  text: 'Product Catalog',
                  level: HeadingLevel.h4,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 300 : 16,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    _buildSearchAndFilter(theme),
                    const SizedBox(height: 16),
                    _buildCategoryChips(theme),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 300 : 16,
              ),
              sliver: _buildProductGrid(theme, isDesktop, isTablet),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: provider.isLoadingMore ? 80 : 20,
                child: provider.isLoadingMore
                    ? const Center(child: CircularProgressIndicator())
                    : null,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchAndFilter(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: SearchField(
            hint: 'Search products...',
            onSearch: _onSearchChanged,
          ),
        ),
        const SizedBox(width: 12),
        PrimaryButton(
          text: 'Filter',
          icon: const Icon(Icons.filter_list, size: 18),
          onPressed: () => _showFilterDialog(),
          size: ButtonSize.medium,
        ),
      ],
    );
  }

  Widget _buildCategoryChips(ThemeData theme) {
    final categories = ['All', 'Medicines', 'Supplements', 'Equipment', 'Other'];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) => _onCategoryChanged(category),
              selectedColor: theme.colorScheme.primaryContainer,
              checkmarkColor: theme.colorScheme.onPrimaryContainer,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductGrid(ThemeData theme, bool isDesktop, bool isTablet) {
    final provider = context.watch<ProductCatalogProvider>();
    final products = provider.products;

    final crossAxisCount = isDesktop ? 4 : (isTablet ? 3 : 2);
    final childAspectRatio = isDesktop ? 0.75 : (isTablet ? 0.7 : 0.65);

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final product = products[index];
          return _buildProductCard(theme, product);
        },
        childCount: products.length,
      ),
    );
  }

  Widget _buildProductCard(ThemeData theme, Product product) {
    return BaseCard(
      onTap: () => _onProductTap(product),
      isInteractive: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: product.images.isNotEmpty
                  ? Image.network(
                      product.images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.medication,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant,
                        );
                      },
                    )
                  : Icon(
                      Icons.medication,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product.genericName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'NPR ${product.price.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: product.stockQuantity > 10
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        product.stockQuantity > 10 ? 'In Stock' : 'Low Stock',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: product.stockQuantity > 10
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(ThemeData theme) {
    return ScaleTransition(
      scale: _fabScaleAnimation,
      child: FloatingActionButton.extended(
        onPressed: () => _navigateToCart(),
        icon: const Icon(Icons.shopping_cart),
        label: const Text('Cart'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildProductDetailSheet(Product product) {
    final theme = Theme.of(context);
    
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Heading(text: product.name, level: HeadingLevel.h4),
                    const SizedBox(height: 8),
                    BodyText(
                      text: product.genericName,
                      size: BodySize.small,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'NPR ${product.price.toStringAsFixed(2)}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Section(
                      title: 'Description',
                      children: [
                        BodyText(text: product.description),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Section(
                      title: 'Stock Information',
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.inventory_2,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            BodyText(
                              text: '${product.stockQuantity} units available',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.category,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            BodyText(text: product.category),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      text: 'Add to Cart',
                      onPressed: () => _addToCart(product),
                      isFullWidth: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState(ThemeData theme, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Heading(text: 'Error Loading Products', level: HeadingLevel.h5),
            const SizedBox(height: 8),
            BodyText(text: error),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Retry',
              onPressed: () => context.read<ProductCatalogProvider>().initialize(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Heading(text: 'No Products Found', level: HeadingLevel.h5),
            const SizedBox(height: 8),
            BodyText(
              text: 'Try adjusting your search or filter criteria',
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToIndex(int index) {
    final routes = [
      '/',
      '/catalog',
      '/orders',
      '/notifications',
      '/profile',
    ];
    if (index >= 0 && index < routes.length) {
      // Navigate to route
    }
  }

  void _navigateToCart() {
    // Navigate to cart
  }

  void _showFilterDialog() {
    // Show filter dialog
  }

  void _addToCart(Product product) {
    // Add to cart logic
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

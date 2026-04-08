import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import '../providers/product_catalog_provider.dart';
import '../../data/models/product_model.dart';
import 'enhanced_product_card.dart';
import '../../../shared/theme/enhanced_app_theme.dart';
import '../../../shared/widgets/responsive/responsive_layout.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/pagination_loader.dart';

/// Enhanced Product Grid with advanced layout options
class EnhancedProductGrid extends StatelessWidget {
  final List<Product> products;
  final Function(Product) onProductTap;
  final Function(Product)? onProductFavorite;
  final Function(Product)? onProductCompare;
  final Function(Product)? onProductQuickView;
  final ViewMode viewMode;
  final bool isLoading;
  final bool hasMore;
  final Function()? onLoadMore;
  final EdgeInsets? padding;
  final double? childAspectRatio;
  final int? crossAxisCount;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;

  const EnhancedProductGrid({
    Key? key,
    required this.products,
    required this.onProductTap,
    this.onProductFavorite,
    this.onProductCompare,
    this.onProductQuickView,
    this.viewMode = ViewMode.grid,
    this.isLoading = false,
    this.hasMore = false,
    this.onLoadMore,
    this.padding,
    this.childAspectRatio,
    this.crossAxisCount,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (products.isEmpty && !isLoading) {
      return _buildEmptyState();
    }

    return ResponsiveLayout(
      mobile: _buildMobileLayout(theme),
      tablet: _buildTabletLayout(theme),
      desktop: _buildDesktopLayout(theme),
    );
  }

  Widget _buildEmptyState() {
    return const EmptyStateWidget(
      icon: Icons.inventory_2_outlined,
      title: 'No Products Found',
      subtitle: 'Try adjusting your filters or search criteria',
      actionText: 'Clear Filters',
    );
  }

  Widget _buildMobileLayout(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: () async {
        final provider = context.read<ProductCatalogProvider>();
        await provider.refresh();
      },
      child: _buildContent(theme, mobileLayout: true),
    );
  }

  Widget _buildTabletLayout(ThemeData theme) {
    return _buildContent(theme, mobileLayout: false);
  }

  Widget _buildDesktopLayout(ThemeData theme) {
    return _buildContent(theme, mobileLayout: false);
  }

  Widget _buildContent(ThemeData theme, {required bool mobileLayout}) {
    if (viewMode == ViewMode.list) {
      return _buildListView(theme);
    }

    return _buildGridView(theme, mobileLayout: mobileLayout);
  }

  Widget _buildListView(ThemeData theme) {
    return ListView.builder(
      padding: padding ?? const EdgeInsets.all(16),
      itemCount: products.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == products.length) {
          return PaginationLoader(isLoading: isLoading);
        }

        final product = products[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: EnhancedProductCard(
            product: product,
            viewMode: ViewMode.list,
            onTap: () => onProductTap(product),
            onFavorite: onProductFavorite != null 
                ? () => onProductFavorite!(product) 
                : null,
            onCompare: onProductCompare != null 
                ? () => onProductCompare!(product) 
                : null,
            onQuickView: onProductQuickView != null 
                ? () => onProductQuickView!(product) 
                : null,
          ),
        );
      },
    );
  }

  Widget _buildGridView(ThemeData theme, {required bool mobileLayout}) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo is ScrollEndNotification &&
            scrollInfo.metrics.extentAfter < 200 &&
            hasMore &&
            !isLoading &&
            onLoadMore != null) {
          onLoadMore!();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () async {
          final provider = context.read<ProductCatalogProvider>();
          await provider.refresh();
        },
        child: CustomScrollView(
          slivers: [
            // Main Grid
            SliverPadding(
              padding: padding ?? const EdgeInsets.all(16),
              sliver: _buildStaggeredGrid(theme, mobileLayout),
            ),
            
            // Loading Indicator
            if (hasMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: PaginationLoader(isLoading: isLoading),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaggeredGrid(ThemeData theme, bool mobileLayout) {
    if (mobileLayout) {
      // Mobile: Simple 2-column grid
      return SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: crossAxisSpacing ?? 12,
          mainAxisSpacing: mainAxisSpacing ?? 12,
          childAspectRatio: childAspectRatio ?? 0.75,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final product = products[index];
            return EnhancedProductCard(
              product: product,
              viewMode: ViewMode.grid,
              onTap: () => onProductTap(product),
              onFavorite: onProductFavorite != null 
                  ? () => onProductFavorite!(product) 
                  : null,
              onCompare: onProductCompare != null 
                  ? () => onProductCompare!(product) 
                  : null,
              onQuickView: onProductQuickView != null 
                  ? () => onProductQuickView!(product) 
                  : null,
            );
          },
          childCount: products.length,
        ),
      );
    } else {
      // Tablet/Desktop: Staggered grid for better visual appeal
      return SliverStaggeredGrid.countBuilder(
        crossAxisCount: _getCrossAxisCount(),
        mainAxisSpacing: mainAxisSpacing ?? 16,
        crossAxisSpacing: crossAxisSpacing ?? 16,
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return EnhancedProductCard(
            product: product,
            viewMode: ViewMode.grid,
            onTap: () => onProductTap(product),
            onFavorite: onProductFavorite != null 
                ? () => onProductFavorite!(product) 
                : null,
            onCompare: onProductCompare != null 
                ? () => onProductCompare!(product) 
                : null,
            onQuickView: onProductQuickView != null 
                ? () => onProductQuickView!(product) 
                : null,
          );
        },
        staggeredTileBuilder: (index) => _getStaggeredTile(index),
      );
    }
  }

  int _getCrossAxisCount() {
    if (crossAxisCount != null) return crossAxisCount!;
    
    // Default responsive cross axis count
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) return 2; // Mobile
    if (screenWidth < 900) return 3; // Tablet
    if (screenWidth < 1200) return 4; // Small Desktop
    return 5; // Large Desktop
  }

  StaggeredTile _getStaggeredTile(int index) {
    // Create interesting staggered pattern
    final pattern = index % 8;
    
    switch (pattern) {
      case 0:
      case 3:
      case 6:
        return const StaggeredTile.count(1, 1.2); // Tall
      case 1:
      case 4:
      case 7:
        return const StaggeredTile.count(1, 1); // Normal
      case 2:
        return const StaggeredTile.count(2, 1); // Wide
      case 5:
        return const StaggeredTile.count(1, 0.8); // Short
      default:
        return const StaggeredTile.count(1, 1); // Normal
    }
  }
}

/// View Mode Enum
enum ViewMode {
  grid,
  list,
}

/// Product Grid Item with Animation
class AnimatedProductCard extends StatefulWidget {
  final Product product;
  final ViewMode viewMode;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onCompare;
  final VoidCallback? onQuickView;
  final int index;

  const AnimatedProductCard({
    Key? key,
    required this.product,
    required this.viewMode,
    required this.onTap,
    this.onFavorite,
    this.onCompare,
    this.onQuickView,
    required this.index,
  }) : super(key: key);

  @override
  State<AnimatedProductCard> createState() => _AnimatedProductCardState();
}

class _AnimatedProductCardState extends State<AnimatedProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300 + (widget.index * 50)),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Start animation after a delay
    Future.delayed(Duration(milliseconds: widget.index * 50), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: child,
          ),
        );
      },
      child: EnhancedProductCard(
        product: widget.product,
        viewMode: widget.viewMode,
        onTap: widget.onTap,
        onFavorite: widget.onFavorite,
        onCompare: widget.onCompare,
        onQuickView: widget.onQuickView,
      ),
    );
  }
}

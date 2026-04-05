import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../shared/theme/enhanced_app_theme.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../../../shared/utils/app_utils.dart';

/// Enhanced Product Card
/// Comprehensive product card with all relevant information and interactive elements
class EnhancedProductCard extends StatefulWidget {
  final ProductEntity product;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onCompare;
  final VoidCallback? onQuickView;
  final bool showFavoriteButton;
  final bool showCompareButton;
  final bool showQuickViewButton;
  final bool showRating;
  final bool showStockStatus;
  final bool showDiscount;
  final double? cardWidth;
  final double? cardHeight;
  final EdgeInsets? margin;
  final bool isLoading;

  const EnhancedProductCard({
    Key? key,
    required this.product,
    this.onTap,
    this.onFavorite,
    this.onCompare,
    this.onQuickView,
    this.showFavoriteButton = true,
    this.showCompareButton = true,
    this.showQuickViewButton = true,
    this.showRating = true,
    this.showStockStatus = true,
    this.showDiscount = true,
    this.cardWidth,
    this.cardHeight,
    this.margin,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<EnhancedProductCard> createState() => _EnhancedProductCardState();
}

class _EnhancedProductCardState extends State<EnhancedProductCard>
    with TickerProviderStateMixin {
  late AnimationController _favoriteController;
  late AnimationController _compareController;
  late AnimationController _quickViewController;
  late Animation<double> _favoriteAnimation;
  late Animation<double> _compareAnimation;
  late Animation<double> _quickViewAnimation;

  bool _isFavorite = false;
  bool _isCompared = false;

  @override
  void initState() {
    super.initState();
    
    _favoriteController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _compareController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _quickViewController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _favoriteAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _favoriteController,
      curve: Curves.elasticOut,
    ));

    _compareAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _compareController,
      curve: Curves.elasticOut,
    ));

    _quickViewAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _quickViewController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _favoriteController.dispose();
    _compareController.dispose();
    _quickViewController.dispose();
    super.dispose();
  }

  void _handleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    _favoriteController.forward().then((_) {
      _favoriteController.reverse();
    });

    widget.onFavorite?.call();
  }

  void _handleCompare() {
    setState(() {
      _isCompared = !_isCompared;
    });

    _compareController.forward().then((_) {
      _compareController.reverse();
    });

    widget.onCompare?.call();
  }

  void _handleQuickView() {
    _quickViewController.forward().then((_) {
      _quickViewController.reverse();
    });

    widget.onQuickView?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (widget.isLoading) {
      return _buildLoadingCard(theme);
    }

    return Container(
      width: widget.cardWidth,
      height: widget.cardHeight,
      margin: widget.margin ?? const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image Section
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    // Main Image
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12.0),
                        ),
                        color: theme.cardColor,
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12.0),
                        ),
                        child: _buildProductImage(theme),
                      ),
                    ),
                    
                    // Action Buttons
                    if (widget.showFavoriteButton || widget.showCompareButton || widget.showQuickViewButton)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.showFavoriteButton)
                              _buildActionButton(
                                icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: _isFavorite ? Colors.red : Colors.grey,
                                animation: _favoriteAnimation,
                                onTap: _handleFavorite,
                              ),
                            const SizedBox(height: 4),
                            if (widget.showCompareButton)
                              _buildActionButton(
                                icon: _isCompared ? Icons.compare : Icons.compare_arrows,
                                color: _isCompared ? theme.primaryColor : Colors.grey,
                                animation: _compareAnimation,
                                onTap: _handleCompare,
                              ),
                            const SizedBox(height: 4),
                            if (widget.showQuickViewButton)
                              _buildActionButton(
                                icon: Icons.quicklook,
                                color: Colors.grey,
                                animation: _quickViewAnimation,
                                onTap: _handleQuickView,
                              ),
                          ],
                        ),
                      ),
                    
                    // Discount Badge
                    if (widget.showDiscount && widget.product.isOnSale)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            widget.product.formattedDiscount,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    
                    // Stock Status Badge
                    if (widget.showStockStatus)
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: _getStockStatusColor(widget.product.stockStatus),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            widget.product.stockStatus,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Product Information Section
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Text(
                        widget.product.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.titleSmall?.color,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Brand and Manufacturer
                      Text(
                        '${widget.product.brand} • ${widget.product.manufacturer}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Dosage Form
                      Text(
                        widget.product.formulation,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const Spacer(),
                      
                      // Rating
                      if (widget.showRating && widget.product.rating != null)
                        _buildRatingRow(theme),
                      
                      const SizedBox(height: 8),
                      
                      // Price Section
                      _buildPriceSection(theme),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(ThemeData theme) {
    if (widget.product.imageUrl.isEmpty) {
      return Container(
        color: theme.scaffoldBackgroundColor,
        child: Icon(
          Icons.medication,
          size: 48,
          color: theme.hintColor,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: widget.product.imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => LoadingShimmer(
        child: Container(
          color: theme.scaffoldBackgroundColor,
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: theme.scaffoldBackgroundColor,
        child: Icon(
          Icons.broken_image,
          size: 48,
          color: theme.hintColor,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required Animation<double> animation,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 16,
                color: color,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRatingRow(ThemeData theme) {
    return Row(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final starValue = index + 1;
            final isFilled = starValue <= widget.product.rating!;
            
            return Icon(
              isFilled ? Icons.star : Icons.star_border,
              size: 12,
              color: isFilled ? Colors.amber : Colors.grey.shade300,
            );
          }),
        ),
        const SizedBox(width: 4),
        Text(
          widget.product.rating!.toStringAsFixed(1),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.hintColor,
            fontSize: 10,
          ),
        ),
        if (widget.product.reviewCount != null) ...[
          const SizedBox(width: 2),
          Text(
            '(${widget.product.reviewCount})',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.hintColor,
              fontSize: 10,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPriceSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current Price
        Text(
          widget.product.formattedPrice,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
        
        // Original Price (if on sale)
        if (widget.product.isOnSale)
          Text(
            widget.product.formattedOriginalPrice,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.hintColor,
              decoration: TextDecoration.lineThrough,
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingCard(ThemeData theme) {
    return Container(
      width: widget.cardWidth,
      height: widget.cardHeight,
      margin: widget.margin ?? const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: LoadingShimmer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12.0),
                    ),
                    color: theme.scaffoldBackgroundColor,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 12,
                        width: double.infinity * 0.8,
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: 16,
                        width: double.infinity * 0.6,
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStockStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'in stock':
        return Colors.green;
      case 'low stock':
        return Colors.orange;
      case 'out of stock':
        return Colors.red;
      case 'expired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

/// Product Card Grid
/// Grid layout for product cards with responsive design
class ProductCardGrid extends StatelessWidget {
  final List<ProductEntity> products;
  final Function(ProductEntity)? onProductTap;
  final Function(ProductEntity)? onProductFavorite;
  final Function(ProductEntity)? onProductCompare;
  final Function(ProductEntity)? onProductQuickView;
  final bool showFavoriteButton;
  final bool showCompareButton;
  final bool showQuickViewButton;
  final bool showRating;
  final bool showStockStatus;
  final bool showDiscount;
  final int crossAxisCount;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsets padding;
  final bool isLoading;
  final int? itemCount;

  const ProductCardGrid({
    Key? key,
    required this.products,
    this.onProductTap,
    this.onProductFavorite,
    this.onProductCompare,
    this.onProductQuickView,
    this.showFavoriteButton = true,
    this.showCompareButton = true,
    this.showQuickViewButton = true,
    this.showRating = true,
    this.showStockStatus = true,
    this.showDiscount = true,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.7,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
    this.padding = const EdgeInsets.all(16.0),
    this.isLoading = false,
    this.itemCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Padding(
        padding: padding,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
          ),
          itemCount: itemCount ?? 6,
          itemBuilder: (context, index) {
            return EnhancedProductCard(
              product: products.isNotEmpty ? products[index % products.length] : _getMockProduct(),
              isLoading: true,
              showFavoriteButton: showFavoriteButton,
              showCompareButton: showCompareButton,
              showQuickViewButton: showQuickViewButton,
              showRating: showRating,
              showStockStatus: showStockStatus,
              showDiscount: showDiscount,
            );
          },
        ),
      );
    }

    if (products.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: padding,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return EnhancedProductCard(
            product: product,
            onTap: () => onProductTap?.call(product),
            onFavorite: () => onProductFavorite?.call(product),
            onCompare: () => onProductCompare?.call(product),
            onQuickView: () => onProductQuickView?.call(product),
            showFavoriteButton: showFavoriteButton,
            showCompareButton: showCompareButton,
            showQuickViewButton: showQuickViewButton,
            showRating: showRating,
            showStockStatus: showStockStatus,
            showDiscount: showDiscount,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Theme.of(context).hintColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).hintColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search terms',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }

  ProductEntity _getMockProduct() {
    return ProductEntity(
      id: 'mock',
      name: 'Mock Product',
      description: 'Mock Description',
      category: 'Mock Category',
      brand: 'Mock Brand',
      manufacturer: 'Mock Manufacturer',
      dosage: 'Mock Dosage',
      formulation: 'Mock Formulation',
      imageUrl: '',
      price: 0.0,
      stockQuantity: 0,
      minOrderQuantity: 1,
      sku: 'MOCK-001',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      preferences: const UserPreferences(),
      securitySettings: const SecuritySettings(
        twoFactorEnabled: false,
        twoFactorMethod: TwoFactorMethod.none,
        sessionTimeoutEnabled: true,
        sessionTimeoutMinutes: 30,
        ipWhitelistEnabled: false,
        whitelistedIps: [],
        deviceTrackingEnabled: true,
        maxConcurrentSessions: 3,
        passwordComplexityEnabled: true,
        passwordMinLength: 8,
        passwordHistoryCount: 5,
        loginAttemptLimitEnabled: true,
        maxLoginAttempts: 5,
        lockoutDurationMinutes: 15,
        suspiciousActivityDetection: true,
      ),
    );
  }
}

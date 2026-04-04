import 'package:flutter/material.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';
import 'package:vedanta_trade/features/catalog/domain/entities/product_entity.dart';

/// Enhanced Product Card with smooth animations and micro-interactions
class EnhancedProductCard extends StatefulWidget {
  final ProductEntity product;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onAddToCart;
  final bool isSelected;
  final bool showFavorite;
  final bool showAddToCart;
  final bool withHeroAnimation;
  final String? heroTag;

  const EnhancedProductCard({
    Key? key,
    required this.product,
    this.onTap,
    this.onFavoriteToggle,
    this.onAddToCart,
    this.isSelected = false,
    this.showFavorite = true,
    this.showAddToCart = true,
    this.withHeroAnimation = true,
    this.heroTag,
  }) : super(key: key);

  @override
  State<EnhancedProductCard> createState() => _EnhancedProductCardState();
}

class _EnhancedProductCardState extends State<EnhancedProductCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  late AnimationController _favoriteController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _favoriteAnimation;
  late Animation<double> _selectionAnimation;

  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _favoriteController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    _favoriteAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _favoriteController,
      curve: Curves.elasticOut,
    ));

    _selectionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    if (widget.product.featured) {
      _shimmerController.repeat();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shimmerController.dispose();
    _favoriteController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _handleMouseEnter(PointerEnterEvent event) {
    setState(() => _isHovered = true);
  }

  void _handleMouseExit(PointerExitEvent event) {
    setState(() => _isHovered = false);
  }

  @override
  Widget build(BuildContext context) {
    final cardContent = _buildCardContent();

    if (widget.withHeroAnimation && widget.heroTag != null) {
      return Hero(
        tag: widget.heroTag!,
        flightShuttleBuilder: (flightContext, animation, direction, fromContext, toContext) {
          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.8 + (animation.value * 0.2),
                child: child,
              );
            },
            child: cardContent,
          );
        },
        child: cardContent,
      );
    }

    return cardContent;
  }

  Widget _buildCardContent() {
    return MouseRegion(
      onEnter: _handleMouseEnter,
      onExit: _handleMouseExit,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? AppTheme.primary.withOpacity(0.1)
                      : AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.isSelected
                        ? AppTheme.primary
                        : AppTheme.glassBorderLight,
                    width: widget.isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(_isHovered ? 0.2 : 0.1),
                      blurRadius: _isHovered ? 12 : 8,
                      offset: Offset(0, _isHovered ? 6 : 4),
                    ),
                    if (widget.product.featured)
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Stack(
                  children: [
                    _buildProductImage(),
                    _buildProductInfo(),
                    _buildActionButtons(),
                    _buildSelectionIndicator(),
                    if (widget.product.featured) _buildFeaturedBadge(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Positioned.fill(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primary.withOpacity(0.1),
                AppTheme.secondary.withOpacity(0.1),
              ],
            ),
          ),
          child: Stack(
            children: [
              if (product.images.isNotEmpty)
                Image.network(
                  product.images.first,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholderImage();
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _buildLoadingImage();
                  },
                )
              else
                _buildPlaceholderImage(),
              if (widget.product.featured)
                _buildShimmerEffect(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppTheme.glassBg,
      child: Icon(
        Icons.medication_rounded,
        size: 48,
        color: AppTheme.glassBorderLight,
      ),
    );
  }

  Widget _buildLoadingImage() {
    return Container(
      color: AppTheme.glassBg,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
        ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.0 + _shimmerAnimation.value, 0),
              end: Alignment(1.0 + _shimmerAnimation.value, 0),
              colors: [
                Colors.transparent,
                Colors.white.withOpacity(0.3),
                Colors.transparent,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductInfo() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.cardDark.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              product.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              product.manufacturer,
              style: const TextStyle(
                color: AppTheme.glassBorderLight,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  product.formattedPrice,
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStockIndicator(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockIndicator() {
    Color indicatorColor;
    String stockText;

    if (product.isOutOfStock) {
      indicatorColor = AppTheme.error;
      stockText = 'Out of Stock';
    } else if (product.hasLowStock) {
      indicatorColor = AppTheme.warning;
      stockText = 'Low Stock';
    } else {
      indicatorColor = AppTheme.success;
      stockText = 'In Stock';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: indicatorColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        stockText,
        style: TextStyle(
          color: indicatorColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Positioned(
      top: 8,
      right: 8,
      child: Column(
        children: [
          if (widget.showFavorite) _buildFavoriteButton(),
          if (widget.showAddToCart) ...[
            const SizedBox(height: 8),
            _buildAddToCartButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return AnimatedBuilder(
      animation: _favoriteAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _favoriteAnimation.value,
          child: GestureDetector(
            onTap: () {
              _favoriteController.forward().then((_) {
                _favoriteController.reverse();
              });
              widget.onFavoriteToggle?.call();
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.favorite_border,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddToCartButton() {
    return GestureDetector(
      onTap: widget.onAddToCart,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.add_shopping_cart,
          size: 16,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSelectionIndicator() {
    return AnimatedBuilder(
      animation: _selectionAnimation,
      builder: (context, child) {
        return Positioned(
          top: 8,
          left: 8,
          child: Transform.scale(
            scale: widget.isSelected ? _selectionAnimation.value : 0,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.check,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturedBadge() {
    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'FEATURED',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/enhanced_product_catalog_provider.dart';
import '../../data/models/product_model.dart';
import '../../../shared/theme/enhanced_app_theme.dart';

/// Product Quick View Dialog
/// Fast product preview without leaving current screen
class ProductQuickView extends StatefulWidget {
  final Product product;
  final VoidCallback? onClose;
  final VoidCallback? onViewFullDetails;
  final VoidCallback? onAddToCart;
  final VoidCallback? onAddToWishlist;

  const ProductQuickView({
    Key? key,
    required this.product,
    this.onClose,
    this.onViewFullDetails,
    this.onAddToCart,
    this.onAddToWishlist,
  }) : super(key: key);

  @override
  State<ProductQuickView> createState() => _ProductQuickViewState();
}

class _ProductQuickViewState extends State<ProductQuickView>
    with TickerProviderStateMixin {
  late AnimationController _dialogController;
  late AnimationController _imageController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _imageAnimation;
  int _selectedImageIndex = 0;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _dialogController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _imageController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _dialogController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _dialogController,
      curve: Curves.easeInOut,
    );

    _imageAnimation = CurvedAnimation(
      parent: _imageController,
      curve: Curves.easeInOut,
    );

    _dialogController.forward();
  }

  @override
  void dispose() {
    _dialogController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _nextImage() {
    if (widget.product.additionalImages.isEmpty) return;
    
    setState(() {
      _selectedImageIndex = (_selectedImageIndex + 1) % widget.product.additionalImages.length;
    });
    
    _imageController.forward(from: 0);
  }

  void _previousImage() {
    if (widget.product.additionalImages.isEmpty) return;
    
    setState(() {
      _selectedImageIndex = (_selectedImageIndex - 1 + widget.product.additionalImages.length) % widget.product.additionalImages.length;
    });
    
    _imageController.forward(from: 0);
  }

  void _incrementQuantity() {
    if (_quantity < widget.product.stockQuantity) {
      setState(() {
        _quantity++;
      });
    }
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<EnhancedProductCatalogProvider>();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.8,
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header
                    _buildHeader(theme),
                    
                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Images
                            _buildProductImages(theme),
                            const SizedBox(height: 24),
                            
                            // Product Info
                            _buildProductInfo(theme),
                            const SizedBox(height: 24),
                            
                            // Stock and Pricing
                            _buildStockPricing(theme),
                            const SizedBox(height: 24),
                            
                            // Quantity Selector
                            _buildQuantitySelector(theme),
                            const SizedBox(height: 24),
                            
                            // Action Buttons
                            _buildActionButtons(theme, provider),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          const Text(
            'Quick View',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: widget.onClose ?? () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImages(ThemeData theme) {
    final images = [widget.product.imageUrl, ...widget.product.additionalImages];
    
    return Container(
      height: 200,
      child: Stack(
        children: [
          // Main Image
          Center(
            child: AnimatedBuilder(
              animation: _imageAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _imageAnimation,
                  child: Transform.scale(
                    scale: 0.95 + (_imageAnimation.value * 0.05),
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(
                            images[_selectedImageIndex],
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Navigation Arrows
          if (images.length > 1) ...[
            // Previous
            Positioned(
              left: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _previousImage,
                    icon: const Icon(Icons.chevron_left, color: Colors.white),
                  ),
                ),
              ),
            ),
            
            // Next
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _nextImage,
                    icon: const Icon(Icons.chevron_right, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
          
          // Image Indicators
          if (images.length > 1)
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: images.asMap().entries.map((entry) {
                  final index = entry.key;
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _selectedImageIndex
                          ? theme.primaryColor
                          : Colors.white.withOpacity(0.5),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Name
        Text(
          widget.product.name,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        // Brand and Category
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.product.brand,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.product.category,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Rating
        Row(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (index) {
                return Icon(
                  index < widget.product.rating.floor()
                      ? Icons.star
                      : index < widget.product.rating
                          ? Icons.star_half
                          : Icons.star_border,
                  color: Colors.amber,
                  size: 16,
                );
              }),
            ),
            const SizedBox(width: 8),
            Text(
              '${widget.product.rating.toStringAsFixed(1)} (${widget.product.reviewCount} reviews)',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Description
        Text(
          widget.product.description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildStockPricing(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          // Price
          Row(
            children: [
              if (widget.product.isOnSale) ...[
                Text(
                  'Rs. ${widget.product.originalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                'Rs. ${widget.product.price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: widget.product.isOnSale ? Colors.red : theme.primaryColor,
                ),
              ),
              if (widget.product.isOnSale) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '${((1 - widget.product.price / widget.product.originalPrice) * 100).toInt()}% OFF',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          
          // Stock Status
          Row(
            children: [
              Icon(
                widget.product.stockQuantity > 0 
                    ? Icons.check_circle 
                    : Icons.cancel,
                color: widget.product.stockQuantity > 0 ? Colors.green : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                widget.product.stockQuantity > 0 
                    ? '${widget.product.stockQuantity} units in stock'
                    : 'Out of stock',
                style: TextStyle(
                  color: widget.product.stockQuantity > 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (widget.product.isLowStock && widget.product.stockQuantity > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Low Stock',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Text(
            'Quantity:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _decrementQuantity,
                  icon: const Icon(Icons.remove),
                  visualDensity: VisualDensity.compact,
                ),
                Container(
                  width: 50,
                  alignment: Alignment.center,
                  child: Text(
                    '$_quantity',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _incrementQuantity,
                  icon: const Icon(Icons.add),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme, EnhancedProductCatalogProvider provider) {
    return Column(
      children: [
        // Primary Actions
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: widget.product.stockQuantity > 0 ? widget.onAddToCart : null,
                icon: const Icon(Icons.shopping_cart),
                label: const Text('Add to Cart'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  provider.toggleFavorite(widget.product);
                },
                icon: Icon(
                  provider.isFavorite(widget.product) 
                      ? Icons.favorite 
                      : Icons.favorite_border,
                ),
                label: Text(
                  provider.isFavorite(widget.product) 
                      ? 'Remove from Wishlist'
                      : 'Add to Wishlist',
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Secondary Actions
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: widget.onViewFullDetails,
            child: const Text('View Full Details'),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../../shared/widgets/premium_glassmorphic_theme.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _quantity = 1;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PremiumGlassmorphicTheme.glassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            Expanded(
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      expandedHeight: 300,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        background: _buildProductImage(),
                      ),
                      actions: [
                        IconButton(
                          onPressed: _toggleFavorite,
                          icon: Icon(
                            _isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: _isFavorite ? Colors.red : PremiumGlassmorphicTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ];
                },
                body: _buildProductDetails(),
              ),
            ),
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PremiumGlassmorphicTheme.glassAppBar(
      title: widget.product.name,
      actions: [
        IconButton(
          onPressed: _shareProduct,
          icon: const Icon(Icons.share),
          color: PremiumGlassmorphicTheme.textPrimary,
        ),
      ],
    );
  }

  Widget _buildProductImage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          widget.product.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: PremiumGlassmorphicTheme.surfaceLight.withOpacity(0.3),
              child: const Center(
                child: Icon(
                  Icons.medication,
                  color: PremiumGlassmorphicTheme.textTertiary,
                  size: 80,
                ),
              ),
            );
          },
        ),
        
        // Stock Badge
        Positioned(
          bottom: 16,
          left: 16,
          child: _buildStockBadge(),
        ),
        
        // Discount Badge
        if (widget.product.hasDiscount)
          Positioned(
            top: 16,
            right: 16,
            child: _buildDiscountBadge(),
          ),
      ],
    );
  }

  Widget _buildProductDetails() {
    return Column(
      children: [
        // Product Info
        _buildProductInfo(),
        
        // Tabs
        PremiumGlassmorphicTheme.glassTabBar(
          tabs: ['Details', 'Reviews', 'Related'],
          selectedIndex: _tabController.index,
          onTap: (index) => _tabController.animateTo(index),
        ),
        
        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDetailsTab(),
              _buildReviewsTab(),
              _buildRelatedProductsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo() {
    return PremiumGlassmorphicTheme.glassCard(
      margin: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingMd),
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Name and Category
          Text(
            widget.product.name,
            style: const TextStyle(
              color: PremiumGlassmorphicTheme.textPrimary,
              fontSize: PremiumGlassmorphicTheme.fontSizeXxl,
              fontWeight: FontWeight.w700,
            ),
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingSm),
          
          Text(
            '${widget.product.category} • ${widget.product.manufacturer}',
            style: const TextStyle(
              color: PremiumGlassmorphicTheme.textSecondary,
              fontSize: PremiumGlassmorphicTheme.fontSizeMd,
            ),
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
          
          // Rating and Reviews
          Row(
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < widget.product.rating.floor()
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 20,
                  );
                }),
              ),
              const SizedBox(width: PremiumGlassmorphicTheme.spacingSm),
              Text(
                '${widget.product.rating.toStringAsFixed(1)} (${widget.product.reviewCount} reviews)',
                style: const TextStyle(
                  color: PremiumGlassmorphicTheme.textSecondary,
                  fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingLg),
          
          // Price
          Row(
            children: [
              if (widget.product.hasDiscount) ...[
                Text(
                  widget.product.originalPrice,
                  style: const TextStyle(
                    color: PremiumGlassmorphicTheme.textTertiary,
                    fontSize: PremiumGlassmorphicTheme.fontSizeLg,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: PremiumGlassmorphicTheme.spacingSm),
              ],
              Text(
                widget.product.formattedPrice,
                style: const TextStyle(
                  color: PremiumGlassmorphicTheme.indigo500,
                  fontSize: PremiumGlassmorphicTheme.fontSizeXxl,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
          
          // Description
          Text(
            widget.product.description,
            style: const TextStyle(
              color: PremiumGlassmorphicTheme.textSecondary,
              fontSize: PremiumGlassmorphicTheme.fontSizeMd,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Specifications
          _buildSectionHeader('Product Specifications'),
          _buildSpecificationGrid(),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingXl),
          
          // Ingredients
          _buildSectionHeader('Ingredients'),
          Text(
            widget.product.ingredients.join(', '),
            style: const TextStyle(
              color: PremiumGlassmorphicTheme.textSecondary,
              fontSize: PremiumGlassmorphicTheme.fontSizeMd,
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingXl),
          
          // Side Effects
          _buildSectionHeader('Side Effects'),
          Text(
            widget.product.sideEffects.join(', '),
            style: const TextStyle(
              color: PremiumGlassmorphicTheme.textSecondary,
              fontSize: PremiumGlassmorphicTheme.fontSizeMd,
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingXl),
          
          // Contraindications
          _buildSectionHeader('Contraindications'),
          Text(
            widget.product.contraindications.join(', '),
            style: const TextStyle(
              color: PremiumGlassmorphicTheme.textSecondary,
              fontSize: PremiumGlassmorphicTheme.fontSizeMd,
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingXl),
          
          // Storage Information
          _buildSectionHeader('Storage Information'),
          Text(
            widget.product.storageConditions,
            style: const TextStyle(
              color: PremiumGlassmorphicTheme.textSecondary,
              fontSize: PremiumGlassmorphicTheme.fontSizeMd,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingMd),
      itemCount: 10, // Mock reviews
      itemBuilder: (context, index) {
        return _buildReviewCard(index);
      },
    );
  }

  Widget _buildRelatedProductsTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingMd),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: PremiumGlassmorphicTheme.spacingMd,
        mainAxisSpacing: PremiumGlassmorphicTheme.spacingMd,
      ),
      itemCount: 6, // Mock related products
      itemBuilder: (context, index) {
        return _buildRelatedProductCard(index);
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PremiumGlassmorphicTheme.spacingMd),
      child: Text(
        title,
        style: const TextStyle(
          color: PremiumGlassmorphicTheme.textPrimary,
          fontSize: PremiumGlassmorphicTheme.fontSizeLg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSpecificationGrid() {
    return PremiumGlassmorphicTheme.glassCard(
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingMd),
      child: Column(
        children: [
          _buildSpecificationRow('Form', widget.product.form),
          _buildSpecificationRow('Dosage', widget.product.dosage),
          _buildSpecificationRow('Pack Size', widget.product.packSize),
          _buildSpecificationRow('Expiry Date', widget.product.expiryDate),
          _buildSpecificationRow('Stock Quantity', '${widget.product.stockQuantity}'),
        ],
      ),
    );
  }

  Widget _buildSpecificationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: PremiumGlassmorphicTheme.spacingSm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: PremiumGlassmorphicTheme.textSecondary,
              fontSize: PremiumGlassmorphicTheme.fontSizeMd,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: PremiumGlassmorphicTheme.textPrimary,
              fontSize: PremiumGlassmorphicTheme.fontSizeMd,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(int index) {
    return PremiumGlassmorphicTheme.glassCard(
      margin: const EdgeInsets.only(bottom: PremiumGlassmorphicTheme.spacingMd),
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Review Header
          Row(
            children: [
              CircleAvatar(
                backgroundColor: PremiumGlassmorphicTheme.indigo500.withOpacity(0.2),
                child: Text(
                  'U${index + 1}',
                  style: const TextStyle(
                    color: PremiumGlassmorphicTheme.indigo500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: PremiumGlassmorphicTheme.spacingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User ${index + 1}',
                      style: const TextStyle(
                        color: PremiumGlassmorphicTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: List.generate(5, (starIndex) {
                        return Icon(
                          starIndex < 4 ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Text(
                '${index + 1} days ago',
                style: const TextStyle(
                  color: PremiumGlassmorphicTheme.textTertiary,
                  fontSize: PremiumGlassmorphicTheme.fontSizeXs,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
          
          // Review Content
          Text(
            'This product works great! Highly recommended for anyone looking for quality medication.',
            style: const TextStyle(
              color: PremiumGlassmorphicTheme.textSecondary,
              fontSize: PremiumGlassmorphicTheme.fontSizeSm,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedProductCard(int index) {
    return PremiumGlassmorphicTheme.glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(PremiumGlassmorphicTheme.radiusMd),
                ),
                color: PremiumGlassmorphicTheme.surfaceLight.withOpacity(0.3),
              ),
              child: const Center(
                child: Icon(
                  Icons.medication,
                  color: PremiumGlassmorphicTheme.textTertiary,
                  size: 40,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Related Product ${index + 1}',
                    style: const TextStyle(
                      color: PremiumGlassmorphicTheme.textPrimary,
                      fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: PremiumGlassmorphicTheme.spacingXs),
                  Text(
                    'NPR ${(500 + index * 100).toString()}',
                    style: const TextStyle(
                      color: PremiumGlassmorphicTheme.indigo500,
                      fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                      fontWeight: FontWeight.w700,
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

  Widget _buildBottomActionBar() {
    return PremiumGlassmorphicTheme.glassCard(
      margin: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingMd),
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingMd),
      child: Row(
        children: [
          // Quantity Selector
          Row(
            children: [
              GestureDetector(
                onTap: _decreaseQuantity,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: PremiumGlassmorphicTheme.surfaceDark.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(PremiumGlassmorphicTheme.radiusSm),
                  ),
                  child: const Icon(
                    Icons.remove,
                    color: PremiumGlassmorphicTheme.textPrimary,
                    size: 20,
                  ),
                ),
              ),
              Container(
                width: 60,
                alignment: Alignment.center,
                child: Text(
                  '$_quantity',
                  style: const TextStyle(
                    color: PremiumGlassmorphicTheme.textPrimary,
                    fontSize: PremiumGlassmorphicTheme.fontSizeLg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _increaseQuantity,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: PremiumGlassmorphicTheme.surfaceDark.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(PremiumGlassmorphicTheme.radiusSm),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: PremiumGlassmorphicTheme.textPrimary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(width: PremiumGlassmorphicTheme.spacingMd),
          
          // Add to Cart Button
          Expanded(
            child: PremiumGlassmorphicTheme.glassButton(
              onPressed: _addToCart,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart),
                  const SizedBox(width: PremiumGlassmorphicTheme.spacingSm),
                  Text('Add to Cart (${(widget.product.price * _quantity).toStringAsFixed(0)})'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockBadge() {
    Color badgeColor;
    String badgeText;
    
    if (widget.product.stockQuantity == 0) {
      badgeColor = PremiumGlassmorphicTheme.error;
      badgeText = 'Out of Stock';
    } else if (widget.product.isLowStock) {
      badgeColor = PremiumGlassmorphicTheme.warning;
      badgeText = 'Low Stock';
    } else {
      badgeColor = PremiumGlassmorphicTheme.success;
      badgeText = 'In Stock';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PremiumGlassmorphicTheme.spacingSm,
        vertical: PremiumGlassmorphicTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(PremiumGlassmorphicTheme.radiusSm),
      ),
      child: Text(
        badgeText,
        style: const TextStyle(
          color: PremiumGlassmorphicTheme.textPrimary,
          fontSize: PremiumGlassmorphicTheme.fontSizeSm,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDiscountBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PremiumGlassmorphicTheme.spacingSm,
        vertical: PremiumGlassmorphicTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: PremiumGlassmorphicTheme.error.withOpacity(0.9),
        borderRadius: BorderRadius.circular(PremiumGlassmorphicTheme.radiusSm),
      ),
      child: Text(
        '-${widget.product.discountPercentage}%',
        style: const TextStyle(
          color: PremiumGlassmorphicTheme.textPrimary,
          fontSize: PremiumGlassmorphicTheme.fontSizeSm,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  void _shareProduct() {
    
  }

  void _increaseQuantity() {
    if (_quantity < widget.product.stockQuantity) {
      setState(() {
        _quantity++;
      });
    }
  }

  void _decreaseQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  void _addToCart() {
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $_quantity items to cart'),
        backgroundColor: PremiumGlassmorphicTheme.success,
      ),
    );
  }
}

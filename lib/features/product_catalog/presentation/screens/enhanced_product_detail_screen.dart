import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/product_model.dart';
import '../providers/product_catalog_provider.dart';
import '../widgets/responsive_product_card.dart';
import 'package:provider/provider.dart';

/// Enhanced Product Detail Screen
/// Comprehensive product information display with improved UX
class EnhancedProductDetailScreen extends StatefulWidget {
  final Product product;

  const EnhancedProductDetailScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<EnhancedProductDetailScreen> createState() => _EnhancedProductDetailScreenState();
}

class _EnhancedProductDetailScreenState extends State<EnhancedProductDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _quantity = 1;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _checkFavoriteStatus();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _checkFavoriteStatus() {
    final provider = context.read<ProductCatalogProvider>();
    setState(() {
      _isFavorite = provider.isFavorite(widget.product.id);
    });
  }

  void _toggleFavorite() {
    HapticFeedback.lightImpact();
    final provider = context.read<ProductCatalogProvider>();
    provider.toggleFavorite(widget.product);
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  void _addToCart() {
    HapticFeedback.lightImpact();
    // Add to cart logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} added to cart'),
        action: SnackBarAction(
          label: 'VIEW CART',
          onPressed: () {
            // Navigate to cart
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: isTablet ? 400 : 300,
            floating: false,
            pinned: true,
            backgroundColor: theme.colorScheme.surface,
            actions: [
              IconButton(
                icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
                color: _isFavorite ? Colors.red : theme.colorScheme.onSurface,
                onPressed: _toggleFavorite,
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  // Share functionality
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.product.name,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              background: _buildProductImage(theme),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price and Rating
                _buildPriceSection(theme),
                
                // Tabs
                _buildTabBar(theme),
                
                // Tab Content
                SizedBox(
                  height: 400,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDescriptionTab(theme),
                      _buildSpecificationsTab(theme),
                      _buildReviewsTab(theme),
                      _buildRelatedProductsTab(theme),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(theme),
    );
  }

  Widget _buildProductImage(ThemeData theme) {
    if (widget.product.images.isNotEmpty) {
      return Image.network(
        widget.product.images.first,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: theme.colorScheme.surfaceVariant,
            child: Icon(
              Icons.medication,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          );
        },
      );
    }
    return Container(
      color: theme.colorScheme.surfaceVariant,
      child: Icon(
        Icons.medication,
        size: 64,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildPriceSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.product.formattedPrice,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.product.isOnSale) ...[
                const SizedBox(width: 12),
                Text(
                  widget.product.formattedOriginalPrice,
                  style: theme.textTheme.titleMedium?.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.product.formattedDiscount,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.star,
                size: 20,
                color: Colors.amber,
              ),
              const SizedBox(width: 4),
              Text(
                widget.product.rating.toStringAsFixed(1),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${widget.product.reviewCount} reviews)',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
              _buildStockIndicator(theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStockIndicator(ThemeData theme) {
    final stockStatus = widget.product.stockStatus;
    final color = widget.product.stockQuantity > 10
        ? Colors.green
        : (widget.product.stockQuantity > 0 ? Colors.orange : Colors.red);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            stockStatus,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return TabBar(
      controller: _tabController,
      labelColor: theme.colorScheme.primary,
      unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
      indicatorColor: theme.colorScheme.primary,
      tabs: const [
        Tab(text: 'Description'),
        Tab(text: 'Specifications'),
        Tab(text: 'Reviews'),
        Tab(text: 'Related'),
      ],
    );
  }

  Widget _buildDescriptionTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.product.description,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          if (widget.product.indications.isNotEmpty) ...[
            Text(
              'Indications',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...widget.product.indications.map((indication) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(
                    child: Text(
                      indication,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 24),
          ],
          if (widget.product.contraindications.isNotEmpty) ...[
            Text(
              'Contraindications',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...widget.product.contraindications.map((contraindication) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(
                    child: Text(
                      contraindication,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 24),
          ],
          if (widget.product.sideEffects.isNotEmpty) ...[
            Text(
              'Side Effects',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...widget.product.sideEffects.map((sideEffect) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(
                    child: Text(
                      sideEffect,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildSpecificationsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Specifications',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSpecRow('SKU', widget.product.sku, theme),
          _buildSpecRow('Brand', widget.product.brand, theme),
          _buildSpecRow('Manufacturer', widget.product.manufacturer, theme),
          _buildSpecRow('Category', widget.product.category, theme),
          _buildSpecRow('Dosage Form', widget.product.dosageForm, theme),
          _buildSpecRow('Strength', widget.product.strength, theme),
          _buildSpecRow('Packaging', widget.product.packaging, theme),
          _buildSpecRow('Unit', widget.product.unit, theme),
          _buildSpecRow('Min Order Qty', '${widget.product.minOrderQuantity}', theme),
          const SizedBox(height: 16),
          Text(
            'Regulatory Information',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildSpecRow('NDC Number', widget.product.ndcNumber, theme),
          _buildSpecRow('IRD Number', widget.product.irdNumber, theme),
          _buildSpecRow('Regulatory Status', widget.product.regulatoryStatus, theme),
          _buildSpecRow('Prescription Required', widget.product.prescriptionRequired, theme),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.reviews,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No reviews yet',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to review this product',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedProductsTab(ThemeData theme) {
    final provider = context.watch<ProductCatalogProvider>();
    final relatedProducts = provider.getProductsByCategory(widget.product.category)
        .where((p) => p.id != widget.product.id)
        .take(4)
        .toList();

    if (relatedProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No related products',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: relatedProducts.length,
      itemBuilder: (context, index) {
        final product = relatedProducts[index];
        return ResponsiveProductCard(
          product: product,
          variant: ProductCardVariant.compact,
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => EnhancedProductDetailScreen(product: product),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Quantity Selector
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                  ),
                  Text(
                    '$_quantity',
                    style: theme.textTheme.titleMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => setState(() => _quantity++),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Add to Cart Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _addToCart,
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Add to Cart'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

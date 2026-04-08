import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/enhanced_product_catalog_provider.dart';
import '../../data/models/product_model.dart';
import '../../../shared/theme/enhanced_app_theme.dart';

/// Product Comparison Panel
/// Side-by-side comparison of selected products
class ProductComparisonPanel extends StatefulWidget {
  final VoidCallback? onClose;

  const ProductComparisonPanel({
    Key? key,
    this.onClose,
  }) : super(key: key);

  @override
  State<ProductComparisonPanel> createState() => _ProductComparisonPanelState();
}

class _ProductComparisonPanelState extends State<ProductComparisonPanel>
    with TickerProviderStateMixin {
  late AnimationController _panelController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _panelController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _panelController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _panelController,
      curve: Curves.easeOutBack,
    ));

    _panelController.forward();
  }

  @override
  void dispose() {
    _panelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<EnhancedProductCatalogProvider>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle Bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: theme.dividerColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'Compare Products',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    provider.clearComparison();
                    widget.onClose?.call();
                  },
                  child: const Text('Clear All'),
                ),
                IconButton(
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Comparison Content
          Expanded(
            child: provider.comparisonProducts.isEmpty
                ? _buildEmptyState(theme)
                : _buildComparisonContent(theme, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.compare,
            size: 64,
            color: theme.iconTheme.color?.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No products selected for comparison',
            style: TextStyle(
              fontSize: 16,
              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select up to 4 products to compare',
            style: TextStyle(
              fontSize: 14,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonContent(ThemeData theme, EnhancedProductCatalogProvider provider) {
    final products = provider.comparisonProducts;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Product Headers
          Row(
            children: [
              // Feature Column Header
              const SizedBox(
                width: 120,
                child: Text(
                  'Features',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              // Product Headers
              ...products.map((product) => Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: [
                      // Product Image
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(product.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Product Name
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Remove Button
                      IconButton(
                        onPressed: () {
                          provider.toggleComparison(product);
                        },
                        icon: const Icon(Icons.close, size: 16),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
              )),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Comparison Features
          _buildComparisonFeature(
            theme: theme,
            products: products,
            feature: 'Price',
            getValue: (product) => 'Rs. ${product.price.toStringAsFixed(2)}',
            isBetter: (product) => products.every((p) => p.price >= product.price),
          ),
          
          _buildComparisonFeature(
            theme: theme,
            products: products,
            feature: 'Brand',
            getValue: (product) => product.brand,
            isBetter: (product) => false, // No better/worse for brand
          ),
          
          _buildComparisonFeature(
            theme: theme,
            products: products,
            feature: 'Stock',
            getValue: (product) => '${product.stockQuantity} units',
            isBetter: (product) => products.every((p) => p.stockQuantity <= product.stockQuantity),
          ),
          
          _buildComparisonFeature(
            theme: theme,
            products: products,
            feature: 'Rating',
            getValue: (product) => '${product.rating.toStringAsFixed(1)} ⭐',
            isBetter: (product) => products.every((p) => p.rating <= product.rating),
          ),
          
          _buildComparisonFeature(
            theme: theme,
            products: products,
            feature: 'Category',
            getValue: (product) => product.category,
            isBetter: (product) => false,
          ),
          
          _buildComparisonFeature(
            theme: theme,
            products: products,
            feature: 'Manufacturer',
            getValue: (product) => product.manufacturer,
            isBetter: (product) => false,
          ),
          
          _buildComparisonFeature(
            theme: theme,
            products: products,
            feature: 'Expiry Date',
            getValue: (product) => product.expiryDate,
            isBetter: (product) => false,
          ),
          
          _buildComparisonFeature(
            theme: theme,
            products: products,
            feature: 'Description',
            getValue: (product) => product.description,
            isBetter: (product) => false,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonFeature({
    required ThemeData theme,
    required List<Product> products,
    required String feature,
    required String Function(Product) getValue,
    required bool Function(Product) isBetter,
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Feature Name
          SizedBox(
            width: 120,
            child: Text(
              feature,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          
          // Product Values
          ...products.map((product) {
            final value = getValue(product);
            final isBest = isBetter(product);
            
            return Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isBest 
                      ? Colors.green.withOpacity(0.1)
                      : theme.cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isBest 
                        ? Colors.green.withOpacity(0.3)
                        : theme.dividerColor.withOpacity(0.1),
                  ),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isBest ? FontWeight.w600 : FontWeight.normal,
                    color: isBest ? Colors.green : null,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

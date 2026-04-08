import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/enhanced_product_catalog_provider.dart';
import '../widgets/product_comparison_panel.dart';
import '../../domain/models/product_entity.dart';
import '../../../shared/theme/enhanced_app_theme.dart';

/// Product Comparison Screen
/// Dedicated screen for comparing selected products side-by-side
class ProductComparisonScreen extends StatelessWidget {
  const ProductComparisonScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        title: const Text(
          'Product Comparison',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Consumer<EnhancedProductCatalogProvider>(
            builder: (context, provider, _) {
              if (provider.comparisonProducts.isEmpty) {
                return const SizedBox.shrink();
              }
              return TextButton.icon(
                onPressed: () {
                  provider.clearComparison();
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Clear All'),
              );
            },
          ),
        ],
      ),
      body: Consumer<EnhancedProductCatalogProvider>(
        builder: (context, provider, _) {
          if (provider.comparisonProducts.isEmpty) {
            return _buildEmptyState(context, theme);
          }

          return _buildComparisonContent(context, theme, provider);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.compare_arrows,
              size: 64,
              color: theme.iconTheme.color?.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Products to Compare',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Select products from the catalog to compare their features side-by-side. You can compare up to 4 products at once.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.shopping_bag),
            label: const Text('Browse Products'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonContent(
    BuildContext context,
    ThemeData theme,
    EnhancedProductCatalogProvider provider,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Comparison Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor.withOpacity(0.1),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.compare,
                  color: theme.primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Comparing ${provider.comparisonProducts.length} Products',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Select up to 4 products to compare',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                // Add Product Button
                if (provider.comparisonProducts.length < 4)
                  IconButton.outlined(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.add),
                    tooltip: 'Add more products',
                  ),
              ],
            ),
          ),

          // Product Comparison Panel
          ProductComparisonPanel(
            onClose: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

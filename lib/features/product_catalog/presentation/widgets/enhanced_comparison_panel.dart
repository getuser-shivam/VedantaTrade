import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/product_model.dart';
import '../providers/product_catalog_provider.dart';
import 'package:provider/provider.dart';

/// Enhanced Comparison Panel
/// Bottom sheet for comparing selected products
class EnhancedComparisonPanel extends StatefulWidget {
  const EnhancedComparisonPanel({Key? key}) : super(key: key);

  @override
  State<EnhancedComparisonPanel> createState() => _EnhancedComparisonPanelState();
}

class _EnhancedComparisonPanelState extends State<EnhancedComparisonPanel> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ProductCatalogProvider>();
    final comparisonProducts = provider.comparisonProducts;

    if (comparisonProducts.isEmpty) {
      return _buildEmptyState(context, theme);
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _buildHeader(context, theme, provider, comparisonProducts),
              Expanded(
                child: _buildComparisonTable(
                  context,
                  theme,
                  comparisonProducts,
                  scrollController,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    ProductCatalogProvider provider,
    List<Product> products,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Compare Products (${products.length})',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _exportComparison(context, products);
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      provider.clearComparison();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Clear'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonTable(
    BuildContext context,
    ThemeData theme,
    List<Product> products,
    ScrollController scrollController,
  ) {
    return SingleChildScrollView(
      controller: scrollController,
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 16,
          horizontalMargin: 16,
          columns: [
            const DataColumn(label: Text('Feature')),
            ...products.map((product) => DataColumn(
              label: _buildProductHeader(product, theme),
            )),
          ],
          rows: [
            _buildImageRow(products, theme),
            _buildNameRow(products, theme),
            _buildPriceRow(products, theme),
            _buildRatingRow(products, theme),
            _buildStockRow(products, theme),
            _buildCategoryRow(products, theme),
            _buildBrandRow(products, theme),
            _buildManufacturerRow(products, theme),
            _buildDosageFormRow(products, theme),
            _buildStrengthRow(products, theme),
            _buildExpiryRow(products, theme),
            _buildActionRow(products, theme, context),
          ],
        ),
      ),
    );
  }

  Widget _buildProductHeader(Product product, ThemeData theme) {
    return SizedBox(
      width: 200,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: product.images.isNotEmpty
                ? Image.network(
                    product.images.first,
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 80,
                        width: 80,
                        color: theme.colorScheme.surfaceVariant,
                        child: Icon(
                          Icons.medication,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      );
                    },
                  )
                : Container(
                    height: 80,
                    width: 80,
                    color: theme.colorScheme.surfaceVariant,
                    child: Icon(
                      Icons.medication,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            product.name,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              HapticFeedback.lightImpact();
              context.read<ProductCatalogProvider>().toggleComparison(product);
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  DataRow _buildImageRow(List<Product> products, ThemeData theme) {
    return DataRow(
      cells: [
        const DataCell(Text('Image')),
        ...products.map((product) => DataCell(
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: product.images.isNotEmpty
                ? Image.network(
                    product.images.first,
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 60,
                    width: 60,
                    color: theme.colorScheme.surfaceVariant,
                    child: Icon(
                      Icons.medication,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
          ),
        )),
      ],
    );
  }

  DataRow _buildNameRow(List<Product> products, ThemeData theme) {
    return DataRow(
      cells: [
        const DataCell(Text('Name')),
        ...products.map((product) => DataCell(
          Text(
            product.name,
            style: theme.textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        )),
      ],
    );
  }

  DataRow _buildPriceRow(List<Product> products, ThemeData theme) {
    return DataRow(
      cells: [
        const DataCell(Text('Price')),
        ...products.map((product) => DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.formattedPrice,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (product.isOnSale)
                Text(
                  product.formattedOriginalPrice,
                  style: theme.textTheme.bodySmall?.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        )),
      ],
    );
  }

  DataRow _buildRatingRow(List<Product> products, ThemeData theme) {
    return DataRow(
      cells: [
        const DataCell(Text('Rating')),
        ...products.map((product) => DataCell(
          Row(
            children: [
              Icon(Icons.star, size: 16, color: Colors.amber),
              const SizedBox(width: 4),
              Text(product.rating.toStringAsFixed(1)),
            ],
          ),
        )),
      ],
    );
  }

  DataRow _buildStockRow(List<Product> products, ThemeData theme) {
    return DataRow(
      cells: [
        const DataCell(Text('Stock')),
        ...products.map((product) => DataCell(
          _buildStockBadge(product, theme),
        )),
      ],
    );
  }

  DataRow _buildCategoryRow(List<Product> products, ThemeData theme) {
    return DataRow(
      cells: [
        const DataCell(Text('Category')),
        ...products.map((product) => DataCell(
          Text(product.category),
        )),
      ],
    );
  }

  DataRow _buildBrandRow(List<Product> products, ThemeData theme) {
    return DataRow(
      cells: [
        const DataCell(Text('Brand')),
        ...products.map((product) => DataCell(
          Text(product.brand),
        )),
      ],
    );
  }

  DataRow _buildManufacturerRow(List<Product> products, ThemeData theme) {
    return DataRow(
      cells: [
        const DataCell(Text('Manufacturer')),
        ...products.map((product) => DataCell(
          Text(product.manufacturer),
        )),
      ],
    );
  }

  DataRow _buildDosageFormRow(List<Product> products, ThemeData theme) {
    return DataRow(
      cells: [
        const DataCell(Text('Dosage Form')),
        ...products.map((product) => DataCell(
          Text(product.dosageForm),
        )),
      ],
    );
  }

  DataRow _buildStrengthRow(List<Product> products, ThemeData theme) {
    return DataRow(
      cells: [
        const DataCell(Text('Strength')),
        ...products.map((product) => DataCell(
          Text(product.strength),
        )),
      ],
    );
  }

  DataRow _buildExpiryRow(List<Product> products, ThemeData theme) {
    return DataRow(
      cells: [
        const DataCell(Text('Expiry Date')),
        ...products.map((product) => DataCell(
          Text(
            '${product.expiryDate.day}/${product.expiryDate.month}/${product.expiryDate.year}',
          ),
        )),
      ],
    );
  }

  DataRow _buildActionRow(List<Product> products, ThemeData theme, BuildContext context) {
    return DataRow(
      cells: [
        const DataCell(Text('Actions')),
        ...products.map((product) => DataCell(
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  // Add to cart logic
                },
                icon: const Icon(Icons.add_shopping_cart, size: 16),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildStockBadge(Product product, ThemeData theme) {
    final color = product.stockQuantity > 10
        ? Colors.green
        : (product.stockQuantity > 0 ? Colors.orange : Colors.red);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        product.stockStatus,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.compare_arrows,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No products to compare',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Add products to compare by tapping the compare icon',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continue Shopping'),
            ),
          ],
        ),
      ),
    );
  }

  void _exportComparison(BuildContext context, List<Product> products) {
    // Export comparison functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Comparison exported successfully'),
      ),
    );
  }
}

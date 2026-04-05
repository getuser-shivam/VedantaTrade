import 'package:flutter/material.dart';
import '../../../shared/widgets/premium_glassmorphic_theme.dart';
import '../models/product.dart';

class ProductComparisonSheet extends StatelessWidget {
  final List<Product> products;
  final Function(Product)? onProductRemoved;

  const ProductComparisonSheet({
    Key? key,
    required this.products,
    this.onProductRemoved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return PremiumGlassmorphicTheme.glassModal(
          padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingLg),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.compare, color: PremiumGlassmorphicTheme.indigo500),
                  const SizedBox(width: PremiumGlassmorphicTheme.spacingSm),
                  const Text(
                    'Product Comparison',
                    style: TextStyle(
                      color: PremiumGlassmorphicTheme.textPrimary,
                      fontSize: PremiumGlassmorphicTheme.fontSizeXl,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: PremiumGlassmorphicTheme.textSecondary,
                  ),
                ],
              ),
              
              const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
              
              // Comparison Table
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: _buildComparisonTable(),
                ),
              ),
              
              const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: PremiumGlassmorphicTheme.glassButton(
                      onPressed: _exportComparison,
                      child: const Text('Export'),
                    ),
                  ),
                  const SizedBox(width: PremiumGlassmorphicTheme.spacingMd),
                  Expanded(
                    child: PremiumGlassmorphicTheme.glassButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildComparisonTable() {
    return PremiumGlassmorphicTheme.glassCard(
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingMd),
      child: Table(
        columnWidths: {
          0: const FlexColumnWidth(1.5), // Feature
          1: const FlexColumnWidth(1),   // Product 1
          2: const FlexColumnWidth(1),   // Product 2
          3: const FlexColumnWidth(1),   // Product 3
        },
        children: [
          // Header Row
          TableRow(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: PremiumGlassmorphicTheme.borderMedium,
                  width: 1,
                ),
              ),
            ),
            children: [
              _buildHeaderCell('Feature'),
              ...products.map((product) => _buildProductHeaderCell(product)),
            ],
          ),
          
          // Product Name Row
          _buildFeatureRow(
            'Name',
            products.map((p) => Text(p.name)).toList(),
            isHeader: true,
          ),
          
          // Price Row
          _buildFeatureRow(
            'Price',
            products.map((p) => Text(p.formattedPrice)).toList(),
          ),
          
          // Category Row
          _buildFeatureRow(
            'Category',
            products.map((p) => Text(p.category)).toList(),
          ),
          
          // Manufacturer Row
          _buildFeatureRow(
            'Manufacturer',
            products.map((p) => Text(p.manufacturer)).toList(),
          ),
          
          // Form Row
          _buildFeatureRow(
            'Form',
            products.map((p) => Text(p.form)).toList(),
          ),
          
          // Dosage Row
          _buildFeatureRow(
            'Dosage',
            products.map((p) => Text(p.dosage)).toList(),
          ),
          
          // Stock Row
          _buildFeatureRow(
            'Stock',
            products.map((p) => Text('${p.stockQuantity}')).toList(),
          ),
          
          // Rating Row
          _buildFeatureRow(
            'Rating',
            products.map((p) => Text('${p.rating}/5.0')).toList(),
          ),
          
          // Reviews Row
          _buildFeatureRow(
            'Reviews',
            products.map((p) => Text('${p.reviewCount}')).toList(),
          ),
          
          // Ingredients Row
          _buildFeatureRow(
            'Ingredients',
            products.map((p) => Text(p.ingredients.join(', '))).toList(),
          ),
          
          // Side Effects Row
          _buildFeatureRow(
            'Side Effects',
            products.map((p) => Text(p.sideEffects.join(', '))).toList(),
          ),
          
          // Contraindications Row
          _buildFeatureRow(
            'Contraindications',
            products.map((p) => Text(p.contraindications.join(', '))).toList(),
          ),
          
          // Storage Row
          _buildFeatureRow(
            'Storage',
            products.map((p) => Text(p.storageConditions)).toList(),
          ),
          
          // Expiry Row
          _buildFeatureRow(
            'Expiry',
            products.map((p) => Text(p.expiryDate)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingSm),
      child: Text(
        text,
        style: const TextStyle(
          color: PremiumGlassmorphicTheme.textPrimary,
          fontSize: PremiumGlassmorphicTheme.fontSizeSm,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildProductHeaderCell(Product product) {
    return Padding(
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingSm),
      child: Column(
        children: [
          Text(
            product.name,
            style: const TextStyle(
              color: PremiumGlassmorphicTheme.textPrimary,
              fontSize: PremiumGlassmorphicTheme.fontSizeSm,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          if (onProductRemoved != null) ...[
            const SizedBox(height: PremiumGlassmorphicTheme.spacingXs),
            GestureDetector(
              onTap: () => onProductRemoved!(product),
              child: const Icon(
                Icons.remove_circle_outline,
                color: PremiumGlassmorphicTheme.error,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  TableRow _buildFeatureRow(
    String feature,
    List<Widget> values, {
    bool isHeader = false,
  }) {
    return TableRow(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: PremiumGlassmorphicTheme.borderLight,
            width: 0.5,
          ),
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingSm),
          child: Text(
            feature,
            style: TextStyle(
              color: isHeader 
                  ? PremiumGlassmorphicTheme.textPrimary
                  : PremiumGlassmorphicTheme.textSecondary,
              fontSize: PremiumGlassmorphicTheme.fontSizeSm,
              fontWeight: isHeader ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
        ...values.map((value) => Padding(
          padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingSm),
          child: value,
        )),
      ],
    );
  }

  void _exportComparison() {
    
    // Export to PDF, Excel, or share as text
  }
}

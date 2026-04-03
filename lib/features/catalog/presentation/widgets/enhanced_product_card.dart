import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../shared/widgets/premium_glassmorphic_theme.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final bool isSelected;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onSelectionChanged;

  const ProductCard({
    Key? key,
    required this.product,
    this.isSelected = false,
    this.onTap,
    this.onSelectionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumGlassmorphicTheme.glassCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image Section
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(PremiumGlassmorphicTheme.radiusMd),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: PremiumGlassmorphicTheme.surfaceLight.withOpacity(0.3),
                      child: const Center(
                        child: PremiumGlassmorphicTheme.glassLoading(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: PremiumGlassmorphicTheme.surfaceLight.withOpacity(0.3),
                      child: const Center(
                        child: Icon(
                          Icons.medication,
                          color: PremiumGlassmorphicTheme.textTertiary,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Selection Checkbox
                if (onSelectionChanged != null)
                  Positioned(
                    top: PremiumGlassmorphicTheme.spacingSm,
                    right: PremiumGlassmorphicTheme.spacingSm,
                    child: GestureDetector(
                      onTap: () => onSelectionChanged!(!isSelected),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? PremiumGlassmorphicTheme.indigo600
                              : PremiumGlassmorphicTheme.surfaceDark.withOpacity(0.8),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected 
                                ? PremiumGlassmorphicTheme.indigo400
                                : PremiumGlassmorphicTheme.borderMedium,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          isSelected ? Icons.check : Icons.add,
                          color: PremiumGlassmorphicTheme.textPrimary,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                
                // Stock Status Badge
                Positioned(
                  bottom: PremiumGlassmorphicTheme.spacingSm,
                  left: PremiumGlassmorphicTheme.spacingSm,
                  child: _buildStockBadge(),
                ),
                
                // Discount Badge
                if (product.hasDiscount)
                  Positioned(
                    top: PremiumGlassmorphicTheme.spacingSm,
                    left: PremiumGlassmorphicTheme.spacingSm,
                    child: _buildDiscountBadge(),
                  ),
              ],
            ),
          ),
          
          // Product Information Section
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product.name,
                    style: const TextStyle(
                      color: PremiumGlassmorphicTheme.textPrimary,
                      fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: PremiumGlassmorphicTheme.spacingXs),
                  
                  // Category and Manufacturer
                  Text(
                    '${product.category} • ${product.manufacturer}',
                    style: const TextStyle(
                      color: PremiumGlassmorphicTheme.textTertiary,
                      fontSize: PremiumGlassmorphicTheme.fontSizeXs,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const Spacer(),
                  
                  // Price Section
                  Row(
                    children: [
                      if (product.hasDiscount) ...[
                        Text(
                          product.originalPrice,
                          style: const TextStyle(
                            color: PremiumGlassmorphicTheme.textTertiary,
                            fontSize: PremiumGlassmorphicTheme.fontSizeXs,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: PremiumGlassmorphicTheme.spacingXs),
                      ],
                      Text(
                        product.formattedPrice,
                        style: const TextStyle(
                          color: PremiumGlassmorphicTheme.indigo500,
                          fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  
                  // Rating
                  if (product.rating > 0) ...[
                    const SizedBox(height: PremiumGlassmorphicTheme.spacingXs),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: PremiumGlassmorphicTheme.textSecondary,
                            fontSize: PremiumGlassmorphicTheme.fontSizeXs,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${product.reviewCount})',
                          style: const TextStyle(
                            color: PremiumGlassmorphicTheme.textTertiary,
                            fontSize: PremiumGlassmorphicTheme.fontSizeXs,
                          ),
                        ),
                      ],
                    ),
                  ],
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
    
    if (product.stockQuantity == 0) {
      badgeColor = PremiumGlassmorphicTheme.error;
      badgeText = 'Out of Stock';
    } else if (product.isLowStock) {
      badgeColor = PremiumGlassmorphicTheme.warning;
      badgeText = 'Low Stock';
    } else {
      badgeColor = PremiumGlassmorphicTheme.success;
      badgeText = 'In Stock';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PremiumGlassmorphicTheme.spacingXs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(PremiumGlassmorphicTheme.radiusXs),
      ),
      child: Text(
        badgeText,
        style: const TextStyle(
          color: PremiumGlassmorphicTheme.textPrimary,
          fontSize: PremiumGlassmorphicTheme.fontSizeXs,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDiscountBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PremiumGlassmorphicTheme.spacingXs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: PremiumGlassmorphicTheme.error.withOpacity(0.9),
        borderRadius: BorderRadius.circular(PremiumGlassmorphicTheme.radiusXs),
      ),
      child: Text(
        '-${product.discountPercentage}%',
        style: const TextStyle(
          color: PremiumGlassmorphicTheme.textPrimary,
          fontSize: PremiumGlassmorphicTheme.fontSizeXs,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

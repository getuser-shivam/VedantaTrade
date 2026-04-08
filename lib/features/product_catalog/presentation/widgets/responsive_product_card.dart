import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/product_model.dart';
import '../providers/product_catalog_provider.dart';
import 'package:provider/provider.dart';

/// Responsive Product Card
/// Adapts its layout based on screen size and card variant
class ResponsiveProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onCompare;
  final VoidCallback? onAddToCart;
  final ProductCardVariant variant;
  final bool showQuickActions;
  final bool showStockIndicator;

  const ResponsiveProductCard({
    Key? key,
    required this.product,
    required this.onTap,
    this.onFavorite,
    this.onCompare,
    this.onAddToCart,
    this.variant = ProductCardVariant.auto,
    this.showQuickActions = true,
    this.showStockIndicator = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    final isDesktop = screenWidth >= 1200;

    ProductCardVariant effectiveVariant = variant;
    if (variant == ProductCardVariant.auto) {
      effectiveVariant = isMobile
          ? ProductCardVariant.compact
          : (isTablet ? ProductCardVariant.standard : ProductCardVariant.detailed);
    }

    switch (effectiveVariant) {
      case ProductCardVariant.compact:
        return _CompactProductCard(
          product: product,
          onTap: onTap,
          onFavorite: onFavorite,
          onCompare: onCompare,
          showStockIndicator: showStockIndicator,
        );
      case ProductCardVariant.standard:
        return _StandardProductCard(
          product: product,
          onTap: onTap,
          onFavorite: onFavorite,
          onCompare: onCompare,
          onAddToCart: onAddToCart,
          showQuickActions: showQuickActions,
          showStockIndicator: showStockIndicator,
        );
      case ProductCardVariant.detailed:
        return _DetailedProductCard(
          product: product,
          onTap: onTap,
          onFavorite: onFavorite,
          onCompare: onCompare,
          onAddToCart: onAddToCart,
          showQuickActions: showQuickActions,
          showStockIndicator: showStockIndicator,
        );
    }
  }
}

/// Compact Product Card (Mobile)
class _CompactProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onCompare;
  final bool showStockIndicator;

  const _CompactProductCard({
    required this.product,
    required this.onTap,
    this.onFavorite,
    this.onCompare,
    this.showStockIndicator = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ProductCatalogProvider>();
    final isFavorite = provider.isFavorite(product.id);

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: product.images.isNotEmpty
                        ? Image.network(
                            product.images.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.medication,
                                size: 40,
                                color: theme.colorScheme.onSurfaceVariant,
                              );
                            },
                          )
                        : Icon(
                            Icons.medication,
                            size: 40,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                  ),
                  if (product.isOnSale)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.formattedDiscount,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (onFavorite != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 20,
                          color: isFavorite ? Colors.red : Colors.white,
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          onFavorite!();
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                ],
              ),
            ),
            // Content
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (showStockIndicator)
                      _buildStockIndicator(theme),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.formattedPrice,
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        if (onCompare != null)
                          IconButton(
                            icon: Icon(
                              Icons.compare_arrows,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            onPressed: onCompare,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockIndicator(ThemeData theme) {
    final stockStatus = product.stockStatus;
    final color = product.stockQuantity > 0
        ? Colors.green
        : Colors.red;

    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          stockStatus,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

/// Standard Product Card (Tablet)
class _StandardProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onCompare;
  final VoidCallback? onAddToCart;
  final bool showQuickActions;
  final bool showStockIndicator;

  const _StandardProductCard({
    required this.product,
    required this.onTap,
    this.onFavorite,
    this.onCompare,
    this.onAddToCart,
    this.showQuickActions = true,
    this.showStockIndicator = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ProductCatalogProvider>();
    final isFavorite = provider.isFavorite(product.id);

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: product.images.isNotEmpty
                        ? Image.network(
                            product.images.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.medication,
                                size: 48,
                                color: theme.colorScheme.onSurfaceVariant,
                              );
                            },
                          )
                        : Icon(
                            Icons.medication,
                            size: 48,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                  ),
                  if (product.isOnSale)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          product.formattedDiscount,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (showQuickActions)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Row(
                        children: [
                          if (onFavorite != null)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  size: 20,
                                  color: isFavorite ? Colors.red : Colors.grey,
                                ),
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  onFavorite!();
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ),
                          if (onCompare != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.compare_arrows,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                                onPressed: onCompare,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
            // Content
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.genericName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if (showStockIndicator)
                      _buildStockIndicator(theme),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.formattedPrice,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
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
                        if (onAddToCart != null)
                          ElevatedButton(
                            onPressed: onAddToCart,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Icon(Icons.add_shopping_cart, size: 18),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockIndicator(ThemeData theme) {
    final stockStatus = product.stockStatus;
    final color = product.stockQuantity > 10
        ? Colors.green
        : (product.stockQuantity > 0 ? Colors.orange : Colors.red);

    return Row(
      children: [
        Icon(
          Icons.inventory_2,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          stockStatus,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Detailed Product Card (Desktop)
class _DetailedProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onCompare;
  final VoidCallback? onAddToCart;
  final bool showQuickActions;
  final bool showStockIndicator;

  const _DetailedProductCard({
    required this.product,
    required this.onTap,
    this.onFavorite,
    this.onCompare,
    this.onAddToCart,
    this.showQuickActions = true,
    this.showStockIndicator = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ProductCatalogProvider>();
    final isFavorite = provider.isFavorite(product.id);

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(20),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: product.images.isNotEmpty
                        ? Image.network(
                            product.images.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.medication,
                                size: 56,
                                color: theme.colorScheme.onSurfaceVariant,
                              );
                            },
                          )
                        : Icon(
                            Icons.medication,
                            size: 56,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                  ),
                  if (product.isOnSale)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          product.formattedDiscount,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (showQuickActions)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Row(
                        children: [
                          if (onFavorite != null)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  size: 22,
                                  color: isFavorite ? Colors.red : Colors.grey,
                                ),
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  onFavorite!();
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ),
                          if (onCompare != null) ...[
                            const SizedBox(width: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.compare_arrows,
                                  size: 22,
                                  color: Colors.grey,
                                ),
                                onPressed: onCompare,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
            // Content
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.genericName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${product.reviewCount} reviews)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (showStockIndicator)
                      _buildStockIndicator(theme),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.formattedPrice,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            if (product.isOnSale)
                              Text(
                                product.formattedOriginalPrice,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                        if (onAddToCart != null)
                          ElevatedButton.icon(
                            onPressed: onAddToCart,
                            icon: const Icon(Icons.add_shopping_cart),
                            label: const Text('Add'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockIndicator(ThemeData theme) {
    final stockStatus = product.stockStatus;
    final color = product.stockQuantity > 10
        ? Colors.green
        : (product.stockQuantity > 0 ? Colors.orange : Colors.red);

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
}

/// Product Card Variant
enum ProductCardVariant {
  auto,
  compact,
  standard,
  detailed,
}

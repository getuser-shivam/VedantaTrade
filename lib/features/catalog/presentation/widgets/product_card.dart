import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../shared/widgets/glassmorphic_widgets.dart';
import '../models/product.dart';
import '../../cart/presentation/providers/cart_provider.dart';
import '../../wishlist/presentation/providers/wishlist_provider.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final bool isSelected;
  final ValueChanged<bool>? onSelectionChanged;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onTap,
    this.isSelected = false,
    this.onSelectionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<CartProvider, WishlistProvider>(
      builder: (context, cartProvider, wishlistProvider, child) {
        final isInWishlist = wishlistProvider.isInWishlist(product.id);
        final isInCart = cartProvider.isInCart(product.id);

        return GlassmorphicCard(
          padding: EdgeInsets.zero,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section
                Expanded(
                  flex: 5,
                  child: Stack(
                    children: [
                      // Product Image
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: CachedNetworkImage(
                            imageUrl: product.firstImage,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                              ),
                            ),
                            errorWidget: (context, url, error) => Center(
                              child: Icon(
                                Icons.medication_liquid_outlined,
                                size: 40,
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Badges
                      if (product.featured)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: _buildBadge('Featured', Colors.orange),
                        ),
                        
                      if (product.isLowStock)
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: _buildBadge('Low Stock', Colors.redAccent),
                        ),

                      // Wishlist Button
                      Positioned(
                        top: 8,
                        left: 8,
                        child: GestureDetector(
                          onTap: () => wishlistProvider.toggleWishlist(product.id),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Icon(
                              isInWishlist ? Icons.favorite : Icons.favorite_border,
                              size: 16,
                              color: isInWishlist ? Colors.red : Colors.white70,
                            ),
                          ),
                        ),
                      ),

                      // Selection Overlay (if enabled)
                      if (onSelectionChanged != null)
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => onSelectionChanged!(!isSelected),
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? Colors.blue : Colors.black26,
                                border: Border.all(color: Colors.white24),
                              ),
                              child: isSelected 
                                ? const Icon(Icons.check, size: 14, color: Colors.white) 
                                : null,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Info Section
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        const SizedBox(height: 2),
                        Text(
                          product.category,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 11,
                          ),
                        ),
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
                                    color: Theme.of(context).colorScheme.primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  product.packaging,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.3),
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                            
                            // Add to Cart / Quantity Selector
                            GestureDetector(
                              onTap: () {
                                cartProvider.addToCart(product);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${product.name} added to cart'),
                                    backgroundColor: Colors.green,
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isInCart 
                                    ? Colors.green.withOpacity(0.2) 
                                    : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isInCart ? Colors.green : Theme.of(context).colorScheme.primary,
                                    width: 0.5,
                                  ),
                                ),
                                child: Icon(
                                  isInCart ? Icons.shopping_cart : Icons.add_shopping_cart,
                                  size: 16,
                                  color: isInCart ? Colors.green : Theme.of(context).colorScheme.primary,
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
      },
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.85),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

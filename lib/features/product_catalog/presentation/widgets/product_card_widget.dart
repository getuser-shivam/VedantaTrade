import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/models/product_entity.dart';

class ProductCardWidget extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;
  final double? width;
  final double? height;

  const ProductCardWidget({
    Key? key,
    required this.product,
    this.onTap,
    this.onFavorite,
    this.isFavorite = false,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: width ?? 200,
          height: height ?? 280,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[100],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: product.images.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: product.images.first,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Icon(Icons.error, color: Colors.grey),
                                  ),
                                ),
                              )
                            : Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(Icons.image_not_supported, color: Colors.grey),
                                ),
                              ),
                      ),
                    ),
                    // Discount Badge
                    if (product.hasDiscount)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${product.discountPercentage.toStringAsFixed(0)}% OFF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    // Favorite Button
                    if (onFavorite != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: GestureDetector(
                          onTap: () => onFavorite!(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: const CircleBorder(),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey[600],
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Product Info
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Category and Manufacturer
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            product.category,
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          product.manufacturer,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Price
                    Row(
                      children: [
                        if (product.hasDiscount) ...[
                          Text(
                            product.formattedOriginalPrice,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          product.formattedPrice,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Stock Status
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2,
                          size: 16,
                          color: product.isLowStock ? Colors.orange : Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          product.stockStatus,
                          style: TextStyle(
                            fontSize: 12,
                            color: product.isLowStock ? Colors.orange : Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        // Expiry Status
                        if (product.isExpiringSoon)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  product.expiryStatus,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Tags
                    if (product.tags.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: product.tags.take(3).map((tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black54,
                            ),
                          ),
                        )).toList(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

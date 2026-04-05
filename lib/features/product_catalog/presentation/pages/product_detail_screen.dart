import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/product_provider.dart';
import '../domain/models/product_entity.dart';
import '../widgets/product_card_widget.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductEntity product;

  const ProductDetailScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedImageIndex = 0;
  bool _isFavorite = false;
  int _quantity = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    // Would check with provider
    setState(() {
      _isFavorite = false; // Mock implementation
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareProduct,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Images
            _buildProductImages(),
            const SizedBox(height: 24),
            // Product Info
            _buildProductInfo(context),
            const SizedBox(height: 24),
            // Specifications
            _buildSpecifications(),
            const SizedBox(height: 24),
            // Pricing and Stock
            _buildPricingAndStock(context),
            const SizedBox(height: 24),
            // Action Buttons
            _buildActionButtons(context),
            const SizedBox(height: 24),
            // Related Products
            _buildRelatedProducts(context),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildProductImages() {
    return Container(
      height: 300,
      child: PageView.builder(
        itemCount: product.images.length,
        onPageChanged: (index) {
          setState(() {
            _selectedImageIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return CachedNetworkImage(
            imageUrl: product.images[index],
            fit: BoxFit.contain,
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
          );
        },
      ),
    );
  }

  Widget _buildProductInfo(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product Information',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Category', product.category),
            _buildInfoRow('Manufacturer', product.manufacturer),
            _buildInfoRow('SKU', product.sku),
            _buildInfoRow('Unit', product.unit),
            if (product.dosageForm != null)
              _buildInfoRow('Dosage Form', product.dosageForm!),
            if (product.strength != null)
              _buildInfoRow('Strength', product.strength!),
            if (product.prescriptionRequired != null)
              _buildInfoRow('Prescription Required', product.prescriptionRequired!),
            if (product.batchNumber != null)
              _buildInfoRow('Batch Number', product.batchNumber!),
            if (product.expiryDate != null)
              _buildInfoRow('Expiry Date', 
                  '${product.expiryDate!.day}/${product.expiryDate!.month}/${product.expiryDate!.year}'),
            if (product.storageConditions != null)
              _buildInfoRow('Storage Conditions', product.storageConditions!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecifications() {
    if (product.specifications.isEmpty) return const SizedBox.shrink();
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Specifications',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ...product.specifications.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      '${entry.key}:',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingAndStock(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pricing & Stock Information',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            // Price Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  if (product.hasDiscount) ...[
                    Text(
                      product.formattedOriginalPrice,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    product.formattedPrice,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  if (product.hasDiscount) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${product.discountPercentage.toStringAsFixed(0)}% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Stock Information
            Row(
              children: [
                Icon(
                  Icons.inventory_2,
                  color: product.isLowStock ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  'Stock: ${product.stockQuantity} ${product.unit}',
                  style: TextStyle(
                    color: product.isLowStock ? Colors.orange : Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (product.isExpiringSoon)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Expiring Soon',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Minimum Order Quantity
            Row(
              children: [
                Icon(
                  Icons.shopping_cart,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  'Minimum Order: ${product.minOrderQuantity} ${product.unit}',
                  style: const TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            // Quantity Selector
            Row(
              children: [
                Text(
                  'Quantity:',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () {
                    if (_quantity > 1) {
                      setState(() {
                        _quantity--;
                      });
                    }
                  },
                  icon: const Icon(Icons.remove),
                ),
                Container(
                  width: 60,
                  alignment: Alignment.center,
                  child: Text(
                    '$_quantity',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _quantity++;
                    });
                  },
                  icon: const Icon(Icons.add),
                ),
                const Spacer(),
                Text(
                  'Total: ${product.currency} ${(product.effectivePrice * _quantity).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _addToCart(),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.shopping_cart),
                    label: Text(_isLoading ? 'Adding...' : 'Add to Cart'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _addToWishlist(),
                    icon: const Icon(Icons.favorite_border),
                    label: const Text('Add to Wishlist'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                      side: BorderSide(color: Theme.of(context).primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedProducts(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Related Products',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            // Related products would be loaded from provider
            Container(
              height: 200,
              child: const Center(
                child: Text('Related products will be shown here'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _addToCart(),
              icon: const Icon(Icons.shopping_cart),
              label: const Text('Add to Cart'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    // Would call provider.toggleFavorite(product.id)
  }

  void _shareProduct() {
    // Implement share functionality
  }

  void _addToCart() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Implement add to cart logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product added to cart successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add product to cart: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addToWishlist() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Product added to wishlist'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

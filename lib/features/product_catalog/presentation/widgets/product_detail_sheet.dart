import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/product_model.dart';

class ProductDetailSheet extends StatelessWidget {
  final Product product;

  const ProductDetailSheet({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Product image and basic info
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product image with badges
                        Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey.shade100,
                              ),
                              child: product.imageUrl.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: CachedNetworkImage(
                                        imageUrl: product.imageUrl,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(
                                          color: Colors.grey.shade200,
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) => Container(
                                          color: Colors.grey.shade200,
                                          child: const Icon(
                                            Icons.medication,
                                            size: 64,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    )
                                  : const Center(
                                      child: Icon(
                                        Icons.medication,
                                        size: 64,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),
                            
                            // Status badges
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (product.isExpired)
                                    _buildStatusBadge('Expired', Colors.red, Icons.warning),
                                  if (product.isExpiringSoon && !product.isExpired)
                                    _buildStatusBadge('Expiring Soon', Colors.orange, Icons.schedule),
                                  if (product.isLowStock && !product.isExpired)
                                    _buildStatusBadge('Low Stock', Colors.amber, Icons.inventory_2),
                                ],
                              ),
                            ),
                            
                            // Prescription badge
                            if (product.requiresPrescription)
                              Positioned(
                                top: 8,
                                left: 8,
                                child: _buildStatusBadge('Rx Required', Colors.blue, Icons.medication),
                              ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Product name and rating
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product.genericName,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.grey.shade600,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star, color: Colors.amber, size: 20),
                                    const SizedBox(width: 4),
                                    Text(
                                      product.rating.toStringAsFixed(1),
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '(${product.reviewCount} reviews)',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Price and stock information
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (product.discountPercentage > 0) ...[
                                      Text(
                                        'NPR ${product.price.toStringAsFixed(2)}',
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          color: Colors.grey.shade600,
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      ),
                                      Text(
                                        'NPR ${product.discountedPrice.toStringAsFixed(2)}',
                                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                          color: Colors.red.shade600,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ] else
                                      Text(
                                        'NPR ${product.price.toStringAsFixed(2)}',
                                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                          color: Colors.green.shade600,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    
                                    if (product.discountPercentage > 0) ...[
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '${product.discountPercentage}% OFF',
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
                              ),
                              
                              const SizedBox(width: 16),
                              
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Stock',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    '${product.stockQuantity} units',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: product.isLowStock ? Colors.red : Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Product details
                        _buildDetailSection(
                          context,
                          'Product Details',
                          [
                            _buildDetailRow('Manufacturer', product.manufacturer),
                            _buildDetailRow('Category', product.category),
                            _buildDetailRow('Dosage Form', product.dosageForm),
                            _buildDetailRow('Strength', product.strength),
                            _buildDetailRow('Batch Number', product.batchNumber),
                            _buildDetailRow('Expiry Date', 
                                '${product.expiryDate.day}/${product.expiryDate.month}/${product.expiryDate.year}'),
                            _buildDetailRow('Storage', product.storageConditions),
                            _buildDetailRow('Regulatory Status', product.regulatoryStatus),
                            if (product.ndcNumber.isNotEmpty)
                              _buildDetailRow('NDC Number', product.ndcNumber),
                            if (product.irdNumber.isNotEmpty)
                              _buildDetailRow('IRD Number', product.irdNumber),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Description
                        _buildDetailSection(
                          context,
                          'Description',
                          [
                            Text(
                              product.description,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Indications
                        if (product.indications.isNotEmpty)
                          _buildDetailSection(
                            context,
                            'Indications',
                            product.indications
                                .map((indication) => Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            size: 16,
                                            color: Colors.green.shade600,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              indication,
                                              style: Theme.of(context).textTheme.bodyMedium,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                        
                        const SizedBox(height: 16),
                        
                        // Contraindications
                        if (product.contraindications.isNotEmpty)
                          _buildDetailSection(
                            context,
                            'Contraindications',
                            product.contraindications
                                .map((contraindication) => Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.warning,
                                            size: 16,
                                            color: Colors.red.shade600,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              contraindication,
                                              style: Theme.of(context).textTheme.bodyMedium,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                        
                        const SizedBox(height: 16),
                        
                        // Side Effects
                        if (product.sideEffects.isNotEmpty)
                          _buildDetailSection(
                            context,
                            'Side Effects',
                            product.sideEffects
                                .map((sideEffect) => Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            size: 16,
                                            color: Colors.orange.shade600,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              sideEffect,
                                              style: Theme.of(context).textTheme.bodyMedium,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                        
                        const SizedBox(height: 16),
                        
                        // Tags
                        if (product.tags.isNotEmpty)
                          _buildDetailSection(
                            context,
                            'Tags',
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: product.tags
                                  .map((tag) => Chip(
                                        label: Text(tag),
                                        backgroundColor: Colors.blue.shade100,
                                        labelStyle: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontSize: 12,
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        
                        const SizedBox(height: 100), // Extra space for bottom buttons
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
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
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

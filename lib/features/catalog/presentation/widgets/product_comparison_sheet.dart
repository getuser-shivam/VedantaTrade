import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_theme.dart';
import '../../domain/entities/product_entity.dart';

class ProductComparisonSheet extends StatefulWidget {
  final List<ProductEntity> products;
  final ScrollController scrollController;

  const ProductComparisonSheet({
    Key? key,
    required this.products,
    required this.scrollController,
  }) : super(key: key);

  @override
  State<ProductComparisonSheet> createState() => _ProductComparisonSheetState();
}

class _ProductComparisonSheetState extends State<ProductComparisonSheet> {
  int _selectedProductIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.products.length < 2) {
      return Container(
        height: 200,
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.glassColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.glassBorderColor),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: AppTheme.errorColor,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Select at least 2 products to compare',
                style: TextStyle(
                  color: AppTheme.textPrimaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.glassColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.glassBorderColor),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppTheme.glassBorderColor),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Compare Products',
                  style: TextStyle(
                    color: AppTheme.textPrimaryColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          
          // Product selector tabs
          Container(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.products.length,
              itemBuilder: (context, index) {
                final product = widget.products[index];
                final isSelected = index == _selectedProductIndex;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedProductIndex = index;
                    });
                    HapticFeedback.selectionClick();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected 
                              ? AppTheme.primaryColor.withOpacity(0.2)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                                ? AppTheme.primaryColor
                                : AppTheme.glassBorderColor,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(
                            color: isSelected 
                                    ? AppTheme.primaryColor
                                    : AppTheme.textPrimaryColor,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'NPR ${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: isSelected 
                                    ? AppTheme.primaryColor
                                    : AppTheme.textSecondaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Comparison content
          Expanded(
            child: _buildComparisonContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonContent() {
    final product1 = widget.products[_selectedProductIndex];
    final product2 = widget.products[(_selectedProductIndex + 1) % widget.products.length];
    
    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Product images
          Row(
            children: [
              Expanded(
                child: _buildProductImage(product1, 'Product 1'),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildProductImage(product2, 'Product 2'),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Comparison table
          _buildComparisonTable(product1, product2),
        ],
      ),
    );
  }

  Widget _buildProductImage(ProductEntity product, String label) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondaryColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppTheme.glassColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.glassBorderColor),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: product.firstImage.isNotEmpty
                ? Image.network(
                    product.firstImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[600],
                        ),
                      );
                    },
                  )
                : Container(
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[600],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonTable(ProductEntity product1, ProductEntity product2) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.glassColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.glassBorderColor),
      ),
      child: Column(
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Feature',
                    style: TextStyle(
                      color: AppTheme.textPrimaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    product1.name,
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    product2.name,
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          
          // Table rows
          _buildComparisonRow('Category', product1.category, product2.category),
          _buildComparisonRow('Price', 'NPR ${product1.price.toStringAsFixed(2)}', 'NPR ${product2.price.toStringAsFixed(2)}'),
          _buildComparisonRow('Form', product1.form, product2.form),
          _buildComparisonRow('Dosage', product1.dosage, product2.dosage),
          _buildComparisonRow('Packaging', product1.packaging, product2.packaging),
          _buildComparisonRow('Manufacturer', product1.manufacturer, product2.manufacturer),
          _buildComparisonRow('Stock', '${product1.stockQuantity}', '${product2.stockQuantity}'),
          _buildComparisonRow('Status', product1.isActive ? 'Active' : 'Inactive', product2.isActive ? 'Active' : 'Inactive'),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String feature, String value1, String value2) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.glassBorderColor.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature,
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value1,
              style: TextStyle(
                color: AppTheme.textPrimaryColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value2,
              style: TextStyle(
                color: AppTheme.textPrimaryColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

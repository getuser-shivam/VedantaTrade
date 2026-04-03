import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../shared/widgets/glassmorphic_widgets.dart';
import '../models/product.dart';

class ProductComparisonSheet extends StatelessWidget {
  final List<Product> products;
  final Function(Product) onProductRemoved;

  const ProductComparisonSheet({
    Key? key,
    required this.products,
    required this.onProductRemoved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Compare Products (${products.length})',
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: products.length < 2
                ? _buildEmptyState()
                : _buildComparisonList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'Add at least 2 products to compare features',
        style: TextStyle(color: Colors.white54),
      ),
    );
  }

  Widget _buildComparisonList(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildFeatureRow('Product', products.map((p) => _buildProductHeader(p)).toList(), isHeader: true),
          const Divider(color: Colors.white10),
          _buildFeatureRow('Price', products.map((p) => Text(p.formattedPrice, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold))).toList()),
          _buildFeatureRow('Category', products.map((p) => Text(p.category, style: const TextStyle(color: Colors.white70))).toList()),
          _buildFeatureRow('Manufacturer', products.map((p) => Text(p.manufacturer, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center)).toList()),
          _buildFeatureRow('Form', products.map((p) => Text(p.form, style: const TextStyle(color: Colors.white70))).toList()),
          _buildFeatureRow('Dosage', products.map((p) => Text(p.dosage, style: const TextStyle(color: Colors.white70))).toList()),
          _buildFeatureRow('Stock', products.map((p) => Text('${p.stockQuantity}', style: TextStyle(color: p.isLowStock ? Colors.orange : Colors.green))).toList()),
          _buildFeatureRow('Ingredients', products.map((p) => Text(p.ingredients.join(', '), style: const TextStyle(color: Colors.white38, fontSize: 10), textAlign: TextAlign.center)).toList()),
        ],
      ),
    );
  }

  Widget _buildProductHeader(Product product) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: product.firstImage,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) => Container(color: Colors.white05, child: const Icon(Icons.medication, color: Colors.blueAccent)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.name,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
        IconButton(
          onPressed: () => onProductRemoved(product),
          icon: const Icon(Icons.remove_circle, color: Colors.redAccent, size: 20),
        ),
      ],
    );
  }

  Widget _buildFeatureRow(String feature, List<Widget> values, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              feature,
              style: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          ...values.map((v) => Expanded(child: Center(child: v))),
        ],
      ),
    );
  }
}

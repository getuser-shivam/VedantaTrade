import 'package:flutter/material.dart';
import '../../../../shared/widgets/premium_glassmorphic_theme.dart';
import '../../data/models/checkout_models.dart';

class CheckoutSummaryWidget extends StatelessWidget {
  final List<CheckoutItem> items;
  final double subtotal;
  final double discountAmount;
  final double vatAmount;
  final double deliveryFee;
  final double totalAmount;

  const CheckoutSummaryWidget({
    Key? key,
    required this.items,
    required this.subtotal,
    required this.discountAmount,
    required this.vatAmount,
    required this.deliveryFee,
    required this.totalAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              color: PremiumGlassmorphicTheme.primaryColor.withOpacity(0.1),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  color: PremiumGlassmorphicTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: PremiumGlassmorphicTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: PremiumGlassmorphicTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${items.length} Items',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Items List
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...items.map((item) => _buildItemRow(item)),
                const SizedBox(height: 16),
                
                // Divider
                Divider(color: Colors.grey[300]),
                const SizedBox(height: 16),
                
                // Price Breakdown
                _buildPriceBreakdown(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(CheckoutItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image Placeholder
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: Icon(
              Icons.medication_outlined,
              color: Colors.grey[400],
              size: 24,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: PremiumGlassmorphicTheme.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.brand} • ${item.category}',
                  style: TextStyle(
                    fontSize: 12,
                    color: PremiumGlassmorphicTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Qty: ${item.quantity}',
                      style: TextStyle(
                        fontSize: 12,
                        color: PremiumGlassmorphicTheme.textSecondary,
                      ),
                    ),
                    if (item.batchNumber != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        'Batch: ${item.batchNumber}',
                        style: TextStyle(
                          fontSize: 12,
                          color: PremiumGlassmorphicTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
                if (item.expiryDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Expires: ${_formatDate(item.expiryDate!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: _getExpiryColor(item.expiryDate!),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'NPR ${item.totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: PremiumGlassmorphicTheme.textPrimary,
                ),
              ),
              if (item.quantity > 1)
                Text(
                  'NPR ${item.unitPrice.toStringAsFixed(2)} each',
                  style: TextStyle(
                    fontSize: 12,
                    color: PremiumGlassmorphicTheme.textSecondary,
                  ),
                ),
              if (!item.available)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Out of Stock',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    return Column(
      children: [
        // Subtotal
        _buildPriceRow(
          'Subtotal',
          'NPR ${subtotal.toStringAsFixed(2)}',
          null,
        ),
        
        // Discount (if applicable)
        if (discountAmount > 0)
          _buildPriceRow(
            'Discount',
            '-NPR ${discountAmount.toStringAsFixed(2)}',
            Colors.green,
          ),
        
        // VAT
        _buildPriceRow(
          'VAT (13%)',
          'NPR ${vatAmount.toStringAsFixed(2)}',
          null,
        ),
        
        // Delivery Fee
        if (deliveryFee > 0)
          _buildPriceRow(
            'Delivery Fee',
            'NPR ${deliveryFee.toStringAsFixed(2)}',
            null,
          ),
        else
          _buildPriceRow(
            'Delivery Fee',
            'FREE',
            Colors.green,
          ),
        
        const SizedBox(height: 8),
        
        // Total
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: PremiumGlassmorphicTheme.primaryColor.withOpacity(0.1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: PremiumGlassmorphicTheme.textPrimary,
                ),
              ),
              Text(
                'NPR ${totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: PremiumGlassmorphicTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),
        
        // Savings Badge (if discount applied)
        if (discountAmount > 0)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.green.withOpacity(0.1),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.savings_outlined,
                  color: Colors.green,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'You saved NPR ${discountAmount.toStringAsFixed(2)} on this order!',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, Color? valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: PremiumGlassmorphicTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? PremiumGlassmorphicTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    
    if (difference.inDays < 30) {
      return '${difference.inDays} days';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} months';
    } else {
      return '${(difference.inDays / 365).floor()} years';
    }
  }

  Color _getExpiryColor(DateTime expiryDate) {
    final now = DateTime.now();
    final difference = expiryDate.difference(now);
    
    if (difference.inDays < 30) {
      return Colors.red;
    } else if (difference.inDays < 90) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}

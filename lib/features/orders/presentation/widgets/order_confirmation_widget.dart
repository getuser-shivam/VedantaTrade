import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/widgets/premium_glassmorphic_theme.dart';
import '../../data/models/checkout_models.dart';
import '../../../shared/utils/nepal_localization_utils.dart';

class OrderConfirmationWidget extends StatefulWidget {
  final OrderSummary orderSummary;
  final VoidCallback onOrderConfirmed;

  const OrderConfirmationWidget({
    Key? key,
    required this.orderSummary,
    required this.onOrderConfirmed,
  }) : super(key: key);

  @override
  State<OrderConfirmationWidget> createState() => _OrderConfirmationWidgetState();
}

class _OrderConfirmationWidgetState extends State<OrderConfirmationWidget> 
    with TickerProviderStateMixin {
  late AnimationController _successController;
  late AnimationController _scaleController;
  late Animation<double> _successAnimation;
  late Animation<double> _scaleAnimation;
  
  bool _isConfirming = false;
  bool _isConfirmed = false;

  @override
  void initState() {
    super.initState();
    
    _successController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _successAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    _scaleController.forward();
  }

  @override
  void dispose() {
    _successController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

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
              color: Colors.green.withOpacity(0.1),
            ),
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _successAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 0.8 + (_successAnimation.value * 0.2),
                      child: Icon(
                        Icons.check_circle_outline,
                        color: Colors.green,
                        size: 24,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                Text(
                  'Order Confirmation',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Success Message
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.green.withOpacity(0.05),
                    border: Border.all(color: Colors.green.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.celebration_outlined,
                        color: Colors.green,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order Placed Successfully!',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Your order has been confirmed and will be processed soon.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Order Details
                _buildOrderDetails(),
                
                const SizedBox(height: 24),
                
                // Delivery Information
                _buildDeliveryInformation(),
                
                const SizedBox(height: 24),
                
                // Payment Information
                _buildPaymentInformation(),
                
                const SizedBox(height: 24),
                
                // Action Buttons
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: PremiumGlassmorphicTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[50],
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              _buildDetailRow('Order ID', widget.orderSummary.orderId),
              const SizedBox(height: 8),
              _buildDetailRow('Order Date', NepalLocalizationUtils.formatNepaliDate(widget.orderSummary.createdAt)),
              const SizedBox(height: 8),
              _buildDetailRow('Total Items', '${widget.orderSummary.totalItems}'),
              const SizedBox(height: 8),
              _buildDetailRow('Total Amount', NepalLocalizationUtils.formatNPRCurrency(widget.orderSummary.totalAmount)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delivery Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: PremiumGlassmorphicTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.blue.withOpacity(0.05),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_shipping_outlined,
                    color: Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Estimated Delivery',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                NepalLocalizationUtils.formatNepaliDate(widget.orderSummary.estimatedDelivery),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: PremiumGlassmorphicTheme.textPrimary,
                ),
              ),
              if (widget.orderSummary.trackingNumber != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.qr_code_scanner_outlined,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tracking Number',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                widget.orderSummary.trackingNumber!,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: PremiumGlassmorphicTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: widget.orderSummary.trackingNumber!));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Tracking number copied!'),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                child: Icon(
                                  Icons.copy_outlined,
                                  color: Colors.blue,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: PremiumGlassmorphicTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.green.withOpacity(0.05),
            border: Border.all(color: Colors.green.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.payment_outlined,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Payment Status',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Paid',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildDetailRow('Payment Method', _getPaymentMethodName()),
              const SizedBox(height: 8),
              _buildDetailRow('Amount Paid', NepalLocalizationUtils.formatNPRCurrency(widget.orderSummary.totalAmount)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
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
            color: PremiumGlassmorphicTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Confirm Order Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isConfirming ? null : _confirmOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isConfirming
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('Confirming...'),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline),
                      const SizedBox(width: 8),
                      Text(
                        'Confirm Order',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Additional Actions
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.orderSummary.orderId));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Order ID copied!'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: PremiumGlassmorphicTheme.primaryColor,
                  side: BorderSide(color: PremiumGlassmorphicTheme.primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Copy Order ID'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // Share order details
                  _shareOrderDetails();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: PremiumGlassmorphicTheme.primaryColor,
                  side: BorderSide(color: PremiumGlassmorphicTheme.primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Share Order'),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Continue Shopping Button
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: TextButton.styleFrom(
              foregroundColor: PremiumGlassmorphicTheme.textSecondary,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text('Continue Shopping'),
          ),
        ),
      ],
    );
  }

  String _getPaymentMethodName() {
    switch (widget.orderSummary.paymentMethod) {
      case 'cod':
        return 'Cash on Delivery';
      case 'khalti':
        return 'Khalti Digital Wallet';
      case 'esewa':
        return 'eSewa Digital Wallet';
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'credit_card':
        return 'Credit/Debit Card';
      default:
        return 'Payment Method';
    }
  }

  Future<void> _confirmOrder() async {
    setState(() {
      _isConfirming = true;
    });

    try {
      // Simulate order confirmation
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _isConfirmed = true;
        _isConfirming = false;
      });
      
      // Trigger success animation
      _successController.forward();
      
      widget.onOrderConfirmed();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order confirmed successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      setState(() {
        _isConfirming = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to confirm order: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _shareOrderDetails() {
    final orderDetails = '''
Order Confirmation
================
Order ID: ${widget.orderSummary.orderId}
Order Date: ${NepalLocalizationUtils.formatNepaliDate(widget.orderSummary.createdAt)}
Total Amount: ${NepalLocalizationUtils.formatNPRCurrency(widget.orderSummary.totalAmount)}
Estimated Delivery: ${NepalLocalizationUtils.formatNepaliDate(widget.orderSummary.estimatedDelivery)}
Tracking Number: ${widget.orderSummary.trackingNumber ?? 'Not available'}

Thank you for shopping with VedantaTrade!
    ''';
    
    // In a real app, you would use the share package
    Clipboard.setData(ClipboardData(text: orderDetails));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order details copied to clipboard!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

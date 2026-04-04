import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_trade/app/theme/enhanced_app_theme.dart';
import 'package:vedanta_trade/shared/widgets/enhanced_ui_components.dart';
import 'package:vedanta_trade/shared/widgets/lottie_animations.dart';
import 'package:vedanta_trade/features/stockist/presentation/providers/stockist_provider.dart';
import 'package:vedanta_trade/features/orders/presentation/providers/order_provider.dart';
import 'package:vedanta_trade/features/orders/data/models/order_model.dart';
import 'package:intl/intl.dart';

class OrderCheckoutScreen extends StatefulWidget {
  final OrderModel order;

  const OrderCheckoutScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderCheckoutScreen> createState() => _OrderCheckoutScreenState();
}

class _OrderCheckoutScreenState extends State<OrderCheckoutScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _currentStep = 0;
  bool _isProcessing = false;
  String? _selectedPaymentMethod;
  Map<String, dynamic>? _selectedShippingAddress;
  List<Map<String, dynamic>> _paymentMethods = [];
  List<Map<String, dynamic>> _shippingAddresses = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadPaymentMethods();
    _loadShippingAddresses();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentMethods() async {
    // Load payment methods from backend or use mock data
    setState(() {
      _paymentMethods = [
        {
          'id': 'cash',
          'name': 'Cash on Delivery',
          'description': 'Pay when you receive your order',
          'icon': Icons.money,
          'fee': 0.0,
          'isAvailable': true,
        },
        {
          'id': 'esewa',
          'name': 'eSewa',
          'description': 'Pay instantly with eSewa',
          'icon': Icons.account_balance_wallet,
          'fee': 0.02, // 2% fee
          'isAvailable': true,
        },
        {
          'id': 'khalti',
          'name': 'Khalti',
          'description': 'Pay instantly with Khalti',
          'icon': Icons.phone_android,
          'fee': 0.02, // 2% fee
          'isAvailable': true,
        },
        {
          'id': 'bank_transfer',
          'name': 'Bank Transfer',
          'description': 'Direct bank transfer',
          'icon': Icons.account_balance,
          'fee': 0.0,
          'isAvailable': true,
        },
      ];
    });
  }

  Future<void> _loadShippingAddresses() async {
    // Load shipping addresses from backend or use mock data
    setState(() {
      _shippingAddresses = [
        {
          'id': 'addr_1',
          'name': 'Main Store',
          'address': 'Bhanu Chowk, Janakpur',
          'phone': '+977-1234567890',
          'isDefault': true,
        },
        {
          'id': 'addr_2',
          'name': 'Branch Office',
          'address': 'Ram Chowk, Janakpur',
          'phone': '+977-9876543210',
          'isDefault': false,
        },
      ];
      _selectedShippingAddress = _shippingAddresses.firstWhere(
        (addr) => addr['isDefault'] == true,
        orElse: () => _shippingAddresses.first,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EnhancedAppTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  _buildProgressIndicator(),
                  Expanded(
                    child: _buildCurrentStep(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: EnhancedAppTheme.surfaceColor,
      elevation: 0,
      title: Text(
        'Checkout',
        style: TextStyle(
          color: EnhancedAppTheme.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: EnhancedAppTheme.textPrimary,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              _buildProgressStep(0, 'Shipping'),
              _buildProgressLine(0),
              _buildProgressStep(1, 'Payment'),
              _buildProgressLine(1),
              _buildProgressStep(2, 'Review'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getStepTitle(_currentStep),
            style: TextStyle(
              color: EnhancedAppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStep(int step, String title) {
    final isActive = step == _currentStep;
    final isCompleted = step < _currentStep;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive
                  ? EnhancedAppTheme.primaryColor
                  : isCompleted
                      ? Colors.green
                      : EnhancedAppTheme.textSecondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: isActive
                  ? Border.all(color: EnhancedAppTheme.primaryColor, width: 2)
                  : null,
            ),
            child: Center(
              child: isCompleted
                  ? Icon(Icons.check, color: Colors.white, size: 18)
                  : Text(
                      '${step + 1}',
                      style: TextStyle(
                        color: isActive ? Colors.white : EnhancedAppTheme.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: isActive
                  ? EnhancedAppTheme.primaryColor
                  : isCompleted
                      ? Colors.green
                      : EnhancedAppTheme.textSecondary,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressLine(int step) {
    final isCompleted = step < _currentStep;
    return Container(
      height: 2,
      color: isCompleted
          ? Colors.green
          : EnhancedAppTheme.textSecondary.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Select shipping address';
      case 1:
        return 'Choose payment method';
      case 2:
        return 'Review and confirm order';
      default:
        return '';
    }
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildShippingStep();
      case 1:
        return _buildPaymentStep();
      case 2:
        return _buildReviewStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildShippingStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shipping Address',
            style: TextStyle(
              color: EnhancedAppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._shippingAddresses.map((address) {
            final isSelected = _selectedShippingAddress?['id'] == address['id'];
            return EnhancedUIComponents.glassmorphicCard(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              borderColor: isSelected
                  ? EnhancedAppTheme.primaryColor
                  : EnhancedAppTheme.glassBorderColor,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedShippingAddress = address;
                  });
                },
                child: Row(
                  children: [
                    Radio<String>(
                      value: address['id'],
                      groupValue: _selectedShippingAddress?['id'],
                      onChanged: (value) {
                        setState(() {
                          _selectedShippingAddress = address;
                        });
                      },
                      activeColor: EnhancedAppTheme.primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                address['name'],
                                style: TextStyle(
                                  color: EnhancedAppTheme.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (address['isDefault'] == true)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: EnhancedAppTheme.primaryColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Default',
                                    style: TextStyle(
                                      color: EnhancedAppTheme.primaryColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            address['address'],
                            style: TextStyle(
                              color: EnhancedAppTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            address['phone'],
                            style: TextStyle(
                              color: EnhancedAppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 16),
          EnhancedUIComponents.enhancedButton(
            child: const Text('Add New Address'),
            onPressed: _showAddAddressDialog,
            backgroundColor: EnhancedAppTheme.secondaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: TextStyle(
              color: EnhancedAppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._paymentMethods.map((method) {
            final isSelected = _selectedPaymentMethod == method['id'];
            final isAvailable = method['isAvailable'] == true;
            
            return EnhancedUIComponents.glassmorphicCard(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              borderColor: isSelected
                  ? EnhancedAppTheme.primaryColor
                  : isAvailable
                      ? EnhancedAppTheme.glassBorderColor
                      : Colors.grey.withOpacity(0.3),
              opacity: isAvailable ? 1.0 : 0.5,
              child: InkWell(
                onTap: isAvailable ? () {
                  setState(() {
                    _selectedPaymentMethod = method['id'];
                  });
                } : null,
                child: Row(
                  children: [
                    Radio<String>(
                      value: method['id'],
                      groupValue: _selectedPaymentMethod,
                      onChanged: isAvailable ? (value) {
                        setState(() {
                          _selectedPaymentMethod = method['id'];
                        });
                      } : null,
                      activeColor: EnhancedAppTheme.primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      method['icon'],
                      color: isAvailable
                          ? EnhancedAppTheme.primaryColor
                          : Colors.grey,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            method['name'],
                            style: TextStyle(
                              color: isAvailable
                                  ? EnhancedAppTheme.textPrimary
                                  : Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            method['description'],
                            style: TextStyle(
                              color: isAvailable
                                  ? EnhancedAppTheme.textSecondary
                                  : Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          if (method['fee'] > 0)
                            Text(
                              'Fee: ${(method['fee'] * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    final subtotal = widget.order.totalAmount;
    final paymentMethod = _paymentMethods.firstWhere(
      (method) => method['id'] == _selectedPaymentMethod,
      orElse: () => {'fee': 0.0},
    );
    final paymentFee = subtotal * (paymentMethod['fee'] as double);
    final shippingFee = 50.0; // Flat shipping fee
    final total = subtotal + paymentFee + shippingFee;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: TextStyle(
              color: EnhancedAppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          EnhancedUIComponents.glassmorphicCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Details',
                  style: TextStyle(
                    color: EnhancedAppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...widget.order.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            item['productName'],
                            style: TextStyle(
                              color: EnhancedAppTheme.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          'x${item['quantity']}',
                          style: TextStyle(
                            color: EnhancedAppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'NPR ${NumberFormat('#,##0.00').format(item['price'] * item['quantity'])}',
                          style: TextStyle(
                            color: EnhancedAppTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const Divider(height: 24),
                _buildSummaryRow('Subtotal', subtotal),
                _buildSummaryRow('Payment Fee', paymentFee),
                _buildSummaryRow('Shipping Fee', shippingFee),
                const Divider(height: 24),
                _buildSummaryRow('Total', total, isBold: true),
              ],
            ),
          ),
          const SizedBox(height: 16),
          EnhancedUIComponents.glassmorphicCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shipping Address',
                  style: TextStyle(
                    color: EnhancedAppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedShippingAddress?['name'] ?? '',
                  style: TextStyle(
                    color: EnhancedAppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedShippingAddress?['address'] ?? '',
                  style: TextStyle(
                    color: EnhancedAppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _selectedShippingAddress?['phone'] ?? '',
                  style: TextStyle(
                    color: EnhancedAppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          EnhancedUIComponents.glassmorphicCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Method',
                  style: TextStyle(
                    color: EnhancedAppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _paymentMethods.firstWhere(
                    (method) => method['id'] == _selectedPaymentMethod,
                    orElse: () => {'name': 'Not selected'},
                  )['name'],
                  style: TextStyle(
                    color: EnhancedAppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: EnhancedAppTheme.textSecondary,
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            'NPR ${NumberFormat('#,##0.00').format(amount)}',
            style: TextStyle(
              color: EnhancedAppTheme.textPrimary,
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EnhancedAppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: EnhancedUIComponents.enhancedButton(
              child: Text(_currentStep == 0 ? 'Cancel' : 'Back'),
              onPressed: _currentStep == 0
                  ? () => Navigator.of(context).pop()
                  : _previousStep,
              backgroundColor: EnhancedAppTheme.surfaceColor,
              foregroundColor: EnhancedAppTheme.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: EnhancedUIComponents.enhancedButton(
              child: _isProcessing
                  ? LottieAnimations.loading(size: 20)
                  : Text(_currentStep == 2 ? 'Place Order' : 'Next'),
              onPressed: _isProcessing ? null : _nextStep,
              backgroundColor: EnhancedAppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() async {
    if (_currentStep == 0) {
      if (_selectedShippingAddress == null) {
        EnhancedUIComponents.showEnhancedSnackbar(
          context: context,
          message: 'Please select a shipping address',
          icon: Icons.warning,
        );
        return;
      }
    } else if (_currentStep == 1) {
      if (_selectedPaymentMethod == null) {
        EnhancedUIComponents.showEnhancedSnackbar(
          context: context,
          message: 'Please select a payment method',
          icon: Icons.warning,
        );
        return;
      }
    } else if (_currentStep == 2) {
      await _placeOrder();
      return;
    }

    setState(() {
      _currentStep++;
    });
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _placeOrder() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final orderProvider = context.read<OrderProvider>();
      
      // Calculate total with fees
      final subtotal = widget.order.totalAmount;
      final paymentMethod = _paymentMethods.firstWhere(
        (method) => method['id'] == _selectedPaymentMethod,
        orElse: () => {'fee': 0.0},
      );
      final paymentFee = subtotal * (paymentMethod['fee'] as double);
      final shippingFee = 50.0;
      final total = subtotal + paymentFee + shippingFee;

      // Update order with checkout details
      final updatedOrder = widget.order.copyWith(
        shippingAddress: _selectedShippingAddress,
        paymentMethod: _selectedPaymentMethod,
        paymentFee: paymentFee,
        shippingFee: shippingFee,
        totalAmount: total,
        status: 'pending_payment',
        updatedAt: DateTime.now(),
      );

      await orderProvider.updateOrder(updatedOrder);

      // Show success animation
      _showSuccessDialog();

    } catch (e) {
      EnhancedUIComponents.showEnhancedSnackbar(
        context: context,
        message: 'Failed to place order: ${e.toString()}',
        icon: Icons.error,
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: EnhancedAppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LottieAnimations.success(size: 100),
              const SizedBox(height: 16),
              Text(
                'Order Placed Successfully!',
                style: TextStyle(
                  color: EnhancedAppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your order has been placed and will be processed soon.',
                style: TextStyle(
                  color: EnhancedAppTheme.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              EnhancedUIComponents.enhancedButton(
                child: const Text('View Orders'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back to orders
                },
                backgroundColor: EnhancedAppTheme.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddAddressDialog() {
    // TODO: Implement add address dialog
    EnhancedUIComponents.showEnhancedSnackbar(
      context: context,
      message: 'Add address feature coming soon',
      icon: Icons.info,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/premium_glassmorphic_theme.dart';
import '../providers/checkout_provider.dart';
import '../../data/models/checkout_models.dart';
import '../../data/models/payment_models.dart';
import '../widgets/checkout_summary_widget.dart';
import '../widgets/payment_method_widget.dart';
import '../widgets/shipping_address_widget.dart';
import '../widgets/order_confirmation_widget.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CheckoutItem> items;
  final String retailerId;
  final String retailerName;

  const CheckoutScreen({
    Key? key,
    required this.items,
    required this.retailerId,
    required this.retailerName,
  }) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _currentStep = 0;
  final List<String> _steps = ['Summary', 'Shipping', 'Payment', 'Confirmation'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _steps.length, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();

    // Initialize checkout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCheckout();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _initializeCheckout() {
    final checkoutProvider = context.read<CheckoutProvider>();
    checkoutProvider.initializeCheckout(
      items: widget.items,
      retailerId: widget.retailerId,
      retailerName: widget.retailerName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Consumer<CheckoutProvider>(
        builder: (context, checkoutProvider, child) {
          return Column(
            children: [
              // Progress Indicator
              _buildProgressIndicator(),
              
              // Main Content
              Expanded(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: TabBarView(
                          controller: _tabController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildSummaryTab(checkoutProvider),
                            _buildShippingTab(checkoutProvider),
                            _buildPaymentTab(checkoutProvider),
                            _buildConfirmationTab(checkoutProvider),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Bottom Action Buttons
              _buildBottomActions(checkoutProvider),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Checkout',
        style: TextStyle(
          color: PremiumGlassmorphicTheme.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: PremiumGlassmorphicTheme.primaryColor,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.help_outline,
            color: PremiumGlassmorphicTheme.primaryColor,
          ),
          onPressed: _showHelpDialog,
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          // Step Indicators
          Row(
            children: List.generate(_steps.length, (index) {
              final isActive = index <= _currentStep;
              final isCompleted = index < _currentStep;
              
              return Expanded(
                child: Row(
                  children: [
                    // Step Circle
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive 
                            ? PremiumGlassmorphicTheme.primaryColor
                            : Colors.grey[300],
                        border: isActive
                            ? Border.all(color: PremiumGlassmorphicTheme.primaryColor, width: 2)
                            : null,
                      ),
                      child: Center(
                        child: isCompleted
                            ? Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isActive ? Colors.white : Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    ),
                    
                    // Step Line
                    if (index < _steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          color: index < _currentStep 
                              ? PremiumGlassmorphicTheme.primaryColor
                              : Colors.grey[300],
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          
          const SizedBox(height: 12),
          
          // Step Labels
          Row(
            children: List.generate(_steps.length, (index) {
              final isActive = index <= _currentStep;
              return Expanded(
                child: Text(
                  _steps[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isActive 
                        ? PremiumGlassmorphicTheme.primaryColor
                        : Colors.grey[600],
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTab(CheckoutProvider checkoutProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Summary
          CheckoutSummaryWidget(
            items: checkoutProvider.currentItems,
            subtotal: checkoutProvider.subtotal,
            discountAmount: checkoutProvider.discountAmount,
            vatAmount: checkoutProvider.vatAmount,
            deliveryFee: checkoutProvider.deliveryFee,
            totalAmount: checkoutProvider.totalAmount,
          ),
          
          const SizedBox(height: 24),
          
          // Promo Code
          _buildPromoCodeSection(checkoutProvider),
          
          const SizedBox(height: 24),
          
          // Delivery Options
          _buildDeliveryOptionsSection(checkoutProvider),
        ],
      ),
    );
  }

  Widget _buildPromoCodeSection(CheckoutProvider checkoutProvider) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_offer_outlined,
                color: PremiumGlassmorphicTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Promo Code',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: PremiumGlassmorphicTheme.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: checkoutProvider.promoCodeController,
                  decoration: InputDecoration(
                    hintText: 'Enter promo code',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: PremiumGlassmorphicTheme.primaryColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: checkoutProvider.isApplyingPromo 
                    ? null 
                    : () => _applyPromoCode(checkoutProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PremiumGlassmorphicTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: checkoutProvider.isApplyingPromo
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text('Apply'),
              ),
            ],
          ),
          
          if (checkoutProvider.promoError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                checkoutProvider.promoError!,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
          
          if (checkoutProvider.discountAmount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Promo code applied! You saved NPR ${checkoutProvider.discountAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDeliveryOptionsSection(CheckoutProvider checkoutProvider) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_shipping_outlined,
                color: PremiumGlassmorphicTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Delivery Options',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: PremiumGlassmorphicTheme.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          ...checkoutProvider.deliveryOptions.map((option) {
            final isSelected = checkoutProvider.selectedDeliveryOption?.id == option.id;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? PremiumGlassmorphicTheme.primaryColor : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
                color: isSelected ? PremiumGlassmorphicTheme.primaryColor.withOpacity(0.05) : Colors.white,
              ),
              child: RadioListTile<DeliveryOption>(
                value: option,
                groupValue: checkoutProvider.selectedDeliveryOption,
                onChanged: (value) => checkoutProvider.selectDeliveryOption(value),
                title: Text(
                  option.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: PremiumGlassmorphicTheme.textPrimary,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.description,
                      style: TextStyle(
                        color: PremiumGlassmorphicTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Est. delivery: ${option.estimatedDeliveryText}',
                      style: TextStyle(
                        color: PremiumGlassmorphicTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                secondary: Text(
                  'NPR ${option.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: PremiumGlassmorphicTheme.primaryColor,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildShippingTab(CheckoutProvider checkoutProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ShippingAddressWidget(
        onAddressSaved: (address) {
          checkoutProvider.setShippingAddress(address);
          _nextStep();
        },
        initialAddress: checkoutProvider.shippingAddress,
      ),
    );
  }

  Widget _buildPaymentTab(CheckoutProvider checkoutProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: PaymentMethodWidget(
        availableMethods: checkoutProvider.availablePaymentMethods,
        selectedMethod: checkoutProvider.selectedPaymentMethod,
        onMethodSelected: (method) {
          checkoutProvider.selectPaymentMethod(method);
        },
        onPaymentProcessed: (result) {
          if (result.success) {
            _nextStep();
          } else {
            _showPaymentError(result.failureReason ?? 'Payment failed');
          }
        },
        amount: checkoutProvider.totalAmount,
      ),
    );
  }

  Widget _buildConfirmationTab(CheckoutProvider checkoutProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: OrderConfirmationWidget(
        orderSummary: checkoutProvider.orderSummary,
        onOrderConfirmed: () {
          _showOrderSuccess();
        },
      ),
    );
  }

  Widget _buildBottomActions(CheckoutProvider checkoutProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          if (_currentStep > 0)
            TextButton(
              onPressed: _previousStep,
              style: TextButton.styleFrom(
                foregroundColor: PremiumGlassmorphicTheme.primaryColor,
              ),
              child: Text('Back'),
            ),
          
          const Spacer(),
          
          // Total Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 12,
                  color: PremiumGlassmorphicTheme.textSecondary,
                ),
              ),
              Text(
                'NPR ${checkoutProvider.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: PremiumGlassmorphicTheme.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(width: 16),
          
          // Next/Place Order Button
          ElevatedButton(
            onPressed: _canProceed(checkoutProvider) ? _nextStep : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: PremiumGlassmorphicTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: _currentStep == _steps.length - 1
                ? Text('Place Order')
                : Text('Next'),
          ),
        ],
      ),
    );
  }

  bool _canProceed(CheckoutProvider checkoutProvider) {
    switch (_currentStep) {
      case 0:
        return checkoutProvider.selectedDeliveryOption != null;
      case 1:
        return checkoutProvider.shippingAddress != null;
      case 2:
        return checkoutProvider.selectedPaymentMethod != null;
      case 3:
        return true; // Confirmation step
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
        _tabController.animateTo(_currentStep);
      });
      
      // Restart animation
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _tabController.animateTo(_currentStep);
      });
      
      // Restart animation
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _applyPromoCode(CheckoutProvider checkoutProvider) async {
    final success = await checkoutProvider.applyPromoCode(
      checkoutProvider.promoCodeController.text.trim(),
    );
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Promo code applied successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showPaymentError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showOrderSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text('Order Placed!'),
          ],
        ),
        content: const Text(
          'Your order has been successfully placed. You will receive a confirmation email shortly.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to previous screen
            },
            child: Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Checkout Help'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How to complete your order:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('1. Review your order summary'),
            Text('2. Select delivery option'),
            Text('3. Enter shipping address'),
            Text('4. Choose payment method'),
            Text('5. Confirm and place order'),
            const SizedBox(height: 16),
            Text(
              'Need help? Contact our support team at support@vedantatrade.com',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }
}

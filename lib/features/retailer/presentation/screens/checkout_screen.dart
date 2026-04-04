import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/payment_service.dart';
import '../providers/retailer_provider.dart';
import '../../../../shared/theme/enhanced_theme.dart';
import '../../../../shared/widgets/enhanced_ui_kit.dart';

/// Checkout screen for retailer orders with Nepal-specific payment processing
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  List<CartItem> _cartItems = [];
  double _subtotal = 0.0;
  double _vatAmount = 0.0;
  double _totalAmount = 0.0;
  String _selectedPaymentMethod = 'cash';
  bool _isProcessing = false;
  late AnimationController _successController;
  late AnimationController _processingController;
  
  // Shipping information
  final _shippingNameController = TextEditingController();
  final _shippingPhoneController = TextEditingController();
  final _shippingAddressController = TextEditingController();
  final _shippingCityController = TextEditingController();
  final _shippingNotesController = TextEditingController();
  
  // Payment information
  final _cardNumberController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCVVController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _bankNameController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _successController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _processingController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    // Load cart data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCartData();
      _loadShippingInfo();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _successController.dispose();
    _processingController.dispose();
    _shippingNameController.dispose();
    _shippingPhoneController.dispose();
    _shippingAddressController.dispose();
    _shippingCityController.dispose();
    _shippingNotesController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCVVController.dispose();
    _bankAccountController.dispose();
    _bankNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EnhancedTheme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildOrderSummary(context),
          _buildTabBar(context),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildShippingTab(context),
                _buildPaymentTab(context),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  /// Build app bar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return EnhancedAppBar(
      title: 'Checkout',
      subtitle: 'Complete your order',
      backgroundColor: EnhancedTheme.of(context).appBarColor,
      actions: [
        IconButton(
          icon: Icon(
            Icons.shopping_cart,
            color: EnhancedTheme.of(context).iconColor,
          ),
          onPressed: () => Navigator.pushNamed(context, '/cart'),
        ),
      ],
    );
  }

  /// Build order summary
  Widget _buildOrderSummary(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EnhancedTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blur: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shopping_bag,
                color: EnhancedTheme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Order Summary',
                style: TextStyle(
                  color: EnhancedTheme.of(context).textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${_cartItems.length} items',
                style: TextStyle(
                  color: EnhancedTheme.of(context).textColor.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildOrderItems(context),
          const SizedBox(height: 16),
          _buildPricingBreakdown(context),
        ],
      ),
    );
  }

  /// Build order items
  Widget _buildOrderItems(BuildContext context) {
    return Column(
      children: _cartItems.map((item) => Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: EnhancedTheme.of(context).dividerColor,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: EnhancedTheme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.medication,
                color: EnhancedTheme.of(context).primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: TextStyle(
                      color: EnhancedTheme.of(context).textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${item.brand} • ${item.sku}',
                    style: TextStyle(
                      color: EnhancedTheme.of(context).textColor.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${item.unitPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: EnhancedTheme.of(context).textColor,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'x${item.quantity}',
                  style: TextStyle(
                    color: EnhancedTheme.of(context).textColor.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Text(
              '₹${item.totalPrice.toStringAsFixed(2)}',
              style: TextStyle(
                color: EnhancedTheme.of(context).primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  /// Build pricing breakdown
  Widget _buildPricingBreakdown(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: EnhancedTheme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildPricingRow(
            context,
            'Subtotal',
            '₹${_subtotal.toStringAsFixed(2)}',
            isBold: false,
          ),
          const SizedBox(height: 8),
          _buildPricingRow(
            context,
            'VAT (13%)',
            '₹${_vatAmount.toStringAsFixed(2)}',
            isBold: false,
          ),
          const Divider(),
          const SizedBox(height: 8),
          _buildPricingRow(
            context,
            'Total Amount',
            '₹${_totalAmount.toStringAsFixed(2)}',
            isBold: true,
            color: EnhancedTheme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  /// Build pricing row
  Widget _buildPricingRow(
    BuildContext context,
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color ?? EnhancedTheme.of(context).textColor,
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color ?? EnhancedTheme.of(context).textColor,
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  /// Build tab bar
  Widget _buildTabBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: EnhancedTheme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: EnhancedTheme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: EnhancedTheme.of(context).textColor,
        unselectedLabelColor: EnhancedTheme.of(context).textColor.withOpacity(0.6),
        indicator: BoxDecoration(
          color: EnhancedTheme.of(context).primaryColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(8),
          ),
        ),
        tabs: const [
          Tab(
            text: 'Shipping',
            icon: Icon(Icons.local_shipping),
          ),
          Tab(
            text: 'Payment',
            icon: Icon(Icons.payment),
          ),
        ],
      ),
    );
  }

  /// Build shipping tab
  Widget _buildShippingTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shipping Information',
            style: TextStyle(
              color: EnhancedTheme.of(context).textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          EnhancedTextField(
            controller: _shippingNameController,
            hintText: 'Full Name',
            prefixIcon: Icon(
              Icons.person,
              color: EnhancedTheme.of(context).iconColor,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your full name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          EnhancedTextField(
            controller: _shippingPhoneController,
            hintText: 'Phone Number',
            prefixIcon: Icon(
              Icons.phone,
              color: EnhancedTheme.of(context).iconColor,
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          EnhancedTextField(
            controller: _shippingAddressController,
            hintText: 'Delivery Address',
            prefixIcon: Icon(
              Icons.location_on,
              color: EnhancedTheme.of(context).iconColor,
            ),
            maxLines: 2,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your delivery address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          EnhancedTextField(
            controller: _shippingCityController,
            hintText: 'City',
            prefixIcon: Icon(
              Icons.location_city,
              color: EnhancedTheme.of(context).iconColor,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your city';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          EnhancedTextField(
            controller: _shippingNotesController,
            hintText: 'Delivery Notes (Optional)',
            prefixIcon: Icon(
              Icons.note,
              color: EnhancedTheme.of(context).iconColor,
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  /// Build payment tab
  Widget _buildPaymentTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: TextStyle(
              color: EnhancedTheme.of(context).textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildPaymentMethodSelector(context),
          const SizedBox(height: 24),
          _buildPaymentForm(context),
        ],
      ),
    );
  }

  /// Build payment method selector
  Widget _buildPaymentMethodSelector(BuildContext context) {
    return Column(
      children: [
        _buildPaymentMethodOption(
          context,
          'cash',
          'Cash on Delivery',
          Icons.money,
          'Pay when you receive your order',
        ),
        const SizedBox(height: 12),
        _buildPaymentMethodOption(
          context,
          'card',
          'Credit/Debit Card',
          Icons.credit_card,
          'Pay securely with your card',
        ),
        const SizedBox(height: 12),
        _buildPaymentMethodOption(
          context,
          'bank',
          'Bank Transfer',
          Icons.account_balance,
          'Transfer directly to our bank account',
        ),
      ],
    );
  }

  /// Build payment method option
  Widget _buildPaymentMethodOption(
    BuildContext context,
    String value,
    String title,
    IconData icon,
    String description,
  ) {
    final isSelected = _selectedPaymentMethod == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? EnhancedTheme.of(context).primaryColor.withOpacity(0.1)
              : EnhancedTheme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? EnhancedTheme.of(context).primaryColor
                : EnhancedTheme.of(context).dividerColor,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? EnhancedTheme.of(context).primaryColor
                  : EnhancedTheme.of(context).iconColor,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: EnhancedTheme.of(context).textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      color: EnhancedTheme.of(context).textColor.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: EnhancedTheme.of(context).primaryColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  /// Build payment form
  Widget _buildPaymentForm(BuildContext context) {
    switch (_selectedPaymentMethod) {
      case 'card':
        return _buildCardPaymentForm(context);
      case 'bank':
        return _buildBankPaymentForm(context);
      default:
        return _buildCashPaymentInfo(context);
    }
  }

  /// Build card payment form
  Widget _buildCardPaymentForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EnhancedTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blur: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Card Details',
            style: TextStyle(
              color: EnhancedTheme.of(context).textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          EnhancedTextField(
            controller: _cardNumberController,
            hintText: 'Card Number',
            prefixIcon: Icon(
              Icons.credit_card,
              color: EnhancedTheme.of(context).iconColor,
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your card number';
              }
              if (value.length < 16) {
                return 'Please enter a valid card number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: EnhancedTextField(
                  controller: _cardExpiryController,
                  hintText: 'MM/YY',
                  prefixIcon: Icon(
                    Icons.date_range,
                    color: EnhancedTheme.of(context).iconColor,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: EnhancedTextField(
                  controller: _cardCVVController,
                  hintText: 'CVV',
                  prefixIcon: Icon(
                    Icons.security,
                    color: EnhancedTheme.of(context).iconColor,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build bank payment form
  Widget _buildBankPaymentForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EnhancedTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blur: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bank Transfer Details',
            style: TextStyle(
              color: EnhancedTheme.of(context).textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: EnhancedTheme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bank Name: Nepal Investment Bank',
                  style: TextStyle(
                    color: EnhancedTheme.of(context).textColor,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Account Name: VedantaTrade Pvt. Ltd.',
                  style: TextStyle(
                    color: EnhancedTheme.of(context).textColor,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Account Number: 1234567890',
                  style: TextStyle(
                    color: EnhancedTheme.of(context).textColor,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Branch: Kathmandu',
                  style: TextStyle(
                    color: EnhancedTheme.of(context).textColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          EnhancedTextField(
            controller: _bankAccountController,
            hintText: 'Your Account Number',
            prefixIcon: Icon(
              Icons.account_balance,
              color: EnhancedTheme.of(context).iconColor,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your account number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          EnhancedTextField(
            controller: _bankNameController,
            hintText: 'Bank Name',
            prefixIcon: Icon(
              Icons.account_balance,
              color: EnhancedTheme.of(context).iconColor,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your bank name';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  /// Build cash payment info
  Widget _buildCashPaymentInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EnhancedTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blur: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info,
                color: EnhancedTheme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Cash on Delivery',
                  style: TextStyle(
                    color: EnhancedTheme.of(context).textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Please have the exact amount ready when our delivery agent arrives. The delivery agent will provide you with a receipt.',
            style: TextStyle(
              color: EnhancedTheme.of(context).textColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.green,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Secure payment option - No card details required',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build bottom bar
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EnhancedTheme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blur: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: TextStyle(
                    color: EnhancedTheme.of(context).textColor,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '₹${_totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: EnhancedTheme.of(context).primaryColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: EnhancedTheme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isProcessing
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
                          Text('Processing...'),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock),
                          const SizedBox(width: 8),
                          Text('Place Order'),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Load cart data
  Future<void> _loadCartData() async {
    // Mock cart data - in real implementation, this would come from cart provider
    setState(() {
      _cartItems = [
        CartItem(
          sku: 'MED001',
          productName: 'Paracetamol 500mg',
          brand: 'Nepal Pharma',
          quantity: 2,
          unitPrice: 25.50,
          totalPrice: 51.00,
        ),
        CartItem(
          sku: 'MED002',
          productName: 'Amoxicillin 250mg',
          brand: 'Janakpur Labs',
          quantity: 1,
          unitPrice: 45.75,
          totalPrice: 45.75,
        ),
      ];
      
      _calculateTotals();
    });
  }

  /// Load shipping information
  Future<void> _loadShippingInfo() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _shippingNameController.text = prefs.getString('shipping_name') ?? '';
      _shippingPhoneController.text = prefs.getString('shipping_phone') ?? '';
      _shippingAddressController.text = prefs.getString('shipping_address') ?? '';
      _shippingCityController.text = prefs.getString('shipping_city') ?? '';
    });
  }

  /// Calculate totals
  void _calculateTotals() {
    _subtotal = _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
    _vatAmount = _subtotal * 0.13; // 13% VAT for Nepal
    _totalAmount = _subtotal + _vatAmount;
  }

  /// Process payment
  Future<void> _processPayment() async {
    // Validate shipping information
    if (_shippingNameController.text.isEmpty ||
        _shippingPhoneController.text.isEmpty ||
        _shippingAddressController.text.isEmpty ||
        _shippingCityController.text.isEmpty) {
      _showErrorDialog('Please complete all shipping information');
      return;
    }
    
    setState(() {
      _isProcessing = true;
    });
    
    _processingController.repeat(reverse: true);
    
    try {
      // Create order data
      final orderData = {
        'items': _cartItems.map((item) => item.toJson()).toList(),
        'subtotal': _subtotal,
        'vatAmount': _vatAmount,
        'totalAmount': _totalAmount,
        'paymentMethod': _selectedPaymentMethod,
        'shipping': {
          'name': _shippingNameController.text,
          'phone': _shippingPhoneController.text,
          'address': _shippingAddressController.text,
          'city': _shippingCityController.text,
          'notes': _shippingNotesController.text,
        },
        'payment': _getPaymentData(),
        'currency': 'NPR',
        'createdAt': DateTime.now().toIso8601String(),
      };
      
      // Process payment through service
      final paymentService = PaymentService();
      final result = await paymentService.processPayment(orderData);
      
      if (result['success']) {
        // Save shipping information
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('shipping_name', _shippingNameController.text);
        await prefs.setString('shipping_phone', _shippingPhoneController.text);
        await prefs.setString('shipping_address', _shippingAddressController.text);
        await prefs.setString('shipping_city', _shippingCityController.text);
        
        // Show success animation
        _successController.forward().then((_) {
          _successController.reverse();
        });
        
        // Navigate to success screen
        Navigator.pushReplacementNamed(
          context,
          '/order-success',
          arguments: {
            'orderId': result['orderId'],
            'totalAmount': _totalAmount,
            'paymentMethod': _selectedPaymentMethod,
          },
        );
      } else {
        _showErrorDialog('Payment failed: ${result['error']}');
      }
      
    } catch (e) {
      _showErrorDialog('Payment processing failed: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
      _processingController.stop();
    }
  }

  /// Get payment data based on selected method
  Map<String, dynamic> _getPaymentData() {
    switch (_selectedPaymentMethod) {
      case 'card':
        return {
          'cardNumber': _cardNumberController.text,
          'expiry': _cardExpiryController.text,
          'cvv': _cardCVVController.text,
        };
      case 'bank':
        return {
          'accountNumber': _bankAccountController.text,
          'bankName': _bankNameController.text,
        };
      default:
        return {};
    }
  }

  /// Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Cart item model
class CartItem {
  final String sku;
  final String productName;
  final String brand;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  
  CartItem({
    required this.sku,
    required this.productName,
    required this.brand,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'sku': sku,
      'productName': productName,
      'brand': brand,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
    };
  }
}

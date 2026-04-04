import 'package:flutter/material.dart';
import '../../../shared/widgets/premium_glassmorphic_theme.dart';
import '../../data/services/checkout_service.dart';
import '../../data/models/checkout_models.dart';
import '../../data/models/payment_models.dart';

class CheckoutProvider extends ChangeNotifier {
  final CheckoutService _checkoutService = CheckoutService();
  
  // State variables
  List<CheckoutItem> _items = [];
  String _retailerId = '';
  String _retailerName = '';
  double _subtotal = 0.0;
  double _discountAmount = 0.0;
  double _vatAmount = 0.0;
  double _deliveryFee = 0.0;
  double _totalAmount = 0.0;
  
  DeliveryOption? _selectedDeliveryOption;
  Address? _shippingAddress;
  Address? _billingAddress;
  PaymentMethod? _selectedPaymentMethod;
  List<DeliveryOption> _deliveryOptions = [];
  List<PaymentMethod> _availablePaymentMethods = [];
  
  CheckoutSession? _currentSession;
  OrderSummary? _orderSummary;
  
  // UI State
  bool _isLoading = false;
  bool _isApplyingPromo = false;
  String? _promoError;
  String? _errorMessage;
  
  // Controllers
  final TextEditingController _promoCodeController = TextEditingController();
  
  // Getters
  List<CheckoutItem> get currentItems => List.unmodifiable(_items);
  String get retailerId => _retailerId;
  String get retailerName => _retailerName;
  double get subtotal => _subtotal;
  double get discountAmount => _discountAmount;
  double get vatAmount => _vatAmount;
  double get deliveryFee => _deliveryFee;
  double get totalAmount => _totalAmount;
  
  DeliveryOption? get selectedDeliveryOption => _selectedDeliveryOption;
  Address? get shippingAddress => _shippingAddress;
  Address? get billingAddress => _billingAddress;
  PaymentMethod? get selectedPaymentMethod => _selectedPaymentMethod;
  List<DeliveryOption> get deliveryOptions => List.unmodifiable(_deliveryOptions);
  List<PaymentMethod> get availablePaymentMethods => List.unmodifiable(_availablePaymentMethods);
  
  CheckoutSession? get currentSession => _currentSession;
  OrderSummary? get orderSummary => _orderSummary;
  
  bool get isLoading => _isLoading;
  bool get isApplyingPromo => _isApplyingPromo;
  String? get promoError => _promoError;
  String? get errorMessage => _errorMessage;
  TextEditingController get promoCodeController => _promoCodeController;
  
  // Initialize checkout
  void initializeCheckout({
    required List<CheckoutItem> items,
    required String retailerId,
    required String retailerName,
  }) {
    _items = items;
    _retailerId = retailerId;
    _retailerName = retailerName;
    
    _calculateTotals();
    _loadDeliveryOptions();
    _loadPaymentMethods();
    
    _checkoutService.initialize(userId: retailerId);
  }
  
  void _calculateTotals() {
    _subtotal = _items.fold(0.0, (sum, item) => sum + item.totalPrice);
    _vatAmount = _checkoutService.calculateVAT(_subtotal);
    _deliveryFee = _selectedDeliveryOption?.price ?? 0.0;
    _totalAmount = _subtotal + _vatAmount + _deliveryFee - _discountAmount;
    notifyListeners();
  }
  
  Future<void> _loadDeliveryOptions() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      _deliveryOptions = await _checkoutService.getDeliveryOptions(_retailerId);
      
      // Select default delivery option (standard)
      if (_deliveryOptions.isNotEmpty) {
        _selectedDeliveryOption = _deliveryOptions.firstWhere(
          (option) => option.id == 'standard',
          orElse: () => _deliveryOptions.first,
        );
        _calculateTotals();
      }
    } catch (e) {
      _errorMessage = 'Failed to load delivery options: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> _loadPaymentMethods() async {
    try {
      _availablePaymentMethods = _checkoutService.availablePaymentMethods;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load payment methods: $e';
      notifyListeners();
    }
  }
  
  // Delivery option selection
  void selectDeliveryOption(DeliveryOption? option) {
    _selectedDeliveryOption = option;
    _calculateTotals();
  }
  
  // Address management
  void setShippingAddress(Address address) {
    _shippingAddress = address;
    notifyListeners();
  }
  
  void setBillingAddress(Address? address) {
    _billingAddress = address;
    notifyListeners();
  }
  
  void useShippingAsBillingAddress() {
    if (_shippingAddress != null) {
      _billingAddress = _shippingAddress;
      notifyListeners();
    }
  }
  
  // Payment method selection
  void selectPaymentMethod(PaymentMethod? method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }
  
  // Promo code management
  Future<bool> applyPromoCode(String promoCode) async {
    if (promoCode.isEmpty) return false;
    
    try {
      _isApplyingPromo = true;
      _promoError = null;
      notifyListeners();
      
      // Calculate discount
      final discount = _checkoutService.calculateDiscount(_subtotal, promoCode);
      
      if (discount > 0) {
        _discountAmount = discount;
        _calculateTotals();
        
        // Apply to session if exists
        if (_currentSession != null) {
          await _checkoutService.applyPromoCode(promoCode, _currentSession!.id);
        }
        
        return true;
      } else {
        _promoError = 'Invalid promo code';
        return false;
      }
    } catch (e) {
      _promoError = 'Failed to apply promo code: $e';
      return false;
    } finally {
      _isApplyingPromo = false;
      notifyListeners();
    }
  }
  
  void clearPromoCode() {
    _promoCodeController.clear();
    _discountAmount = 0.0;
    _promoError = null;
    _calculateTotals();
  }
  
  // Checkout session management
  Future<CheckoutSession> initiateCheckout() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final request = CheckoutRequest(
        retailerId: _retailerId,
        retailerName: _retailerName,
        items: _items,
        subtotal: _subtotal,
        discountAmount: _discountAmount,
        vatAmount: _vatAmount,
        deliveryFee: _deliveryFee,
        totalAmount: _totalAmount,
        promoCode: _promoCodeController.text.isNotEmpty ? _promoCodeController.text : null,
        shippingAddress: _shippingAddress!,
        billingAddress: _billingAddress,
        deliveryOption: _selectedDeliveryOption?.id ?? 'standard',
        notes: null,
      );
      
      // Validate inventory
      final isValid = await _checkoutService.validateInventory(request);
      if (!isValid) {
        throw Exception('Some items are no longer available');
      }
      
      // Initiate checkout session
      _currentSession = await _checkoutService.initiateCheckout(request);
      
      return _currentSession!;
    } catch (e) {
      _errorMessage = 'Failed to initiate checkout: $e';
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Payment processing
  Future<PaymentResult> processPayment(Map<String, dynamic> paymentDetails) async {
    if (_selectedPaymentMethod == null) {
      throw Exception('No payment method selected');
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      final request = PaymentRequest(
        paymentMethodId: _selectedPaymentMethod!.id,
        amount: _totalAmount,
        currency: 'NPR',
        paymentDetails: paymentDetails,
        returnUrl: 'https://vedantatrade.com/checkout/return',
        cancelUrl: 'https://vedantatrade.com/checkout/cancel',
        callbackUrl: 'https://vedantatrade.com/checkout/callback',
      );
      
      final result = await _checkoutService.processPayment(request);
      
      if (result.success) {
        // Generate order summary
        await _generateOrderSummary();
      }
      
      return result;
    } catch (e) {
      _errorMessage = 'Payment processing failed: $e';
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> _generateOrderSummary() async {
    if (_currentSession == null) return;
    
    try {
      final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';
      _orderSummary = await _checkoutService.getOrderSummary(orderId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to generate order summary: $e';
    }
  }
  
  // Order confirmation
  Future<bool> confirmOrder() async {
    if (_orderSummary == null) return false;
    
    try {
      _isLoading = true;
      notifyListeners();
      
      final success = await _checkoutService.confirmOrder(_orderSummary!.orderId);
      
      if (success) {
        // Clear checkout data
        _clearCheckout();
      }
      
      return success;
    } catch (e) {
      _errorMessage = 'Failed to confirm order: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void _clearCheckout() {
    _items = [];
    _retailerId = '';
    _retailerName = '';
    _subtotal = 0.0;
    _discountAmount = 0.0;
    _vatAmount = 0.0;
    _deliveryFee = 0.0;
    _totalAmount = 0.0;
    
    _selectedDeliveryOption = null;
    _shippingAddress = null;
    _billingAddress = null;
    _selectedPaymentMethod = null;
    
    _currentSession = null;
    _orderSummary = null;
    
    _promoCodeController.clear();
    _promoError = null;
    _errorMessage = null;
    
    notifyListeners();
  }
  
  // Validation methods
  bool validateCheckout() {
    if (_items.isEmpty) return false;
    if (_selectedDeliveryOption == null) return false;
    if (_shippingAddress == null) return false;
    if (_selectedPaymentMethod == null) return false;
    return true;
  }
  
  String? validateShippingAddress() {
    if (_shippingAddress == null) return 'Shipping address is required';
    if (_shippingAddress!.street.isEmpty) return 'Street address is required';
    if (_shippingAddress!.city.isEmpty) return 'City is required';
    if (_shippingAddress!.state.isEmpty) return 'State is required';
    if (_shippingAddress!.postalCode.isEmpty) return 'Postal code is required';
    return null;
  }
  
  String? validatePaymentDetails(Map<String, dynamic> details) {
    if (_selectedPaymentMethod == null) return 'Payment method is required';
    
    switch (_selectedPaymentMethod!.type) {
      case PaymentType.digital:
        if (!details.containsKey('phoneNumber') || details['phoneNumber'].toString().isEmpty) {
          return 'Phone number is required';
        }
        break;
      case PaymentType.card:
        if (!details.containsKey('cardNumber') || details['cardNumber'].toString().length < 16) {
          return 'Valid card number is required';
        }
        if (!details.containsKey('cvv') || details['cvv'].toString().length < 3) {
          return 'Valid CVV is required';
        }
        break;
      case PaymentType.bank:
        if (!details.containsKey('accountNumber') || details['accountNumber'].toString().isEmpty) {
          return 'Account number is required';
        }
        break;
      default:
        break;
    }
    
    return null;
  }
  
  // Utility methods
  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);
  
  bool get hasDiscount => _discountAmount > 0;
  
  bool get isFreeDelivery => _deliveryFee == 0.0;
  
  String get estimatedDelivery {
    if (_selectedDeliveryOption == null) return 'Not available';
    return _selectedDeliveryOption!.estimatedDeliveryText;
  }
  
  double get paymentFee {
    if (_selectedPaymentMethod == null) return 0.0;
    return _selectedPaymentMethod!.calculateFee(_totalAmount);
  }
  
  // Error handling
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  void clearPromoError() {
    _promoError = null;
    notifyListeners();
  }
  
  // Dispose
  @override
  void dispose() {
    _promoCodeController.dispose();
    _checkoutService.dispose();
    super.dispose();
  }
}

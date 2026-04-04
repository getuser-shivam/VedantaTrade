import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:async';
import '../../../shared/widgets/premium_glassmorphic_theme.dart';
import '../models/checkout_models.dart';
import '../models/payment_models.dart';

class CheckoutService {
  static final CheckoutService _instance = CheckoutService._internal();
  factory CheckoutService() => _instance;
  CheckoutService._internal();

  late final Dio _dio;
  final StreamController<CheckoutSession> _sessionController = 
      StreamController<CheckoutSession>.broadcast();
  final StreamController<List<PaymentMethod>> _paymentMethodsController = 
      StreamController<List<PaymentMethod>>.broadcast();
  final StreamController<OrderStatus> _orderStatusController = 
      StreamController<OrderStatus>.broadcast();

  CheckoutSession? _currentSession;
  List<PaymentMethod> _availablePaymentMethods = [];
  OrderStatus _currentOrderStatus = OrderStatus.pending;
  
  Timer? _sessionTimer;
  String? _currentUserId;

  // Stream getters
  Stream<CheckoutSession> get sessionStream => _sessionController.stream;
  Stream<List<PaymentMethod>> get paymentMethodsStream => _paymentMethodsController.stream;
  Stream<OrderStatus> get orderStatusStream => _orderStatusController.stream;

  // Data getters
  CheckoutSession? get currentSession => _currentSession;
  List<PaymentMethod> get availablePaymentMethods => List.unmodifiable(_availablePaymentMethods);
  OrderStatus get currentOrderStatus => _currentOrderStatus;

  void initialize({String? userId}) {
    try {
      debugPrint('🛒 Initializing Checkout Service...');
      
      _currentUserId = userId;
      _setupDioClient();
      _loadPaymentMethods();
      
      debugPrint('✅ Checkout Service initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize Checkout Service: $e');
      _sessionController.addError(e);
    }
  }

  void _setupDioClient() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://api.vedantatrade.com.np',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'X-Country': 'NP',
        'X-Currency': 'NPR',
        'X-Timezone': 'Asia/Kathmandu',
      },
    ));

    // Add request interceptor for authentication
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          // final token = await _getAuthToken();
          // if (token != null) {
          //   options.headers['Authorization'] = 'Bearer $token';
          // }
          handler.next(options);
        },
        onError: (error, handler) {
          debugPrint('Checkout API Error: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  Future<void> _loadPaymentMethods() async {
    try {
      debugPrint('💳 Loading payment methods...');
      
      final response = await _dio.get('/api/payments/methods');
      if (response.statusCode == 200) {
        _availablePaymentMethods = (response.data['methods'] as List)
            .map((json) => PaymentMethod.fromJson(json))
            .toList();
        _paymentMethodsController.add(_availablePaymentMethods);
      }
    } catch (e) {
      debugPrint('Failed to load payment methods: $e');
      // Load mock payment methods as fallback
      await _loadMockPaymentMethods();
    }
  }

  Future<void> _loadMockPaymentMethods() async {
    debugPrint('📋 Loading mock payment methods...');
    
    _availablePaymentMethods = [
      PaymentMethod(
        id: 'cod',
        name: 'Cash on Delivery',
        type: PaymentType.cod,
        description: 'Pay when you receive your order',
        icon: 'local_shipping',
        isEnabled: true,
        fee: 0.0,
        feeType: FeeType.fixed,
        minAmount: 0.0,
        maxAmount: 50000.0,
        processingTime: const Duration(minutes: 0),
        supportedRegions: ['Kathmandu', 'Pokhara', 'Biratnagar', 'All Nepal'],
      ),
      PaymentMethod(
        id: 'khalti',
        name: 'Khalti Digital Wallet',
        type: PaymentType.digital,
        description: 'Pay instantly with Khalti wallet',
        icon: 'account_balance_wallet',
        isEnabled: true,
        fee: 0.02,
        feeType: FeeType.percentage,
        minAmount: 100.0,
        maxAmount: 100000.0,
        processingTime: const Duration(seconds: 30),
        supportedRegions: ['All Nepal'],
      ),
      PaymentMethod(
        id: 'esewa',
        name: 'eSewa Digital Wallet',
        type: PaymentType.digital,
        description: 'Pay with eSewa mobile wallet',
        icon: 'smartphone',
        isEnabled: true,
        fee: 0.015,
        feeType: FeeType.percentage,
        minAmount: 100.0,
        maxAmount: 50000.0,
        processingTime: const Duration(seconds: 45),
        supportedRegions: ['All Nepal'],
      ),
      PaymentMethod(
        id: 'bank_transfer',
        name: 'Bank Transfer',
        type: PaymentType.bank,
        description: 'Direct bank transfer to our account',
        icon: 'account_balance',
        isEnabled: true,
        fee: 0.01,
        feeType: FeeType.percentage,
        minAmount: 500.0,
        maxAmount: 1000000.0,
        processingTime: const Duration(hours: 1),
        supportedRegions: ['All Nepal'],
      ),
      PaymentMethod(
        id: 'credit_card',
        name: 'Credit/Debit Card',
        type: PaymentType.card,
        description: 'Pay with Visa, Mastercard, or other cards',
        icon: 'credit_card',
        isEnabled: true,
        fee: 0.025,
        feeType: FeeType.percentage,
        minAmount: 100.0,
        maxAmount: 200000.0,
        processingTime: const Duration(minutes: 2),
        supportedRegions: ['All Nepal'],
      ),
    ];
    
    _paymentMethodsController.add(_availablePaymentMethods);
    debugPrint('✅ Mock payment methods loaded');
  }

  Future<CheckoutSession> initiateCheckout(CheckoutRequest request) async {
    try {
      debugPrint('🛒 Initiating checkout...');
      
      final response = await _dio.post('/api/checkout/initiate', data: request.toJson());
      
      if (response.statusCode == 201) {
        _currentSession = CheckoutSession.fromJson(response.data['session']);
        _sessionController.add(_currentSession!);
        
        // Start session timeout timer
        _startSessionTimer();
        
        debugPrint('✅ Checkout session initiated: ${_currentSession!.id}');
        return _currentSession!;
      }
    } catch (e) {
      debugPrint('Failed to initiate checkout: $e');
      // Create mock session as fallback
      return _createMockSession(request);
    }
    
    throw Exception('Failed to initiate checkout');
  }

  CheckoutSession _createMockSession(CheckoutRequest request) {
    final sessionId = 'checkout_${DateTime.now().millisecondsSinceEpoch}';
    final session = CheckoutSession(
      id: sessionId,
      retailerId: request.retailerId,
      retailerName: request.retailerName,
      items: request.items,
      subtotal: request.subtotal,
      discountAmount: request.discountAmount,
      vatAmount: request.vatAmount,
      deliveryFee: request.deliveryFee,
      totalAmount: request.totalAmount,
      currency: 'NPR',
      status: CheckoutStatus.pending,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(minutes: 30)),
      paymentMethod: null,
      shippingAddress: request.shippingAddress,
      billingAddress: request.billingAddress,
      notes: request.notes,
    );
    
    _currentSession = session;
    _sessionController.add(session);
    _startSessionTimer();
    
    return session;
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_currentSession != null && _currentSession!.expiresAt.isBefore(DateTime.now())) {
        _expireSession();
      }
    });
  }

  void _expireSession() {
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(
        status: CheckoutStatus.expired,
      );
      _sessionController.add(_currentSession!);
      _sessionTimer?.cancel();
      debugPrint('⏰ Checkout session expired');
    }
  }

  Future<PaymentResult> processPayment(PaymentRequest request) async {
    try {
      debugPrint('💳 Processing payment...');
      
      if (_currentSession == null) {
        throw Exception('No active checkout session');
      }
      
      final response = await _dio.post('/api/payments/process', data: {
        ...request.toJson(),
        'sessionId': _currentSession!.id,
      });
      
      if (response.statusCode == 200) {
        final result = PaymentResult.fromJson(response.data['result']);
        
        // Update session status
        if (result.success) {
          _currentSession = _currentSession!.copyWith(
            status: CheckoutStatus.paid,
            paymentMethod: request.paymentMethodId,
            completedAt: DateTime.now(),
          );
          _sessionController.add(_currentSession!);
        }
        
        debugPrint('✅ Payment processed: ${result.success ? 'Success' : 'Failed'}');
        return result;
      }
    } catch (e) {
      debugPrint('Failed to process payment: $e');
      // Return mock result as fallback
      return _createMockPaymentResult(request);
    }
    
    throw Exception('Failed to process payment');
  }

  PaymentResult _createMockPaymentResult(PaymentRequest request) {
    // Simulate payment processing
    final isSuccess = DateTime.now().millisecond % 10 > 2; // 80% success rate
    
    if (isSuccess) {
      _currentSession = _currentSession!.copyWith(
        status: CheckoutStatus.paid,
        paymentMethod: request.paymentMethodId,
        completedAt: DateTime.now(),
      );
      _sessionController.add(_currentSession!);
    }
    
    return PaymentResult(
      success: isSuccess,
      transactionId: isSuccess ? 'txn_${DateTime.now().millisecondsSinceEpoch}' : null,
      paymentMethodId: request.paymentMethodId,
      amount: request.amount,
      currency: 'NPR',
      status: isSuccess ? PaymentStatus.completed : PaymentStatus.failed,
      processedAt: DateTime.now(),
      failureReason: isSuccess ? null : 'Payment processing failed',
      metadata: {
        'sessionId': _currentSession?.id,
        'retailerId': _currentSession?.retailerId,
      },
    );
  }

  Future<bool> confirmOrder(String orderId) async {
    try {
      debugPrint('📦 Confirming order: $orderId');
      
      final response = await _dio.post('/api/orders/confirm', data: {
        'orderId': orderId,
        'sessionId': _currentSession?.id,
      });
      
      if (response.statusCode == 200) {
        _currentOrderStatus = OrderStatus.confirmed;
        _orderStatusController.add(_currentOrderStatus);
        
        debugPrint('✅ Order confirmed: $orderId');
        return true;
      }
    } catch (e) {
      debugPrint('Failed to confirm order: $e');
    }
    
    return false;
  }

  Future<OrderSummary> getOrderSummary(String orderId) async {
    try {
      debugPrint('📋 Getting order summary: $orderId');
      
      final response = await _dio.get('/api/orders/$orderId/summary');
      
      if (response.statusCode == 200) {
        return OrderSummary.fromJson(response.data['summary']);
      }
    } catch (e) {
      debugPrint('Failed to get order summary: $e');
      // Return mock summary as fallback
      return _createMockOrderSummary(orderId);
    }
    
    throw Exception('Failed to get order summary');
  }

  OrderSummary _createMockOrderSummary(String orderId) {
    if (_currentSession == null) {
      throw Exception('No active checkout session');
    }
    
    return OrderSummary(
      orderId: orderId,
      retailerId: _currentSession!.retailerId,
      retailerName: _currentSession!.retailerName,
      items: _currentSession!.items,
      subtotal: _currentSession!.subtotal,
      discountAmount: _currentSession!.discountAmount,
      vatAmount: _currentSession!.vatAmount,
      deliveryFee: _currentSession!.deliveryFee,
      totalAmount: _currentSession!.totalAmount,
      currency: _currentSession!.currency,
      status: _currentSession!.status == CheckoutStatus.paid 
          ? OrderStatus.confirmed 
          : OrderStatus.pending,
      paymentMethod: _currentSession!.paymentMethod,
      paymentStatus: _currentSession!.status == CheckoutStatus.paid 
          ? PaymentStatus.paid 
          : PaymentStatus.pending,
      createdAt: _currentSession!.createdAt,
      estimatedDelivery: DateTime.now().add(const Duration(days: 2)),
      trackingNumber: _currentSession!.status == CheckoutStatus.paid 
          ? 'VT${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}'
          : null,
      shippingAddress: _currentSession!.shippingAddress,
      notes: _currentSession!.notes,
    );
  }

  Future<List<DeliveryOption>> getDeliveryOptions(String retailerId) async {
    try {
      debugPrint('🚚 Getting delivery options for retailer: $retailerId');
      
      final response = await _dio.get('/api/delivery/options/$retailerId');
      
      if (response.statusCode == 200) {
        return (response.data['options'] as List)
            .map((json) => DeliveryOption.fromJson(json))
            .toList();
      }
    } catch (e) {
      debugPrint('Failed to get delivery options: $e');
      // Return mock options as fallback
      return _getMockDeliveryOptions(retailerId);
    }
    
    throw Exception('Failed to get delivery options');
  }

  List<DeliveryOption> _getMockDeliveryOptions(String retailerId) {
    return [
      DeliveryOption(
        id: 'standard',
        name: 'Standard Delivery',
        description: 'Delivery within 2-3 business days',
        price: 50.0,
        estimatedDays: 3,
        available: true,
        regions: ['Kathmandu', 'Pokhara', 'Biratnagar'],
      ),
      DeliveryOption(
        id: 'express',
        name: 'Express Delivery',
        description: 'Delivery within 24 hours',
        price: 150.0,
        estimatedDays: 1,
        available: true,
        regions: ['Kathmandu', 'Pokhara'],
      ),
      DeliveryOption(
        id: 'pickup',
        name: 'Store Pickup',
        description: 'Pick up from our warehouse',
        price: 0.0,
        estimatedDays: 0,
        available: true,
        regions: ['Kathmandu', 'Pokhara', 'Biratnagar'],
      ),
    ];
  }

  Future<bool> applyPromoCode(String promoCode, String sessionId) async {
    try {
      debugPrint('🎫 Applying promo code: $promoCode');
      
      final response = await _dio.post('/api/promotions/apply', data: {
        'promoCode': promoCode,
        'sessionId': sessionId,
      });
      
      if (response.statusCode == 200) {
        final discount = response.data['discount'] as double;
        
        if (_currentSession != null) {
          _currentSession = _currentSession!.copyWith(
            discountAmount: discount,
            totalAmount: _currentSession!.subtotal + _currentSession!.vatAmount + 
                        _currentSession!.deliveryFee - discount,
          );
          _sessionController.add(_currentSession!);
        }
        
        debugPrint('✅ Promo code applied: $promoCode (Discount: NPR $discount)');
        return true;
      }
    } catch (e) {
      debugPrint('Failed to apply promo code: $e');
    }
    
    return false;
  }

  Future<bool> validateInventory(CheckoutRequest request) async {
    try {
      debugPrint('📦 Validating inventory...');
      
      final response = await _dio.post('/api/inventory/validate', data: {
        'items': request.items.map((item) => item.toJson()).toList(),
      });
      
      if (response.statusCode == 200) {
        final isValid = response.data['valid'] as bool;
        debugPrint('✅ Inventory validation: ${isValid ? 'Valid' : 'Invalid'}');
        return isValid;
      }
    } catch (e) {
      debugPrint('Failed to validate inventory: $e');
    }
    
    return true; // Assume valid for mock
  }

  void cancelSession() {
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(
        status: CheckoutStatus.cancelled,
      );
      _sessionController.add(_currentSession!);
      _sessionTimer?.cancel();
      debugPrint('❌ Checkout session cancelled');
    }
  }

  void clearSession() {
    _currentSession = null;
    _sessionTimer?.cancel();
    _sessionController.add(null);
    debugPrint('🗑️ Checkout session cleared');
  }

  double calculateDeliveryFee(String retailerId, double orderValue, String deliveryOption) {
    // Mock delivery fee calculation
    final baseFee = 50.0;
    final weightFee = orderValue > 10000 ? 100.0 : 0.0;
    final expressFee = deliveryOption == 'express' ? 100.0 : 0.0;
    
    return baseFee + weightFee + expressFee;
  }

  double calculateVAT(double amount) {
    // Nepal VAT: 13%
    return amount * 0.13;
  }

  double calculateDiscount(double subtotal, String promoCode) {
    // Mock discount calculation
    switch (promoCode.toLowerCase()) {
      case 'welcome10':
        return subtotal * 0.10;
      case 'save20':
        return subtotal * 0.20;
      case 'first5':
        return subtotal * 0.05;
      default:
        return 0.0;
    }
  }

  void dispose() {
    debugPrint('🗑️ Disposing Checkout Service...');
    
    _sessionTimer?.cancel();
    _sessionController.close();
    _paymentMethodsController.close();
    _orderStatusController.close();
    
    debugPrint('✅ Checkout Service disposed');
  }
}

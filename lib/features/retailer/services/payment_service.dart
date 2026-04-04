import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Payment service for Nepal-specific payment processing
class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  late Dio _dio;
  final StreamController<PaymentStatus> _paymentStatusController = 
      StreamController<PaymentStatus>.broadcast();
  
  Stream<PaymentStatus> get paymentStatusStream => _paymentStatusController.stream;

  /// Initialize payment service
  Future<void> initialize() async {
    try {
      print('💳 Initializing Payment Service...');
      
      // Setup Dio client
      _setupDioClient();
      
      print('✅ Payment Service initialized');
      
    } catch (e) {
      print('❌ Failed to initialize Payment Service: $e');
      _paymentStatusController.addError(e);
    }
  }

  /// Setup Dio client with Nepal-specific configurations
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
        'X-VAT-Rate': '13', // Nepal VAT rate
      },
    ));

    // Add request interceptor for authentication
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          handler.next(options);
        },
        onError: (error, handler) async {
          print('Payment API Error: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  /// Process payment with Nepal-specific validation
  Future<Map<String, dynamic>> processPayment(Map<String, dynamic> orderData) async {
    try {
      print('💳 Processing payment...');
      
      // Validate order data
      _validateOrderData(orderData);
      
      // Add Nepal-specific processing
      final nepalOrderData = _addNepalSpecificData(orderData);
      
      // Process payment based on method
      final paymentResult = await _processPaymentByMethod(
        nepalOrderData['paymentMethod'],
        nepalOrderData,
      );
      
      if (paymentResult['success']) {
        // Create order in backend
        final orderResult = await _createOrder(nepalOrderData);
        
        if (orderResult['success']) {
          // Generate receipt
          final receipt = await _generateReceipt(orderResult['orderId']);
          
          // Send confirmation
          await _sendOrderConfirmation(orderResult['orderId'], nepalOrderData);
          
          print('✅ Payment processed successfully');
          return {
            'success': true,
            'orderId': orderResult['orderId'],
            'receipt': receipt,
            'transactionId': paymentResult['transactionId'],
          };
        } else {
          throw Exception('Failed to create order: ${orderResult['error']}');
        }
      } else {
        throw Exception('Payment failed: ${paymentResult['error']}');
      }
      
    } catch (e) {
      print('❌ Failed to process payment: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Validate order data
  void _validateOrderData(Map<String, dynamic> orderData) {
    // Check required fields
    final requiredFields = [
      'items',
      'subtotal',
      'vatAmount',
      'totalAmount',
      'paymentMethod',
      'shipping',
    ];
    
    for (final field in requiredFields) {
      if (!orderData.containsKey(field) || orderData[field] == null) {
        throw Exception('Missing required field: $field');
      }
    }
    
    // Validate shipping information
    final shipping = orderData['shipping'];
    final shippingFields = ['name', 'phone', 'address', 'city'];
    
    for (final field in shippingFields) {
      if (!shipping.containsKey(field) || shipping[field]?.toString().trim().isEmpty == true) {
        throw Exception('Missing required shipping field: $field');
      }
    }
    
    // Validate phone number (Nepal format)
    final phone = shipping['phone'].toString();
    if (!_isValidNepalPhone(phone)) {
      throw Exception('Invalid Nepal phone number format');
    }
    
    // Validate total amount
    final totalAmount = orderData['totalAmount'] as double;
    if (totalAmount <= 0) {
      throw Exception('Invalid total amount');
    }
  }

  /// Add Nepal-specific data
  Map<String, dynamic> _addNepalSpecificData(Map<String, dynamic> orderData) {
    return {
      ...orderData,
      'country': 'NP',
      'currency': 'NPR',
      'vatRate': 13.0,
      'timezone': 'Asia/Kathmandu',
      'locale': 'ne_NP',
      'regionalData': {
        'state': 'Province 2', // Janakpur is in Province 2
        'district': 'Dhanusha',
        'municipality': 'Janakpur',
      },
      'compliance': {
        'taxCompliant': true,
        'pharmaceuticalLicense': true,
        'medicalSupplyRegulation': true,
      },
    };
  }

  /// Process payment by method
  Future<Map<String, dynamic>> _processPaymentByMethod(
    String paymentMethod,
    Map<String, dynamic> orderData,
  ) async {
    switch (paymentMethod) {
      case 'cash':
        return await _processCashPayment(orderData);
      case 'card':
        return await _processCardPayment(orderData);
      case 'bank':
        return await _processBankTransfer(orderData);
      default:
        throw Exception('Unsupported payment method: $paymentMethod');
    }
  }

  /// Process cash payment
  Future<Map<String, dynamic>> _processCashPayment(Map<String, dynamic> orderData) async {
    try {
      print('💰 Processing cash payment...');
      
      // Create cash payment record
      final paymentData = {
        'method': 'cash',
        'amount': orderData['totalAmount'],
        'currency': 'NPR',
        'status': 'pending',
        'description': 'Cash on delivery',
        'metadata': {
          'deliveryInstructions': 'Collect exact amount from customer',
          'changePolicy': 'Provide change if needed',
          'receiptRequired': true,
        },
      };
      
      final response = await _dio.post(
        '/api/payments/cash',
        data: paymentData,
      );
      
      if (response.statusCode == 201) {
        final payment = response.data['payment'];
        return {
          'success': true,
          'transactionId': payment['id'],
          'paymentMethod': 'cash',
          'status': 'pending_delivery',
        };
      }
      
    } catch (e) {
      print('❌ Failed to process cash payment: $e');
    }
    
    return {
      'success': false,
      'error': 'Failed to process cash payment',
    };
  }

  /// Process card payment
  Future<Map<String, dynamic>> _processCardPayment(Map<String, dynamic> orderData) async {
    try {
      print('💳 Processing card payment...');
      
      final payment = orderData['payment'];
      
      // Validate card details
      _validateCardDetails(payment);
      
      // Create card payment request
      final paymentData = {
        'method': 'card',
        'amount': orderData['totalAmount'],
        'currency': 'NPR',
        'cardDetails': {
          'number': _maskCardNumber(payment['cardNumber']),
          'expiry': payment['expiry'],
          'cvv': payment['cvv'],
        },
        'billingAddress': {
          'name': orderData['shipping']['name'],
          'address': orderData['shipping']['address'],
          'city': orderData['shipping']['city'],
          'country': 'NP',
        },
        'nepalSpecific': {
          'bankCode': _getBankCode(payment['cardNumber']),
          'cardType': _getCardType(payment['cardNumber']),
          'region': 'Asia/Kathmandu',
        },
      };
      
      // Process through Nepal payment gateway
      final response = await _dio.post(
        '/api/payments/card',
        data: paymentData,
      );
      
      if (response.statusCode == 201) {
        final payment = response.data['payment'];
        return {
          'success': true,
          'transactionId': payment['id'],
          'paymentMethod': 'card',
          'status': payment['status'],
          'gatewayResponse': payment['gatewayResponse'],
        };
      }
      
    } catch (e) {
      print('❌ Failed to process card payment: $e');
    }
    
    return {
      'success': false,
      'error': 'Failed to process card payment',
    };
  }

  /// Process bank transfer
  Future<Map<String, dynamic>> _processBankTransfer(Map<String, dynamic> orderData) async {
    try {
      print('🏦 Processing bank transfer...');
      
      final payment = orderData['payment'];
      
      // Validate bank details
      _validateBankDetails(payment);
      
      // Create bank transfer request
      final paymentData = {
        'method': 'bank',
        'amount': orderData['totalAmount'],
        'currency': 'NPR',
        'bankDetails': {
          'accountNumber': payment['accountNumber'],
          'bankName': payment['bankName'],
          'accountHolder': 'VedantaTrade Pvt. Ltd.',
        },
        'nepalSpecific': {
          'routingNumber': _getRoutingNumber(payment['bankName']),
          'swiftCode': _getSwiftCode(payment['bankName']),
          'branchCode': 'JNK', // Janakpur branch
        },
      };
      
      final response = await _dio.post(
        '/api/payments/bank',
        data: paymentData,
      );
      
      if (response.statusCode == 201) {
        final payment = response.data['payment'];
        return {
          'success': true,
          'transactionId': payment['id'],
          'paymentMethod': 'bank',
          'status': 'pending_verification',
          'bankReference': payment['bankReference'],
        };
      }
      
    } catch (e) {
      print('❌ Failed to process bank transfer: $e');
    }
    
    return {
      'success': false,
      'error': 'Failed to process bank transfer',
    };
  }

  /// Create order in backend
  Future<Map<String, dynamic>> _createOrder(Map<String, dynamic> orderData) async {
    try {
      print('📦 Creating order...');
      
      final orderRequest = {
        'items': orderData['items'],
        'subtotal': orderData['subtotal'],
        'vatAmount': orderData['vatAmount'],
        'totalAmount': orderData['totalAmount'],
        'currency': 'NPR',
        'shipping': orderData['shipping'],
        'payment': {
          'method': orderData['paymentMethod'],
          'status': 'pending',
        },
        'nepalSpecific': orderData['regionalData'],
        'compliance': orderData['compliance'],
        'createdAt': DateTime.now().toIso8601String(),
      };
      
      final response = await _dio.post(
        '/api/orders',
        data: orderRequest,
      );
      
      if (response.statusCode == 201) {
        final order = response.data['order'];
        return {
          'success': true,
          'orderId': order['id'],
          'orderNumber': order['orderNumber'],
        };
      }
      
    } catch (e) {
      print('❌ Failed to create order: $e');
    }
    
    return {
      'success': false,
      'error': 'Failed to create order',
    };
  }

  /// Generate receipt
  Future<Map<String, dynamic>> _generateReceipt(String orderId) async {
    try {
      print('🧾 Generating receipt...');
      
      final response = await _dio.post(
        '/api/receipts/generate',
        data: {
          'orderId': orderId,
          'template': 'nepal_standard',
          'language': 'ne',
          'currency': 'NPR',
        },
      );
      
      if (response.statusCode == 201) {
        final receipt = response.data['receipt'];
        return {
          'success': true,
          'receiptId': receipt['id'],
          'receiptNumber': receipt['receiptNumber'],
          'pdfUrl': receipt['pdfUrl'],
          'qrCode': receipt['qrCode'],
        };
      }
      
    } catch (e) {
      print('❌ Failed to generate receipt: $e');
    }
    
    return {
      'success': false,
      'error': 'Failed to generate receipt',
    };
  }

  /// Send order confirmation
  Future<void> _sendOrderConfirmation(String orderId, Map<String, dynamic> orderData) async {
    try {
      print('📧 Sending order confirmation...');
      
      final confirmationData = {
        'orderId': orderId,
        'customerName': orderData['shipping']['name'],
        'customerPhone': orderData['shipping']['phone'],
        'customerEmail': orderData['shipping']['email'] ?? '',
        'totalAmount': orderData['totalAmount'],
        'currency': 'NPR',
        'deliveryAddress': orderData['shipping']['address'],
        'deliveryCity': orderData['shipping']['city'],
        'paymentMethod': orderData['paymentMethod'],
        'estimatedDelivery': _calculateEstimatedDelivery(),
        'nepalSpecific': {
          'deliveryInstructions': 'Deliver during business hours (9 AM - 6 PM)',
          'contactNumber': '+977-XXXXXXXXX', // Nepal contact number
        },
      };
      
      await _dio.post(
        '/api/notifications/order-confirmation',
        data: confirmationData,
      );
      
      print('✅ Order confirmation sent');
      
    } catch (e) {
      print('❌ Failed to send order confirmation: $e');
    }
  }

  /// Validate card details
  void _validateCardDetails(Map<String, dynamic> payment) {
    final cardNumber = payment['cardNumber']?.toString() ?? '';
    final expiry = payment['expiry']?.toString() ?? '';
    final cvv = payment['cvv']?.toString() ?? '';
    
    if (cardNumber.length < 16 || cardNumber.length > 19) {
      throw Exception('Invalid card number');
    }
    
    if (!_isValidExpiry(expiry)) {
      throw Exception('Invalid expiry date');
    }
    
    if (cvv.length < 3 || cvv.length > 4) {
      throw Exception('Invalid CVV');
    }
  }

  /// Validate bank details
  void _validateBankDetails(Map<String, dynamic> payment) {
    final accountNumber = payment['accountNumber']?.toString() ?? '';
    final bankName = payment['bankName']?.toString() ?? '';
    
    if (accountNumber.length < 10 || accountNumber.length > 20) {
      throw Exception('Invalid account number');
    }
    
    if (bankName.isEmpty) {
      throw Exception('Bank name is required');
    }
  }

  /// Check if Nepal phone number is valid
  bool _isValidNepalPhone(String phone) {
    // Nepal phone numbers: +977-XXXXXXXXX or 01-XXXXXXX
    final nepalPhonePattern = RegExp(r'^(\+977|01)?[0-9]{7,10}$');
    return nepalPhonePattern.hasMatch(phone);
  }

  /// Check if expiry date is valid
  bool _isValidExpiry(String expiry) {
    if (expiry.length != 5 || !expiry.contains('/')) {
      return false;
    }
    
    final parts = expiry.split('/');
    final month = int.tryParse(parts[0]);
    final year = int.tryParse('20${parts[1]}');
    
    if (month == null || year == null) {
      return false;
    }
    
    final now = DateTime.now();
    final expiryDate = DateTime(year, month);
    
    return expiryDate.isAfter(now);
  }

  /// Mask card number
  String _maskCardNumber(String cardNumber) {
    if (cardNumber.length < 4) return cardNumber;
    
    final lastFour = cardNumber.substring(cardNumber.length - 4);
    final maskedPart = '*' * (cardNumber.length - 4);
    
    return '$maskedPart$lastFour';
  }

  /// Get bank code from card number
  String _getBankCode(String cardNumber) {
    // Nepal bank identification by BIN (Bank Identification Number)
    // This is a simplified implementation
    final bin = cardNumber.substring(0, 6);
    
    // Nepal bank codes (simplified)
    final bankCodes = {
      '426242': 'NABIL',
      '426243': 'NABIL',
      '453432': 'SBL',
      '453433': 'SBL',
      '453434': 'SBL',
      '453435': 'SBL',
      '453436': 'SBL',
      '453437': 'SBL',
      '453438': 'SBL',
      '453439': 'SBL',
    };
    
    return bankCodes[bin] ?? 'UNKNOWN';
  }

  /// Get card type from card number
  String _getCardType(String cardNumber) {
    if (cardNumber.startsWith('4')) {
      return 'VISA';
    } else if (cardNumber.startsWith('5')) {
      return 'MASTERCARD';
    } else if (cardNumber.startsWith('3')) {
      return 'AMEX';
    } else {
      return 'UNKNOWN';
    }
  }

  /// Get routing number for Nepal bank
  String _getRoutingNumber(String bankName) {
    final routingNumbers = {
      'Nepal Investment Bank': 'NIBLNPKT',
      'Nabil Bank': 'NABILNPK',
      'Standard Chartered': 'SCBLNPKT',
      'Himalayan Bank': 'HIMBLNPKT',
      'Agricultural Development Bank': 'ADBLNPKT',
      'Kumari Bank': 'KUMBLNPKT',
    };
    
    return routingNumbers[bankName] ?? 'UNKNOWN';
  }

  /// Get SWIFT code for Nepal bank
  String _getSwiftCode(String bankName) {
    final swiftCodes = {
      'Nepal Investment Bank': 'NIBLNPKT',
      'Nabil Bank': 'NARBNPKA',
      'Standard Chartered': 'SCBLNPKT',
      'Himalayan Bank': 'HIMBLNPKT',
      'Agricultural Development Bank': 'ADBLNPKT',
      'Kumari Bank': 'KUMBLNPKT',
    };
    
    return swiftCodes[bankName] ?? 'UNKNOWN';
  }

  /// Calculate estimated delivery
  String _calculateEstimatedDelivery() {
    final now = DateTime.now();
    
    // Nepal business days (Sunday - Friday)
    int businessDays = 0;
    DateTime deliveryDate = now;
    
    while (businessDays < 3) { // 3 business days delivery
      deliveryDate = deliveryDate.add(const Duration(days: 1));
      
      // Skip Saturday (day 6)
      if (deliveryDate.weekday != 6) {
        businessDays++;
      }
    }
    
    return deliveryDate.toIso8601String();
  }

  /// Get payment status
  Future<PaymentStatus> getPaymentStatus(String transactionId) async {
    try {
      final response = await _dio.get(
        '/api/payments/$transactionId/status',
      );
      
      if (response.statusCode == 200) {
        final status = response.data['status'];
        return PaymentStatus.values.firstWhere(
          (e) => e.toString() == status,
          orElse: () => PaymentStatus.pending,
        );
      }
    } catch (e) {
      print('❌ Failed to get payment status: $e');
    }
    
    return PaymentStatus.failed;
  }

  /// Cancel payment
  Future<bool> cancelPayment(String transactionId) async {
    try {
      final response = await _dio.post(
        '/api/payments/$transactionId/cancel',
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Failed to cancel payment: $e');
      return false;
    }
  }

  /// Refund payment
  Future<bool> refundPayment(String transactionId, double? amount) async {
    try {
      final response = await _dio.post(
        '/api/payments/$transactionId/refund',
        data: {
          'amount': amount,
          'reason': 'Customer request',
          'currency': 'NPR',
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Failed to refund payment: $e');
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    print('🗑️ Disposing Payment Service...');
    
    _paymentStatusController.close();
    
    print('✅ Payment Service disposed');
  }
}

/// Payment status enum
enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
  refunded,
  pending_verification,
  pending_delivery,
}

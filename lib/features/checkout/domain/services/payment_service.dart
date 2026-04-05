import 'dart:async';
import 'dart:math';
import 'package:dartz/dartz.dart';
import '../entities/payment_entity.dart';
import '../repositories/payment_repository.dart';
import '../../../../shared/utils/app_utils.dart';

/// Payment Service for VedantaTrade
/// Handles payment processing, checkout flows, and payment gateway integration
class PaymentService {
  final PaymentRepository _repository;
  final AppUtils _appUtils;
  
  PaymentService({
    required PaymentRepository repository,
    AppUtils? appUtils,
  }) : _repository = repository,
       _appUtils = appUtils ?? AppUtils();
  
  /// Create checkout session
  Future<Either<String, CheckoutSession>> createCheckoutSession({
    required String retailerId,
    required List<PaymentItem> items,
    Address? billingAddress,
    Address? shippingAddress,
    PaymentMethod? paymentMethod,
    PaymentGateway? gateway,
    String? couponCode,
  }) async {
    try {
      // Validate items
      final validationResult = _validateCheckoutItems(items);
      if (validationResult != null) {
        return Left(validationResult);
      }
      
      // Calculate totals
      final totals = _calculateTotals(items, couponCode);
      
      // Apply coupon if provided
      Coupon? coupon;
      if (couponCode != null && couponCode!.isNotEmpty) {
        final couponResult = await _validateCoupon(couponCode!, totals.subtotal);
        couponResult.fold(
          (error) => coupon = null,
          (validCoupon) => coupon = validCoupon,
        );
      }
      
      // Apply coupon discount
      if (coupon != null) {
        totals = _applyCouponDiscount(totals, coupon!);
      }
      
      // Calculate shipping
      final shippingCost = await _calculateShippingCost(shippingAddress, items);
      
      // Create checkout session
      final checkoutSession = CheckoutSession(
        id: _appUtils.generateId(),
        retailerId: retailerId,
        items: items,
        subtotal: totals.subtotal,
        taxAmount: totals.taxAmount,
        discountAmount: totals.discountAmount,
        shippingAmount: shippingCost,
        totalAmount: totals.subtotal + totals.taxAmount + totals.discountAmount + shippingCost,
        currency: 'NPR',
        couponCode: coupon?.code,
        couponDiscount: coupon?.discountValue,
        billingAddress: billingAddress,
        shippingAddress: shippingAddress,
        selectedPaymentMethod: paymentMethod,
        selectedGateway: gateway ?? PaymentGateway.khalti,
        status: CheckoutStatus.cart,
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
        metadata: {
          'deviceInfo': await _appUtils.getDeviceInfo(),
          'ipAddress': await _appUtils.getIpAddress(),
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Save checkout session
      final result = await _repository.createCheckoutSession(checkoutSession);
      
      return result.fold(
        (error) => Left(error),
        (session) => Right(session),
      );
    } catch (e) {
      return Left('Failed to create checkout session: ${e.toString()}');
    }
  }
  
  /// Process payment
  Future<Either<String, PaymentEntity>> processPayment({
    required String checkoutSessionId,
    required PaymentMethod paymentMethod,
    required PaymentGateway gateway,
    Map<String, dynamic>? paymentDetails,
  }) async {
    try {
      // Get checkout session
      final sessionResult = await _repository.getCheckoutSession(checkoutSessionId);
      if (sessionResult.isLeft()) {
        return Left('Checkout session not found');
      }
      
      final session = sessionResult.getOrElse(() => null);
      if (session == null) {
        return const Left('Checkout session not found');
      }
      
      // Validate payment method
      final methodValidation = _validatePaymentMethod(paymentMethod, gateway);
      if (methodValidation != null) {
        return Left(methodValidation);
      }
      
      // Create payment entity
      final payment = PaymentEntity(
        id: _appUtils.generateId(),
        orderId: _appUtils.generateOrderId(),
        retailerId: session.retailerId,
        retailerName: session.retailerName,
        retailerEmail: session.retailerEmail,
        retailerPhone: session.retailerPhone,
        paymentMethod: paymentMethod,
        status: PaymentStatus.pending,
        amount: session.totalAmount,
        taxAmount: session.taxAmount,
        discountAmount: session.discountAmount,
        shippingAmount: session.shippingAmount,
        totalAmount: session.totalAmount,
        currency: session.currency,
        gateway: gateway,
        items: session.items,
        billingAddress: session.billingAddress,
        shippingAddress: session.shippingAddress,
        metadata: {
          ...session.metadata ?? {},
          ...paymentDetails ?? {},
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Process payment based on gateway
      final processedPayment = await _processPaymentGateway(payment, gateway, paymentDetails);
      
      // Save payment
      final result = await _repository.createPayment(processedPayment);
      
      return result.fold(
        (error) => Left(error),
        (savedPayment) => Right(savedPayment),
      );
    } catch (e) {
      return Left('Failed to process payment: ${e.toString()}');
    }
  }
  
  /// Process payment based on gateway
  Future<PaymentEntity> _processPaymentGateway(
    PaymentEntity payment,
    PaymentGateway gateway,
    Map<String, dynamic>? paymentDetails,
  ) async {
    switch (gateway) {
      case PaymentGateway.khalti:
        return await _processKhaltiPayment(payment, paymentDetails);
      case PaymentGateway.esewa:
        return await _processEsewaPayment(payment, paymentDetails);
      case PaymentGateway.imePay:
        return await _processImePayPayment(payment, paymentDetails);
      case PaymentGateway.connectIPS:
        return await _processConnectIPSPayment(payment, paymentDetails);
      case PaymentGateway.stripe:
        return await _processStripePayment(payment, paymentDetails);
      case PaymentGateway.paypal:
        return await _processPayPalPayment(payment, paymentDetails);
      case PaymentGateway.cashOnDelivery:
        return await _processCashOnDeliveryPayment(payment, paymentDetails);
      default:
        return await _processBankTransferPayment(payment, paymentDetails);
    }
  }
  
  /// Process Khalti payment
  Future<PaymentEntity> _processKhaltiPayment(
    PaymentEntity payment,
    Map<String, dynamic>? paymentDetails,
  ) async {
    try {
      // Khalti API integration
      final khaltiResponse = await _callKhaltiAPI(payment, paymentDetails);
      
      if (khaltiResponse['success'] == true) {
        return payment.copyWith(
          status: PaymentStatus.completed,
          transactionId: khaltiResponse['transaction_id'],
          gatewayTransactionId: khaltiResponse['gateway_transaction_id'],
          authorizationCode: khaltiResponse['authorization_code'],
          processedAt: DateTime.now(),
        );
      } else {
        return payment.copyWith(
          status: PaymentStatus.failed,
          failureReason: khaltiResponse['message'] ?? 'Payment failed',
          failureCode: khaltiResponse['error_code'],
          processedAt: DateTime.now(),
        );
      }
    } catch (e) {
      return payment.copyWith(
        status: PaymentStatus.failed,
        failureReason: 'Khalti payment error: ${e.toString()}',
        processedAt: DateTime.now(),
      );
    }
  }
  
  /// Process eSewa payment
  Future<PaymentEntity> _processEsewaPayment(
    PaymentEntity payment,
    Map<String, dynamic>? paymentDetails,
  ) async {
    try {
      // eSewa API integration
      final esewaResponse = await _callEsewaAPI(payment, paymentDetails);
      
      if (esewaResponse['success'] == true) {
        return payment.copyWith(
          status: PaymentStatus.completed,
          transactionId: esewaResponse['transaction_id'],
          gatewayTransactionId: esewaResponse['gateway_transaction_id'],
          authorizationCode: esewaResponse['authorization_code'],
          processedAt: DateTime.now(),
        );
      } else {
        return payment.copyWith(
          status: PaymentStatus.failed,
          failureReason: esewaResponse['message'] ?? 'Payment failed',
          failureCode: esewaResponse['error_code'],
          processedAt: DateTime.now(),
        );
      }
    } catch (e) {
      return payment.copyWith(
        status: PaymentStatus.failed,
        failureReason: 'eSewa payment error: ${e.toString()}',
        processedAt: DateTime.now(),
      );
    }
  }
  
  /// Process IME Pay payment
  Future<PaymentEntity> _processImePayPayment(
    PaymentEntity payment,
    Map<String, dynamic>? paymentDetails,
  ) async {
    try {
      // IME Pay API integration
      final imePayResponse = await _callImePayAPI(payment, paymentDetails);
      
      if (imePayResponse['success'] == true) {
        return payment.copyWith(
          status: PaymentStatus.completed,
          transactionId: imePayResponse['transaction_id'],
          gatewayTransactionId: imePayResponse['gateway_transaction_id'],
          authorizationCode: imePayResponse['authorization_code'],
          processedAt: DateTime.now(),
        );
      } else {
        return payment.copyWith(
          status: PaymentStatus.failed,
          failureReason: imePayResponse['message'] ?? 'Payment failed',
          failureCode: imePayResponse['error_code'],
          processedAt: DateTime.now(),
        );
      }
    } catch (e) {
      return payment.copyWith(
        status: PaymentStatus.failed,
        failureReason: 'IME Pay payment error: ${e.toString()}',
        processedAt: DateTime.now(),
      );
    }
  }
  
  /// Process Connect IPS payment
  Future<PaymentEntity> _processConnectIPSPayment(
    PaymentEntity payment,
    Map<String, dynamic>? paymentDetails,
  ) async {
    try {
      // Connect IPS API integration
      final connectIPSResponse = await _callConnectIPSAPI(payment, paymentDetails);
      
      if (connectIPSResponse['success'] == true) {
        return payment.copyWith(
          status: PaymentStatus.completed,
          transactionId: connectIPSResponse['transaction_id'],
          gatewayTransactionId: connectIPSResponse['gateway_transaction_id'],
          authorizationCode: connectIPSResponse['authorization_code'],
          processedAt: DateTime.now(),
        );
      } else {
        return payment.copyWith(
          status: PaymentStatus.failed,
          failureReason: connectIPSResponse['message'] ?? 'Payment failed',
          failureCode: connectIPSResponse['error_code'],
          processedAt: DateTime.now(),
        );
      }
    } catch (e) {
      return payment.copyWith(
        status: PaymentStatus.failed,
        failureReason: 'Connect IPS payment error: ${e.toString()}',
        processedAt: DateTime.now(),
      );
    }
  }
  
  /// Process Stripe payment
  Future<PaymentEntity> _processStripePayment(
    PaymentEntity payment,
    Map<String, dynamic>? paymentDetails,
  ) async {
    try {
      // Stripe API integration
      final stripeResponse = await _callStripeAPI(payment, paymentDetails);
      
      if (stripeResponse['success'] == true) {
        return payment.copyWith(
          status: PaymentStatus.completed,
          transactionId: stripeResponse['transaction_id'],
          gatewayTransactionId: stripeResponse['gateway_transaction_id'],
          authorizationCode: stripeResponse['authorization_code'],
          processedAt: DateTime.now(),
        );
      } else {
        return payment.copyWith(
          status: PaymentStatus.failed,
          failureReason: stripeResponse['message'] ?? 'Payment failed',
          failureCode: stripeResponse['error_code'],
          processedAt: DateTime.now(),
        );
      }
    } catch (e) {
      return payment.copyWith(
        status: PaymentStatus.failed,
        failureReason: 'Stripe payment error: ${e.toString()}',
        processedAt: DateTime.now(),
      );
    }
  }
  
  /// Process PayPal payment
  Future<PaymentEntity> _processPayPalPayment(
    PaymentEntity payment,
    Map<String, dynamic>? paymentDetails,
  ) async {
    try {
      // PayPal API integration
      final paypalResponse = await _callPayPalAPI(payment, paymentDetails);
      
      if (paypalResponse['success'] == true) {
        return payment.copyWith(
          status: PaymentStatus.completed,
          transactionId: paypalResponse['transaction_id'],
          gatewayTransactionId: paypalResponse['gateway_transaction_id'],
          authorizationCode: paypalResponse['authorization_code'],
          processedAt: DateTime.now(),
        );
      } else {
        return payment.copyWith(
          status: PaymentStatus.failed,
          failureReason: paypalResponse['message'] ?? 'Payment failed',
          failureCode: paypalResponse['error_code'],
          processedAt: DateTime.now(),
        );
      }
    } catch (e) {
      return payment.copyWith(
        status: PaymentStatus.failed,
        failureReason: 'PayPal payment error: ${e.toString()}',
        processedAt: DateTime.now(),
      );
    }
  }
  
  /// Process Cash on Delivery payment
  Future<PaymentEntity> _processCashOnDeliveryPayment(
    PaymentEntity payment,
    Map<String, dynamic>? paymentDetails,
  ) async {
    try {
      // Cash on delivery doesn't require immediate payment processing
      return payment.copyWith(
        status: PaymentStatus.authorized,
        transactionId: 'COD_${payment.id}',
        processedAt: DateTime.now(),
      );
    } catch (e) {
      return payment.copyWith(
        status: PaymentStatus.failed,
        failureReason: 'Cash on delivery error: ${e.toString()}',
        processedAt: DateTime.now(),
      );
    }
  }
  
  /// Process Bank Transfer payment
  Future<PaymentEntity> _processBankTransferPayment(
    PaymentEntity payment,
    Map<String, dynamic>? paymentDetails,
  ) async {
    try {
      // Bank transfer doesn't require immediate payment processing
      return payment.copyWith(
        status: PaymentStatus.authorized,
        transactionId: 'BT_${payment.id}',
        processedAt: DateTime.now(),
      );
    } catch (e) {
      return payment.copyWith(
        status: PaymentStatus.failed,
        failureReason: 'Bank transfer error: ${e.toString()}',
        processedAt: DateTime.now(),
      );
    }
  }
  
  /// Validate coupon
  Future<Either<String, Coupon>> validateCoupon(String code, double subtotal) async {
    try {
      // Get coupon from repository
      final couponResult = await _repository.getCouponByCode(code);
      
      if (couponResult.isLeft()) {
        return const Left('Invalid coupon code');
      }
      
      final coupon = couponResult.getOrElse(() => null);
      if (coupon == null) {
        return const Left('Coupon not found');
      }
      
      // Check if coupon is valid
      final now = DateTime.now();
      if (!coupon.isActive) {
        return const Left('Coupon is not active');
      }
      
      if (now.isBefore(coupon.startDate)) {
        return const Left('Coupon is not yet active');
      }
      
      if (now.isAfter(coupon.endDate)) {
        return const Left('Coupon has expired');
      }
      
      if (subtotal < coupon.minimumAmount) {
        return Left('Minimum order amount not met');
      }
      
      if (coupon.usedCount >= coupon.usageLimit) {
        return const Left('Coupon usage limit exceeded');
      }
      
      return Right(coupon);
    } catch (e) {
      return Left('Failed to validate coupon: ${e.toString()}');
    }
  }
  
  /// Calculate totals
  PaymentTotals _calculateTotals(List<PaymentItem> items, String? couponCode) {
    double subtotal = 0.0;
    double totalTax = 0.0;
    
    for (final item in items) {
      subtotal += item.totalPrice;
      totalTax += item.tax;
    }
    
    return PaymentTotals(
      subtotal: subtotal,
      taxAmount: totalTax,
      discountAmount: 0.0,
      shippingAmount: 0.0,
    );
  }
  
  /// Apply coupon discount
  PaymentTotals _applyCouponDiscount(PaymentTotals totals, Coupon coupon) {
    double discountAmount = 0.0;
    
    switch (coupon.type) {
      case CouponType.percentage:
        discountAmount = totals.subtotal * (coupon.discountValue / 100);
        break;
      case CouponType.fixedAmount:
        discountAmount = coupon.discountValue;
        break;
      case CouponType.freeShipping:
        discountAmount = totals.shippingAmount;
        break;
      case CouponType.buyOneGetOne:
        // Complex logic for buy one get one
        discountAmount = coupon.discountValue;
        break;
    }
    
    // Apply maximum discount limit
    if (discountAmount > coupon.maximumDiscount) {
      discountAmount = coupon.maximumDiscount;
    }
    
    return totals.copyWith(discountAmount: -discountAmount);
  }
  
  /// Calculate shipping cost
  Future<double> _calculateShippingCost(Address? shippingAddress, List<PaymentItem> items) async {
    if (shippingAddress == null) {
      return 0.0;
    }
    
    // Simple shipping calculation based on weight and distance
    double totalWeight = 0.0;
    for (final item in items) {
      totalWeight += item.quantity * 1.0; // Assume 1kg per item
    }
    
    // Base shipping cost
    double baseCost = 50.0;
    
    // Weight-based cost
    double weightCost = totalWeight * 10.0;
    
    // Distance-based cost (simplified)
    double distanceCost = 0.0;
    if (shippingAddress!.city.toLowerCase().contains('kathmandu')) {
      distanceCost = 0.0;
    } else {
      distanceCost = 100.0;
    }
    
    return baseCost + weightCost + distanceCost;
  }
  
  /// Validate checkout items
  String? _validateCheckoutItems(List<PaymentItem> items) {
    if (items.isEmpty) {
      return 'Cart is empty';
    }
    
    for (final item in items) {
      if (item.quantity <= 0) {
        return 'Invalid quantity for item: ${item.productName}';
      }
      
      if (item.unitPrice <= 0) {
        return 'Invalid price for item: ${item.productName}';
      }
    }
    
    return null;
  }
  
  /// Validate payment method
  String? _validatePaymentMethod(PaymentMethod method, PaymentGateway gateway) {
    // Check if payment method is supported by gateway
    switch (gateway) {
      case PaymentGateway.khalti:
        if (!['creditCard', 'debitCard', 'mobileWallet'].contains(method.name)) {
          return 'Payment method not supported by Khalti';
        }
        break;
      case PaymentGateway.esewa:
        if (!['creditCard', 'debitCard', 'mobileWallet', 'bankTransfer'].contains(method.name)) {
          return 'Payment method not supported by eSewa';
        }
        break;
      case PaymentGateway.imePay:
        if (!['creditCard', 'debitCard', 'mobileWallet'].contains(method.name)) {
          return 'Payment method not supported by IME Pay';
        }
        break;
      case PaymentGateway.connectIPS:
        if (!['creditCard', 'debitCard', 'mobileWallet', 'bankTransfer'].contains(method.name)) {
          return 'Payment method not supported by Connect IPS';
        }
        break;
      case PaymentGateway.stripe:
        if (!['creditCard', 'debitCard', 'mobileWallet'].contains(method.name)) {
          return 'Payment method not supported by Stripe';
        }
        break;
      case PaymentGateway.paypal:
        if (!['creditCard', 'debitCard', 'mobileWallet', 'bankTransfer'].contains(method.name)) {
          return 'Payment method not supported by PayPal';
        }
        break;
      case PaymentGateway.cashOnDelivery:
        if (method != PaymentMethod.cashOnDelivery) {
          return 'Only cash on delivery is supported';
        }
        break;
      case PaymentGateway.bankTransfer:
        if (method != PaymentMethod.bankTransfer) {
          return 'Only bank transfer is supported';
        }
        break;
    }
    
    return null;
  }
  
  /// Mock API calls (to be replaced with actual implementations)
  Future<Map<String, dynamic>> _callKhaltiAPI(
    PaymentEntity payment,
    Map<String, dynamic>? details,
  ) async {
    // TODO: Implement actual Khalti API call
    await Future.delayed(const Duration(seconds: 2));
    return {
      'success': true,
      'transaction_id': 'KHA_${DateTime.now().millisecondsSinceEpoch}',
      'gateway_transaction_id': 'KHA_GATEWAY_${DateTime.now().millisecondsSinceEpoch}',
      'authorization_code': 'AUTH_${DateTime.now().millisecondsSinceEpoch}',
    };
  }
  
  Future<Map<String, dynamic>> _callEsewaAPI(
    PaymentEntity payment,
    Map<String, dynamic>? details,
  ) async {
    // TODO: Implement actual eSewa API call
    await Future.delayed(const Duration(seconds: 2));
    return {
      'success': true,
      'transaction_id': 'ESE_${DateTime.now().millisecondsSinceEpoch}',
      'gateway_transaction_id': 'ESE_GATEWAY_${DateTime.now().millisecondsSinceEpoch}',
      'authorization_code': 'AUTH_${DateTime.now().millisecondsSinceEpoch}',
    };
  }
  
  Future<Map<String, dynamic>> _callImePayAPI(
    PaymentEntity payment,
    Map<String, dynamic>? details,
  ) async {
    // TODO: Implement actual IME Pay API call
    await Future.delayed(const Duration(seconds: 2));
    return {
      'success': true,
      'transaction_id': 'IME_${DateTime.now().millisecondsSinceEpoch}',
      'gateway_transaction_id': 'IME_GATEWAY_${DateTime.now().millisecondsSinceEpoch}',
      'authorization_code': 'AUTH_${DateTime.now().millisecondsSinceEpoch}',
    };
  }
  
  Future<Map<String, dynamic>> _callConnectIPSAPI(
    PaymentEntity payment,
    Map<String, dynamic>? details,
  ) async {
    // TODO: Implement actual Connect IPS API call
    await Future.delayed(const Duration(seconds: 2));
    return {
      'success': true,
      'transaction_id': 'CIP_${DateTime.now().millisecondsSinceEpoch}',
      'gateway_transaction_id': 'CIP_GATEWAY_${DateTime.now().millisecondsSinceEpoch}',
      'authorization_code': 'AUTH_${DateTime.now().millisecondsSinceEpoch}',
    };
  }
  
  Future<Map<String, dynamic>> _callStripeAPI(
    PaymentEntity payment,
    Map<String, dynamic>? details,
  ) async {
    // TODO: Implement actual Stripe API call
    await Future.delayed(const Duration(seconds: 2));
    return {
      'success': true,
      'transaction_id': 'STR_${DateTime.now().millisecondsSinceEpoch}',
      'gateway_transaction_id': 'STR_GATEWAY_${DateTime.now().millisecondsSinceEpoch}',
      'authorization_code': 'AUTH_${DateTime.now().millisecondsSinceEpoch}',
    };
  }
  
  Future<Map<String, dynamic>> _callPayPalAPI(
    PaymentEntity payment,
    Map<String, dynamic>? details,
  ) async {
    // TODO: Implement actual PayPal API call
    await Future.delayed(const Duration(seconds: 2));
    return {
      'success': true,
      'transaction_id': 'PPL_${DateTime.now().millisecondsSinceEpoch}',
      'gateway_transaction_id': 'PPL_GATEWAY_${DateTime.now().millisecondsSinceEpoch}',
      'authorization_code': 'AUTH_${DateTime.now().millisecondsSinceEpoch}',
    };
  }
  
  /// Refund payment
  Future<Either<String, PaymentEntity>> refundPayment({
    required String paymentId,
    required double refundAmount,
    required String refundReason,
  }) async {
    try {
      // Get payment
      final paymentResult = await _repository.getPayment(paymentId);
      if (paymentResult.isLeft()) {
        return Left('Payment not found');
      }
      
      final payment = paymentResult.getOrElse(() => null);
      if (payment == null) {
        return const Left('Payment not found');
      }
      
      // Check if payment can be refunded
      if (payment.status != PaymentStatus.completed) {
        return Left('Payment cannot be refunded');
      }
      
      if (refundAmount > payment.totalAmount) {
        return Left('Refund amount cannot exceed payment amount');
      }
      
      // Process refund based on gateway
      final refundedPayment = await _processRefund(payment, refundAmount, refundReason);
      
      // Update payment
      final result = await _repository.updatePayment(refundedPayment);
      
      return result.fold(
        (error) => Left(error),
        (updatedPayment) => Right(updatedPayment),
      );
    } catch (e) {
      return Left('Failed to refund payment: ${e.toString()}');
    }
  }
  
  /// Process refund based on gateway
  Future<PaymentEntity> _processRefund(
    PaymentEntity payment,
    double refundAmount,
    String refundReason,
  ) async {
    try {
      // Refund API call based on gateway
      final refundResponse = await _callRefundAPI(payment, refundAmount);
      
      if (refundResponse['success'] == true) {
        return payment.copyWith(
          status: refundAmount == payment.totalAmount 
              ? PaymentStatus.refunded 
              : PaymentStatus.partiallyRefunded,
          refundedAmount: refundAmount,
          refundReason: refundReason,
          refundedAt: DateTime.now(),
        );
      } else {
        return payment.copyWith(
          status: PaymentStatus.failed,
          failureReason: refundResponse['message'] ?? 'Refund failed',
          failureCode: refundResponse['error_code'],
        );
      }
    } catch (e) {
      return payment.copyWith(
        status: PaymentStatus.failed,
        failureReason: 'Refund error: ${e.toString()}',
      );
    }
  }
  
  /// Refund API call
  Future<Map<String, dynamic>> _callRefundAPI(
    PaymentEntity payment,
    double refundAmount,
  ) async {
    // TODO: Implement actual refund API call
    await Future.delayed(const Duration(seconds: 2));
    return {
      'success': true,
      'refund_id': 'REF_${DateTime.now().millisecondsSinceEpoch}',
    };
  }
  
  /// Get payment status
  Future<Either<String, PaymentEntity>> getPaymentStatus(String paymentId) async {
    try {
      final result = await _repository.getPayment(paymentId);
      return result;
    } catch (e) {
      return Left('Failed to get payment status: ${e.toString()}');
    }
  }
  
  /// Get payment history
  Future<Either<String, List<PaymentEntity>>> getPaymentHistory({
    String? retailerId,
    DateTime? startDate,
    DateTime? endDate,
    PaymentStatus? status,
    int? limit,
  }) async {
    try {
      final result = await _repository.getPayments(
        retailerId: retailerId,
        startDate: startDate,
        endDate: endDate,
        status: status,
        limit: limit,
      );
      return result;
    } catch (e) {
      return Left('Failed to get payment history: ${e.toString()}');
    }
  }
  
  /// Get checkout session
  Future<Either<String, CheckoutSession>> getCheckoutSession(String sessionId) async {
    try {
      final result = await _repository.getCheckoutSession(sessionId);
      return result;
    } catch (e) {
      return Left('Failed to get checkout session: ${e.toString()}');
    }
  }
  
  /// Update checkout session
  Future<Either<String, CheckoutSession>> updateCheckoutSession(CheckoutSession session) async {
    try {
      final result = await _repository.updateCheckoutSession(session);
      return result;
    } catch (e) {
      return Left('Failed to update checkout session: ${e.toString()}');
    }
  }
  
  /// Delete checkout session
  Future<Either<String, void>> deleteCheckoutSession(String sessionId) async {
    try {
      final result = await _repository.deleteCheckoutSession(sessionId);
      return result;
    } catch (e) {
      return Left('Failed to delete checkout session: ${e.toString()}');
    }
  }
}

/// Payment totals helper class
class PaymentTotals {
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double shippingAmount;
  
  const PaymentTotals({
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.shippingAmount,
  });
  
  PaymentTotals copyWith({
    double? subtotal,
    double? taxAmount,
    double? discountAmount,
    double? shippingAmount,
  }) {
    return PaymentTotals(
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      shippingAmount: shippingAmount ?? this.shippingAmount,
    );
  }
  
  double get totalAmount {
    return subtotal + taxAmount + discountAmount + shippingAmount;
  }
}

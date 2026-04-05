import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../../../shared/services/storage_service.dart';
import '../../../../shared/utils/app_utils.dart';

/// Payment Repository Implementation
/// Handles data persistence and retrieval for payments and checkout sessions
class PaymentRepositoryImpl implements PaymentRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final StorageService _storageService;
  final AppUtils _appUtils;
  
  PaymentRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    StorageService? storageService,
    AppUtils? appUtils,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance,
       _storageService = storageService ?? StorageService(),
       _appUtils = appUtils ?? AppUtils();
  
  @override
  Future<Either<String, CheckoutSession>> createCheckoutSession(CheckoutSession session) async {
    try {
      // Create checkout session in Firestore
      await _firestore
          .collection('checkout_sessions')
          .doc(session.id)
          .set(session.toMap());
      
      // Cache locally
      await _storageService.saveCheckoutSession(session);
      
      return Right(session);
    } catch (e) {
      return Left('Failed to create checkout session: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, CheckoutSession>> getCheckoutSession(String sessionId) async {
    try {
      // Try cache first
      final cached = await _storageService.getCheckoutSession(sessionId);
      if (cached != null) {
        return Right(cached);
      }
      
      // Fetch from Firestore
      final doc = await _firestore.collection('checkout_sessions').doc(sessionId).get();
      
      if (!doc.exists) {
        return const Left('Checkout session not found');
      }
      
      final session = CheckoutSession.fromMap(doc.data()!);
      
      // Cache for future use
      await _storageService.saveCheckoutSession(session);
      
      return Right(session);
    } catch (e) {
      return Left('Failed to get checkout session: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, CheckoutSession>> updateCheckoutSession(CheckoutSession session) async {
    try {
      // Update in Firestore
      await _firestore
          .collection('checkout_sessions')
          .doc(session.id)
          .update(session.toMap());
      
      // Update cache
      await _storageService.saveCheckoutSession(session);
      
      return Right(session);
    } catch (e) {
      return Left('Failed to update checkout session: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, void>> deleteCheckoutSession(String sessionId) async {
    try {
      // Delete from Firestore
      await _firestore.collection('checkout_sessions').doc(sessionId).delete();
      
      // Delete from cache
      await _storageService.deleteCheckoutSession(sessionId);
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to delete checkout session: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, List<CheckoutSession>>> getCheckoutSessionsByRetailer(String retailerId) async {
    try {
      final query = await _firestore
          .collection('checkout_sessions')
          .where('retailerId', isEqualTo: retailerId)
          .orderBy('createdAt', descending: true)
          .get();
      
      final sessions = query.docs
          .map((doc) => CheckoutSession.fromMap(doc.data()!))
          .toList();
      
      return Right(sessions);
    } catch (e) {
      return Left('Failed to get checkout sessions: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, List<CheckoutSession>>> getActiveCheckoutSessions(String retailerId) async {
    try {
      final query = await _firestore
          .collection('checkout_sessions')
          .where('retailerId', isEqualTo: retailerId)
          .where('status', whereIn: [
            CheckoutStatus.cart.name,
            CheckoutStatus.address.name,
            CheckoutStatus.shipping.name,
            CheckoutStatus.payment.name,
          ])
          .orderBy('createdAt', descending: true)
          .get();
      
      final sessions = query.docs
          .map((doc) => CheckoutSession.fromMap(doc.data()!))
          .toList();
      
      return Right(sessions);
    } catch (e) {
      return Left('Failed to get active checkout sessions: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, PaymentEntity>> createPayment(PaymentEntity payment) async {
    try {
      // Create payment in Firestore
      await _firestore
          .collection('payments')
          .doc(payment.id)
          .set(payment.toMap());
      
      // Cache locally
      await _storageService.savePayment(payment);
      
      return Right(payment);
    } catch (e) {
      return Left('Failed to create payment: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, PaymentEntity>> getPayment(String paymentId) async {
    try {
      // Try cache first
      final cached = await _storageService.getPayment(paymentId);
      if (cached != null) {
        return Right(cached);
      }
      
      // Fetch from Firestore
      final doc = await _firestore.collection('payments').doc(paymentId).get();
      
      if (!doc.exists) {
        return const Left('Payment not found');
      }
      
      final payment = PaymentEntity.fromMap(doc.data()!);
      
      // Cache for future use
      await _storageService.savePayment(payment);
      
      return Right(payment);
    } catch (e) {
      return Left('Failed to get payment: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, PaymentEntity>> updatePayment(PaymentEntity payment) async {
    try {
      // Update in Firestore
      await _firestore
          .collection('payments')
          .doc(payment.id)
          .update(payment.toMap());
      
      // Update cache
      await _storageService.savePayment(payment);
      
      return Right(payment);
    } catch (e) {
      return Left('Failed to update payment: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, void>> deletePayment(String paymentId) async {
    try {
      // Delete from Firestore
      await _firestore.collection('payments').doc(paymentId).delete();
      
      // Delete from cache
      await _storageService.deletePayment(paymentId);
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to delete payment: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, List<PaymentEntity>>> getPaymentsByRetailer(String retailerId) async {
    try {
      final query = await _firestore
          .collection('payments')
          .where('retailerId', isEqualTo: retailerId)
          .orderBy('createdAt', descending: true)
          .get();
      
      final payments = query.docs
          .map((doc) => PaymentEntity.fromMap(doc.data()!))
          .toList();
      
      return Right(payments);
    } catch (e) {
      return Left('Failed to get payments: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, List<PaymentEntity>>> getPaymentsByStatus(
    String retailerId,
    PaymentStatus status,
  ) async {
    try {
      final query = await _firestore
          .collection('payments')
          .where('retailerId', isEqualTo: retailerId)
          .where('status', isEqualTo: status.name)
          .orderBy('createdAt', descending: true)
          .get();
      
      final payments = query.docs
          .map((doc) => PaymentEntity.fromMap(doc.data()!))
          .toList();
      
      return Right(payments);
    } catch (e) {
      return Left('Failed to get payments by status: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, List<PaymentEntity>>> getPaymentsByDateRange(
    String retailerId,
    DateTime startDate,
    DateTime endDate,
    {PaymentStatus? status}
  ) async {
    try {
      Query query = _firestore
          .collection('payments')
          .where('retailerId', isEqualTo: retailerId)
          .where('createdAt', isGreaterThanOrEqualTo: startDate)
          .where('createdAt', isLessThanOrEqualTo: endDate);
      
      if (status != null) {
        query = query.where('status', isEqualTo: status!.name);
      }
      
      final snapshot = await query
          .orderBy('createdAt', descending: true)
          .get();
      
      final payments = snapshot.docs
          .map((doc) => PaymentEntity.fromMap(doc.data()!))
          .toList();
      
      return Right(payments);
    } catch (e) {
      return Left('Failed to get payments by date range: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, Coupon>> createCoupon(Coupon coupon) async {
    try {
      // Create coupon in Firestore
      await _firestore
          .collection('coupons')
          .doc(coupon.id)
          .set(coupon.toMap());
      
      return Right(coupon);
    } catch (e) {
      return Left('Failed to create coupon: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, Coupon>> getCouponByCode(String code) async {
    try {
      final query = await _firestore
          .collection('coupons')
          .where('code', isEqualTo: code.toUpperCase())
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();
      
      if (query.docs.isEmpty) {
        return const Left('Coupon not found');
      }
      
      final coupon = Coupon.fromMap(query.docs.first.data());
      
      // Check if coupon is still valid
      final now = DateTime.now();
      if (now.isBefore(coupon.startDate) || now.isAfter(coupon.endDate)) {
        return const Left('Coupon has expired');
      }
      
      return Right(coupon);
    } catch (e) {
      return Left('Failed to get coupon: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, Coupon>> updateCoupon(Coupon coupon) async {
    try {
      await _firestore
          .collection('coupons')
          .doc(coupon.id)
          .update(coupon.toMap());
      
      return Right(coupon);
    } catch (e) {
      return Left('Failed to update coupon: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, void>> deleteCoupon(String couponId) async {
    try {
      await _firestore.collection('coupons').doc(couponId).delete();
      return const Right(null);
    } catch (e) {
      return Left('Failed to delete coupon: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, List<Coupon>>> getActiveCoupons() async {
    try {
      final now = DateTime.now();
      
      final query = await _firestore
          .collection('coupons')
          .where('isActive', isEqualTo: true)
          .where('startDate', isLessThanOrEqualTo: now)
          .where('endDate', isGreaterThanOrEqualTo: now)
          .orderBy('endDate', descending: true)
          .get();
      
      final coupons = query.docs
          .map((doc) => Coupon.fromMap(doc.data()!))
          .toList();
      
      return Right(coupons);
    } catch (e) {
      return Left('Failed to get active coupons: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, List<Coupon>>> getCouponsByRetailer(String retailerId) async {
    try {
      // This would typically be implemented with retailer-specific coupons
      // For now, return all active coupons
      return getActiveCoupons();
    } catch (e) {
      return Left('Failed to get retailer coupons: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, Map<String, dynamic>>> getPaymentStatistics(String retailerId) async {
    try {
      // Get total payments
      final totalPaymentsQuery = await _firestore
          .collection('payments')
          .where('retailerId', isEqualTo: retailerId)
          .get();
      
      final totalPayments = totalPaymentsQuery.docs.length;
      
      // Get payments by status
      final completedQuery = await _firestore
          .collection('payments')
          .where('retailerId', isEqualTo: retailerId)
          .where('status', isEqualTo: PaymentStatus.completed.name)
          .get();
      
      final failedQuery = await _firestore
          .collection('payments')
          .where('retailerId', isEqualTo: retailerId)
          .where('status', isEqualTo: PaymentStatus.failed.name)
          .get();
      
      final refundedQuery = await _firestore
          .collection('payments')
          .where('retailerId', isEqualTo: retailerId)
          .where('status', whereIn: [
            PaymentStatus.refunded.name,
            PaymentStatus.partiallyRefunded.name,
          ])
          .get();
      
      final completedPayments = completedQuery.docs.length;
      final failedPayments = failedQuery.docs.length;
      final refundedPayments = refundedQuery.docs.length;
      
      // Calculate total amounts
      double totalAmount = 0.0;
      double totalRefunded = 0.0;
      
      for (final doc in totalPaymentsQuery.docs) {
        final payment = PaymentEntity.fromMap(doc.data()!);
        totalAmount += payment.totalAmount;
        if (payment.refundedAmount != null) {
          totalRefunded += payment.refundedAmount!;
        }
      }
      
      final statistics = {
        'totalPayments': totalPayments,
        'completedPayments': completedPayments,
        'failedPayments': failedPayments,
        'refundedPayments': refundedPayments,
        'totalAmount': totalAmount,
        'totalRefunded': totalRefunded,
        'netAmount': totalAmount - totalRefunded,
        'successRate': totalPayments > 0 ? (completedPayments / totalPayments) * 100 : 0.0,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      
      return Right(statistics);
    } catch (e) {
      return Left('Failed to get payment statistics: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, List<PaymentEntity>>> searchPayments({
    required String retailerId,
    String? searchTerm,
    String? transactionId,
    PaymentStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection('payments')
          .where('retailerId', isEqualTo: retailerId);
      
      if (searchTerm != null && searchTerm!.isNotEmpty) {
        query = query.where('searchTerms', arrayContains: [searchTerm!.toLowerCase()]);
      }
      
      if (transactionId != null && transactionId!.isNotEmpty) {
        query = query.where('transactionId', isEqualTo: transactionId);
      }
      
      if (status != null) {
        query = query.where('status', isEqualTo: status!.name);
      }
      
      if (startDate != null) {
        query = query.where('createdAt', isGreaterThanOrEqualTo: startDate);
      }
      
      if (endDate != null) {
        query = query.where('createdAt', isLessThanOrEqualTo: endDate);
      }
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final snapshot = await query
          .orderBy('createdAt', descending: true)
          .get();
      
      final payments = snapshot.docs
          .map((doc) => PaymentEntity.fromMap(doc.data()!))
          .toList();
      
      return Right(payments);
    } catch (e) {
      return Left('Failed to search payments: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, void>> cleanupExpiredSessions() async {
    try {
      final now = DateTime.now();
      
      final expiredQuery = await _firestore
          .collection('checkout_sessions')
          .where('expiresAt', isLessThan: now)
          .get();
      
      // Delete expired sessions
      for (final doc in expiredQuery.docs) {
        await doc.reference.delete();
      }
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to cleanup expired sessions: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, void>> archiveOldPayments() async {
    try {
      final ninetyDaysAgo = DateTime.now().subtract(const Duration(days: 90));
      
      final oldPaymentsQuery = await _firestore
          .collection('payments')
          .where('createdAt', isLessThan: ninetyDaysAgo)
          .where('status', whereIn: [
            PaymentStatus.completed.name,
            PaymentStatus.refunded.name,
            PaymentStatus.partiallyRefunded.name,
          ])
          .get();
      
      // Archive old payments
      for (final doc in oldPaymentsQuery.docs) {
        final archiveData = doc.data();
        archiveData['archivedAt'] = DateTime.now().toIso8601String();
        
        await _firestore.collection('payments_archive').add(archiveData);
        await doc.reference.delete();
      }
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to archive old payments: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, List<PaymentEntity>>> getPendingPayments() async {
    try {
      final query = await _firestore
          .collection('payments')
          .where('status', whereIn: [
            PaymentStatus.pending.name,
            PaymentStatus.processing.name,
            PaymentStatus.authorized.name,
          ])
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
      
      final payments = query.docs
          .map((doc) => PaymentEntity.fromMap(doc.data()!))
          .toList();
      
      return Right(payments);
    } catch (e) {
      return Left('Failed to get pending payments: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, List<PaymentEntity>>> getFailedPayments() async {
    try {
      final twentyFourHoursAgo = DateTime.now().subtract(const Duration(hours: 24));
      
      final query = await _firestore
          .collection('payments')
          .where('status', isEqualTo: PaymentStatus.failed.name)
          .where('createdAt', isGreaterThanOrEqualTo: twentyFourHoursAgo)
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();
      
      final payments = query.docs
          .map((doc) => PaymentEntity.fromMap(doc.data()!))
          .toList();
      
      return Right(payments);
    } catch (e) {
      return Left('Failed to get failed payments: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, void>> retryFailedPayments() async {
    try {
      final failedPaymentsResult = await getFailedPayments();
      
      if (failedPaymentsResult.isLeft()) {
        return failedPaymentsResult;
      }
      
      final failedPayments = failedPaymentsResult.getOrElse(() => []);
      
      for (final payment in failedPayments) {
        if (payment.retryCount != null && payment.retryCount! >= 3) {
          continue; // Skip payments that have been retried 3+ times
        }
        
        // Update retry count
        final updatedPayment = payment.copyWith(
          retryCount: (payment.retryCount ?? 0) + 1,
          status: PaymentStatus.pending,
          updatedAt: DateTime.now(),
        );
        
        await updatePayment(updatedPayment);
      }
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to retry failed payments: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, String>> generatePaymentReport({
    required String retailerId,
    required DateTime startDate,
    required DateTime endDate,
    String? format,
  }) async {
    try {
      final paymentsResult = await getPaymentsByDateRange(
        retailerId,
        startDate,
        endDate,
      );
      
      if (paymentsResult.isLeft()) {
        return Left('Failed to get payments for report');
      }
      
      final payments = paymentsResult.getOrElse(() => []);
      
      // Generate report based on format
      switch (format?.toLowerCase()) {
        case 'csv':
          return _generateCSVReport(payments);
        case 'pdf':
          return _generatePDFReport(payments);
        case 'excel':
          return _generateExcelReport(payments);
        default:
          return _generateJSONReport(payments);
      }
    } catch (e) {
      return Left('Failed to generate payment report: ${e.toString()}');
    }
  }
  
  String _generateCSVReport(List<PaymentEntity> payments) {
    final buffer = StringBuffer();
    
    // CSV header
    buffer.writeln('Transaction ID,Order ID,Retailer,Amount,Status,Payment Method,Date');
    
    // CSV data
    for (final payment in payments) {
      buffer.writeln('${payment.transactionId},${payment.orderId},${payment.retailerName},${payment.totalAmount},${payment.status.name},${payment.paymentMethod.name},${payment.createdAt.toIso8601String()}');
    }
    
    return buffer.toString();
  }
  
  String _generatePDFReport(List<PaymentEntity> payments) {
    // TODO: Implement PDF report generation
    return 'PDF report generation not yet implemented';
  }
  
  String _generateExcelReport(List<PaymentEntity> payments) {
    // TODO: Implement Excel report generation
    return 'Excel report generation not yet implemented';
  }
  
  String _generateJSONReport(List<PaymentEntity> payments) {
    final report = {
      'generatedAt': DateTime.now().toIso8601String(),
      'totalPayments': payments.length,
      'payments': payments.map((payment) => payment.toMap()).toList(),
    };
    
    return report.toString();
  }
  
  @override
  Future<Either<String, List<Address>>> getRetailerAddresses(String retailerId) async {
    try {
      final query = await _firestore
          .collection('addresses')
          .where('retailerId', isEqualTo: retailerId)
          .orderBy('isDefault', descending: true)
          .orderBy('createdAt', descending: true)
          .get();
      
      final addresses = query.docs
          .map((doc) => Address.fromMap(doc.data()!))
          .toList();
      
      return Right(addresses);
    } catch (e) {
      return Left('Failed to get retailer addresses: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, Address>> createAddress(Address address) async {
    try {
      // Create address in Firestore
      await _firestore
          .collection('addresses')
          .doc(address.id)
          .set(address.toMap());
      
      return Right(address);
    } catch (e) {
      return Left('Failed to create address: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, Address>> updateAddress(Address address) async {
    try {
      // Update address in Firestore
      await _firestore
          .collection('addresses')
          .doc(address.id)
          .update(address.toMap());
      
      return Right(address);
    } catch (e) {
      return Left('Failed to update address: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, void>> deleteAddress(String addressId) async {
    try {
      await _firestore.collection('addresses').doc(addressId).delete();
      return const Right(null);
    } catch (e) {
      return Left('Failed to delete address: ${e.toString()}');
    }
  }
  
  @override
  Future<Either<String, Address>> setDefaultAddress(String retailerId, String addressId) async {
    try {
      // Get all addresses for retailer
      final addressesResult = await getRetailerAddresses(retailerId);
      
      if (addressesResult.isLeft()) {
        return addressesResult;
      }
      
      final addresses = addressesResult.getOrElse(() => []);
      
      // Remove default flag from all addresses
      for (final address in addresses) {
        await _firestore
            .collection('addresses')
            .doc(address.id)
            .update({'isDefault': false});
      }
      
      // Set new default address
      await _firestore
          .collection('addresses')
          .doc(addressId)
          .update({'isDefault': true});
      
      // Get updated address
      final addressResult = await _firestore.collection('addresses').doc(addressId).get();
      final address = Address.fromMap(addressResult.data()!);
      
      return Right(address);
    } catch (e) {
      return Left('Failed to set default address: ${e.toString()}');
    }
  }
}

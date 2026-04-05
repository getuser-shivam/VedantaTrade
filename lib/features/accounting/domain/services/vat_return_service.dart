import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import '../entities/vat_return.dart';
import '../repositories/vat_return_repository.dart';

/// VAT Return Service
/// Comprehensive VAT return management with IRDN compliance and PDF export
class VATReturnService {
  final VATReturnRepository _repository;
  final Map<String, VATReturn> _cachedReturns = {};
  final Map<String, List<VATTransaction>> _transactionsByReturn = {};
  Timer? _dueDateCheckTimer;
  Timer? _complianceCheckTimer;
  bool _isInitialized = false;

  VATReturnService(this._repository);

  /// Initialize service
  Future<void> initialize() async {
    try {
      if (_isInitialized) return;
      
// print('🔍 Initializing VAT Return Service...'); // Removed for production
      
      // Load cached returns
      await _loadCachedReturns();
      
      // Start monitoring
      _startDueDateMonitoring();
      _startComplianceMonitoring();
      
      _isInitialized = true;
// print('✅ VAT Return Service initialized successfully'); // Removed for production
    } catch (e) {
// print('❌ Failed to initialize VAT Return Service: $e'); // Removed for production
      rethrow;
    }
  }

  /// Create new VAT return
  Future<Either<Failure, VATReturn>> createVATReturn({
    required String stockistId,
    required String stockistName,
    required String period,
    required DateTime startDate,
    required DateTime endDate,
    required List<VATTransaction> salesTransactions,
    required List<VATTransaction> purchaseTransactions,
    double vatRate = 0.13, // 13% VAT for Nepal
    Map<String, dynamic>? metadata,
  }) async {
    try {
// print('📝 Creating new VAT return for period: $period'); // Removed for production
      
      // Generate unique return number
      final returnNumber = _generateReturnNumber();
      final returnId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Calculate totals
      final totalSales = salesTransactions.fold(0.0, (sum, transaction) => sum + transaction.totalAmount);
      final totalPurchases = purchaseTransactions.fold(0.0, (sum, transaction) => sum + transaction.totalAmount);
      final totalVATCollected = salesTransactions.fold(0.0, (sum, transaction) => sum + transaction.vatAmount);
      final totalVATPaid = purchaseTransactions.fold(0.0, (sum, transaction) => sum + transaction.vatAmount);
      final netVATPayable = totalVATCollected - totalVATPaid;
      
      final vatReturn = VATReturn(
        id: returnId,
        returnNumber: returnNumber,
        stockistId: stockistId,
        stockistName: stockistName,
        period: period,
        startDate: startDate,
        endDate: endDate,
        filingDate: DateTime.now(),
        status: VATReturnStatus.draft,
        totalSales: totalSales,
        totalPurchases: totalPurchases,
        totalVATCollected: totalVATCollected,
        totalVATPaid: totalVATPaid,
        netVATPayable: netVATPayable,
        vatRate: vatRate,
        salesTransactions: salesTransactions,
        purchaseTransactions: purchaseTransactions,
        metadata: metadata ?? {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Save to repository
      final result = await _repository.saveVATReturn(vatReturn);
      
      if (result.isRight()) {
        // Update cache
        _cachedReturns[returnId] = vatReturn;
        _transactionsByReturn[returnId] = [...salesTransactions, ...purchaseTransactions];
        
// print('✅ VAT return created successfully: $returnNumber'); // Removed for production
        return Right(vatReturn);
      } else {
        return Left(result.fold((l) => l, (r) => r));
      }
    } catch (e) {
// print('❌ Failed to create VAT return: $e'); // Removed for production
      return Left(Failure(
        message: 'Failed to create VAT return',
        code: 'CREATE_ERROR',
        details: e,
      ));
    }
  }

  /// Submit VAT return for IRDN
  Future<Either<Failure, void>> submitVATReturn({
    required String id,
    required String irdnReference,
    String? notes,
  }) async {
    try {
// print('📤 Submitting VAT return to IRDN: $id'); // Removed for production
      
      final vatReturnResult = await _repository.getVATReturnById(id);
      
      return vatReturnResult.fold(
        (error) => Left(error),
        (vatReturn) async {
          if (!vatReturn.canBeSubmitted()) {
            return Left(Failure(
              message: 'VAT return cannot be submitted in current status',
              code: 'INVALID_STATUS',
            ));
          }
          
          final updatedReturn = vatReturn.copyWith(
            status: VATReturnStatus.irdnSubmitted,
            irdnReference: irdnReference,
            irdnSubmissionDate: DateTime.now(),
            metadata: {
              ...vatReturn.metadata,
              'irdn_submission_at': DateTime.now().toIso8601String(),
              'irdn_reference': irdnReference,
              'submission_notes': notes,
            },
          );
          
          // Update repository
          final result = await _repository.submitToIRDN(
            id: id,
            irdnReference: irdnReference,
            notes: notes,
          );
          
          if (result.isRight()) {
            // Update cache
            _cachedReturns[id] = updatedReturn;
            
// print('✅ VAT return submitted to IRDN: ${updatedReturn.returnNumber}'); // Removed for production
            return const Right(null);
          } else {
            return Left(result.fold((l) => l, (r) => r));
          }
        },
      );
    } catch (e) {
// print('❌ Failed to submit VAT return to IRDN: $e'); // Removed for production
      return Left(Failure(
        message: 'Failed to submit VAT return to IRDN',
        code: 'SUBMIT_ERROR',
        details: e,
      ));
    }
  }

  /// Record VAT return payment
  Future<Either<Failure, void>> recordVATReturnPayment({
    required String id,
    required String paymentReference,
    required DateTime paymentDate,
    required double paymentAmount,
    String? bankName,
    String? accountNumber,
    String? chequeNumber,
    String? transactionId,
  }) async {
    try {
// print('💳 Recording VAT return payment: $id'); // Removed for production
      
      final vatReturnResult = await _repository.getVATReturnById(id);
      
      return vatReturnResult.fold(
        (error) => Left(error),
        (vatReturn) async {
          if (!vatReturn.canBePaid()) {
            return Left(Failure(
              message: 'VAT return cannot be paid in current status',
              code: 'INVALID_STATUS',
            ));
          }
          
          final updatedReturn = vatReturn.copyWith(
            status: VATReturnStatus.paid,
            paymentReference: paymentReference,
            paymentDate: paymentDate,
            paymentAmount: paymentAmount,
            bankName: bankName,
            accountNumber: accountNumber,
            chequeNumber: chequeNumber,
            transactionId: transactionId,
            metadata: {
              ...vatReturn.metadata,
              'payment_recorded_at': DateTime.now().toIso8601String(),
              'payment_reference': paymentReference,
              'payment_amount': paymentAmount,
              'payment_method': 'bank_transfer',
            },
          );
          
          // Update repository
          final result = await _repository.recordVATReturnPayment(
            id: id,
            paymentReference: paymentReference,
            paymentDate: paymentDate,
            paymentAmount: paymentAmount,
            bankName: bankName,
            accountNumber: accountNumber,
            chequeNumber: chequeNumber,
            transactionId: transactionId,
          );
          
          if (result.isRight()) {
            // Update cache
            _cachedReturns[id] = updatedReturn;
            
// print('✅ VAT return payment recorded: ${updatedReturn.returnNumber}'); // Removed for production
            return const Right(null);
          } else {
            return Left(result.fold((l) => l, (r) => r));
          }
        },
      );
    } catch (e) {
// print('❌ Failed to record VAT return payment: $e'); // Removed for production
      return Left(Failure(
        message: 'Failed to record VAT return payment',
        code: 'PAYMENT_ERROR',
        details: e,
      ));
    }
  }

  /// Generate VAT return PDF
  Future<Either<Failure, String>> generateVATReturnPDF(String id) async {
    try {
// print('📄 Generating VAT return PDF: $id'); // Removed for production
      
      final result = await _repository.generateVATReturnPDF(id);
      
      if (result.isRight()) {
// print('✅ VAT return PDF generated successfully'); // Removed for production
        return Right(result.fold((l) => l, (r) => r));
      } else {
        return Left(result.fold((l) => l, (r) => r));
      }
    } catch (e) {
// print('❌ Failed to generate VAT return PDF: $e'); // Removed for production
      return Left(Failure(
        message: 'Failed to generate VAT return PDF',
        code: 'PDF_GENERATION_ERROR',
        details: e,
      ));
    }
  }

  /// Get VAT returns by stockist
  Future<Either<Failure, List<VATReturn>>> getVATReturnsByStockist({
    required String stockistId,
    VATReturnStatus? status,
    String? period,
    int? limit,
  }) async {
    try {
// print('🔍 Getting VAT returns for stockist: $stockistId'); // Removed for production
      
      final result = await _repository.getVATReturnsByStockist(
        stockistId: stockistId,
        status: status,
        period: period,
        limit: limit,
      );
      
      if (result.isRight()) {
        // Update cache
        for (final vatReturn in result) {
          _cachedReturns[vatReturn.id] = vatReturn;
        }
        
// print('✅ Retrieved ${result.length} VAT returns for stockist: $stockistId'); // Removed for production
        return Right(result);
      } else {
        return Left(result.fold((l) => l, (r) => r));
      }
    } catch (e) {
// print('❌ Failed to get VAT returns for stockist: $e'); // Removed for production
      return Left(Failure(
        message: 'Failed to get VAT returns for stockist',
        code: 'RETRIEVE_ERROR',
        details: e,
      ));
    }
  }

  /// Get pending VAT returns
  Future<Either<Failure, List<VATReturn>>> getPendingVATReturns({
    String? stockistId,
    int? limit,
  }) async {
    try {
// print('🔍 Getting pending VAT returns...'); // Removed for production
      
      final result = await _repository.getPendingVATReturns(
        stockistId: stockistId,
        limit: limit,
      );
      
      if (result.isRight()) {
// print('✅ Retrieved ${result.length} pending VAT returns'); // Removed for production
        return Right(result);
      } else {
        return Left(result.fold((l) => l, (r) => r));
      }
    } catch (e) {
// print('❌ Failed to get pending VAT returns: $e'); // Removed for production
      return Left(Failure(
        message: 'Failed to get pending VAT returns',
        code: 'RETRIEVE_ERROR',
        details: e,
      ));
    }
  }

  /// Get overdue VAT returns
  Future<Either<Failure, List<VATReturn>>> getOverdueVATReturns({
    String? stockistId,
    int? limit,
  }) async {
    try {
// print('🔍 Getting overdue VAT returns...'); // Removed for production
      
      final result = await _repository.getOverdueVATReturns(
        stockistId: stockistId,
        limit: limit,
      );
      
      if (result.isRight()) {
// print('✅ Retrieved ${result.length} overdue VAT returns'); // Removed for production
        return Right(result);
      } else {
        return Left(result.fold((l) => l, (r) => r));
      }
    } catch (e) {
// print('❌ Failed to get overdue VAT returns: $e'); // Removed for production
      return Left(Failure(
        message: 'Failed to get overdue VAT returns',
        code: 'RETRIEVE_ERROR',
        details: e,
      ));
    }
  }

  /// Get VAT return statistics
  Future<Either<Failure, Map<String, dynamic>>> getVATReturnStatistics({
    String? stockistId,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
    VATReturnStatus? status,
  }) async {
    try {
// print('📊 Getting VAT return statistics...'); // Removed for production
      
      final result = await _repository.getVATReturnStatistics(
        stockistId: stockistId,
        period: period,
        startDate: startDate,
        endDate: endDate,
        status: status,
      );
      
      if (result.isRight()) {
// print('✅ VAT return statistics calculated'); // Removed for production
        return Right(result);
      } else {
        return Left(result.fold((l) => l, (r) => r));
      }
    } catch (e) {
// print('❌ Failed to get VAT return statistics: $e'); // Removed for production
      return Left(Failure(
        message: 'Failed to get VAT return statistics',
        code: 'STATISTICS_ERROR',
        details: e,
      ));
    }
  }

  /// Get VAT compliance report
  Future<Either<Failure, Map<String, dynamic>>> getVATComplianceReport({
    required String stockistId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
// print('📋 Getting VAT compliance report...'); // Removed for production
      
      final result = await _repository.getVATComplianceReport(
        stockistId: stockistId,
        startDate: startDate,
        endDate: endDate,
      );
      
      if (result.isRight()) {
// print('✅ VAT compliance report generated'); // Removed for production
        return Right(result);
      } else {
        return Left(result.fold((l) => l, (r) => r));
      }
    } catch (e) {
// print('❌ Failed to get VAT compliance report: $e'); // Removed for production
      return Left(Failure(
        message: 'Failed to get VAT compliance report',
        code: 'COMPLIANCE_ERROR',
        details: e,
      ));
    }
  }

  /// Validate VAT return
  Future<Either<Failure, VATReturnValidation>> validateVATReturn(VATReturn vatReturn) async {
    try {
// print('🔍 Validating VAT return: ${vatReturn.returnNumber}'); // Removed for production
      
      final errors = <String>[];
      final warnings = <String>[];
      
      // Validate required fields
      if (vatReturn.totalSales < 0) {
        errors.add('Total sales cannot be negative');
      }
      
      if (vatReturn.totalPurchases < 0) {
        errors.add('Total purchases cannot be negative');
      }
      
      if (vatReturn.salesTransactions.isEmpty) {
        warnings.add('No sales transactions found');
      }
      
      if (vatReturn.purchaseTransactions.isEmpty) {
        warnings.add('No purchase transactions found');
      }
      
      // Validate calculations
      final calculatedVATCollected = vatReturn.salesTransactions.fold(0.0, (sum, transaction) => sum + transaction.vatAmount);
      final calculatedVATPaid = vatReturn.purchaseTransactions.fold(0.0, (sum, transaction) => sum + transaction.vatAmount);
      final calculatedNetVAT = calculatedVATCollected - calculatedVATPaid;
      
      if ((vatReturn.totalVATCollected - calculatedVATCollected).abs() > 0.01) {
        errors.add('VAT collected calculation mismatch');
      }
      
      if ((vatReturn.totalVATPaid - calculatedVATPaid).abs() > 0.01) {
        errors.add('VAT paid calculation mismatch');
      }
      
      if ((vatReturn.netVATPayable - calculatedNetVAT).abs() > 0.01) {
        errors.add('Net VAT payable calculation mismatch');
      }
      
      // Validate dates
      if (vatReturn.startDate.isAfter(vatReturn.endDate)) {
        errors.add('Start date cannot be after end date');
      }
      
      if (vatReturn.endDate.isAfter(DateTime.now())) {
        warnings.add('End date is in the future');
      }
      
      // Validate VAT rate
      if (vatReturn.vatRate <= 0 || vatReturn.vatRate > 1) {
        errors.add('VAT rate must be between 0 and 1');
      }
      
      final validation = VATReturnValidation(
        isValid: errors.isEmpty,
        errors: errors,
        warnings: warnings,
        summary: {
          'total_sales': vatReturn.totalSales,
          'total_purchases': vatReturn.totalPurchases,
          'vat_collected': vatReturn.totalVATCollected,
          'vat_paid': vatReturn.totalVATPaid,
          'net_vat_payable': vatReturn.netVATPayable,
          'calculated_vat_collected': calculatedVATCollected,
          'calculated_vat_paid': calculatedVATPaid,
          'calculated_net_vat': calculatedNetVAT,
          'sales_transactions_count': vatReturn.salesTransactions.length,
          'purchase_transactions_count': vatReturn.purchaseTransactions.length,
        },
      );
      
// print('✅ VAT return validation completed'); // Removed for production
      return Right(validation);
    } catch (e) {
// print('❌ Failed to validate VAT return: $e'); // Removed for production
      return Left(Failure(
        message: 'Failed to validate VAT return',
        code: 'VALIDATION_ERROR',
        details: e,
      ));
    }
  }

  /// Export VAT return data
  Future<Either<Failure, void>> exportVATReturnData({
    required String id,
    required String format,
    String? filePath,
  }) async {
    try {
// print('📤 Exporting VAT return data: $id'); // Removed for production
      
      final result = await _repository.exportVATReturnData(
        id: id,
        format: format,
        filePath: filePath,
      );
      
      if (result.isRight()) {
// print('✅ VAT return data exported successfully'); // Removed for production
        return const Right(null);
      } else {
        return Left(result.fold((l) => l, (r) => r));
      }
    } catch (e) {
// print('❌ Failed to export VAT return data: $e'); // Removed for production
      return Left(Failure(
        message: 'Failed to export VAT return data',
        code: 'EXPORT_ERROR',
        details: e,
      ));
    }
  }

  /// Generate unique return number
  String _generateReturnNumber() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().millisecond % 1000;
    return 'VAT-${timestamp}-$random';
  }

  /// Load cached returns
  Future<void> _loadCachedReturns() async {
    try {
// print('📂 Loading cached VAT returns...'); // Removed for production
      
      // This would load recent returns from repository
      // For now, we'll initialize with empty cache
      
// print('✅ Cached VAT returns loaded'); // Removed for production
    } catch (e) {
// print('❌ Failed to load cached VAT returns: $e'); // Removed for production
    }
  }

  /// Start due date monitoring
  void _startDueDateMonitoring() {
    _dueDateCheckTimer?.cancel();
    
    _dueDateCheckTimer = Timer.periodic(const Duration(hours: 6), (timer) async {
      if (!_isInitialized) return;
      
      try {
        await _checkDueDates();
      } catch (e) {
// print('❌ Failed to check due dates: $e'); // Removed for production
      }
    });
    
// print('✅ Due date monitoring started'); // Removed for production
  }

  /// Start compliance monitoring
  void _startComplianceMonitoring() {
    _complianceCheckTimer?.cancel();
    
    _complianceCheckTimer = Timer.periodic(const Duration(days: 1), (timer) async {
      if (!_isInitialized) return;
      
      try {
        await _checkCompliance();
      } catch (e) {
// print('❌ Failed to check compliance: $e'); // Removed for production
      }
    });
    
// print('✅ Compliance monitoring started'); // Removed for production
  }

  /// Check due dates
  Future<void> _checkDueDates() async {
    try {
      final result = await _repository.getOverdueVATReturns();
      
      result.fold(
        (error) => print('❌ Failed to check due dates: ${error.message}'),
        (overdueReturns) {
          for (final vatReturn in overdueReturns) {
// print('⚠️ Overdue VAT return: ${vatReturn.returnNumber}'); // Removed for production
            // This would trigger notifications
          }
        },
      );
    } catch (e) {
// print('❌ Failed to check due dates: $e'); // Removed for production
    }
  }

  /// Check compliance
  Future<void> _checkCompliance() async {
    try {
      // This would run compliance checks on all active VAT returns
      // For now, we'll just log that compliance check was performed
// print('🔍 Compliance check completed'); // Removed for production
    } catch (e) {
// print('❌ Failed to check compliance: $e'); // Removed for production
    }
  }

  /// Dispose resources
  void dispose() {
// print('🗑️ Disposing VAT Return Service...'); // Removed for production
    
    _dueDateCheckTimer?.cancel();
    _complianceCheckTimer?.cancel();
    
// print('✅ VAT Return Service disposed'); // Removed for production
  }
}

/// Extension methods for VATReturn
extension VATReturnExtensions on VATReturn {
  /// Check if return can be submitted
  bool canBeSubmitted() {
    return status == VATReturnStatus.draft ||
           status == VATReturnStatus.ready;
  }

  /// Check if return can be paid
  bool canBePaid() {
    return status == VATReturnStatus.irdnAcknowledged;
  }

  /// Check if return is completed
  bool isCompleted() {
    return status == VATReturnStatus.completed;
  }

  /// Check if return is overdue
  bool isOverdue() {
    final now = DateTime.now();
    final dueDate = endDate.add(const Duration(days: 30)); // 30 days after period end
    return now.isAfter(dueDate) && !isCompleted();
  }

  /// Get compliance percentage
  double getCompliancePercentage() {
    if (status == VATReturnStatus.completed) {
      return 100.0;
    } else if (status == VATReturnStatus.paid) {
      return 90.0;
    } else if (status == VATReturnStatus.irdnAcknowledged) {
      return 80.0;
    } else if (status == VATReturnStatus.irdnSubmitted) {
      return 60.0;
    } else if (status == VATReturnStatus.submitted) {
      return 40.0;
    } else if (status == VATReturnStatus.ready) {
      return 20.0;
    } else {
      return 0.0;
    }
  }

  /// Get formatted compliance percentage
  String getFormattedCompliancePercentage() {
    return '${getCompliancePercentage().toStringAsFixed(1)}%';
  }
}

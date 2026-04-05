import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import '../entities/expense_reconciliation.dart';
import '../repositories/expense_reconciliation_repository.dart';

/// Expense Reconciliation Service
/// Comprehensive expense management with multi-photo receipt approval
class ExpenseReconciliationService {
  final ExpenseReconciliationRepository _repository;
  final Map<String, ExpenseReconciliation> _cachedExpenses = {};
  final Map<String, List<ExpenseReceipt>> _receiptsByExpense = {};
  Timer? _approvalCheckTimer;
  Timer? _dueDateCheckTimer;
  bool _isInitialized = false;

  ExpenseReconciliationService(this._repository);

  /// Initialize service
  Future<void> initialize() async {
    try {
      if (_isInitialized) return;
      
// print('🔍 Initializing Expense Reconciliation Service...'); // Removed for production
      
      // Load cached expenses
      await _loadCachedExpenses();
      
      // Start monitoring
      _startApprovalMonitoring();
      _startDueDateMonitoring();
      
      _isInitialized = true;
// print('✅ Expense Reconciliation Service initialized successfully'); // Removed for production
    } catch (e) {
// print('❌ Failed to initialize Expense Reconciliation Service: $e'); // Removed for production
      rethrow;
    }
  }

  /// Create new expense
  Future<Either<Failure, ExpenseReconciliation>> createExpense({
    required String mrId,
    required String mrName,
    required String stockistId,
    required String stockistName,
    required String period,
    required DateTime expenseDate,
    required String category,
    required String subcategory,
    required double amount,
    required String currency,
    required double exchangeRate,
    required String description,
    required String purpose,
    required List<ExpenseReceipt> receipts,
    String? paymentMethod,
    String? bankName,
    String? accountNumber,
    String? notes,
    Map<String, dynamic>? metadata,
  }) async {
    try {
// print('💾 Creating new expense for MR: $mrId'); // Removed for production
      
      // Generate unique expense number
      final expenseNumber = _generateExpenseNumber();
      final expenseId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Calculate amount in NPR
      final amountInNPR = amount * exchangeRate;
      
      final expense = ExpenseReconciliation(
        id: expenseId,
        expenseNumber: expenseNumber,
        mrId: mrId,
        mrName: mrName,
        stockistId: stockistId,
        stockistName: stockistName,
        period: period,
        expenseDate: expenseDate,
        category: category,
        subcategory: subcategory,
        amount: amount,
        currency: currency,
        exchangeRate: exchangeRate,
        amountInNPR: amountInNPR,
        description: description,
        purpose: purpose,
        receipts: receipts,
        status: ExpenseStatus.pending,
        metadata: metadata ?? {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Save to repository
      final result = await _repository.saveExpense(expense);
      
      if (result.isRight()) {
        // Update cache
        _cachedExpenses[expenseId] = expense;
        _receiptsByExpense[expenseId] = receipts;
        
// print('✅ Expense created successfully: $expenseNumber'); // Removed for production
        return Right(expense);
      } else {
        return Left(result.fold((l) => l, (r) => r));
      }
    } catch (e) {
// print('❌ Failed to create expense: $e'); // Removed for production
      return Left(Failure(
        message: 'Failed to create expense',
        code: 'CREATE_ERROR',
        details: e,
      ));
    }
  }

  /// Add receipt to expense
  Future<Either<Failure, void>> addReceiptToExpense({
    required String expenseId,
    required ExpenseReceipt receipt,
  }) async {
    try {
// print('📷 Adding receipt to expense: $expenseId'); // Removed for production
      
      final expenseResult = await _repository.getExpenseById(expenseId);
      
      return expenseResult.fold(
        (error) => Left(error),
        (expense) async {
          if (!expense.canBeApproved()) {
            return Left(Failure(
              message: 'Cannot add receipt to expense in current status',
              code: 'INVALID_STATUS',
            ));
          }
          
          final updatedReceipts = [...expense.receipts, receipt];
          final updatedExpense = expense.copyWith(
            receipts: updatedReceipts,
            updatedAt: DateTime.now(),
          );
          
          // Update repository
          final result = await _repository.updateExpense(updatedExpense);
          
          if (result.isRight()) {
            // Update cache
            _cachedExpenses[expenseId] = updatedExpense;
            _receiptsByExpense[expenseId] = updatedReceipts;
            
// print('✅ Receipt added to expense successfully'); // Removed for production
            return const Right(null);
          } else {
            return Left(result.fold((l) => l, (r) => r));
          }
        },
      );
    } catch (e) {
// print('❌ Failed to add receipt to expense: $e'); // Removed for production
      return Left(Failure(
        message: 'Failed to add receipt to expense',
        code: 'ADD_RECEIPT_ERROR',
        details: e,
      ));
    }
  }

  /// Approve expense
  Future<Either<Failure, void>> approveExpense({
    required String expenseId,
    required String approvedBy,
    required double approvedAmount,
    String? notes,
  }) async {
    try {
// print('✅ Approving expense: $expenseId'); // Removed for production
      
      final expenseResult = await _repository.getExpenseById(expenseId);
      
      return expenseResult.fold(
        (error) => Left(error),
        (expense) async {
          if (!expense.canBeApproved()) {
            return Left(Failure(
              message: 'Expense cannot be approved in current status',
              code: 'INVALID_STATUS',
            ));
          }
          
          // Validate receipts
          final receiptValidation = _validateReceipts(expense.receipts, approvedAmount);
          if (!receiptValidation.isValid) {
            return Left(Failure(
              message: 'Receipt validation failed: ${receiptValidation.errors.join(', ')}',
              code: 'RECEIPT_VALIDATION_ERROR',
            ));
          }
          
          final updatedExpense = expense.copyWith(
            status: ExpenseStatus.approved,
            approvedBy: approvedBy,
            approvedAt: DateTime.now(),
            approvedAmount: approvedAmount,
            notes: notes,
            metadata: {
              ...expense.metadata,
              'approved_at': DateTime.now().toIso8601String(),
              'approved_by': approvedBy,
              'approved_amount': approvedAmount,
              'approval_notes': notes,
            },
          );
          
          // Update repository
          final result = await _repository.updateExpense(updatedExpense);
          
          if (result.isRight()) {
            // Update cache
            _cachedExpenses[expenseId] = updatedExpense;
            
// print('✅ Expense approved successfully: ${updatedExpense.expenseNumber}'); // Removed for production
            return const Right(null);
          } else {
            return Left(result.fold((l) => l, (r) => r));
          }
        },
      );
    } catch (e) {
// print('❌ Failed to approve expense: $e'); // Removed for production
      return Left(Failure(
        message: 'Failed to approve expense',
        code: 'APPROVE_ERROR',
        details: e,
      ));
    }
  }

  /// Reject expense
  Future<Either<Failure, void>> rejectExpense({
    required String expenseId,
    required String rejectionReason,
    double? rejectedAmount,
    String? notes,
  }) async {
    try {
// print('❌ Rejecting expense: $expenseId'); // Removed for production
      
      final expenseResult = await _repository.getExpenseById(expenseId);
      
      return expenseResult.fold(
        (error) => Left(error),
        (expense) async {
          if (!expense.canBeRejected()) {
            return Left(Failure(
              message: 'Expense cannot be rejected in current status',
              code: 'INVALID_STATUS',
            ));
          }
          
          final updatedExpense = expense.copyWith(
            status: ExpenseStatus.rejected,
            rejectionReason: rejectionReason,
            rejectedAmount: rejectedAmount,
            notes: notes,
            metadata: {
              ...expense.metadata,
              'rejected_at': DateTime.now().toIso8601String(),
              'rejection_reason': rejectionReason,
              'rejected_amount': rejectedAmount,
              'rejection_notes': notes,
            },
          );
          
          // Update repository
          final result = await _repository.updateExpense(updatedExpense);
          
          if (result.isRight()) {
            // Update cache
            _cachedExpenses[expenseId] = updatedExpense;
            
// print('✅ Expense rejected successfully: ${updatedExpense.expenseNumber}'); // Removed for production
            return const Right(null);
          } else {
            return Left(result.fold((l) => l, (r) => r));
          }
        },
      );
    } catch (e) {
// print('❌ Failed to reject expense: $e'); // Removed for production
      return Left(Failure(
        message: 'Failed to reject expense',
        code: 'REJECT_ERROR',
        details: e,
      ));
    }
  }

  /// Get expenses by MR
  Future<Either<Failure, List<ExpenseReconciliation>>> getExpensesByMR({
    required String mrId,
    ExpenseStatus? status,
    String? period,
    int? limit,
  }) async {
    try {
// print('🔍 Getting expenses for MR: $mrId'); // Removed for production
      
      final result = await _repository.getExpensesByMR(
        mrId: mrId,
        status: status,
        period: period,
        limit: limit,
      );
      
      if (result.isRight()) {
        // Update cache
        for (final expense in result) {
          _cachedExpenses[expense.id] = expense;
          _receiptsByExpense[expense.id] = expense.receipts;
        }
        
// print('✅ Retrieved ${result.length} expenses for MR: $mrId'); // Removed for production
        return Right(result);
      } else {
        return Left(result.fold((l) => l, (r) => r));
      }
    } catch (e) {
// print('❌ Failed to get expenses for MR: $e'); // Removed for production
      return Left(Failure(
        message: 'Failed to get expenses for MR',
        code: 'RETRIEVE_ERROR',
        details: e,
      ));
    }
  }

  /// Get expenses by stockist
  Future<Either<Failure, List<ExpenseReconciliation>>> getExpensesByStockist({
    required String stockistId,
    ExpenseStatus? status,
    String? period,
    int? limit,
  }) async {
    try {
// print('🔍 Getting expenses for stockist: $stockistId'); // Removed for production
      
      final result = await _repository.getExpensesByStockist(
        stockistId: stockistId,
        status: status,
        period: period,
        limit: limit,
      );
      
      if (result.isRight()) {
        // Update cache
        for (final expense in result) {
          _cachedExpenses[expense.id] = expense;
          _receiptsByExpense[expense.id] = expense.receipts;
        }
        
// print('✅ Retrieved ${result.length} expenses for stockist: $stockistId'); // Removed for production
        return Right(result);
      } else {
        return Left(result.fold((l) => l, (r) => r));
      }
    } catch (e) {
// print('❌ Failed to get expenses for stockist: $e'); // Removed for production
      return Left(Failure(
        message: 'Failed to get expenses for stockist',
        code: 'RETRIEVE_ERROR',
        details: e,
      ));
    }
  }

  /// Get pending expenses
  Future<Either<Failure, List<ExpenseReconciliation>>> getPendingExpenses({
    String? stockistId,
    int? limit,
  }) async {
    try {
// print('🔍 Getting pending expenses...'); // Removed for production
      
      final result = await _repository.getPendingExpenses(
        stockistId: stockistId,
        limit: limit,
      );
      
      if (result.isRight()) {
// print('✅ Retrieved ${result.length} pending expenses'); // Removed for production
        return Right(result);
      } else {
        return Left(result.fold((l) => l, (r) => r));
      }
    } catch (e) {
// print('❌ Failed to get pending expenses: $e'); // Removed for production
      return Left(Failure(
        message: 'Failed to get pending expenses',
        code: 'RETRIEVE_ERROR',
        details: e,
      ));
    }
  }

  /// Get expense statistics
  Future<Either<Failure, Map<String, dynamic>>> getExpenseStatistics({
    String? stockistId,
    String? mrId,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
    ExpenseStatus? status,
  }) async {
    try {
// print('📊 Getting expense statistics...'); // Removed for production
      
      final result = await _repository.getExpenseStatistics(
        stockistId: stockistId,
        mrId: mrId,
        period: period,
        startDate: startDate,
        endDate: endDate,
        status: status,
      );
      
      if (result.isRight()) {
// print('✅ Expense statistics calculated'); // Removed for production
        return Right(result);
      } else {
        return Left(result.fold((l) => l, (r) => r));
      }
    } catch (e) {
// print('❌ Failed to get expense statistics: $e'); // Removed for production
      return Left(Failure(
        message: 'Failed to get expense statistics',
        code: 'STATISTICS_ERROR',
        details: e,
      ));
    }
  }

  /// Generate expense report
  Future<Either<Failure, String>> generateExpenseReport({
    required String stockistId,
    required String period,
    String format = 'pdf',
  }) async {
    try {
// print('📄 Generating expense report...'); // Removed for production
      
      final result = await _repository.generateExpenseReport(
        stockistId: stockistId,
        period: period,
        format: format,
      );
      
      if (result.isRight()) {
// print('✅ Expense report generated successfully'); // Removed for production
        return Right(result);
      } else {
        return Left(result.fold((l) => l, (r) => r));
      }
    } catch (e) {
// print('❌ Failed to generate expense report: $e'); // Removed for production
      return Left(Failure(
        message: 'Failed to generate expense report',
        code: 'REPORT_GENERATION_ERROR',
        details: e,
      ));
    }
  }

  /// Validate receipts
  ReceiptValidationResult _validateReceipts(List<ExpenseReceipt> receipts, double approvedAmount) {
    final errors = <String>[];
    final warnings = <String>[];
    
    if (receipts.isEmpty) {
      errors.add('No receipts attached');
      return ReceiptValidationResult(
        isValid: false,
        errors: errors,
        warnings: warnings,
      );
    }
    
    final totalReceiptAmount = receipts.fold(0.0, (sum, receipt) => sum + receipt.amountInNPR);
    final difference = (approvedAmount - totalReceiptAmount).abs();
    final tolerance = approvedAmount * 0.05; // 5% tolerance
    
    if (totalReceiptAmount == 0) {
      errors.add('Total receipt amount is zero');
    }
    
    if (difference > tolerance) {
      errors.add('Receipt amount difference exceeds tolerance');
    }
    
    // Check for missing required photos
    for (final receipt in receipts) {
      if (receipt.photos.isEmpty) {
        warnings.add('Receipt ${receipt.receiptNumber} has no photos');
      }
      
      if (receipt.items.isEmpty) {
        warnings.add('Receipt ${receipt.receiptNumber} has no items');
      }
    }
    
    return ReceiptValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
      totalReceiptAmount: totalReceiptAmount,
      approvedAmount: approvedAmount,
      difference: difference,
      tolerance: tolerance,
    );
  }

  /// Generate unique expense number
  String _generateExpenseNumber() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().millisecond % 1000;
    return 'EXP-${timestamp}-$random';
  }

  /// Load cached expenses
  Future<void> _loadCachedExpenses() async {
    try {
// print('📂 Loading cached expenses...'); // Removed for production
      
      // This would load recent expenses from repository
      // For now, we'll initialize with empty cache
      
// print('✅ Cached expenses loaded'); // Removed for production
    } catch (e) {
// print('❌ Failed to load cached expenses: $e'); // Removed for production
    }
  }

  /// Start approval monitoring
  void _startApprovalMonitoring() {
    _approvalCheckTimer?.cancel();
    
    _approvalCheckTimer = Timer.periodic(const Duration(hours: 2), (timer) async {
      if (!_isInitialized) return;
      
      try {
        await _checkPendingApprovals();
      } catch (e) {
// print('❌ Failed to check pending approvals: $e'); // Removed for production
      }
    });
    
// print('✅ Approval monitoring started'); // Removed for production
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

  /// Check pending approvals
  Future<void> _checkPendingApprovals() async {
    try {
      final result = await _repository.getPendingExpenses();
      
      result.fold(
        (error) => print('❌ Failed to check pending approvals: ${error.message}'),
        (expenses) {
          for (final expense in expenses) {
            final daysPending = expense.getDaysSinceSubmission();
            
            if (daysPending > 3) {
// print('⚠️ Expense pending approval for ${daysPending} days: ${expense.expenseNumber}'); // Removed for production
              // This would trigger notifications
            }
          }
        },
      );
    } catch (e) {
// print('❌ Failed to check pending approvals: $e'); // Removed for production
    }
  }

  /// Check due dates
  Future<void> _checkDueDates() async {
    try {
      // This would check for upcoming due dates or overdue items
      // For now, we'll just log that due date check was performed
// print('🔍 Due date check completed'); // Removed for production
    } catch (e) {
// print('❌ Failed to check due dates: $e'); // Removed for production
    }
  }

  /// Dispose resources
  void dispose() {
// print('🗑️ Disposing Expense Reconciliation Service...'); // Removed for production
    
    _approvalCheckTimer?.cancel();
    _dueDateCheckTimer?.cancel();
    
// print('✅ Expense Reconciliation Service disposed'); // Removed for production
  }
}

/// Receipt Validation Result
class ReceiptValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final double totalReceiptAmount;
  final double approvedAmount;
  final double difference;
  final double tolerance;

  const ReceiptValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
    required this.totalReceiptAmount,
    required this.approvedAmount,
    required this.difference,
    required this.tolerance,
  });
}

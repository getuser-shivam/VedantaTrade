import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../states/expense_state.dart';
import '../events/expense_event.dart';

/// Expense Provider
/// Manages expense state and handles expense events
class ExpenseProvider extends ChangeNotifier {
  final ExpenseRepository _repository;
  ExpenseState _state = const ExpenseState.initial();
  StreamSubscription? _expenseSubscription;
  
  ExpenseProvider({
    required ExpenseRepository repository,
  }) : _repository = repository;
  
  /// Current expense state
  ExpenseState get state => _state;
  
  /// Initialize expense provider
  Future<void> initialize() async {
    _emitState(const ExpenseState.loading());
    
    try {
      final expenses = await _repository.getExpensesByMR('current_mr_id'); // TODO: Get from auth
      _emitState(ExpenseState.loaded(expenses: expenses));
    } catch (e) {
      _emitState(ExpenseState.error(
        message: 'Failed to load expenses: ${e.toString()}',
      ));
    }
  }
  
  /// Create expense
  Future<void> createExpense(ExpenseEntity expense) async {
    _emitState(const ExpenseState.loading());
    
    try {
      final result = await _repository.createExpense(expense);
      
      if (result.isLeft()) {
        _emitState(ExpenseState.error(
          message: result.fold((l) => l, (r) => 'Failed to create expense'),
        ));
        return;
      }
      
      final createdExpense = result.fold((l) => throw Exception(l), (r) => r);
      final updatedExpenses = [..._state.expenses, createdExpense];
      
      _emitState(ExpenseState.loaded(
        expenses: updatedExpenses,
        successMessage: 'Expense created successfully',
      ));
    } catch (e) {
      _emitState(ExpenseState.error(
        message: 'Failed to create expense: ${e.toString()}',
      ));
    }
  }
  
  /// Update expense
  Future<void> updateExpense(ExpenseEntity expense) async {
    _emitState(const ExpenseState.loading());
    
    try {
      final result = await _repository.updateExpense(expense);
      
      if (result.isLeft()) {
        _emitState(ExpenseState.error(
          message: result.fold((l) => l, (r) => 'Failed to update expense'),
        ));
        return;
      }
      
      final updatedExpense = result.fold((l) => throw Exception(l), (r) => r);
      final updatedExpenses = _state.expenses.map((e) => 
        e.id == updatedExpense.id ? updatedExpense : e
      ).toList();
      
      _emitState(ExpenseState.loaded(
        expenses: updatedExpenses,
        successMessage: 'Expense updated successfully',
      ));
    } catch (e) {
      _emitState(ExpenseState.error(
        message: 'Failed to update expense: ${e.toString()}',
      ));
    }
  }
  
  /// Delete expense
  Future<void> deleteExpense(String expenseId) async {
    _emitState(const ExpenseState.loading());
    
    try {
      final result = await _repository.deleteExpense(expenseId);
      
      if (result.isLeft()) {
        _emitState(ExpenseState.error(
          message: result.fold((l) => l, (r) => 'Failed to delete expense'),
        ));
        return;
      }
      
      final updatedExpenses = _state.expenses.where((e) => e.id != expenseId).toList();
      
      _emitState(ExpenseState.loaded(
        expenses: updatedExpenses,
        successMessage: 'Expense deleted successfully',
      ));
    } catch (e) {
      _emitState(ExpenseState.error(
        message: 'Failed to delete expense: ${e.toString()}',
      ));
    }
  }
  
  /// Get expenses by MR
  Future<void> loadExpensesByMR(String mrId) async {
    _emitState(const ExpenseState.loading());
    
    try {
      final result = await _repository.getExpensesByMR(mrId);
      
      if (result.isLeft()) {
        _emitState(ExpenseState.error(
          message: result.fold((l) => l, (r) => 'Failed to load expenses'),
        ));
        return;
      }
      
      final expenses = result.getOrElse(() => []);
      
      _emitState(ExpenseState.loaded(expenses: expenses));
    } catch (e) {
      _emitState(ExpenseState.error(
        message: 'Failed to load expenses: ${e.toString()}',
      ));
    }
  }
  
  /// Get expenses by status
  Future<void> loadExpensesByStatus(ExpenseStatus status) async {
    _emitState(const ExpenseState.loading());
    
    try {
      final result = await _repository.getExpensesByStatus('current_user_id', status); // TODO: Get from auth
      
      if (result.isLeft()) {
        _emitState(ExpenseState.error(
          message: result.fold((l) => l, (r) => 'Failed to load expenses'),
        ));
        return;
      }
      
      final expenses = result.getOrElse(() => []);
      
      _emitState(ExpenseState.loaded(expenses: expenses));
    } catch (e) {
      _emitState(ExpenseState.error(
        message: 'Failed to load expenses: ${e.toString()}',
      ));
    }
  }
  
  /// Search expenses
  Future<void> searchExpenses({
    String? mrId,
    String? retailerId,
    String? searchTerm,
    ExpenseStatus? status,
    ExpenseCategory? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _emitState(const ExpenseState.loading());
    
    try {
      final result = await _repository.searchExpenses(
        mrId: mrId,
        retailerId: retailerId,
        searchTerm: searchTerm,
        status: status,
        category: category,
        startDate: startDate,
        endDate: endDate,
      );
      
      if (result.isLeft()) {
        _emitState(ExpenseState.error(
          message: result.fold((l) => l, (r) => 'Failed to search expenses'),
        ));
        return;
      }
      
      final expenses = result.getOrElse(() => []);
      
      _emitState(ExpenseState.loaded(expenses: expenses));
    } catch (e) {
      _emitState(ExpenseState.error(
        message: 'Failed to search expenses: ${e.toString()}',
      ));
    }
  }
  
  /// Submit expense for approval
  Future<void> submitExpense(String expenseId) async {
    _emitState(const ExpenseState.loading());
    
    try {
      final result = await _repository.submitExpense(expenseId);
      
      if (result.isLeft()) {
        _emitState(ExpenseState.error(
          message: result.fold((l) => l, (r) => 'Failed to submit expense'),
        ));
        return;
      }
      
      final updatedExpenses = _state.expenses.map((e) => 
        e.id == expenseId ? e.copyWith(status: ExpenseStatus.submitted) : e
      ).toList();
      
      _emitState(ExpenseState.loaded(
        expenses: updatedExpenses,
        successMessage: 'Expense submitted for approval',
      ));
    } catch (e) {
      _emitState(ExpenseState.error(
        message: 'Failed to submit expense: ${e.toString()}',
      ));
    }
  }
  
  /// Approve expense
  Future<void> approveExpense(String expenseId, {String? notes}) async {
    _emitState(const ExpenseState.loading());
    
    try {
      final result = await _repository.approveExpense(
        expenseId: expenseId,
        approvedBy: 'current_user', // TODO: Get from auth
        notes: notes,
      );
      
      if (result.isLeft()) {
        _emitState(ExpenseState.error(
          message: result.fold((l) => l, (r) => 'Failed to approve expense'),
        ));
        return;
      }
      
      final updatedExpenses = _state.expenses.map((e) => 
        e.id == expenseId ? e.copyWith(status: ExpenseStatus.approved) : e
      ).toList();
      
      _emitState(ExpenseState.loaded(
        expenses: updatedExpenses,
        successMessage: 'Expense approved successfully',
      ));
    } catch (e) {
      _emitState(ExpenseState.error(
        message: 'Failed to approve expense: ${e.toString()}',
      ));
    }
  }
  
  /// Reject expense
  Future<void> rejectExpense(String expenseId, String rejectionReason) async {
    _emitState(const ExpenseState.loading());
    
    try {
      final result = await _repository.rejectExpense(
        expenseId: expenseId,
        rejectedBy: 'current_user', // TODO: Get from auth
        rejectionReason: rejectionReason,
      );
      
      if (result.isLeft()) {
        _emitState(ExpenseState.error(
          message: result.fold((l) => l, (r) => 'Failed to reject expense'),
        ));
        return;
      }
      
      final updatedExpenses = _state.expenses.map((e) => 
        e.id == expenseId ? e.copyWith(status: ExpenseStatus.rejected) : e
      ).toList();
      
      _emitState(ExpenseState.loaded(
        expenses: updatedExpenses,
        successMessage: 'Expense rejected successfully',
      ));
    } catch (e) {
      _emitState(ExpenseState.error(
        message: 'Failed to reject expense: ${e.toString()}',
      ));
    }
  }
  
  /// Add receipt to expense
  Future<void> addReceiptToExpense(String expenseId, List<String> imageUrls) async {
    _emitState(const ExpenseState.loading());
    
    try {
      // Create receipt entity for each image
      for (int i = 0; i < imageUrls.length; i++) {
        final receipt = ExpenseReceipt(
          id: 'receipt_${DateTime.now().millisecondsSinceEpoch}_$i',
          expenseId: expenseId,
          receiptType: 'image',
          imageUrls: [imageUrls[i]],
          thumbnailUrls: [imageUrls[i]], // TODO: Generate thumbnails
          status: ReceiptStatus.uploaded,
          uploadedBy: 'current_user', // TODO: Get from auth
          uploadedAt: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        final result = await _repository.createReceipt(receipt);
        
        if (result.isLeft()) {
          _emitState(ExpenseState.error(
            message: result.fold((l) => l, (r) => 'Failed to add receipt'),
          ));
          return;
        }
      }
      
      _emitState(const ExpenseState.success(
        message: 'Receipts added successfully',
      ));
    } catch (e) {
      _emitState(ExpenseState.error(
        message: 'Failed to add receipts: ${e.toString()}',
      ));
    }
  }
  
  /// Verify receipt
  Future<void> verifyReceipt(String receiptId, bool isApproved, {String? notes}) async {
    _emitState(const ExpenseState.loading());
    
    try {
      final result = await _repository.verifyReceipt(
        receiptId: receiptId,
        verifiedBy: 'current_user', // TODO: Get from auth
        isApproved: isApproved,
        notes: notes,
      );
      
      if (result.isLeft()) {
        _emitState(ExpenseState.error(
          message: result.fold((l) => l, (r) => 'Failed to verify receipt'),
        ));
        return;
      }
      
      _emitState(const ExpenseState.success(
        message: 'Receipt ${isApproved ? 'approved' : 'rejected'} successfully',
      ));
    } catch (e) {
      _emitState(ExpenseState.error(
        message: 'Failed to verify receipt: ${e.toString()}',
      ));
    }
  }
  
  /// Get expense statistics
  Future<void> loadExpenseStatistics(String mrId) async {
    _emitState(const ExpenseState.loading());
    
    try {
      final result = await _repository.getExpenseStatistics(mrId);
      
      if (result.isLeft()) {
        _emitState(ExpenseState.error(
          message: result.fold((l) => l, (r) => 'Failed to load statistics'),
        ));
        return;
      }
      
      final statistics = result.getOrElse(() => {});
      
      _emitState(ExpenseState.loaded(statistics: statistics));
    } catch (e) {
      _emitState(ExpenseState.error(
        message: 'Failed to load statistics: ${e.toString()}',
      ));
    }
  }
  
  /// Generate expense report
  Future<void> generateExpenseReport({
    required String mrId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _emitState(const ExpenseState.loading());
    
    try {
      final result = await _repository.generateExpenseReport(
        mrId: mrId,
        startDate: startDate,
        endDate: endDate,
      );
      
      if (result.isLeft()) {
        _emitState(ExpenseState.error(
          message: result.fold((l) => l, (r) => 'Failed to generate report'),
        ));
        return;
      }
      
      _emitState(const ExpenseState.success(
        message: 'Expense report generated successfully',
      ));
    } catch (e) {
      _emitState(ExpenseState.error(
        message: 'Failed to generate report: ${e.toString()}',
      ));
    }
  }
  
  /// Export expenses
  Future<void> exportExpenses({
    String? mrId,
    String? retailerId,
    DateTime? startDate,
    DateTime? endDate,
    String format = 'csv',
  }) async {
    _emitState(const ExpenseState.loading());
    
    try {
      final result = await _repository.exportExpenses(
        mrId: mrId,
        retailerId: retailerId,
        startDate: startDate,
        endDate: endDate,
        format: format,
      );
      
      if (result.isLeft()) {
        _emitState(ExpenseState.error(
          message: result.fold((l) => l, (r) => 'Failed to export expenses'),
        ));
        return;
      }
      
      _emitState(const ExpenseState.success(
        message: 'Expenses exported successfully',
      ));
    } catch (e) {
      _emitState(ExpenseState.error(
        message: 'Failed to export expenses: ${e.toString()}',
      ));
    }
  }
  
  /// Set filter
  void setFilter(ExpenseFilter? filter) {
    _emitState(_state.copyWith(
      activeFilter: filter,
      expenses: filter != null ? _state.expenses : _state.expenses, // Keep current expenses
    ));
  }
  
  /// Clear filter
  void clearFilter() {
    _emitState(_state.copyWith(
      activeFilter: null,
      expenses: _state.expenses, // Keep current expenses
    ));
  }
  
  /// Toggle expense selection
  void toggleExpenseSelection(String expenseId) {
    final selectedExpenses = Set<String>.from(_state.selectedExpenses);
    
    if (selectedExpenses.contains(expenseId)) {
      selectedExpenses.remove(expenseId);
    } else {
      selectedExpenses.add(expenseId);
    }
    
    _emitState(_state.copyWith(selectedExpenses: selectedExpenses));
  }
  
  /// Clear selection
  void clearSelection() {
    _emitState(_state.copyWith(selectedExpenses: <String>{}));
  }
  
  /// Select all expenses
  void selectAllExpenses() {
    final allIds = _state.expenses.map((e) => e.id).toSet();
    _emitState(_state.copyWith(selectedExpenses: allIds));
  }
  
  /// Approve multiple expenses
  Future<void> approveMultipleExpenses(List<String> expenseIds) async {
    _emitState(const ExpenseState.loading());
    
    try {
      for (final expenseId in expenseIds) {
        await approveExpense(expenseId);
      }
      
      _emitState(const ExpenseState.success(
        message: '${expenseIds.length} expenses approved successfully',
      ));
    } catch (e) {
      _emitState(ExpenseState.error(
        message: 'Failed to approve expenses: ${e.toString()}',
      ));
    }
  }
  
  /// Reject multiple expenses
  Future<void> rejectMultipleExpenses(List<String> expenseIds, String rejectionReason) async {
    _emitState(const ExpenseState.loading());
    
    try {
      for (final expenseId in expenseIds) {
        await rejectExpense(expenseId, rejectionReason);
      }
      
      _emitState(const ExpenseState.success(
        message: '${expenseIds.length} expenses rejected successfully',
      ));
    } catch (e) {
      _emitState(ExpenseState.error(
        message: 'Failed to reject expenses: ${e.toString()}',
      ));
    }
  }
  
  /// Delete multiple expenses
  Future<void> deleteMultipleExpenses(List<String> expenseIds) async {
    _emitState(const ExpenseState.loading());
    
    try {
      for (final expenseId in expenseIds) {
        await deleteExpense(expenseId);
      }
      
      _emitState(const ExpenseState.success(
        message: '${expenseIds.length} expenses deleted successfully',
      ));
    } catch (e) {
      _emitState(ExpenseState.error(
        message: 'Failed to delete expenses: ${e.toString()}',
      ));
    }
  }
  
  /// Export selected expenses
  Future<void> exportSelectedExpenses(List<String> expenseIds) async {
    _emitState(const ExpenseState.loading());
    
    try {
      final selectedExpenses = _state.expenses
          .where((e) => expenseIds.contains(e.id))
          .toList();
      
      // TODO: Implement selected export logic
      _emitState(const ExpenseState.success(
        message: '${selectedExpenses.length} expenses exported successfully',
      ));
    } catch (e) {
      _emitState(ExpenseState.error(
        message: 'Failed to export expenses: ${e.toString()}',
      ));
    }
  }
  
  /// Generate PDF report
  Future<void> generatePDFReport(String mrId) async {
    _emitState(const ExpenseState.loading());
    
    try {
      // TODO: Implement PDF generation
      _emitState(const ExpenseState.success(
        message: 'PDF report generated successfully',
      ));
    } catch (e) {
      _emitState(ExpenseState.error(
        message: 'Failed to generate PDF report: ${e.toString()}',
      ));
    }
  }
  
  /// Generate Excel report
  Future<void> generateExcelReport(String mrId) async {
    _emitState(const ExpenseState.loading());
    
    try {
      // TODO: Implement Excel generation
      _emitState(const ExpenseState.success(
        message: 'Excel report generated successfully',
      ));
    } catch (e) {
      _emitState(ExpenseState.error(
        message: 'Failed to generate Excel report: ${e.toString()}',
      ));
    }
  }
  
  /// Generate summary report
  Future<void> generateSummaryReport(String mrId) async {
    _emitState(const ExpenseState.loading());
    
    try {
      // TODO: Implement summary report generation
      _emitState(const ExpenseState.success(
        message: 'Summary report generated successfully',
      ));
    } catch (e) {
      _emitState(ExpenseState.error(
        message: 'Failed to generate summary report: ${e.toString()}',
      ));
    }
  }
  
  /// Emit new state
  void _emitState(ExpenseState newState) {
    _state = newState;
    notifyListeners();
  }
  
  /// Get current user (TODO: Get from auth provider)
  String get _currentUserId => 'current_user_id';
  
  /// Get current MR ID (TODO: Get from auth provider)
  String get _currentMrId => 'current_mr_id';
  
  @override
  void dispose() {
    _expenseSubscription?.cancel();
    super.dispose();
  }
}

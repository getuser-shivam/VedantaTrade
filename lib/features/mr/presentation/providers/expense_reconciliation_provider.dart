import 'package:flutter/foundation.dart';
import '../../data/services/expense_reconciliation_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

/// Expense Reconciliation Provider for state management
class ExpenseReconciliationProvider extends ChangeNotifier {
  final ExpenseReconciliationService _expenseService = ExpenseReconciliationService();
  final ImagePicker _imagePicker = ImagePicker();
  
  // State variables
  List<Expense> _expenses = [];
  List<Expense> _pendingExpenses = [];
  List<Expense> _approvedExpenses = [];
  ExpenseSummary? _currentSummary;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  List<Expense> get expenses => List.unmodifiable(_expenses);
  List<Expense> get pendingExpenses => List.unmodifiable(_pendingExpenses);
  List<Expense> get approvedExpenses => List.unmodifiable(_approvedExpenses);
  ExpenseSummary? get currentSummary => _currentSummary;
  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;

  /// Initialize the provider
  Future<void> initialize() async {
    try {
      _setLoading(true);
      await _expenseService.initialize();
      
      // Listen to streams
      _expenseService.expensesStream.listen((expenses) {
        _expenses = expenses;
        notifyListeners();
      });
      
      _expenseService.pendingExpensesStream.listen((pendingExpenses) {
        _pendingExpenses = pendingExpenses;
        notifyListeners();
      });
      
      _expenseService.approvedExpensesStream.listen((approvedExpenses) {
        _approvedExpenses = approvedExpenses;
        notifyListeners();
      });
      
      _expenseService.summaryStream.listen((summary) {
        _currentSummary = summary;
        notifyListeners();
      });
      
    } catch (e) {
      _setError('Failed to initialize expense reconciliation provider: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load expenses
  Future<void> loadExpenses({String? mrId, String? status}) async {
    try {
      _setLoading(true);
      await _expenseService.loadExpenses(mrId: mrId, status: status);
    } catch (e) {
      _setError('Failed to load expenses: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Create expense
  Future<Expense> createExpense(Map<String, dynamic> expenseData) async {
    try {
      _setLoading(true);
      
      final expense = await _expenseService.createExpense(
        mrId: expenseData['mrId'],
        description: expenseData['description'],
        amount: expenseData['amount'],
        category: expenseData['category'],
        expenseDate: expenseData['expenseDate'],
        receiptPhotos: expenseData['receiptPhotos'],
        vendorName: expenseData['vendorName'],
        notes: expenseData['notes'],
        location: expenseData['location'],
      );
      
      return expense;
    } catch (e) {
      _setError('Failed to create expense: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Approve expense
  Future<bool> approveExpense(String expenseId, {String? remarks}) async {
    try {
      _setLoading(true);
      final success = await _expenseService.approveExpense(expenseId, remarks: remarks);
      return success;
    } catch (e) {
      _setError('Failed to approve expense: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Reject expense
  Future<bool> rejectExpense(String expenseId, {String? remarks}) async {
    try {
      _setLoading(true);
      final success = await _expenseService.rejectExpense(expenseId, remarks: remarks);
      return success;
    } catch (e) {
      _setError('Failed to reject expense: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete expense
  Future<bool> deleteExpense(String expenseId) async {
    try {
      _setLoading(true);
      final success = await _expenseService.deleteExpense(expenseId);
      return success;
    } catch (e) {
      _setError('Failed to delete expense: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Calculate expense summary
  Future<ExpenseSummary> calculateExpenseSummary({
    String? mrId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final summary = await _expenseService.calculateExpenseSummary(
        mrId: mrId,
        startDate: startDate,
        endDate: endDate,
      );
      return summary;
    } catch (e) {
      _setError('Failed to calculate expense summary: $e');
      rethrow;
    }
  }

  /// Capture photo using camera
  Future<File?> capturePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      
      if (image != null) {
        return File(image.path);
      }
    } catch (e) {
      _setError('Failed to capture photo: $e');
    }
    
    return null;
  }

  /// Pick photo from gallery
  Future<File?> pickPhotoFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      
      if (image != null) {
        return File(image.path);
      }
    } catch (e) {
      _setError('Failed to pick photo from gallery: $e');
    }
    
    return null;
  }

  /// Process receipt photo with OCR
  Future<ReceiptOCRResult> processReceiptPhoto(File photo) async {
    try {
      final result = await _expenseService.processReceiptPhoto(photo);
      return result;
    } catch (e) {
      _setError('Failed to process receipt photo: $e');
      rethrow;
    }
  }

  /// Get expenses by status
  List<Expense> getExpensesByStatus(ExpenseStatus status) {
    return _expenseService.getExpensesByStatus(status);
  }

  /// Get expenses by category
  List<Expense> getExpensesByCategory(ExpenseCategory category) {
    return _expenseService.getExpensesByCategory(category);
  }

  /// Get expenses by date range
  List<Expense> getExpensesByDateRange(DateTime startDate, DateTime endDate) {
    return _expenseService.getExpensesByDateRange(startDate, endDate);
  }

  /// Search expenses
  List<Expense> searchExpenses(String query) {
    return _expenseService.searchExpenses(query);
  }

  /// Refresh all data
  Future<void> refresh() async {
    await Future.wait([
      loadExpenses(),
      calculateExpenseSummary(),
    ]);
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Dispose
  @override
  void dispose() {
    _expenseService.dispose();
    super.dispose();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error
  void _setError(String error) {
    _errorMessage = error;
    if (kDebugMode) {
      
    }
    notifyListeners();
  }
}

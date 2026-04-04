import 'package:flutter/foundation.dart';
import 'package:vedanta_trade/features/accounting/data/services/accounting_service.dart';

class AccountingProvider extends ChangeNotifier {
  final AccountingService _accountingService;
  
  AccountingProvider({AccountingService? accountingService})
      : _accountingService = accountingService ?? AccountingService();

  // State variables
  Map<String, dynamic> _financialSummary = {};
  List<Map<String, dynamic>> _vatReturns = [];
  List<Map<String, dynamic>> _expenseReports = [];
  List<Map<String, dynamic>> _mrExpenses = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Map<String, dynamic> get financialSummary => _financialSummary;
  List<Map<String, dynamic>> get vatReturns => _vatReturns;
  List<Map<String, dynamic>> get expenseReports => _expenseReports;
  List<Map<String, dynamic>> get mrExpenses => _mrExpenses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Nepal VAT constants
  static const double VAT_RATE = 0.13; // 13% flat VAT rate for Nepal

  // Computed properties
  double get totalRevenue => _financialSummary['totalRevenue']?.toDouble() ?? 0.0;
  double get vatCollected => _financialSummary['vatCollected']?.toDouble() ?? 0.0;
  double get pendingExpenses => _financialSummary['pendingExpenses']?.toDouble() ?? 0.0;
  double get netProfit => _financialSummary['netProfit']?.toDouble() ?? 0.0;
  double get totalExpenses => _financialSummary['totalExpenses']?.toDouble() ?? 0.0;
  double get vatPayable => vatCollected - (_financialSummary['vatOnExpenses']?.toDouble() ?? 0.0);

  /// Load financial summary
  Future<void> loadFinancialSummary() async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      final summary = await _accountingService.getFinancialSummary();
      _financialSummary = summary;
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load financial summary: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load VAT returns
  Future<void> loadVatReturns() async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      final vatReturns = await _accountingService.getVatReturns();
      _vatReturns = vatReturns;
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load VAT returns: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load expense reports
  Future<void> loadExpenseReports() async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      final expenses = await _accountingService.getExpenseReports();
      _expenseReports = expenses;
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load expense reports: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load MR expenses
  Future<void> loadMrExpenses() async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      final mrExpenses = await _accountingService.getMrExpenses();
      _mrExpenses = mrExpenses;
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load MR expenses: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Generate VAT return for specific period
  Future<Map<String, dynamic>> generateVatReturn(DateTime startDate, DateTime endDate) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      final vatReturn = await _accountingService.generateVatReturn(startDate, endDate);
      
      // Add to local state
      _vatReturns.insert(0, vatReturn);
      notifyListeners();
      
      return vatReturn;
    } catch (e) {
      _setError('Failed to generate VAT return: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Approve expense
  Future<void> approveExpense(String expenseId) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      await _accountingService.updateExpenseStatus(expenseId, 'approved');
      
      // Update local state
      _updateExpenseStatus(expenseId, 'approved');
      
    } catch (e) {
      _setError('Failed to approve expense: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Reject expense
  Future<void> rejectExpense(String expenseId, String? reason) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      await _accountingService.updateExpenseStatus(expenseId, 'rejected');
      
      // Update local state
      _updateExpenseStatus(expenseId, 'rejected');
      
    } catch (e) {
      _setError('Failed to reject expense: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Approve MR expense
  Future<void> approveMrExpense(String expenseId) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      await _accountingService.updateMrExpenseStatus(expenseId, 'approved');
      
      // Update local state
      _updateMrExpenseStatus(expenseId, 'approved');
      
    } catch (e) {
      _setError('Failed to approve MR expense: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Reject MR expense
  Future<void> rejectMrExpense(String expenseId, String? reason) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      await _accountingService.updateMrExpenseStatus(expenseId, 'rejected');
      
      // Update local state
      _updateMrExpenseStatus(expenseId, 'rejected');
      
    } catch (e) {
      _setError('Failed to reject MR expense: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Export VAT return as PDF
  Future<void> exportVatReturn(String vatReturnId) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      await _accountingService.exportVatReturn(vatReturnId);
      
    } catch (e) {
      _setError('Failed to export VAT return: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Export financial report
  Future<void> exportFinancialReport(DateTime startDate, DateTime endDate) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      await _accountingService.exportFinancialReport(startDate, endDate);
      
    } catch (e) {
      _setError('Failed to export financial report: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Calculate VAT amount
  double calculateVatAmount(double amount) {
    return amount * VAT_RATE;
  }

  /// Calculate amount including VAT
  double calculateAmountIncludingVat(double amount) {
    return amount + calculateVatAmount(amount);
  }

  /// Calculate amount excluding VAT
  double calculateAmountExcludingVat(double amountIncludingVat) {
    return amountIncludingVat / (1 + VAT_RATE);
  }

  /// Get VAT period for given date
  Map<String, DateTime> getVatPeriod(DateTime date) {
    // Nepal uses monthly VAT periods
    final startDate = DateTime(date.year, date.month, 1);
    final endDate = DateTime(date.year, date.month + 1, 0, 23, 59, 59);
    
    return {
      'startDate': startDate,
      'endDate': endDate,
    };
  }

  /// Get VAT return deadline
  DateTime getVatReturnDeadline(DateTime vatPeriodEnd) {
    // VAT return is due by 25th of the following month
    return DateTime(vatPeriodEnd.year, vatPeriodEnd.month + 1, 25);
  }

  /// Check if VAT return is overdue
  bool isVatReturnOverdue(DateTime vatPeriodEnd) {
    final deadline = getVatReturnDeadline(vatPeriodEnd);
    return DateTime.now().isAfter(deadline);
  }

  /// Get VAT return status
  String getVatReturnStatus(Map<String, dynamic> vatReturn) {
    final status = vatReturn['status']?.toString().toLowerCase();
    
    switch (status) {
      case 'draft':
        return 'Draft';
      case 'submitted':
        return 'Submitted';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }

  /// Get expense analytics
  Map<String, dynamic> getExpenseAnalytics() {
    final totalExpenses = _expenseReports.fold<double>(
      0.0, (sum, expense) => sum + (expense['amount'] as double));
    
    final pendingExpenses = _expenseReports
        .where((expense) => expense['status'] == 'pending')
        .fold<double>(0.0, (sum, expense) => sum + (expense['amount'] as double));
    
    final approvedExpenses = _expenseReports
        .where((expense) => expense['status'] == 'approved')
        .fold<double>(0.0, (sum, expense) => sum + (expense['amount'] as double));
    
    final rejectedExpenses = _expenseReports
        .where((expense) => expense['status'] == 'rejected')
        .fold<double>(0.0, (sum, expense) => sum + (expense['amount'] as double));

    // Group expenses by category
    final expensesByCategory = <String, double>{};
    for (final expense in _expenseReports) {
      final category = expense['category'] as String;
      final amount = expense['amount'] as double;
      expensesByCategory[category] = (expensesByCategory[category] ?? 0.0) + amount;
    }

    return {
      'totalExpenses': totalExpenses,
      'pendingExpenses': pendingExpenses,
      'approvedExpenses': approvedExpenses,
      'rejectedExpenses': rejectedExpenses,
      'expensesByCategory': expensesByCategory,
      'averageExpense': _expenseReports.isNotEmpty ? totalExpenses / _expenseReports.length : 0.0,
    };
  }

  /// Get MR expense analytics
  Map<String, dynamic> getMrExpenseAnalytics() {
    final totalMrExpenses = _mrExpenses.fold<double>(
      0.0, (sum, expense) => sum + (expense['amount'] as double));
    
    final pendingMrExpenses = _mrExpenses
        .where((expense) => expense['status'] == 'pending')
        .fold<double>(0.0, (sum, expense) => sum + (expense['amount'] as double));
    
    final approvedMrExpenses = _mrExpenses
        .where((expense) => expense['status'] == 'approved')
        .fold<double>(0.0, (sum, expense) => sum + (expense['amount'] as double));

    // Group expenses by MR
    final expensesByMr = <String, double>{};
    for (final expense in _mrExpenses) {
      final mrName = expense['mrName'] as String;
      final amount = expense['amount'] as double;
      expensesByMr[mrName] = (expensesByMr[mrName] ?? 0.0) + amount;
    }

    return {
      'totalMrExpenses': totalMrExpenses,
      'pendingMrExpenses': pendingMrExpenses,
      'approvedMrExpenses': approvedMrExpenses,
      'expensesByMr': expensesByMr,
      'averageMrExpense': _mrExpenses.isNotEmpty ? totalMrExpenses / _mrExpenses.length : 0.0,
    };
  }

  /// Validate VAT return data
  bool validateVatReturn(Map<String, dynamic> vatReturn) {
    final taxableSales = vatReturn['taxableSales']?.toDouble() ?? 0.0;
    final vatCollected = vatReturn['vatCollected']?.toDouble() ?? 0.0;
    final vatOnExpenses = vatReturn['vatOnExpenses']?.toDouble() ?? 0.0;
    final vatPayable = vatReturn['vatPayable']?.toDouble() ?? 0.0;

    // Validate VAT calculations
    final expectedVatCollected = calculateVatAmount(taxableSales);
    final expectedVatPayable = vatCollected - vatOnExpenses;

    return (vatCollected - expectedVatCollected).abs() < 0.01 &&
           (vatPayable - expectedVatPayable).abs() < 0.01;
  }

  void _updateExpenseStatus(String expenseId, String status) {
    final index = _expenseReports.indexWhere((expense) => expense['id'] == expenseId);
    if (index != -1) {
      _expenseReports[index]['status'] = status;
      _expenseReports[index]['updatedAt'] = DateTime.now().toIso8601String();
      notifyListeners();
    }
  }

  void _updateMrExpenseStatus(String expenseId, String status) {
    final index = _mrExpenses.indexWhere((expense) => expense['id'] == expenseId);
    if (index != -1) {
      _mrExpenses[index]['status'] = status;
      _mrExpenses[index]['updatedAt'] = DateTime.now().toIso8601String();
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

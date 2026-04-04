import 'package:flutter/foundation.dart';
import '../../data/services/vat_return_service.dart';

/// VAT Return Provider for state management
class VATReturnProvider extends ChangeNotifier {
  final VATReturnService _vatReturnService = VATReturnService();
  
  // State variables
  List<VATReturn> _vatReturns = [];
  List<VATTransaction> _transactions = [];
  VATSummary? _currentSummary;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  List<VATReturn> get vatReturns => List.unmodifiable(_vatReturns);
  List<VATTransaction> get transactions => List.unmodifiable(_transactions);
  VATSummary? get currentSummary => _currentSummary;
  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;

  /// Initialize the provider
  Future<void> initialize() async {
    try {
      _setLoading(true);
      await _vatReturnService.initialize();
      
      // Listen to streams
      _vatReturnService.vatReturnsStream.listen((returns) {
        _vatReturns = returns;
        notifyListeners();
      });
      
      _vatReturnService.transactionsStream.listen((transactions) {
        _transactions = transactions;
        notifyListeners();
      });
      
      _vatReturnService.vatSummaryStream.listen((summary) {
        _currentSummary = summary;
        notifyListeners();
      });
      
    } catch (e) {
      _setError('Failed to initialize VAT return provider: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load VAT returns
  Future<void> loadVATReturns({String? period}) async {
    try {
      _setLoading(true);
      await _vatReturnService.loadVATReturns(period: period);
    } catch (e) {
      _setError('Failed to load VAT returns: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load VAT transactions
  Future<void> loadVATTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? transactionType,
  }) async {
    try {
      _setLoading(true);
      await _vatReturnService.loadVATTransactions(
        startDate: startDate,
        endDate: endDate,
        transactionType: transactionType,
      );
    } catch (e) {
      _setError('Failed to load VAT transactions: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Calculate VAT summary
  Future<VATSummary> calculateVATSummary({
    DateTime? startDate,
    DateTime? endDate,
    String? period,
  }) async {
    try {
      _setLoading(true);
      final summary = await _vatReturnService.calculateVATSummary(
        startDate: startDate,
        endDate: endDate,
        period: period,
      );
      return summary;
    } catch (e) {
      _setError('Failed to calculate VAT summary: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Generate VAT return
  Future<VATReturn> generateVATReturn({
    required DateTime startDate,
    required DateTime endDate,
    required VATReturnType returnType,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      _setLoading(true);
      final vatReturn = await _vatReturnService.generateVATReturn(
        startDate: startDate,
        endDate: endDate,
        returnType: returnType,
        additionalData: additionalData,
      );
      return vatReturn;
    } catch (e) {
      _setError('Failed to generate VAT return: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Submit VAT return
  Future<bool> submitVATReturn({
    required String vatReturnId,
    required Map<String, dynamic> submissionData,
  }) async {
    try {
      _setLoading(true);
      final success = await _vatReturnService.submitVATReturn(
        vatReturnId: vatReturnId,
        submissionData: submissionData,
      );
      return success;
    } catch (e) {
      _setError('Failed to submit VAT return: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Export VAT return to PDF
  Future<Uint8List> exportVATReturnToPDF(VATReturn vatReturn) async {
    try {
      return await _vatReturnService.exportVATReturnToPDF(vatReturn);
    } catch (e) {
      _setError('Failed to export VAT return to PDF: $e');
      rethrow;
    }
  }

  /// Validate VAT return
  VATValidationResult validateVATReturn({
    required DateTime startDate,
    required DateTime endDate,
    required List<VATTransaction> transactions,
  }) {
    return _vatReturnService.validateVATReturn(
      startDate: startDate,
      endDate: endDate,
      transactions: transactions,
    );
  }

  /// Get VAT return by ID
  VATReturn? getVATReturnById(String id) {
    return _vatReturnService.getVATReturnById(id);
  }

  /// Get VAT returns by status
  List<VATReturn> getVATReturnsByStatus(VATReturnStatus status) {
    return _vatReturnService.getVATReturnsByStatus(status);
  }

  /// Get VAT returns by period
  List<VATReturn> getVATReturnsByPeriod(String period) {
    return _vatReturnService.getVATReturnsByPeriod(period);
  }

  /// Refresh all data
  Future<void> refresh() async {
    await Future.wait([
      loadVATReturns(),
      loadVATTransactions(),
      calculateVATSummary(),
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
    _vatReturnService.dispose();
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

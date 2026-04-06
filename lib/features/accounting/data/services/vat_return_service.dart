import 'package:vedanta_trade/core/constants/app_constants.dart';
import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/utils/nepal_localization_utils.dart';

/// VAT Return Service for Nepal IRDN Compliance
/// Handles VAT return calculations, reporting, and PDF generation
class VATReturnService {
  static final VATReturnService _instance = VATReturnService._internal();
  factory VATReturnService() => _instance;
  VATReturnService._internal();

  late Dio _dio;
  static const String _baseUrl = 'AppConstants.apiBaseUrl';
  static const double _vatRate = 0.13; // 13% VAT for Nepal

  // Stream controllers for real-time updates
  final StreamController<List<VATReturn>> _vatReturnsController = 
      StreamController<List<VATReturn>>.broadcast();
  final StreamController<VATSummary> _vatSummaryController = 
      StreamController<VATSummary>..broadcast();
  final StreamController<List<VATTransaction>> _transactionsController = 
      StreamController<List<VATTransaction>>.broadcast();

  List<VATReturn> _vatReturns = [];
  List<VATTransaction> _transactions = [];
  VATSummary? _currentSummary;

  // Getters
  Stream<List<VATReturn>> get vatReturnsStream => _vatReturnsController.stream;
  Stream<VATSummary> get vatSummaryStream => _vatSummaryController.stream;
  Stream<List<VATTransaction>> get transactionsStream => _transactionsController.stream;
  
  List<VATReturn> get vatReturns => List.unmodifiable(_vatReturns);
  List<VATTransaction> get transactions => List.unmodifiable(_transactions);
  VATSummary? get currentSummary => _currentSummary;

  /// Initialize VAT return service
  Future<void> initialize() async {
    try {

      _setupDioClient();
      
      // Load cached data
      await _loadCachedData();

    } catch (e) {
      
      _vatReturnsController.addError(e);
    }
  }

  /// Setup Dio client with Nepal-specific configurations
  void _setupDioClient() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'X-Country': 'NP',
        'X-Currency': 'NPR',
        'X-Timezone': 'Asia/Kathmandu',
        'X-VAT-Rate': _vatRate.toString(),
      },
    ));

    // Add request interceptor for authentication
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
// final token = prefs.getString('auth_token'); // TODO: Move to environment variables
          
// if (token != null) { // TODO: Move to environment variables
// options.headers['Authorization'] = 'Bearer $token'; // TODO: Move to environment variables
          }
          
          handler.next(options);
        },
        onError: (error, handler) async {
          
          handler.next(error);
        },
      ),
    );
  }

  /// Load VAT returns from server
  Future<void> loadVATReturns({String? period}) async {
    try {

      final response = await _dio.get(
        '/api/vat/returns',
        queryParameters: period != null ? {'period': period} : null,
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['vatReturns'] != null) {
          _vatReturns = (data['vatReturns'] as List)
              .map((json) => VATReturn.fromJson(json))
              .toList();
          
          _vatReturnsController.add(_vatReturns);
          await _cacheVATReturns();

        }
      }
    } catch (e) {
      
      // Load mock data as fallback
      await _loadMockVATReturns();
    }
  }

  /// Load VAT transactions from server
  Future<void> loadVATTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? transactionType,
  }) async {
    try {

      final response = await _dio.get(
        '/api/vat/transactions',
        queryParameters: {
          if (startDate != null) 'startDate': startDate.toIso8601String(),
          if (endDate != null) 'endDate': endDate.toIso8601String(),
          if (transactionType != null) 'transactionType': transactionType,
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['transactions'] != null) {
          _transactions = (data['transactions'] as List)
              .map((json) => VATTransaction.fromJson(json))
              .toList();
          
          _transactionsController.add(_transactions);
          await _cacheVATTransactions();

        }
      }
    } catch (e) {
      
      // Load mock data as fallback
      await _loadMockVATTransactions();
    }
  }

  /// Calculate VAT summary for a period
  Future<VATSummary> calculateVATSummary({
    DateTime? startDate,
    DateTime? endDate,
    String? period,
  }) async {
    try {

      final response = await _dio.post(
        '/api/vat/summary',
        data: {
          if (startDate != null) 'startDate': startDate.toIso8601String(),
          if (endDate != null) 'endDate': endDate.toIso8601String(),
          if (period != null) 'period': period,
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['summary'] != null) {
          _currentSummary = VATSummary.fromJson(data['summary']);
          _vatSummaryController.add(_currentSummary!);

          return _currentSummary!;
        }
      }
    } catch (e) {
      
      // Calculate from local data as fallback
      return _calculateLocalVATSummary(startDate, endDate);
    }
    
    throw Exception('Failed to calculate VAT summary');
  }

  /// Generate VAT return report
  Future<VATReturn> generateVATReturn({
    required DateTime startDate,
    required DateTime endDate,
    required VATReturnType returnType,
    Map<String, dynamic>? additionalData,
  }) async {
    try {

      final response = await _dio.post(
        '/api/vat/returns/generate',
        data: {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'returnType': returnType.toString(),
          'vatRate': _vatRate,
          if (additionalData != null) ...additionalData,
        },
      );
      
      if (response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true && data['vatReturn'] != null) {
          final vatReturn = VATReturn.fromJson(data['vatReturn']);
          _vatReturns.insert(0, vatReturn);
          _vatReturnsController.add(_vatReturns);

          return vatReturn;
        }
      }
    } catch (e) {
      
      throw Exception('Failed to generate VAT return: $e');
    }
    
    throw Exception('Failed to generate VAT return');
  }

  /// Submit VAT return to tax authorities
  Future<bool> submitVATReturn({
    required String vatReturnId,
    required Map<String, dynamic> submissionData,
  }) async {
    try {

      final response = await _dio.post(
        '/api/vat/returns/$vatReturnId/submit',
        data: {
          'submissionData': submissionData,
          'submittedAt': DateTime.now().toIso8601String(),
          'status': VATReturnStatus.submitted.toString(),
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          // Update local status
          final index = _vatReturns.indexWhere((vr) => vr.id == vatReturnId);
          if (index != -1) {
            _vatReturns[index] = _vatReturns[index].copyWith(
              status: VATReturnStatus.submitted,
              submittedAt: DateTime.now(),
            );
            _vatReturnsController.add(_vatReturns);
          }

          return true;
        }
      }
    } catch (e) {
      
    }
    
    return false;
  }

  /// Get VAT return by ID
  VATReturn? getVATReturnById(String id) {
    try {
      return _vatReturns.firstWhere((vr) => vr.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get VAT returns by status
  List<VATReturn> getVATReturnsByStatus(VATReturnStatus status) {
    return _vatReturns.where((vr) => vr.status == status).toList();
  }

  /// Get VAT returns by period
  List<VATReturn> getVATReturnsByPeriod(String period) {
    return _vatReturns.where((vr) => vr.period == period).toList();
  }

  /// Validate VAT return data
  VATValidationResult validateVATReturn({
    required DateTime startDate,
    required DateTime endDate,
    required List<VATTransaction> transactions,
  }) {
    final errors = <String>[];
    final warnings = <String>[];
    
    // Validate date range
    if (startDate.isAfter(endDate)) {
      errors.add('Start date must be before end date');
    }
    
    if (endDate.difference(startDate).inDays > 365) {
      warnings.add('VAT return period exceeds 365 days');
    }
    
    // Validate transactions
    if (transactions.isEmpty) {
      warnings.add('No transactions found for the selected period');
    }
    
    // Validate VAT calculations
    double totalSales = 0.0;
    double totalVAT = 0.0;
    
    for (final transaction in transactions) {
      if (transaction.type == VATTransactionType.sale) {
        totalSales += transaction.amount;
        totalVAT += transaction.vatAmount;
      }
    }
    
    // Check if VAT is correctly calculated
    final expectedVAT = totalSales * _vatRate;
    if ((totalVAT - expectedVAT).abs() > 0.01) {
      errors.add('VAT calculation mismatch detected');
    }
    
    return VATValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Export VAT return to PDF
  Future<Uint8List> exportVATReturnToPDF(VATReturn vatReturn) async {
    try {

      final response = await _dio.post(
        '/api/vat/returns/${vatReturn.id}/export/pdf',
        data: {
          'format': 'pdf',
          'includeDetails': true,
          'includeCharts': true,
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['pdfData'] != null) {
          final pdfData = base64.decode(data['pdfData']);
          
          return Uint8List.fromList(pdfData);
        }
      }
    } catch (e) {
      
    }
    
    throw Exception('Failed to export VAT return to PDF');
  }

  /// Load mock VAT returns (fallback)
  Future<void> _loadMockVATReturns() async {
    try {
      _vatReturns = [
        VATReturn(
          id: 'VR-2024-Q1-001',
          period: 'Q1-2024',
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 3, 31),
          totalSales: 1500000.0,
          totalVAT: 195000.0,
          totalPurchases: 800000.0,
          totalInputVAT: 104000.0,
          payableVAT: 91000.0,
          status: VATReturnStatus.submitted,
          submittedAt: DateTime(2024, 4, 15),
          returnType: VATReturnType.quarterly,
          taxPeriod: '2024 Q1',
        ),
        VATReturn(
          id: 'VR-2024-Q2-002',
          period: 'Q2-2024',
          startDate: DateTime(2024, 4, 1),
          endDate: DateTime(2024, 6, 30),
          totalSales: 1800000.0,
          totalVAT: 234000.0,
          totalPurchases: 950000.0,
          totalInputVAT: 123500.0,
          payableVAT: 110500.0,
          status: VATReturnStatus.draft,
          returnType: VATReturnType.quarterly,
          taxPeriod: '2024 Q2',
        ),
        VATReturn(
          id: 'VR-2024-MAR-003',
          period: 'March-2024',
          startDate: DateTime(2024, 3, 1),
          endDate: DateTime(2024, 3, 31),
          totalSales: 550000.0,
          totalVAT: 71500.0,
          totalPurchases: 320000.0,
          totalInputVAT: 41600.0,
          payableVAT: 29900.0,
          status: VATReturnStatus.approved,
          approvedAt: DateTime(2024, 4, 20),
          returnType: VATReturnType.monthly,
          taxPeriod: '2024 March',
        ),
      ];
      
      _vatReturnsController.add(_vatReturns);
      
    } catch (e) {
      
    }
  }

  /// Load mock VAT transactions (fallback)
  Future<void> _loadMockVATTransactions() async {
    try {
      _transactions = [
        VATTransaction(
          id: 'VT-001',
          date: DateTime(2024, 3, 15),
          type: VATTransactionType.sale,
          description: 'Sales to Kathmandu Pharmacy',
          amount: 50000.0,
          vatAmount: 6500.0,
          customerName: 'Kathmandu Pharmacy',
          invoiceNumber: 'INV-2024-001',
          category: 'Medicines',
        ),
        VATTransaction(
          id: 'VT-002',
          date: DateTime(2024, 3, 16),
          type: VATTransactionType.purchase,
          description: 'Purchase from Distributor',
          amount: 30000.0,
          vatAmount: 3900.0,
          vendorName: 'MediCorp Distributors',
          invoiceNumber: 'PUR-2024-001',
          category: 'Medical Supplies',
        ),
        VATTransaction(
          id: 'VT-003',
          date: DateTime(2024, 3, 17),
          type: VATTransactionType.sale,
          description: 'Sales to Pokhara Medical',
          amount: 75000.0,
          vatAmount: 9750.0,
          customerName: 'Pokhara Medical',
          invoiceNumber: 'INV-2024-002',
          category: 'Equipment',
        ),
      ];
      
      _transactionsController.add(_transactions);
      
    } catch (e) {
      
    }
  }

  /// Calculate local VAT summary (fallback)
  VATSummary _calculateLocalVATSummary(DateTime? startDate, DateTime? endDate) {
    final filteredTransactions = _transactions.where((t) {
      if (startDate != null && t.date.isBefore(startDate)) return false;
      if (endDate != null && t.date.isAfter(endDate)) return false;
      return true;
    }).toList();

    final totalSales = filteredTransactions
        .where((t) => t.type == VATTransactionType.sale)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final totalPurchases = filteredTransactions
        .where((t) => t.type == VATTransactionType.purchase)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final totalOutputVAT = filteredTransactions
        .where((t) => t.type == VATTransactionType.sale)
        .fold(0.0, (sum, t) => sum + t.vatAmount);
    
    final totalInputVAT = filteredTransactions
        .where((t) => t.type == VATTransactionType.purchase)
        .fold(0.0, (sum, t) => sum + t.vatAmount);
    
    final payableVAT = totalOutputVAT - totalInputVAT;

    return VATSummary(
      period: startDate != null && endDate != null 
          ? '${startDate.toString().split('-')[1]}-${endDate.toString().split('-')[1]}'
          : 'Current Period',
      startDate: startDate ?? DateTime.now().subtract(const Duration(days: 30)),
      endDate: endDate ?? DateTime.now(),
      totalSales: totalSales,
      totalPurchases: totalPurchases,
      totalOutputVAT: totalOutputVAT,
      totalInputVAT: totalInputVAT,
      payableVAT: payableVAT,
      transactionCount: filteredTransactions.length,
      averageTransactionValue: filteredTransactions.isEmpty 
          ? 0.0 
          : filteredTransactions.fold(0.0, (sum, t) => sum + t.amount) / filteredTransactions.length,
      topCategories: _getTopCategories(filteredTransactions),
      generatedAt: DateTime.now(),
    );
  }

  /// Get top categories from transactions
  List<String> _getTopCategories(List<VATTransaction> transactions) {
    final categoryCounts = <String, int>{};
    
    for (final transaction in transactions) {
      categoryCounts[transaction.category] = 
          (categoryCounts[transaction.category] ?? 0) + 1;
    }
    
    final sortedCategories = categoryCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedCategories
        .take(5)
        .map((e) => e.key)
        .toList();
  }

  /// Cache VAT returns
  Future<void> _cacheVATReturns() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vatReturnsJson = jsonEncode(
        _vatReturns.map((vr) => vr.toJson()).toList(),
      );
      await prefs.setString('cached_vat_returns', vatReturnsJson);
    } catch (e) {
      
    }
  }

  /// Cache VAT transactions
  Future<void> _cacheVATTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final transactionsJson = jsonEncode(
        _transactions.map((t) => t.toJson()).toList(),
      );
      await prefs.setString('cached_vat_transactions', transactionsJson);
    } catch (e) {
      
    }
  }

  /// Load cached data
  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load cached VAT returns
      final vatReturnsJson = prefs.getString('cached_vat_returns');
      if (vatReturnsJson != null) {
        final vatReturnsList = List<Map<String, dynamic>>.from(
          jsonDecode(vatReturnsJson)
        );
        _vatReturns = vatReturnsList
            .map((json) => VATReturn.fromJson(json))
            .toList();
        _vatReturnsController.add(_vatReturns);
      }
      
      // Load cached transactions
      final transactionsJson = prefs.getString('cached_vat_transactions');
      if (transactionsJson != null) {
        final transactionsList = List<Map<String, dynamic>>.from(
          jsonDecode(transactionsJson)
        );
        _transactions = transactionsList
            .map((json) => VATTransaction.fromJson(json))
            .toList();
        _transactionsController.add(_transactions);
      }

    } catch (e) {
      
    }
  }

  /// Clear cached data
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_vat_returns');
      await prefs.remove('cached_vat_transactions');
      
      _vatReturns.clear();
      _transactions.clear();
      _currentSummary = null;
      
      _vatReturnsController.add(_vatReturns);
      _transactionsController.add(_transactions);

    } catch (e) {
      
    }
  }

  /// Dispose resources
  void dispose() {
    _vatReturnsController.close();
    _vatSummaryController.close();
    _transactionsController.close();
    
  }
}

/// VAT Return Model
class VATReturn {
  final String id;
  final String period;
  final DateTime startDate;
  final DateTime endDate;
  final double totalSales;
  final double totalVAT;
  final double totalPurchases;
  final double totalInputVAT;
  final double payableVAT;
  final VATReturnStatus status;
  final DateTime? submittedAt;
  final DateTime? approvedAt;
  final VATReturnType returnType;
  final String taxPeriod;
  final String? remarks;
  final DateTime createdAt;

  const VATReturn({
    required this.id,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.totalSales,
    required this.totalVAT,
    required this.totalPurchases,
    required this.totalInputVAT,
    required this.payableVAT,
    required this.status,
    this.submittedAt,
    this.approvedAt,
    required this.returnType,
    required this.taxPeriod,
    this.remarks,
    required this.createdAt,
  });

  factory VATReturn.fromJson(Map<String, dynamic> json) {
    return VATReturn(
      id: json['id'] as String,
      period: json['period'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalSales: (json['totalSales'] as num).toDouble(),
      totalVAT: (json['totalVAT'] as num).toDouble(),
      totalPurchases: (json['totalPurchases'] as num).toDouble(),
      totalInputVAT: (json['totalInputVAT'] as num).toDouble(),
      payableVAT: (json['payableVAT'] as num).toDouble(),
      status: VATReturnStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => VATReturnStatus.draft,
      ),
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'] as String)
          : null,
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'] as String)
          : null,
      returnType: VATReturnType.values.firstWhere(
        (e) => e.toString() == json['returnType'],
        orElse: () => VATReturnType.monthly,
      ),
      taxPeriod: json['taxPeriod'] as String,
      remarks: json['remarks'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  VATReturn copyWith({
    String? id,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
    double? totalSales,
    double? totalVAT,
    double? totalPurchases,
    double? totalInputVAT,
    double? payableVAT,
    VATReturnStatus? status,
    DateTime? submittedAt,
    DateTime? approvedAt,
    VATReturnType? returnType,
    String? taxPeriod,
    String? remarks,
    DateTime? createdAt,
  }) {
    return VATReturn(
      id: id ?? this.id,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalSales: totalSales ?? this.totalSales,
      totalVAT: totalVAT ?? this.totalVAT,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      totalInputVAT: totalInputVAT ?? this.totalInputVAT,
      payableVAT: payableVAT ?? this.payableVAT,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      returnType: returnType ?? this.returnType,
      taxPeriod: taxPeriod ?? this.taxPeriod,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'period': period,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalSales': totalSales,
      'totalVAT': totalVAT,
      'totalPurchases': totalPurchases,
      'totalInputVAT': totalInputVAT,
      'payableVAT': payableVAT,
      'status': status.toString(),
      'submittedAt': submittedAt?.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'returnType': returnType.toString(),
      'taxPeriod': taxPeriod,
      'remarks': remarks,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Computed properties
  int get daysInPeriod => endDate.difference(startDate).inDays + 1;
  
  String get formattedTotalSales => NepalLocalizationUtils.formatNPRCurrency(totalSales);
  String get formattedTotalVAT => NepalLocalizationUtils.formatNPRCurrency(totalVAT);
  String get formattedPayableVAT => NepalLocalizationUtils.formatNPRCurrency(payableVAT);
  
  bool get isOverdue => DateTime.now().isAfter(endDate.add(const Duration(days: 30)));
  
  String get statusText {
    switch (status) {
      case VATReturnStatus.draft:
        return 'Draft';
      case VATReturnStatus.submitted:
        return 'Submitted';
      case VATReturnStatus.approved:
        return 'Approved';
      case VATReturnStatus.rejected:
        return 'Rejected';
      case VATReturnStatus.paid:
        return 'Paid';
    }
  }
}

/// VAT Transaction Model
class VATTransaction {
  final String id;
  final DateTime date;
  final VATTransactionType type;
  final String description;
  final double amount;
  final double vatAmount;
  final String? customerName;
  final String? vendorName;
  final String? invoiceNumber;
  final String category;
  final String? remarks;

  const VATTransaction({
    required this.id,
    required this.date,
    required this.type,
    required this.description,
    required this.amount,
    required this.vatAmount,
    this.customerName,
    this.vendorName,
    this.invoiceNumber,
    required this.category,
    this.remarks,
  });

  factory VATTransaction.fromJson(Map<String, dynamic> json) {
    return VATTransaction(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      type: VATTransactionType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => VATTransactionType.sale,
      ),
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      vatAmount: (json['vatAmount'] as num).toDouble(),
      customerName: json['customerName'] as String?,
      vendorName: json['vendorName'] as String?,
      invoiceNumber: json['invoiceNumber'] as String?,
      category: json['category'] as String,
      remarks: json['remarks'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'type': type.toString(),
      'description': description,
      'amount': amount,
      'vatAmount': vatAmount,
      'customerName': customerName,
      'vendorName': vendorName,
      'invoiceNumber': invoiceNumber,
      'category': category,
      'remarks': remarks,
    };
  }

  String get formattedAmount => NepalLocalizationUtils.formatNPRCurrency(amount);
  String get formattedVATAmount => NepalLocalizationUtils.formatNPRCurrency(vatAmount);
  String get formattedDate => NepalLocalizationUtils.formatNepaliDate(date);
}

/// VAT Summary Model
class VATSummary {
  final String period;
  final DateTime startDate;
  final DateTime endDate;
  final double totalSales;
  final double totalPurchases;
  final double totalOutputVAT;
  final double totalInputVAT;
  final double payableVAT;
  final int transactionCount;
  final double averageTransactionValue;
  final List<String> topCategories;
  final DateTime generatedAt;

  const VATSummary({
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.totalSales,
    required this.totalPurchases,
    required this.totalOutputVAT,
    required this.totalInputVAT,
    required this.payableVAT,
    required this.transactionCount,
    required this.averageTransactionValue,
    required this.topCategories,
    required this.generatedAt,
  });

  factory VATSummary.fromJson(Map<String, dynamic> json) {
    return VATSummary(
      period: json['period'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalSales: (json['totalSales'] as num).toDouble(),
      totalPurchases: (json['totalPurchases'] as num).toDouble(),
      totalOutputVAT: (json['totalOutputVAT'] as num).toDouble(),
      totalInputVAT: (json['totalInputVAT'] as num).toDouble(),
      payableVAT: (json['payableVAT'] as num).toDouble(),
      transactionCount: (json['transactionCount'] as num).toInt(),
      averageTransactionValue: (json['averageTransactionValue'] as num).toDouble(),
      topCategories: List<String>.from(json['topCategories'] as List),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );
  }

  String get formattedTotalSales => NepalLocalizationUtils.formatNPRCurrency(totalSales);
  String get formattedPayableVAT => NepalLocalizationUtils.formatNPRCurrency(payableVAT);
  String get formattedAverageTransactionValue => NepalLocalizationUtils.formatNPRCurrency(averageTransactionValue);
}

/// VAT Validation Result
class VATValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const VATValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });
}

/// Enums
enum VATReturnStatus {
  draft,
  submitted,
  approved,
  rejected,
  paid,
}

enum VATTransactionType {
  sale,
  purchase,
  refund,
  adjustment,
}

enum VATReturnType {
  monthly,
  quarterly,
  yearly,
}

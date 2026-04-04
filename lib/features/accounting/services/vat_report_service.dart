import 'package:vedanta_trade/core/constants/app_constants.dart';
import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

/// VAT report service for Nepal-compliant tax returns
class VATReportService {
  static final VATReportService _instance = VATReportService._internal();
  factory VATReportService() => _instance;
  VATReportService._internal();

  late Dio _dio;
  List<VATReport> _reports = [];
  List<ExpenseClaim> _expenseClaims = [];
  final StreamController<List<VATReport>> _reportsController = 
      StreamController<List<VATReport>>.broadcast();
  final StreamController<List<ExpenseClaim>> _claimsController = 
      StreamController<List<ExpenseClaim>>.broadcast();
  
  Stream<List<VATReport>> get reportsStream => _reportsController.stream;
  Stream<List<ExpenseClaim>> get claimsStream => _claimsController.stream;
  List<VATReport> get reports => List.unmodifiable(_reports);
  List<ExpenseClaim> get expenseClaims => List.unmodifiable(_expenseClaims);

  /// Initialize VAT report service
  Future<void> initialize() async {
    try {

      // Setup Dio client
      _setupDioClient();
      
      // Load cached reports
      await _loadCachedReports();
      
      // Load cached expense claims
      await _loadCachedExpenseClaims();

    } catch (e) {
      
      _reportsController.addError(e);
    }
  }

  /// Setup Dio client with Nepal-specific configurations
  void _setupDioClient() {
    _dio = Dio(BaseOptions(
      baseUrl: 'AppConstants.apiBaseUrl',
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
          
          handler.next(error);
        },
      ),
    );
  }

  /// Load cached reports from storage
  Future<void> _loadCachedReports() async {
    try {

      final prefs = await SharedPreferences.getInstance();
      final reportsJson = prefs.getString('cached_vat_reports');
      
      if (reportsJson != null) {
        final reportsList = List<Map<String, dynamic>>.from(
          jsonDecode(reportsJson)
        );
        
        _reports = reportsList
            .map((json) => VATReport.fromJson(json))
            .toList();
        
        _reportsController.add(_reports);
        
      }
      
    } catch (e) {
      
    }
  }

  /// Load cached expense claims from storage
  Future<void> _loadCachedExpenseClaims() async {
    try {

      final prefs = await SharedPreferences.getInstance();
      final claimsJson = prefs.getString('cached_expense_claims');
      
      if (claimsJson != null) {
        final claimsList = List<Map<String, dynamic>>.from(
          jsonDecode(claimsJson)
        );
        
        _expenseClaims = claimsList
            .map((json) => ExpenseClaim.fromJson(json))
            .toList();
        
        _claimsController.add(_expenseClaims);
        
      }
      
    } catch (e) {
      
    }
  }

  /// Generate VAT report for specific period
  Future<VATReport?> generateVATReport({
    required DateTime startDate,
    required DateTime endDate,
    required String reportType,
    String? description,
  }) async {
    try {

      // Fetch transactions from server
      final transactions = await _fetchTransactions(startDate, endDate);
      
      // Calculate VAT amounts
      final vatCalculations = _calculateVAT(transactions);
      
      // Generate report data
      final reportData = {
        'reportId': 'VAT-${DateTime.now().millisecondsSinceEpoch}',
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'reportType': reportType,
        'description': description,
        'transactions': transactions.map((t) => t.toJson()).toList(),
        'vatCalculations': vatCalculations.toJson(),
        'generatedAt': DateTime.now().toIso8601String(),
        'generatedBy': await _getCurrentUser(),
        'currency': 'NPR',
        'vatRate': 13.0,
      };
      
      // Create report on server
      final response = await _dio.post(
        '/api/vat/reports',
        data: reportData,
      );
      
      if (response.statusCode == 201) {
        final reportJson = response.data['report'];
        final newReport = VATReport.fromJson(reportJson);
        
        _reports.insert(0, newReport);
        _reportsController.add(_reports);
        
        // Cache reports
        await _cacheReports();

        return newReport;
      }
      
    } catch (e) {
      
      throw Exception('Failed to generate VAT report: $e');
    }
    
    return null;
  }

  /// Fetch transactions for VAT calculation
  Future<List<Transaction>> _fetchTransactions(DateTime startDate, DateTime endDate) async {
    try {

      final response = await _dio.get(
        '/api/transactions/vat-calculation',
        queryParameters: {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );
      
      if (response.statusCode == 200) {
        final transactionsData = response.data['transactions'] as List;
        final transactions = transactionsData
            .map((json) => Transaction.fromJson(json))
            .toList();

        return transactions;
      }
      
    } catch (e) {
      
    }
    
    return [];
  }

  /// Calculate VAT amounts
  VATCalculations _calculateVAT(List<Transaction> transactions) {

    double totalSales = 0.0;
    double totalPurchases = 0.0;
    double totalVATOnSales = 0.0;
    double totalVATOnPurchases = 0.0;
    double netVATPayable = 0.0;
    
    for (final transaction in transactions) {
      switch (transaction.type) {
        case TransactionType.sales:
          totalSales += transaction.amount;
          totalVATOnSales += transaction.vatAmount;
          break;
        case TransactionType.purchase:
          totalPurchases += transaction.amount;
          totalVATOnPurchases += transaction.vatAmount;
          break;
      }
    }
    
    // Nepal VAT calculation
    netVATPayable = totalVATOnSales - totalVATOnPurchases;
    
    return VATCalculations(
      totalSales: totalSales,
      totalPurchases: totalPurchases,
      totalVATOnSales: totalVATOnSales,
      totalVATOnPurchases: totalVATOnPurchases,
      netVATPayable: netVATPayable,
      vatRate: 13.0,
      transactionCount: transactions.length,
    );
  }

  /// Generate VAT return PDF
  Future<String?> generateVATReturnPDF(String reportId) async {
    try {

      // Find the report
      final report = _reports.firstWhere((r) => r.id == reportId);
      
      // Create PDF document
      final pdf = pw.Document();
      
      // Add title page
      pdf.addPage(
        pw.Page(
          pageFormat: pw.PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildPDFHeader(context, report),
              pw.SizedBox(height: 20),
              
              // VAT Summary
              _buildPDFVATSummary(context, report.vatCalculations),
              pw.SizedBox(height: 20),
              
              // Transaction Details
              _buildPDFTransactionDetails(context, report.transactions),
              pw.SizedBox(height: 20),
              
              // Footer
              _buildPDFFooter(context, report),
            ],
          ),
        ),
      );
      
      // Save PDF
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/VAT_Return_${report.id}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      return filePath;
      
    } catch (e) {
      
      throw Exception('Failed to generate VAT return PDF: $e');
    }
  }

  /// Build PDF header
  pw.Widget _buildPDFHeader(pw.Context context, VATReport report) {
    return pw.Container(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'VAT RETURN - NEPAL',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Report ID: ${report.id}',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                    pw.Text(
                      'Period: ${_formatDate(report.startDate)} to ${_formatDate(report.endDate)}',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                    pw.Text(
                      'Generated: ${_formatDate(report.generatedAt)}',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              pw.Container(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'VAT Rate: ${report.vatRate}%',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.red,
                      ),
                    ),
                    pw.Text(
                      'Currency: NPR',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build PDF VAT summary
  pw.Widget _buildPDFVATSummary(pw.Context context, VATCalculations calculations) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'VAT SUMMARY',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text(
                  'Total Sales (NPR)',
                  style: pw.TextStyle(fontSize: 12),
                ),
              ),
              pw.Text(
                '₹${calculations.totalSales.toStringAsFixed(2)}',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text(
                  'VAT on Sales (NPR)',
                  style: pw.TextStyle(fontSize: 12),
                ),
              ),
              pw.Text(
                '₹${calculations.totalVATOnSales.toStringAsFixed(2)}',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text(
                  'Total Purchases (NPR)',
                  style: pw.TextStyle(fontSize: 12),
                ),
              ),
              pw.Text(
                '₹${calculations.totalPurchases.toStringAsFixed(2)}',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text(
                  'VAT on Purchases (NPR)',
                  style: pw.TextStyle(fontSize: 12),
                ),
              ),
              pw.Text(
                '₹${calculations.totalVATOnPurchases.toStringAsFixed(2)}',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            padding: const pw.EdgeInsets.all(5),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
            ),
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Text(
                    'NET VAT PAYABLE (NPR)',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.red,
                    ),
                  ),
                ),
                pw.Text(
                  '₹${calculations.netVATPayable.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build PDF transaction details
  pw.Widget _buildPDFTransactionDetails(pw.Context context, List<Transaction> transactions) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'TRANSACTION DETAILS',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey),
          columnWidths: {
            0: pw.FlexColumnWidth(2),
            1: pw.FlexColumnWidth(3),
            2: pw.FlexColumnWidth(2),
            3: pw.FlexColumnWidth(2),
            4: pw.FlexColumnWidth(2),
            5: pw.FlexColumnWidth(2),
          },
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
          headerDecoration: pw.BoxDecoration(
            color: PdfColors.blue,
          ),
          children: [
            // Table header
            pw.TableRow(
              children: [
                _buildPDFCell('Date'),
                _buildPDFCell('Description'),
                _buildPDFCell('Type'),
                _buildPDFCell('Amount'),
                _buildPDFCell('VAT'),
                _buildPDFCell('Total'),
              ],
            ),
            // Table rows
            ...transactions.map((transaction) => pw.TableRow(
              children: [
                _buildPDFCell(_formatDate(transaction.date)),
                _buildPDFCell(transaction.description),
                _buildPDFCell(transaction.type.toString().split('.').last),
                _buildPDFCell('₹${transaction.amount.toStringAsFixed(2)}'),
                _buildPDFCell('₹${transaction.vatAmount.toStringAsFixed(2)}'),
                _buildPDFCell('₹${transaction.totalAmount.toStringAsFixed(2)}'),
              ],
            )),
          ],
        ),
      ],
    );
  }

  /// Build PDF cell
  pw.Widget _buildPDFCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 10),
      ),
    );
  }

  /// Build PDF footer
  pw.Widget _buildPDFFooter(pw.Context context, VATReport report) {
    return pw.Container(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(height: 20),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Generated by: ${report.generatedBy}',
                      style: pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      'This is a computer-generated document',
                      style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic),
                    ),
                  ],
                ),
              ),
              pw.Text(
                'Page ${context.pageNumber}',
                style: pw.TextStyle(fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Submit expense claim for MR
  Future<ExpenseClaim?> submitExpenseClaim(ExpenseClaimRequest request) async {
    try {

      final response = await _dio.post(
        '/api/expense-claims',
        data: request.toJson(),
      );
      
      if (response.statusCode == 201) {
        final claimJson = response.data['claim'];
        final newClaim = ExpenseClaim.fromJson(claimJson);
        
        _expenseClaims.insert(0, newClaim);
        _claimsController.add(_expenseClaims);
        
        // Cache claims
        await _cacheExpenseClaims();

        return newClaim;
      }
      
    } catch (e) {
      
      throw Exception('Failed to submit expense claim: $e');
    }
    
    return null;
  }

  /// Approve expense claim (Accountant action)
  Future<bool> approveExpenseClaim(String claimId, String? notes) async {
    try {

      final response = await _dio.put(
        '/api/expense-claims/$claimId/approve',
        data: {
          'approvedAt': DateTime.now().toIso8601String(),
          'approvedBy': await _getCurrentUser(),
          'notes': notes,
        },
      );
      
      if (response.statusCode == 200) {
        final claimIndex = _expenseClaims.indexWhere((claim) => claim.id == claimId);
        if (claimIndex != -1) {
          _expenseClaims[claimIndex] = _expenseClaims[claimIndex].copyWith(
            status: ExpenseClaimStatus.approved,
            approvedAt: DateTime.now(),
            approvedBy: await _getCurrentUser(),
            notes: notes,
          );
          _claimsController.add(_expenseClaims);
          
          // Cache claims
          await _cacheExpenseClaims();

          return true;
        }
      }
      
    } catch (e) {
      
      throw Exception('Failed to approve expense claim: $e');
    }
    
    return false;
  }

  /// Reject expense claim (Accountant action)
  Future<bool> rejectExpenseClaim(String claimId, String reason) async {
    try {

      final response = await _dio.put(
        '/api/expense-claims/$claimId/reject',
        data: {
          'rejectedAt': DateTime.now().toIso8601String(),
          'rejectedBy': await _getCurrentUser(),
          'rejectionReason': reason,
        },
      );
      
      if (response.statusCode == 200) {
        final claimIndex = _expenseClaims.indexWhere((claim) => claim.id == claimId);
        if (claimIndex != -1) {
          _expenseClaims[claimIndex] = _expenseClaims[claimIndex].copyWith(
            status: ExpenseClaimStatus.rejected,
            rejectedAt: DateTime.now(),
            rejectedBy: await _getCurrentUser(),
            rejectionReason: reason,
          );
          _claimsController.add(_expenseClaims);
          
          // Cache claims
          await _cacheExpenseClaims();

          return true;
        }
      }
      
    } catch (e) {
      
      throw Exception('Failed to reject expense claim: $e');
    }
    
    return false;
  }

  /// Get VAT reports by date range
  List<VATReport> getVATReportsByDateRange(DateTime startDate, DateTime endDate) {
    return _reports.where((report) {
      return report.generatedAt.isAfter(startDate) && report.generatedAt.isBefore(endDate);
    }).toList();
  }

  /// Get pending expense claims
  List<ExpenseClaim> getPendingExpenseClaims() {
    return _expenseClaims.where((claim) => claim.status == ExpenseClaimStatus.pending).toList();
  }

  /// Get approved expense claims
  List<ExpenseClaim> getApprovedExpenseClaims() {
    return _expenseClaims.where((claim) => claim.status == ExpenseClaimStatus.approved).toList();
  }

  /// Get rejected expense claims
  List<ExpenseClaim> getRejectedExpenseClaims() {
    return _expenseClaims.where((claim) => claim.status == ExpenseClaimStatus.rejected).toList();
  }

  /// Get current user
  Future<String> _getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name') ?? 'Unknown User';
  }

  /// Format date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Cache reports to storage
  Future<void> _cacheReports() async {
    try {

      final prefs = await SharedPreferences.getInstance();
      final reportsJson = jsonEncode(
        _reports.map((report) => report.toJson()).toList(),
      );
      
      await prefs.setString('cached_vat_reports', reportsJson);
      await prefs.setString('last_reports_update', DateTime.now().toIso8601String());

    } catch (e) {
      
    }
  }

  /// Cache expense claims to storage
  Future<void> _cacheExpenseClaims() async {
    try {

      final prefs = await SharedPreferences.getInstance();
      final claimsJson = jsonEncode(
        _expenseClaims.map((claim) => claim.toJson()).toList(),
      );
      
      await prefs.setString('cached_expense_claims', claimsJson);
      await prefs.setString('last_claims_update', DateTime.now().toIso8601String());

    } catch (e) {
      
    }
  }

  /// Open generated PDF
  Future<void> openPDF(String filePath) async {
    try {

      final result = await OpenFile.open(filePath);
      
      if (result.type == ResultType.done) {
        
      } else {
        
      }
      
    } catch (e) {
      
    }
  }

  /// Dispose resources
  void dispose() {

    _reportsController.close();
    _claimsController.close();

  }
}

/// VAT report model
class VATReport {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final String reportType;
  final String? description;
  final List<Transaction> transactions;
  final VATCalculations vatCalculations;
  final DateTime generatedAt;
  final String generatedBy;
  final String currency;
  final double vatRate;
  
  VATReport({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.reportType,
    this.description,
    required this.transactions,
    required this.vatCalculations,
    required this.generatedAt,
    required this.generatedBy,
    required this.currency,
    required this.vatRate,
  });

  factory VATReport.fromJson(Map<String, dynamic> json) {
    return VATReport(
      id: json['id'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      reportType: json['reportType'] as String,
      description: json['description'] as String?,
      transactions: (json['transactions'] as List)
          .map((item) => Transaction.fromJson(item))
          .toList(),
      vatCalculations: VATCalculations.fromJson(json['vatCalculations']),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      generatedBy: json['generatedBy'] as String,
      currency: json['currency'] as String,
      vatRate: (json['vatRate'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'reportType': reportType,
      'description': description,
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'vatCalculations': vatCalculations.toJson(),
      'generatedAt': generatedAt.toIso8601String(),
      'generatedBy': generatedBy,
      'currency': currency,
      'vatRate': vatRate,
    };
  }
}

/// VAT calculations model
class VATCalculations {
  final double totalSales;
  final double totalPurchases;
  final double totalVATOnSales;
  final double totalVATOnPurchases;
  final double netVATPayable;
  final double vatRate;
  final int transactionCount;
  
  VATCalculations({
    required this.totalSales,
    required this.totalPurchases,
    required this.totalVATOnSales,
    required this.totalVATOnPurchases,
    required this.netVATPayable,
    required this.vatRate,
    required this.transactionCount,
  });

  factory VATCalculations.fromJson(Map<String, dynamic> json) {
    return VATCalculations(
      totalSales: (json['totalSales'] as num).toDouble(),
      totalPurchases: (json['totalPurchases'] as num).toDouble(),
      totalVATOnSales: (json['totalVATOnSales'] as num).toDouble(),
      totalVATOnPurchases: (json['totalVATOnPurchases'] as num).toDouble(),
      netVATPayable: (json['netVATPayable'] as num).toDouble(),
      vatRate: (json['vatRate'] as num).toDouble(),
      transactionCount: json['transactionCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSales': totalSales,
      'totalPurchases': totalPurchases,
      'totalVATOnSales': totalVATOnSales,
      'totalVATOnPurchases': totalVATOnPurchases,
      'netVATPayable': netVATPayable,
      'vatRate': vatRate,
      'transactionCount': transactionCount,
    };
  }
}

/// Transaction model
class Transaction {
  final String id;
  final DateTime date;
  final String description;
  final TransactionType type;
  final double amount;
  final double vatAmount;
  final double totalAmount;
  final String? category;
  final String? reference;
  
  Transaction({
    required this.id,
    required this.date,
    required this.description,
    required this.type,
    required this.amount,
    required this.vatAmount,
    required this.totalAmount,
    this.category,
    this.reference,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => TransactionType.sales,
      ),
      amount: (json['amount'] as num).toDouble(),
      vatAmount: (json['vatAmount'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      category: json['category'] as String?,
      reference: json['reference'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'description': description,
      'type': type.toString(),
      'amount': amount,
      'vatAmount': vatAmount,
      'totalAmount': totalAmount,
      'category': category,
      'reference': reference,
    };
  }
}

/// Expense claim model
class ExpenseClaim {
  final String id;
  final String mrId;
  final String mrName;
  final double amount;
  final String currency;
  final DateTime claimDate;
  final String description;
  final List<String> receiptImages;
  final ExpenseClaimStatus status;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final String? approvedBy;
  final String? rejectedBy;
  final String? notes;
  final String? rejectionReason;
  
  ExpenseClaim({
    required this.id,
    required this.mrId,
    required this.mrName,
    required this.amount,
    required this.currency,
    required this.claimDate,
    required this.description,
    required this.receiptImages,
    required this.status,
    this.approvedAt,
    this.rejectedAt,
    this.approvedBy,
    this.rejectedBy,
    this.notes,
    this.rejectionReason,
  });

  factory ExpenseClaim.fromJson(Map<String, dynamic> json) {
    return ExpenseClaim(
      id: json['id'] as String,
      mrId: json['mrId'] as String,
      mrName: json['mrName'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      claimDate: DateTime.parse(json['claimDate'] as String),
      description: json['description'] as String,
      receiptImages: List<String>.from(json['receiptImages'] as List),
      status: ExpenseClaimStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => ExpenseClaimStatus.pending,
      ),
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'] as String)
          : null,
      rejectedAt: json['rejectedAt'] != null
          ? DateTime.parse(json['rejectedAt'] as String)
          : null,
      approvedBy: json['approvedBy'] as String?,
      rejectedBy: json['rejectedBy'] as String?,
      notes: json['notes'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
    );
  }

  ExpenseClaim copyWith({
    String? id,
    String? mrId,
    String? mrName,
    double? amount,
    String? currency,
    DateTime? claimDate,
    String? description,
    List<String>? receiptImages,
    ExpenseClaimStatus? status,
    DateTime? approvedAt,
    DateTime? rejectedAt,
    String? approvedBy,
    String? rejectedBy,
    String? notes,
    String? rejectionReason,
  }) {
    return ExpenseClaim(
      id: id ?? this.id,
      mrId: mrId ?? this.mrId,
      mrName: mrName ?? this.mrName,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      claimDate: claimDate ?? this.claimDate,
      description: description ?? this.description,
      receiptImages: receiptImages ?? this.receiptImages,
      status: status ?? this.status,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      rejectedBy: rejectedBy ?? this.rejectedBy,
      notes: notes ?? this.notes,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mrId': mrId,
      'mrName': mrName,
      'amount': amount,
      'currency': currency,
      'claimDate': claimDate.toIso8601String(),
      'description': description,
      'receiptImages': receiptImages,
      'status': status.toString(),
      'approvedAt': approvedAt?.toIso8601String(),
      'rejectedAt': rejectedAt?.toIso8601String(),
      'approvedBy': approvedBy,
      'rejectedBy': rejectedBy,
      'notes': notes,
      'rejectionReason': rejectionReason,
    };
  }
}

/// Expense claim request model
class ExpenseClaimRequest {
  final String mrId;
  final double amount;
  final String description;
  final List<String> receiptImages;
  
  ExpenseClaimRequest({
    required this.mrId,
    required this.amount,
    required this.description,
    required this.receiptImages,
  });

  Map<String, dynamic> toJson() {
    return {
      'mrId': mrId,
      'amount': amount,
      'description': description,
      'receiptImages': receiptImages,
    };
  }
}

/// Transaction type enum
enum TransactionType {
  sales,
  purchase,
}

/// Expense claim status enum
enum ExpenseClaimStatus {
  pending,
  approved,
  rejected,
}

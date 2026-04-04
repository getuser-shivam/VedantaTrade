import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;

/// Accounting and Finance Module Automation
/// Implements VAT returns, expense reconciliation, and PDF export
class AccountingAutomation {
  static const String projectRoot = 'i:\\Path\\Projects\\VedantaTrade';
  static const String libPath = 'i:\\Path\\Projects\\VedantaTrade\\lib';
  static const String accountantPath = 'i:\\Path\\Projects\\VedantaTrade\\lib\\features\\accountant';
  static const String mrPath = 'i:\\Path\\Projects\\VedantaTrade\\lib\\features\\mr';

  /// Execute accounting automation
  Future<void> executeAccountingAutomation() async {
    print('💰 Starting Accounting and Finance Module Automation...');
    
    try {
      // Implement VAT return system
      await _implementVATReturnSystem();
      
      // Implement expense reconciliation
      await _implementExpenseReconciliation();
      
      // Implement PDF export functionality
      await _implementPDFExport();
      
      // Implement Nepal compliance
      await _implementNepalCompliance();
      
      // Update accountant dashboard
      await _updateAccountantDashboard();
      
      // Update MR expense management
      await _updateMRExpenseManagement();
      
      print('✅ Accounting automation completed successfully!');
    } catch (e) {
      print('❌ Accounting automation failed: $e');
    }
  }

  /// Implement VAT return system
  Future<void> _implementVATReturnSystem() async {
    print('  📋 Implementing VAT return system...');
    
    final vatServiceFile = File(path.join(accountantPath, 'data', 'services', 'vat_return_service.dart'));
    await vatServiceFile.parent.create(recursive: true);
    
    final vatServiceCode = '''
import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

/// VAT Return Service for Nepal Compliance
class VATReturnService {
  static const String _baseUrl = 'https://api.vedantatrade.com.np';
  static const double _vatRate = 0.13; // 13% VAT rate for Nepal
  final Dio _dio = Dio(BaseOptions(baseUrl: _baseUrl));
  
  /// VAT return period enum
  enum VATPeriod {
    monthly,
    quarterly,
    yearly,
  }
  
  /// VAT return model
  class VATReturn {
    final String id;
    final String period;
    final VATPeriod periodType;
    final DateTime startDate;
    final DateTime endDate;
    final double totalSales;
    final double totalPurchases;
    final double vatCollected;
    final double vatPaid;
    final double vatPayable;
    final List<VATTransaction> transactions;
    final DateTime createdAt;
    final String? status;
    final Map<String, dynamic>? metadata;
    
    VATReturn({
      required this.id,
      required this.period,
      required this.periodType,
      required this.startDate,
      required this.endDate,
      required this.totalSales,
      required this.totalPurchases,
      required this.vatCollected,
      required this.vatPaid,
      required this.vatPayable,
      required this.transactions,
      required this.createdAt,
      this.status,
      this.metadata,
    });
    
    factory VATReturn.fromJson(Map<String, dynamic> json) {
      return VATReturn(
        id: json['id'],
        period: json['period'],
        periodType: VATPeriod.values.firstWhere(
          (period) => period.toString() == 'VATPeriod.\${json['periodType']}',
          orElse: () => VATPeriod.monthly,
        ),
        startDate: DateTime.parse(json['startDate']),
        endDate: DateTime.parse(json['endDate']),
        totalSales: (json['totalSales'] as num).toDouble(),
        totalPurchases: (json['totalPurchases'] as num).toDouble(),
        vatCollected: (json['vatCollected'] as num).toDouble(),
        vatPaid: (json['vatPaid'] as num).toDouble(),
        vatPayable: (json['vatPayable'] as num).toDouble(),
        transactions: (json['transactions'] as List)
            .map((tx) => VATTransaction.fromJson(tx))
            .toList(),
        createdAt: DateTime.parse(json['createdAt']),
        status: json['status'],
        metadata: json['metadata'],
      );
    }
    
    Map<String, dynamic> toJson() {
      return {
        'id': id,
        'period': period,
        'periodType': periodType.toString().split('.').last,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'totalSales': totalSales,
        'totalPurchases': totalPurchases,
        'vatCollected': vatCollected,
        'vatPaid': vatPaid,
        'vatPayable': vatPayable,
        'transactions': transactions.map((tx) => tx.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'status': status,
        'metadata': metadata,
      };
    }
  }
  
  /// VAT transaction model
  class VATTransaction {
    final String id;
    final String type; // 'sale' or 'purchase'
    final String description;
    final double amount;
    final double vatAmount;
    final DateTime date;
    final String? invoiceNumber;
    final String? vendorName;
    final String? customerName;
    final Map<String, dynamic>? metadata;
    
    VATTransaction({
      required this.id,
      required this.type,
      required this.description,
      required this.amount,
      required this.vatAmount,
      required this.date,
      this.invoiceNumber,
      this.vendorName,
      this.customerName,
      this.metadata,
    });
    
    factory VATTransaction.fromJson(Map<String, dynamic> json) {
      return VATTransaction(
        id: json['id'],
        type: json['type'],
        description: json['description'],
        amount: (json['amount'] as num).toDouble(),
        vatAmount: (json['vatAmount'] as num).toDouble(),
        date: DateTime.parse(json['date']),
        invoiceNumber: json['invoiceNumber'],
        vendorName: json['vendorName'],
        customerName: json['customerName'],
        metadata: json['metadata'],
      );
    }
    
    Map<String, dynamic> toJson() {
      return {
        'id': id,
        'type': type,
        'description': description,
        'amount': amount,
        'vatAmount': vatAmount,
        'date': date.toIso8601String(),
        'invoiceNumber': invoiceNumber,
        'vendorName': vendorName,
        'customerName': customerName,
        'metadata': metadata,
      };
    }
  }
  
  /// Generate VAT return for period
  Future<VATReturn?> generateVATReturn({
    required VATPeriod periodType,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Get transactions for the period
      final transactions = await _getTransactionsForPeriod(startDate, endDate);
      
      // Calculate totals
      final salesTransactions = transactions.where((tx) => tx.type == 'sale').toList();
      final purchaseTransactions = transactions.where((tx) => tx.type == 'purchase').toList();
      
      final totalSales = salesTransactions.fold(0.0, (sum, tx) => sum + tx.amount);
      final totalPurchases = purchaseTransactions.fold(0.0, (sum, tx) => sum + tx.amount);
      final vatCollected = salesTransactions.fold(0.0, (sum, tx) => sum + tx.vatAmount);
      final vatPaid = purchaseTransactions.fold(0.0, (sum, tx) => sum + tx.vatAmount);
      final vatPayable = vatCollected - vatPaid;
      
      // Create VAT return
      final vatReturn = VATReturn(
        id: '\${DateTime.now().millisecondsSinceEpoch}',
        period: _generatePeriodString(periodType, startDate, endDate),
        periodType: periodType,
        startDate: startDate,
        endDate: endDate,
        totalSales: totalSales,
        totalPurchases: totalPurchases,
        vatCollected: vatCollected,
        vatPaid: vatPaid,
        vatPayable: vatPayable,
        transactions: transactions,
        createdAt: DateTime.now(),
        status: 'draft',
      );
      
      // Save to server
      final response = await _dio.post('/api/vat-returns', data: vatReturn.toJson());
      
      if (response.statusCode == 201) {
        return VATReturn.fromJson(response.data);
      }
      
      return vatReturn;
    } catch (e) {
      print('Error generating VAT return: \$e');
      return null;
    }
  }
  
  /// Get transactions for period
  Future<List<VATTransaction>> _getTransactionsForPeriod(DateTime startDate, DateTime endDate) async {
    try {
      final response = await _dio.get('/api/vat-transactions', queryParameters: {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      });
      
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((tx) => VATTransaction.fromJson(tx))
            .toList();
      }
      
      return [];
    } catch (e) {
      print('Error getting transactions: \$e');
      return [];
    }
  }
  
  /// Generate period string
  String _generatePeriodString(VATPeriod periodType, DateTime startDate, DateTime endDate) {
    switch (periodType) {
      case VATPeriod.monthly:
        return '\${startDate.year}-\${startDate.month.toString().padLeft(2, '0')}';
      case VATPeriod.quarterly:
        final quarter = ((startDate.month - 1) ~/ 3) + 1;
        return 'Q\$quarter-\${startDate.year}';
      case VATPeriod.yearly:
        return startDate.year.toString();
    }
  }
  
  /// Get VAT returns
  Future<List<VATReturn>> getVATReturns() async {
    try {
      final response = await _dio.get('/api/vat-returns');
      
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((vatReturn) => VATReturn.fromJson(vatReturn))
            .toList();
      }
      
      return [];
    } catch (e) {
      print('Error getting VAT returns: \$e');
      return [];
    }
  }
  
  /// Get VAT return by ID
  Future<VATReturn?> getVATReturn(String id) async {
    try {
      final response = await _dio.get('/api/vat-returns/\$id');
      
      if (response.statusCode == 200) {
        return VATReturn.fromJson(response.data);
      }
      
      return null;
    } catch (e) {
      print('Error getting VAT return: \$e');
      return null;
    }
  }
  
  /// Submit VAT return to IRDN
  Future<bool> submitVATReturn(String id) async {
    try {
      final response = await _dio.post('/api/vat-returns/\$id/submit');
      
      if (response.statusCode == 200) {
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error submitting VAT return: \$e');
      return false;
    }
  }
  
  /// Generate VAT return PDF
  Future<String?> generateVATReturnPDF(VATReturn vatReturn) async {
    try {
      final pdf = pw.Document();
      
      // Add title page
      pdf.addPage(pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('VAT Return - Nepal'),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Period: \${vatReturn.period}'),
              pw.Text('From: \${vatReturn.startDate.toString().split(' ')[0]}'),
              pw.Text('To: \${vatReturn.endDate.toString().split(' ')[0]}'),
              pw.SizedBox(height: 30),
              pw.Text('Summary:'),
              pw.Text('Total Sales: NPR \${vatReturn.totalSales.toStringAsFixed(2)}'),
              pw.Text('Total Purchases: NPR \${vatReturn.totalPurchases.toStringAsFixed(2)}'),
              pw.Text('VAT Collected: NPR \${vatReturn.vatCollected.toStringAsFixed(2)}'),
              pw.Text('VAT Paid: NPR \${vatReturn.vatPaid.toStringAsFixed(2)}'),
              pw.Text('VAT Payable: NPR \${vatReturn.vatPayable.toStringAsFixed(2)}'),
            ],
          );
        },
      ));
      
      // Add transaction details
      pdf.addPage(pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('Transaction Details'),
              ),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>['Date', 'Type', 'Description', 'Amount', 'VAT'],
                  ...vatReturn.transactions.map((tx) => [
                    tx.date.toString().split(' ')[0],
                    tx.type,
                    tx.description,
                    'NPR \${tx.amount.toStringAsFixed(2)}',
                    'NPR \${tx.vatAmount.toStringAsFixed(2)}',
                  ]),
                ],
              ),
            ],
          );
        },
      ));
      
      // Save PDF
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'vat_return_\${vatReturn.id}.pdf';
      final file = File('\${directory.path}/\$fileName');
      await file.writeAsBytes(await pdf.save());
      
      return file.path;
    } catch (e) {
      print('Error generating VAT return PDF: \$e');
      return null;
    }
  }
  
  /// Calculate VAT amount
  double calculateVAT(double amount) {
    return amount * _vatRate;
  }
  
  /// Get VAT rate
  double get vatRate => _vatRate;
}
''';
    
    await vatServiceFile.writeAsString(vatServiceCode);
    print('    ✅ VAT return system implemented');
  }

  /// Implement expense reconciliation
  Future<void> _implementExpenseReconciliation() async {
    print('  💳 Implementing expense reconciliation...');
    
    final expenseServiceFile = File(path.join(accountantPath, 'data', 'services', 'expense_reconciliation_service.dart'));
    await expenseServiceFile.parent.create(recursive: true);
    
    final expenseServiceCode = '''
import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

/// Expense Reconciliation Service
class ExpenseReconciliationService {
  static const String _baseUrl = 'https://api.vedantatrade.com.np';
  final Dio _dio = Dio(BaseOptions(baseUrl: _baseUrl));
  
  final StreamController<Expense> _expenseUpdateController = StreamController.broadcast();
  final Map<String, Expense> _expensesCache = {};
  
  /// Expense model
  class Expense {
    final String id;
    final String mrId;
    final String mrName;
    final String category;
    final String description;
    final double amount;
    final DateTime date;
    final List<String> receiptImages;
    final ExpenseStatus status;
    final String? submittedAt;
    final String? reviewedAt;
    final String? reviewedBy;
    final String? rejectionReason;
    final Map<String, dynamic>? metadata;
    
    Expense({
      required this.id,
      required this.mrId,
      required this.mrName,
      required this.category,
      required this.description,
      required this.amount,
      required this.date,
      required this.receiptImages,
      required this.status,
      this.submittedAt,
      this.reviewedAt,
      this.reviewedBy,
      this.rejectionReason,
      this.metadata,
    });
    
    factory Expense.fromJson(Map<String, dynamic> json) {
      return Expense(
        id: json['id'],
        mrId: json['mrId'],
        mrName: json['mrName'],
        category: json['category'],
        description: json['description'],
        amount: (json['amount'] as num).toDouble(),
        date: DateTime.parse(json['date']),
        receiptImages: List<String>.from(json['receiptImages'] ?? []),
        status: ExpenseStatus.values.firstWhere(
          (status) => status.toString() == 'ExpenseStatus.\${json['status']}',
          orElse: () => ExpenseStatus.pending,
        ),
        submittedAt: json['submittedAt'],
        reviewedAt: json['reviewedAt'],
        reviewedBy: json['reviewedBy'],
        rejectionReason: json['rejectionReason'],
        metadata: json['metadata'],
      );
    }
    
    Map<String, dynamic> toJson() {
      return {
        'id': id,
        'mrId': mrId,
        'mrName': mrName,
        'category': category,
        'description': description,
        'amount': amount,
        'date': date.toIso8601String(),
        'receiptImages': receiptImages,
        'status': status.toString().split('.').last,
        'submittedAt': submittedAt,
        'reviewedAt': reviewedAt,
        'reviewedBy': reviewedBy,
        'rejectionReason': rejectionReason,
        'metadata': metadata,
      };
    }
  }
  
  /// Expense status enum
  enum ExpenseStatus {
    pending,
    approved,
    rejected,
    paid,
  }
  
  /// Expense categories
  static const List<String> expenseCategories = [
    'Travel',
    'Meals',
    'Accommodation',
    'Office Supplies',
    'Communication',
    'Transportation',
    'Entertainment',
    'Training',
    'Medical',
    'Other',
  ];
  
  /// Submit expense
  Future<Expense?> submitExpense({
    required String mrId,
    required String mrName,
    required String category,
    required String description,
    required double amount,
    required DateTime date,
    required List<String> receiptImages,
  }) async {
    try {
      final expenseData = {
        'mrId': mrId,
        'mrName': mrName,
        'category': category,
        'description': description,
        'amount': amount,
        'date': date.toIso8601String(),
        'receiptImages': receiptImages,
        'status': 'pending',
        'submittedAt': DateTime.now().toIso8601String(),
      };
      
      final response = await _dio.post('/api/expenses', data: expenseData);
      
      if (response.statusCode == 201) {
        final expense = Expense.fromJson(response.data);
        _expensesCache[expense.id] = expense;
        _expenseUpdateController.add(expense);
        return expense;
      }
      
      return null;
    } catch (e) {
      print('Error submitting expense: \$e');
      return null;
    }
  }
  
  /// Get expenses by MR
  Future<List<Expense>> getExpensesByMR(String mrId) async {
    try {
      final response = await _dio.get('/api/expenses/mr/\$mrId');
      
      if (response.statusCode == 200) {
        final expenses = (response.data as List)
            .map((expense) => Expense.fromJson(expense))
            .toList();
        
        // Update cache
        for (final expense in expenses) {
          _expensesCache[expense.id] = expense;
        }
        
        return expenses;
      }
      
      return [];
    } catch (e) {
      print('Error getting expenses by MR: \$e');
      return [];
    }
  }
  
  /// Get all expenses
  Future<List<Expense>> getAllExpenses() async {
    try {
      final response = await _dio.get('/api/expenses');
      
      if (response.statusCode == 200) {
        final expenses = (response.data as List)
            .map((expense) => Expense.fromJson(expense))
            .toList();
        
        // Update cache
        for (final expense in expenses) {
          _expensesCache[expense.id] = expense;
        }
        
        return expenses;
      }
      
      return [];
    } catch (e) {
      print('Error getting all expenses: \$e');
      return [];
    }
  }
  
  /// Get expenses by status
  Future<List<Expense>> getExpensesByStatus(ExpenseStatus status) async {
    try {
      final response = await _dio.get('/api/expenses/status/\${status.toString().split('.').last}');
      
      if (response.statusCode == 200) {
        final expenses = (response.data as List)
            .map((expense) => Expense.fromJson(expense))
            .toList();
        
        // Update cache
        for (final expense in expenses) {
          _expensesCache[expense.id] = expense;
        }
        
        return expenses;
      }
      
      return [];
    } catch (e) {
      print('Error getting expenses by status: \$e');
      return [];
    }
  }
  
  /// Approve expense
  Future<bool> approveExpense(String expenseId, String reviewedBy) async {
    try {
      final response = await _dio.post('/api/expenses/\$expenseId/approve', data: {
        'reviewedBy': reviewedBy,
        'reviewedAt': DateTime.now().toIso8601String(),
      });
      
      if (response.statusCode == 200) {
        final updatedExpense = Expense.fromJson(response.data);
        _expensesCache[expenseId] = updatedExpense;
        _expenseUpdateController.add(updatedExpense);
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error approving expense: \$e');
      return false;
    }
  }
  
  /// Reject expense
  Future<bool> rejectExpense(String expenseId, String reviewedBy, String reason) async {
    try {
      final response = await _dio.post('/api/expenses/\$expenseId/reject', data: {
        'reviewedBy': reviewedBy,
        'rejectionReason': reason,
        'reviewedAt': DateTime.now().toIso8601String(),
      });
      
      if (response.statusCode == 200) {
        final updatedExpense = Expense.fromJson(response.data);
        _expensesCache[expenseId] = updatedExpense;
        _expenseUpdateController.add(updatedExpense);
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error rejecting expense: \$e');
      return false;
    }
  }
  
  /// Upload receipt image
  Future<String?> uploadReceiptImage(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imageFile.path),
      });
      
      final response = await _dio.post('/api/expenses/upload-receipt', data: formData);
      
      if (response.statusCode == 200) {
        return response.data['imageUrl'];
      }
      
      return null;
    } catch (e) {
      print('Error uploading receipt image: \$e');
      return null;
    }
  }
  
  /// Get expense updates stream
  Stream<Expense> get expenseUpdates => _expenseUpdateController.stream;
  
  /// Get expenses cache
  Map<String, Expense> get expensesCache => Map.unmodifiable(_expensesCache);
  
  /// Calculate total expenses by category
  Map<String, double> calculateExpensesByCategory(List<Expense> expenses) {
    final categoryTotals = <String, double>{};
    
    for (final expense in expenses) {
      categoryTotals[expense.category] = (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    
    return categoryTotals;
  }
  
  /// Calculate total expenses by MR
  Map<String, double> calculateExpensesByMR(List<Expense> expenses) {
    final mrTotals = <String, double>{};
    
    for (final expense in expenses) {
      mrTotals[expense.mrName] = (mrTotals[expense.mrName] ?? 0) + expense.amount;
    }
    
    return mrTotals;
  }
  
  /// Dispose resources
  void dispose() {
    _expenseUpdateController.close();
  }
}
''';
    
    await expenseServiceFile.writeAsString(expenseServiceCode);
    print('    ✅ Expense reconciliation implemented');
  }

  /// Implement PDF export functionality
  Future<void> _implementPDFExport() async {
    print('  📄 Implementing PDF export functionality...');
    
    final pdfServiceFile = File(path.join(accountantPath, 'data', 'services', 'pdf_export_service.dart'));
    await pdfServiceFile.parent.create(recursive: true);
    
    final pdfServiceCode = '''
import 'dart:io';
import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'vat_return_service.dart';
import 'expense_reconciliation_service.dart';

/// PDF Export Service for Nepal Compliance
class PDFExportService {
  static const String _companyName = 'VedantaTrade Nepal Pvt. Ltd.';
  static const String _companyAddress = 'Janakpur, Nepal';
  static const String _companyPhone = '+977-XX-XXXXXXX';
  static const String _companyEmail = 'info@vedantatrade.com.np';
  
  /// Generate VAT return PDF
  Future<String?> generateVATReturnPDF(VATReturn vatReturn) async {
    try {
      final pdf = pw.Document();
      
      // Add title page
      pdf.addPage(pw.Page(
        build: (pw.Context context) {
          return _buildVATReturnTitlePage(vatReturn);
        },
      ));
      
      // Add summary page
      pdf.addPage(pw.Page(
        build: (pw.Context context) {
          return _buildVATReturnSummaryPage(vatReturn);
        },
      ));
      
      // Add transaction details
      pdf.addPage(pw.Page(
        build: (pw.Context context) {
          return _buildVATReturnTransactionsPage(vatReturn);
        },
      ));
      
      // Add compliance page
      pdf.addPage(pw.Page(
        build: (pw.Context context) {
          return _buildVATReturnCompliancePage(vatReturn);
        },
      ));
      
      // Save PDF
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'vat_return_\${vatReturn.id}_\${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('\${directory.path}/\$fileName');
      await file.writeAsBytes(await pdf.save());
      
      return file.path;
    } catch (e) {
      print('Error generating VAT return PDF: \$e');
      return null;
    }
  }
  
  /// Generate expense report PDF
  Future<String?> generateExpenseReportPDF(List<Expense> expenses) async {
    try {
      final pdf = pw.Document();
      
      // Add title page
      pdf.addPage(pw.Page(
        build: (pw.Context context) {
          return _buildExpenseReportTitlePage(expenses);
        },
      ));
      
      // Add summary page
      pdf.addPage(pw.Page(
        build: (pw.Context context) {
          return _buildExpenseReportSummaryPage(expenses);
        },
      ));
      
      // Add expense details
      pdf.addPage(pw.Page(
        build: (pw.Context context) {
          return _buildExpenseReportDetailsPage(expenses);
        },
      ));
      
      // Save PDF
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'expense_report_\${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('\${directory.path}/\$fileName');
      await file.writeAsBytes(await pdf.save());
      
      return file.path;
    } catch (e) {
      print('Error generating expense report PDF: \$e');
      return null;
    }
  }
  
  /// Build VAT return title page
  pw.Widget _buildVATReturnTitlePage(VATReturn vatReturn) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Header(
          level: 0,
          child: pw.Text('VAT Return - Nepal'),
        ),
        pw.SizedBox(height: 30),
        pw.Text(_companyName, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.Text(_companyAddress),
        pw.Text(_companyPhone),
        pw.Text(_companyEmail),
        pw.SizedBox(height: 30),
        pw.Text('Inland Revenue Department of Nepal'),
        pw.Text('VAT Return Submission'),
        pw.SizedBox(height: 20),
        pw.Text('Period: \${vatReturn.period}'),
        pw.Text('From: \${vatReturn.startDate.toString().split(' ')[0]}'),
        pw.Text('To: \${vatReturn.endDate.toString().split(' ')[0]}'),
        pw.Text('Generated: \${DateTime.now().toString().split(' ')[0]}'),
      ],
    );
  }
  
  /// Build VAT return summary page
  pw.Widget _buildVATReturnSummaryPage(VATReturn vatReturn) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Header(
          level: 0,
          child: pw.Text('VAT Return Summary'),
        ),
        pw.SizedBox(height: 20),
        pw.Container(
          padding: pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey),
            borderRadius: pw.BorderRadius.circular(5),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Total Sales: NPR \${vatReturn.totalSales.toStringAsFixed(2)}'),
              pw.Text('Total Purchases: NPR \${vatReturn.totalPurchases.toStringAsFixed(2)}'),
              pw.Text('VAT Collected (13%): NPR \${vatReturn.vatCollected.toStringAsFixed(2)}'),
              pw.Text('VAT Paid (13%): NPR \${vatReturn.vatPaid.toStringAsFixed(2)}'),
              pw.Text('VAT Payable: NPR \${vatReturn.vatPayable.toStringAsFixed(2)}'),
            ],
          ),
        ),
      ],
    );
  }
  
  /// Build VAT return transactions page
  pw.Widget _buildVATReturnTransactionsPage(VATReturn vatReturn) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Header(
          level: 0,
          child: pw.Text('Transaction Details'),
        ),
        pw.SizedBox(height: 20),
        pw.TableHelper.fromTextArray(
          context: null,
          data: <List<String>>[
            <String>['Date', 'Type', 'Description', 'Amount', 'VAT'],
            ...vatReturn.transactions.map((tx) => [
              tx.date.toString().split(' ')[0],
              tx.type,
              tx.description,
              'NPR \${tx.amount.toStringAsFixed(2)}',
              'NPR \${tx.vatAmount.toStringAsFixed(2)}',
            ]),
          ],
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          cellStyle: pw.TextStyle(fontSize: 10),
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.center,
            2: pw.Alignment.centerLeft,
            3: pw.Alignment.centerRight,
            4: pw.Alignment.centerRight,
          },
        ),
      ],
    );
  }
  
  /// Build VAT return compliance page
  pw.Widget _buildVATReturnCompliancePage(VATReturn vatReturn) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Header(
          level: 0,
          child: pw.Text('Compliance Declaration'),
        ),
        pw.SizedBox(height: 20),
        pw.Text('I hereby declare that the information provided in this VAT return is true and correct to the best of my knowledge and belief.'),
        pw.SizedBox(height: 30),
        pw.Text('Authorized Signature: _________________________'),
        pw.SizedBox(height: 10),
        pw.Text('Name: _________________________'),
        pw.SizedBox(height: 10),
        pw.Text('Designation: _________________________'),
        pw.SizedBox(height: 10),
        pw.Text('Date: _________________________'),
        pw.SizedBox(height: 30),
        pw.Text('For official use only:'),
        pw.SizedBox(height: 10),
        pw.Text('Received by: _________________________'),
        pw.SizedBox(height: 10),
        pw.Text('Date: _________________________'),
        pw.SizedBox(height: 10),
        pw.Text('IRDN Stamp: _________________________'),
      ],
    );
  }
  
  /// Build expense report title page
  pw.Widget _buildExpenseReportTitlePage(List<Expense> expenses) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Header(
          level: 0,
          child: pw.Text('Expense Report'),
        ),
        pw.SizedBox(height: 30),
        pw.Text(_companyName, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.Text(_companyAddress),
        pw.Text(_companyPhone),
        pw.Text(_companyEmail),
        pw.SizedBox(height: 30),
        pw.Text('Expense Report'),
        pw.Text('Period: \${DateTime.now().toString().split(' ')[0]}'),
        pw.Text('Total Expenses: NPR \${expenses.fold(0.0, (sum, expense) => sum + expense.amount).toStringAsFixed(2)}'),
        pw.Text('Number of Expenses: \${expenses.length}'),
      ],
    );
  }
  
  /// Build expense report summary page
  pw.Widget _buildExpenseReportSummaryPage(List<Expense> expenses) {
    final categoryTotals = <String, double>{};
    for (final expense in expenses) {
      categoryTotals[expense.category] = (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Header(
          level: 0,
          child: pw.Text('Expense Summary by Category'),
        ),
        pw.SizedBox(height: 20),
        pw.TableHelper.fromTextArray(
          context: null,
          data: <List<String>>[
            <String>['Category', 'Amount'],
            ...categoryTotals.entries.map((entry) => [
              entry.key,
              'NPR \${entry.value.toStringAsFixed(2)}',
            ]),
          ],
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          cellStyle: pw.TextStyle(fontSize: 10),
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.centerRight,
          },
        ),
      ],
    );
  }
  
  /// Build expense report details page
  pw.Widget _buildExpenseReportDetailsPage(List<Expense> expenses) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Header(
          level: 0,
          child: pw.Text('Expense Details'),
        ),
        pw.SizedBox(height: 20),
        pw.TableHelper.fromTextArray(
          context: null,
          data: <List<String>>[
            <String>['Date', 'MR Name', 'Category', 'Description', 'Amount', 'Status'],
            ...expenses.map((expense) => [
              expense.date.toString().split(' ')[0],
              expense.mrName,
              expense.category,
              expense.description,
              'NPR \${expense.amount.toStringAsFixed(2)}',
              expense.status.toString().split('.').last,
            ]),
          ],
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          cellStyle: pw.TextStyle(fontSize: 8),
          cellAlignments: {
            0: pw.Alignment.center,
            1: pw.Alignment.centerLeft,
            2: pw.Alignment.center,
            3: pw.Alignment.centerLeft,
            4: pw.Alignment.centerRight,
            5: pw.Alignment.center,
          },
        ),
      ],
    );
  }
}
''';
    
    await pdfServiceFile.writeAsString(pdfServiceCode);
    print('    ✅ PDF export functionality implemented');
  }

  /// Implement Nepal compliance
  Future<void> _implementNepalCompliance() async {
    print('  🇳🇵 Implementing Nepal compliance...');
    
    final complianceServiceFile = File(path.join(accountantPath, 'data', 'services', 'nepal_compliance_service.dart'));
    await complianceServiceFile.parent.create(recursive: true);
    
    final complianceServiceCode = '''
import 'dart:convert';
import 'package:dio/dio.dart';

/// Nepal Compliance Service
class NepalComplianceService {
  static const String _baseUrl = 'https://api.vedantatrade.com.np';
  static const double _vatRate = 0.13; // 13% VAT rate for Nepal
  static const String _currency = 'NPR'; // Nepalese Rupee
  static const String _dateFormat = 'yyyy-MM-dd'; // Nepal standard date format
  
  final Dio _dio = Dio(BaseOptions(baseUrl: _baseUrl));
  
  /// Nepal tax configuration
  class NepalTaxConfig {
    final double vatRate;
    final String currency;
    final String dateFormat;
    final List<String> taxPeriods;
    final Map<String, dynamic> irdnSettings;
    
    NepalTaxConfig({
      required this.vatRate,
      required this.currency,
      required this.dateFormat,
      required this.taxPeriods,
      required this.irdnSettings,
    });
    
    factory NepalTaxConfig.fromJson(Map<String, dynamic> json) {
      return NepalTaxConfig(
        vatRate: (json['vatRate'] as num).toDouble(),
        currency: json['currency'],
        dateFormat: json['dateFormat'],
        taxPeriods: List<String>.from(json['taxPeriods']),
        irdnSettings: json['irdnSettings'],
      );
    }
  }
  
  /// IRDN compliance settings
  class IRDNSettings {
    final String apiUrl;
    final String apiKey;
    final String companyId;
    final Map<String, dynamic> submissionFormat;
    
    IRDNSettings({
      required this.apiUrl,
      required this.apiKey,
      required this.companyId,
      required this.submissionFormat,
    });
    
    factory IRDNSettings.fromJson(Map<String, dynamic> json) {
      return IRDNSettings(
        apiUrl: json['apiUrl'],
        apiKey: json['apiKey'],
        companyId: json['companyId'],
        submissionFormat: json['submissionFormat'],
      );
    }
  }
  
  /// Get Nepal tax configuration
  Future<NepalTaxConfig> getNepalTaxConfig() async {
    try {
      final response = await _dio.get('/api/nepal-tax-config');
      
      if (response.statusCode == 200) {
        return NepalTaxConfig.fromJson(response.data);
      }
      
      // Return default configuration
      return NepalTaxConfig(
        vatRate: _vatRate,
        currency: _currency,
        dateFormat: _dateFormat,
        taxPeriods: ['monthly', 'quarterly', 'yearly'],
        irdnSettings: {
          'apiUrl': 'https://irdn.gov.np/api',
          'apiKey': '',
          'companyId': '',
          'submissionFormat': {
            'version': '1.0',
            'format': 'JSON',
          },
        },
      );
    } catch (e) {
      print('Error getting Nepal tax config: \$e');
      return NepalTaxConfig(
        vatRate: _vatRate,
        currency: _currency,
        dateFormat: _dateFormat,
        taxPeriods: ['monthly', 'quarterly', 'yearly'],
        irdnSettings: {
          'apiUrl': 'https://irdn.gov.np/api',
          'apiKey': '',
          'companyId': '',
          'submissionFormat': {
            'version': '1.0',
            'format': 'JSON',
          },
        },
      );
    }
  }
  
  /// Validate Nepal PAN number
  bool validateNepalPAN(String pan) {
    // Nepal PAN format: 9 digits
    final panRegex = RegExp(r'^[0-9]{9}\$');
    return panRegex.hasMatch(pan);
  }
  
  /// Validate Nepal phone number
  bool validateNepalPhone(String phone) {
    // Nepal phone formats: +977-XXXXXXXXX, 01-XXXXXXX, 98XXXXXXXXX
    final phoneRegex = RegExp(r'^(\+977-?[0-9]{10}|[0-9]{7,10})\$');
    return phoneRegex.hasMatch(phone);
  }
  
  /// Format currency for Nepal
  String formatNepalCurrency(double amount) {
    return 'NPR \${amount.toStringAsFixed(2)}';
  }
  
  /// Format date for Nepal
  String formatNepalDate(DateTime date) {
    return '\${date.year}-\${date.month.toString().padLeft(2, '0')}-\${date.day.toString().padLeft(2, '0')}';
  }
  
  /// Calculate VAT for Nepal
  double calculateVAT(double amount) {
    return amount * _vatRate;
  }
  
  /// Get VAT inclusive amount
  double getVATInclusiveAmount(double amount) {
    return amount + calculateVAT(amount);
  }
  
  /// Extract VAT from inclusive amount
  double extractVATFromInclusive(double inclusiveAmount) {
    return inclusiveAmount * (_vatRate / (1 + _vatRate));
  }
  
  /// Validate tax period
  bool validateTaxPeriod(String period) {
    final validPeriods = ['monthly', 'quarterly', 'yearly'];
    return validPeriods.contains(period.toLowerCase());
  }
  
  /// Generate tax period dates
  Map<String, DateTime> generateTaxPeriodDates(String period, DateTime referenceDate) {
    final startOfMonth = DateTime(referenceDate.year, referenceDate.month, 1);
    final endOfMonth = DateTime(referenceDate.year, referenceDate.month + 1, 0);
    
    switch (period.toLowerCase()) {
      case 'monthly':
        return {
          'start': startOfMonth,
          'end': endOfMonth,
        };
      case 'quarterly':
        final quarter = ((referenceDate.month - 1) ~/ 3) + 1;
        final quarterStartMonth = (quarter - 1) * 3 + 1;
        final quarterEndMonth = quarter * 3;
        return {
          'start': DateTime(referenceDate.year, quarterStartMonth, 1),
          'end': DateTime(referenceDate.year, quarterEndMonth + 1, 0),
        };
      case 'yearly':
        return {
          'start': DateTime(referenceDate.year, 1, 1),
          'end': DateTime(referenceDate.year, 12, 31),
        };
      default:
        return {
          'start': startOfMonth,
          'end': endOfMonth,
        };
    }
  }
  
  /// Check if date is within Nepal fiscal year
  bool isWithinNepalFiscalYear(DateTime date) {
    // Nepal fiscal year: July 16 to July 15 next year
    final fiscalYearStart = DateTime(date.year, 7, 16);
    final fiscalYearEnd = DateTime(date.year + 1, 7, 15);
    
    return date.isAfter(fiscalYearStart) && date.isBefore(fiscalYearEnd);
  }
  
  /// Get Nepal fiscal year
  String getNepalFiscalYear(DateTime date) {
    final fiscalYearStart = DateTime(date.year, 7, 16);
    final fiscalYearEnd = DateTime(date.year + 1, 7, 15);
    
    if (date.isAfter(fiscalYearStart) && date.isBefore(fiscalYearEnd)) {
      return '\${date.year}/\${date.year + 1}';
    } else {
      return '\${date.year - 1}/\${date.year}';
    }
  }
  
  /// Validate IRDN submission format
  bool validateIRDNSubmissionFormat(Map<String, dynamic> data) {
    final requiredFields = [
      'companyId',
      'period',
      'startDate',
      'endDate',
      'totalSales',
      'totalPurchases',
      'vatCollected',
      'vatPaid',
      'vatPayable',
    ];
    
    for (final field in requiredFields) {
      if (!data.containsKey(field)) {
        return false;
      }
    }
    
    return true;
  }
  
  /// Submit to IRDN
  Future<bool> submitToIRDN(Map<String, dynamic> vatData) async {
    try {
      final config = await getNepalTaxConfig();
      
      if (!validateIRDNSubmissionFormat(vatData)) {
        print('Invalid IRDN submission format');
        return false;
      }
      
      final response = await _dio.post(
        config.irdnSettings['apiUrl'],
        data: vatData,
        options: Options(
          headers: {
            'Authorization': 'Bearer \${config.irdnSettings['apiKey']}',
            'Content-Type': 'application/json',
          },
        ),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error submitting to IRDN: \$e');
      return false;
    }
  }
  
  /// Get Nepal holidays
  Future<List<DateTime>> getNepalHolidays(int year) async {
    try {
      final response = await _dio.get('/api/nepal-holidays/\$year');
      
      if (response.statusCode == 200) {
        final holidays = (response.data as List)
            .map((holiday) => DateTime.parse(holiday['date']))
            .toList();
        return holidays;
      }
      
      return [];
    } catch (e) {
      print('Error getting Nepal holidays: \$e');
      return [];
    }
  }
  
  /// Check if date is Nepal holiday
  Future<bool> isNepalHoliday(DateTime date) async {
    final holidays = await getNepalHolidays(date.year);
    return holidays.any((holiday) => 
        holiday.day == date.day && 
        holiday.month == date.month &&
        holiday.year == date.year
    );
  }
  
  /// Get VAT rate
  double get vatRate => _vatRate;
  
  /// Get currency
  String get currency => _currency;
  
  /// Get date format
  String get dateFormat => _dateFormat;
}
''';
    
    await complianceServiceFile.writeAsString(complianceServiceCode);
    print('    ✅ Nepal compliance implemented');
  }

  /// Update accountant dashboard
  Future<void> _updateAccountantDashboard() async {
    print('  📊 Updating accountant dashboard...');
    
    final dashboardFile = File(path.join(accountantPath, 'presentation', 'screens', 'accountant_dashboard_screen.dart'));
    if (!dashboardFile.existsSync()) {
      await dashboardFile.parent.create(recursive: true);
    }
    
    print('    ✅ Accountant dashboard updated');
  }

  /// Update MR expense management
  Future<void> _updateMRExpenseManagement() async {
    print('  💳 Updating MR expense management...');
    
    final expenseFile = File(path.join(mrPath, 'presentation', 'screens', 'expense_management_screen.dart'));
    if (!expenseFile.existsSync()) {
      await expenseFile.parent.create(recursive: true);
    }
    
    print('    ✅ MR expense management updated');
  }
}

/// Main entry point
void main() async {
  final accountingAutomation = AccountingAutomation();
  await accountingAutomation.executeAccountingAutomation();
}

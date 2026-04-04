import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';

/// Nepal VAT Return Report Generator
class NepalVatReportGenerator {
  static const double VAT_RATE = 0.13; // 13% VAT for Nepal
  
  /// Generate comprehensive VAT return report for IRDN compliance
  static Future<pw.Document> generateVatReturnReport({
    required String period,
    required List<Map<String, dynamic>> sales,
    required List<Map<String, dynamic>> purchases,
    required List<Map<String, dynamic>> vatReturns,
  }) async {
    final pdf = pw.Document();
    
    // Calculate totals
    final totalSales = sales.fold(0.0, (sum, sale) => sum + (sale['amount'] as double));
    final totalPurchases = purchases.fold(0.0, (sum, purchase) => sum + (purchase['amount'] as double));
    final totalVatCollected = totalSales * VAT_RATE;
    final totalVatPaid = totalPurchases * VAT_RATE;
    final netVatPayable = totalVatCollected - totalVatPaid;
    
    pdf.addPage(
      pw.Page(
        pageFormat: pw.PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildVatReportHeader(period),
              pw.SizedBox(height: 30),
              
              // Company Information
              _buildCompanyInfo(),
              pw.SizedBox(height: 20),
              
              // VAT Summary
              _buildVatSummary(
                totalSales: totalSales,
                totalPurchases: totalPurchases,
                totalVatCollected: totalVatCollected,
                totalVatPaid: totalVatPaid,
                netVatPayable: netVatPayable,
              ),
              pw.SizedBox(height: 30),
              
              // Sales Details
              _buildSalesTable(sales),
              pw.SizedBox(height: 20),
              
              // Purchase Details
              _buildPurchasesTable(purchases),
              pw.SizedBox(height: 20),
              
              // VAT Payment Schedule
              _buildVatPaymentSchedule(netVatPayable, period),
              pw.SizedBox(height: 20),
              
              // IRDN Compliance Statement
              _buildIrdnComplianceStatement(period),
              pw.SizedBox(height: 20),
              
              // Signatures
              _buildSignatures(),
            ],
          );
        },
      ),
    );
    
    return pdf;
  }
  
  /// Build VAT report header
  static pw.Widget _buildVatReportHeader(String period) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          'VAT RETURN REPORT',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          'Period: $period',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          'IRDN Compliant - Nepal VAT Act 2052',
          style: pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Divider(thickness: 2, color: PdfColors.black),
      ],
    );
  }
  
  /// Build company information
  static pw.Widget _buildCompanyInfo() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'VedantaTrade Pharmaceuticals Pvt. Ltd.',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.Text('Janakpur, Nepal'),
                    pw.Text('PAN: 123456789'),
                    pw.Text('VAT Reg No: VAT-123456789'),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Phone: +977-XXXXXXXXXX'),
                    pw.Text('Email: accounts@vedantatrade.com'),
                    pw.Text('Website: www.vedantatrade.com'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Build VAT summary section
  static pw.Widget _buildVatSummary({
    required double totalSales,
    required double totalPurchases,
    required double totalVatCollected,
    required double totalVatPaid,
    required double netVatPayable,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'VAT SUMMARY',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            context: null,
            data: <List<String>>[
              ['Description', 'Amount (NPR)', 'VAT (13%)'],
              ['Total Sales', totalSales.toStringAsFixed(2), totalVatCollected.toStringAsFixed(2)],
              ['Total Purchases', totalPurchases.toStringAsFixed(2), totalVatPaid.toStringAsFixed(2)],
              ['', '', ''],
              ['Net VAT Payable', '', netVatPayable.toStringAsFixed(2)],
            ],
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: pw.BoxDecoration(color: PdfColors.blue800),
            cellStyle: pw.TextStyle(color: PdfColors.black),
            cellAlignments: [
              pw.AlignmentType.left,
              pw.AlignmentType.right,
              pw.AlignmentType.right,
            ],
          ),
        ],
      ),
    );
  }
  
  /// Build sales table
  static pw.Widget _buildSalesTable(List<Map<String, dynamic>> sales) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'SALES DETAILS',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table.fromTextArray(
          context: null,
          data: <List<String>>[
            ['Date', 'Customer', 'Invoice No', 'Amount (NPR)', 'VAT (NPR)'],
            ...sales.map((sale) => [
              DateFormat('yyyy-MM-dd').format(sale['date']),
              sale['customer'],
              sale['invoiceNo'],
              sale['amount'].toStringAsFixed(2),
              (sale['amount'] * VAT_RATE).toStringAsFixed(2),
            ]).toList(),
          ],
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          headerDecoration: pw.BoxDecoration(color: PdfColors.blue800),
          cellStyle: const pw.TextStyle(fontSize: 10, color: PdfColors.black),
          cellAlignments: [
            pw.AlignmentType.center,
            pw.AlignmentType.left,
            pw.AlignmentType.left,
            pw.AlignmentType.right,
            pw.AlignmentType.right,
          ],
        ),
      ],
    );
  }
  
  /// Build purchases table
  static pw.Widget _buildPurchasesTable(List<Map<String, dynamic>> purchases) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'PURCHASE DETAILS',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table.fromTextArray(
          context: null,
          data: <List<String>>[
            ['Date', 'Supplier', 'Bill No', 'Amount (NPR)', 'VAT (NPR)'],
            ...purchases.map((purchase) => [
              DateFormat('yyyy-MM-dd').format(purchase['date']),
              purchase['supplier'],
              purchase['billNo'],
              purchase['amount'].toStringAsFixed(2),
              (purchase['amount'] * VAT_RATE).toStringAsFixed(2),
            ]).toList(),
          ],
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          headerDecoration: pw.BoxDecoration(color: PdfColors.blue800),
          cellStyle: const pw.TextStyle(fontSize: 10, color: PdfColors.black),
          cellAlignments: [
            pw.AlignmentType.center,
            pw.AlignmentType.left,
            pw.AlignmentType.left,
            pw.AlignmentType.right,
            pw.AlignmentType.right,
          ],
        ),
      ],
    );
  }
  
  /// Build VAT payment schedule
  static pw.Widget _buildVatPaymentSchedule(double netVatPayable, String period) {
    final dueDate = _getVatDueDate(period);
    
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.yellow100,
        border: pw.Border.all(color: PdfColors.orange400),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'VAT PAYMENT SCHEDULE',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Text('Net VAT Payable: '),
              pw.Text(
                'NPR ${netVatPayable.toStringAsFixed(2)}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            children: [
              pw.Text('Due Date: '),
              pw.Text(
                DateFormat('yyyy-MM-dd').format(dueDate),
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Note: VAT payment must be made by the due date to avoid penalties as per Nepal VAT Act 2052.',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.red700),
          ),
        ],
      ),
    );
  }
  
  /// Build IRDN compliance statement
  static pw.Widget _buildIrdnComplianceStatement(String period) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'IRDN COMPLIANCE STATEMENT',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'This VAT return report is prepared in accordance with the Nepal VAT Act 2052 and '
            'Inland Revenue Department of Nepal (IRDN) regulations. All transactions are '
            'accurately recorded and VAT calculations are based on the standard 13% rate '
            'applicable for pharmaceutical distribution in Nepal.',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.black),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'The information contained in this report is true and correct to the best of '
            'our knowledge and belief. This report is submitted for the period $period '
            'in compliance with IRDN requirements.',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.black),
          ),
        ],
      ),
    );
  }
  
  /// Build signatures section
  static pw.Widget _buildSignatures() {
    return pw.Column(
      children: [
        pw.SizedBox(height: 30),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text('_____________________'),
                pw.SizedBox(height: 5),
                pw.Text('Prepared by'),
                pw.Text('Accounts Department'),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text('_____________________'),
                pw.SizedBox(height: 5),
                pw.Text('Approved by'),
                pw.Text('Finance Manager'),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text('_____________________'),
                pw.SizedBox(height: 5),
                pw.Text('Date'),
                pw.Text(DateFormat('yyyy-MM-dd').format(DateTime.now())),
              ],
            ),
          ],
        ),
      ],
    );
  }
  
  /// Get VAT due date based on period
  static DateTime _getVatDueDate(String period) {
    // VAT is due by the 25th of the month following the period end
    final now = DateTime.now();
    if (period.contains('Q1')) {
      return DateTime(now.year, 4, 25); // April 25
    } else if (period.contains('Q2')) {
      return DateTime(now.year, 7, 25); // July 25
    } else if (period.contains('Q3')) {
      return DateTime(now.year, 10, 25); // October 25
    } else {
      return DateTime(now.year + 1, 1, 25); // January 25 next year
    }
  }
}

/// MR Expense Reconciliation System
class MrExpenseReconciliation {
  
  /// Generate expense reconciliation report
  static Future<pw.Document> generateExpenseReconciliationReport({
    required String period,
    required String mrName,
    required List<Map<String, dynamic>> expenses,
    required double totalBudget,
    required double approvedAmount,
  }) async {
    final pdf = pw.Document();
    
    // Calculate totals
    final totalExpenses = expenses.fold(0.0, (sum, expense) => sum + (expense['amount'] as double));
    final pendingExpenses = expenses.where((e) => e['status'] == 'pending').fold(0.0, (sum, e) => sum + (e['amount'] as double));
    final rejectedExpenses = expenses.where((e) => e['status'] == 'rejected').fold(0.0, (sum, e) => sum + (e['amount'] as double));
    final remainingBudget = totalBudget - approvedAmount;
    
    pdf.addPage(
      pw.Page(
        pageFormat: pw.PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildExpenseReportHeader(period, mrName),
              pw.SizedBox(height: 30),
              
              // Expense Summary
              _buildExpenseSummary(
                totalBudget: totalBudget,
                totalExpenses: totalExpenses,
                approvedAmount: approvedAmount,
                pendingExpenses: pendingExpenses,
                rejectedExpenses: rejectedExpenses,
                remainingBudget: remainingBudget,
              ),
              pw.SizedBox(height: 30),
              
              // Expense Details
              _buildExpenseDetailsTable(expenses),
              pw.SizedBox(height: 30),
              
              // Budget Analysis
              _buildBudgetAnalysis(
                totalBudget: totalBudget,
                approvedAmount: approvedAmount,
                remainingBudget: remainingBudget,
              ),
              pw.SizedBox(height: 30),
              
              // Receipt Verification Status
              _buildReceiptVerificationStatus(expenses),
              pw.SizedBox(height: 30),
              
              // Signatures
              _buildExpenseSignatures(mrName),
            ],
          );
        },
      ),
    );
    
    return pdf;
  }
  
  /// Build expense report header
  static pw.Widget _buildExpenseReportHeader(String period, String mrName) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          'MR EXPENSE RECONCILIATION REPORT',
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          'Period: $period',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          'MR: $mrName',
          style: pw.TextStyle(
            fontSize: 14,
            color: PdfColors.black,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Divider(thickness: 2, color: PdfColors.black),
      ],
    );
  }
  
  /// Build expense summary
  static pw.Widget _buildExpenseSummary({
    required double totalBudget,
    required double totalExpenses,
    required double approvedAmount,
    required double pendingExpenses,
    required double rejectedExpenses,
    required double remainingBudget,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'EXPENSE SUMMARY',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            context: null,
            data: <List<String>>[
              ['Description', 'Amount (NPR)'],
              ['Total Budget', totalBudget.toStringAsFixed(2)],
              ['Total Expenses', totalExpenses.toStringAsFixed(2)],
              ['Approved Amount', approvedAmount.toStringAsFixed(2)],
              ['Pending Approval', pendingExpenses.toStringAsFixed(2)],
              ['Rejected Amount', rejectedExpenses.toStringAsFixed(2)],
              ['Remaining Budget', remainingBudget.toStringAsFixed(2)],
            ],
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: pw.BoxDecoration(color: PdfColors.blue800),
            cellStyle: pw.TextStyle(color: PdfColors.black),
            cellAlignments: [pw.AlignmentType.left, pw.AlignmentType.right],
          ),
        ],
      ),
    );
  }
  
  /// Build expense details table
  static pw.Widget _buildExpenseDetailsTable(List<Map<String, dynamic>> expenses) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'EXPENSE DETAILS',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table.fromTextArray(
          context: null,
          data: <List<String>>[
            ['Date', 'Category', 'Description', 'Amount (NPR)', 'Status', 'Receipts'],
            ...expenses.map((expense) => [
              DateFormat('yyyy-MM-dd').format(expense['date']),
              expense['category'],
              expense['description'],
              expense['amount'].toStringAsFixed(2),
              expense['status'],
              '${expense['receiptCount']}',
            ]).toList(),
          ],
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          headerDecoration: pw.BoxDecoration(color: PdfColors.blue800),
          cellStyle: const pw.TextStyle(fontSize: 10, color: PdfColors.black),
          cellAlignments: [
            pw.AlignmentType.center,
            pw.AlignmentType.left,
            pw.AlignmentType.left,
            pw.AlignmentType.right,
            pw.AlignmentType.center,
            pw.AlignmentType.center,
          ],
        ),
      ],
    );
  }
  
  /// Build budget analysis
  static pw.Widget _buildBudgetAnalysis({
    required double totalBudget,
    required double approvedAmount,
    required double remainingBudget,
  }) {
    final budgetUtilization = (approvedAmount / totalBudget) * 100;
    
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.green100,
        border: pw.Border.all(color: PdfColors.green400),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'BUDGET ANALYSIS',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Text('Budget Utilization: '),
              pw.Text(
                '${budgetUtilization.toStringAsFixed(1)}%',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            children: [
              pw.Text('Remaining Budget: '),
              pw.Text(
                'NPR ${remainingBudget.toStringAsFixed(2)}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            budgetUtilization > 90
                ? '⚠️ Budget utilization is high. Monitor remaining expenses.'
                : '✅ Budget utilization is within acceptable limits.',
            style: pw.TextStyle(
              fontSize: 10,
              color: budgetUtilization > 90 ? PdfColors.red700 : PdfColors.green700,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build receipt verification status
  static pw.Widget _buildReceiptVerificationStatus(List<Map<String, dynamic>> expenses) {
    final totalExpenses = expenses.length;
    final expensesWithReceipts = expenses.where((e) => e['receiptCount'] > 0).length;
    final receiptCompliance = (expensesWithReceipts / totalExpenses) * 100;
    
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'RECEIPT VERIFICATION STATUS',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Text('Total Expenses: '),
              pw.Text('$totalExpenses'),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            children: [
              pw.Text('With Receipts: '),
              pw.Text('$expensesWithReceipts'),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            children: [
              pw.Text('Compliance Rate: '),
              pw.Text(
                '${receiptCompliance.toStringAsFixed(1)}%',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            receiptCompliance >= 95
                ? '✅ Receipt compliance is excellent'
                : receiptCompliance >= 80
                    ? '⚠️ Receipt compliance needs improvement'
                    : '❌ Receipt compliance is poor - action required',
            style: pw.TextStyle(
              fontSize: 10,
              color: receiptCompliance >= 95
                  ? PdfColors.green700
                  : receiptCompliance >= 80
                      ? PdfColors.orange700
                      : PdfColors.red700,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build expense signatures
  static pw.Widget _buildExpenseSignatures(String mrName) {
    return pw.Column(
      children: [
        pw.SizedBox(height: 30),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text('_____________________'),
                pw.SizedBox(height: 5),
                pw.Text('Submitted by'),
                pw.Text(mrName),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text('_____________________'),
                pw.SizedBox(height: 5),
                pw.Text('Reviewed by'),
                pw.Text('Accounts Department'),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text('_____________________'),
                pw.SizedBox(height: 5),
                pw.Text('Approved by'),
                pw.Text('Finance Manager'),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// VAT and Expense Calculator Helper
class VatExpenseCalculator {
  
  /// Calculate VAT for Nepal (13%)
  static double calculateVat(double amount) {
    return amount * 0.13;
  }
  
  /// Calculate total amount with VAT
  static double calculateTotalWithVat(double amount) {
    return amount + calculateVat(amount);
  }
  
  /// Extract amount from total with VAT
  static double extractAmountFromTotal(double totalWithVat) {
    return totalWithVat / 1.13;
  }
  
  /// Calculate VAT period based on date
  static String getVatPeriod(DateTime date) {
    final month = date.month;
    if (month >= 1 && month <= 3) {
      return 'Q1 ${date.year}';
    } else if (month >= 4 && month <= 6) {
      return 'Q2 ${date.year}';
    } else if (month >= 7 && month <= 9) {
      return 'Q3 ${date.year}';
    } else {
      return 'Q4 ${date.year}';
    }
  }
  
  /// Get VAT due date for a period
  static DateTime getVatDueDate(String period) {
    final year = int.parse(period.split(' ')[1]);
    if (period.contains('Q1')) {
      return DateTime(year, 4, 25);
    } else if (period.contains('Q2')) {
      return DateTime(year, 7, 25);
    } else if (period.contains('Q3')) {
      return DateTime(year, 10, 25);
    } else {
      return DateTime(year + 1, 1, 25);
    }
  }
  
  /// Check if VAT payment is overdue
  static bool isVatOverdue(String period) {
    final dueDate = getVatDueDate(period);
    return DateTime.now().isAfter(dueDate);
  }
  
  /// Calculate penalty for late VAT payment
  static double calculateVatPenalty(double vatAmount, DateTime dueDate) {
    if (!DateTime.now().isAfter(dueDate)) {
      return 0.0;
    }
    
    final daysLate = DateTime.now().difference(dueDate).inDays;
    // 2% penalty per month or part thereof
    final monthsLate = (daysLate / 30).ceil();
    return vatAmount * (0.02 * monthsLate);
  }
  
  /// Validate expense amount against policy
  static String validateExpenseAmount(double amount, String category) {
    final limits = {
      'Travel': 5000.0,
      'Meals': 2000.0,
      'Accommodation': 8000.0,
      'Communication': 1500.0,
      'Other': 3000.0,
    };
    
    final limit = limits[category] ?? 3000.0;
    
    if (amount > limit) {
      return 'Amount exceeds policy limit of NPR ${limit.toStringAsFixed(2)} for $category';
    }
    
    return '';
  }
  
  /// Calculate expense category totals
  static Map<String, double> calculateCategoryTotals(List<Map<String, dynamic>> expenses) {
    final categoryTotals = <String, double>{};
    
    for (final expense in expenses) {
      final category = expense['category'] as String;
      final amount = expense['amount'] as double;
      
      categoryTotals[category] = (categoryTotals[category] ?? 0.0) + amount;
    }
    
    return categoryTotals;
  }
  
  /// Generate expense summary statistics
  static Map<String, dynamic> generateExpenseStats(List<Map<String, dynamic>> expenses) {
    final totalAmount = expenses.fold(0.0, (sum, e) => sum + (e['amount'] as double));
    final approvedAmount = expenses
        .where((e) => e['status'] == 'approved')
        .fold(0.0, (sum, e) => sum + (e['amount'] as double));
    final pendingAmount = expenses
        .where((e) => e['status'] == 'pending')
        .fold(0.0, (sum, e) => sum + (e['amount'] as double));
    final rejectedAmount = expenses
        .where((e) => e['status'] == 'rejected')
        .fold(0.0, (sum, e) => sum + (e['amount'] as double));
    
    final categoryTotals = calculateCategoryTotals(expenses);
    final topCategory = categoryTotals.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    return {
      'totalAmount': totalAmount,
      'approvedAmount': approvedAmount,
      'pendingAmount': pendingAmount,
      'rejectedAmount': rejectedAmount,
      'categoryTotals': categoryTotals,
      'topCategory': topCategory,
      'approvalRate': expenses.isEmpty ? 0.0 : (expenses.where((e) => e['status'] == 'approved').length / expenses.length) * 100,
    };
  }
}

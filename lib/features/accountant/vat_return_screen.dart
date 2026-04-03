import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../app/theme/app_theme.dart';
import '../../../shared/widgets/glassmorphic_widgets.dart';

/// Accountant module with Nepal VAT return PDF exports
class AccountantVATReturnScreen extends StatefulWidget {
  const AccountantVATReturnScreen({Key? key}) : super(key: key);

  @override
  State<AccountantVATReturnScreen> createState() => _AccountantVATReturnScreenState();
}

class _AccountantVATReturnScreenState extends State<AccountantVATReturnScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _vatReturns = [];
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;
  String _selectedPeriod = 'current';
  DateTime? _startDate;
  DateTime? _endDate;
  Map<String, dynamic>? _vatSummary;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      await _loadVATReturns();
      await _loadTransactions();
      await _calculateVATSummary();
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Failed to load VAT data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadVATReturns() async {
    // TODO: Replace with real API call - GET /api/accountant/vat-returns
    await Future.delayed(const Duration(milliseconds: 500));
    
    final mockVATReturns = [
      {
        'id': '1',
        'period': '2024-Q1',
        'startDate': '2024-01-01',
        'endDate': '2024-03-31',
        'totalSales': 1500000.0,
        'totalVAT': 195000.0,
        'vatRate': 13.0,
        'status': 'filed',
        'filedDate': '2024-04-15',
        'referenceNumber': 'VAT-2024-Q1-001',
        'irnNumber': 'IRN-2024-001234',
      },
      {
        'id': '2',
        'period': '2024-Q2',
        'startDate': '2024-04-01',
        'endDate': '2024-06-30',
        'totalSales': 1800000.0,
        'totalVAT': 234000.0,
        'vatRate': 13.0,
        'status': 'draft',
        'filedDate': null,
        'referenceNumber': null,
        'irnNumber': null,
      },
      {
        'id': '3',
        'period': '2024-Q3',
        'startDate': '2024-07-01',
        'endDate': '2024-09-30',
        'totalSales': 0.0,
        'totalVAT': 0.0,
        'vatRate': 13.0,
        'status': 'pending',
        'filedDate': null,
        'referenceNumber': null,
        'irnNumber': null,
      },
    ];
    
    if (mounted) {
      setState(() {
        _vatReturns = mockVATReturns;
      });
    }
  }

  Future<void> _loadTransactions() async {
    // TODO: Replace with real API call - GET /api/accountant/transactions
    await Future.delayed(const Duration(milliseconds: 300));
    
    final mockTransactions = [
      {
        'id': '1',
        'date': '2024-03-15',
        'type': 'sale',
        'description': 'Pharmaceutical sales - Janakpur Medical',
        'amount': 50000.0,
        'vatAmount': 6500.0,
        'customerType': 'retailer',
        'customerName': 'Janakpur Medical Hall',
        'invoiceNumber': 'INV-2024-001',
        'category': 'pharmaceuticals',
      },
      {
        'id': '2',
        'date': '2024-03-18',
        'type': 'sale',
        'description': 'Medical supplies - City Pharmacy',
        'amount': 35000.0,
        'vatAmount': 4550.0,
        'customerType': 'retailer',
        'customerName': 'City Pharmacy',
        'invoiceNumber': 'INV-2024-002',
        'category': 'medical_supplies',
      },
      {
        'id': '3',
        'date': '2024-03-20',
        'type': 'purchase',
        'description': 'Stock purchase - Pharma Nepal',
        'amount': -120000.0,
        'vatAmount': -15600.0,
        'supplierName': 'Pharma Nepal Ltd',
        'billNumber': 'BILL-2024-001',
        'category': 'inventory_purchase',
      },
      {
        'id': '4',
        'date': '2024-03-22',
        'type': 'sale',
        'description': 'Vitamin supplements - Rural Health Center',
        'amount': 28000.0,
        'vatAmount': 3640.0,
        'customerType': 'retailer',
        'customerName': 'Rural Health Center',
        'invoiceNumber': 'INV-2024-003',
        'category': 'supplements',
      },
    ];
    
    if (mounted) {
      setState(() {
        _transactions = mockTransactions;
      });
    }
  }

  Future<void> _calculateVATSummary() async {
    // Calculate VAT summary for current period
    final now = DateTime.now();
    final currentQuarter = ((now.month - 1) ~/ 3) + 1;
    final year = now.year;
    
    final startDate = DateTime(year, (currentQuarter - 1) * 3 + 1, 1);
    final endDate = DateTime(year, currentQuarter * 3, DateTime(year, currentQuarter * 3 + 1, 0).day);
    
    final periodTransactions = _transactions.where((t) {
      final transactionDate = DateTime.parse(t['date']);
      return transactionDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
             transactionDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
    
    final totalSales = periodTransactions
        .where((t) => t['type'] == 'sale')
        .fold(0.0, (sum, t) => sum + (t['amount'] as double));
    
    final totalVAT = periodTransactions
        .where((t) => t['type'] == 'sale')
        .fold(0.0, (sum, t) => sum + (t['vatAmount'] as double));
    
    final totalPurchases = periodTransactions
        .where((t) => t['type'] == 'purchase')
        .fold(0.0, (sum, t) => sum + (t['amount'] as double).abs());
    
    final inputVAT = periodTransactions
        .where((t) => t['type'] == 'purchase')
        .fold(0.0, (sum, t) => sum + (t['vatAmount'] as double).abs());
    
    final netVAT = totalVAT - inputVAT;
    
    if (mounted) {
      setState(() {
        _startDate = startDate;
        _endDate = endDate;
        _vatSummary = {
          'period': '$year-Q$currentQuarter',
          'totalSales': totalSales,
          'totalVAT': totalVAT,
          'totalPurchases': totalPurchases,
          'inputVAT': inputVAT,
          'netVAT': netVAT,
          'vatRate': 13.0,
          'transactionCount': periodTransactions.length,
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'VAT Returns',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.accountantColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: _generateVATReturnPDF,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                _buildPeriodSelector(),
                _buildVATSummary(),
                Expanded(
                  child: _buildTabBar(),
                ),
              ],
            ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: GlassmorphicCard(
              child: DropdownButtonFormField<String>(
                decoration: AppTheme.inputDecoration('Select period...'),
                value: _selectedPeriod,
                items: const [
                  DropdownMenuItem(value: 'current', child: Text('Current Quarter', style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: 'previous', child: Text('Previous Quarter', style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: 'custom', child: Text('Custom Range', style: TextStyle(color: Colors.white))),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedPeriod = value;
                  });
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (_selectedPeriod == 'custom') ...[
            Expanded(
              child: GlassmorphicButton(
                text: '${_startDate != null ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}' : 'Start Date'}',
                icon: Icons.calendar_today,
                onPressed: _selectStartDate,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlassmorphicButton(
                text: '${_endDate != null ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}' : 'End Date'}',
                icon: Icons.calendar_today,
                onPressed: _selectEndDate,
              ),
            ),
          ] else ...[
            Expanded(
              child: GlassmorphicButton(
                text: 'Generate Return',
                icon: Icons.file_download,
                onPressed: _generateVATReturnPDF,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVATSummary() {
    if (_vatSummary == null) return const SizedBox();
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: GlassmorphicCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long, color: AppTheme.accountantColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  'VAT Summary - ${_vatSummary!['period']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Total Sales',
                    'NPR ${(_vatSummary!['totalSales'] as double).toStringAsFixed(2)}',
                    Icons.trending_up,
                    AppTheme.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryItem(
                    'Output VAT',
                    'NPR ${(_vatSummary!['totalVAT'] as double).toStringAsFixed(2)}',
                    Icons.account_balance,
                    AppTheme.info,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Input VAT',
                    'NPR ${(_vatSummary!['inputVAT'] as double).toStringAsFixed(2)}',
                    Icons.account_balance_wallet,
                    AppTheme.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryItem(
                    'Net VAT Payable',
                    'NPR ${(_vatSummary!['netVAT'] as double).toStringAsFixed(2)}',
                    Icons.payment,
                    (_vatSummary!['netVAT'] as double) >= 0 ? AppTheme.success : AppTheme.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: AppTheme.accountantColor,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.accountantColor,
            tabs: const [
              Tab(text: 'VAT Returns'),
              Tab(text: 'Transactions'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildVATReturnsList(),
                _buildTransactionsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVATReturnsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _vatReturns.length,
      itemBuilder: (context, index) {
        return _buildVATReturnCard(_vatReturns[index]);
      },
    );
  }

  Widget _buildVATReturnCard(Map<String, dynamic> vatReturn) {
    final status = vatReturn['status'] as String;
    final statusColor = _getVATReturnStatusColor(status);
    final statusIcon = _getVATReturnStatusIcon(status);
    
    return GlassmorphicCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vatReturn['period'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${vatReturn['startDate']} to ${vatReturn['endDate']}',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Sales: NPR ${(vatReturn['totalSales'] as double).toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'VAT Amount: NPR ${(vatReturn['totalVAT'] as double).toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (vatReturn['referenceNumber'] != null) ...[
                      Text(
                        'Ref: ${vatReturn['referenceNumber']}',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    if (vatReturn['irnNumber'] != null)
                      Text(
                        'IRN: ${vatReturn['irnNumber']}',
                        style: TextStyle(
                          color: AppTheme.info,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GlassmorphicButton(
                    text: 'View Details',
                    icon: Icons.visibility,
                    onPressed: () => _showVATReturnDetails(vatReturn),
                  ),
                ),
                const SizedBox(width: 8),
                if (status == 'draft')
                  Expanded(
                    child: GlassmorphicButton(
                      text: 'File Return',
                      icon: Icons.file_upload,
                      onPressed: () => _fileVATReturn(vatReturn),
                    ),
                  ),
                if (status == 'filed')
                  Expanded(
                    child: GlassmorphicButton(
                      text: 'Download PDF',
                      icon: Icons.download,
                      onPressed: () => _downloadVATReturnPDF(vatReturn),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        return _buildTransactionCard(_transactions[index]);
      },
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final type = transaction['type'] as String;
    final typeColor = type == 'sale' ? AppTheme.success : AppTheme.warning;
    final typeIcon = type == 'sale' ? Icons.trending_up : Icons.trending_down;
    
    return GlassmorphicCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(typeIcon, color: typeColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction['description'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transaction['date'],
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'NPR ${(transaction['amount'] as double).toStringAsFixed(2)}',
                  style: TextStyle(
                    color: typeColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (transaction['invoiceNumber'] != null)
              Text(
                'Invoice: ${transaction['invoiceNumber']}',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'VAT: NPR ${(transaction['vatAmount'] as double).toStringAsFixed(2)}',
              style: TextStyle(
                color: AppTheme.info,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getVATReturnStatusColor(String status) {
    switch (status) {
      case 'filed':
        return AppTheme.success;
      case 'draft':
        return AppTheme.warning;
      case 'pending':
        return AppTheme.info;
      case 'rejected':
        return AppTheme.error;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _getVATReturnStatusIcon(String status) {
    switch (status) {
      case 'filed':
        return Icons.check_circle;
      case 'draft':
        return Icons.edit;
      case 'pending':
        return Icons.pending;
      case 'rejected':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (date != null) {
      setState(() {
        _startDate = date;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now(),
    );
    
    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  Future<void> _generateVATReturnPDF() async {
    if (_vatSummary == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No VAT data available'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    try {
      final pdf = await _createVATReturnPDF();
      
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'VAT_Return_${_vatSummary!['period']}.pdf',
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('VAT Return PDF generated successfully'),
          backgroundColor: AppTheme.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate PDF: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  Future<pw.Document> _createVATReturnPDF() async {
    final pdf = pw.Document();
    
    // Add title page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'VEDANTATRADE PVT. LTD.',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'VAT Return Form',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.SizedBox(height: 20),
              
              // Period Information
              pw.Text(
                'Period Information',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Period: ${_vatSummary!['period']}'),
                        pw.Text('Start Date: ${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'),
                        pw.Text('End Date: ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('VAT Rate: ${_vatSummary!['vatRate']}%'),
                        pw.Text('Total Transactions: ${_vatSummary!['transactionCount']}'),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              
              // VAT Summary
              pw.Text(
                'VAT Summary',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  // Header
                  pw.TableRow(
                    children: [
                      _pdfCell('Description', bold: true),
                      _pdfCell('Amount (NPR)', bold: true),
                    ],
                  ),
                  // Data rows
                  pw.TableRow(
                    children: [
                      _pdfCell('Total Sales'),
                      _pdfCell((_vatSummary!['totalSales'] as double).toStringAsFixed(2)),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _pdfCell('Output VAT (13%)'),
                      _pdfCell((_vatSummary!['totalVAT'] as double).toStringAsFixed(2)),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _pdfCell('Input VAT'),
                      _pdfCell((_vatSummary!['inputVAT'] as double).toStringAsFixed(2)),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _pdfCell('Net VAT Payable', bold: true),
                      _pdfCell((_vatSummary!['netVAT'] as double).toStringAsFixed(2), bold: true),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              
              // IRDN Compliance Note
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'IRDN Compliance Note',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'This VAT return is filed as per Inland Revenue Department Nepal (IRDN) regulations. '
                      'All calculations are based on 13% VAT rate as per current Nepal tax laws.',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
    
    return pdf;
  }

  pw.Widget _pdfCell(String text, {bool bold = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  void _showVATReturnDetails(Map<String, dynamic> vatReturn) {
    showDialog(
      context: context,
      builder: (context) => _VATReturnDetailsDialog(vatReturn: vatReturn),
    );
  }

  Future<void> _fileVATReturn(Map<String, dynamic> vatReturn) async {
    try {
      // TODO: Replace with real API call - POST /api/accountant/vat-returns/{id}/file
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('VAT return filed successfully'),
            backgroundColor: AppTheme.success,
          ),
        );
        _loadData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to file VAT return: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  Future<void> _downloadVATReturnPDF(Map<String, dynamic> vatReturn) async {
    try {
      // TODO: Replace with real API call - GET /api/accountant/vat-returns/{id}/pdf
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Downloading VAT return PDF...'),
          backgroundColor: AppTheme.info,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download PDF: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }
}

class _VATReturnDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> vatReturn;

  const _VATReturnDetailsDialog({required this.vatReturn, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surfaceDark,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'VAT Return Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Return Information
            _buildDetailSection('Return Information', [
              _buildDetailRow('Period', vatReturn['period']),
              _buildDetailRow('Start Date', vatReturn['startDate']),
              _buildDetailRow('End Date', vatReturn['endDate']),
              _buildDetailRow('Status', vatReturn['status']),
              if (vatReturn['referenceNumber'] != null)
                _buildDetailRow('Reference Number', vatReturn['referenceNumber']),
              if (vatReturn['irnNumber'] != null)
                _buildDetailRow('IRN Number', vatReturn['irnNumber']),
            ]),
            
            const SizedBox(height: 20),
            
            // Financial Summary
            _buildDetailSection('Financial Summary', [
              _buildDetailRow('Total Sales', 'NPR ${(vatReturn['totalSales'] as double).toStringAsFixed(2)}'),
              _buildDetailRow('VAT Amount', 'NPR ${(vatReturn['totalVAT'] as double).toStringAsFixed(2)}'),
              _buildDetailRow('VAT Rate', '${vatReturn['vatRate']}%'),
              if (vatReturn['filedDate'] != null)
                _buildDetailRow('Filed Date', vatReturn['filedDate']),
            ]),
            
            const Spacer(),
            
            // Close Button
            SizedBox(
              width: double.infinity,
              child: GlassmorphicButton(
                text: 'Close',
                icon: Icons.close,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

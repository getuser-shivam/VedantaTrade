import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import '../providers/vat_return_provider.dart';
import '../widgets/vat_return_summary_widget.dart';
import '../widgets/vat_return_items_widget.dart';
import '../widgets/vat_return_actions_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/theme/app_theme.dart';

/// VAT Return Details Page
/// Displays detailed information about a specific VAT return
class VatReturnDetailsPage extends StatefulWidget {
  final String vatReturnId;
  
  const VatReturnDetailsPage({
    Key? key,
    required this.vatReturnId,
  }) : super(key: key);

  @override
  _VatReturnDetailsPageState createState() => _VatReturnDetailsPageState();
}

class _VatReturnDetailsPageState extends State<VatReturnDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Load VAT return details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVatReturnDetails();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _loadVatReturnDetails() {
    final provider = VatReturnProvider.of(context);
    provider.getVatReturnDetails(widget.vatReturnId);
  }
  
  void _onEdit() {
    Navigator.pushNamed(
      context,
      '/vat-return/edit',
      arguments: widget.vatReturnId,
    );
  }
  
  void _onDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete VAT Return'),
        content: const Text('Are you sure you want to delete this VAT return? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteVatReturn();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  void _deleteVatReturn() {
    final provider = VatReturnProvider.of(context);
    provider.deleteVatReturn(widget.vatReturnId).then((_) {
      Navigator.pop(context);
    });
  }
  
  void _onSubmit() {
    final provider = VatReturnProvider.of(context);
    provider.submitVatReturn(widget.vatReturnId);
  }
  
  void _onApprove() {
    final provider = VatReturnProvider.of(context);
    provider.approveVatReturn(widget.vatReturnId);
  }
  
  void _onReject() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject VAT Return'),
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'Reason for rejection',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            // Store reason
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Reject with reason
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
  
  void _onGeneratePdf() async {
    final provider = VatReturnProvider.of(context);
    final result = await provider.generateVatReturnPdf(widget.vatReturnId);
    
    result.fold(
      (error) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      ),
      (pdfData) => _showPdfOptions(pdfData),
    );
  }
  
  void _showPdfOptions(Uint8List pdfData) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PDF Options',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Download PDF'),
              subtitle: const Text('Save PDF to device'),
              onTap: () {
                Navigator.pop(context);
                _downloadPdf(pdfData);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share PDF'),
              subtitle: const Text('Share via email, messaging, etc.'),
              onTap: () {
                Navigator.pop(context);
                _sharePdf(pdfData);
              },
            ),
            ListTile(
              leading: const Icon(Icons.print),
              title: const Text('Print PDF'),
              subtitle: const Text('Print using device printer'),
              onTap: () {
                Navigator.pop(context);
                _printPdf(pdfData);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _downloadPdf(Uint8List pdfData) async {
    final provider = VatReturnProvider.of(context);
    final result = await provider.saveVatReturnPdf(widget.vatReturnId, pdfData);
    
    result.fold(
      (error) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      ),
      (filePath) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved to $filePath')),
      ),
    );
  }
  
  void _sharePdf(Uint8List pdfData) async {
    try {
      final provider = VatReturnProvider.of(context);
      final vatReturn = provider.currentVatReturn;
      
      if (vatReturn != null) {
        final fileName = 'vat_return_${vatReturn.id}.pdf';
        await Share.shareXFiles(
          [XFile.fromData(pdfData, name: fileName)],
          subject: 'VAT Return - ${vatReturn.taxPeriod}',
          text: 'VAT Return for ${vatReturn.businessName} - ${vatReturn.taxPeriod}',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share PDF: $e')),
      );
    }
  }
  
  void _printPdf(Uint8List pdfData) async {
    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfData,
        name: 'VAT Return',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to print PDF: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VAT Return Details'),
        actions: [
          Consumer<VatReturnProvider>(
            builder: (context, provider, child) {
              final vatReturn = provider.currentVatReturn;
              
              if (vatReturn == null) return const SizedBox.shrink();
              
              return PopupMenuButton<String>(
                onSelected: (action) {
                  switch (action) {
                    case 'edit':
                      _onEdit();
                      break;
                    case 'delete':
                      _onDelete();
                      break;
                    case 'submit':
                      _onSubmit();
                      break;
                    case 'approve':
                      _onApprove();
                      break;
                    case 'reject':
                      _onReject();
                      break;
                    case 'pdf':
                      _onGeneratePdf();
                      break;
                  }
                },
                itemBuilder: (context) {
                  final items = <PopupMenuEntry<String>>[];
                  
                  // Edit action (only for draft status)
                  if (vatReturn.status == VatReturnStatus.draft) {
                    items.add(const PopupMenuItem(value: 'edit', child: Text('Edit')));
                  }
                  
                  // Submit action (only for draft status)
                  if (vatReturn.status == VatReturnStatus.draft) {
                    items.add(const PopupMenuItem(value: 'submit', child: Text('Submit')));
                  }
                  
                  // Approve action (only for submitted status)
                  if (vatReturn.status == VatReturnStatus.submitted) {
                    items.add(const PopupMenuItem(value: 'approve', child: Text('Approve')));
                    items.add(const PopupMenuItem(value: 'reject', child: Text('Reject')));
                  }
                  
                  // PDF action
                  items.add(const PopupMenuItem(value: 'pdf', child: Text('Generate PDF')));
                  
                  // Delete action (only for draft status)
                  if (vatReturn.status == VatReturnStatus.draft) {
                    items.add(const PopupMenuItem(value: 'delete', child: Text('Delete')));
                  }
                  
                  return items;
                },
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Sales'),
            Tab(text: 'Purchases'),
            Tab(text: 'Tax Details'),
          ],
        ),
      ),
      body: Consumer<VatReturnProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingWidget();
          }
          
          if (provider.error != null) {
            return AppErrorWidget(
              message: provider.error!,
              onRetry: _loadVatReturnDetails,
            );
          }
          
          final vatReturn = provider.currentVatReturn;
          
          if (vatReturn == null) {
            return const Center(child: Text('VAT Return not found'));
          }
          
          return Column(
            children: [
              // Status banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: _getStatusColor(vatReturn.status).withOpacity(0.1),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(vatReturn.status),
                      color: _getStatusColor(vatReturn.status),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getStatusText(vatReturn.status),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(vatReturn.status),
                            ),
                          ),
                          Text(
                            'Tax Period: ${vatReturn.taxPeriod}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Action buttons
              VatReturnActionsWidget(
                vatReturn: vatReturn,
                onEdit: _onEdit,
                onDelete: _onDelete,
                onSubmit: _onSubmit,
                onApprove: _onApprove,
                onReject: _onReject,
                onGeneratePdf: _onGeneratePdf,
              ),
              
              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(vatReturn),
                    _buildSalesTab(vatReturn),
                    _buildPurchasesTab(vatReturn),
                    _buildTaxDetailsTab(vatReturn),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildOverviewTab(VatReturnEntity vatReturn) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Business Information
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Business Information',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Business Name:', vatReturn.businessName),
                  _buildInfoRow('Address:', vatReturn.businessAddress),
                  _buildInfoRow('PAN Number:', vatReturn.businessPan),
                  _buildInfoRow('IRDN Number:', vatReturn.businessIrdn),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Tax Period Information
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tax Period',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Period:', vatReturn.taxPeriod),
                  _buildInfoRow('Start Date:', _formatDate(vatReturn.startDate)),
                  _buildInfoRow('End Date:', _formatDate(vatReturn.endDate)),
                  _buildInfoRow('Filing Date:', _formatDate(vatReturn.filingDate)),
                  _buildInfoRow('Return Type:', _formatReturnType(vatReturn.returnType)),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Summary
          VatReturnSummaryWidget(vatReturn: vatReturn),
          
          const SizedBox(height: 16),
          
          // Submission Information
          if (vatReturn.submittedDate != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Submission Information',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    if (vatReturn.submittedTo != null)
                      _buildInfoRow('Submitted To:', vatReturn.submittedTo!),
                    _buildInfoRow('Submission Date:', _formatDate(vatReturn.submittedDate!)),
                    if (vatReturn.submissionReference != null)
                      _buildInfoRow('Reference:', vatReturn.submissionReference!),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildSalesTab(VatReturnEntity vatReturn) {
    return VatReturnItemsWidget(
      title: 'Sales Transactions',
      items: vatReturn.salesItems,
      emptyMessage: 'No sales transactions found',
    );
  }
  
  Widget _buildPurchasesTab(VatReturnEntity vatReturn) {
    return VatReturnItemsWidget(
      title: 'Purchase Transactions',
      items: vatReturn.purchaseItems,
      emptyMessage: 'No purchase transactions found',
    );
  }
  
  Widget _buildTaxDetailsTab(VatReturnEntity vatReturn) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tax Details',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          
          // Tax breakdown by rate
          Card(
            child: Column(
              children: [
                const ListTile(
                  title: Text('Tax Breakdown by Rate'),
                  subtitle: Text('Detailed tax calculation by VAT rate'),
                ),
                const Divider(),
                ...vatReturn.taxDetails.map((detail) => ListTile(
                  title: Text('${detail.vatRate.value}% VAT'),
                  subtitle: Text(detail.description),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatCurrency(detail.taxableAmount),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _formatCurrency(detail.vatAmount),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Tax calculation summary
          Card(
            child: Column(
              children: [
                const ListTile(
                  title: Text('Tax Calculation Summary'),
                  subtitle: Text('Complete tax calculation breakdown'),
                ),
                const Divider(),
                _buildCalculationRow('Output Tax', vatReturn.outputTax),
                _buildCalculationRow('Input Tax', vatReturn.inputTax),
                _buildCalculationRow('Net Tax Payable', vatReturn.netTaxPayable),
                _buildCalculationRow('Tax Paid', vatReturn.taxPaid),
                _buildCalculationRow('Tax Refundable', vatReturn.taxRefundable),
                if (vatReturn.penalty > 0)
                  _buildCalculationRow('Penalty', vatReturn.penalty),
                if (vatReturn.interest > 0)
                  _buildCalculationRow('Interest', vatReturn.interest),
                const Divider(),
                _buildCalculationRow(
                  'Total Amount Due',
                  vatReturn.totalAmountDue,
                  isBold: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCalculationRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            _formatCurrency(amount),
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: amount < 0 ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getStatusColor(VatReturnStatus status) {
    switch (status) {
      case VatReturnStatus.draft:
        return Colors.grey;
      case VatReturnStatus.pending:
        return Colors.orange;
      case VatReturnStatus.submitted:
        return Colors.blue;
      case VatReturnStatus.processing:
        return Colors.purple;
      case VatReturnStatus.approved:
        return Colors.green;
      case VatReturnStatus.rejected:
        return Colors.red;
      case VatReturnStatus.paid:
        return Colors.teal;
      case VatReturnStatus.refunded:
        return Colors.indigo;
      case VatReturnStatus.cancelled:
        return Colors.grey;
      case VatReturnStatus.archived:
        return Colors.grey;
    }
  }
  
  IconData _getStatusIcon(VatReturnStatus status) {
    switch (status) {
      case VatReturnStatus.draft:
        return Icons.edit;
      case VatReturnStatus.pending:
        return Icons.pending;
      case VatReturnStatus.submitted:
        return Icons.send;
      case VatReturnStatus.processing:
        return Icons.hourglass_empty;
      case VatReturnStatus.approved:
        return Icons.check_circle;
      case VatReturnStatus.rejected:
        return Icons.cancel;
      case VatReturnStatus.paid:
        return Icons.payment;
      case VatReturnStatus.refunded:
        return Icons.money_off;
      case VatReturnStatus.cancelled:
        return Icons.cancel;
      case VatReturnStatus.archived:
        return Icons.archive;
    }
  }
  
  String _getStatusText(VatReturnStatus status) {
    switch (status) {
      case VatReturnStatus.draft:
        return 'Draft';
      case VatReturnStatus.pending:
        return 'Pending';
      case VatReturnStatus.submitted:
        return 'Submitted';
      case VatReturnStatus.processing:
        return 'Processing';
      case VatReturnStatus.approved:
        return 'Approved';
      case VatReturnStatus.rejected:
        return 'Rejected';
      case VatReturnStatus.paid:
        return 'Paid';
      case VatReturnStatus.refunded:
        return 'Refunded';
      case VatReturnStatus.cancelled:
        return 'Cancelled';
      case VatReturnStatus.archived:
        return 'Archived';
    }
  }
  
  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }
  
  String _formatCurrency(double amount) {
    return 'NPR ${amount.toStringAsFixed(2)}';
  }
  
  String _formatReturnType(VatReturnType type) {
    switch (type) {
      case VatReturnType.monthly:
        return 'Monthly';
      case VatReturnType.quarterly:
        return 'Quarterly';
      case VatReturnType.halfYearly:
        return 'Half-Yearly';
      case VatReturnType.yearly:
        return 'Yearly';
      case VatReturnType.adHoc:
        return 'Ad-Hoc';
    }
  }
}

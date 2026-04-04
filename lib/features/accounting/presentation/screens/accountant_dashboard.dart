import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:open_file/open_file.dart';

import '../services/vat_report_service.dart';
import '../providers/accountant_provider.dart';
import '../../../../shared/theme/enhanced_theme.dart';
import '../../../../shared/widgets/enhanced_ui_kit.dart';

/// Accountant dashboard with VAT returns and expense reconciliation
class AccountantDashboardScreen extends StatefulWidget {
  const AccountantDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AccountantDashboardScreen> createState() => _AccountantDashboardScreenState();
}

class _AccountantDashboardScreenState extends State<AccountantDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  List<VATReport> _vatReports = [];
  List<ExpenseClaim> _expenseClaims = [];
  bool _isLoading = false;
  String _searchQuery = '';
  ExpenseClaimStatus? _selectedClaimStatus;
  DateTimeRange? _selectedDateRange;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Initialize VAT report service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDashboard();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Initialize dashboard
  Future<void> _initializeDashboard() async {
    try {
      setState(() => _isLoading = true);
      
      final vatService = VATReportService();
      
      // Initialize VAT service
      await vatService.initialize();
      
      // Listen to VAT reports
      vatService.reportsStream.listen((reports) {
        if (mounted) {
          setState(() {
            _vatReports = reports;
            _isLoading = false;
          });
        }
      });
      
      // Listen to expense claims
      vatService.claimsStream.listen((claims) {
        if (mounted) {
          setState(() {
            _expenseClaims = claims;
          });
        }
      });
      
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Failed to initialize dashboard: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EnhancedTheme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildSummaryCards(context),
          _buildTabBar(context),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVATReportsTab(context),
                _buildExpenseClaimsTab(context),
                _buildAnalyticsTab(context),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  /// Build app bar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return EnhancedAppBar(
      title: 'Accountant Dashboard',
      subtitle: 'VAT Returns & Expense Reconciliation',
      backgroundColor: EnhancedTheme.of(context).appBarColor,
      actions: [
        IconButton(
          icon: Icon(
            Icons.search,
            color: EnhancedTheme.of(context).iconColor,
          ),
          onPressed: _showSearchDialog,
        ),
        IconButton(
          icon: Icon(
            Icons.refresh,
            color: EnhancedTheme.of(context).iconColor,
          ),
          onPressed: _refreshData,
        ),
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: EnhancedTheme.of(context).iconColor,
          ),
          onSelected: (value) => _handleMenuAction(context, value),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(
                    Icons.download,
                    color: EnhancedTheme.of(context).iconColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Export Data',
                    style: TextStyle(
                      color: EnhancedTheme.of(context).textColor,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(
                    Icons.settings,
                    color: EnhancedTheme.of(context).iconColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Settings',
                    style: TextStyle(
                      color: EnhancedTheme.of(context).textColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build summary cards
  Widget _buildSummaryCards(BuildContext context) {
    final pendingClaims = _expenseClaims.where((claim) => claim.status == ExpenseClaimStatus.pending).length;
    final approvedClaims = _expenseClaims.where((claim) => claim.status == ExpenseClaimStatus.approved).length;
    final rejectedClaims = _expenseClaims.where((claim) => claim.status == ExpenseClaimStatus.rejected).length;
    final totalVATPayable = _calculateTotalVATPayable();
    
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              context,
              'Pending Claims',
              '$pendingClaims',
              Icons.pending_actions,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              context,
              'Total VAT Payable',
              '₹${totalVATPayable.toStringAsFixed(2)}',
              Icons.account_balance,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              context,
              'Approved Claims',
              '$approvedClaims',
              Icons.check_circle,
              Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  /// Build summary card
  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EnhancedTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blur: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.trending_up,
                  color: color,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: EnhancedTheme.of(context).textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: EnhancedTheme.of(context).textColor.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Build tab bar
  Widget _buildTabBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: EnhancedTheme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: EnhancedTheme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: EnhancedTheme.of(context).textColor,
        unselectedLabelColor: EnhancedTheme.of(context).textColor.withOpacity(0.6),
        indicator: BoxDecoration(
          color: EnhancedTheme.of(context).primaryColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(8),
          ),
        ),
        tabs: const [
          Tab(
            text: 'VAT Reports',
            icon: Icon(Icons.receipt_long),
          ),
          Tab(
            text: 'Expense Claims',
            icon: Icon(Icons.receipt),
          ),
          Tab(
            text: 'Analytics',
            icon: Icon(Icons.analytics),
          ),
        ],
      ),
    );
  }

  /// Build VAT reports tab
  Widget _buildVATReportsTab(BuildContext context) {
    return Column(
      children: [
        // Date range selector
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.date_range,
                color: EnhancedTheme.of(context).iconColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Select Date Range:',
                style: TextStyle(
                  color: EnhancedTheme.of(context).textColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _showDateRangeDialog,
                  child: Text(
                    _selectedDateRange != null
                        ? '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}'
                        : 'Select Range',
                    style: TextStyle(
                      color: EnhancedTheme.of(context).textColor,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: EnhancedTheme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              EnhancedButton(
                text: 'Generate Report',
                icon: Icons.add,
                onPressed: _showGenerateVATReportDialog,
              ),
            ],
          ),
        ),
        
        // VAT reports list
        Expanded(
          child: _isLoading
              ? _buildLoadingWidget(context)
              : _vatReports.isEmpty
                  ? _buildEmptyState(context, 'No VAT reports found')
                  : ListView.builder(
                      itemCount: _vatReports.length,
                      itemBuilder: (context, index) {
                        final report = _vatReports[index];
                        return _buildVATReportCard(context, report);
                      },
                    ),
        ),
      ],
    );
  }

  /// Build expense claims tab
  Widget _buildExpenseClaimsTab(BuildContext context) {
    return Column(
      children: [
        // Filter controls
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.filter_list,
                color: EnhancedTheme.of(context).iconColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Filter by Status:',
                style: TextStyle(
                  color: EnhancedTheme.of(context).textColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButton<ExpenseClaimStatus>(
                  value: _selectedClaimStatus,
                  hint: Text(
                    'All Claims',
                    style: TextStyle(
                      color: EnhancedTheme.of(context).textColor,
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(
                        'All Claims',
                        style: TextStyle(
                          color: EnhancedTheme.of(context).textColor,
                        ),
                      ),
                    ),
                    ...ExpenseClaimStatus.values.map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(
                        status.toString().split('.').last.capitalize(),
                        style: TextStyle(
                          color: EnhancedTheme.of(context).textColor,
                        ),
                      ),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedClaimStatus = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        
        // Expense claims list
        Expanded(
          child: _isLoading
              ? _buildLoadingWidget(context)
              : _expenseClaims.isEmpty
                  ? _buildEmptyState(context, 'No expense claims found')
                  : ListView.builder(
                      itemCount: _getFilteredClaims().length,
                      itemBuilder: (context, index) {
                        final claim = _getFilteredClaims()[index];
                        return _buildExpenseClaimCard(context, claim);
                      },
                    ),
        ),
      ],
    );
  }

  /// Build analytics tab
  Widget _buildAnalyticsTab(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Financial Analytics',
            style: TextStyle(
              color: EnhancedTheme.of(context).textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Analytics cards
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildAnalyticsCard(
                  context,
                  'Total VAT Reports',
                  '${_vatReports.length}',
                  Icons.receipt_long,
                  Colors.blue,
                ),
                _buildAnalyticsCard(
                  context,
                  'Total Claims',
                  '${_expenseClaims.length}',
                  Icons.receipt,
                  Colors.green,
                ),
                _buildAnalyticsCard(
                  context,
                  'Pending Claims',
                  '${_expenseClaims.where((c) => c.status == ExpenseClaimStatus.pending).length}',
                  Icons.pending,
                  Colors.orange,
                ),
                _buildAnalyticsCard(
                  context,
                  'Total Amount',
                  '₹${_calculateTotalClaimAmount().toStringAsFixed(2)}',
                  Icons.attach_money,
                  Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build VAT report card
  Widget _buildVATReportCard(BuildContext context, VATReport report) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EnhancedTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blur: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                      report.reportType,
                      style: TextStyle(
                        color: EnhancedTheme.of(context).textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Period: ${_formatDate(report.startDate)} - ${_formatDate(report.endDate)}',
                      style: TextStyle(
                        color: EnhancedTheme.of(context).textColor.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: EnhancedTheme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'NPR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Net VAT Payable: ₹${report.vatCalculations.netVATPayable.toStringAsFixed(2)}',
                style: TextStyle(
                  color: EnhancedTheme.of(context).primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                'Generated: ${_formatDate(report.generatedAt)}',
                style: TextStyle(
                  color: EnhancedTheme.of(context).textColor.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.description,
                color: EnhancedTheme.of(context).textColor.withOpacity(0.7),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                report.description ?? 'No description',
                style: TextStyle(
                  color: EnhancedTheme.of(context).textColor.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.picture_as_pdf,
                      color: EnhancedTheme.of(context).primaryColor,
                      size: 20,
                    ),
                    onPressed: () => _generateAndOpenVATPDF(report.id),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.visibility,
                      color: EnhancedTheme.of(context).primaryColor,
                      size: 20,
                    ),
                    onPressed: () => _viewVATReportDetails(report),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build expense claim card
  Widget _buildExpenseClaimCard(BuildContext context, ExpenseClaim claim) {
    final isPending = claim.status == ExpenseClaimStatus.pending;
    final isApproved = claim.status == ExpenseClaimStatus.approved;
    final isRejected = claim.status == ExpenseClaimStatus.rejected;
    
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EnhancedTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blur: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isPending ? Colors.orange : isRejected ? Colors.red : Colors.transparent,
          width: 2,
        ),
      ),
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
                      claim.mrName,
                      style: TextStyle(
                        color: EnhancedTheme.of(context).textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Claim Date: ${_formatDate(claim.claimDate)}',
                      style: TextStyle(
                        color: EnhancedTheme.of(context).textColor.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getClaimStatusColor(claim.status),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  claim.status.toString().split('.').last.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Amount: ₹${claim.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: EnhancedTheme.of(context).primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                'Receipts: ${claim.receiptImages.length}',
                style: TextStyle(
                  color: EnhancedTheme.of(context).textColor.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            claim.description,
            style: TextStyle(
              color: EnhancedTheme.of(context).textColor,
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (isPending)
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.check,
                        color: Colors.green,
                        size: 20,
                      ),
                      onPressed: () => _approveClaim(claim),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: () => _rejectClaim(claim),
                    ),
                  ],
                ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  Icons.visibility,
                  color: EnhancedTheme.of(context).primaryColor,
                  size: 20,
                ),
                onPressed: () => _viewClaimDetails(claim),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build analytics card
  Widget _buildAnalyticsCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EnhancedTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blur: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: EnhancedTheme.of(context).textColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Build floating action button
  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: EnhancedTheme.of(context).primaryColor,
      onPressed: _showGenerateVATReportDialog,
      child: Icon(
        Icons.add,
        color: Colors.white,
      ),
    );
  }

  /// Build loading widget
  Widget _buildLoadingWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/loading.json',
            width: 100,
            height: 100,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading...',
            style: TextStyle(
              color: EnhancedTheme.of(context).textColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// Build empty state widget
  Widget _buildEmptyState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: EnhancedTheme.of(context).iconColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: EnhancedTheme.of(context).textColor.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// Get filtered claims
  List<ExpenseClaim> _getFilteredClaims() {
    if (_selectedClaimStatus == null) {
      return _expenseClaims;
    }
    return _expenseClaims.where((claim) => claim.status == _selectedClaimStatus).toList();
  }

  /// Calculate total VAT payable
  double _calculateTotalVATPayable() {
    return _vatReports.fold(0.0, (sum, report) {
      return sum + report.vatCalculations.netVATPayable;
    });
  }

  /// Calculate total claim amount
  double _calculateTotalClaimAmount() {
    return _expenseClaims.fold(0.0, (sum, claim) {
      return sum + claim.amount;
    });
  }

  /// Get claim status color
  Color _getClaimStatusColor(ExpenseClaimStatus status) {
    switch (status) {
      case ExpenseClaimStatus.pending:
        return Colors.orange;
      case ExpenseClaimStatus.approved:
        return Colors.green;
      case ExpenseClaimStatus.rejected:
        return Colors.red;
    }
  }

  /// Format date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Show search dialog
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Search'),
        content: EnhancedTextField(
          hintText: 'Enter search query...',
          autofocus: true,
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Show date range dialog
  void _showDateRangeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Date Range'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Start Date:'),
            ElevatedButton(
              onPressed: () => _selectStartDate(),
              child: Text('Select Start Date'),
            ),
            const SizedBox(height: 16),
            Text('End Date:'),
            ElevatedButton(
              onPressed: () => _selectEndDate(),
              child: Text('Select End Date'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Apply date range filter
            },
            child: Text('Apply'),
          ),
        ],
      ),
    );
  }

  /// Show generate VAT report dialog
  void _showGenerateVATReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Generate VAT Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select report type:'),
            DropdownButton<String>(
              items: [
                DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                DropdownMenuItem(value: 'quarterly', child: Text('Quarterly')),
                DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
              ],
              onChanged: (value) {
                // Handle report type selection
              },
            ),
            const SizedBox(height: 16),
            EnhancedTextField(
              hintText: 'Description (optional)',
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _generateVATReport();
            },
            child: Text('Generate'),
          ),
        ],
      ),
    );
  }

  /// Select start date
  void _selectStartDate() {
    showDatePicker(
      context: context,
      initialDate: _selectedDateRange?.start ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((date) {
      if (date != null) {
        setState(() {
          _selectedDateRange = _selectedDateRange?.copyWith(start: date) ??
              DateTimeRange(start: date!, end: date!);
        });
      }
    });
  }

  /// Select end date
  void _selectEndDate() {
    showDatePicker(
      context: context,
      initialDate: _selectedDateRange?.end ?? DateTime.now(),
      firstDate: _selectedDateRange?.start ?? DateTime.now(),
      lastDate: DateTime.now(),
    ).then((date) {
      if (date != null) {
        setState(() {
          _selectedDateRange = _selectedDateRange?.copyWith(end: date) ??
              DateTimeRange(start: date!, end: date!);
        });
      }
    });
  }

  /// Generate VAT report
  Future<void> _generateVATReport() async {
    try {
      final vatService = VATReportService();
      
      final startDate = _selectedDateRange?.start ?? DateTime.now().subtract(const Duration(days: 30));
      final endDate = _selectedDateRange?.end ?? DateTime.now();
      
      final report = await vatService.generateVATReport(
        startDate: startDate,
        endDate: endDate,
        reportType: 'monthly',
        description: 'Monthly VAT return for Nepal',
      );
      
      if (report != null) {
        _showSuccessSnackBar('VAT report generated successfully');
      } else {
        _showErrorSnackBar('Failed to generate VAT report');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    }
  }

  /// Generate and open VAT PDF
  Future<void> _generateAndOpenVATPDF(String reportId) async {
    try {
      final vatService = VATReportService();
      final pdfPath = await vatService.generateVATReturnPDF(reportId);
      
      if (pdfPath != null) {
        await vatService.openPDF(pdfPath!);
        _showSuccessSnackBar('VAT PDF opened successfully');
      } else {
        _showErrorSnackBar('Failed to generate VAT PDF');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    }
  }

  /// View VAT report details
  void _viewVATReportDetails(VATReport report) {
    Navigator.pushNamed(context, '/vat-report-details', arguments: report);
  }

  /// Approve claim
  Future<void> _approveClaim(ExpenseClaim claim) async {
    try {
      final vatService = VATReportService();
      final success = await vatService.approveExpenseClaim(claim.id, 'Approved by accountant');
      
      if (success) {
        _showSuccessSnackBar('Expense claim approved successfully');
      } else {
        _showErrorSnackBar('Failed to approve expense claim');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    }
  }

  /// Reject claim
  Future<void> _rejectClaim(ExpenseClaim claim) async {
    try {
      final vatService = VATReportService();
      final success = await vatService.rejectExpenseClaim(claim.id, 'Insufficient documentation');
      
      if (success) {
        _showSuccessSnackBar('Expense claim rejected successfully');
      } else {
        _showErrorSnackBar('Failed to reject expense claim');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    }
  }

  /// View claim details
  void _viewClaimDetails(ExpenseClaim claim) {
    Navigator.pushNamed(context, '/claim-details', arguments: claim);
  }

  /// Refresh data
  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    
    try {
      final vatService = VATReportService();
      // Refresh data would be implemented here
    } catch (e) {
      _showErrorSnackBar('Failed to refresh data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Handle menu actions
  void _handleMenuAction(BuildContext context, String? action) {
    switch (action) {
      case 'export':
        _exportData(context);
        break;
      case 'settings':
        Navigator.pushNamed(context, '/settings');
        break;
    }
  }

  /// Export data
  void _exportData(BuildContext context) {
    // Implement data export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Data exported successfully'),
        backgroundColor: EnhancedTheme.of(context).primaryColor,
      ),
    );
  }

  /// Show success snack bar
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Show error snack bar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}

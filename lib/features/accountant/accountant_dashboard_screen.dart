import 'package:flutter/material.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';
import 'package:vedanta_trade/shared/app_scaffold.dart';
import 'package:vedanta_trade/shared/widgets.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_trade/features/auth/presentation/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:vedanta_trade/core/api_config.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';

class AccountantDashboardScreen extends StatefulWidget {
  const AccountantDashboardScreen({Key? key}) : super(key: key);

  @override
  _AccountantDashboardScreenState createState() => _AccountantDashboardScreenState();
}

class _AccountantDashboardScreenState extends State<AccountantDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic> _dashboardData = {};
  List<dynamic> _pendingExpenses = [];
  List<dynamic> _vatReturns = [];
  List<dynamic> _transactions = [];
  bool _loading = true;
  String _selectedPeriod = 'current_month';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      
      final futures = await Future.wait([
        dio.get('${ApiConfig.baseUrl}/accountant/dashboard', 
             options: Options(headers: {'Authorization': 'Bearer ${auth.token}'})),
        dio.get('${ApiConfig.baseUrl}/accountant/expenses/pending', 
             options: Options(headers: {'Authorization': 'Bearer ${auth.token}'})),
        dio.get('${ApiConfig.baseUrl}/accountant/vat-returns', 
             options: Options(headers: {'Authorization': 'Bearer ${auth.token}'})),
        dio.get('${ApiConfig.baseUrl}/accountant/transactions', 
             options: Options(headers: {'Authorization': 'Bearer ${auth.token}'})),
      ]);

      if (mounted) {
        setState(() {
          _dashboardData = futures[0].data['data'] ?? {};
          _pendingExpenses = futures[1].data['data'] ?? [];
          _vatReturns = futures[2].data['data'] ?? [];
          _transactions = futures[3].data['data'] ?? [];
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading dashboard: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Accountant Dashboard',
      roleColor: AppTheme.accountantColor,
      navItems: [
        NavItem(label: 'Dashboard', icon: Icons.dashboard_rounded, route: '/accountant'),
        NavItem(label: 'VAT Returns', icon: Icons.receipt_long_rounded, route: '/accountant/vat'),
        NavItem(label: 'Expenses', icon: Icons.money_rounded, route: '/accountant/expenses'),
        NavItem(label: 'Reports', icon: Icons.assessment_rounded, route: '/accountant/reports'),
      ],
      selectedIndex: 0,
      body: Column(
        children: [
          // Period Selector
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              border: Border(bottom: BorderSide(color: AppTheme.dividerDark)),
            ),
            child: Row(
              children: [
                const Text(
                  'Period:',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _selectedPeriod,
                  dropdownColor: AppTheme.surfaceDark,
                  items: [
                    DropdownMenuItem(value: 'current_month', child: Text('Current Month')),
                    DropdownMenuItem(value: 'last_month', child: Text('Last Month')),
                    DropdownMenuItem(value: 'current_quarter', child: Text('Current Quarter')),
                    DropdownMenuItem(value: 'last_quarter', child: Text('Last Quarter')),
                    DropdownMenuItem(value: 'current_year', child: Text('Current Year')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedPeriod = value!);
                    _loadDashboardData();
                  },
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _generateVATReturn(),
                  icon: const Icon(Icons.file_download, size: 16),
                  label: const Text('Generate VAT Return'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accountantColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          // Tab Bar
          Container(
            color: AppTheme.cardDark,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.accountantColor,
              labelColor: AppTheme.accountantColor,
              unselectedLabelColor: Colors.white38,
              tabs: const [
                Tab(text: 'Overview', icon: Icon(Icons.dashboard_rounded)),
                Tab(text: 'VAT Returns', icon: Icon(Icons.receipt_long_rounded)),
                Tab(text: 'Expenses', icon: Icon(Icons.money_rounded)),
                Tab(text: 'Transactions', icon: Icon(Icons.list_alt_rounded)),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildVATReturnsTab(),
                _buildExpensesTab(),
                _buildTransactionsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.accountantColor));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key Metrics Cards
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Total Revenue',
                  'NPR ${(_dashboardData['totalRevenue'] ?? 0).toStringAsFixed(2)}',
                  Icons.trending_up_rounded,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'VAT Collected',
                  'NPR ${(_dashboardData['vatCollected'] ?? 0).toStringAsFixed(2)}',
                  Icons.account_balance_rounded,
                  AppTheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Pending Expenses',
                  '${_pendingExpenses.length}',
                  Icons.pending_actions_rounded,
                  Colors.orange,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // VAT Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.accountantColor.withOpacity(0.1),
                  AppTheme.primary.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.accountantColor.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.receipt_long_rounded, color: AppTheme.accountantColor, size: 24),
                    const SizedBox(width: 12),
                    const Text(
                      'VAT Summary',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _tabController.animateTo(1),
                      child: const Text('View Details', style: TextStyle(color: AppTheme.accountantColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildVATSummaryItem('Taxable Sales', _dashboardData['taxableSales'] ?? 0),
                    ),
                    Expanded(
                      child: _buildVATSummaryItem('VAT Rate', '13%'),
                    ),
                    Expanded(
                      child: _buildVATSummaryItem('VAT Amount', _dashboardData['vatAmount'] ?? 0),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Recent Activity
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Activity List
          ...(_dashboardData['recentActivity'] ?? []).map((activity) => _buildActivityItem(activity)).toList(),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildVATSummaryItem(String label, dynamic value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value is String ? value : 'NPR ${value.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(dynamic activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerDark),
      ),
      child: Row(
        children: [
          Icon(
            _getActivityIcon(activity['type']),
            color: _getActivityColor(activity['type']),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['description'] ?? 'Unknown activity',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['timestamp'] != null 
                      ? DateFormat('MMM dd, yyyy HH:mm').format(DateTime.parse(activity['timestamp']))
                      : 'Unknown time',
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
          if (activity['amount'] != null)
            Text(
              'NPR ${activity['amount'].toStringAsFixed(2)}',
              style: TextStyle(
                color: activity['type'] == 'expense' ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'sale':
        return Icons.shopping_cart_rounded;
      case 'expense':
        return Icons.money_off_rounded;
      case 'vat_payment':
        return Icons.account_balance_rounded;
      case 'expense_approval':
        return Icons.check_circle_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'sale':
        return Colors.green;
      case 'expense':
        return Colors.red;
      case 'vat_payment':
        return AppTheme.primary;
      case 'expense_approval':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildVATReturnsTab() {
    return Column(
      children: [
        // VAT Returns Header
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text(
                'VAT Returns',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _generateVATReturn(),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Generate New'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accountantColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        
        // VAT Returns List
        Expanded(
          child: _vatReturns.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 64, color: AppTheme.accountantColor.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      const Text('No VAT returns found', style: TextStyle(color: Colors.white38, fontSize: 18)),
                      const SizedBox(height: 8),
                      const Text('Generate your first VAT return', style: TextStyle(color: Colors.white24, fontSize: 14)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _vatReturns.length,
                  itemBuilder: (context, index) {
                    final vatReturn = _vatReturns[index];
                    return _buildVATReturnCard(vatReturn);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildVATReturnCard(dynamic vatReturn) {
    final status = vatReturn['status'] ?? 'DRAFT';
    final period = vatReturn['period'] ?? 'Unknown';
    final totalAmount = vatReturn['totalAmount'] ?? 0.0;
    final dueDate = vatReturn['dueDate'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getVATReturnStatusColor(status).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // VAT Return Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VAT Return - $period',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: #${vatReturn['id'] ?? 'N/A'}',
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                      if (dueDate != null)
                        Text(
                          'Due: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(dueDate))}',
                          style: const TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                    ],
                  ),
                ),
                
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getVATReturnStatusColor(status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // VAT Return Details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Total VAT Amount',
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                    const Spacer(),
                    Text(
                      'NPR ${totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _viewVATReturnDetails(vatReturn),
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text('View'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.accountantColor,
                          side: BorderSide(color: AppTheme.accountantColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _downloadVATReturn(vatReturn),
                        icon: const Icon(Icons.download, size: 16),
                        label: const Text('Download'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accountantColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    if (status == 'DRAFT') ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _submitVATReturn(vatReturn),
                          icon: const Icon(Icons.send, size: 16),
                          label: const Text('Submit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Color _getVATReturnStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'DRAFT':
        return Colors.grey;
      case 'SUBMITTED':
        return Colors.blue;
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      case 'PAID':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  Widget _buildExpensesTab() {
    return Column(
      children: [
        // Expenses Header
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text(
                'Pending Expense Approvals',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_pendingExpenses.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Pending Expenses List
        Expanded(
          child: _pendingExpenses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 64, color: Colors.green.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      const Text('No pending expenses', style: TextStyle(color: Colors.white38, fontSize: 18)),
                      const SizedBox(height: 8),
                      const Text('All expenses have been processed', style: TextStyle(color: Colors.white24, fontSize: 14)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pendingExpenses.length,
                  itemBuilder: (context, index) {
                    final expense = _pendingExpenses[index];
                    return _buildExpenseCard(expense);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildExpenseCard(dynamic expense) {
    final mr = expense['mr'] ?? {};
    final amount = expense['amount'] ?? 0.0;
    final category = expense['category'] ?? 'Unknown';
    final description = expense['description'] ?? '';
    final receipts = expense['receipts'] ?? [];
    final submittedDate = expense['submittedDate'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Expense Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.mrColor.withOpacity(0.15),
                  child: Icon(Icons.person_rounded, color: AppTheme.mrColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mr['name'] ?? 'Unknown MR',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Employee Code: ${mr['employeeCode'] ?? 'N/A'}',
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'NPR ${amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category,
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Expense Details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (description.isNotEmpty) ...[
                  Text(
                    description,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Receipts
                if (receipts.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.receipt_rounded, size: 16, color: Colors.white38),
                      const SizedBox(width: 8),
                      Text(
                        '${receipts.length} receipt${receipts.length > 1 ? 's' : ''}',
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => _viewExpenseReceipts(expense),
                        child: const Text('View Receipts', style: TextStyle(color: AppTheme.accountantColor)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Date
                Row(
                  children: [
                    Icon(Icons.schedule_rounded, size: 16, color: Colors.white38),
                    const SizedBox(width: 8),
                    Text(
                      submittedDate != null 
                          ? DateFormat('MMM dd, yyyy').format(DateTime.parse(submittedDate))
                          : 'Unknown date',
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _approveExpense(expense),
                        icon: const Icon(Icons.check_circle, size: 16),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _rejectExpense(expense),
                        icon: const Icon(Icons.cancel, size: 16),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab() {
    return Column(
      children: [
        // Transactions Header
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text(
                'All Transactions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _exportTransactions(),
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Export'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accountantColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        
        // Transactions List
        Expanded(
          child: _transactions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.list_alt_outlined, size: 64, color: AppTheme.accountantColor.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      const Text('No transactions found', style: TextStyle(color: Colors.white38, fontSize: 18)),
                      const SizedBox(height: 8),
                      const Text('Transactions will appear here', style: TextStyle(color: Colors.white24, fontSize: 14)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = _transactions[index];
                    return _buildTransactionCard(transaction);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(dynamic transaction) {
    final type = transaction['type'] ?? 'Unknown';
    final amount = transaction['amount'] ?? 0.0;
    final description = transaction['description'] ?? '';
    final date = transaction['date'];
    final reference = transaction['reference'] ?? '';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerDark),
      ),
      child: Row(
        children: [
          Icon(
            _getTransactionIcon(type),
            color: _getTransactionColor(type),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '$type • $reference',
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
                if (date != null)
                  Text(
                    DateFormat('MMM dd, yyyy HH:mm').format(DateTime.parse(date)),
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
              ],
            ),
          ),
          Text(
            '${type == 'credit' ? '+' : '-'}NPR ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: type == 'credit' ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTransactionIcon(String type) {
    switch (type.toLowerCase()) {
      case 'sale':
        return Icons.shopping_cart_rounded;
      case 'expense':
        return Icons.money_off_rounded;
      case 'vat_payment':
        return Icons.account_balance_rounded;
      case 'refund':
        return Icons.refresh_rounded;
      default:
        return Icons.swap_horiz_rounded;
    }
  }

  Color _getTransactionColor(String type) {
    switch (type.toLowerCase()) {
      case 'sale':
      case 'vat_payment':
      case 'refund':
        return Colors.green;
      case 'expense':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _generateVATReturn() async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      
      final response = await dio.post(
        '${ApiConfig.baseUrl}/accountant/vat-returns/generate',
        data: { period: _selectedPeriod },
        options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}),
      );
      
      if (response.data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('VAT return generated successfully'),
            backgroundColor: AppTheme.success,
          ),
        );
        _loadDashboardData(); // Refresh data
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating VAT return: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  void _viewVATReturnDetails(dynamic vatReturn) {
    // Show VAT return details dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: const Text(
          'VAT Return Details',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Return ID', '#${vatReturn['id']}'),
              _buildDetailRow('Period', vatReturn['period'] ?? 'N/A'),
              _buildDetailRow('Status', vatReturn['status'] ?? 'N/A'),
              _buildDetailRow('Total Amount', 'NPR ${(vatReturn['totalAmount'] ?? 0).toStringAsFixed(2)}'),
              _buildDetailRow('Taxable Sales', 'NPR ${(vatReturn['taxableSales'] ?? 0).toStringAsFixed(2)}'),
              _buildDetailRow('VAT Rate', '${vatReturn['vatRate'] ?? 13}%'),
              _buildDetailRow('Created Date', vatReturn['createdAt'] != null 
                  ? DateFormat('MMM dd, yyyy').format(DateTime.parse(vatReturn['createdAt']))
                  : 'N/A'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _downloadVATReturn(vatReturn);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accountantColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  void _downloadVATReturn(dynamic vatReturn) async {
    // Generate and download PDF
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 0,
              child: pw.Text('VAT Return - ${vatReturn['period']}'),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Return ID: #${vatReturn['id']}'),
            pw.Text('Status: ${vatReturn['status']}'),
            pw.Text('Total VAT Amount: NPR ${(vatReturn['totalAmount'] ?? 0).toStringAsFixed(2)}'),
            // Add more VAT return details
          ],
        ),
      ),
    );
    
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'vat_return_${vatReturn['id']}.pdf',
    );
  }

  void _submitVATReturn(dynamic vatReturn) async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      
      await dio.post(
        '${ApiConfig.baseUrl}/accountant/vat-returns/${vatReturn['id']}/submit',
        options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}),
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('VAT return submitted successfully'),
          backgroundColor: AppTheme.success,
        ),
      );
      _loadDashboardData(); // Refresh data
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting VAT return: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  void _viewExpenseReceipts(dynamic expense) {
    // Show expense receipts dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: const Text(
          'Expense Receipts',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: (expense['receipts'] ?? []).map((receipt) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.receipt_rounded, color: AppTheme.accountantColor, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        receipt['fileName'] ?? 'Unknown receipt',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _downloadReceipt(receipt),
                      icon: const Icon(Icons.download, color: AppTheme.accountantColor),
                    ),
                  ],
                ),
              ),
            )).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.white38)),
          ),
        ],
      ),
    );
  }

  void _downloadReceipt(dynamic receipt) {
    // Download receipt logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Downloading receipt...'),
        backgroundColor: AppTheme.accountantColor,
      ),
    );
  }

  void _approveExpense(dynamic expense) async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      
      await dio.post(
        '${ApiConfig.baseUrl}/accountant/expenses/${expense['id']}/approve',
        options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}),
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expense approved successfully'),
          backgroundColor: AppTheme.success,
        ),
      );
      _loadDashboardData(); // Refresh data
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error approving expense: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  void _rejectExpense(dynamic expense) async {
    // Show rejection reason dialog
    final TextEditingController reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: const Text(
          'Reject Expense',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: reasonController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Rejection Reason',
            labelStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: AppTheme.surfaceDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                final auth = context.read<AuthProvider>();
                final dio = Dio();
                
                await dio.post(
                  '${ApiConfig.baseUrl}/accountant/expenses/${expense['id']}/reject',
                  data: { reason: reasonController.text },
                  options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}),
                );
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Expense rejected'),
                    backgroundColor: AppTheme.success,
                  ),
                );
                _loadDashboardData(); // Refresh data
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error rejecting expense: $e'),
                    backgroundColor: AppTheme.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _exportTransactions() async {
    // Export transactions to CSV/Excel
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exporting transactions...'),
        backgroundColor: AppTheme.accountantColor,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white38, fontSize: 14),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

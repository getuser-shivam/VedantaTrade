import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_trade/app/theme/enhanced_app_theme.dart';
import 'package:vedanta_trade/shared/widgets/enhanced_ui_components.dart';
import 'package:vedanta_trade/features/auth/presentation/providers/auth_provider.dart';
import 'package:vedanta_trade/features/accounting/presentation/providers/accounting_provider.dart';
import 'package:vedanta_trade/features/accounting/widgets/vat_return_widget.dart';
import 'package:vedanta_trade/features/accounting/widgets/expense_reconciliation_widget.dart';
import 'package:vedanta_trade/features/accounting/widgets/financial_summary_widget.dart';
import 'package:intl/intl.dart';

class AccountantDashboard extends StatefulWidget {
  const AccountantDashboard({super.key});

  @override
  State<AccountantDashboard> createState() => _AccountantDashboardState();
}

class _AccountantDashboardState extends State<AccountantDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeAnimations();
    _loadData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final accountingProvider = context.read<AccountingProvider>();
    await accountingProvider.loadFinancialSummary();
    await accountingProvider.loadVatReturns();
    await accountingProvider.loadExpenseReports();
    await accountingProvider.loadMrExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EnhancedAppTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildHeaderStats(),
                _buildTabBar(),
                Expanded(
                  child: _buildTabBarView(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: EnhancedAppTheme.surfaceColor,
      elevation: 0,
      title: Text(
        'Accountant Dashboard',
        style: TextStyle(
          color: EnhancedAppTheme.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.download,
            color: EnhancedAppTheme.textPrimary,
          ),
          onPressed: _exportFinancialReport,
        ),
        IconButton(
          icon: Icon(
            Icons.refresh,
            color: EnhancedAppTheme.textPrimary,
          ),
          onPressed: _refreshData,
        ),
      ],
    );
  }

  Widget _buildHeaderStats() {
    return Consumer<AccountingProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Revenue',
                      'NPR ${NumberFormat('#,##0.00').format(provider.totalRevenue)}',
                      Icons.trending_up,
                      EnhancedAppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'VAT Collected',
                      'NPR ${NumberFormat('#,##0.00').format(provider.vatCollected)}',
                      Icons.account_balance,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Pending Expenses',
                      'NPR ${NumberFormat('#,##0.00').format(provider.pendingExpenses)}',
                      Icons.pending_actions,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Net Profit',
                      'NPR ${NumberFormat('#,##0.00').format(provider.netProfit)}',
                      Icons.attach_money,
                      provider.netProfit >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return EnhancedUIComponents.glassmorphicCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: EnhancedAppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: EnhancedAppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: EnhancedAppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: EnhancedAppTheme.primaryColor,
        labelColor: EnhancedAppTheme.primaryColor,
        unselectedLabelColor: EnhancedAppTheme.textSecondary,
        tabs: const [
          Tab(text: 'Summary'),
          Tab(text: 'VAT Returns'),
          Tab(text: 'Expenses'),
          Tab(text: 'MR Expenses'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildSummaryTab(),
        _buildVatReturnsTab(),
        _buildExpensesTab(),
        _buildMrExpensesTab(),
      ],
    );
  }

  Widget _buildSummaryTab() {
    return Consumer<AccountingProvider>(
      builder: (context, provider, child) {
        return FinancialSummaryWidget(
          summary: provider.financialSummary,
          onExport: _exportFinancialReport,
        );
      },
    );
  }

  Widget _buildVatReturnsTab() {
    return Consumer<AccountingProvider>(
      builder: (context, provider, child) {
        return VatReturnWidget(
          vatReturns: provider.vatReturns,
          onGenerateVatReturn: _generateVatReturn,
          onExportVatReturn: _exportVatReturn,
        );
      },
    );
  }

  Widget _buildExpensesTab() {
    return Consumer<AccountingProvider>(
      builder: (context, provider, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.expenseReports.length,
          itemBuilder: (context, index) {
            final expense = provider.expenseReports[index];
            return _buildExpenseCard(expense);
          },
        );
      },
    );
  }

  Widget _buildExpenseCard(Map<String, dynamic> expense) {
    return EnhancedUIComponents.glassmorphicCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  expense['description'],
                  style: TextStyle(
                    color: EnhancedAppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getExpenseStatusColor(expense['status']).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  expense['status'].toString().toUpperCase(),
                  style: TextStyle(
                    color: _getExpenseStatusColor(expense['status']),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category: ${expense['category']}',
                      style: TextStyle(
                        color: EnhancedAppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Date: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(expense['date']))}',
                      style: TextStyle(
                        color: EnhancedAppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'NPR ${NumberFormat('#,##0.00').format(expense['amount'])}',
                    style: TextStyle(
                      color: EnhancedAppTheme.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (expense['vatAmount'] != null && expense['vatAmount'] > 0)
                    Text(
                      'VAT: NPR ${NumberFormat('#,##0.00').format(expense['vatAmount'])}',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ],
          ),
          if (expense['receiptImages'] != null && expense['receiptImages'].isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Receipts:',
                  style: TextStyle(
                    color: EnhancedAppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: expense['receiptImages'].length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 60,
                        height: 60,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: EnhancedAppTheme.glassBorderColor,
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            expense['receiptImages'][index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: EnhancedAppTheme.surfaceColor,
                                child: Icon(
                                  Icons.receipt,
                                  color: EnhancedAppTheme.textSecondary,
                                  size: 24,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: EnhancedUIComponents.enhancedButton(
                  child: const Text('Approve'),
                  onPressed: () => _approveExpense(expense['id']),
                  backgroundColor: Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: EnhancedUIComponents.enhancedButton(
                  child: const Text('Reject'),
                  onPressed: () => _rejectExpense(expense['id']),
                  backgroundColor: Colors.red,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: EnhancedUIComponents.enhancedButton(
                  child: const Text('Details'),
                  onPressed: () => _showExpenseDetails(expense),
                  backgroundColor: EnhancedAppTheme.secondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMrExpensesTab() {
    return Consumer<AccountingProvider>(
      builder: (context, provider, child) {
        return ExpenseReconciliationWidget(
          expenses: provider.mrExpenses,
          onApproveExpense: _approveMrExpense,
          onRejectExpense: _rejectMrExpense,
          onViewDetails: _showMrExpenseDetails,
        );
      },
    );
  }

  Color _getExpenseStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _exportFinancialReport() {
    
    EnhancedUIComponents.showEnhancedSnackbar(
      context: context,
      message: 'Exporting financial report...',
      icon: Icons.download,
    );
  }

  void _refreshData() {
    _loadData();
  }

  void _generateVatReturn() {
    
    EnhancedUIComponents.showEnhancedSnackbar(
      context: context,
      message: 'Generating VAT return...',
      icon: Icons.file_download,
    );
  }

  void _exportVatReturn(String vatReturnId) {
    
    EnhancedUIComponents.showEnhancedSnackbar(
      context: context,
      message: 'Exporting VAT return...',
      icon: Icons.file_download,
    );
  }

  void _approveExpense(String expenseId) {
    
    EnhancedUIComponents.showEnhancedSnackbar(
      context: context,
      message: 'Expense approved',
      icon: Icons.check_circle,
    );
  }

  void _rejectExpense(String expenseId) {
    
    EnhancedUIComponents.showEnhancedSnackbar(
      context: context,
      message: 'Expense rejected',
      icon: Icons.cancel,
    );
  }

  void _showExpenseDetails(Map<String, dynamic> expense) {
    
  }

  void _approveMrExpense(String expenseId) {
    
    EnhancedUIComponents.showEnhancedSnackbar(
      context: context,
      message: 'MR expense approved',
      icon: Icons.check_circle,
    );
  }

  void _rejectMrExpense(String expenseId) {
    
    EnhancedUIComponents.showEnhancedSnackbar(
      context: context,
      message: 'MR expense rejected',
      icon: Icons.cancel,
    );
  }

  void _showMrExpenseDetails(Map<String, dynamic> expense) {
    
  }
}

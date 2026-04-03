import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';
import 'package:vedanta_trade/shared/app_scaffold.dart';
import 'package:vedanta_trade/shared/widgets/glassmorphic_widgets.dart';
import 'package:vedanta_trade/features/auth/presentation/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:vedanta_trade/core/api_config.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:file_picker/file_picker.dart';
import 'package:vedanta_trade/features/accountant/widgets/vat_report_card.dart';
import 'package:vedanta_trade/features/accountant/widgets/expense_reconciliation_card.dart';

/// Accountant Dashboard with VAT Returns and Expense Reconciliation
class AccountantDashboard extends StatefulWidget {
  const AccountantDashboard({Key? key}) : super(key: key);

  @override
  _AccountantDashboardState createState() => _AccountantDashboardState();
}

class _AccountantDashboardState extends State<AccountantDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = true;
  Map<String, dynamic>? _stats;
  List<dynamic> _vatReturns = [];
  List<dynamic> _expenses = [];
  List<dynamic> _reconciliations = [];

  static const _navItems = [
    NavItem(label: 'Dashboard', icon: Icons.dashboard_rounded, route: '/accountant'),
    NavItem(label: 'VAT Returns', icon: Icons.receipt_long_rounded, route: '/accountant/vat'),
    NavItem(label: 'Expenses', icon: Icons.money_off_rounded, route: '/accountant/expenses'),
    NavItem(label: 'Reports', icon: Icons.analytics_rounded, route: '/accountant/reports'),
    NavItem(label: 'Settings', icon: Icons.settings_rounded, route: '/accountant/settings'),
    NavItem(label: 'Profile', icon: Icons.person_rounded, route: '/profile'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    
    try {
      await Future.wait([
        _loadStats(),
        _loadVatReturns(),
        _loadExpenses(),
        _loadReconciliations(),
      ]);
    } catch (e) {
      _showErrorSnackBar('Failed to load data: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadStats() async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      
      final res = await dio.get(
        '${ApiConfig.baseUrl}/accountant/dashboard',
        options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}),
      );
      
      if (mounted) {
        setState(() {
          _stats = res.data['data'] ?? {
            'totalVatCollected': 0,
            'pendingExpenses': 0,
            'totalReconciliations': 0,
            'currentQuarter': 'Q1 2026',
          };
        });
      }
    } catch (e) {
      debugPrint('Error loading stats: $e');
      // Set default stats
      if (mounted) {
        setState(() {
          _stats = {
            'totalVatCollected': 125000,
            'pendingExpenses': 8,
            'totalReconciliations': 45,
            'currentQuarter': 'Q1 2026',
          };
        });
      }
    }
  }

  Future<void> _loadVatReturns() async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      
      final res = await dio.get(
        '${ApiConfig.baseUrl}/accountant/vat-returns',
        options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}),
      );
      
      if (mounted) {
        setState(() {
          _vatReturns = res.data['data'] ?? [
            {
              'id': 'VAT001',
              'period': 'Q1 2026',
              'totalSales': 2500000,
              'vatAmount': 325000,
              'status': 'filed',
              'filedDate': DateTime.now().subtract(const Duration(days: 15)),
              'dueDate': DateTime.now().add(const Duration(days: 15)),
            },
            {
              'id': 'VAT002',
              'period': 'Q4 2025',
              'totalSales': 2100000,
              'vatAmount': 273000,
              'status': 'pending',
              'filedDate': null,
              'dueDate': DateTime.now().subtract(const Duration(days: 5)),
            },
          ];
        });
      }
    } catch (e) {
      debugPrint('Error loading VAT returns: $e');
    }
  }

  Future<void> _loadExpenses() async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      
      final res = await dio.get(
        '${ApiConfig.baseUrl}/accountant/expenses',
        options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}),
      );
      
      if (mounted) {
        setState(() {
          _expenses = res.data['data'] ?? [
            {
              'id': 'EXP001',
              'mrName': 'Ramesh Kumar',
              'amount': 2500,
              'category': 'Travel',
              'description': 'Field visit to Janakpur region',
              'date': DateTime.now().subtract(const Duration(days: 2)),
              'status': 'pending',
              'receiptCount': 3,
            },
            {
              'id': 'EXP002',
              'mrName': 'Sita Sharma',
              'amount': 1800,
              'category': 'Meals',
              'description': 'Client meeting expenses',
              'date': DateTime.now().subtract(const Duration(days: 1)),
              'status': 'approved',
              'receiptCount': 2,
            },
          ];
        });
      }
    } catch (e) {
      debugPrint('Error loading expenses: $e');
    }
  }

  Future<void> _loadReconciliations() async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      
      final res = await dio.get(
        '${ApiConfig.baseUrl}/accountant/reconciliations',
        options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}),
      );
      
      if (mounted) {
        setState(() {
          _reconciliations = res.data['data'] ?? [
            {
              'id': 'REC001',
              'mrName': 'Ramesh Kumar',
              'period': 'March 2026',
              'totalExpenses': 15000,
              'approvedAmount': 14200,
              'status': 'completed',
              'reconciledDate': DateTime.now().subtract(const Duration(days: 1)),
            },
          ];
        });
      }
    } catch (e) {
      debugPrint('Error loading reconciliations: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _loadData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Accountant Dashboard',
      roleColor: AppTheme.accountantColor,
      navItems: _navItems,
      selectedIndex: 0,
      fab: FloatingActionButton.extended(
        onPressed: () => _generateVatReport(),
        backgroundColor: AppTheme.accountantColor,
        icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
        label: const Text('VAT Report', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: LoadingAnimation())
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppTheme.accountantColor,
              child: Column(
                children: [
                  // Stats Cards
                  _buildStatsCards(),
                  const SizedBox(height: 20),

                  // Quick Actions
                  _buildQuickActions(),
                  const SizedBox(height: 20),

                  // Tabs
                  _buildTabs(),
                  const SizedBox(height: 20),

                  // Tab Content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildVatReturnsTab(),
                        _buildExpensesTab(),
                        _buildReconciliationsTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: GlassmorphicStatCard(
              title: 'VAT Collected',
              value: 'NPR ${(_stats?['totalVatCollected'] ?? 0).toString()}',
              icon: Icons.receipt_long_rounded,
              color: AppTheme.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GlassmorphicStatCard(
              title: 'Pending Expenses',
              value: '${_stats?['pendingExpenses'] ?? 0}',
              icon: Icons.pending_rounded,
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GlassmorphicStatCard(
              title: 'Reconciliations',
              value: '${_stats?['totalReconciliations'] ?? 0}',
              icon: Icons.account_balance_rounded,
              color: AppTheme.accountantColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _QuickActionCard(
              icon: Icons.picture_as_pdf,
              label: 'VAT Report',
              color: AppTheme.accountantColor,
              onTap: () => _generateVatReport(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickActionCard(
              icon: Icons.approval_rounded,
              label: 'Approve Expenses',
              color: AppTheme.success,
              onTap: () => _tabController.animateTo(1),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickActionCard(
              icon: Icons.analytics_rounded,
              label: 'Analytics',
              color: AppTheme.info,
              onTap: () => _showAnalytics(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppTheme.accountantColor,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        tabs: const [
          Tab(text: 'VAT Returns'),
          Tab(text: 'Expenses'),
          Tab(text: 'Reconciliations'),
        ],
      ),
    );
  }

  Widget _buildVatReturnsTab() {
    return Column(
      children: [
        // Current Quarter Info
        _buildCurrentQuarterInfo(),
        const SizedBox(height: 16),

        // VAT Returns List
        Expanded(
          child: _vatReturns.isEmpty
              ? _buildEmptyState('No VAT returns found', Icons.receipt_long_outlined)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _vatReturns.length,
                  itemBuilder: (context, index) {
                    final vatReturn = _vatReturns[index];
                    return VatReportCard(
                      vatReturn: vatReturn,
                      onTap: () => _showVatReturnDetails(vatReturn),
                      onGeneratePdf: () => _generateVatReturnPdf(vatReturn),
                      onFile: () => _fileVatReturn(vatReturn),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCurrentQuarterInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassmorphicCard(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accountantColor.withOpacity(0.2),
                    AppTheme.accountantColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.calendar_today, color: AppTheme.accountantColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Quarter',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    _stats?['currentQuarter'] ?? 'Q1 2026',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.success.withOpacity(0.2),
                    AppTheme.success.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.success.withOpacity(0.3)),
              ),
              child: Text(
                '13% VAT',
                style: TextStyle(
                  color: AppTheme.success,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesTab() {
    return Column(
      children: [
        // Expense Filters
        _buildExpenseFilters(),
        const SizedBox(height: 16),

        // Expenses List
        Expanded(
          child: _expenses.isEmpty
              ? _buildEmptyState('No expenses found', Icons.money_off_outlined)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _expenses.length,
                  itemBuilder: (context, index) {
                    final expense = _expenses[index];
                    return ExpenseReconciliationCard(
                      expense: expense,
                      onTap: () => _showExpenseDetails(expense),
                      onApprove: () => _approveExpense(expense['id']),
                      onReject: () => _rejectExpense(expense['id']),
                      onViewReceipts: () => _viewExpenseReceipts(expense),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildExpenseFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: 'All',
              isSelected: true,
              onTap: () {},
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Pending',
              isSelected: false,
              onTap: () {},
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Approved',
              isSelected: false,
              onTap: () {},
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Rejected',
              isSelected: false,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReconciliationsTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Search Bar
          TextField(
            style: const TextStyle(color: Colors.white),
            decoration: AppTheme.inputDecoration('Search reconciliations...'),
          ),
          const SizedBox(height: 16),

          // Reconciliations List
          Expanded(
            child: _reconciliations.isEmpty
                ? _buildEmptyState('No reconciliations found', Icons.account_balance_outlined)
                : ListView.builder(
                    itemCount: _reconciliations.length,
                    itemBuilder: (context, index) {
                      final reconciliation = _reconciliations[index];
                      return _ReconciliationCard(
                        reconciliation: reconciliation,
                        onTap: () => _showReconciliationDetails(reconciliation),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.white38),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: Colors.white38, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  void _generateVatReport() async {
    try {
      // Generate comprehensive VAT report
      final pdf = await _createVatReportPdf();
      
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'VAT_Report_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } catch (e) {
      _showErrorSnackBar('Failed to generate VAT report: $e');
    }
  }

  Future<pw.Document> _createVatReportPdf() async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: pw.PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('VAT Report - ${_stats?['currentQuarter'] ?? 'Q1 2026'}'),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Total VAT Collected: NPR ${_stats?['totalVatCollected'] ?? 0}'),
              pw.Text('Generated on: ${DateFormat('yyyy-MM-dd').format(DateTime.now())'),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                context: context,
                data: <List<String>>[
                  ['Period', 'Sales', 'VAT (13%)', 'Status'],
                  ['Q1 2026', '2,500,000', '325,000', 'Filed'],
                  ['Q4 2025', '2,100,000', '273,000', 'Pending'],
                ],
              ),
            ],
          );
        },
      ),
    );
    
    return pdf;
  }

  void _showVatReturnDetails(Map<String, dynamic> vatReturn) {
    showDialog(
      context: context,
      builder: (context) => _VatReturnDetailsDialog(vatReturn: vatReturn),
    );
  }

  void _generateVatReturnPdf(Map<String, dynamic> vatReturn) async {
    try {
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.Page(
          pageFormat: pw.PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text('VAT Return - ${vatReturn['period']}'),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Return ID: ${vatReturn['id']}'),
                pw.Text('Total Sales: NPR ${vatReturn['totalSales']}'),
                pw.Text('VAT Amount: NPR ${vatReturn['vatAmount']}'),
                pw.Text('Status: ${vatReturn['status']}'),
                pw.Text('Generated on: ${DateFormat('yyyy-MM-dd').format(DateTime.now())'),
              ],
            );
          },
        ),
      );
      
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'VAT_Return_${vatReturn['id']}.pdf',
      );
    } catch (e) {
      _showErrorSnackBar('Failed to generate PDF: $e');
    }
  }

  void _fileVatReturn(Map<String, dynamic> vatReturn) async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      
      await dio.post(
        '${ApiConfig.baseUrl}/accountant/vat-returns/${vatReturn['id']}/file',
        options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}),
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('VAT return ${vatReturn['id']} filed successfully'),
          backgroundColor: AppTheme.success,
        ),
      );
      
      await _loadVatReturns();
    } catch (e) {
      _showErrorSnackBar('Failed to file VAT return: $e');
    }
  }

  void _showExpenseDetails(Map<String, dynamic> expense) {
    showDialog(
      context: context,
      builder: (context) => _ExpenseDetailsDialog(expense: expense),
    );
  }

  void _approveExpense(String expenseId) async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      
      await dio.patch(
        '${ApiConfig.baseUrl}/accountant/expenses/$expenseId/approve',
        options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}),
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Expense $expenseId approved'),
          backgroundColor: AppTheme.success,
        ),
      );
      
      await _loadExpenses();
    } catch (e) {
      _showErrorSnackBar('Failed to approve expense: $e');
    }
  }

  void _rejectExpense(String expenseId) async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      
      await dio.patch(
        '${ApiConfig.baseUrl}/accountant/expenses/$expenseId/reject',
        options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}),
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Expense $expenseId rejected'),
          backgroundColor: AppTheme.error,
        ),
      );
      
      await _loadExpenses();
    } catch (e) {
      _showErrorSnackBar('Failed to reject expense: $e');
    }
  }

  void _viewExpenseReceipts(Map<String, dynamic> expense) {
    // TODO: Implement receipt viewing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('View ${expense['receiptCount']} receipts')),
    );
  }

  void _showReconciliationDetails(Map<String, dynamic> reconciliation) {
    showDialog(
      context: context,
      builder: (context) => _ReconciliationDetailsDialog(reconciliation: reconciliation),
    );
  }

  void _showAnalytics() {
    // TODO: Navigate to analytics screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Analytics functionality')),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassmorphicCard(
        height: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.2),
                    color.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [AppTheme.accountantColor, AppTheme.accountantColor.withOpacity(0.8)])
              : LinearGradient(colors: [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.02)]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.accountantColor : Colors.white.withOpacity(0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _VatReturnDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> vatReturn;

  const _VatReturnDetailsDialog({required this.vatReturn});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.cardColor.withOpacity(0.95),
              AppTheme.cardColor.withOpacity(0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.accountantColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: AppTheme.accountantColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'VAT Return Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Return ID', vatReturn['id']),
            _buildDetailRow('Period', vatReturn['period']),
            _buildDetailRow('Total Sales', 'NPR ${vatReturn['totalSales']}'),
            _buildDetailRow('VAT Amount', 'NPR ${vatReturn['vatAmount']}'),
            _buildDetailRow('Status', vatReturn['status']),
            _buildDetailRow('Due Date', DateFormat('yyyy-MM-dd').format(vatReturn['dueDate'])),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Close', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            '$label:',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> expense;

  const _ExpenseDetailsDialog({required this.expense});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.cardColor.withOpacity(0.95),
              AppTheme.cardColor.withOpacity(0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.accountantColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.money_off, color: AppTheme.accountantColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Expense Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Expense ID', expense['id']),
            _buildDetailRow('MR Name', expense['mrName']),
            _buildDetailRow('Amount', 'NPR ${expense['amount']}'),
            _buildDetailRow('Category', expense['category']),
            _buildDetailRow('Description', expense['description']),
            _buildDetailRow('Date', DateFormat('yyyy-MM-dd').format(expense['date'])),
            _buildDetailRow('Receipts', '${expense['receiptCount']} files'),
            _buildDetailRow('Status', expense['status']),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Close', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            '$label:',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReconciliationCard extends StatelessWidget {
  final Map<String, dynamic> reconciliation;
  final VoidCallback onTap;

  const _ReconciliationCard({
    required this.reconciliation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassmorphicCard(
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
                        reconciliation['mrName'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Reconciliation #${reconciliation['id']}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.success.withOpacity(0.2),
                        AppTheme.success.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.success.withOpacity(0.3)),
                  ),
                  child: Text(
                    reconciliation['status'].toUpperCase(),
                    style: TextStyle(
                      color: AppTheme.success,
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
                Expanded(
                  child: _InfoRow(
                    icon: Icons.calendar_today,
                    label: reconciliation['period'],
                    color: Colors.white54,
                  ),
                ),
                Expanded(
                  child: _InfoRow(
                    icon: Icons.monetization_on,
                    label: 'NPR ${reconciliation['totalExpenses']}',
                    color: AppTheme.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _InfoRow(
                    icon: Icons.check_circle,
                    label: 'Approved: NPR ${reconciliation['approvedAmount']}',
                    color: AppTheme.info,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReconciliationDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> reconciliation;

  const _ReconciliationDetailsDialog({required this.reconciliation});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.cardColor.withOpacity(0.95),
              AppTheme.cardColor.withOpacity(0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.accountantColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance, color: AppTheme.accountantColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Reconciliation Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Reconciliation ID', reconciliation['id']),
            _buildDetailRow('MR Name', reconciliation['mrName']),
            _buildDetailRow('Period', reconciliation['period']),
            _buildDetailRow('Total Expenses', 'NPR ${reconciliation['totalExpenses']}'),
            _buildDetailRow('Approved Amount', 'NPR ${reconciliation['approvedAmount']}'),
            _buildDetailRow('Status', reconciliation['status']),
            _buildDetailRow('Reconciled Date', DateFormat('yyyy-MM-dd').format(reconciliation['reconciledDate'])),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Close', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            '$label:',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

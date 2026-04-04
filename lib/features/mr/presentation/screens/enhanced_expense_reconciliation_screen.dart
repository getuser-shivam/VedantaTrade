import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../shared/widgets/premium_glassmorphic_theme.dart';
import '../../../../shared/widgets/enhanced_animations.dart';
import '../../../../shared/utils/nepal_localization_utils.dart';
import '../../../../shared/utils/error_handling_utils.dart';
import '../../data/services/expense_reconciliation_service.dart';
import '../providers/expense_reconciliation_provider.dart';
import '../widgets/expense_summary_card.dart';
import '../widgets/expense_list_widget.dart';
import '../widgets/add_expense_form.dart';
import '../widgets/expense_photo_viewer.dart';

/// Enhanced MR Expense Reconciliation Screen with Multi-Photo Receipts
class EnhancedExpenseReconciliationScreen extends StatefulWidget {
  const EnhancedExpenseReconciliationScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedExpenseReconciliationScreen> createState() => _EnhancedExpenseReconciliationScreenState();
}

class _EnhancedExpenseReconciliationScreenState extends State<EnhancedExpenseReconciliationScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  String _selectedStatus = 'all';
  String _searchQuery = '';
  ExpenseCategory? _selectedCategory;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 4, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
    
    // Initialize expense reconciliation service and load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _initializeData() {
    context.read<ExpenseReconciliationProvider>().initialize();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    try {
      await Future.wait([
        context.read<ExpenseReconciliationProvider>().loadExpenses(),
        context.read<ExpenseReconciliationProvider>().calculateExpenseSummary(),
      ]);
    } catch (e) {
      ErrorHandlingUtils.showErrorSnackBar(
        context,
        'Failed to load expenses: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildBody(),
            ),
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expense Reconciliation',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'Multi-Photo Receipt Management',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
      backgroundColor: PremiumGlassmorphicTheme.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              PremiumGlassmorphicTheme.primaryColor,
              PremiumGlassmorphicTheme.secondaryColor,
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadExpenses,
          tooltip: 'Refresh Data',
        ),
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: _showFilterDialog,
          tooltip: 'Filter Expenses',
        ),
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(Icons.download),
                  SizedBox(width: 8),
                  Text('Export Report'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings),
                  SizedBox(width: 8),
                  Text('Settings'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'help',
              child: Row(
                children: [
                  Icon(Icons.help_outline),
                  SizedBox(width: 8),
                  Text('Help'),
                ],
              ),
            ),
          ],
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.7),
        tabs: const [
          Tab(
            icon: Icon(Icons.dashboard),
            text: 'Dashboard',
          ),
          Tab(
            icon: Icon(Icons.pending_actions),
            text: 'Pending',
          ),
          Tab(
            icon: Icon(Icons.approval),
            text: 'Approved',
          ),
          Tab(
            icon: Icon(Icons.add),
            text: 'Add Expense',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildDashboardTab(),
        _buildPendingTab(),
        _buildApprovedTab(),
        _buildAddExpenseTab(),
      ],
    );
  }

  Widget _buildDashboardTab() {
    return Consumer<ExpenseReconciliationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading expense data',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.red[400],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.errorMessage ?? 'Unknown error occurred',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _loadExpenses,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PremiumGlassmorphicTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Expense Summary Card
              EnhancedAnimations.slideIn(
                child: ExpenseSummaryCard(
                  summary: provider.currentSummary,
                  onTap: () => _showExpenseSummaryDetails(provider.currentSummary),
                ),
                delay: const Duration(milliseconds: 100),
              ),
              
              const SizedBox(height: 16),
              
              // Quick Stats
              EnhancedAnimations.slideIn(
                child: _buildQuickStats(provider),
                delay: const Duration(milliseconds: 200),
              ),
              
              const SizedBox(height: 16),
              
              // Recent Expenses
              EnhancedAnimations.slideIn(
                child: _buildRecentExpenses(provider),
                delay: const Duration(milliseconds: 300),
              ),
              
              const SizedBox(height: 16),
              
              // Category Breakdown
              EnhancedAnimations.slideIn(
                child: _buildCategoryBreakdown(provider),
                delay: const Duration(milliseconds: 400),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickStats(ExpenseReconciliationProvider provider) {
    final summary = provider.currentSummary;
    if (summary == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Statistics',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: PremiumGlassmorphicTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Expenses',
                  summary.totalExpenses.toString(),
                  Icons.receipt_long,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Total Amount',
                  summary.formattedTotalAmount,
                  Icons.account_balance_wallet,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Pending',
                  summary.formattedPendingAmount,
                  Icons.pending_actions,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Approved',
                  summary.formattedApprovedAmount,
                  Icons.approval,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentExpenses(ExpenseReconciliationProvider provider) {
    final recentExpenses = provider.expenses.take(5).toList();
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Expenses',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: PremiumGlassmorphicTheme.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => _tabController.animateTo(1),
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: PremiumGlassmorphicTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (recentExpenses.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No expenses found',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            ...recentExpenses.map((expense) => _buildExpenseItem(expense)),
        ],
      ),
    );
  }

  Widget _buildExpenseItem(Expense expense) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                expense.description,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: PremiumGlassmorphicTheme.textPrimary,
                ),
              ),
              _buildStatusChip(expense.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Amount: ${expense.formattedAmount}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Category: ${expense.category.toString().split('.').last}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          if (expense.hasPhotos) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.photo, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${expense.receiptPhotos.length} receipt photos',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                expense.formattedDate,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility, size: 16),
                    onPressed: () => _viewExpense(expense),
                    tooltip: 'View Details',
                  ),
                  if (expense.isPending) ...[
                    IconButton(
                      icon: const Icon(Icons.approve, size: 16),
                      onPressed: () => _approveExpense(expense),
                      tooltip: 'Approve',
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () => _rejectExpense(expense),
                      tooltip: 'Reject',
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(ExpenseStatus status) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case ExpenseStatus.pending:
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[700]!;
        text = 'Pending';
        break;
      case ExpenseStatus.approved:
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[700]!;
        text = 'Approved';
        break;
      case ExpenseStatus.rejected:
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[700]!;
        text = 'Rejected';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(ExpenseReconciliationProvider provider) {
    final summary = provider.currentSummary;
    if (summary == null || summary.categoryBreakdown.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category Breakdown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: PremiumGlassmorphicTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...summary.categoryBreakdown.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    _getCategoryIcon(entry.key),
                    color: _getCategoryColor(entry.key),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.key.toString().split('.').last,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    NepalLocalizationUtils.formatNPRCurrency(entry.value),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _getCategoryColor(entry.key),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPendingTab() {
    return Consumer<ExpenseReconciliationProvider>(
      builder: (context, provider, child) {
        return ExpenseListWidget(
          expenses: provider.pendingExpenses,
          title: 'Pending Expenses',
          emptyMessage: 'No pending expenses found',
          onRefresh: _loadExpenses,
          onApprove: _approveExpense,
          onReject: _rejectExpense,
          onView: _viewExpense,
        );
      },
    );
  }

  Widget _buildApprovedTab() {
    return Consumer<ExpenseReconciliationProvider>(
      builder: (context, provider, child) {
        return ExpenseListWidget(
          expenses: provider.approvedExpenses,
          title: 'Approved Expenses',
          emptyMessage: 'No approved expenses found',
          onRefresh: _loadExpenses,
          onView: _viewExpense,
        );
      },
    );
  }

  Widget _buildAddExpenseTab() {
    return AddExpenseForm(
      onSubmit: _createExpense,
      onCapturePhoto: _capturePhoto,
      onPickPhoto: _pickPhotoFromGallery,
      onProcessReceipt: _processReceiptPhoto,
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => _tabController.animateTo(3),
      icon: const Icon(Icons.add),
      label: const Text('Add Expense'),
      backgroundColor: PremiumGlassmorphicTheme.primaryColor,
      foregroundColor: Colors.white,
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        _exportExpenseReport();
        break;
      case 'settings':
        _showSettings();
        break;
      case 'help':
        _showHelp();
        break;
    }
  }

  void _showExpenseSummaryDetails(ExpenseSummary? summary) {
    if (summary == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Expense Summary Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Total Expenses', summary.totalExpenses.toString()),
              _buildDetailRow('Total Amount', summary.formattedTotalAmount),
              _buildDetailRow('Pending Amount', summary.formattedPendingAmount),
              _buildDetailRow('Approved Amount', summary.formattedApprovedAmount),
              _buildDetailRow('Average Amount', summary.formattedAverageAmount),
              _buildDetailRow('Most Expensive Category', summary.mostExpensiveCategory.toString().split('.').last),
              _buildDetailRow('Generated At', NepalLocalizationUtils.formatNepaliDate(summary.generatedAt)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
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
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _viewExpense(Expense expense) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExpenseDetailScreen(expense: expense),
      ),
    );
  }

  Future<void> _approveExpense(Expense expense) async {
    try {
      final success = await context.read<ExpenseReconciliationProvider>()
          .approveExpense(expense.id);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Expense ${expense.id} approved'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ErrorHandlingUtils.showErrorSnackBar(
        context,
        'Failed to approve expense: $e',
      );
    }
  }

  Future<void> _rejectExpense(Expense expense) async {
    final TextEditingController remarksController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to reject this expense?'),
            const SizedBox(height: 16),
            TextField(
              controller: remarksController,
              decoration: const InputDecoration(
                labelText: 'Remarks (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    
    if (result == true) {
      try {
        final success = await context.read<ExpenseReconciliationProvider>()
            .rejectExpense(expense.id, remarks: remarksController.text.trim());
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Expense ${expense.id} rejected'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        ErrorHandlingUtils.showErrorSnackBar(
          context,
          'Failed to reject expense: $e',
        );
      }
    }
  }

  Future<void> _createExpense(Map<String, dynamic> expenseData) async {
    try {
      await context.read<ExpenseReconciliationProvider>()
          .createExpense(expenseData);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expense created successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate to pending tab
      _tabController.animateTo(1);
    } catch (e) {
      ErrorHandlingUtils.showErrorSnackBar(
        context,
        'Failed to create expense: $e',
      );
    }
  }

  Future<File?> _capturePhoto() async {
    try {
      return await context.read<ExpenseReconciliationProvider>()
          .capturePhoto();
    } catch (e) {
      ErrorHandlingUtils.showErrorSnackBar(
        context,
        'Failed to capture photo: $e',
      );
      return null;
    }
  }

  Future<File?> _pickPhotoFromGallery() async {
    try {
      return await context.read<ExpenseReconciliationProvider>()
          .pickPhotoFromGallery();
    } catch (e) {
      ErrorHandlingUtils.showErrorSnackBar(
        context,
        'Failed to pick photo: $e',
      );
      return null;
    }
  }

  Future<ReceiptOCRResult?> _processReceiptPhoto(File photo) async {
    try {
      return await context.read<ExpenseReconciliationProvider>()
          .processReceiptPhoto(photo);
    } catch (e) {
      ErrorHandlingUtils.showErrorSnackBar(
        context,
        'Failed to process receipt: $e',
      );
      return null;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Expenses'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedStatus,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'approved', child: Text('Approved')),
                    DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ExpenseCategory>(
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedCategory,
                  items: ExpenseCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _applyFilters();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _applyFilters() {
    // Apply filters logic here
    _loadExpenses();
  }

  void _exportExpenseReport() {
    // Export expense report logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exporting expense report...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showSettings() {
    // Show settings dialog
  }

  void _showHelp() {
    // Show help dialog
  }

  IconData _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.travel:
        return Icons.directions_car;
      case ExpenseCategory.meals:
        return Icons.restaurant;
      case ExpenseCategory.accommodation:
        return Icons.hotel;
      case ExpenseCategory.office:
        return Icons.business_center;
      case ExpenseCategory.communication:
        return Icons.phone;
      case ExpenseCategory.entertainment:
        return Icons.movie;
      case ExpenseCategory.medical:
        return Icons.local_hospital;
      case ExpenseCategory.other:
        return Icons.more_horiz;
    }
  }

  Color _getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.travel:
        return Colors.blue;
      case ExpenseCategory.meals:
        return Colors.orange;
      case ExpenseCategory.accommodation:
        return Colors.purple;
      case ExpenseCategory.office:
        return Colors.green;
      case ExpenseCategory.communication:
        return Colors.red;
      case ExpenseCategory.entertainment:
        return Colors.pink;
      case ExpenseCategory.medical:
        return Colors.teal;
      case ExpenseCategory.other:
        return Colors.grey;
    }
  }
}

/// Expense Detail Screen
class ExpenseDetailScreen extends StatelessWidget {
  final Expense expense;

  const ExpenseDetailScreen({
    Key? key,
    required this.expense,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense ${expense.id}'),
        backgroundColor: PremiumGlassmorphicTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expense Details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Expense Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: PremiumGlassmorphicTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Expense ID', expense.id),
                  _buildDetailRow('Description', expense.description),
                  _buildDetailRow('Amount', expense.formattedAmount),
                  _buildDetailRow('Category', expense.category.toString().split('.').last),
                  _buildDetailRow('Status', expense.statusText),
                  _buildDetailRow('Date', expense.formattedDate),
                  if (expense.vendorName != null)
                    _buildDetailRow('Vendor', expense.vendorName!),
                  if (expense.location != null)
                    _buildDetailRow('Location', expense.location!),
                  if (expense.notes != null && expense.notes!.isNotEmpty)
                    _buildDetailRow('Notes', expense.notes!),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Receipt Photos
            if (expense.hasPhotos) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Receipt Photos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: PremiumGlassmorphicTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: expense.receiptPhotos.length,
                        itemBuilder: (context, index) {
                          return ExpensePhotoViewer(
                            photoUrl: expense.receiptPhotos[index],
                            onTap: () => _viewPhoto(expense.receiptPhotos[index]),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
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
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _viewPhoto(String photoUrl) {
    // View photo in full screen
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_card.dart';
import '../widgets/expense_filter_widget.dart';
import '../widgets/expense_summary_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/theme/app_theme.dart';

/// Expense List Page
/// Displays list of expenses with filtering and management options
class ExpenseListPage extends StatefulWidget {
  const ExpenseListPage({Key? key}) : super(key: key);

  @override
  _ExpenseListPageState createState() => _ExpenseListPageState();
}

class _ExpenseListPageState extends State<ExpenseListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExpenses();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  void _loadExpenses() {
    final provider = ExpenseProvider.of(context);
    provider.loadExpenses();
  }
  
  void _onSearchChanged(String query) {
    final provider = ExpenseProvider.of(context);
    provider.searchExpenses(query);
  }
  
  void _onTabChanged() {
    setState(() {});
  }
  
  void _onRefresh() {
    _loadExpenses();
  }
  
  void _onCreateExpense() {
    Navigator.pushNamed(context, '/expense/create');
  }
  
  void _onFilterTap() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ExpenseFilterWidget(
        onApplyFilter: (filter) {
          Navigator.pop(context);
          final provider = ExpenseProvider.of(context);
          provider.setFilter(filter);
        },
      ),
    );
  }
  
  void _onExportExpenses() {
    final provider = ExpenseProvider.of(context);
    provider.exportExpenses();
  }
  
  void _onGenerateReport() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Generate Report',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('PDF Report'),
              subtitle: const Text('Generate detailed expense report'),
              onTap: () {
                Navigator.pop(context);
                final provider = ExpenseProvider.of(context);
                provider.generatePDFReport();
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Excel Report'),
              subtitle: const Text('Export to Excel format'),
              onTap: () {
                Navigator.pop(context);
                final provider = ExpenseProvider.of(context);
                provider.generateExcelReport();
              },
            ),
            ListTile(
              leading: const Icon(Icons.summarize),
              title: const Text('Summary Report'),
              subtitle: const Text('Generate summary statistics'),
              onTap: () {
                Navigator.pop(context);
                final provider = ExpenseProvider.of(context);
                provider.generateSummaryReport();
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _onBulkAction(String action) {
    final provider = ExpenseProvider.of(context);
    final selectedExpenses = provider.selectedExpenses;
    
    if (selectedExpenses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select expenses to perform bulk action')),
      );
      return;
    }
    
    switch (action) {
      case 'approve':
        provider.approveMultipleExpenses(selectedExpenses);
        break;
      case 'reject':
        _showBulkRejectDialog(selectedExpenses);
        break;
      case 'delete':
        _showBulkDeleteDialog(selectedExpenses);
        break;
      case 'export':
        provider.exportSelectedExpenses(selectedExpenses);
        break;
    }
  }
  
  void _showBulkRejectDialog(List<String> expenseIds) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reject ${expenseIds.length} Expenses'),
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'Rejection Reason',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            // Store rejection reason
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
              // Get rejection reason and reject expenses
              final provider = ExpenseProvider.of(context);
              provider.rejectMultipleExpenses(expenseIds, 'Bulk rejection');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
  
  void _showBulkDeleteDialog(List<String> expenseIds) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${expenseIds.length} Expenses'),
        content: Text('Are you sure you want to delete ${expenseIds.length} expense(s)? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final provider = ExpenseProvider.of(context);
              provider.deleteMultipleExpenses(expenseIds);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _onFilterTap,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _onExportExpenses,
          ),
          PopupMenuButton<String>(
            onSelected: _onBulkAction,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'approve', child: Text('Approve Selected')),
              const PopupMenuItem(value: 'reject', child: Text('Reject Selected')),
              const PopupMenuItem(value: 'delete', child: Text('Delete Selected')),
              const PopupMenuItem(value: 'export', child: Text('Export Selected')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All', icon: Icon(Icons.list)),
            Tab(text: 'Pending', icon: Icon(Icons.pending)),
            Tab(text: 'Approved', icon: Icon(Icons.check_circle)),
            Tab(text: 'Rejected', icon: Icon(Icons.cancel)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          if (_tabController.index == 0))
            Container(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search expenses...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
          
          // Filter chips
          Consumer<ExpenseProvider>(
            builder: (context, provider) {
              if (provider.hasActiveFilter) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      Chip(
                        label: Text(provider.activeFilter!.category ?? 'All'),
                        deleteIcon: const Icon(Icons.close),
                        onDeleted: () {
                          provider.clearFilter();
                        },
                      ),
                      if (provider.activeFilter!.status != null)
                        Chip(
                          label: Text(provider.activeFilter!.status!),
                          deleteIcon: const Icon(Icons.close),
                          onDeleted: () {
                            provider.clearFilter();
                          },
                        ),
                      if (provider.activeFilter!.dateRange != null)
                        Chip(
                          label: Text(
                            '${DateFormat('MMM dd').format(provider.activeFilter!.dateRange!.start)} - ${DateFormat('MMM dd').format(provider.activeFilter!.dateRange!.end)}',
                          ),
                          deleteIcon: const Icon(Icons.close),
                          onDeleted: () {
                            provider.clearFilter();
                          },
                        ),
                    ],
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
          
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildExpenseList('all'),
                _buildExpenseList('pending'),
                _buildExpenseList('approved'),
                _buildExpenseList('rejected'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'generate_report',
            onPressed: _onGenerateReport,
            child: const Icon(Icons.assessment),
            tooltip: 'Generate Report',
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'create_expense',
            onPressed: _onCreateExpense,
            child: const Icon(Icons.add),
            tooltip: 'Create Expense',
          ),
        ],
      ),
    );
  }
  
  Widget _buildExpenseList(String status) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider) {
        if (provider.isLoading) {
          return const LoadingWidget();
        }
        
        if (provider.error != null) {
          return AppErrorWidget(
            message: provider.error!,
            onRetry: _onRefresh,
          );
        }
        
        List<ExpenseEntity> expenses;
        switch (status) {
          case 'all':
            expenses = provider.expenses;
            break;
          case 'pending':
            expenses = provider.expenses.where((e) => 
              e.status == ExpenseStatus.pending || e.status == ExpenseStatus.submitted
            ).toList();
            break;
          case 'approved':
            expenses = provider.expenses.where((e) => e.status == ExpenseStatus.approved).toList();
            break;
          case 'rejected':
            expenses = provider.expenses.where((e) => e.status == ExpenseStatus.rejected).toList();
            break;
          default:
            expenses = provider.expenses;
        }
        
        if (expenses.isEmpty) {
          return EmptyStateWidget(
            title: 'No $status expenses',
            subtitle: 'No expenses found for this status',
            action: _onCreateExpense,
            actionText: 'Create Expense',
          );
        }
        
        return RefreshIndicator(
          onRefresh: () async => _onRefresh(),
          child: Column(
            children: [
              // Summary widget
              ExpenseSummaryWidget(expenses: expenses),
              
              const SizedBox(height: 16),
              
              // Expense list
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return ExpenseCard(
                      expense: expense,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/expense/details',
                          arguments: expense.id,
                        );
                      },
                      onEdit: () {
                        Navigator.pushNamed(
                          context,
                          '/expense/edit',
                          arguments: expense.id,
                        );
                      },
                      onDelete: () {
                        _showDeleteDialog(expense);
                      },
                      onApprove: expense.status == ExpenseStatus.pending || expense.status == ExpenseStatus.submitted
                          ? () {
                              final provider = ExpenseProvider.of(context);
                              provider.approveExpense(expense.id);
                            }
                          : null,
                      onReject: expense.status == ExpenseStatus.pending || expense.status == ExpenseStatus.submitted
                          ? () {
                              _showRejectDialog(expense);
                            }
                          : null,
                      isSelected: provider.selectedExpenses.contains(expense.id),
                      onSelected: (selected) {
                        final provider = ExpenseProvider.of(context);
                        provider.toggleExpenseSelection(expense.id);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _showDeleteDialog(ExpenseEntity expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final provider = ExpenseProvider.of(context);
              provider.deleteExpense(expense.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  void _showRejectDialog(ExpenseEntity expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Rejection Reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                // Store rejection reason
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Get rejection reason and reject expense
              final provider = ExpenseProvider.of(context);
              provider.rejectExpense(expense.id, 'Rejection reason');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../shared/widgets/premium_glassmorphic_theme.dart';
import '../../../../shared/utils/nepal_localization_utils.dart';
import '../../data/services/expense_reconciliation_service.dart';

/// Expense List Widget
class ExpenseListWidget extends StatefulWidget {
  final List<Expense> expenses;
  final String title;
  final String emptyMessage;
  final VoidCallback? onRefresh;
  final Function(Expense)? onView;
  final Function(Expense)? onApprove;
  final Function(Expense)? onReject;

  const ExpenseListWidget({
    Key? key,
    required this.expenses,
    required this.title,
    required this.emptyMessage,
    this.onRefresh,
    this.onView,
    this.onApprove,
    this.onReject,
  }) : super(key: key);

  @override
  State<ExpenseListWidget> createState() => _ExpenseListWidgetState();
}

class _ExpenseListWidgetState extends State<ExpenseListWidget> {
  String _searchQuery = '';
  ExpenseCategory? _selectedCategory;
  bool _isFilterExpanded = false;

  @override
  Widget build(BuildContext context) {
    final filteredExpenses = _getFilteredExpenses();

    return Column(
      children: [
        // Search and Filter Bar
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              // Search Bar
              TextField(
                decoration: InputDecoration(
                  labelText: 'Search expenses...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: Icon(_isFilterExpanded ? Icons.filter_list_off : Icons.filter_list),
                    onPressed: () {
                      setState(() {
                        _isFilterExpanded = !_isFilterExpanded;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              
              // Filter Options
              if (_isFilterExpanded) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<ExpenseCategory>(
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  value: _selectedCategory,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Categories'),
                    ),
                    ...ExpenseCategory.values.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category.toString().split('.').last),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear Filters'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[600],
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        '${filteredExpenses.length} expenses found',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        
        // Expense List
        Expanded(
          child: filteredExpenses.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: widget.onRefresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = filteredExpenses[index];
                      return _buildExpenseItem(expense);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  List<Expense> _getFilteredExpenses() {
    var filtered = List<Expense>.from(widget.expenses);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((expense) {
        return expense.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               (expense.vendorName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
               (expense.notes?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
               expense.category.toString().toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply category filter
    if (_selectedCategory != null) {
      filtered = filtered.where((expense) => expense.category == _selectedCategory).toList();
    }

    // Sort by date (most recent first)
    filtered.sort((a, b) => b.expenseDate.compareTo(a.expenseDate));

    return filtered;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            widget.emptyMessage,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or add new expenses',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseItem(Expense expense) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: _getCategoryColor(expense.category).withOpacity(0.1),
              ),
              child: Icon(
                _getCategoryIcon(expense.category),
                color: _getCategoryColor(expense.category),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.description,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: PremiumGlassmorphicTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    expense.formattedDate,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  expense.formattedAmount,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _getCategoryColor(expense.category),
                  ),
                ),
                _buildStatusChip(expense.status),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Expense ID', expense.id),
                if (expense.vendorName != null)
                  _buildDetailRow('Vendor', expense.vendorName!),
                if (expense.location != null)
                  _buildDetailRow('Location', expense.location!),
                _buildDetailRow('Category', expense.category.toString().split('.').last),
                _buildDetailRow('Amount', expense.formattedAmount),
                _buildDetailRow('Status', expense.statusText),
                if (expense.notes != null && expense.notes!.isNotEmpty)
                  _buildDetailRow('Notes', expense.notes!),
                
                const SizedBox(height: 12),
                
                // Receipt Photos
                if (expense.hasPhotos) ...[
                  Text(
                    'Receipt Photos',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: PremiumGlassmorphicTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: expense.receiptPhotos.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[200],
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Icon(
                                  Icons.image,
                                  color: Colors.grey[600],
                                  size: 32,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => widget.onView?.call(expense),
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('View'),
                    ),
                    if (widget.onApprove != null && expense.isPending) ...[
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => widget.onApprove?.call(expense),
                        icon: const Icon(Icons.approve, size: 16),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                    if (widget.onReject != null && expense.isPending) ...[
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => widget.onReject?.call(expense),
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Reject'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
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
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
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

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedCategory = null;
    });
  }
}

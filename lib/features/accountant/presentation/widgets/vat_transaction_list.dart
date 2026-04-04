import 'package:flutter/material.dart';
import '../../../../shared/widgets/premium_glassmorphic_theme.dart';
import '../../../../shared/utils/nepal_localization_utils.dart';
import '../../data/services/vat_return_service.dart';

/// VAT Transaction List Widget
class VATTransactionList extends StatefulWidget {
  final List<VATTransaction> transactions;
  final VoidCallback? onRefresh;

  const VATTransactionList({
    Key? key,
    required this.transactions,
    this.onRefresh,
  }) : super(key: key);

  @override
  State<VATTransactionList> createState() => _VATTransactionListState();
}

class _VATTransactionListState extends State<VATTransactionList> {
  String _searchQuery = '';
  VATTransactionType? _selectedType;
  String _selectedCategory = 'All';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isFilterExpanded = false;

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = _getFilteredTransactions();

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
                  labelText: 'Search transactions...',
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
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<VATTransactionType>(
                        decoration: InputDecoration(
                          labelText: 'Transaction Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        value: _selectedType,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Types'),
                          ),
                          ...VATTransactionType.values.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type.toString().split('.').last),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        value: _selectedCategory,
                        items: _getCategories().map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Start Date',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        onTap: () => _selectStartDate(),
                        controller: TextEditingController(
                          text: _startDate != null
                              ? NepalLocalizationUtils.formatNepaliDate(_startDate!)
                              : '',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'End Date',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        onTap: () => _selectEndDate(),
                        controller: TextEditingController(
                          text: _endDate != null
                              ? NepalLocalizationUtils.formatNepaliDate(_endDate!)
                              : '',
                        ),
                      ),
                    ),
                  ],
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
                        '${filteredTransactions.length} transactions found',
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
        
        // Transaction List
        Expanded(
          child: filteredTransactions.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: widget.onRefresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = filteredTransactions[index];
                      return _buildTransactionItem(transaction);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  List<VATTransaction> _getFilteredTransactions() {
    var filtered = List<VATTransaction>.from(widget.transactions);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((transaction) {
        return transaction.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               transaction.customerName?.toLowerCase().contains(_searchQuery.toLowerCase()) == true ||
               transaction.vendorName?.toLowerCase().contains(_searchQuery.toLowerCase()) == true ||
               transaction.invoiceNumber?.toLowerCase().contains(_searchQuery.toLowerCase()) == true;
      }).toList();
    }

    // Apply type filter
    if (_selectedType != null) {
      filtered = filtered.where((transaction) => transaction.type == _selectedType).toList();
    }

    // Apply category filter
    if (_selectedCategory != 'All') {
      filtered = filtered.where((transaction) => transaction.category == _selectedCategory).toList();
    }

    // Apply date filter
    if (_startDate != null) {
      filtered = filtered.where((transaction) => transaction.date.isAfter(_startDate!)).toList();
    }
    if (_endDate != null) {
      filtered = filtered.where((transaction) => transaction.date.isBefore(_endDate!)).toList();
    }

    // Sort by date (most recent first)
    filtered.sort((a, b) => b.date.compareTo(a.date));

    return filtered;
  }

  List<String> _getCategories() {
    final categories = widget.transactions.map((t) => t.category).toSet().toList();
    categories.sort();
    return ['All', ...categories];
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
            'No transactions found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search terms',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(VATTransaction transaction) {
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
                color: _getTransactionTypeColor(transaction.type).withOpacity(0.1),
              ),
              child: Icon(
                _getTransactionTypeIcon(transaction.type),
                color: _getTransactionTypeColor(transaction.type),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: PremiumGlassmorphicTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    transaction.formattedDate,
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
                  transaction.formattedAmount,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _getTransactionTypeColor(transaction.type),
                  ),
                ),
                Text(
                  'VAT: ${transaction.formattedVATAmount}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
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
                _buildDetailRow('Transaction ID', transaction.id),
                if (transaction.invoiceNumber != null)
                  _buildDetailRow('Invoice Number', transaction.invoiceNumber!),
                if (transaction.customerName != null)
                  _buildDetailRow('Customer', transaction.customerName!),
                if (transaction.vendorName != null)
                  _buildDetailRow('Vendor', transaction.vendorName!),
                _buildDetailRow('Category', transaction.category),
                _buildDetailRow('Transaction Type', transaction.type.toString().split('.').last),
                _buildDetailRow('Amount', transaction.formattedAmount),
                _buildDetailRow('VAT Amount', transaction.formattedVATAmount),
                _buildDetailRow('Total with VAT', 
                  NepalLocalizationUtils.formatNPRCurrency(transaction.amount + transaction.vatAmount)),
                if (transaction.remarks != null && transaction.remarks!.isNotEmpty)
                  _buildDetailRow('Remarks', transaction.remarks!),
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
            width: 120,
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

  Color _getTransactionTypeColor(VATTransactionType type) {
    switch (type) {
      case VATTransactionType.sale:
        return Colors.green;
      case VATTransactionType.purchase:
        return Colors.blue;
      case VATTransactionType.refund:
        return Colors.orange;
      case VATTransactionType.adjustment:
        return Colors.purple;
    }
  }

  IconData _getTransactionTypeIcon(VATTransactionType type) {
    switch (type) {
      case VATTransactionType.sale:
        return Icons.trending_up;
      case VATTransactionType.purchase:
        return Icons.shopping_cart;
      case VATTransactionType.refund:
        return Icons.refresh;
      case VATTransactionType.adjustment:
        return Icons.tune;
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

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedType = null;
      _selectedCategory = 'All';
      _startDate = null;
      _endDate = null;
    });
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../../app/theme/app_theme.dart';
import '../../../shared/widgets/glassmorphic_widgets.dart';

/// MR expense reconciliation with multi-photo receipts
class MRExpenseReconciliationScreen extends StatefulWidget {
  const MRExpenseReconciliationScreen({Key? key}) : super(key: key);

  @override
  State<MRExpenseReconciliationScreen> createState() => _MRExpenseReconciliationScreenState();
}

class _MRExpenseReconciliationScreenState extends State<MRExpenseReconciliationScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _expenses = [];
  List<Map<String, dynamic>> _pendingExpenses = [];
  List<Map<String, dynamic>> _approvedExpenses = [];
  bool _isLoading = true;
  String _selectedStatus = 'all';
  String _searchQuery = '';
  double _totalPendingAmount = 0.0;
  double _totalApprovedAmount = 0.0;
  
  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadExpenses() async {
    try {
      await _loadPendingExpenses();
      await _loadApprovedExpenses();
      await _calculateTotals();
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Failed to load expenses: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadPendingExpenses() async {
    // TODO: Replace with real API call - GET /api/mr/expenses/pending
    await Future.delayed(const Duration(milliseconds: 500));
    
    final mockPendingExpenses = [
      {
        'id': '1',
        'mrId': 'MR-001',
        'mrName': 'Ramesh Kumar',
        'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'category': 'travel',
        'description': 'Travel to Janakpur Medical Hall for doctor visit',
        'amount': 500.0,
        'currency': 'NPR',
        'receiptImages': [
          'assets/mock_receipts/travel_001.jpg',
          'assets/mock_receipts/travel_002.jpg',
        ],
        'status': 'pending',
        'submittedDate': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'location': 'Janakpur, Dhanusha',
        'purpose': 'Doctor visit - Dr. Santosh Mahaseth',
        'distance': 25.5,
        'vehicleType': 'motorcycle',
      },
      {
        'id': '2',
        'mrId': 'MR-001',
        'mrName': 'Ramesh Kumar',
        'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'category': 'food',
        'description': 'Lunch meeting with Dr. Anjali Jha',
        'amount': 350.0,
        'currency': 'NPR',
        'receiptImages': [
          'assets/mock_receipts/food_001.jpg',
        ],
        'status': 'pending',
        'submittedDate': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'location': 'Janakpur Bazaar, Janakpur',
        'purpose': 'Business lunch',
        'attendees': 3,
      },
      {
        'id': '3',
        'mrId': 'MR-001',
        'mrName': 'Ramesh Kumar',
        'date': DateTime.now().subtract(const Duration(hours: 6)).toIso8601String(),
        'category': 'supplies',
        'description': 'Purchase of sample medicines for doctor distribution',
        'amount': 1200.0,
        'currency': 'NPR',
        'receiptImages': [
          'assets/mock_receipts/supplies_001.jpg',
          'assets/mock_receipts/supplies_002.jpg',
          'assets/mock_receipts/supplies_003.jpg',
        ],
        'status': 'pending',
        'submittedDate': DateTime.now().subtract(const Duration(hours: 6)).toIso8601String(),
        'location': 'City Pharmacy, Janakpur',
        'purpose': 'Sample medicines for distribution',
        'items': [
          'Paracetamol samples',
          'Amoxicillin samples',
          'Vitamin C samples',
        ],
      },
    ];
    
    if (mounted) {
      setState(() {
        _pendingExpenses = mockPendingExpenses;
      });
    }
  }

  Future<void> _loadApprovedExpenses() async {
    // TODO: Replace with real API call - GET /api/mr/expenses/approved
    await Future.delayed(const Duration(milliseconds: 300));
    
    final mockApprovedExpenses = [
      {
        'id': '4',
        'mrId': 'MR-001',
        'mrName': 'Ramesh Kumar',
        'date': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'category': 'travel',
        'description': 'Travel to Rural Health Center',
        'amount': 750.0,
        'currency': 'NPR',
        'receiptImages': [
          'assets/mock_receipts/travel_003.jpg',
        ],
        'status': 'approved',
        'submittedDate': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'approvedDate': DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
        'approvedBy': 'Accountant - Sita Sharma',
        'location': 'Rural Health Center, Dhanusha',
        'purpose': 'Doctor visit - Rural Health Center',
        'reimbursementDate': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'reimbursementAmount': 750.0,
      },
      {
        'id': '5',
        'mrId': 'MR-001',
        'mrName': 'Ramesh Kumar',
        'date': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
        'category': 'communication',
        'description': 'Mobile phone bill for business calls',
        'amount': 450.0,
        'currency': 'NPR',
        'receiptImages': [
          'assets/mock_receipts/bill_001.jpg',
        ],
        'status': 'approved',
        'submittedDate': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
        'approvedDate': DateTime.now().subtract(const Duration(days: 6)).toIso8601String(),
        'approvedBy': 'Accountant - Sita Sharma',
        'location': 'Janakpur',
        'purpose': 'Business communication expenses',
        'reimbursementDate': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'reimbursementAmount': 450.0,
      },
    ];
    
    if (mounted) {
      setState(() {
        _approvedExpenses = mockApprovedExpenses;
      });
    }
  }

  Future<void> _calculateTotals() async {
    final pendingTotal = _pendingExpenses.fold(0.0, (sum, expense) => sum + (expense['amount'] as double));
    final approvedTotal = _approvedExpenses.fold(0.0, (sum, expense) => sum + (expense['amount'] as double));
    
    if (mounted) {
      setState(() {
        _totalPendingAmount = pendingTotal;
        _totalApprovedAmount = approvedTotal;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredExpenses {
    var filtered = [..._pendingExpenses, ..._approvedExpenses];
    
    // Filter by status
    if (_selectedStatus != 'all') {
      filtered = filtered.where((expense) => expense['status'] == _selectedStatus).toList();
    }
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((expense) {
        final query = _searchQuery.toLowerCase();
        return expense['description'].toString().toLowerCase().contains(query) ||
               expense['category'].toString().toLowerCase().contains(query) ||
               expense['location'].toString().toLowerCase().contains(query);
      }).toList();
    }
    
    // Sort by date (newest first)
    filtered.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Expense Reconciliation',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.mrColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _showAddExpenseDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                _buildSummaryBar(),
                _buildFilterBar(),
                Expanded(
                  child: _buildExpensesList(),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: GlassmorphicStatCard(
              title: 'Pending Amount',
              value: 'NPR ${_totalPendingAmount.toStringAsFixed(2)}',
              icon: Icons.pending_actions,
              color: AppTheme.warning,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GlassmorphicStatCard(
              title: 'Approved Amount',
              value: 'NPR ${_totalApprovedAmount.toStringAsFixed(2)}',
              icon: Icons.approval,
              color: AppTheme.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GlassmorphicCard(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search expenses...',
                      hintStyle: TextStyle(color: AppTheme.textSecondary),
                      prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GlassmorphicButton(
                text: 'Add Expense',
                icon: Icons.add,
                onPressed: _showAddExpenseDialog,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatusChip('all', 'All'),
                _buildStatusChip('pending', 'Pending'),
                _buildStatusChip('approved', 'Approved'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, String label) {
    final isSelected = _selectedStatus == status;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = status;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.mrColor : AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.mrColor : AppTheme.borderDark,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildExpensesList() {
    final filteredExpenses = _filteredExpenses;
    
    if (filteredExpenses.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: AppTheme.textSecondary),
            SizedBox(height: 16),
            Text(
              'No expenses found',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 18),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredExpenses.length,
      itemBuilder: (context, index) {
        return _buildExpenseCard(filteredExpenses[index]);
      },
    );
  }

  Widget _buildExpenseCard(Map<String, dynamic> expense) {
    final status = expense['status'] as String;
    final statusColor = _getExpenseStatusColor(status);
    final statusIcon = _getExpenseStatusIcon(status);
    final receiptImages = expense['receiptImages'] as List<dynamic>? ?? [];
    
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
                        expense['description'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        expense['category'],
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        expense['location'],
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
                  child: Text(
                    'NPR ${(expense['amount'] as double).toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  expense['date'],
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            
            // Receipt Images Preview
            if (receiptImages.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Receipt Images (${receiptImages.length})',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: receiptImages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.borderDark),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: receiptImages[index].toString().startsWith('assets')
                            ? Image.asset(
                                receiptImages[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppTheme.surfaceDark,
                                    child: const Icon(
                                      Icons.receipt_long,
                                      color: AppTheme.textSecondary,
                                      size: 32,
                                    ),
                                  );
                                },
                              )
                            : Image.network(
                                receiptImages[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppTheme.surfaceDark,
                                    child: const Icon(
                                      Icons.receipt_long,
                                      color: AppTheme.textSecondary,
                                      size: 32,
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
            
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GlassmorphicButton(
                    text: 'View Details',
                    icon: Icons.visibility,
                    onPressed: () => _showExpenseDetails(expense),
                  ),
                ),
                const SizedBox(width: 8),
                if (status == 'pending')
                  Expanded(
                    child: GlassmorphicButton(
                      text: 'Approve',
                      icon: Icons.check_circle,
                      onPressed: () => _approveExpense(expense),
                    ),
                  ),
                if (status == 'approved')
                  Expanded(
                    child: GlassmorphicButton(
                      text: 'View Receipt',
                      icon: Icons.receipt_long,
                      onPressed: () => _viewReceiptImages(expense),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getExpenseStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppTheme.warning;
      case 'approved':
        return AppTheme.success;
      case 'rejected':
        return AppTheme.error;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _getExpenseStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddExpenseDialog(
        onSuccess: () => _loadExpenses(),
      ),
    );
  }

  void _showExpenseDetails(Map<String, dynamic> expense) {
    showDialog(
      context: context,
      builder: (context) => _ExpenseDetailsDialog(expense: expense),
    );
  }

  Future<void> _approveExpense(Map<String, dynamic> expense) async {
    try {
      // TODO: Replace with real API call - PATCH /api/accountant/expenses/{id}/approve
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense approved successfully'),
            backgroundColor: AppTheme.success,
          ),
        );
        _loadExpenses();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to approve expense: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  void _viewReceiptImages(Map<String, dynamic> expense) {
    showDialog(
      context: context,
      builder: (context) => _ReceiptImagesDialog(expense: expense),
    );
  }
}

class _AddExpenseDialog extends StatefulWidget {
  final VoidCallback onSuccess;

  const _AddExpenseDialog({required this.onSuccess, Key? key}) : super(key: key);

  @override
  State<_AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<_AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _locationController = TextEditingController();
  final _purposeController = TextEditingController();
  String _selectedCategory = 'travel';
  List<File> _receiptImages = [];
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _categories = [
    {'id': 'travel', 'name': 'Travel'},
    {'id': 'food', 'name': 'Food'},
    {'id': 'supplies', 'name': 'Supplies'},
    {'id': 'communication', 'name': 'Communication'},
    {'id': 'accommodation', 'name': 'Accommodation'},
    {'id': 'other', 'name': 'Other'},
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surfaceDark,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add New Expense',
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
              
              Expanded(
                child: ListView(
                  children: [
                    // Category
                    const Text(
                      'Category',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: AppTheme.inputDecoration('Select category...'),
                      value: _selectedCategory,
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category['id'],
                          child: Text(
                            category['name'],
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                    
                    // Description
                    const SizedBox(height: 16),
                    const Text(
                      'Description',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: AppTheme.inputDecoration('Enter description...'),
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Description is required';
                        return null;
                      },
                    ),
                    
                    // Amount
                    const SizedBox(height: 16),
                    const Text(
                      'Amount (NPR)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _amountController,
                      decoration: AppTheme.inputDecoration('Enter amount...'),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Amount is required';
                        if (double.tryParse(value) == null) return 'Invalid amount';
                        return null;
                      },
                    ),
                    
                    // Location
                    const SizedBox(height: 16),
                    const Text(
                      'Location',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _locationController,
                      decoration: AppTheme.inputDecoration('Enter location...'),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Location is required';
                        return null;
                      },
                    ),
                    
                    // Purpose
                    const SizedBox(height: 16),
                    const Text(
                      'Purpose',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _purposeController,
                      decoration: AppTheme.inputDecoration('Enter purpose...'),
                      style: const TextStyle(color: Colors.white),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Purpose is required';
                        return null;
                      },
                    ),
                    
                    // Receipt Images
                    const SizedBox(height: 16),
                    const Text(
                      'Receipt Images',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildReceiptImagesSection(),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: GlassmorphicButton(
                  text: 'Submit Expense',
                  icon: Icons.send,
                  onPressed: _isSubmitting ? null : _submitExpense,
                  isLoading: _isSubmitting,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ..._receiptImages.asMap().entries.map((entry) {
              final index = entry.key;
              final image = entry.value;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Stack(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.borderDark),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppTheme.surfaceDark,
                              child: const Icon(
                                Icons.receipt_long,
                                color: AppTheme.textSecondary,
                                size: 24,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      top: -5,
                      right: -5,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _receiptImages.removeAt(index);
                          });
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: AppTheme.error,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
            }).toList(),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _pickReceiptImage,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.borderDark, style: BorderStyle.solid),
                ),
                child: const Icon(
                  Icons.add_a_photo,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Add receipt images (max 5)',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Future<void> _pickReceiptImage() async {
    if (_receiptImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 5 receipt images allowed'),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    
    if (pickedFile != null) {
      setState(() {
        _receiptImages.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _submitExpense() async {
    if (!_formKey.currentState!.validate()) {
      if (_receiptImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one receipt image'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // TODO: Replace with real API call - POST /api/mr/expenses
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense submitted successfully'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit expense: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

class _ExpenseDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> expense;

  const _ExpenseDetailsDialog({required this.expense, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final receiptImages = expense['receiptImages'] as List<dynamic>? ?? [];
    
    return Dialog(
      backgroundColor: AppTheme.surfaceDark,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Expense Details',
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
            
            Expanded(
              child: ListView(
                children: [
                  _buildDetailRow('Description', expense['description']),
                  _buildDetailRow('Category', expense['category']),
                  _buildDetailRow('Amount', 'NPR ${(expense['amount'] as double).toStringAsFixed(2)}'),
                  _buildDetailRow('Location', expense['location']),
                  _buildDetailRow('Date', expense['date']),
                  if (expense['purpose'] != null)
                    _buildDetailRow('Purpose', expense['purpose']),
                  if (expense['approvedBy'] != null)
                    _buildDetailRow('Approved By', expense['approvedBy']),
                  if (expense['approvedDate'] != null)
                    _buildDetailRow('Approved Date', expense['approvedDate']),
                  if (expense['reimbursementDate'] != null)
                    _buildDetailRow('Reimbursement Date', expense['reimbursementDate']),
                  if (expense['reimbursementAmount'] != null)
                    _buildDetailRow('Reimbursement Amount', 'NPR ${(expense['reimbursementAmount'] as double).toStringAsFixed(2)}'),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Receipt Images
            if (receiptImages.isNotEmpty) ...[
              const Text(
                'Receipt Images',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: receiptImages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.borderDark),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: receiptImages[index].toString().startsWith('assets')
                            ? Image.asset(
                                receiptImages[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppTheme.surfaceDark,
                                    child: const Icon(
                                      Icons.receipt_long,
                                      color: AppTheme.textSecondary,
                                      size: 32,
                                    ),
                                  );
                                },
                              )
                            : Image.network(
                                receiptImages[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppTheme.surfaceDark,
                                    child: const Icon(
                                      Icons.receipt_long,
                                      color: AppTheme.textSecondary,
                                      size: 32,
                                    ),
                                  );
                                },
                              ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
            
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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

class _ReceiptImagesDialog extends StatelessWidget {
  final Map<String, dynamic> expense;

  const _ReceiptImagesDialog({required this.expense, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final receiptImages = expense['receiptImages'] as List<dynamic>? ?? [];
    
    return Dialog(
      backgroundColor: AppTheme.surfaceDark,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Receipt Images - ${expense['description']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
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
            
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                itemCount: receiptImages.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Show full-screen image
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderDark),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: receiptImages[index].toString().startsWith('assets')
                            ? Image.asset(
                                receiptImages[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppTheme.surfaceDark,
                                    child: const Icon(
                                      Icons.receipt_long,
                                      color: AppTheme.textSecondary,
                                      size: 32,
                                    ),
                                  );
                                },
                              )
                            : Image.network(
                                receiptImages[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppTheme.surfaceDark,
                                    child: const Icon(
                                      Icons.receipt_long,
                                      color: AppTheme.textSecondary,
                                      size: 32,
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 24),
            
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
}

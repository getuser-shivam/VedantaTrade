import 'package:flutter/material.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';
import 'package:vedanta_trade/shared/app_scaffold.dart';
import 'package:vedanta_trade/shared/widgets/glassmorphic_widgets.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_trade/features/auth/presentation/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:vedanta_trade/core/api_config.dart';
import 'package:intl/intl.dart';
import 'package:vedanta_trade/shared/widgets/toast_notification.dart';

class ExpenseReconciliationScreen extends StatefulWidget {
  const ExpenseReconciliationScreen({super.key});

  @override
  State<ExpenseReconciliationScreen> createState() => _ExpenseReconciliationScreenState();
}

class _ExpenseReconciliationScreenState extends State<ExpenseReconciliationScreen> {
  List<dynamic> _pendingExpenses = [];
  List<dynamic> _processedExpenses = [];
  bool _loading = true;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      final headers = {'Authorization': 'Bearer ${auth.token}'};
      
      final res = await dio.get(
        '${ApiConfig.baseUrl}/accounting/expenses',
        options: Options(headers: headers),
      );
      
      final allExpenses = res.data['data'] ?? [];
      
      if (mounted) {
        setState(() {
          _pendingExpenses = allExpenses.where((e) => e['status'] == 'PENDING').toList();
          _processedExpenses = allExpenses.where((e) => e['status'] != 'PENDING').toList();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _pendingExpenses = [];
          _processedExpenses = [];
          _loading = false;
        });
      }
    }
  }

  Future<void> _approveExpense(String expenseId) async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      final headers = {'Authorization': 'Bearer ${auth.token}'};
      
      await dio.patch(
        '${ApiConfig.baseUrl}/accounting/expenses/$expenseId',
        data: {'status': 'APPROVED', 'approvedAt': DateTime.now().toIso8601String()},
        options: Options(headers: headers),
      );
      
      context.showSuccess('Expense approved successfully');
      _loadExpenses();
    } catch (e) {
      context.showError('Failed to approve expense');
    }
  }

  Future<void> _rejectExpense(String expenseId, String reason) async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      final headers = {'Authorization': 'Bearer ${auth.token}'};
      
      await dio.patch(
        '${ApiConfig.baseUrl}/accounting/expenses/$expenseId',
        data: {'status': 'REJECTED', 'rejectionReason': reason, 'rejectedAt': DateTime.now().toIso8601String()},
        options: Options(headers: headers),
      );
      
      context.showSuccess('Expense rejected');
      _loadExpenses();
    } catch (e) {
      context.showError('Failed to reject expense');
    }
  }

  void _showRejectDialog(String expenseId) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: const Text('Reject Expense', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: reasonController,
          style: const TextStyle(color: Colors.white),
          decoration: AppTheme.inputDecoration('Enter rejection reason...'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.isNotEmpty) {
                Navigator.pop(context);
                _rejectExpense(expenseId, reasonController.text);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentList = _selectedTab == 0 ? _pendingExpenses : _processedExpenses;
    
    return AppScaffold(
      title: 'MR Expense Reconciliation',
      roleColor: AppTheme.accountantColor,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.accountantColor))
          : Column(
              children: [
                // Tab Selector
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _TabButton(
                            label: 'Pending (${_pendingExpenses.length})',
                            isSelected: _selectedTab == 0,
                            onTap: () => setState(() => _selectedTab = 0),
                          ),
                        ),
                        Expanded(
                          child: _TabButton(
                            label: 'Processed',
                            isSelected: _selectedTab == 1,
                            onTap: () => setState(() => _selectedTab = 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Expense List
                Expanded(
                  child: currentList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _selectedTab == 0 ? Icons.check_circle : Icons.folder_open,
                                size: 64,
                                color: Colors.white24,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _selectedTab == 0 ? 'No pending expenses' : 'No processed expenses',
                                style: const TextStyle(color: Colors.white38, fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: currentList.length,
                          itemBuilder: (context, index) {
                            final expense = currentList[index];
                            return _ExpenseCard(
                              expense: expense,
                              isPending: _selectedTab == 0,
                              onApprove: () => _approveExpense(expense['id']),
                              onReject: () => _showRejectDialog(expense['id']),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accountantColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white54,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final Map<String, dynamic> expense;
  final bool isPending;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _ExpenseCard({
    required this.expense,
    required this.isPending,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final mr = expense['mr'];
    final date = DateTime.parse(expense['expenseDate']);
    final status = expense['status'];
    final statusColor = status == 'APPROVED' 
        ? AppTheme.success 
        : status == 'REJECTED' 
            ? AppTheme.error 
            : AppTheme.warning;

    return GlassmorphicCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: MR Info & Amount
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.mrColor.withOpacity(0.2),
                child: const Icon(Icons.person, color: AppTheme.mrColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mr?['name'] ?? 'Unknown MR',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      DateFormat('d MMM yyyy').format(date),
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'NPR ${expense['amount']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Expense Details
          Row(
            children: [
              Icon(
                _getCategoryIcon(expense['category']),
                size: 16,
                color: Colors.white54,
              ),
              const SizedBox(width: 8),
              Text(
                expense['category'] ?? 'Miscellaneous',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          
          if (expense['description']?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(
              expense['description'],
              style: const TextStyle(color: Colors.white54, fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          
          // Photo indicators if available
          if ((expense['receipts'] as List?)?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.photo_library, size: 16, color: Colors.white38),
                const SizedBox(width: 4),
                Text(
                  '${(expense['receipts'] as List).length} receipt(s)',
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ],
          
          // Action buttons for pending
          if (isPending) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white12),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close, color: AppTheme.error, size: 18),
                    label: const Text('Reject', style: TextStyle(color: AppTheme.error)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check, color: Colors.white, size: 18),
                    label: const Text('Approve', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ],
          
          // Rejection reason for rejected expenses
          if (status == 'REJECTED' && expense['rejectionReason'] != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.error.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 16, color: AppTheme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Reason: ${expense['rejectionReason']}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'TRAVEL':
        return Icons.directions_car_rounded;
      case 'FOOD':
        return Icons.restaurant_rounded;
      case 'STAY':
        return Icons.hotel_rounded;
      case 'MISC':
        return Icons.more_horiz_rounded;
      default:
        return Icons.receipt_rounded;
    }
  }
}

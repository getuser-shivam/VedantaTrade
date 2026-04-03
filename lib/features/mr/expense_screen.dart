import 'package:flutter/material.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';
import 'package:vedanta_trade/shared/app_scaffold.dart';
import 'package:vedanta_trade/shared/widgets/glassmorphic_widgets.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_trade/features/auth/presentation/providers/auth_provider.dart';
import 'package:intl/intl.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});
  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  List<dynamic> _claims = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    // Mocking for Phase 5 demo
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        _claims = [
          {
            'category': 'TRAVEL',
            'amount': 450,
            'description': 'Fuel for Janakpur territory coverage',
            'expenseDate': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
            'status': 'PENDING',
          },
          {
            'category': 'FOOD',
            'amount': 220,
            'description': 'Lunch during field visit',
            'expenseDate': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
            'status': 'APPROVED',
          },
          {
            'category': 'STAY',
            'amount': 1800,
            'description': 'Hotel stay for overnight coverage',
            'expenseDate': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
            'status': 'APPROVED',
          },
        ];
        _loading = false;
      });
    }
  }

  static const _navItems = [
    NavItem(label: 'Dashboard', icon: Icons.dashboard_rounded, route: '/mr'),
    NavItem(label: 'Doctor Visits', icon: Icons.medical_services_rounded, route: '/mr/visits'),
    NavItem(label: 'Tour Plan', icon: Icons.map_rounded, route: '/mr/tour-plan'),
    NavItem(label: 'Expenses', icon: Icons.receipt_long_rounded, route: '/mr/expenses'),
    NavItem(label: 'Profile', icon: Icons.person_rounded, route: '/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    double totalPending = 0;
    double totalApproved = 0;
    for (var c in _claims) {
      if (c['status'] == 'PENDING') {
        totalPending += (c['amount'] as num).toDouble();
      } else if (c['status'] == 'APPROVED') {
        totalApproved += (c['amount'] as num).toDouble();
      }
    }

    return AppScaffold(
      title: 'Expense Management',
      roleColor: AppTheme.mrColor,
      navItems: _navItems,
      selectedIndex: 3,
      fab: FloatingActionButton.extended(
        onPressed: () => _showAddExpenseDialog(),
        backgroundColor: AppTheme.mrColor,
        icon: const Icon(Icons.add_card_rounded, color: Colors.white),
        label: const Text('Submit Claim', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: LoadingAnimation())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fast Stats Grid
                  Row(
                    children: [
                      Expanded(
                        child: GlassmorphicStatCard(
                          title: 'Pending',
                          value: '₹${totalPending.toStringAsFixed(0)}',
                          icon: Icons.pending_actions_rounded,
                          color: AppTheme.warning,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GlassmorphicStatCard(
                          title: 'Approved (MTD)',
                          value: '₹${totalApproved.toStringAsFixed(0)}',
                          icon: Icons.verified_rounded,
                          color: AppTheme.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Expense History
                  const SectionHeader(title: 'Recent Claims'),
                  const SizedBox(height: 12),
                  if (_claims.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(48),
                        child: Text('No claims found', style: TextStyle(color: Colors.white38)),
                      ),
                    )
                  else
                    ...(_claims.map((c) => _ExpenseListItem(claim: c)).toList()),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  void _showAddExpenseDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddExpenseModal(onSuccess: () => _loadExpenses()),
    );
  }
}

class _ExpenseListItem extends StatelessWidget {
  final Map<String, dynamic> claim;
  const _ExpenseListItem({required this.claim});

  @override
  Widget build(BuildContext context) {
    final isApproved = claim['status'] == 'APPROVED';
    final date = DateTime.parse(claim['expenseDate']);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassmorphicListItem(
        title: claim['category'] ?? 'Miscellaneous',
        subtitle: '${claim['description']} • ${DateFormat('d MMM').format(date)}',
        leadingIcon: _expenseIcon(claim['category']),
        iconColor: isApproved ? AppTheme.success : AppTheme.warning,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${claim['amount']}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              claim['status'],
              style: TextStyle(
                color: isApproved ? AppTheme.success : AppTheme.warning,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _expenseIcon(String? type) {
    switch (type) {
      case 'TRAVEL': return Icons.directions_car_rounded;
      case 'FOOD': return Icons.restaurant_rounded;
      case 'STAY': return Icons.hotel_rounded;
      case 'MISC': return Icons.more_horiz_rounded;
      default: return Icons.money_rounded;
    }
  }
}

class _AddExpenseModal extends StatefulWidget {
  final VoidCallback onSuccess;
  const _AddExpenseModal({required this.onSuccess});

  @override
  State<_AddExpenseModal> createState() => _AddExpenseModalState();
}

class _AddExpenseModalState extends State<_AddExpenseModal> {
  String _category = 'TRAVEL';
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  DateTime _date = DateTime.now();
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    return GlassmorphicBackground(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.bgDark.withOpacity(0.8),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text(
                  'Submit Claim',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.white38),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView(
                children: [
                  const Text('CATEGORY', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: ['TRAVEL', 'FOOD', 'STAY', 'MISC'].map((c) {
                      final isSelected = _category == c;
                      return ChoiceChip(
                        label: Text(c, style: TextStyle(color: isSelected ? Colors.white : Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
                        selected: isSelected,
                        onSelected: (v) { if (v) setState(() => _category = c); },
                        backgroundColor: Colors.white.withOpacity(0.05),
                        selectedColor: AppTheme.mrColor,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text('AMOUNT (₹)', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                    decoration: AppTheme.inputDecoration('0.00').copyWith(
                      prefixIcon: const Icon(Icons.currency_rupee_rounded, color: AppTheme.mrColor),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('DATE', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context, 
                        initialDate: _date, 
                        firstDate: DateTime.now().subtract(const Duration(days: 30)), 
                        lastDate: DateTime.now(),
                      );
                      if (d != null) setState(() => _date = d);
                    },
                    child: GlassmorphicCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 18, color: AppTheme.mrColor),
                          const SizedBox(width: 12),
                          Text(DateFormat('d MMMM yyyy').format(_date), style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('REMARKS', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descController,
                    style: const TextStyle(color: Colors.white),
                    decoration: AppTheme.inputDecoration('Description...'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submitting ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.mrColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _submitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'SUBMIT EXPENSE CLAIM',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter an amount')));
      return;
    }

    setState(() => _submitting = true);
    // Success simulation
    await Future.delayed(const Duration(seconds: 1));
    widget.onSuccess();
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense claim submitted for approval'), backgroundColor: AppTheme.success),
      );
    }
  }
}

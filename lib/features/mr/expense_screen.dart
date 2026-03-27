import 'package:flutter/material.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';
import 'package:vedanta_trade/shared/app_scaffold.dart';
import 'package:vedanta_trade/shared/widgets.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_trade/features/auth/presentation/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:vedanta_trade/core/api_config.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});
  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  List<dynamic> _claims = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _loadExpenses(); }

  Future<void> _loadExpenses() async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      final res = await dio.get('${ApiConfig.baseUrl}/mr/expenses', options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}));
      if (mounted) setState(() { _claims = res.data['data'] ?? []; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  static const _navItems = [
    NavItem(label: 'MR Dashboard', icon: Icons.dashboard_rounded, route: '/mr'),
    NavItem(label: 'Doctor Visits', icon: Icons.medical_services_rounded, route: '/mr/visits'),
    NavItem(label: 'Tour Plan', icon: Icons.map_rounded, route: '/mr/tour-plan'),
    NavItem(label: 'Expenses', icon: Icons.receipt_long_rounded, route: '/mr/expenses'),
    NavItem(label: 'Doctor List', icon: Icons.health_and_safety_rounded, route: '/doctors-list'),
  ];

  @override
  Widget build(BuildContext context) {
    double totalPending = 0;
    for (var c in _claims) { if (c['status'] == 'PENDING') totalPending += (c['amount'] as num).toDouble(); }

    return AppScaffold(
      title: 'Expense Management',
      roleColor: AppTheme.mrColor,
      navItems: _navItems,
      selectedIndex: 3,
      fab: FloatingActionButton.extended(
        onPressed: () => _showAddExpenseDialog(),
        backgroundColor: AppTheme.mrColor,
        icon: const Icon(Icons.add_card_rounded),
        label: const Text('Submit Claim'),
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppTheme.mrColor))
        : Column(children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(children: [
                Expanded(child: StatCard(title: 'Pending Claims', value: '₹${totalPending.toStringAsFixed(0)}', icon: Icons.pending_actions_rounded, color: AppTheme.warning)),
                const SizedBox(width: 16),
                Expanded(child: StatCard(title: 'Approved (MTD)', value: '₹14,200', icon: Icons.verified_rounded, color: AppTheme.success)),
              ]),
            ),
            const Divider(height: 1),
            Expanded(
              child: _claims.isEmpty
                ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.receipt_long_rounded, size: 56, color: AppTheme.mrColor.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    const Text('No expense claims found', style: TextStyle(color: Colors.white38, fontSize: 16)),
                  ]))
                : ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: _claims.length,
                    itemBuilder: (ctx, i) {
                      final c = _claims[i];
                      final isApproved = c['status'] == 'APPROVED';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(14)),
                        child: Row(children: [
                          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: (isApproved ? AppTheme.success : AppTheme.warning).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                            child: Icon(_expenseIcon(c['category']), color: isApproved ? AppTheme.success : AppTheme.warning)),
                          const SizedBox(width: 14),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(c['category']?.toString().replaceAll('_', ' ') ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                            Text(c['expenseDate']?.toString().substring(0, 10) ?? '', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                          ])),
                          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            Text('₹${c['amount']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                            Text(c['status'], style: TextStyle(color: isApproved ? AppTheme.success : AppTheme.warning, fontSize: 11, fontWeight: FontWeight.w600)),
                          ]),
                        ]),
                      );
                    },
                  ),
            ),
          ]),
    );
  }

  void _showAddExpenseDialog() {
    final auth = context.read<AuthProvider>();
    final dio = Dio();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          String category = 'TRAVEL';
          final amountController = TextEditingController();
          final descController = TextEditingController();
          DateTime date = DateTime.now();
          bool submitting = false;

          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(color: AppTheme.bgDark, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(children: [
              Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2))),
              const Padding(padding: EdgeInsets.all(16), child: Text('Submit Expense Claim', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    const Text('Category', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Row(
                      children: ['TRAVEL', 'FOOD', 'STAY', 'MISC'].map((c) {
                        final sel = category == c;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(c, style: TextStyle(color: sel ? Colors.white : Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                            selected: sel,
                            onSelected: (v) { if (v) setModalState(() => category = c); },
                            backgroundColor: AppTheme.surfaceDark,
                            selectedColor: AppTheme.mrColor,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Text('Amount (₹)', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      decoration: AppTheme.inputDecoration('0.00'),
                    ),
                    const SizedBox(height: 20),
                    const Text('Description', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: AppTheme.inputDecoration('What was this expense for?'),
                    ),
                    const SizedBox(height: 20),
                    const Text('Expense Date', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final d = await showDatePicker(context: context, initialDate: date, firstDate: DateTime.now().subtract(const Duration(days: 30)), lastDate: DateTime.now());
                        if (d != null) setModalState(() => date = d);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: AppTheme.surfaceDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
                        child: Row(children: [
                          const Icon(Icons.calendar_today_rounded, size: 18, color: AppTheme.mrColor),
                          const SizedBox(width: 12),
                          Text(date.toString().substring(0, 10), style: const TextStyle(color: Colors.white)),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: submitting ? null : () async {
                      if (amountController.text.isEmpty) return;
                      setModalState(() => submitting = true);
                      try {
                        await dio.post(
                          '${ApiConfig.baseUrl}/mr/expenses',
                          data: {
                            'category': category,
                            'amount': double.tryParse(amountController.text) ?? 0,
                            'description': descController.text,
                            'expenseDate': date.toIso8601String(),
                          },
                          options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}),
                        );
                        if (context.mounted) {
                          Navigator.pop(context);
                          _loadExpenses();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Claim submitted successfully!'), backgroundColor: AppTheme.success));
                        }
                      } catch (e) {
                        setModalState(() => submitting = false);
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error));
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.mrColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: submitting ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('SUBMIT CLAIM', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                ),
              ),
            ]),
          );
        }
      ),
    );
  }

  IconData _expenseIcon(String? type) {
    switch(type) {
      case 'TRAVEL': return Icons.directions_car_rounded;
      case 'FOOD': return Icons.restaurant_rounded;
      case 'STAY': return Icons.hotel_rounded;
      case 'MISC': return Icons.more_horiz_rounded;
      default: return Icons.money_rounded;
    }
  }
}


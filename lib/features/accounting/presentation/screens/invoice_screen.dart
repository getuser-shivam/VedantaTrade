import 'package:flutter/material.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';
import 'package:vedanta_trade/shared/app_scaffold.dart';
import 'package:vedanta_trade/shared/widgets.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_trade/features/authentication/presentation/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:vedanta_trade/core/api_config.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});
  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  List<dynamic> _invoices = [];
  bool _loading = true;
  String _filter = 'ALL';

  @override
  void initState() { super.initState(); _loadInvoices(); }

  Future<void> _loadInvoices() async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      final res = await dio.get('${ApiConfig.baseUrl}/accounting/invoices', 
        options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}));
      if (mounted) setState(() { _invoices = res.data['data'] ?? []; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  static const _navItems = [
    NavItem(label: 'Dashboard', icon: Icons.dashboard_rounded, route: '/accounting'),
    NavItem(label: 'Invoices', icon: Icons.receipt_long_rounded, route: '/accounting/invoices'),
    NavItem(label: 'Ledger', icon: Icons.book_rounded, route: '/accounting/ledger'),
    NavItem(label: 'VAT Reports', icon: Icons.calculate_rounded, route: '/accounting/vat'),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _invoices.where((inv) => _filter == 'ALL' || inv['status'] == _filter).toList();

    return AppScaffold(
      title: 'Invoice Records',
      roleColor: AppTheme.accountantColor,
      navItems: _navItems,
      selectedIndex: 1,
      fab: FloatingActionButton.extended(
        onPressed: () => _showCreateInvoiceDialog(),
        backgroundColor: AppTheme.accountantColor,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Create Invoice'),
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppTheme.accountantColor))
        : Column(children: [
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _FilterChip(label: 'All Invoices', isSelected: _filter == 'ALL', onSelect: () => setState(() => _filter = 'ALL')),
                  _FilterChip(label: 'Paid', isSelected: _filter == 'PAID', onSelect: () => setState(() => _filter = 'PAID')),
                  _FilterChip(label: 'Pending', isSelected: _filter == 'PENDING', onSelect: () => setState(() => _filter = 'PENDING')),
                  _FilterChip(label: 'Overdue', isSelected: _filter == 'OVERDUE', onSelect: () => setState(() => _filter = 'OVERDUE')),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filtered.isEmpty
                ? const Center(child: Text('No matching invoices found', style: TextStyle(color: Colors.white38)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final inv = filtered[i];
                      final statusColor = inv['status'] == 'PAID' ? AppTheme.success : inv['status'] == 'OVERDUE' ? AppTheme.error : AppTheme.warning;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.dividerDark)),
                        child: Row(children: [
                          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: statusColor.withOpacity(0.1), shape: BoxShape.circle),
                            child: Icon(Icons.receipt_rounded, color: statusColor, size: 20)),
                          const SizedBox(width: 16),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(inv['invoiceNumber'] ?? 'N/A', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                            Text(inv['invoiceType'] ?? 'General', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                          ])),
                          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            Text('NPR ${inv['totalAmount']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                            Text(inv['status'] ?? 'Draft', style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                          ]),
                        ]),
                      );
                    },
                  ),
            ),
          ]),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelect;
  const _FilterChip({required this.label, required this.isSelected, required this.onSelect});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelect(),
        backgroundColor: AppTheme.cardDark,
        selectedColor: AppTheme.accountantColor.withOpacity(0.2),
        labelStyle: TextStyle(color: isSelected ? AppTheme.accountantColor : Colors.white60, fontSize: 12),
      ),
  void _showCreateInvoiceDialog() {
    final auth = context.read<AuthProvider>();
    final dio = Dio();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          String type = 'SALE';
          final subtotalController = TextEditingController();
          final totalController = TextEditingController();
          DateTime? dueDate;
          bool submitting = false;

          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(color: AppTheme.bgDark, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(children: [
              Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2))),
              const Padding(padding: EdgeInsets.all(16), child: Text('Create New Invoice', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    const Text('Invoice Type', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Row(
                      children: ['SALE', 'PURCHASE'].map((t) {
                        final sel = type == t;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(t, style: TextStyle(color: sel ? Colors.white : Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                            selected: sel,
                            onSelected: (v) { if (v) setModalState(() => type = t); },
                            backgroundColor: AppTheme.surfaceDark,
                            selectedColor: AppTheme.accountantColor,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Text('Subtotal (NPR)', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: subtotalController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: AppTheme.inputDecoration('Ex: 15000'),
                      onChanged: (val) {
                        final amt = double.tryParse(val) ?? 0;
                        setModalState(() => totalController.text = (amt * 1.13).toStringAsFixed(2));
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text('Total (incl. 13% VAT)', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: totalController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      decoration: AppTheme.inputDecoration('Ex: 17700'),
                    ),
                    const SizedBox(height: 20),
                    const Text('Due Date', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final d = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 15)), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                        if (d != null) setModalState(() => dueDate = d);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: AppTheme.surfaceDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
                        child: Row(children: [
                          const Icon(Icons.calendar_today_rounded, size: 18, color: AppTheme.accountantColor),
                          const SizedBox(width: 12),
                          Text(dueDate == null ? 'Select date' : dueDate!.toString().substring(0, 10), style: TextStyle(color: dueDate != null ? Colors.white : Colors.white38)),
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
                     onPressed: submitting || subtotalController.text.isEmpty ? null : () async {
                       setModalState(() => submitting = true);
                       try {
                         final sub = double.tryParse(subtotalController.text) ?? 0;
                         final total = double.tryParse(totalController.text) ?? 0;
                         await dio.post(
                           '${ApiConfig.baseUrl}/accounting/invoices',
                           data: {
                             'invoiceType': type,
                             'subtotal': sub,
                             'vatAmount': total - sub,
                             'totalAmount': total,
                             'dueDate': dueDate?.toIso8601String(),
                           },
                           options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}),
                         );
                         if (context.mounted) {
                           Navigator.pop(context);
                           _loadInvoices();
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoice created!'), backgroundColor: AppTheme.success));
                         }
                       } catch (e) {
                         setModalState(() => submitting = false);
                         if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error));
                       }
                     },
                     style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accountantColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                     child: submitting ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('CREATE INVOICE', style: TextStyle(fontWeight: FontWeight.bold)),
                   ),
                ),
              ),
            ]),
          );
        }
      ),
    );
  }
}

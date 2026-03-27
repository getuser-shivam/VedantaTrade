import 'package:flutter/material.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';
import 'package:vedanta_trade/shared/app_scaffold.dart';
import 'package:vedanta_trade/shared/widgets.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_trade/features/auth/presentation/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:vedanta_trade/core/api_config.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});
  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  List<dynamic> _entries = [];
  bool _loading = true;
  String _accountHead = 'ALL';

  @override
  void initState() { super.initState(); _loadLedger(); }

  Future<void> _loadLedger() async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      final query = _accountHead == 'ALL' ? {} : {'accountHead': _accountHead};
      final res = await dio.get('${ApiConfig.baseUrl}/accounting/ledger', 
        queryParameters: query,
        options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}));
      if (mounted) setState(() { _entries = res.data['data'] ?? []; _loading = false; });
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
    double totalDr = 0, totalCr = 0;
    for (var e in _entries) {
      if (e['debitAmount'] != null) totalDr += (e['debitAmount'] as num).toDouble();
      if (e['creditAmount'] != null) totalCr += (e['creditAmount'] as num).toDouble();
    }

    return AppScaffold(
      title: 'General Ledger',
      roleColor: AppTheme.accountantColor,
      navItems: _navItems,
      selectedIndex: 2,
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppTheme.accountantColor))
        : Column(children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(children: [
                Expanded(child: StatCard(title: 'Total Dr', value: 'NPR ${totalDr.toInt()}', icon: Icons.arrow_outward_rounded, color: AppTheme.error)),
                const SizedBox(width: 16),
                Expanded(child: StatCard(title: 'Total Cr', value: 'NPR ${totalCr.toInt()}', icon: Icons.arrow_downward_rounded, color: AppTheme.success)),
                const SizedBox(width: 16),
                Expanded(child: StatCard(title: 'Balance', value: 'NPR ${(totalCr - totalDr).toInt()}', icon: Icons.account_balance_rounded, color: AppTheme.accountantColor)),
              ]),
            ),
            const Divider(height: 1),
            Expanded(
              child: _entries.isEmpty
                ? const Center(child: Text('No ledger entries found', style: TextStyle(color: Colors.white38)))
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _entries.length,
                    itemBuilder: (ctx, i) {
                      final e = _entries[i];
                      final isCr = (e['creditAmount'] as num?) != null && (e['creditAmount'] as num) > 0;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(12)),
                        child: Row(children: [
                          Container(width: 4, height: 30, decoration: BoxDecoration(color: isCr ? AppTheme.success : AppTheme.error, borderRadius: BorderRadius.circular(2))),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(e['description'] ?? 'No description', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                            Text('${e['entryDate'].toString().substring(0,10)} • ${e['accountHead']}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                          ])),
                          Text('NPR ${isCr ? e['creditAmount'] : e['debitAmount']}', style: TextStyle(color: isCr ? AppTheme.success : AppTheme.error, fontWeight: FontWeight.bold, fontSize: 14)),
                        ]),
                      );
                    },
                  ),
            ),
          ]),
    );
  }
}

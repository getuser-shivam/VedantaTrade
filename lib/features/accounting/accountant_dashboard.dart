import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';
import 'package:vedanta_trade/shared/app_scaffold.dart';
import 'package:vedanta_trade/shared/widgets.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_trade/providers/auth_provider.dart';
import 'package:dio/dio.dart';

class AccountantDashboard extends StatefulWidget {
  const AccountantDashboard({super.key});
  @override
  State<AccountantDashboard> createState() => _AccountantDashboardState();
}

class _AccountantDashboardState extends State<AccountantDashboard> {
  Map<String, dynamic>? _stats;
  List<dynamic> _recentInvoices = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      final headers = {'Authorization': 'Bearer ${auth.token}'};
      final [dashRes, invRes] = await Future.wait([
        dio.get('http://localhost:3001/api/accounting/dashboard', options: Options(headers: headers)),
        dio.get('http://localhost:3001/api/accounting/invoices?limit=5', options: Options(headers: headers)),
      ]);
      if (mounted) setState(() {
        _stats = dashRes.data['data'];
        _recentInvoices = invRes.data['data'] ?? [];
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() { _loading = false; _stats = {'totalReceivables': 0, 'totalPayables': 0, 'paidThisMonth': 0, 'overdueInvoices': 0}; });
    }
  }

  static const _navItems = [
    NavItem(label: 'Dashboard', icon: Icons.dashboard_rounded, route: '/accounting'),
    NavItem(label: 'Invoices', icon: Icons.receipt_long_rounded, route: '/accounting/invoices'),
    NavItem(label: 'Ledger', icon: Icons.book_rounded, route: '/accounting/ledger'),
    NavItem(label: 'GST Reports', icon: Icons.calculate_rounded, route: '/accounting/gst'),
    NavItem(label: 'MR Expenses', icon: Icons.account_balance_wallet_rounded, route: '/mr/expenses'),
    NavItem(label: 'Orders', icon: Icons.shopping_bag_rounded, route: '/orders'),
    NavItem(label: 'Profile', icon: Icons.person_rounded, route: '/profile'),
  ];

  String _inr(dynamic v) => '₹${(double.tryParse('$v') ?? 0).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}';

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Accounting Dashboard',
      roleColor: AppTheme.accountantColor,
      navItems: _navItems,
      selectedIndex: 0,
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppTheme.accountantColor))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Financial Overview', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 6),
              Text('Current Month — ${DateTime.now().year}', style: TextStyle(color: Colors.white.withOpacity(0.4))),
              const SizedBox(height: 24),
              GridView.count(
                crossAxisCount: 4, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 1.5,
                children: [
                  StatCard(title: 'Receivables', value: _inr(_stats?['totalReceivables']), icon: Icons.arrow_downward_rounded, color: AppTheme.success, subtitle: 'Outstanding from customers'),
                  StatCard(title: 'Payables', value: _inr(_stats?['totalPayables']), icon: Icons.arrow_upward_rounded, color: AppTheme.error, subtitle: 'Outstanding to suppliers'),
                  StatCard(title: 'Collected This Month', value: _inr(_stats?['paidThisMonth']), icon: Icons.check_circle_rounded, color: AppTheme.accountantColor),
                  StatCard(title: 'Overdue Invoices', value: '${_stats?['overdueInvoices'] ?? 0}', icon: Icons.warning_rounded, color: AppTheme.warning, subtitle: 'Requires immediate action'),
                ],
              ),
              const SizedBox(height: 24),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Cash Flow Chart
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(16)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const SectionHeader(title: 'Cash Flow (Last 6 Months)'),
                      const SizedBox(height: 20),
                      SizedBox(height: 180, child: BarChart(_buildCashFlowChart())),
                    ]),
                  ),
                ),
                const SizedBox(width: 16),
                // GST Summary
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(16)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const SectionHeader(title: 'GST Status'),
                      const SizedBox(height: 16),
                      _GstRow(label: 'CGST Collected', amount: '₹24,500', color: AppTheme.primary),
                      const SizedBox(height: 10),
                      _GstRow(label: 'SGST Collected', amount: '₹24,500', color: AppTheme.secondary),
                      const SizedBox(height: 10),
                      _GstRow(label: 'IGST Collected', amount: '₹8,200', color: AppTheme.accountantColor),
                      const Divider(height: 20),
                      _GstRow(label: 'Total GST', amount: '₹57,200', color: AppTheme.success, bold: true),
                    ]),
                  ),
                ),
              ]),
              const SizedBox(height: 24),
              SectionHeader(title: 'Recent Invoices', trailing: TextButton(onPressed: () {}, child: const Text('View All', style: TextStyle(color: AppTheme.accountantColor)))),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(16)),
                child: _recentInvoices.isEmpty
                  ? const Padding(padding: EdgeInsets.all(32), child: Center(child: Text('No invoices yet', style: TextStyle(color: Colors.white38))))
                  : Column(children: _recentInvoices.map<Widget>((inv) => _InvoiceRow(invoice: inv)).toList()),
              ),
            ]),
          ),
    );
  }

  BarChartData _buildCashFlowChart() {
    final inflow = [95000.0, 120000, 88000, 145000, 130000, 175000];
    final outflow = [60000.0, 80000, 70000, 90000, 85000, 110000];
    return BarChartData(
      barGroups: List.generate(6, (i) => BarChartGroupData(x: i, barRods: [
        BarChartRodData(toY: (inflow[i] as num).toDouble(), color: AppTheme.success, width: 10, borderRadius: BorderRadius.circular(4)),
        BarChartRodData(toY: (outflow[i] as num).toDouble(), color: AppTheme.error, width: 10, borderRadius: BorderRadius.circular(4)),
      ])),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
          const months = ['Oct','Nov','Dec','Jan','Feb','Mar'];
          return Text(months[v.toInt()], style: const TextStyle(color: Colors.white38, fontSize: 9));
        }, reservedSize: 20)),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
    );
  }
}

class _GstRow extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;
  final bool bold;
  const _GstRow({required this.label, required this.amount, required this.color, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      Text(label, style: TextStyle(color: bold ? Colors.white : Colors.white54, fontSize: 13)),
      const Spacer(),
      Text(amount, style: TextStyle(color: color, fontWeight: bold ? FontWeight.w700 : FontWeight.w500, fontSize: 13)),
    ]);
  }
}

class _InvoiceRow extends StatelessWidget {
  final Map<String, dynamic> invoice;
  const _InvoiceRow({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final statusColor = invoice['status'] == 'PAID' ? AppTheme.success : invoice['status'] == 'OVERDUE' ? AppTheme.error : AppTheme.warning;
    return ListTile(
      title: Text(invoice['invoiceNumber'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
      subtitle: Text(invoice['invoiceType'] ?? '', style: const TextStyle(color: Colors.white38, fontSize: 11)),
      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text('₹${invoice['totalAmount'] ?? 0}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
          child: Text(invoice['status'] ?? '', style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}

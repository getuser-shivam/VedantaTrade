import 'package:flutter/material.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';
import 'package:vedanta_trade/shared/app_scaffold.dart';
import 'package:vedanta_trade/shared/widgets.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_trade/features/authentication/presentation/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:vedanta_trade/core/api_config.dart';
import 'package:vedanta_trade/core/utils/vat_pdf_generator.dart';
import 'package:vedanta_trade/shared/widgets/toast_notification.dart';

class VatScreen extends StatefulWidget {
  const VatScreen({super.key});
  @override
  State<VatScreen> createState() => _VatScreenState();
}

class _VatScreenState extends State<VatScreen> {
  Map<String, dynamic>? _summary;
  List<dynamic> _records = [];
  bool _loading = true;
  int _month = DateTime.now().month;
  int _year = DateTime.now().year;

  @override
  void initState() { super.initState(); _loadVatData(); }

  Future<void> _loadVatData() async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      final res = await dio.get('${ApiConfig.baseUrl}/accounting/vat-report', 
        queryParameters: {'month': _month, 'year': _year},
        options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}));
      if (mounted) setState(() { 
        _summary = res.data['data']['summary']; 
        _records = res.data['data']['records'] ?? []; 
        _loading = false; 
      });
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
    return AppScaffold(
      title: 'VAT Filings & Reports',
      roleColor: AppTheme.accountantColor,
      navItems: _navItems,
      selectedIndex: 3,
      actions: [
        // Export PDF button
        IconButton(
          icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
          tooltip: 'Export IRDN PDF',
          onPressed: _loading || _summary == null ? null : _exportVatPdf,
        ),
      ],
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppTheme.accountantColor))
        : ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Row(children: [
                Expanded(child: StatCard(title: 'Taxable Amt', value: 'NPR ${_summary?['totalTaxable'] ?? 0}', icon: Icons.money_rounded, color: Colors.white60)),
                const SizedBox(width: 16),
                Expanded(child: StatCard(title: 'Total VAT', value: 'NPR ${_summary?['totalVat'] ?? 0}', icon: Icons.calculate_rounded, color: AppTheme.success)),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: StatCard(title: 'VAT on Sales', value: 'NPR ${_summary?['totalVatSales'] ?? 0}', icon: Icons.arrow_outward_rounded, color: AppTheme.primary)),
                const SizedBox(width: 16),
                Expanded(child: StatCard(title: 'VAT on Purchases', value: 'NPR ${_summary?['totalVatPurchases'] ?? 0}', icon: Icons.arrow_downward_rounded, color: AppTheme.secondary)),
                const SizedBox(width: 16),
                Expanded(child: StatCard(title: 'Net Payable', value: 'NPR ${_summary?['netVatPayable'] ?? 0}', icon: Icons.account_balance_rounded, color: AppTheme.accountantColor)),
              ]),
              const SizedBox(height: 32),
              const SectionHeader(title: 'Transaction Details'),
              const SizedBox(height: 16),
              ..._records.map((r) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.dividerDark)),
                child: Row(children: [
                   Icon(Icons.receipt_long_rounded, color: Colors.white24, size: 20),
                   const SizedBox(width: 14),
                   Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                     Text(r['invoice']?['invoiceNumber'] ?? 'N/A', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                     Text('Taxable: NPR ${r['taxableAmount']}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                   ])),
                   Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                     Text('VAT: NPR ${r['totalVat']}', style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold, fontSize: 14)),
                     Text('Rate: ${r['vatRate']}%', style: const TextStyle(color: Colors.white38, fontSize: 10)),
                   ]),
                ]),
              )),
              if (_records.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No records found for selected period', style: TextStyle(color: Colors.white38)))),
            ],
          ),
    );
  }

  Future<void> _exportVatPdf() async {
    try {
      await VatPdfGenerator.exportAndShare(
        month: _month,
        year: _year,
        summary: _summary!,
        records: _records,
      );
      if (mounted) {
        context.showSuccess('VAT report exported successfully');
      }
    } catch (e) {
      if (mounted) {
        context.showError('Failed to export VAT report: $e');
      }
    }
  }
}

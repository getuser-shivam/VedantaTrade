import 'package:flutter/material.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';
import 'package:vedanta_trade/shared/app_scaffold.dart';
import 'package:vedanta_trade/shared/widgets.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_trade/features/authentication/presentation/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:vedanta_trade/core/api_config.dart';

class ScraperScreen extends StatefulWidget {
  const ScraperScreen({super.key});
  @override
  State<ScraperScreen> createState() => _ScraperScreenState();
}

class _ScraperScreenState extends State<ScraperScreen> with SingleTickerProviderStateMixin {
  List<dynamic> _jobs = [];
  List<dynamic> _leads = [];
  bool _loading = true;
  late TabController _tabCtrl;
  String _source = 'PRACTO';
  String _targetType = 'DOCTOR';
  String _city = 'Mumbai';

  @override
  void initState() { super.initState(); _tabCtrl = TabController(length: 2, vsync: this); _loadData(); }

  Future<void> _loadData() async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
// final headers = {'Authorization': 'Bearer ${auth.token}'}; // TODO: Move to environment variables
      final [jobsRes, leadsRes] = await Future.wait([
        dio.get('${ApiConfig.baseUrl}/scraper/jobs', options: Options(headers: headers)),
        dio.get('${ApiConfig.baseUrl}/scraper/leads?status=RAW&limit=50', options: Options(headers: headers)),
      ]);
      if (mounted) setState(() {
        _jobs = jobsRes.data['data'] ?? [];
        _leads = leadsRes.data['data'] ?? [];
        _loading = false;
      });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _runScraper() async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      await dio.post('${ApiConfig.baseUrl}/scraper/run',
        data: {'source': _source, 'targetType': _targetType, 'city': _city},
        options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Scraper job queued! Run Python scraper to process.'), backgroundColor: AppTheme.success));
        _loadData();
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to start scraper'), backgroundColor: AppTheme.error));
    }
  }

  Future<void> _approveLead(int id) async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      await dio.post('${ApiConfig.baseUrl}/scraper/leads/$id/approve', options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}));
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Lead approved and converted!'), backgroundColor: AppTheme.success)); _loadData(); }
    } catch (_) {}
  }

  Future<void> _rejectLead(int id) async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      await dio.post('${ApiConfig.baseUrl}/scraper/leads/$id/reject', options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}));
      if (mounted) { _loadData(); }
    } catch (_) {}
  }

  static const _navItems = [
    NavItem(label: 'Admin Dashboard', icon: Icons.dashboard_rounded, route: '/admin'),
    NavItem(label: 'Users', icon: Icons.people_rounded, route: '/admin/users'),
    NavItem(label: 'Web Scraper', icon: Icons.travel_explore_rounded, route: '/admin/scraper'),
    NavItem(label: 'Products', icon: Icons.inventory_2_rounded, route: '/products'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Web Scraper — Lead Discovery',
      roleColor: AppTheme.secondary,
      navItems: _navItems,
      selectedIndex: 2,
      body: Column(children: [
        TabBar(controller: _tabCtrl, indicatorColor: AppTheme.secondary, labelColor: AppTheme.secondary, unselectedLabelColor: Colors.white38, tabs: [
          Tab(text: 'Scraper Jobs (${_jobs.length})'),
          Tab(text: 'Pending Leads (${_leads.length})'),
        ]),
        Expanded(
          child: TabBarView(controller: _tabCtrl, children: [
            // Tab 1: Scraper Control
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Config Panel
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(16)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const SectionHeader(title: '🔍 Configure Scraper'),
                    const SizedBox(height: 20),
                    Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Source', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        const SizedBox(height: 8),
                        DropdownButton<String>(value: _source, dropdownColor: AppTheme.cardDark, style: const TextStyle(color: Colors.white), isExpanded: true, underline: Container(height: 1, color: AppTheme.dividerDark),
                          items: const [DropdownMenuItem(value: 'PRACTO', child: Text('Practo')), DropdownMenuItem(value: 'JUSTDIAL', child: Text('Justdial')), DropdownMenuItem(value: 'INDIAMART', child: Text('IndiaMart')), DropdownMenuItem(value: 'NMC', child: Text('NMC Registry'))],
                          onChanged: (v) => setState(() => _source = v!)),
                      ])),
                      const SizedBox(width: 20),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Target Type', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        const SizedBox(height: 8),
                        DropdownButton<String>(value: _targetType, dropdownColor: AppTheme.cardDark, style: const TextStyle(color: Colors.white), isExpanded: true, underline: Container(height: 1, color: AppTheme.dividerDark),
                          items: const [DropdownMenuItem(value: 'DOCTOR', child: Text('Doctors')), DropdownMenuItem(value: 'HOSPITAL', child: Text('Hospitals')), DropdownMenuItem(value: 'STOCKIST', child: Text('Stockists')), DropdownMenuItem(value: 'RETAILER', child: Text('Retailers'))],
                          onChanged: (v) => setState(() => _targetType = v!)),
                      ])),
                      const SizedBox(width: 20),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('City', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: TextEditingController(text: _city),
                          onChanged: (v) => _city = v,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(hintText: 'e.g. Mumbai'),
                        ),
                      ])),
                    ]),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _runScraper,
                        icon: const Icon(Icons.travel_explore_rounded),
                        label: const Text('Start Scraping Job'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondary, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.withOpacity(0.3))),
                      child: const Text('💡 After creating a job, run:\npython tool/scraper/run_scraper.py --job-id <ID>', style: TextStyle(color: Colors.blue, fontSize: 12, fontFamily: 'monospace'))),
                  ]),
                ),
                const SizedBox(height: 24),
                const SectionHeader(title: 'Job History'),
                const SizedBox(height: 12),
                ..._jobs.map((job) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: job['status'] == 'COMPLETED' ? AppTheme.success : job['status'] == 'RUNNING' ? AppTheme.warning : Colors.white38)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${job['source']} → ${job['targetType']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                      Text('City: ${job['city'] ?? 'All'} • Leads: ${job['_count']?['leads'] ?? 0}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                    ])),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: (job['status'] == 'COMPLETED' ? AppTheme.success : AppTheme.warning).withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                      child: Text(job['status'] ?? '', style: TextStyle(color: job['status'] == 'COMPLETED' ? AppTheme.success : AppTheme.warning, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ]),
                )),
              ]),
            ),
            // Tab 2: Pending Leads
            _leads.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.search_off_rounded, size: 48, color: Colors.white24),
                  const SizedBox(height: 12),
                  const Text('No pending leads. Run a scraper job to find new leads.', style: TextStyle(color: Colors.white38)),
                ]))
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _leads.length,
                  itemBuilder: (ctx, i) {
                    final lead = _leads[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(14)),
                      child: Column(children: [
                        Row(children: [
                          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppTheme.secondary.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                            child: Icon(_leadIcon(lead['leadType']), color: AppTheme.secondary, size: 18)),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(lead['name'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                            Text('${lead['leadType']} • ${lead['city'] ?? ''}, ${lead['state'] ?? ''}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                            if (lead['specialization'] != null) Text(lead['specialization'], style: const TextStyle(color: Colors.white54, fontSize: 11)),
                            if (lead['phone'] != null) Text(lead['phone'], style: TextStyle(color: AppTheme.secondary, fontSize: 12)),
                          ])),
                          Row(children: [
                            IconButton(icon: const Icon(Icons.check_circle_rounded, color: AppTheme.success), tooltip: 'Approve & Convert', onPressed: () => _approveLead(lead['id'])),
                            IconButton(icon: const Icon(Icons.cancel_rounded, color: AppTheme.error), tooltip: 'Reject', onPressed: () => _rejectLead(lead['id'])),
                          ]),
                        ]),
                      ]),
                    );
                  },
                ),
          ]),
        ),
      ]),
    );
  }

  IconData _leadIcon(String? type) {
    switch (type) {
      case 'DOCTOR': return Icons.health_and_safety_rounded;
      case 'HOSPITAL': return Icons.local_hospital_rounded;
      case 'STOCKIST': return Icons.warehouse_rounded;
      case 'RETAILER': return Icons.storefront_rounded;
      default: return Icons.person_rounded;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';
import 'package:vedanta_trade/shared/app_scaffold.dart';
import 'package:vedanta_trade/shared/widgets.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_trade/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:vedanta_trade/core/api_config.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});
  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  List<dynamic> _recentVisits = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      final res = await dio.get('${ApiConfig.baseUrl}/mr/visits', options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}));
      if (mounted) setState(() { _recentVisits = (res.data['data'] as List? ?? []).take(5).toList(); _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  static const _navItems = [
    NavItem(label: 'Dashboard', icon: Icons.dashboard_rounded, route: '/doctor'),
    NavItem(label: 'Orders', icon: Icons.shopping_bag_rounded, route: '/orders'),
    NavItem(label: 'Products', icon: Icons.inventory_2_rounded, route: '/products'),
    NavItem(label: 'Profile', icon: Icons.person_rounded, route: '/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return AppScaffold(
      title: 'Doctor Portal',
      roleColor: AppTheme.doctorColor,
      navItems: _navItems,
      selectedIndex: 0,
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppTheme.doctorColor))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Profile Banner
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppTheme.doctorColor.withOpacity(0.3), AppTheme.primary.withOpacity(0.1)]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(children: [
                  CircleAvatar(radius: 36, backgroundColor: AppTheme.doctorColor.withOpacity(0.2), child: Icon(Icons.person_rounded, size: 40, color: AppTheme.doctorColor)),
                  const SizedBox(width: 20),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(auth.userName ?? 'Dr.', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                    const Text('General Physician  •  MBBS, MD', style: TextStyle(color: Colors.white60, fontSize: 13)),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.location_on_rounded, size: 14, color: Colors.white38),
                      const SizedBox(width: 4),
                      const Text('Verma Clinic, Mumbai', style: TextStyle(color: Colors.white38, fontSize: 12)),
                    ]),
                  ]),
                ]),
              ),
              const SizedBox(height: 24),
              GridView.count(
                crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 1.6,
                children: const [
                  StatCard(title: 'MR Visits This Month', value: '8', icon: Icons.group_rounded, color: AppTheme.mrColor),
                  StatCard(title: 'Samples Received', value: '24', icon: Icons.medication_rounded, color: AppTheme.doctorColor),
                  StatCard(title: 'Pending Orders', value: '2', icon: Icons.pending_actions_rounded, color: AppTheme.warning),
                ],
              ),
              const SizedBox(height: 24),
              // Promoted Products
              const SectionHeader(title: '🆕 New Products from Vedanta'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(16)),
                child: Column(children: [
                  _ProductRow(name: 'Amoxicillin 500mg', by: 'Vedanta Labs', category: 'Antibiotic', isNew: true),
                  const Divider(color: Color(0xFF2D3057)),
                  _ProductRow(name: 'Metformin 500mg', by: 'Vedanta Labs', category: 'Anti-diabetic', isNew: false),
                  const Divider(color: Color(0xFF2D3057)),
                  _ProductRow(name: 'Vitamin D3 60000 IU', by: 'Vedanta Labs', category: 'Supplement', isNew: true),
                ]),
              ),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Recent MR Visits'),
              const SizedBox(height: 12),
              _recentVisits.isEmpty
                ? Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(16)), child: const Center(child: Text('No recent visits', style: TextStyle(color: Colors.white38))))
                : Container(
                    decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(16)),
                    child: Column(children: _recentVisits.map<Widget>((v) => ListTile(
                      leading: CircleAvatar(backgroundColor: AppTheme.mrColor.withOpacity(0.2), child: Icon(Icons.medical_services_rounded, color: AppTheme.mrColor, size: 18)),
                      title: Text(v['user']?['name'] ?? 'MR', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                      subtitle: Text(v['visitType']?.toString().replaceAll('_', ' ') ?? '', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                      trailing: Text(v['visitDate']?.toString().substring(0, 10) ?? '', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                    )).toList()),
                  ),
            ]),
          ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final String name, by, category;
  final bool isNew;
  const _ProductRow({required this.name, required this.by, required this.category, required this.isNew});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: AppTheme.doctorColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.medication_rounded, color: AppTheme.doctorColor, size: 20)),
      title: Row(children: [
        Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
        if (isNew) ...[const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppTheme.success.withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: const Text('NEW', style: TextStyle(color: AppTheme.success, fontSize: 9, fontWeight: FontWeight.w700)))],
      ]),
      subtitle: Text('$by • $category', style: const TextStyle(color: Colors.white38, fontSize: 11)),
    );
  }
}

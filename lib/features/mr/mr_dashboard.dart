import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';
import 'package:vedanta_trade/shared/app_scaffold.dart';
import 'package:vedanta_trade/shared/widgets.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_trade/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:vedanta_trade/core/api_config.dart';

class MrDashboard extends StatefulWidget {
  const MrDashboard({super.key});
  @override
  State<MrDashboard> createState() => _MrDashboardState();
}

class _MrDashboardState extends State<MrDashboard> {
  Map<String, dynamic>? _stats;
  List<dynamic> _recentVisits = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      final headers = {'Authorization': 'Bearer ${auth.token}'};
      final [dashRes, visitsRes] = await Future.wait([
        dio.get('${ApiConfig.baseUrl}/mr/dashboard', options: Options(headers: headers)),
        dio.get('${ApiConfig.baseUrl}/mr/visits', options: Options(headers: headers)),
      ]);
      if (mounted) setState(() {
        _stats = dashRes.data['data'];
        _recentVisits = (visitsRes.data['data'] as List).take(5).toList();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() { _loading = false; _stats = {'visitsThisMonth': 0, 'visitsToday': 0, 'pendingExpenses': 0, 'samplesDistributed': 0}; });
    }
  }

  static const _navItems = [
    NavItem(label: 'Dashboard', icon: Icons.dashboard_rounded, route: '/mr'),
    NavItem(label: 'Doctor Visits', icon: Icons.medical_services_rounded, route: '/mr/visits'),
    NavItem(label: 'Tour Plan', icon: Icons.map_rounded, route: '/mr/tour-plan'),
    NavItem(label: 'Expenses', icon: Icons.receipt_long_rounded, route: '/mr/expenses'),
    NavItem(label: 'Doctor List', icon: Icons.health_and_safety_rounded, route: '/doctors-list'),
    NavItem(label: 'Orders', icon: Icons.shopping_bag_rounded, route: '/orders'),
    NavItem(label: 'Profile', icon: Icons.person_rounded, route: '/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'MR Dashboard',
      roleColor: AppTheme.mrColor,
      navItems: _navItems,
      selectedIndex: 0,
      fab: FloatingActionButton.extended(
        onPressed: () => context.go('/mr/visits'),
        backgroundColor: AppTheme.mrColor,
        icon: const Icon(Icons.add_location_alt_rounded),
        label: const Text('Log Visit'),
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppTheme.mrColor))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Greeting
              Text('Today, ${DateFormat('d MMM yyyy').format(DateTime.now())}', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
              const Text('Good Morning, Ramesh! 👋', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 24),
              // Stats
              GridView.count(
                crossAxisCount: 4, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 1.4,
                children: [
                  StatCard(title: 'Visits Today', value: '${_stats?['visitsToday'] ?? 0}', icon: Icons.today_rounded, color: AppTheme.mrColor),
                  StatCard(title: 'This Month', value: '${_stats?['visitsThisMonth'] ?? 0}', icon: Icons.calendar_month_rounded, color: AppTheme.primary, subtitle: '/${_stats?['mrProfile']?['id'] != null ? 60 : 60} target'),
                  StatCard(title: 'Samples Given', value: '${_stats?['samplesDistributed'] ?? 0}', icon: Icons.medication_rounded, color: AppTheme.secondary),
                  StatCard(title: 'Pending Claims', value: '${_stats?['pendingExpenses'] ?? 0}', icon: Icons.account_balance_wallet_rounded, color: AppTheme.warning),
                ],
              ),
              const SizedBox(height: 24),
              // Target Progress
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(16)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SectionHeader(title: 'Monthly Target Progress'),
                  const SizedBox(height: 16),
                  _TargetRow(label: 'Visits', achieved: _stats?['visitsThisMonth'] ?? 0, target: 60, color: AppTheme.mrColor),
                  const SizedBox(height: 12),
                  _TargetRow(label: 'Orders (₹)', achieved: 75000, target: 250000, color: AppTheme.primary),
                  const SizedBox(height: 12),
                  _TargetRow(label: 'Samples', achieved: _stats?['samplesDistributed'] ?? 0, target: 200, color: AppTheme.secondary),
                ]),
              ),
              const SizedBox(height: 24),
              // Recent Visits
              SectionHeader(title: 'Recent Visits', trailing: TextButton(onPressed: () => context.go('/mr/visits'), child: const Text('View All', style: TextStyle(color: AppTheme.mrColor)))),
              const SizedBox(height: 12),
              if (_recentVisits.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(16)),
                  child: Center(child: Column(children: [
                    Icon(Icons.medical_services_rounded, size: 40, color: AppTheme.mrColor.withOpacity(0.4)),
                    const SizedBox(height: 12),
                    const Text('No visits yet. Log your first visit!', style: TextStyle(color: Colors.white38)),
                  ])),
                )
              else
                ...(_recentVisits.map((v) => _VisitCard(visit: v)).toList()),
            ]),
          ),
    );
  }
}

class _TargetRow extends StatelessWidget {
  final String label;
  final num achieved;
  final num target;
  final Color color;
  const _TargetRow({required this.label, required this.achieved, required this.target, required this.color});

  @override
  Widget build(BuildContext context) {
    final pct = (achieved / target).clamp(0.0, 1.0);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13)),
        const Spacer(),
        Text('$achieved / $target', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(value: pct.toDouble(), backgroundColor: Colors.white10, color: color, minHeight: 6),
      ),
    ]);
  }
}

class _VisitCard extends StatelessWidget {
  final Map<String, dynamic> visit;
  const _VisitCard({required this.visit});

  @override
  Widget build(BuildContext context) {
    final doctor = visit['doctor'];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        CircleAvatar(backgroundColor: AppTheme.mrColor.withOpacity(0.2), child: Icon(Icons.person_rounded, color: AppTheme.mrColor)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(doctor?['name'] ?? 'Unknown Doctor', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
          Text(doctor?['clinicName'] ?? 'Clinic', style: const TextStyle(color: Colors.white38, fontSize: 12)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppTheme.mrColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
            child: Text(visit['visitType']?.toString().replaceAll('_', ' ') ?? '', style: const TextStyle(color: AppTheme.mrColor, fontSize: 10, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 4),
          Text(DateFormat('d MMM').format(DateTime.parse(visit['visitDate'])), style: const TextStyle(color: Colors.white38, fontSize: 11)),
        ]),
      ]),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';
import 'package:vedanta_trade/shared/app_scaffold.dart';
import 'package:vedanta_trade/shared/widgets.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_trade/providers/auth_provider.dart';
import 'package:dio/dio.dart';

class VisitLogScreen extends StatefulWidget {
  const VisitLogScreen({super.key});
  @override
  State<VisitLogScreen> createState() => _VisitLogScreenState();
}

class _VisitLogScreenState extends State<VisitLogScreen> {
  List<dynamic> _visits = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _loadVisits(); }

  Future<void> _loadVisits() async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      final res = await dio.get('${ApiConfig.baseUrl}/mr/visits', options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}));
      if (mounted) setState(() { _visits = res.data['data'] ?? []; _loading = false; });
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
    return AppScaffold(
      title: 'Doctor Visit Tracker',
      roleColor: AppTheme.mrColor,
      navItems: _navItems,
      selectedIndex: 1,
      fab: FloatingActionButton.extended(
        onPressed: () => _showAddVisitDialog(),
        backgroundColor: AppTheme.mrColor,
        icon: const Icon(Icons.add_location_alt_rounded),
        label: const Text('Log Visit'),
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppTheme.mrColor))
        : Column(children: [
            // Header stats
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(children: [
                Expanded(child: StatCard(title: 'Total Visits', value: '${_visits.length}', icon: Icons.medical_services_rounded, color: AppTheme.mrColor)),
                const SizedBox(width: 16),
                Expanded(child: StatCard(title: 'This Week', value: '${_visits.where((v) { try { return DateTime.parse(v['visitDate'].toString()).isAfter(DateTime.now().subtract(const Duration(days: 7))); } catch (_) { return false; } }).length}', icon: Icons.calendar_month_rounded, color: AppTheme.primary)),
                const SizedBox(width: 16),
                Expanded(child: StatCard(title: 'Pending Follow-ups', value: '${_visits.where((v) => v['nextFollowUp'] != null).length}', icon: Icons.schedule_rounded, color: AppTheme.warning)),
              ]),
            ),
            const Divider(height: 1),
            // Visit List
            Expanded(
              child: _visits.isEmpty
                ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.medical_services_rounded, size: 56, color: AppTheme.mrColor.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    const Text('No visits logged yet', style: TextStyle(color: Colors.white38, fontSize: 16)),
                    const SizedBox(height: 8),
                    const Text('Tap "+ Log Visit" to record your first doctor visit', style: TextStyle(color: Colors.white24, fontSize: 13)),
                  ]))
                : ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: _visits.length,
                    itemBuilder: (ctx, i) {
                      final v = _visits[i];
                      final doctor = v['doctor'];
                      final hasFollowUp = v['nextFollowUp'] != null;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.dividerDark)),
                        child: Column(children: [
                          Row(children: [
                            CircleAvatar(radius: 22, backgroundColor: AppTheme.mrColor.withOpacity(0.15), child: Icon(Icons.person_rounded, color: AppTheme.mrColor, size: 22)),
                            const SizedBox(width: 14),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(doctor?['name'] ?? 'Unknown Doctor', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                              Text('${doctor?['specialization'] ?? ''} • ${doctor?['clinicName'] ?? ''}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                            ])),
                            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: AppTheme.mrColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                                child: Text(v['visitType']?.toString().replaceAll('_', ' ') ?? '', style: const TextStyle(color: AppTheme.mrColor, fontSize: 11, fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(height: 4),
                              Text(v['visitDate']?.toString().substring(0, 10) ?? '', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                            ]),
                          ]),
                          if (v['notes'] != null && (v['notes'] as String).isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(8)),
                              child: Text(v['notes'], style: const TextStyle(color: Colors.white60, fontSize: 12)),
                            ),
                          ],
                          if (hasFollowUp) ...[
                            const SizedBox(height: 10),
                            Row(children: [
                              const Icon(Icons.schedule_rounded, size: 14, color: Colors.orange),
                              const SizedBox(width: 6),
                              Text('Follow-up: ${v['nextFollowUp']?.toString().substring(0, 10)}', style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w500)),
                            ]),
                          ],
                        ]),
                      );
                    },
                  ),
            ),
          ]),
    );
  }

  void _showAddVisitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: const Text('Log Doctor Visit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: const Text('Connect the backend and use the full visit form to log a new visit with GPS check-in, samples, and notes.', style: TextStyle(color: Colors.white54)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close', style: TextStyle(color: AppTheme.mrColor))),
        ],
      ),
    );
  }
}

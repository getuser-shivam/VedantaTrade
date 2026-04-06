import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';
import 'package:vedanta_trade/shared/app_scaffold.dart';
import 'package:vedanta_trade/shared/widgets/glassmorphic_widgets.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_trade/features/authentication/presentation/providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';
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
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
// final headers = {'Authorization': 'Bearer ${auth.token}'}; // TODO: Move to environment variables
      
      final res = await dio.get(
        '${ApiConfig.baseUrl}/mr/dashboard',
        options: Options(headers: headers),
      );
      
      if (mounted) {
        setState(() {
          _stats = res.data['data']?['stats'];
          _recentVisits = res.data['data']?['recentVisits'] ?? [];
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _stats = {
            'visitsToday': 0,
            'visitsThisMonth': 0,
            'samplesDistributed': 0,
            'pendingExpenses': 0,
          };
          _recentVisits = [];
          _loading = false;
        });
      }
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
    return AppScaffold(
      title: 'MR Dashboard',
      roleColor: AppTheme.mrColor,
      navItems: _navItems,
      selectedIndex: 0,
      fab: FloatingActionButton.extended(
        onPressed: () => context.push('/mr/visits'),
        backgroundColor: AppTheme.mrColor,
        icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white),
        label: const Text('Log Visit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: LoadingAnimation())
          : LayoutBuilder(
              builder: (context, constraints) {
                final isSmall = constraints.maxWidth < 600;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Today, ${DateFormat('d MMM yyyy').format(DateTime.now())}',
                                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                              ),
                              const Text(
                                'Good Morning, Ramesh! 👋',
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                            ],
                          ),
                          const Spacer(),
                          const CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.white10,
                            child: Icon(Icons.notifications_outlined, color: Colors.white70),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      // Stats Grid
                      GridView.count(
                        crossAxisCount: isSmall ? 2 : 4,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.3,
                        children: [
                          GlassmorphicStatCard(
                            title: 'Visits Today',
                            value: '${_stats?['visitsToday'] ?? 0}',
                            icon: Icons.today_rounded,
                            color: AppTheme.mrColor,
                          ),
                          GlassmorphicStatCard(
                            title: 'This Month',
                            value: '${_stats?['visitsThisMonth'] ?? 0}',
                            icon: Icons.calendar_month_rounded,
                            color: AppTheme.primary,
                          ),
                          GlassmorphicStatCard(
                            title: 'Samples Given',
                            value: '${_stats?['samplesDistributed'] ?? 0}',
                            icon: Icons.medication_rounded,
                            color: AppTheme.secondary,
                          ),
                          GlassmorphicStatCard(
                            title: 'Pending Claims',
                            value: '₹${_stats?['pendingExpenses'] ?? 0}',
                            icon: Icons.account_balance_wallet_rounded,
                            color: AppTheme.warning,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      // Target Progress Section
                      const Text(
                        'Performance Metrics',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      GlassmorphicCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            _TargetRow(label: 'Visit Target', achieved: _stats?['visitsThisMonth'] ?? 0, target: 60, color: AppTheme.mrColor),
                            const SizedBox(height: 20),
                            const _TargetRow(label: 'Revenue (MTD)', achieved: 185000, target: 250000, color: AppTheme.primary),
                            const SizedBox(height: 20),
                            _TargetRow(label: 'Samples Distributed', achieved: _stats?['samplesDistributed'] ?? 0, target: 200, color: AppTheme.secondary),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Live Map View for Janakpur territory
                      const Text(
                        'Live Territory Map (Janakpur)',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      GlassmorphicCard(
                        height: 300,
                        padding: EdgeInsets.zero,
                        clipBehavior: Clip.hardEdge,
                        child: FlutterMap(
                          options: const MapOptions(
                            initialCenter: LatLng(26.7288, 85.9260),
                            initialZoom: 14.0,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'np.com.vedantatrade.app',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: const LatLng(26.7288, 85.9260),
                                  width: 40,
                                  height: 40,
                                  child: Icon(Icons.person_pin_circle_rounded, color: AppTheme.mrColor, size: 38),
                                ),
                                Marker(
                                  point: const LatLng(26.7310, 85.9220),
                                  width: 40,
                                  height: 40,
                                  child: Icon(Icons.local_hospital_rounded, color: AppTheme.doctorColor, size: 32),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Recent Visits
                      Row(
                        children: [
                          const Text(
                            'Recent Field Visits',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => context.push('/mr/visits'),
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_recentVisits.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text('No visits logged today', style: TextStyle(color: Colors.white38)),
                          ),
                        )
                      else
                        ...(_recentVisits.map((v) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GlassmorphicListItem(
                                title: v['doctor']?['name'] ?? 'Unknown Doctor',
                                subtitle: '${v['doctor']?['clinicName']} • ${DateFormat('jm').format(DateTime.parse(v['visitDate']))}',
                                leadingIcon: Icons.medical_services_rounded,
                                iconColor: AppTheme.mrColor,
                                trailingIcon: Icons.chevron_right_rounded,
                                onTap: () {},
                              ),
                            )).toList()),
                    ],
                  ),
                );
              },
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
            const Spacer(),
            Text(
              '${(pct * 100).toStringAsFixed(0)}%',
              style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(seconds: 1),
              height: 8,
              width: MediaQuery.of(context).size.width * 0.7 * pct,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.5)],
                ),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '$achieved / $target units',
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ),
      ],
    );
  }
}

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
import 'package:vedanta_trade/shared/widgets/responsive/responsive_layout.dart';
import 'package:vedanta_trade/shared/widgets/responsive/responsive_grid.dart';
import 'package:vedanta_trade/shared/widgets/responsive/responsive_container.dart';
import 'package:vedanta_trade/shared/widgets/responsive/responsive_row.dart';
import 'package:vedanta_trade/shared/widgets/responsive/responsive_column.dart';

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
          : ResponsiveLayout(
              mobile: _buildMobileLayout(),
              tablet: _buildTabletLayout(),
              desktop: _buildDesktopLayout(),
            ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ResponsiveColumn(
        spacing: 24,
        children: [
          _buildGreetingSection(),
          _buildStatsGrid(isMobile: true),
          _buildPerformanceMetrics(),
          _buildLiveMap(),
          _buildRecentVisits(),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ResponsiveColumn(
        spacing: 32,
        children: [
          _buildGreetingSection(),
          _buildStatsGrid(isMobile: false),
          ResponsiveRow(
            spacing: 24,
            children: [
              Expanded(
                flex: 1,
                child: _buildPerformanceMetrics(),
              ),
              Expanded(
                flex: 1,
                child: _buildRecentVisits(),
              ),
            ],
          ),
          _buildLiveMap(),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: ResponsiveColumn(
        spacing: 32,
        children: [
          _buildGreetingSection(),
          _buildStatsGrid(isMobile: false),
          ResponsiveRow(
            spacing: 32,
            children: [
              Expanded(
                flex: 1,
                child: _buildPerformanceMetrics(),
              ),
              Expanded(
                flex: 1,
                child: _buildRecentVisits(),
              ),
            ],
          ),
          _buildLiveMap(),
        ],
      ),
    );
  }
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

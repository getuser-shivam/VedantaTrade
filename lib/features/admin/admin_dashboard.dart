import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';
import 'package:vedanta_trade/shared/app_scaffold.dart';
import 'package:vedanta_trade/shared/widgets.dart';
import 'package:vedanta_trade/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:vedanta_trade/core/api_config.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Map<String, dynamic>? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      final res = await dio.get(
        '${ApiConfig.baseUrl}/users/admin/dashboard',
        options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}),
      );
      if (res.data['success'] == true && mounted) {
        setState(() { _stats = res.data['data']; _loading = false; });
      }
    } catch (_) {
      if (mounted) setState(() { _loading = false; _stats = {'totalUsers': 0, 'totalMRs': 0, 'totalDoctors': 0, 'totalStockists': 0, 'totalRetailers': 0, 'totalOrders': 0, 'pendingLeads': 0}; });
    }
  }

  static const _navItems = [
    NavItem(label: 'Dashboard', icon: Icons.dashboard_rounded, route: '/admin'),
    NavItem(label: 'Users', icon: Icons.people_rounded, route: '/admin/users'),
    NavItem(label: 'Upload Media', icon: Icons.cloud_upload_rounded, route: '/admin/media-upload'),
    NavItem(label: 'Products', icon: Icons.inventory_2_rounded, route: '/products'),
    NavItem(label: 'Orders', icon: Icons.shopping_bag_rounded, route: '/orders'),
    NavItem(label: 'Doctors', icon: Icons.health_and_safety_rounded, route: '/doctors-list'),
    NavItem(label: 'Web Scraper', icon: Icons.travel_explore_rounded, route: '/admin/scraper'),
    NavItem(label: 'Reports', icon: Icons.bar_chart_rounded, route: '/accounting'),
    NavItem(label: 'Profile', icon: Icons.person_rounded, route: '/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Admin Dashboard',
      roleColor: AppTheme.adminColor,
      navItems: _navItems,
      selectedIndex: 0,
      actions: [
        IconButton(icon: const Icon(Icons.refresh_rounded, color: Colors.white54), onPressed: _loadStats),
        const SizedBox(width: 8),
      ],
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppTheme.adminColor))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome
                Row(children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Platform Overview', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                    Text('Vedanta TradeLink Enterprise', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
                  ]),
                ]),
                const SizedBox(height: 24),
                // Stats Grid
                GridView.count(
                  crossAxisCount: 4, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 1.5,
                  children: [
                    StatCard(title: 'Total Users', value: '${_stats?['totalUsers'] ?? 0}', icon: Icons.people_rounded, color: AppTheme.adminColor),
                    StatCard(title: 'Medical Reps', value: '${_stats?['totalMRs'] ?? 0}', icon: Icons.medical_services_rounded, color: AppTheme.mrColor),
                    StatCard(title: 'Doctors', value: '${_stats?['totalDoctors'] ?? 0}', icon: Icons.health_and_safety_rounded, color: AppTheme.doctorColor),
                    StatCard(title: 'Stockists', value: '${_stats?['totalStockists'] ?? 0}', icon: Icons.warehouse_rounded, color: AppTheme.stockistColor),
                    StatCard(title: 'Retailers', value: '${_stats?['totalRetailers'] ?? 0}', icon: Icons.storefront_rounded, color: AppTheme.retailerColor),
                    StatCard(title: 'Orders', value: '${_stats?['totalOrders'] ?? 0}', icon: Icons.shopping_bag_rounded, color: AppTheme.primary),
                    StatCard(title: 'Pending Leads', value: '${_stats?['pendingLeads'] ?? 0}', icon: Icons.travel_explore_rounded, color: AppTheme.secondary, subtitle: 'Tap to review scraped leads'),
                    StatCard(title: 'Products', value: '50+', icon: Icons.inventory_2_rounded, color: AppTheme.success),
                  ],
                ),
                const SizedBox(height: 32),
                // Charts Row
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Sales Chart
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(16)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const SectionHeader(title: 'Monthly Sales Trend'),
                        const SizedBox(height: 20),
                        SizedBox(height: 180, child: LineChart(_buildSalesChart())),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Role Distribution
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(16)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const SectionHeader(title: 'Supply Chain'),
                        const SizedBox(height: 20),
                        SizedBox(height: 180, child: PieChart(_buildPieChart())),
                      ]),
                    ),
                  ),
                ]),
                const SizedBox(height: 24),
                // Quick Actions
                const SectionHeader(title: 'Quick Actions'),
                const SizedBox(height: 16),
                Row(children: [
                  _QuickAction(label: 'Add User', icon: Icons.person_add_rounded, color: AppTheme.adminColor, onTap: () => context.go('/admin/users')),
                  const SizedBox(width: 12),
                  _QuickAction(label: 'Run Scraper', icon: Icons.travel_explore_rounded, color: AppTheme.secondary, onTap: () => context.go('/admin/scraper')),
                  const SizedBox(width: 12),
                  _QuickAction(label: 'View Invoices', icon: Icons.receipt_long_rounded, color: AppTheme.accountantColor, onTap: () => context.go('/accounting/invoices')),
                  const SizedBox(width: 12),
                  _QuickAction(label: 'Upload Media', icon: Icons.cloud_upload_rounded, color: AppTheme.mrColor, onTap: () => context.go('/admin/media-upload')),
                ]),
              ],
            ),
          ),
    );
  }

  LineChartData _buildSalesChart() {
    final spots = [
      const FlSpot(0, 80000), const FlSpot(1, 120000), const FlSpot(2, 95000),
      const FlSpot(3, 145000), const FlSpot(4, 130000), const FlSpot(5, 175000),
    ];
    return LineChartData(
      gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: AppTheme.dividerDark, strokeWidth: 1)),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text('₹${(v/1000).toStringAsFixed(0)}k', style: const TextStyle(color: Colors.white38, fontSize: 9)), reservedSize: 40)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
          const months = ['Oct','Nov','Dec','Jan','Feb','Mar'];
          return Text(months[v.toInt()], style: const TextStyle(color: Colors.white38, fontSize: 10));
        }, reservedSize: 20)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [LineChartBarData(
        spots: spots, isCurved: true, color: AppTheme.primary, barWidth: 3,
        belowBarData: BarAreaData(show: true, color: AppTheme.primary.withOpacity(0.1)),
        dotData: const FlDotData(show: false),
      )],
    );
  }

  PieChartData _buildPieChart() {
    return PieChartData(
      sections: [
        PieChartSectionData(value: 35, color: AppTheme.mrColor, title: 'MR\n35%', radius: 60, titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
        PieChartSectionData(value: 30, color: AppTheme.stockistColor, title: 'Stockist\n30%', radius: 60, titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
        PieChartSectionData(value: 25, color: AppTheme.retailerColor, title: 'Retail\n25%', radius: 60, titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
        PieChartSectionData(value: 10, color: AppTheme.doctorColor, title: 'Dir\n10%', radius: 60, titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
      ],
      centerSpaceRadius: 30,
      sectionsSpace: 3,
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))),
          child: Row(children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
          ]),
        ),
      ),
    );
  }
}

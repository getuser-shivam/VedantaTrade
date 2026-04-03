import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/theme/app_theme.dart';
import '../../shared/widgets/glassmorphic_widgets.dart';
import '../../shared/widgets/enhanced_loading_widget.dart';

class GalleryDashboardScreen extends StatefulWidget {
  const GalleryDashboardScreen({Key? key}) : super(key: key);

  @override
  State<GalleryDashboardScreen> createState() => _GalleryDashboardScreenState();
}

class _GalleryDashboardScreenState extends State<GalleryDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _statsController;
  late AnimationController _chartController;
  late Animation<double> _statsAnimation;
  late Animation<double> _chartAnimation;

  @override
  void initState() {
    super.initState();
    _statsController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _statsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _statsController,
      curve: Curves.easeOutCubic,
    ));
    
    _chartAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chartController,
      curve: Curves.easeOutCubic,
    ));
    
    _startAnimations();
  }

  @override
  void dispose() {
    _statsController.dispose();
    _chartController.dispose();
    super.dispose();
  }

  void _startAnimations() {
    _statsController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _chartController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: Text(
          'Gallery Dashboard',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.surfaceDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewCards(),
            const SizedBox(height: 24),
            _buildChartsSection(),
            const SizedBox(height: 24),
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards() {
    return FadeTransition(
      opacity: _statsAnimation,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Versions',
                  '12',
                  Icons.history,
                  AppTheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Featured Versions',
                  '4',
                  Icons.star,
                  AppTheme.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Stable Releases',
                  '3',
                  Icons.verified,
                  AppTheme.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Alpha Versions',
                  '6',
                  Icons.science,
                  AppTheme.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return GlassmorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Icon(
                  Icons.trending_up,
                  color: AppTheme.success,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection() {
    return FadeTransition(
      opacity: _chartAnimation,
      child: GlassmorphicCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Version Distribution',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: _buildVersionChart(),
              ),
            ],
        ),
      ),
    );
  }

  Widget _buildVersionChart() {
    return CustomPaint(
      painter: VersionChartPainter(),
      child: Container(
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }

  Widget _buildRecentActivity() {
    return GlassmorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildActivityList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityList() {
    final activities = [
      {
        'icon': Icons.new_releases,
        'title': 'Version 3.2.1-alpha Released',
        'description': 'Comprehensive CI/CD pipeline implementation',
        'time': '2 hours ago',
        'color': AppTheme.primary,
      },
      {
        'icon': Icons.photo_library,
        'title': 'New Screenshots Added',
        'description': 'Updated gallery with latest UI screenshots',
        'time': '1 day ago',
        'color': AppTheme.accent,
      },
      {
        'icon': Icons.update,
        'title': 'Gallery Updated',
        'description': 'Enhanced carousel and grid view',
        'time': '3 days ago',
        'color': AppTheme.info,
      },
      {
        'icon': Icons.compare_arrows,
        'title': 'Comparison Feature Added',
        'description': 'Side-by-side version comparison',
        'time': '1 week ago',
        'color': AppTheme.warning,
      },
    ];

    return Column(
      children: activities.map((activity) => _buildActivityItem(activity)).toList(),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (activity['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              activity['icon'] as IconData,
              color: activity['color'] as Color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'] as String,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['description'] as String,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['time'] as String,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
        ),
      ),
    );
  }
}

class VersionChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = AppTheme.primary.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Sample data for version distribution
    final data = [
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.25, size.height * 0.6),
      Offset(size.width * 0.5, size.height * 0.4),
      Offset(size.width * 0.75, size.height * 0.3),
      Offset(size.width, size.height * 0.2),
    ];

    // Draw filled area
    final path = Path()
      ..moveTo(data[0])
      ..lineTo(data[1])
      ..lineTo(data[2])
      ..lineTo(data[3])
      ..lineTo(data[4])
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, fillPaint);

    // Draw line
    for (int i = 0; i < data.length - 1; i++) {
      canvas.drawLine(data[i], data[i + 1], paint);
    }

    // Draw points
    for (final point in data) {
      canvas.drawCircle(point, 4, Paint()..color = AppTheme.primary);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

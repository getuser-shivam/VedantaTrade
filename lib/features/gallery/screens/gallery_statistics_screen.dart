import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lottie/lottie.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GalleryStatisticsScreen extends StatefulWidget {
  const GalleryStatisticsScreen({Key? key}) : super(key: key);

  @override
  State<GalleryStatisticsScreen> createState() => _GalleryStatisticsScreenState();
}

class _GalleryStatisticsScreenState extends State<GalleryStatisticsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  // Sample data for statistics
  final Map<String, dynamic> _overallStats = {
    'totalViews': 1250,
    'uniqueUsers': 342,
    'avgSessionDuration': 45,
    'totalSessions': 890,
    'bounceRate': 12.5,
    'mostViewedVersion': '3.2.1-alpha',
    'lastUpdated': DateTime.now(),
  };

  final Map<String, Map<String, dynamic>> _versionStats = {
    '3.2.1-alpha': {
      'views': 450,
      'uniqueUsers': 120,
      'avgSessionTime': 52,
      'bounceRate': 8.5,
      'conversionRate': 15.2,
      'userSatisfaction': 4.8,
    },
    '3.2.0-alpha': {
      'views': 320,
      'uniqueUsers': 95,
      'avgSessionTime': 48,
      'bounceRate': 10.2,
      'conversionRate': 12.8,
      'userSatisfaction': 4.6,
    },
    '3.1.0-alpha': {
      'views': 280,
      'uniqueUsers': 78,
      'avgSessionTime': 42,
      'bounceRate': 14.8,
      'conversionRate': 11.5,
      'userSatisfaction': 4.4,
    },
    '3.0.0-alpha': {
      'views': 200,
      'uniqueUsers': 49,
      'avgSessionTime': 38,
      'bounceRate': 18.5,
      'conversionRate': 9.2,
      'userSatisfaction': 4.2,
    },
  };

  final List<Map<String, dynamic>> _userEngagement = [
    {'date': '2026-04-03', 'views': 85, 'users': 23, 'sessions': 62},
    {'date': '2026-04-02', 'views': 92, 'users': 28, 'sessions': 68},
    {'date': '2026-04-01', 'views': 78, 'users': 22, 'sessions': 58},
    {'date': '2026-03-31', 'views': 65, 'users': 19, 'sessions': 48},
    {'date': '2026-03-30', 'views': 71, 'users': 21, 'sessions': 52},
    {'date': '2026-03-29', 'views': 88, 'users': 25, 'sessions': 65},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Gallery Statistics'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _exportStatistics(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshStatistics(context),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(context),
            _buildVersionStatsTab(context),
            _buildUserEngagementTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewHeader(context),
          const SizedBox(height: 24),
          _buildKeyMetrics(context),
          const SizedBox(height: 24),
          _buildPerformanceIndicators(context),
          const SizedBox(height: 24),
          _buildTrendsSection(context),
        ],
      ),
    );
  }

  Widget _buildOverviewHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gallery Overview',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Real-time analytics and insights for VedantaTrade app gallery',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Views',
                  _overallStats['totalViews'].toString(),
                  Icons.visibility,
                  Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Unique Users',
                  _overallStats['uniqueUsers'].toString(),
                  Icons.people,
                  Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetrics(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Metrics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.4,
          children: [
            _buildMetricCard(
              'Avg Session Duration',
              '${_overallStats['avgSessionDuration']}s',
              Icons.timer,
              Colors.blue,
            ),
            _buildMetricCard(
              'Total Sessions',
              _overallStats['totalSessions'].toString(),
              Icons.analytics,
              Colors.green,
            ),
            _buildMetricCard(
              'Bounce Rate',
              '${_overallStats['bounceRate']}%',
              Icons.trending_down,
              Colors.orange,
            ),
            _buildMetricCard(
              'Most Viewed',
              _overallStats['mostViewedVersion'],
              Icons.star,
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceIndicators(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Indicators',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPerformanceBar(
                  'User Engagement',
                  85,
                  Colors.green,
                ),
                const SizedBox(height: 12),
                _buildPerformanceBar(
                  'Content Quality',
                  92,
                  Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildPerformanceBar(
                  'Navigation Efficiency',
                  78,
                  Colors.orange,
                ),
                const SizedBox(height: 12),
                _buildPerformanceBar(
                  'Overall Performance',
                  88,
                  Colors.purple,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceBar(String title, double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage / 100,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Trends',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTrendItem(
                  'Daily Views',
                  Icons.trending_up,
                  '12.5%',
                  Colors.green,
                ),
                const SizedBox(height: 12),
                _buildTrendItem(
                  'User Retention',
                  Icons.trending_up,
                  '8.3%',
                  Colors.green,
                ),
                const SizedBox(height: 12),
                _buildTrendItem(
                  'Session Duration',
                  Icons.trending_flat,
                  '2.1%',
                  Colors.orange,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendItem(String title, IconData icon, String percentage, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            percentage,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVersionStatsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Version Statistics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ..._versionStats.entries.map((entry) {
            return _buildVersionStatCard(context, entry.key, entry.value);
          }),
        ],
      ),
    );
  }

  Widget _buildVersionStatCard(BuildContext context, String version, Map<String, dynamic> stats) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    version,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${stats['views']} views',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _buildVersionMetric('Users', stats['uniqueUsers'].toString()),
                _buildVersionMetric('Session Time', '${stats['avgSessionTime']}s'),
                _buildVersionMetric('Bounce Rate', '${stats['bounceRate']}%'),
                _buildVersionMetric('Satisfaction', '${stats['userSatisfaction']}/5'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildUserEngagementTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Engagement',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Engagement (Last 7 Days)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._userEngagement.map((data) {
                    return _buildEngagementItem(data);
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementItem(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              data['date'],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              data['views'].toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          Expanded(
            child: Text(
              data['users'].toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
          Expanded(
            child: Text(
              data['sessions'].toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _exportStatistics(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Statistics exported successfully')),
    );
  }

  void _refreshStatistics(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Statistics refreshed')),
    );
  }
}

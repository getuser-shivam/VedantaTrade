import 'package:flutter/material.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// App Gallery Showcase Widget with Carousel and Version History
class AppGalleryShowcase extends StatefulWidget {
  const AppGalleryShowcase({Key? key}) : super(key: key);

  @override
  State<AppGalleryShowcase> createState() => _AppGalleryShowcaseState();
}

class _AppGalleryShowcaseState extends State<AppGalleryShowcase>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late TabController _tabController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('App Gallery'),
        backgroundColor: AppTheme.surfaceDark,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.glassBorderLight,
          tabs: const [
            Tab(text: 'v3.2.1', icon: Icon(Icons.star)),
            Tab(text: 'v3.2.0', icon: Icon(Icons.build)),
            Tab(text: 'v3.1.0', icon: Icon(Icons.history)),
            Tab(text: 'Compare', icon: Icon(Icons.compare)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVersion321Showcase(),
          _buildVersion320Showcase(),
          _buildVersion310Showcase(),
          _buildVersionComparison(),
        ],
      ),
    );
  }

  Widget _buildVersion321Showcase() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVersionHeader(
            '3.2.1-alpha',
            'UI/UX Enhancement Suite',
            'Complete UI overhaul with glassmorphic design',
            Colors.purple,
          ),
          const SizedBox(height: 20),
          _buildFeatureCarousel(),
          const SizedBox(height: 20),
          _buildEnhancedComponents(),
          const SizedBox(height: 20),
          _buildResponsiveShowcase(),
        ],
      ),
    );
  }

  Widget _buildVersion320Showcase() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVersionHeader(
            '3.2.0-alpha',
            'CI/CD Pipeline',
            'Enterprise-grade automation and deployment',
            Colors.blue,
          ),
          const SizedBox(height: 20),
          _buildCICDShowcase(),
        ],
      ),
    );
  }

  Widget _buildVersion310Showcase() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVersionHeader(
            '3.1.0-alpha',
            'Geospatial Tracking',
            'Advanced GPS tracking and field force management',
            Colors.green,
          ),
          const SizedBox(height: 20),
          _buildGeospatialShowcase(),
        ],
      ),
    );
  }

  Widget _buildVersionComparison() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVersionHeader(
            'Version Comparison',
            'Side-by-side comparison',
            'Compare features across different versions',
            Colors.orange,
          ),
          const SizedBox(height: 20),
          _buildComparisonTable(),
        ],
      ),
    );
  }

  Widget _buildVersionHeader(
    String version,
    String title,
    String description,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            version,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: AppTheme.glassBorderLight,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCarousel() {
    return Container(
      height: 300,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemCount: _featureItems.length,
        itemBuilder: (context, index) {
          return _buildFeatureItem(_featureItems[index]);
        },
      ),
    );
  }

  Widget _buildFeatureItem(FeatureItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [item.color.withOpacity(0.3), item.color.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: item.color.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              size: 64,
              color: item.color,
            ),
            const SizedBox(height: 16),
            Text(
              item.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              item.description,
              style: TextStyle(
                color: AppTheme.glassBorderLight,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedComponents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enhanced Components',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildComponentCard(
              'Glassmorphic Button',
              'Premium buttons with shimmer effects',
              Icons.touch_app,
              Colors.purple,
            ),
            _buildComponentCard(
              'Enhanced Navigation',
              'Hero animations and smooth transitions',
              Icons.navigation,
              Colors.blue,
            ),
            _buildComponentCard(
              'Skeleton Loading',
              'Multiple loading styles with animations',
              Icons.hourglass_empty,
              Colors.green,
            ),
            _buildComponentCard(
              'Responsive Layout',
              'Adaptive layouts for all screen sizes',
              Icons.devices,
              Colors.orange,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComponentCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                color: AppTheme.glassBorderLight,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveShowcase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Responsive Design',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDeviceCard(
                'Mobile',
                '< 768px',
                Icons.phone_iphone,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDeviceCard(
                'Tablet',
                '768px - 1024px',
                Icons.tablet_mac,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDeviceCard(
                'Desktop',
                '> 1024px',
                Icons.desktop_mac,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeviceCard(
    String device,
    String screenSize,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              device,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              screenSize,
              style: TextStyle(
                color: AppTheme.glassBorderLight,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCICDShowcase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CI/CD Pipeline Features',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildCICDCard(
          'Automated Testing',
          'Unit, widget, integration tests with coverage',
          Icons.check_circle,
          Colors.green,
        ),
        const SizedBox(height: 12),
        _buildCICDCard(
          'Deployment Automation',
          'Multi-platform deployment with health checks',
          Icons.cloud_upload,
          Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildCICDCard(
          'Quality Gates',
          'Code analysis and vulnerability scanning',
          Icons.security,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildCICDCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: AppTheme.glassBorderLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeospatialShowcase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Geospatial Features',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildGeospatialCard(
          'GPS Tracking',
          'Continuous location tracking with high accuracy',
          Icons.gps_fixed,
          Colors.red,
        ),
        const SizedBox(height: 12),
        _buildGeospatialCard(
          'Visit Logging',
          'Field force visit management with validation',
          Icons.location_on,
          Colors.green,
        ),
        const SizedBox(height: 12),
        _buildGeospatialCard(
          'Route Optimization',
          'Smart route planning and territory management',
          Icons.route,
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildGeospatialCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: AppTheme.glassBorderLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonTable() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.glassBorderLight),
      ),
      child: Column(
        children: [
          _buildComparisonHeader(),
          _buildComparisonRow('UI/UX', 'Basic', 'Enhanced', 'Glassmorphic'),
          _buildComparisonRow('Performance', 'Good', 'Better', 'Optimized'),
          _buildComparisonRow('Responsiveness', 'Limited', 'Improved', 'Complete'),
          _buildComparisonRow('Accessibility', 'Basic', 'Enhanced', 'WCAG 2.1 AA'),
          _buildComparisonRow('CI/CD', 'None', 'Basic', 'Enterprise'),
        ],
      ),
    );
  }

  Widget _buildComparisonHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.2),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: const [
          Expanded(
            flex: 2,
            child: Text(
              'Feature',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'v3.1.0',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              'v3.2.0',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              'v3.2.1',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String feature, String v310, String v320, String v321) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.glassBorderLight),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              v310,
              style: TextStyle(
                color: AppTheme.glassBorderLight,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              v320,
              style: TextStyle(
                color: AppTheme.glassBorderLight,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              v321,
              style: const TextStyle(
                color: AppTheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class FeatureItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  FeatureItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

final List<FeatureItem> _featureItems = [
  FeatureItem(
    title: 'Glassmorphic Design',
    description: 'Premium glassmorphic components with shimmer effects',
    icon: Icons.blur_on,
    color: Colors.purple,
  ),
  FeatureItem(
    title: 'Responsive Layout',
    description: 'Adaptive layouts for mobile, tablet, and desktop',
    icon: Icons.devices,
    color: Colors.blue,
  ),
  FeatureItem(
    title: 'Enhanced Navigation',
    description: 'Hero animations and smooth transitions',
    icon: Icons.navigation,
    color: Colors.green,
  ),
  FeatureItem(
    title: 'Skeleton Loading',
    description: 'Multiple loading styles with animations',
    icon: Icons.hourglass_empty,
    color: Colors.orange,
  ),
  FeatureItem(
    title: 'Micro-interactions',
    description: 'Smooth animations and haptic feedback',
    icon: Icons.touch_app,
    color: Colors.red,
  ),
  FeatureItem(
    title: 'Accessibility',
    description: 'WCAG 2.1 AA compliance with screen reader support',
    icon: Icons.accessibility,
    color: Colors.teal,
  ),
];

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AppGalleryScreen extends StatefulWidget {
  const AppGalleryScreen({Key? key}) : super(key: key);

  @override
  State<AppGalleryScreen> createState() => _AppGalleryScreenState();
}

class _AppGalleryScreenState extends State<AppGalleryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  
  final List<VersionInfo> _versions = [
    VersionInfo(
      version: '3.2.1-alpha',
      date: '2026-04-03',
      title: 'Comprehensive CI/CD Pipeline',
      description: 'Enterprise-grade automation with quality gates and security scanning',
      features: [
        'Complete CI/CD workflow with quality gates',
        'Automated testing suite with coverage reporting',
        'Multi-platform deployment automation',
        'Security vulnerability scanning',
        'Performance monitoring and optimization',
        'Release management with semantic versioning',
      ],
      screenshot: 'assets/screenshots/v3.2.1-alpha.png',
      isNew: true,
    ),
    VersionInfo(
      version: '3.2.0-alpha',
      date: '2026-04-03',
      title: 'Production Hardening',
      description: 'Production-ready infrastructure with enhanced monitoring',
      features: [
        'Production deployment automation',
        'Health checks and monitoring',
        'Performance optimization',
        'Security enhancements',
        'Documentation updates',
      ],
      screenshot: 'assets/screenshots/v3.2.0-alpha.png',
      isNew: false,
    ),
    VersionInfo(
      version: '3.1.0-alpha',
      date: '2026-04-02',
      title: 'Feature Complete',
      description: 'Complete feature implementation with enhanced UI',
      features: [
        '6-role architecture implementation',
        'Geospatial field force tracking',
        'Product catalog with search',
        'Distribution management',
        'VAT compliance system',
      ],
      screenshot: 'assets/screenshots/v3.1.0-alpha.png',
      isNew: false,
    ),
    VersionInfo(
      version: '3.0.0-alpha',
      date: '2026-04-01',
      title: 'Initial Release',
      description: 'Initial production-ready release with core features',
      features: [
        'Basic 6-role system',
        'Product catalog',
        'Order management',
        'Authentication system',
      ],
      screenshot: 'assets/screenshots/v3.0.0-alpha.png',
      isNew: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
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
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('App Gallery'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showGalleryInfo(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(context),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCarouselTab(context),
                _buildGridTab(context),
                _buildCompareTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: Theme.of(context).colorScheme.primary,
        labelColor: Theme.of(context).colorScheme.onSurface,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        tabs: const [
          Tab(
            icon: Icon(Icons.slideshow),
            text: 'Carousel',
          ),
          Tab(
            icon: Icon(Icons.grid_view),
            text: 'Grid View',
          ),
          Tab(
            icon: Icon(Icons.compare),
            text: 'Compare',
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselTab(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _versions.length,
            itemBuilder: (context, index) {
              return _buildVersionCard(context, _versions[index], true);
            },
          ),
        );
      },
    );
  }

  Widget _buildGridTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: _versions.length,
        itemBuilder: (context, index) {
          return _buildVersionCard(context, _versions[index], false);
        },
      ),
    );
  }

  Widget _buildCompareTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Select two versions to compare',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildVersionSelector(context, 'Version 1'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildVersionSelector(context, 'Version 2'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionCard(BuildContext context, VersionInfo version, bool isCarousel) {
    return Card(
      elevation: isCarousel ? 8 : 4,
      margin: EdgeInsets.all(isCarousel ? 8 : 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showVersionDetails(context, version),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: version.isNew
                  ? [
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      Theme.of(context).colorScheme.primary.withOpacity(0.05),
                    ]
                  : [
                      Theme.of(context).colorScheme.surface,
                      Theme.of(context).colorScheme.surface,
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (version.isNew)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'NEW',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const Spacer(),
                  Text(
                    version.version,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                version.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                version.description,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                version.date,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 12),
              if (version.screenshot.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    version.screenshot,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVersionSelector(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              child: const Center(
                child: Text(
                  'Select Version',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showVersionDetails(BuildContext context, VersionInfo version) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            version.title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Version ${version.version}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            version.date,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (version.isNew)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'NEW',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        version.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Features',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...version.features.map((feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                feature,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                      const SizedBox(height: 20),
                      if (version.screenshot.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Screenshot',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                version.screenshot,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 200,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Theme.of(context).dividerColor,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.surface,
                                foregroundColor: Theme.of(context).colorScheme.onSurface,
                                side: BorderSide(
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                              child: const Text('Close'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _launchVersionInfo(version),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              ),
                              child: const Text('View Details'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGalleryInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About App Gallery'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This gallery showcases the evolution of VedantaTrade app through different versions.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 12),
            Text(
              'Features:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('• Carousel view with auto-play', style: TextStyle(fontSize: 12)),
            Text('• Grid view for all versions', style: TextStyle(fontSize: 12)),
            Text('• Side-by-side version comparison', style: TextStyle(fontSize: 12)),
            Text('• Detailed version information', style: TextStyle(fontSize: 12)),
            Text('• Interactive screenshots', style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _launchVersionInfo(VersionInfo version) async {
    final url = 'https://github.com/getuser-shivam/VedantaTrade/releases/tag/v${version.version}';
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch release page')),
      );
    }
  }
}

class VersionInfo {
  final String version;
  final String date;
  final String title;
  final String description;
  final List<String> features;
  final String screenshot;
  final bool isNew;

  VersionInfo({
    required this.version,
    required this.date,
    required this.title,
    required this.description,
    required this.features,
    required this.screenshot,
    required this.isNew,
  });
}

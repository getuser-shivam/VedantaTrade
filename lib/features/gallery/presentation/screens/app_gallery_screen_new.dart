import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vedanta_trade/shared/widgets/premium_glassmorphic_theme.dart';

class AppGalleryScreen extends StatefulWidget {
  const AppGalleryScreen({Key? key}) : super(key: key);

  @override
  _AppGalleryScreenState createState() => _AppGalleryScreenState();
}

class _AppGalleryScreenState extends State<AppGalleryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;
  int _currentCarouselIndex = 0;
  int _currentVersionIndex = 0;

  final List<VersionGallery> _versions = [
    VersionGallery(
      version: 'v3.2.1-alpha',
      date: 'April 3, 2026',
      title: 'Comprehensive CI/CD Pipeline',
      description: 'Enterprise-grade automated testing, deployment, and monitoring pipeline with enhanced UX system',
      screenshots: [
        'assets/gallery/v3.2.1/ci_cd_dashboard.png',
        'assets/gallery/v3.2.1/enhanced_ui_ux.png',
        'assets/gallery/v3.2.1/product_catalog.png',
        'assets/gallery/v3.2.1/distribution_management.png',
        'assets/gallery/v3.2.1/authentication_system.png',
        'assets/gallery/v3.2.1/code_quality_tools.png',
      ],
      features: [
        'Comprehensive CI/CD Pipeline',
        'Enhanced UI/UX System',
        'Premium Glassmorphic Design',
        'Advanced Product Catalog',
        'Distribution Management',
        'Enhanced Authentication',
        'Code Quality Tools',
        'GitHub Integration',
      ],
      improvements: [
        'Automated testing and deployment',
        'Enhanced user experience',
        'Production-ready codebase',
        'Comprehensive documentation',
        'Security enhancements',
        'Performance optimizations',
      ],
    ),
    VersionGallery(
      version: 'v3.2.0-alpha',
      date: 'April 3, 2026',
      title: 'Enhanced UI/UX System',
      description: 'Major UI/UX overhaul with premium glassmorphic design and enhanced user experience',
      screenshots: [
        'assets/gallery/v3.2.0/glassmorphic_theme.png',
        'assets/gallery/v3.2.0/enhanced_navigation.png',
        'assets/gallery/v3.2.0/loading_states.png',
        'assets/gallery/v3.2.0/error_states.png',
        'assets/gallery/v3.2.0/micro_interactions.png',
        'assets/gallery/v3.2.0/accessibility_features.png',
      ],
      features: [
        'Premium Glassmorphic Theme',
        'Enhanced Navigation Components',
        'Loading & Error States',
        'Micro-interactions',
        'Accessibility Features',
        'Responsive Design',
      ],
      improvements: [
        'Consistent design system',
        'Enhanced user feedback',
        'WCAG 2.1 AA compliance',
        'Smooth animations',
        'Better accessibility',
      ],
    ),
    VersionGallery(
      version: 'v3.1.0-alpha',
      date: 'April 3, 2026',
      title: 'Production Infrastructure',
      description: 'Production-ready infrastructure with enhanced features and optimizations',
      screenshots: [
        'assets/gallery/v3.1.0/ci_cd_pipeline.png',
        'assets/gallery/v3.1.0/code_quality.png',
        'assets/gallery/v3.1.0/development_tools.png',
        'assets/gallery/v3.1.0/github_integration.png',
        'assets/gallery/v3.1.0/product_catalog_v3.png',
        'assets/gallery/v3.1.0/distribution_v3.png',
      ],
      features: [
        'CI/CD Pipeline',
        'Code Quality Tools',
        'Development Workflow',
        'GitHub Integration',
        'Product Catalog',
        'Distribution Management',
      ],
      improvements: [
        'Automated workflows',
        'Quality assurance',
        'Development automation',
        'Repository management',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _versions.length, vsync: this);
    _pageController = PageController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PremiumGlassmorphicTheme.backgroundGradient,
      appBar: AppBar(
        title: Text(
          'App Gallery',
          style: TextStyle(
            color: PremiumGlassmorphicTheme.primaryTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: PremiumGlassmorphicTheme.backgroundGradient,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: PremiumGlassmorphicTheme.primaryColor,
          labelColor: PremiumGlassmorphicTheme.primaryColor,
          unselectedLabelColor: PremiumGlassmorphicTheme.secondaryTextColor,
          tabs: _versions.map((version) => Tab(
            text: version.version,
          )).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _versions.map((version) => _buildVersionGallery(version)).toList(),
      ),
    );
  }

  Widget _buildVersionGallery(VersionGallery version) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVersionHeader(version),
          const SizedBox(height: 24),
          _buildScreenshotCarousel(version),
          const SizedBox(height: 24),
          _buildFeatureGrid(version),
          const SizedBox(height: 24),
          _buildImprovementsList(version),
          const SizedBox(height: 24),
          _buildTechnicalDetails(version),
        ],
      ),
    );
  }

  Widget _buildVersionHeader(VersionGallery version) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PremiumGlassmorphicTheme.cardColor.withOpacity(0.9),
            PremiumGlassmorphicTheme.cardColor.withOpacity(0.7),
          ],
        ),
        border: Border.all(
          color: PremiumGlassmorphicTheme.borderColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: PremiumGlassmorphicTheme.shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      PremiumGlassmorphicTheme.primaryColor.withOpacity(0.2),
                      PremiumGlassmorphicTheme.primaryColor.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: PremiumGlassmorphicTheme.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  version.version,
                  style: TextStyle(
                    color: PremiumGlassmorphicTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                version.date,
                style: TextStyle(
                  color: PremiumGlassmorphicTheme.secondaryTextColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            version.title,
            style: TextStyle(
              color: PremiumGlassmorphicTheme.primaryTextColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            version.description,
            style: TextStyle(
              color: PremiumGlassmorphicTheme.secondaryTextColor,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenshotCarousel(VersionGallery version) {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: version.screenshots.length,
          itemBuilder: (context, index, realIndex) {
            return _buildScreenshotCard(version.screenshots[index], index);
          },
          options: CarouselOptions(
            height: 300,
            viewportFraction: 0.8,
            enlargeCenterPage: true,
            enableInfiniteScroll: false,
            onPageChanged: (index, reason) {
              setState(() {
                _currentCarouselIndex = index;
              });
            },
          ),
        ),
        const SizedBox(height: 16),
        _buildCarouselIndicators(version.screenshots.length),
      ],
    );
  }

  Widget _buildScreenshotCard(String screenshot, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PremiumGlassmorphicTheme.cardColor.withOpacity(0.9),
            PremiumGlassmorphicTheme.cardColor.withOpacity(0.7),
          ],
        ),
        border: Border.all(
          color: PremiumGlassmorphicTheme.borderColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: PremiumGlassmorphicTheme.shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Placeholder for screenshot
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    PremiumGlassmorphicTheme.primaryColor.withOpacity(0.1),
                    PremiumGlassmorphicTheme.secondaryColor.withOpacity(0.1),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image,
                    size: 80,
                    color: PremiumGlassmorphicTheme.primaryColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Screenshot ${index + 1}',
                    style: TextStyle(
                      color: PremiumGlassmorphicTheme.secondaryTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    screenshot.split('/').last,
                    style: TextStyle(
                      color: PremiumGlassmorphicTheme.secondaryTextColor.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Overlay with screenshot info
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      PremiumGlassmorphicTheme.cardColor.withOpacity(0.9),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.fullscreen,
                      color: PremiumGlassmorphicTheme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tap to view full screen',
                      style: TextStyle(
                        color: PremiumGlassmorphicTheme.primaryTextColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselIndicators(int itemCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentCarouselIndex == index ? 12 : 8,
          height: _currentCarouselIndex == index ? 12 : 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentCarouselIndex == index
                ? PremiumGlassmorphicTheme.primaryColor
                : PremiumGlassmorphicTheme.primaryColor.withOpacity(0.3),
          ),
        );
      }),
    );
  }

  Widget _buildFeatureGrid(VersionGallery version) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Features',
          style: TextStyle(
            color: PremiumGlassmorphicTheme.primaryTextColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 3,
          ),
          itemCount: version.features.length,
          itemBuilder: (context, index) {
            return _buildFeatureCard(version.features[index]);
          },
        ),
      ],
    );
  }

  Widget _buildFeatureCard(String feature) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PremiumGlassmorphicTheme.cardColor.withOpacity(0.8),
            PremiumGlassmorphicTheme.cardColor.withOpacity(0.6),
          ],
        ),
        border: Border.all(
          color: PremiumGlassmorphicTheme.borderColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  PremiumGlassmorphicTheme.primaryColor.withOpacity(0.2),
                  PremiumGlassmorphicTheme.primaryColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.star,
              color: PremiumGlassmorphicTheme.primaryColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(
                color: PremiumGlassmorphicTheme.primaryTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImprovementsList(VersionGallery version) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Improvements',
          style: TextStyle(
            color: PremiumGlassmorphicTheme.primaryTextColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...version.improvements.map((improvement) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      PremiumGlassmorphicTheme.successColor.withOpacity(0.2),
                      PremiumGlassmorphicTheme.successColor.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.check,
                  color: PremiumGlassmorphicTheme.successColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  improvement,
                  style: TextStyle(
                    color: PremiumGlassmorphicTheme.primaryTextColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildTechnicalDetails(VersionGallery version) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PremiumGlassmorphicTheme.cardColor.withOpacity(0.8),
            PremiumGlassmorphicTheme.cardColor.withOpacity(0.6),
          ],
        ),
        border: Border.all(
          color: PremiumGlassmorphicTheme.borderColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Technical Details',
            style: TextStyle(
              color: PremiumGlassmorphicTheme.primaryTextColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildTechnicalDetailRow('Version', version.version),
          _buildTechnicalDetailRow('Release Date', version.date),
          _buildTechnicalDetailRow('Screenshots', '${version.screenshots.length} images'),
          _buildTechnicalDetailRow('Features', '${version.features.length} features'),
          _buildTechnicalDetailRow('Improvements', '${version.improvements.length} improvements'),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  PremiumGlassmorphicTheme.primaryColor.withOpacity(0.1),
                  PremiumGlassmorphicTheme.primaryColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: PremiumGlassmorphicTheme.primaryColor.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.info_outline,
                  color: PremiumGlassmorphicTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  'Screenshots are placeholders and will be replaced with actual app screenshots when available.',
                  style: TextStyle(
                    color: PremiumGlassmorphicTheme.primaryTextColor,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label:',
            style: TextStyle(
              color: PremiumGlassmorphicTheme.secondaryTextColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              color: PremiumGlassmorphicTheme.primaryTextColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class VersionGallery {
  final String version;
  final String date;
  final String title;
  final String description;
  final List<String> screenshots;
  final List<String> features;
  final List<String> improvements;

  VersionGallery({
    required this.version,
    required this.date,
    required this.title,
    required this.description,
    required this.screenshots,
    required this.features,
    required this.improvements,
  });
}

import 'package:flutter/material.dart';
import 'package:vedanta_trade/app/theme/enhanced_app_theme.dart';
import 'package:vedanta_trade/shared/widgets/enhanced_ui_components.dart';

class GalleryShowcaseScreen extends StatefulWidget {
  const GalleryShowcaseScreen({super.key});

  @override
  State<GalleryShowcaseScreen> createState() => _GalleryShowcaseScreenState();
}

class _GalleryShowcaseScreenState extends State<GalleryShowcaseScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late PageController _showcaseController;
  int _currentShowcaseIndex = 0;

  final List<ShowcaseItem> _showcaseItems = [
    ShowcaseItem(
      title: 'Glassmorphic Design Evolution',
      description: 'Witness the transformation from basic UI to premium glassmorphic design',
      beforeImage: 'assets/showcase/ui_before.png',
      afterImage: 'assets/showcase/ui_after.png',
      features: [
        'Basic Material Design → Premium Glassmorphic Design',
        'Static Components → Interactive & Animated',
        'Single Theme → Light/Dark Mode Support',
        'Standard UI → Micro-interactions & Haptic Feedback',
      ],
    ),
    ShowcaseItem(
      title: 'Navigation System Enhancement',
      description: 'From simple navigation to advanced carousel-based system',
      beforeImage: 'assets/showcase/nav_before.png',
      afterImage: 'assets/showcase/nav_after.png',
      features: [
        'Static Navigation → Animated Transitions',
        'Basic Bottom Bar → Enhanced Carousel',
        'Simple Routing → Hero Animations',
        'Standard App Bar → Search Integration',
      ],
    ),
    ShowcaseItem(
      title: 'Component Library Expansion',
      description: 'Comprehensive UI component library with enhanced functionality',
      beforeImage: 'assets/showcase/components_before.png',
      afterImage: 'assets/showcase/components_after.png',
      features: [
        'Basic Widgets → Enhanced Components',
        'No Animations → Smooth Transitions',
        'Limited Customization → Full Theming',
        'Static Elements → Interactive Elements',
      ],
    ),
    ShowcaseItem(
      title: 'Testing Framework Implementation',
      description: 'From manual testing to automated comprehensive testing suite',
      beforeImage: 'assets/showcase/testing_before.png',
      afterImage: 'assets/showcase/testing_after.png',
      features: [
        'Manual Testing → Automated Testing',
        'Basic Validation → Comprehensive Testing',
        'No Coverage → 85%+ Coverage',
        'Manual Debugging → Performance Monitoring',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _showcaseController = PageController();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _showcaseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EnhancedAppTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  _buildShowcaseCarousel(),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _buildShowcaseDetails(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: EnhancedAppTheme.surfaceColor,
      elevation: 0,
      title: Text(
        'UI Evolution Showcase',
        style: TextStyle(
          color: EnhancedAppTheme.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: EnhancedAppTheme.textPrimary,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        EnhancedUIComponents.enhancedButton(
          child: const Text('View Gallery'),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/gallery');
          },
          backgroundColor: EnhancedAppTheme.primaryColor,
        ),
      ],
    );
  }

  Widget _buildShowcaseCarousel() {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: _showcaseController,
        onPageChanged: (index) {
          setState(() {
            _currentShowcaseIndex = index;
          });
        },
        itemCount: _showcaseItems.length,
        itemBuilder: (context, index) {
          final item = _showcaseItems[index];
          final isSelected = index == _currentShowcaseIndex;
          
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isSelected 
                  ? EnhancedAppTheme.primaryColor.withOpacity(0.1)
                  : EnhancedAppTheme.surfaceColor,
              border: Border.all(
                color: isSelected 
                    ? EnhancedAppTheme.primaryColor
                    : EnhancedAppTheme.glassBorderColor,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: EnhancedAppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : EnhancedAppTheme.getCardShadow(),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      color: isSelected 
                          ? EnhancedAppTheme.primaryColor
                          : EnhancedAppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: TextStyle(
                      color: EnhancedAppTheme.textSecondary,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShowcaseDetails() {
    final currentItem = _showcaseItems[_currentShowcaseIndex];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBeforeAfterComparison(currentItem),
          const SizedBox(height: 24),
          _buildFeatureList(currentItem),
          const SizedBox(height: 24),
          _buildInteractiveDemo(currentItem),
        ],
      ),
    );
  }

  Widget _buildBeforeAfterComparison(ShowcaseItem item) {
    return EnhancedUIComponents.glassmorphicCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'UI Evolution',
            style: TextStyle(
              color: EnhancedAppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildComparisonCard(
                  'Before',
                  item.beforeImage,
                  Colors.red,
                  'Previous version with basic UI',
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.arrow_forward,
                color: EnhancedAppTheme.primaryColor,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildComparisonCard(
                  'After',
                  item.afterImage,
                  Colors.green,
                  'Current version with enhanced UI',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(String title, String imagePath, Color color, String description) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: EnhancedAppTheme.getCardShadow(),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: EnhancedAppTheme.surfaceColor,
                  child: Center(
                    child: Icon(
                      Icons.broken_image,
                      color: EnhancedAppTheme.textSecondary,
                      size: 40,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            color: EnhancedAppTheme.textSecondary,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeatureList(ShowcaseItem item) {
    return EnhancedUIComponents.glassmorphicCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Improvements',
            style: TextStyle(
              color: EnhancedAppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...item.features.asMap().entries.map((entry) {
            final index = entry.key;
            final feature = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: EnhancedAppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: TextStyle(
                        color: EnhancedAppTheme.textPrimary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildInteractiveDemo(ShowcaseItem item) {
    return EnhancedUIComponents.glassmorphicCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Interactive Demo',
            style: TextStyle(
              color: EnhancedAppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: EnhancedUIComponents.enhancedButton(
                  child: const Text('Try Glassmorphic UI'),
                  onPressed: () {
                    _showUIDemo('glassmorphic');
                  },
                  backgroundColor: EnhancedAppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: EnhancedUIComponents.enhancedButton(
                  child: const Text('Try Animations'),
                  onPressed: () {
                    _showUIDemo('animations');
                  },
                  backgroundColor: EnhancedAppTheme.secondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: EnhancedUIComponents.enhancedButton(
              child: const Text('View Live Demo'),
              onPressed: () {
                _showLiveDemo();
              },
              backgroundColor: EnhancedAppTheme.accentColor,
              withLottieIcon: true,
              lottieAsset: 'assets/lottie/play.json',
            ),
          ),
        ],
      ),
    );
  }

  void _showUIDemo(String demoType) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: EnhancedAppTheme.surfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: EnhancedAppTheme.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UI Demo: $demoType',
                      style: TextStyle(
                        color: EnhancedAppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'This is an interactive demonstration of the enhanced UI components. Try out the different features and animations.',
                      style: TextStyle(
                        color: EnhancedAppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Demo components would go here
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: EnhancedAppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Interactive Demo Area',
                            style: TextStyle(
                              color: EnhancedAppTheme.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ),
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

  void _showLiveDemo() {
    EnhancedUIComponents.showEnhancedSnackbar(
      context: context,
      message: 'Opening live demo...',
      icon: Icons.play_circle,
    );
  }
}

class ShowcaseItem {
  final String title;
  final String description;
  final String beforeImage;
  final String afterImage;
  final List<String> features;

  ShowcaseItem({
    required this.title,
    required this.description,
    required this.beforeImage,
    required this.afterImage,
    required this.features,
  });
}

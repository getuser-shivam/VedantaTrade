import 'package:flutter/material.dart';
import 'package:vedanta_trade/app/theme/enhanced_app_theme.dart';
import 'package:vedanta_trade/shared/widgets/enhanced_ui_components.dart';
import 'package:vedanta_trade/features/gallery/data/version_data.dart';

class VersionDetailScreen extends StatefulWidget {
  final VersionInfo version;

  const VersionDetailScreen({
    super.key,
    required this.version,
  });

  @override
  State<VersionDetailScreen> createState() => _VersionDetailScreenState();
}

class _VersionDetailScreenState extends State<VersionDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late PageController _screenshotController;
  int _currentScreenshotIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _screenshotController = PageController();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
    _screenshotController.dispose();
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildVersionHeader(),
                    const SizedBox(height: 24),
                    _buildScreenshotsCarousel(),
                    const SizedBox(height: 24),
                    _buildFeatureHighlights(),
                    const SizedBox(height: 24),
                    _buildTechnicalDetails(),
                    const SizedBox(height: 24),
                    _buildChangelog(),
                    const SizedBox(height: 24),
                    _buildDownloadSection(),
                  ],
                ),
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
        widget.version.version,
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
        if (widget.version.isProductionReady)
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green,
                width: 1,
              ),
            ),
            child: Text(
              'PRODUCTION',
              style: TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVersionHeader() {
    return EnhancedUIComponents.glassmorphicCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: widget.version.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.version.primaryColor,
                    width: 2,
                  ),
                ),
                child: Text(
                  widget.version.version,
                  style: TextStyle(
                    color: widget.version.primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (widget.version.isNew)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'NEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.version.title,
            style: TextStyle(
              color: EnhancedAppTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.version.description,
            style: TextStyle(
              color: EnhancedAppTheme.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: widget.version.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                widget.version.releaseDate,
                style: TextStyle(
                  color: widget.version.primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.version.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.version.primaryColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  widget.version.statusDisplay,
                  style: TextStyle(
                    color: widget.version.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScreenshotsCarousel() {
    if (widget.version.screenshots.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Screenshots',
          style: TextStyle(
            color: EnhancedAppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _screenshotController,
            onPageChanged: (index) {
              setState(() {
                _currentScreenshotIndex = index;
              });
            },
            itemCount: widget.version.screenshots.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _showFullScreenScreenshot(index),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: EnhancedAppTheme.getCardShadow(),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      widget.version.screenshots[index],
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
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...List.generate(widget.version.screenshots.length, (index) {
              final isSelected = index == _currentScreenshotIndex;
              return GestureDetector(
                onTap: () {
                  _screenshotController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isSelected ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? widget.version.primaryColor
                        : EnhancedAppTheme.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${_currentScreenshotIndex + 1} / ${widget.version.screenshots.length}',
          style: TextStyle(
            color: EnhancedAppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureHighlights() {
    return EnhancedUIComponents.glassmorphicCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Features',
            style: TextStyle(
              color: EnhancedAppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.version.features.map((feature) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.version.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.version.primaryColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  feature,
                  style: TextStyle(
                    color: widget.version.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalDetails() {
    return EnhancedUIComponents.glassmorphicCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Technical Details',
            style: TextStyle(
              color: EnhancedAppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Flutter Version', widget.version.flutterVersion),
          _buildDetailRow('Build Number', widget.version.buildNumber),
          _buildDetailRow('Platform Support', widget.version.platformSupport),
          _buildDetailRow('Status', widget.version.statusDisplay),
          _buildDetailRow('Release Date', widget.version.releaseDate),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: EnhancedAppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: EnhancedAppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangelog() {
    return EnhancedUIComponents.glassmorphicCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What\'s New',
            style: TextStyle(
              color: EnhancedAppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...widget.version.features.asMap().entries.map((entry) {
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
                      color: widget.version.primaryColor,
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

  Widget _buildDownloadSection() {
    return EnhancedUIComponents.glassmorphicCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Download',
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
                  child: const Text('Download APK'),
                  onPressed: _downloadAPK,
                  backgroundColor: widget.version.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: EnhancedUIComponents.enhancedButton(
                  child: const Text('Download IPA'),
                  onPressed: _downloadIPA,
                  backgroundColor: widget.version.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: EnhancedUIComponents.enhancedButton(
              child: const Text('View Source Code'),
              onPressed: _viewSourceCode,
              backgroundColor: widget.version.primaryColor.withOpacity(0.1),
              foregroundColor: widget.version.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenScreenshot(int index) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return FullScreenScreenshotViewer(
            screenshotPath: widget.version.screenshots[index],
            version: widget.version.version,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  void _downloadAPK() {
    // Implement APK download functionality
    EnhancedUIComponents.showEnhancedSnackbar(
      context: context,
      message: 'APK download started...',
      icon: Icons.download,
    );
  }

  void _downloadIPA() {
    // Implement IPA download functionality
    EnhancedUIComponents.showEnhancedSnackbar(
      context: context,
      message: 'IPA download started...',
      icon: Icons.download,
    );
  }

  void _viewSourceCode() {
    // Implement source code viewing functionality
    EnhancedUIComponents.showEnhancedSnackbar(
      context: context,
      message: 'Opening source code...',
      icon: Icons.code,
    );
  }
}

class FullScreenScreenshotViewer extends StatelessWidget {
  final String screenshotPath;
  final String version;

  const FullScreenScreenshotViewer({
    super.key,
    required this.screenshotPath,
    required this.version,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          '$version - Screenshot',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.fullscreen, color: Colors.white),
            onPressed: () {
              // Implement fullscreen functionality
            },
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 3.0,
          child: Image.asset(
            screenshotPath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 64,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Screenshot not available',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

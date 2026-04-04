import 'package:flutter/material.dart';
import 'package:vedanta_trade/app/theme/enhanced_app_theme.dart';
import 'package:vedanta_trade/shared/widgets/enhanced_ui_components.dart';

class VersionCarousel extends StatefulWidget {
  final List<VersionInfo> versions;
  final int selectedIndex;
  final Function(int) onVersionSelected;

  const VersionCarousel({
    super.key,
    required this.versions,
    required this.selectedIndex,
    required this.onVersionSelected,
  });

  @override
  State<VersionCarousel> createState() => _VersionCarouselState();
}

class _VersionCarouselState extends State<VersionCarousel>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: widget.selectedIndex,
      viewportFraction: 0.8,
    );
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                HapticUtils.lightImpact();
                widget.onVersionSelected(index);
              },
              itemCount: widget.versions.length,
              itemBuilder: (context, index) {
                final version = widget.versions[index];
                final isSelected = index == widget.selectedIndex;
                
                return AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: isSelected ? _scaleAnimation.value : 0.9,
                      child: _buildVersionCard(version, isSelected),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildVersionCard(VersionInfo version, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: EnhancedUIComponents.glassmorphicCard(
        padding: const EdgeInsets.all(20),
        borderRadius: BorderRadius.circular(20),
        backgroundColor: isSelected 
            ? version.primaryColor.withOpacity(0.1)
            : EnhancedAppTheme.surfaceColor,
        borderColor: isSelected 
            ? version.primaryColor
            : EnhancedAppTheme.glassBorderColor,
        borderWidth: isSelected ? 2 : 1,
        boxShadow: isSelected
            ? EnhancedAppTheme.getElevatedShadow(color: version.primaryColor)
            : EnhancedAppTheme.getCardShadow(),
        onTap: () {
          final currentPage = _pageController.page?.round() ?? 0;
          if (currentPage != widget.versions.indexOf(version)) {
            _pageController.animateToPage(
              widget.versions.indexOf(version),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: version.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    version.version,
                    style: TextStyle(
                      color: version.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (version.isNew) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Text(
              version.title,
              style: TextStyle(
                color: EnhancedAppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              version.description,
              style: TextStyle(
                color: EnhancedAppTheme.textSecondary,
                fontSize: 14,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: version.primaryColor,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  version.date,
                  style: TextStyle(
                    color: version.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class VersionDetailCard extends StatelessWidget {
  final VersionInfo version;
  final Function(int) onScreenshotTap;

  const VersionDetailCard({
    super.key,
    required this.version,
    required this.onScreenshotTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildVersionHeader(),
        const SizedBox(height: 24),
        _buildScreenshotsGrid(),
        const SizedBox(height: 24),
        _buildFeaturesList(),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: version.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  version.version,
                  style: TextStyle(
                    color: version.primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (version.isNew) ...[
                const SizedBox(width: 12),
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
            ],
          ),
          const SizedBox(height: 16),
          Text(
            version.title,
            style: TextStyle(
              color: EnhancedAppTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            version.description,
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
                color: version.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                version.date,
                style: TextStyle(
                  color: version.primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScreenshotsGrid() {
    if (version.screenshots.isEmpty) return const SizedBox.shrink();

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
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 16 / 9,
          ),
          itemCount: version.screenshots.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => onScreenshotTap(index),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: EnhancedAppTheme.getCardShadow(),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    version.screenshots[index],
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
      ],
    );
  }

  Widget _buildFeaturesList() {
    return Column(
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
        ...version.features.asMap().entries.map((entry) {
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
                    color: version.primaryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    feature,
                    style: TextStyle(
                      color: EnhancedAppTheme.textPrimary,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}

class VersionInfo {
  final String version;
  final String date;
  final String title;
  final String description;
  final List<String> features;
  final List<String> screenshots;
  final Color primaryColor;
  final bool isNew;

  VersionInfo({
    required this.version,
    required this.date,
    required this.title,
    required this.description,
    required this.features,
    required this.screenshots,
    required this.primaryColor,
    this.isNew = false,
  });
}

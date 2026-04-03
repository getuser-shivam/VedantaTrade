import 'package:flutter/material.dart';
import '../../../../shared/widgets/glassmorphic_widgets.dart';
import '../../../../app/theme/app_theme.dart';
import '../providers/gallery_provider.dart';

class GlassmorphicGalleryCarousel extends StatefulWidget {
  final List<AppVersion> versions;
  final Function(AppVersion) onVersionSelected;
  final bool autoPlay;

  const GlassmorphicGalleryCarousel({
    Key? key,
    required this.versions,
    required this.onVersionSelected,
    this.autoPlay = true,
  }) : super(key: key);

  @override
  _GlassmorphicGalleryCarouselState createState() => _GlassmorphicGalleryCarouselState();
}

class _GlassmorphicGalleryCarouselState extends State<GlassmorphicGalleryCarousel>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    if (widget.autoPlay && widget.versions.isNotEmpty) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && widget.autoPlay) {
        _nextPage();
        _startAutoPlay();
      }
    });
  }

  void _nextPage() {
    if (_currentIndex < widget.versions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.fastOutSlowIn,
      );
    } else {
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 600),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) => setState(() => _currentIndex = index),
      itemCount: widget.versions.length,
      itemBuilder: (context, index) {
        final version = widget.versions[index];
        final isSelected = index == _currentIndex;
        return AnimatedScale(
          scale: isSelected ? 1.0 : 0.9,
          duration: const Duration(milliseconds: 400),
          child: AnimatedOpacity(
            opacity: isSelected ? 1.0 : 0.6,
            duration: const Duration(milliseconds: 400),
            child: GlassmorphicVersionCard(
              version: version,
              onTap: () => widget.onVersionSelected(version),
              isFeatured: isSelected,
            ),
          ),
        );
      },
    );
  }
}

class GlassmorphicVersionCard extends StatelessWidget {
  final AppVersion version;
  final VoidCallback onTap;
  final bool isFeatured;

  const GlassmorphicVersionCard({
    Key? key,
    required this.version,
    required this.onTap,
    this.isFeatured = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      onTap: onTap,
      margin: const EdgeInsets.all(8),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Screenshot Preview / Header
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primary.withOpacity(0.4),
                        AppTheme.secondary.withOpacity(0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: version.screenshots.isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: Image.network(
                            version.screenshots.first,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => _PlaceholderIcon(version: version.version),
                          ),
                        )
                      : _PlaceholderIcon(version: version.version),
                ),
                // Version Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'v${version.version}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (version.isFeatured)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Icon(Icons.star_rounded, color: AppTheme.warning, size: 28),
                  ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    version.status,
                    style: TextStyle(
                      color: version.status == 'Stable' ? AppTheme.success : AppTheme.warning,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    version.description,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: version.features.take(3).map((f) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Text(
                        f,
                        style: const TextStyle(color: Colors.white60, fontSize: 9),
                      ),
                    )).toList(),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, color: Colors.white38, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        version.releaseDate,
                        style: const TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderIcon extends StatelessWidget {
  final String version;
  const _PlaceholderIcon({required this.version});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome_mosaic_rounded, color: Colors.white24, size: 48),
          const SizedBox(height: 8),
          Text(
            'Milestone $version',
            style: const TextStyle(color: Colors.white12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class GlassmorphicComparisonTool extends StatelessWidget {
  final AppVersion v1;
  final AppVersion v2;

  const GlassmorphicComparisonTool({
    Key? key,
    required this.v1,
    required this.v2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildVersionColumn(context, v1, true)),
        Container(
          width: 1,
          color: AppTheme.glassBorderLight,
          margin: const EdgeInsets.symmetric(vertical: 20),
        ),
        Expanded(child: _buildVersionColumn(context, v2, false)),
      ],
    );
  }

  Widget _buildVersionColumn(BuildContext context, AppVersion v, bool isLeft) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(
            'v${v.version}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: v.features.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: AppTheme.success, size: 14),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        v.features[i],
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../shared/theme/app_theme.dart';
import '../providers/gallery_provider.dart';

class GalleryCarousel extends StatefulWidget {
  final List<AppVersion> versions;
  final Function(AppVersion) onVersionSelected;
  final double height;
  final bool autoPlay;
  final Duration autoPlayDuration;

  const GalleryCarousel({
    Key? key,
    required this.versions,
    required this.onVersionSelected,
    this.height = 300,
    this.autoPlay = true,
    this.autoPlayDuration = const Duration(seconds: 5),
  }) : super(key: key);

  @override
  _GalleryCarouselState createState() => _GalleryCarouselState();
}

class _GalleryCarouselState extends State<GalleryCarousel>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    if (widget.autoPlay && widget.versions.isNotEmpty) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    Future.delayed(widget.autoPlayDuration, () {
      if (mounted && widget.autoPlay) {
        _nextPage();
        _startAutoPlay();
      }
    });
  }

  void _nextPage() {
    if (_currentIndex < widget.versions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: widget.height,
      child: Stack(
        children: [
          // Carousel content
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.versions.length,
            itemBuilder: (context, index) {
              final version = widget.versions[index];
              return _buildCarouselItem(version, theme, index);
            },
          ),
          
          // Navigation arrows
          if (widget.versions.length > 1) ...[
            Positioned(
              left: 8,
              top: 0,
              bottom: 0,
              child: _buildNavigationButton(
                theme,
                Icons.arrow_back_ios,
                () => _previousPage(),
              ),
            ),
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: _buildNavigationButton(
                theme,
                Icons.arrow_forward_ios,
                () => _nextPage(),
              ),
            ),
          ],
          
          // Page indicators
          if (widget.versions.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: _buildPageIndicators(theme),
            ),
        ],
      ),
    );
  }

  Widget _buildCarouselItem(AppVersion version, ThemeData theme, int index) {
    final isSelected = index == _currentIndex;
    
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double value = 1.0;
        if (_pageController.position.haveDimensions) {
          value = _pageController.page! - index;
          value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
        }

        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.8),
                    theme.colorScheme.primary.withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => widget.onVersionSelected(version),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Version badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'v${version.version}',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Title
                        Text(
                          version.description,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Features preview
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: version.features
                              .take(3)
                              .map((feature) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  feature,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                              .toList(),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Release date
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Colors.white.withOpacity(0.8),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              version.releaseDate,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavigationButton(
    ThemeData theme,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed,
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicators(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.versions.length,
        (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == _currentIndex
                ? Colors.white
                : Colors.white.withOpacity(0.4),
          ),
        ),
      ),
    );
  }
}

class CompactCarousel extends StatelessWidget {
  final List<AppVersion> versions;
  final Function(AppVersion) onVersionSelected;

  const CompactCarousel({
    Key? key,
    required this.versions,
    required this.onVersionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: versions.length,
        itemBuilder: (context, index) {
          final version = versions[index];
          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.1),
                  theme.colorScheme.primary.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.2),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onVersionSelected(version),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'v${version.version}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (version.isFeatured) ...[
                            const SizedBox(width: 6),
                            Icon(
                              Icons.star,
                              color: AppTheme.warningColor,
                              size: 16,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Text(
                          version.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        version.releaseDate,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

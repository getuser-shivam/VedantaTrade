import 'dart:async';
import 'package:flutter/material.dart';
import '../providers/gallery_provider.dart';

class EnhancedGalleryCarousel extends StatefulWidget {
  final List<dynamic> versions;
  final bool autoPlay;
  final Function(int)? onPageChanged;
  final Duration autoPlayInterval;

  const EnhancedGalleryCarousel({
    Key? key,
    required this.versions,
    this.autoPlay = false,
    this.onPageChanged,
    this.autoPlayInterval = const Duration(seconds: 3),
  }) : super(key: key);

  @override
  _EnhancedGalleryCarouselState createState() => _EnhancedGalleryCarouselState();
}

class _EnhancedGalleryCarouselState extends State<EnhancedGalleryCarousel>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late Timer? _autoPlayTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    if (widget.autoPlay) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(EnhancedGalleryCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.autoPlay != oldWidget.autoPlay) {
      if (widget.autoPlay) {
        _startAutoPlay();
      } else {
        _stopAutoPlay();
      }
    }
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(widget.autoPlayInterval, (timer) {
      if (_currentPage < widget.versions.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Carousel controls
        _buildCarouselControls(context),
        // Main carousel
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                  widget.onPageChanged?.call(index);
                },
                itemCount: widget.versions.length,
                itemBuilder: (context, index) {
                  final version = widget.versions[index];
                  return _buildVersionPage(context, version);
                },
              ),
            ),
          ),
        ),
        // Page indicators
        _buildPageIndicators(context),
      ],
    );
  }

  Widget _buildCarouselControls(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          IconButton(
            onPressed: _currentPage > 0
                ? () {
                    _stopAutoPlay();
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
            icon: Icon(
              Icons.arrow_back_ios,
              color: _currentPage > 0
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            tooltip: 'Previous Version',
          ),
          
          // Auto-play indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _autoPlayTimer?.isActive ?? false
                      ? Icons.pause
                      : Icons.play_arrow,
                  size: 16,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 6),
                Text(
                  _autoPlayTimer?.isActive ?? false
                      ? 'Auto-playing'
                      : 'Paused',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          // Next button
          IconButton(
            onPressed: _currentPage < widget.versions.length - 1
                ? () {
                    _stopAutoPlay();
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
            icon: Icon(
              Icons.arrow_forward_ios,
              color: _currentPage < widget.versions.length - 1
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            tooltip: 'Next Version',
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicators(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.versions.length,
          (index) => Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index == _currentPage
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVersionPage(BuildContext context, dynamic version) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Version header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  version.version ?? 'Unknown',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(version.status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  version.status ?? 'Unknown',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Screenshot carousel
          if (version.screenshots != null && version.screenshots.isNotEmpty)
            Expanded(
              flex: 2,
              child: _buildScreenshotCarousel(context, version.screenshots),
            ),
          
          const SizedBox(height: 16),
          
          // Version details
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Release Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDetailItem(
                  context,
                  'Release Date',
                  version.releaseDate ?? 'Unknown',
                  Icons.calendar_today,
                ),
                _buildDetailItem(
                  context,
                  'Build Number',
                  version.buildNumber ?? 'Unknown',
                  Icons.build,
                ),
                _buildDetailItem(
                  context,
                  'Platform',
                  version.platform ?? 'Unknown',
                  Icons.devices,
                ),
                const SizedBox(height: 16),
                Text(
                  'Key Features',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...version.features?.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
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
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    )).toList() ??
                    [],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenshotCarousel(BuildContext context, List<String>? screenshots) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'Screenshots',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: PageView.builder(
              itemCount: screenshots?.length ?? 0,
              itemBuilder: (context, index) {
                final screenshot = screenshots?[index] ?? '';
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      screenshot,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Theme.of(context).colorScheme.errorContainer,
                          child: Icon(
                            Icons.broken_image,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'stable':
        return Colors.green;
      case 'beta':
        return Colors.orange;
      case 'alpha':
        return Colors.red;
      case 'development':
        return Colors.grey;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }
}

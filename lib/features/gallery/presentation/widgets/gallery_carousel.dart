import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../shared/widgets/common/enhanced_glassmorphic_theme.dart';
import '../providers/gallery_provider.dart';

class GalleryCarousel extends StatefulWidget {
  final List<AppVersion> versions;
  final Function(AppVersion) onVersionSelected;
  final bool autoPlay;
  final Duration autoPlayInterval;

  const GalleryCarousel({
    Key? key,
    required this.versions,
    required this.onVersionSelected,
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 5),
  }) : super(key: key);

  @override
  State<GalleryCarousel> createState() => _GalleryCarouselState();
}

class _GalleryCarouselState extends State<GalleryCarousel> {
  final CarouselController _carouselController = CarouselController();
  int _currentIndex = 0;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    if (widget.autoPlay) {
      _startAutoPlay();
    }
  }

  @override
  void didUpdateWidget(GalleryCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.autoPlay != oldWidget.autoPlay) {
      if (widget.autoPlay) {
        _startAutoPlay();
      } else {
        _stopAutoPlay();
      }
    }
  }

  @override
  void dispose() {
    _stopAutoPlay();
    _carouselController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(widget.autoPlayInterval, (timer) {
      if (_currentIndex < widget.versions.length - 1) {
        _carouselController.nextPage();
      } else {
        _carouselController.animateToPage(0);
      }
    });
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: CarouselSlider.builder(
        carouselController: _carouselController,
        options: CarouselOptions(
          height: 400,
          enlargeCenterPage: true,
          autoPlay: false, // We handle autoPlay manually
          autoPlayInterval: Duration.zero,
          viewportFraction: 0.9,
          aspectRatio: 16 / 9,
          initialPage: 0,
          enableInfiniteScroll: widget.versions.length > 1,
          enlargeStrategy: CenterPageEnlargeStrategy.height,
          onPageChanged: (index, reason) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
        itemCount: widget.versions.length,
        itemBuilder: (context, index, realIndex) {
          final version = widget.versions[index];
          return _buildCarouselItem(version, index == _currentIndex);
        },
      ),
    );
  }

  Widget _buildCarouselItem(AppVersion version, bool isActive) {
    return GestureDetector(
      onTap: () {
        _stopAutoPlay();
        widget.onVersionSelected(version);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()
          ..scale(isActive ? 1.05 : 1.0),
        child: GlassmorphicCard(
          elevation: isActive ? 8 : 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[200],
                  ),
                  child: version.screenshotUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: version.screenshotUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.error, color: Colors.grey),
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.image, color: Colors.grey),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                version.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.blue[600] : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                version.date,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              if (version.isMajor)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Major Update',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[800],
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  version.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CarouselIndicator extends StatelessWidget {
  final int itemCount;
  final int currentIndex;
  final Color activeColor;
  final Color inactiveColor;

  const CarouselIndicator({
    Key? key,
    required this.itemCount,
    required this.currentIndex,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.grey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        itemCount,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: index == currentIndex ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == currentIndex ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

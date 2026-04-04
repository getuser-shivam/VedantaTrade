import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

/// Enhanced carousel slider widget for gallery
class CarouselSlider extends StatefulWidget {
  final List<Widget> items;
  final double height;
  final double viewportFraction;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final bool enlargeCenterPage;
  final bool enableInfiniteScroll;
  final Axis scrollDirection;
  final ValueChanged<int>? onPageChanged;
  final Duration? animationDuration;
  final Curve? animationCurve;
  
  const CarouselSlider({
    Key? key,
    required this.items,
    this.height = 400,
    this.viewportFraction = 0.9,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 3),
    this.enlargeCenterPage = true,
    this.enableInfiniteScroll = false,
    this.scrollDirection = Axis.horizontal,
    this.onPageChanged,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
  }) : super(key: key);

  @override
  State<CarouselSlider> createState() => _CarouselSliderState();
}

class _CarouselSliderState extends State<CarouselSlider> {
  late CarouselController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = CarouselController();
    
    if (widget.autoPlay) {
      _startAutoPlay();
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    Future.delayed(widget.autoPlayInterval, () {
      if (mounted && widget.autoPlay) {
        _controller.nextPage();
        _startAutoPlay();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      child: CarouselSlider.builder(
        carouselController: _controller,
        options: CarouselOptions(
          height: widget.height,
          viewportFraction: widget.viewportFraction,
          enlargeCenterPage: widget.enlargeCenterPage,
          autoPlay: widget.autoPlay,
          autoPlayInterval: widget.autoPlayInterval,
          enableInfiniteScroll: widget.enableInfiniteScroll,
          scrollDirection: widget.scrollDirection,
          animationDuration: widget.animationDuration,
          animationCurve: widget.animationCurve,
          onPageChanged: (index, reason) {
            widget.onPageChanged?.call(index, reason);
          },
        ),
        itemCount: widget.items.length,
        itemBuilder: (context, index, realIndex) {
          return widget.items[index];
        },
      ),
    );
  }
}

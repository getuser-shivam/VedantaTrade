import 'package:flutter/material.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';

/// Skeleton loading widget for better perceived performance
class SkeletonLoading extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final bool isCircle;
  final Color? baseColor;
  final Color? highlightColor;

  const SkeletonLoading({
    Key? key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius,
    this.isCircle = false,
    this.baseColor,
    this.highlightColor,
  }) : super(key: key);

  @override
  _SkeletonLoadingState createState() => _SkeletonLoadingState();
}

class _SkeletonLoadingState extends State<SkeletonLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.baseColor ?? Colors.white.withOpacity(0.1);
    final highlightColor = widget.highlightColor ?? Colors.white.withOpacity(0.2);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: widget.isCircle ? null : (widget.borderRadius ?? BorderRadius.circular(8)),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton card for content loading
class SkeletonCard extends StatelessWidget {
  final double height;

  const SkeletonCard({Key? key, this.height = 120}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkeletonLoading(width: 48, height: 48, isCircle: true),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SkeletonLoading(width: double.infinity, height: 16),
                    SizedBox(height: 8),
                    SkeletonLoading(width: 150, height: 12),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const SkeletonLoading(width: double.infinity, height: 12),
          const SizedBox(height: 8),
          const SkeletonLoading(width: double.infinity, height: 12),
          const SizedBox(height: 8),
          const SkeletonLoading(width: 200, height: 12),
        ],
      ),
    );
  }
}

/// Skeleton list for multiple items
class SkeletonList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const SkeletonList({
    Key? key,
    this.itemCount = 5,
    this.itemHeight = 80,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SkeletonCard(height: itemHeight),
        );
      },
    );
  }
}

/// Skeleton for product cards
class SkeletonProductCard extends StatelessWidget {
  const SkeletonProductCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SkeletonLoading(
              width: double.infinity,
              height: 140,
              borderRadius: BorderRadius.zero,
            ),
          ),
          // Content area
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonLoading(width: double.infinity, height: 16),
                SizedBox(height: 8),
                SkeletonLoading(width: 100, height: 14),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonLoading(width: 80, height: 20),
                    SkeletonLoading(width: 40, height: 32, borderRadius: BorderRadius.all(Radius.circular(8))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

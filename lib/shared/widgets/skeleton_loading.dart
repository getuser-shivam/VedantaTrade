import 'package:flutter/material.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';

/// Enhanced Skeleton loading widget for better perceived performance
class SkeletonLoading extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final bool isCircle;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;
  final bool animate;

  const SkeletonLoading({
    Key? key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius,
    this.isCircle = false,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
    this.animate = true,
  }) : super(key: key);

  @override
  State<SkeletonLoading> createState() => _SkeletonLoadingState();
}

class _SkeletonLoadingState extends State<SkeletonLoading>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _controller = AnimationController(
        duration: widget.duration,
        vsync: this,
      );
      _animation = Tween<double>(
        begin: -1.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    if (widget.animate) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.baseColor ?? AppTheme.glassBg;
    final highlightColor = widget.highlightColor ?? Colors.white.withOpacity(0.3);

    if (!widget.animate) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: widget.isCircle
              ? null
              : widget.borderRadius ?? BorderRadius.circular(8),
          shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.0 + _animation.value, 0),
              end: Alignment(1.0 + _animation.value, 0),
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: widget.isCircle
                  ? null
                  : widget.borderRadius ?? BorderRadius.circular(8),
              shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton Card for product cards and other complex layouts
class SkeletonCard extends StatelessWidget {
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Widget? child;
  final BorderRadius? borderRadius;

  const SkeletonCard({
    Key? key,
    this.width,
    this.height,
    this.padding,
    this.child,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.glassBorderLight,
          width: 1,
        ),
      ),
      child: child ?? _buildDefaultSkeleton(),
    );
  }

  Widget _buildDefaultSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonLoading(
          height: 120,
          borderRadius: BorderRadius.circular(12),
        ),
        const SizedBox(height: 12),
        SkeletonLoading(
          height: 16,
          width: double.infinity,
        ),
        const SizedBox(height: 8),
        SkeletonLoading(
          height: 12,
          width: 100,
        ),
        const SizedBox(height: 8),
        SkeletonLoading(
          height: 14,
          width: 60,
        ),
      ],
    );
  }
}

/// Skeleton List for list items
class SkeletonList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsetsGeometry? padding;
  final Widget Function(int index)? itemBuilder;

  const SkeletonList({
    Key? key,
    required this.itemCount,
    this.itemHeight = 80,
    this.padding,
    this.itemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return itemBuilder != null
            ? itemBuilder!(index)
            : SkeletonListItem(height: itemHeight);
      },
    );
  }
}

/// Skeleton List Item
class SkeletonListItem extends StatelessWidget {
  final double height;
  final Widget? leading;
  final Widget? trailing;
  final bool showAvatar;

  const SkeletonListItem({
    Key? key,
    required this.height,
    this.leading,
    this.trailing,
    this.showAvatar = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.glassBorderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (showAvatar)
            SkeletonLoading(
              width: 40,
              height: 40,
              isCircle: true,
            )
          else if (leading != null)
            leading!,
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkeletonLoading(
                  height: 16,
                  width: double.infinity,
                ),
                const SizedBox(height: 8),
                SkeletonLoading(
                  height: 12,
                  width: 200,
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Skeleton Grid for grid layouts
class SkeletonGrid extends StatelessWidget {
  final int crossAxisCount;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final int itemCount;
  final Widget Function(int index)? itemBuilder;

  const SkeletonGrid({
    Key? key,
    required this.crossAxisCount,
    this.childAspectRatio = 1.0,
    this.crossAxisSpacing = 16,
    this.mainAxisSpacing = 16,
    required this.itemCount,
    this.itemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return itemBuilder != null
            ? itemBuilder!(index)
            : SkeletonCard(
                width: double.infinity,
                height: double.infinity,
              );
      },
    );
  }
}

/// Loading State Widget with multiple loading types
class LoadingStateWidget extends StatelessWidget {
  final LoadingType type;
  final String? message;
  final Color? color;

  const LoadingStateWidget({
    Key? key,
    required this.type,
    this.message,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLoadingIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                color: color ?? AppTheme.glassBorderLight,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    switch (type) {
      case LoadingType.circular:
        return CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(color ?? AppTheme.primary),
          strokeWidth: 3,
        );
      case LoadingType.dots:
        return _DotsLoadingIndicator(color: color ?? AppTheme.primary);
      case LoadingType.pulse:
        return _PulseLoadingIndicator(color: color ?? AppTheme.primary);
      case LoadingType.bounce:
        return _BounceLoadingIndicator(color: color ?? AppTheme.primary);
    }
  }
}

enum LoadingType { circular, dots, pulse, bounce }

/// Dots Loading Indicator
class _DotsLoadingIndicator extends StatefulWidget {
  final Color color;

  const _DotsLoadingIndicator({required this.color});

  @override
  State<_DotsLoadingIndicator> createState() => _DotsLoadingIndicatorState();
}

class _DotsLoadingIndicatorState extends State<_DotsLoadingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (index) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );
      controller.repeat();
      return controller;
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }).toList();

    // Start animations with delays
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Transform.scale(
              scale: 0.5 + _animations[index].value * 0.5,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

/// Pulse Loading Indicator
class _PulseLoadingIndicator extends StatefulWidget {
  final Color color;

  const _PulseLoadingIndicator({required this.color});

  @override
  State<_PulseLoadingIndicator> createState() => _PulseLoadingIndicatorState();
}

class _PulseLoadingIndicatorState extends State<_PulseLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

/// Bounce Loading Indicator
class _BounceLoadingIndicator extends StatefulWidget {
  final Color color;

  const _BounceLoadingIndicator({required this.color});

  @override
  State<_BounceLoadingIndicator> createState() => _BounceLoadingIndicatorState();
}

class _BounceLoadingIndicatorState extends State<_BounceLoadingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (index) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      );
      controller.repeat();
      return controller;
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: -20, end: 20).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.bounceOut,
        ),
      );
    }).toList();

    // Start animations with delays
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) {
          _controllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _animations[index].value),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';

class EnhancedLoadingWidget extends StatefulWidget {
  final String? message;
  final Color? color;
  final double? size;
  final bool isOverlay;
  final Duration? duration;
  final Widget? customWidget;
  final LoadingType type;

  const EnhancedLoadingWidget({
    Key? key,
    this.message,
    this.color,
    this.size,
    this.isOverlay = false,
    this.duration = const Duration(milliseconds: 1500),
    this.customWidget,
    this.type = LoadingType.modern,
  }) : super(key: key);

  @override
  _EnhancedLoadingWidgetState createState() => _EnhancedLoadingWidgetState();
}

enum LoadingType {
  modern,
  pulse,
  dots,
  bars,
  skeleton,
  shimmer,
  glassmorphic,
}

class _EnhancedLoadingWidgetState extends State<EnhancedLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loadingColor = widget.color ?? theme.colorScheme.primary;

    Widget content = _buildLoadingContent(loadingColor);

    if (widget.message != null) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          content,
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Opacity(
                opacity: _animation.value,
                child: Text(
                  widget.message!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ],
      );
    }

    if (widget.isOverlay) {
      return Container(
        color: Colors.black.withOpacity(0.3),
        child: Center(child: content),
      );
    }

    return content;
  }

  Widget _buildLoadingContent(Color color) {
    switch (widget.type) {
      case LoadingType.modern:
        return _buildModernSpinner(color);
      case LoadingType.pulse:
        return _buildPulseSpinner(color);
      case LoadingType.dots:
        return _buildDotsSpinner(color);
      case LoadingType.bars:
        return _buildBarsSpinner(color);
      case LoadingType.skeleton:
        return _buildSkeletonLoader();
      case LoadingType.shimmer:
        return _buildShimmerLoader();
      case LoadingType.glassmorphic:
        return _buildGlassmorphicLoader(color);
    }
  }

  Widget _buildModernSpinner(Color color) {
    return SizedBox(
      width: widget.size ?? 40,
      height: widget.size ?? 40,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * 3.14159,
            child: CustomPaint(
              painter: _ModernSpinnerPainter(color),
              size: Size(widget.size ?? 40, widget.size ?? 40),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPulseSpinner(Color color) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: widget.size ?? 32,
            height: widget.size ?? 32,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  color.withOpacity(0.8),
                  color.withOpacity(0.4),
                  color.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDotsSpinner(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final animatedValue = (_controller.value + delay) % 1.0;
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(animatedValue),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildBarsSpinner(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.1;
            final animatedValue = (_controller.value + delay) % 1.0;
            return Container(
              width: 4,
              height: 20,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(animatedValue),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildSkeletonLoader() {
    return Container(
      width: widget.size ?? 200,
      height: widget.size ?? 20,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.withOpacity(0.3),
            Colors.grey.withOpacity(0.1),
            Colors.grey.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.size ?? 200,
          height: widget.size ?? 20,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.grey.withOpacity(0.1),
                Colors.grey.withOpacity(0.3 * _animation.value),
                Colors.grey.withOpacity(0.1),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }

  Widget _buildGlassmorphicLoader(Color color) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: widget.size ?? 48,
          height: widget.size ?? 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.2),
                color.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ModernSpinnerPainter extends CustomPainter {
  final Color color;

  _ModernSpinnerPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - paint.strokeWidth / 2;

    // Draw arc segments
    const segmentCount = 6;
    for (int i = 0; i < segmentCount; i++) {
      final startAngle = (i * 2 * 3.14159) / segmentCount;
      final sweepAngle = (2 * 3.14159) / (segmentCount * 2);
      
      paint.color = color.withOpacity(1.0 - (i / segmentCount));
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

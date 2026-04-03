import 'package:flutter/material.dart';

enum LoadingType {
  spinner,
  dots,
  bars,
  pulse,
  skeleton,
  shimmer,
}

class LoadingWidget extends StatefulWidget {
  final LoadingType type;
  final String? message;
  final Color? color;
  final double? size;
  final bool isOverlay;
  final Duration? duration;
  final Widget? customWidget;

  const LoadingWidget({
    Key? key,
    this.type = LoadingType.spinner,
    this.message,
    this.color,
    this.size,
    this.isOverlay = false,
    this.duration = const Duration(milliseconds: 1500),
    this.customWidget,
  }) : super(key: key);

  @override
  _LoadingWidgetState createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
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
          Text(
            widget.message!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
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

    return Center(child: content);
  }

  Widget _buildLoadingContent(Color color) {
    if (widget.customWidget != null) {
      return AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: 0.8 + (_animation.value * 0.2),
            child: widget.customWidget!,
          );
        },
      );
    }

    switch (widget.type) {
      case LoadingType.spinner:
        return _buildSpinner(color);
      case LoadingType.dots:
        return _buildDots(color);
      case LoadingType.bars:
        return _buildBars(color);
      case LoadingType.pulse:
        return _buildPulse(color);
      case LoadingType.skeleton:
        return _buildSkeleton();
      case LoadingType.shimmer:
        return _buildShimmer();
    }
  }

  Widget _buildSpinner(Color color) {
    return SizedBox(
      width: widget.size ?? 24,
      height: widget.size ?? 24,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }

  Widget _buildDots(Color color) {
    return SizedBox(
      width: widget.size ?? 60,
      height: widget.size ?? 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final delay = index * 0.2;
              final animationValue = (_animation.value + delay) % 1.0;
              return Transform.scale(
                scale: 0.5 + animationValue * 0.5,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildBars(Color color) {
    return SizedBox(
      width: widget.size ?? 40,
      height: widget.size ?? 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final delay = index * 0.15;
              final animationValue = (_animation.value + delay) % 1.0;
              return Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: animationValue,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildPulse(Color color) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size ?? 40,
          height: widget.size ?? 40,
          decoration: BoxDecoration(
            color: color.withOpacity(_animation.value * 0.3),
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: 2,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkeleton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSkeletonLine(width: 200, height: 20),
        const SizedBox(height: 12),
        _buildSkeletonLine(width: 150, height: 16),
        const SizedBox(height: 12),
        _buildSkeletonLine(width: 180, height: 16),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildSkeletonLine(width: 60, height: 36),
            const SizedBox(width: 12),
            _buildSkeletonLine(width: 80, height: 36),
          ],
        ),
      ],
    );
  }

  Widget _buildSkeletonLine({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildShimmer() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size ?? 60,
          height: widget.size ?? 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
              stops: [0.0, _animation.value, 1.0],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingMessage;
  final LoadingType loadingType;
  final Color? loadingColor;

  const LoadingOverlay({
    Key? key,
    required this.child,
    this.isLoading = false,
    this.loadingMessage,
    this.loadingType = LoadingType.spinner,
    this.loadingColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: LoadingWidget(
              type: loadingType,
              message: loadingMessage,
              color: loadingColor,
              isOverlay: true,
            ),
          ),
      ],
    );
  }
}

class PageLoadingWidget extends StatelessWidget {
  final String? message;
  final LoadingType type;
  final Color? color;

  const PageLoadingWidget({
    Key? key,
    this.message,
    this.type = LoadingType.spinner,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LoadingWidget(
          type: type,
          message: message,
          color: color,
          size: 48,
        ),
      ),
    );
  }
}

class ButtonLoadingWidget extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final Color? loadingColor;

  const ButtonLoadingWidget({
    Key? key,
    required this.isLoading,
    required this.child,
    this.loadingColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            loadingColor ?? Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      );
    }

    return child;
  }
}

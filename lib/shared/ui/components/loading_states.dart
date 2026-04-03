import 'package:flutter/material.dart';
import '../design_system/app_colors.dart';
import '../design_system/app_spacing.dart';
import '../design_system/app_typography.dart';

class LoadingStates {
  // Full Screen Loading
  static Widget fullScreen({
    String? message,
    Color? backgroundColor,
    Color? spinnerColor,
    double? size,
  }) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSpinner(
              color: spinnerColor ?? AppColors.primary,
              size: size ?? 48.0,
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                message,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Card Loading
  static Widget card({
    double? height,
    double? width,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? AppSpacing.paddingCard,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius ?? AppBorderRadius.radiusCard,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      ),
    );
  }

  // Skeleton Loading
  static Widget skeleton({
    double? height,
    double? width,
    BorderRadius? borderRadius,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? AppBorderRadius.radiusSM,
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            baseColor ?? Colors.grey[300]!,
            highlightColor ?? Colors.grey[100]!,
            baseColor ?? Colors.grey[300]!,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  // List Skeleton Loading
  static Widget listSkeleton({
    int itemCount = 3,
    double itemHeight = 80.0,
    EdgeInsetsGeometry? padding,
  }) {
    return Padding(
      padding: padding ?? AppSpacing.paddingScreen,
      child: Column(
        children: List.generate(
          itemCount,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              children: [
                // Avatar skeleton
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Text skeletons
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: AppBorderRadius.radiusXS,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        width: 200,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: AppBorderRadius.radiusXS,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Custom Spinner Widget
  static Widget _buildSpinner({
    required Color color,
    required double size,
    double strokeWidth = 3.0,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        color: color,
        strokeWidth: strokeWidth,
        backgroundColor: color.withOpacity(0.1),
      ),
    );
  }
}

class EnhancedLoadingIndicator extends StatefulWidget {
  final String? message;
  final Color? color;
  final double? size;
  final LoadingType type;
  final bool showBackground;
  final double? progress;
  final Duration animationDuration;

  const EnhancedLoadingIndicator({
    Key? key,
    this.message,
    this.color,
    this.size,
    this.type = LoadingType.spinner,
    this.showBackground = true,
    this.progress,
    this.animationDuration = const Duration(milliseconds: 1500),
  }) : super(key: key);

  @override
  State<EnhancedLoadingIndicator> createState() => _EnhancedLoadingIndicatorState();
}

class _EnhancedLoadingIndicatorState extends State<EnhancedLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveColor = widget.color ?? AppColors.primary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: _buildLoadingWidget(effectiveColor, isDark),
              );
            },
          ),
          if (widget.message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              widget.message!,
              style: isDark 
                  ? AppTypography.darkBodyMedium
                  : AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingWidget(Color color, bool isDark) {
    switch (widget.type) {
      case LoadingType.spinner:
        return _buildSpinner(color);
      case LoadingType.dots:
        return _buildDots(color);
      case LoadingType.pulse:
        return _buildPulse(color);
      case LoadingType.progress:
        return _buildProgress(color, isDark);
      case LoadingType.bounce:
        return _buildBounce(color);
    }
  }

  Widget _buildSpinner(Color color) {
    return Transform.rotate(
      angle: _rotationAnimation.value * 2 * 3.14159,
      child: Container(
        width: widget.size ?? 40,
        height: widget.size ?? 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.3), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular((widget.size ?? 40) / 2),
        ),
        child: Padding(
          padding: EdgeInsets.all((widget.size ?? 40) * 0.15),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBackground : Colors.white,
              borderRadius: BorderRadius.circular((widget.size ?? 40) / 2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDots(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final animationValue = (_controller.value - delay).clamp(0.0, 1.0);
            final scale = 0.5 + (animationValue * 0.5);
            
            return Container(
              width: 8,
              height: 8,
              margin: EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(animationValue),
                shape: BoxShape.circle,
              ),
              transform: Matrix4.identity()..scale(scale),
            );
          },
        );
      }),
    );
  }

  Widget _buildPulse(Color color) {
    return Container(
      width: widget.size ?? 40,
      height: widget.size ?? 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final pulseValue = (_controller.value % 1.0);
          return Container(
            width: (widget.size ?? 40) * (0.5 + pulseValue * 0.5),
            height: (widget.size ?? 40) * (0.5 + pulseValue * 0.5),
            decoration: BoxDecoration(
              color: color.withOpacity(1.0 - pulseValue * 0.5),
              shape: BoxShape.circle,
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgress(Color color, bool isDark) {
    return Container(
      width: widget.size ?? 200,
      height: 8,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBorder : Colors.grey[300],
        borderRadius: AppBorderRadius.radiusSM,
      ),
      child: ClipRRect(
        borderRadius: AppBorderRadius.radiusSM,
        child: LinearProgressIndicator(
          value: widget.progress ?? _controller.value,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    );
  }

  Widget _buildBounce(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.15;
            final animationValue = ((_controller.value + delay) % 1.0);
            final bounceValue = (animationValue * 2 * 3.14159).sin();
            final offset = bounceValue * 10;
            
            return Container(
              width: 12,
              height: 12,
              margin: EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              transform: Matrix4.translationValues(0, -offset, 0),
            );
          },
        );
      }),
    );
  }
}

enum LoadingType {
  spinner,
  dots,
  pulse,
  progress,
  bounce,
}

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;
  final Color? backgroundColor;
  final Color? spinnerColor;
  final LoadingType loadingType;

  const LoadingOverlay({
    Key? key,
    required this.child,
    required this.isLoading,
    this.message,
    this.backgroundColor,
    this.spinnerColor,
    this.loadingType = LoadingType.spinner,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: (backgroundColor ?? Colors.black).withOpacity(0.5),
            child: Center(
              child: EnhancedLoadingIndicator(
                message: message,
                color: spinnerColor,
                type: loadingType,
              ),
            ),
          ),
      ],
    );
  }
}

class PullToRefreshLoading extends StatefulWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final Color? color;
  final String? message;

  const PullToRefreshLoading({
    Key? key,
    required this.onRefresh,
    required this.child,
    this.color,
    this.message,
  }) : super(key: key);

  @override
  State<PullToRefreshLoading> createState() => _PullToRefreshLoadingState();
}

class _PullToRefreshLoadingState extends State<PullToRefreshLoading> {
  bool _isRefreshing = false;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: widget.color ?? AppColors.primary,
      child: widget.child,
    );
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    try {
      await widget.onRefresh();
    } finally {
      setState(() => _isRefreshing = false);
    }
  }
}

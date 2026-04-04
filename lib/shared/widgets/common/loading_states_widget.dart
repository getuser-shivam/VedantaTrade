import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Enhanced loading states with better UX
class LoadingStatesWidget {
  /// Skeleton loading widget
  static Widget skeleton({
    double? width,
    double? height,
    EdgeInsetsGeometry? margin,
    Color? baseColor,
    Color? highlightColor,
    BorderRadius? borderRadius,
    bool isAnimated = true,
    Duration? animationDuration,
  }) {
    return _SkeletonLoader(
      width: width,
      height: height,
      margin: margin,
      baseColor: baseColor,
      highlightColor: highlightColor,
      borderRadius: borderRadius,
      isAnimated: isAnimated,
      animationDuration: animationDuration,
    );
  }

  /// Shimmer loading widget
  static Widget shimmer({
    required Widget child,
    Color? baseColor,
    Color? highlightColor,
    Duration? duration,
    bool enabled = true,
  }) {
    return _ShimmerLoader(
      child: child,
      baseColor: baseColor,
      highlightColor: highlightColor,
      duration: duration,
      enabled: enabled,
    );
  }

  /// Pulse loading widget
  static Widget pulse({
    required Widget child,
    Color? pulseColor,
    double? scale,
    Duration? duration,
    bool enabled = true,
  }) {
    return _PulseLoader(
      child: child,
      pulseColor: pulseColor,
      scale: scale,
      duration: duration,
      enabled: enabled,
    );
  }

  /// Spin loading widget
  static Widget spin({
    required Widget child,
    Color? spinColor,
    double? size,
    Duration? duration,
    bool enabled = true,
  }) {
    return _SpinLoader(
      child: child,
      spinColor: spinColor,
      size: size,
      duration: duration,
      enabled: enabled,
    );
  }

  /// Progress loading widget
  static Widget progress({
    required double value,
    String? message,
    Color? backgroundColor,
    Color? progressColor,
    double? height,
    double? borderRadius,
    bool showPercentage = true,
    bool isAnimated = true,
    Duration? animationDuration,
  }) {
    return _ProgressLoader(
      value: value,
      message: message,
      backgroundColor: backgroundColor,
      progressColor: progressColor,
      height: height,
      borderRadius: borderRadius,
      showPercentage: showPercentage,
      isAnimated: isAnimated,
      animationDuration: animationDuration,
    );
  }

  /// Staggered loading widget
  static Widget staggered({
    required List<Widget> children,
    Duration? staggerDuration,
    Duration? animationDuration,
    bool enabled = true,
  }) {
    return _StaggeredLoader(
      children: children,
      staggerDuration: staggerDuration,
      animationDuration: animationDuration,
      enabled: enabled,
    );
  }

  /// Wave loading widget
  static Widget wave({
    required Widget child,
    Color? waveColor,
    double? amplitude,
    double? frequency,
    Duration? duration,
    bool enabled = true,
  }) {
    return _WaveLoader(
      child: child,
      waveColor: waveColor,
      amplitude: amplitude,
      frequency: frequency,
      duration: duration,
      enabled: enabled,
    );
  }

  /// Bounce loading widget
  static Widget bounce({
    required Widget child,
    Color? bounceColor,
    double? bounceHeight,
    Duration? duration,
    bool enabled = true,
  }) {
    return _BounceLoader(
      child: child,
      bounceColor: bounceColor,
      bounceHeight: bounceHeight,
      duration: duration,
      enabled: enabled,
    );
  }

  /// Fade loading widget
  static Widget fade({
    required Widget child,
    Color? fadeColor,
    Duration? duration,
    bool enabled = true,
  }) {
    return _FadeLoader(
      child: child,
      fadeColor: fadeColor,
      duration: duration,
      enabled: enabled,
    );
  }

  /// Scale loading widget
  static Widget scale({
    required Widget child,
    Color? scaleColor,
    double? scale,
    Duration? duration,
    bool enabled = true,
  }) {
    return _ScaleLoader(
      child: child,
      scaleColor: scaleColor,
      scale: scale,
      duration: duration,
      enabled: enabled,
    );
  }

  /// Rotating loading widget
  static Widget rotate({
    required Widget child,
    Color? rotateColor,
    double? degrees,
    Duration? duration,
    bool enabled = true,
  }) {
    return _RotateLoader(
      child: child,
      rotateColor: rotateColor,
      degrees: degrees,
      duration: duration,
      enabled: enabled,
    );
  }

  /// Elastic loading widget
  static Widget elastic({
    required Widget child,
    Color? elasticColor,
    double? elasticity,
    Duration? duration,
    bool enabled = true,
  }) {
    return _ElasticLoader(
      child: child,
      elasticColor: elasticColor,
      elasticity: elasticity,
      duration: duration,
      enabled: enabled,
    );
  }

  /// Custom loading widget with multiple effects
  static Widget custom({
    required Widget child,
    required List<LoadingEffect> effects,
    bool enabled = true,
  }) {
    return _CustomLoader(
      child: child,
      effects: effects,
      enabled: enabled,
    );
  }
}

/// Loading effect enum
enum LoadingEffect {
  skeleton,
  shimmer,
  pulse,
  spin,
  progress,
  staggered,
  wave,
  bounce,
  fade,
  scale,
  rotate,
  elastic,
}

/// Private implementation classes for loading states
class _SkeletonLoader extends StatefulWidget {
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final Color? baseColor;
  final Color? highlightColor;
  final BorderRadius? borderRadius;
  final bool isAnimated;
  final Duration? animationDuration;

  const _SkeletonLoader({
    Key? key,
    this.width,
    this.height,
    this.margin,
    this.baseColor,
    this.highlightColor,
    this.borderRadius,
    this.isAnimated = true,
    this.animationDuration,
  }) : super(key: key);

  @override
  State<_SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<_SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.isAnimated) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.baseColor ?? Colors.grey[300]!;
    final highlightColor = widget.highlightColor ?? Colors.grey[100]!;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                0.0,
                0.3,
                0.5,
                1.0,
              ],
              transform: GradientRotation(_animation.value * 3.14159),
            ),
          ),
        );
      },
    );
  }
}

class _ShimmerLoader extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration? duration;
  final bool enabled;

  const _ShimmerLoader({
    Key? key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<_ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<_ShimmerLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    final baseColor = widget.baseColor ?? Colors.grey[300]!;
    final highlightColor = widget.highlightColor ?? Colors.grey[100]!;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                baseColor,
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                0.0,
                0.3,
                0.5,
                1.0,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: GradientRotation(_animation.value * 3.14159),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class _PulseLoader extends StatefulWidget {
  final Widget child;
  final Color? pulseColor;
  final double? scale;
  final Duration? duration;
  final bool enabled;

  const _PulseLoader({
    Key? key,
    required this.child,
    this.pulseColor,
    this.scale,
    this.duration,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<_PulseLoader> createState() => _PulseLoaderState();
}

class _PulseLoaderState extends State<_PulseLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 1.0,
      end: widget.scale ?? 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.enabled) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: (widget.pulseColor ?? Colors.blue).withOpacity(0.3),
                  blurRadius: 10.0,
                  spreadRadius: 2.0,
                ),
              ],
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}

class _SpinLoader extends StatefulWidget {
  final Widget child;
  final Color? spinColor;
  final double? size;
  final Duration? duration;
  final bool enabled;

  const _SpinLoader({
    Key? key,
    required this.child,
    this.spinColor,
    this.size,
    this.duration,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<_SpinLoader> createState() => _SpinLoaderState();
}

class _SpinLoaderState extends State<_SpinLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? const Duration(milliseconds: 2000),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);

    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value * 6.28318, // 2 * PI
          child: Container(
            width: widget.size ?? 24,
            height: widget.size ?? 24,
            decoration: BoxDecoration(
              color: widget.spinColor ?? Colors.blue,
              shape: BoxShape.circle,
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}

class _ProgressLoader extends StatefulWidget {
  final double value;
  final String? message;
  final Color? backgroundColor;
  final Color? progressColor;
  final double? height;
  final double? borderRadius;
  final bool showPercentage;
  final bool isAnimated;
  final Duration? animationDuration;

  const _ProgressLoader({
    Key? key,
    required this.value,
    this.message,
    this.backgroundColor,
    this.progressColor,
    this.height,
    this.borderRadius,
    this.showPercentage = true,
    this.isAnimated = true,
    this.animationDuration,
  }) : super(key: key);

  @override
  State<_ProgressLoader> createState() => _ProgressLoaderState();
}

class _ProgressLoaderState extends State<_ProgressLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.isAnimated) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? Colors.grey[200],
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.message != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    widget.message!,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: _animation.value,
                      backgroundColor: Colors.grey[300],
                      valueColor: widget.progressColor ?? Colors.blue,
                    ),
                    if (widget.showPercentage)
                      const SizedBox(height: 8),
                    if (widget.showPercentage)
                      Text(
                        '${(_animation.value * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Placeholder implementations for remaining loading widgets
class _StaggeredLoader extends StatefulWidget {
  final List<Widget> children;
  final Duration? staggerDuration;
  final Duration? animationDuration;
  final bool enabled;

  const _StaggeredLoader({
    Key? key,
    required this.children,
    this.staggerDuration,
    this.animationDuration,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<_StaggeredLoader> createState() => _StaggeredLoaderState();
}

class _StaggeredLoaderState extends State<_StaggeredLoader>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.children.length,
      (index) => AnimationController(
        duration: widget.animationDuration ?? const Duration(milliseconds: 500),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));
    }).toList();

    if (widget.enabled) {
      for (int i = 0; i < _controllers.length; i++) {
        Future.delayed(
          Duration(milliseconds: i * (widget.staggerDuration?.inMilliseconds ?? 100)),
          () {
            _controllers[i].forward();
          },
        );
      }
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
    if (!widget.enabled) {
      return Column(children: widget.children);
    }

    return Column(
      children: List.generate(widget.children.length, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Transform.scale(
              scale: _animations[index].value,
              child: Opacity(
                opacity: _animations[index].value,
                child: widget.children[index],
              ),
            );
          },
        );
      }),
    );
  }
}

/// Placeholder implementations for remaining loading widgets
class _WaveLoader extends StatefulWidget {
  final Widget child;
  final Color? waveColor;
  final double? amplitude;
  final double? frequency;
  final Duration? duration;
  final bool enabled;

  const _WaveLoader({
    Key? key,
    required this.child,
    this.waveColor,
    this.amplitude,
    this.frequency,
    this.duration,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<_WaveLoader> createState() => _WaveLoaderState();
}

class _WaveLoaderState extends State<_WaveLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? const Duration(milliseconds: 2000),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);

    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value * (widget.amplitude ?? 10)),
          child: widget.child,
        );
      },
    );
  }
}

/// Placeholder implementations for remaining loading widgets
class _BounceLoader extends StatefulWidget {
  final Widget child;
  final Color? bounceColor;
  final double? bounceHeight;
  final Duration? duration;
  final bool enabled;

  const _BounceLoader({
    Key? key,
    required this.child,
    this.bounceColor,
    this.bounceHeight,
    this.duration,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<_BounceLoader> createState() => _BounceLoaderState();
}

class _BounceLoaderState extends State<_BounceLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceOut,
    ));

    if (widget.enabled) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_animation.value * (widget.bounceHeight ?? 20)),
          child: widget.child,
        );
      },
    );
  }
}

/// Placeholder implementations for remaining loading widgets
class _FadeLoader extends StatefulWidget {
  final Widget child;
  final Color? fadeColor;
  final Duration? duration;
  final bool enabled;

  const _FadeLoader({
    Key? key,
    required this.child,
    this.fadeColor,
    this.duration,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<_FadeLoader> createState() => _FadeLoaderState();
}

class _FadeLoaderState extends State<_FadeLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.enabled) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}

/// Placeholder implementations for remaining loading widgets
class _ScaleLoader extends StatefulWidget {
  final Widget child;
  final Color? scaleColor;
  final double? scale;
  final Duration? duration;
  final bool enabled;

  const _ScaleLoader({
    Key? key,
    required this.child,
    this.scaleColor,
    this.scale,
    this.duration,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<_ScaleLoader> createState() => _ScaleLoaderState();
}

class _ScaleLoaderState extends State<_ScaleLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.8,
      end: widget.scale ?? 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.enabled) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}

/// Placeholder implementations for remaining loading widgets
class _RotateLoader extends StatefulWidget {
  final Widget child;
  final Color? rotateColor;
  final double? degrees;
  final Duration? duration;
  final bool enabled;

  const _RotateLoader({
    Key? key,
    required this.child,
    this.rotateColor,
    this.degrees,
    this.duration,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<_RotateLoader> createState() => _RotateLoaderState();
}

class _RotateLoaderState extends State<_RotateLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? const Duration(milliseconds: 2000),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.degrees ?? 360.0,
    ).animate(_controller);

    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value * 3.14159 / 180,
          child: widget.child,
        );
      },
    );
  }
}

/// Placeholder implementations for remaining loading widgets
class _ElasticLoader extends StatefulWidget {
  final Widget child;
  final Color? elasticColor;
  final double? elasticity;
  final Duration? duration;
  final bool enabled;

  const _ElasticLoader({
    Key? key,
    required this.child,
    this.elasticColor,
    this.elasticity,
    this.duration,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<_ElasticLoader> createState() => _ElasticLoaderState();
}

class _ElasticLoaderState extends State<_ElasticLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

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
      curve: Curves.elasticOut,
    ));

    if (widget.enabled) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_animation.value * (widget.elasticity ?? 0.2)),
          child: widget.child,
        );
      },
    );
  }
}

/// Placeholder implementations for remaining loading widgets
class _CustomLoader extends StatefulWidget {
  final Widget child;
  final List<LoadingEffect> effects;
  final bool enabled;

  const _CustomLoader({
    Key? key,
    required this.child,
    required this.effects,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<_CustomLoader> createState() => _CustomLoaderState();
}

class _CustomLoaderState extends State<_CustomLoader> {
  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    // Apply multiple effects based on the effects list
    Widget currentChild = widget.child;
    
    for (final effect in widget.effects) {
      switch (effect) {
        case LoadingEffect.skeleton:
          currentChild = LoadingStatesWidget.skeleton(child: currentChild);
          break;
        case LoadingEffect.shimmer:
          currentChild = LoadingStatesWidget.shimmer(child: currentChild);
          break;
        case LoadingEffect.pulse:
          currentChild = LoadingStatesWidget.pulse(child: currentChild);
          break;
        case LoadingEffect.spin:
          currentChild = LoadingStatesWidget.spin(child: currentChild);
          break;
        case LoadingEffect.progress:
          // Progress effect needs a value, so we'll use a default
          currentChild = LoadingStatesWidget.progress(value: 0.5, child: currentChild);
          break;
        case LoadingEffect.staggered:
          currentChild = LoadingStatesWidget.staggered(children: [currentChild]);
          break;
        case LoadingEffect.wave:
          currentChild = LoadingStatesWidget.wave(child: currentChild);
          break;
        case LoadingEffect.bounce:
          currentChild = LoadingStatesWidget.bounce(child: currentChild);
          break;
        case LoadingEffect.fade:
          currentChild = LoadingStatesWidget.fade(child: currentChild);
          break;
        case LoadingEffect.scale:
          currentChild = LoadingStatesWidget.scale(child: currentChild);
          break;
        case LoadingEffect.rotate:
          currentChild = LoadingStatesWidget.rotate(child: currentChild);
          break;
        case LoadingEffect.elastic:
          currentChild = LoadingStatesWidget.elastic(child: currentChild);
          break;
      }
    }

    return currentChild;
  }
}

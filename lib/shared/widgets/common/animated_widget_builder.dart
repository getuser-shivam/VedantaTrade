import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Animated widget builder with smooth transitions
class AnimatedWidgetBuilder extends StatefulWidget {
  final Widget Function(BuildContext, Animation<double>) builder;
  final Duration? duration;
  final Curve? curve;
  final bool autoStart;
  final VoidCallback? onComplete;
  final VoidCallback? onStart;
  final bool repeat;
  final bool reverse;

  const AnimatedWidgetBuilder({
    Key? key,
    required this.builder,
    this.duration,
    this.curve,
    this.autoStart = true,
    this.onComplete,
    this.onStart,
    this.repeat = false,
    this.reverse = false,
  }) : super(key: key);

  @override
  State<AnimatedWidgetBuilder> createState() => _AnimatedWidgetBuilderState();
}

class _AnimatedWidgetBuilderState extends State<AnimatedWidgetBuilder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve ?? Curves.easeInOut,
    );

    if (widget.autoStart) {
      if (widget.reverse) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    }

    if (widget.repeat) {
      _controller.repeat();
    }

    _controller.addStatusListener(_handleStatusChange);
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_handleStatusChange);
    _controller.dispose();
    super.dispose();
  }

  void _handleStatusChange(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.forward:
        widget.onStart?.call();
        break;
      case AnimationStatus.completed:
        widget.onComplete?.call();
        if (!widget.repeat) {
          _controller.reverse();
        }
        break;
      case AnimationStatus.dismissed:
        if (!widget.repeat) {
          _controller.forward();
        }
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: widget.builder,
    );
  }
}

/// Staggered animation builder for multiple widgets
class StaggeredAnimationBuilder extends StatefulWidget {
  final List<Widget> children;
  final List<Duration> durations;
  final List<Curve> curves;
  final bool autoStart;
  final VoidCallback? onComplete;

  const StaggeredAnimationBuilder({
    Key? key,
    required this.children,
    this.durations = const [Duration(milliseconds: 300)],
    this.curves = const [Curves.easeInOut],
    this.autoStart = true,
    this.onComplete,
  }) : super(key: key);

  @override
  State<StaggeredAnimationBuilder> createState() => _StaggeredAnimationBuilderState();
}

class _StaggeredAnimationBuilderState extends State<StaggeredAnimationBuilder>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  int _completedCount = 0;

  @override
  void initState() {
    super.initState();
    
    _controllers = List.generate(
      widget.children.length,
      (index) => AnimationController(
        duration: widget.durations[index % widget.durations.length],
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return CurvedAnimation(
        parent: controller,
        curve: widget.curves[index % widget.curves.length],
      );
    }).toList();

    if (widget.autoStart) {
      _startAnimations();
    }

    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i].addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _completedCount++;
          if (_completedCount == widget.children.length) {
            widget.onComplete?.call();
          }
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

  void _startAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        _controllers[i].forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(widget.children.length, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, animation) {
            return Transform.scale(
              scale: animation.value,
              child: Opacity(
                opacity: animation.value,
                child: widget.children[index],
              ),
            );
          },
        );
      }),
    );
  }
}

/// Parallax animation builder
class ParallaxBuilder extends StatefulWidget {
  final Widget child;
  final double parallaxFactor;
  final ScrollController? scrollController;
  final bool vertical;
  final bool enabled;

  const ParallaxBuilder({
    Key? key,
    required this.child,
    this.parallaxFactor = 0.5,
    this.scrollController,
    this.vertical = true,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<ParallaxBuilder> createState() => _ParallaxBuilderState();
}

class _ParallaxBuilderState extends State<ParallaxBuilder> {
  late ScrollController _scrollController;
  double _previousScrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.removeListener(_handleScroll);
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _handleScroll() {
    if (!widget.enabled) return;

    final currentOffset = widget.vertical
        ? _scrollController.offset.dy
        : _scrollController.offset.dx;

    if (currentOffset != _previousScrollOffset) {
      setState(() {
        _previousScrollOffset = currentOffset;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    final offset = widget.vertical
        ? _scrollController.offset.dy
        : _scrollController.offset.dx;

    return Transform.translate(
      offset: widget.vertical
          ? Offset(0, offset * widget.parallaxFactor)
          : Offset(offset * widget.parallaxFactor, 0),
      child: widget.child,
    );
  }
}

/// Morphing animation builder
class MorphingBuilder extends StatefulWidget {
  final Widget Function(BuildContext, double progress) builder;
  final Duration? duration;
  final Curve? curve;
  final bool autoStart;
  final VoidCallback? onComplete;

  const MorphingBuilder({
    Key? key,
    required this.builder,
    this.duration,
    this.curve,
    this.autoStart = true,
    this.onComplete,
  }) : super(key: key);

  @override
  State<MorphingBuilder> createState() => _MorphingBuilderState();
}

class _MorphingBuilderState extends State<MorphingBuilder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve ?? Curves.easeInOut,
    );

    if (widget.autoStart) {
      _controller.forward();
    }

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
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
      builder: widget.builder,
    );
  }
}

/// Reveal animation builder
class RevealBuilder extends StatefulWidget {
  final Widget child;
  final Duration? duration;
  final Curve? curve;
  final bool autoStart;
  final Axis direction;
  final bool reverse;
  final VoidCallback? onComplete;

  const RevealBuilder({
    Key? key,
    required this.child,
    this.duration,
    this.curve,
    this.autoStart = true,
    this.direction = Axis.horizontal,
    this.reverse = false,
    this.onComplete,
  }) : super(key: key);

  @override
  State<RevealBuilder> createState() => _RevealBuilderState();
}

class _RevealBuilderState extends State<RevealBuilder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? const Duration(milliseconds: 600),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve ?? Curves.easeInOut,
    );

    if (widget.autoStart) {
      if (widget.reverse) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    }

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
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
      builder: (context, animation) {
        return ClipRect(
          clipper: _RevealClipper(
            progress: animation.value,
            direction: widget.direction,
            reverse: widget.reverse,
          ),
          child: widget.child,
        );
      },
    );
  }
}

class _RevealClipper extends CustomClipper {
  final double progress;
  final Axis direction;
  final bool reverse;

  const _RevealClipper({
    required this.progress,
    required this.direction,
    required this.reverse,
  });

  @override
  Rect getClip(Size size) {
    switch (direction) {
      case Axis.horizontal:
        final clipWidth = size.width * (reverse ? (1 - progress) : progress);
        return Rect.fromLTWH(
          reverse ? size.width - clipWidth : 0,
          0,
          clipWidth,
          size.height,
        );
      case Axis.vertical:
        final clipHeight = size.height * (reverse ? (1 - progress) : progress);
        return Rect.fromLTWH(
          0,
          reverse ? size.height - clipHeight : 0,
          size.width,
          clipHeight,
        );
    }
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return oldClipper is _RevealClipper &&
        (oldClipper as _RevealClipper).progress != progress;
  }
}

/// Particle animation builder
class ParticleBuilder extends StatefulWidget {
  final Widget child;
  final int particleCount;
  final Duration? duration;
  final bool autoStart;
  final List<Color>? colors;
  final List<double>? sizes;
  final List<Offset>? directions;

  const ParticleBuilder({
    Key? key,
    required this.child,
    this.particleCount = 20,
    this.duration,
    this.autoStart = true,
    this.colors,
    this.sizes,
    this.directions,
  }) : super(key: key);

  @override
  State<ParticleBuilder> createState() => _ParticleBuilderState();
}

class _ParticleBuilderState extends State<ParticleBuilder>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animations = List.generate(widget.particleCount, (index) {
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(
          index / widget.particleCount,
          (index + 1) / widget.particleCount,
          Curves.easeOut,
        ),
      );
    });

    _particles = List.generate(widget.particleCount, (index) {
      return Particle(
        color: widget.colors?[index % (widget.colors?.length ?? 1)] ?? Colors.white,
        size: widget.sizes?[index % (widget.sizes?.length ?? 1)] ?? 4.0,
        direction: widget.directions?[index % (widget.directions?.length ?? 1)] ?? 
            Offset.random().direction,
        initialPosition: Offset.zero,
      );
    });

    if (widget.autoStart) {
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
      builder: (context, animation) {
        return Stack(
          children: List.generate(widget.particleCount, (index) {
            final particle = _particles[index];
            final progress = _animations[index].value;
            final position = particle.initialPosition + (particle.direction * progress * 100);
            
            return Positioned(
              left: position.dx,
              top: position.dy,
              child: Container(
                width: particle.size,
                height: particle.size,
                decoration: BoxDecoration(
                  color: particle.color.withOpacity(1 - progress),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class Particle {
  final Color color;
  final double size;
  final Offset direction;
  final Offset initialPosition;

  const Particle({
    required this.color,
    required this.size,
    required this.direction,
    required this.initialPosition,
  });
}

/// Magnetic animation builder
class MagneticBuilder extends StatefulWidget {
  final Widget child;
  final double magnetStrength;
  final Duration? duration;
  final bool autoStart;

  const MagneticBuilder({
    Key? key,
    required this.child,
    this.magnetStrength = 0.1,
    this.duration,
    this.autoStart = true,
  }) : super(key: key);

  @override
  State<MagneticBuilder> createState() => _MagneticBuilderState();
}

class _MagneticBuilderState extends State<MagneticBuilder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  Offset _targetPosition = Offset.zero;
  Offset _currentPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    if (widget.autoStart) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateTargetPosition(Offset position) {
    setState(() {
      _targetPosition = position;
    });
    
    final tween = Tween<Offset>(
      begin: _currentPosition,
      end: _targetPosition,
    );
    
    _animation = tween.animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    
    _controller.reset();
    _controller.forward();
    
    _currentPosition = _targetPosition;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, animation) {
        return Transform.translate(
          offset: animation.value,
          child: widget.child,
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Enhanced gesture detector with haptic feedback and visual feedback
class GestureDetectorWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onPanStart;
  final VoidCallback? onPanEnd;
  final Function(DragUpdateDetails)? onPanUpdate;
  final Function(ScaleStartDetails)? onScaleStart;
  final Function(ScaleUpdateDetails)? onScaleUpdate;
  final Function(ScaleEndDetails)? onScaleEnd;
  final Function(RotationStartDetails)? onRotationStart;
  final Function(RotationUpdateDetails)? onRotationUpdate;
  final Function(RotationEndDetails)? onRotationEnd;
  final double? threshold;
  final bool enableHapticFeedback;
  final bool enableVisualFeedback;
  final Color? feedbackColor;
  final double? feedbackScale;
  final Duration? hapticDelay;

  const GestureDetectorWidget({
    Key? key,
    required this.child,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onPanStart,
    this.onPanEnd,
    this.onPanUpdate,
    this.onScaleStart,
    this.onScaleUpdate,
    this.onScaleEnd,
    this.onRotationStart,
    this.onRotationUpdate,
    this.onRotationEnd,
    this.threshold,
    this.enableHapticFeedback = true,
    this.enableVisualFeedback = true,
    this.feedbackColor,
    this.feedbackScale,
    this.hapticDelay,
  }) : super(key: key);

  @override
  State<GestureDetectorWidget> createState() => _GestureDetectorWidgetState();
}

class _GestureDetectorWidgetState extends State<GestureDetectorWidget>
    with TickerProviderStateMixin {
  late AnimationController _feedbackController;
  late Animation<double> _feedbackAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _feedbackAnimation = Tween<double>(
      begin: 1.0,
      end: widget.feedbackScale ?? 0.95,
    ).animate(CurvedAnimation(
      parent: _feedbackController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _triggerFeedback() {
    if (widget.enableHapticFeedback) {
      final delay = widget.hapticDelay ?? Duration.zero;
      Future.delayed(delay, () {
        HapticFeedback.lightImpact();
      });
    }

    if (widget.enableVisualFeedback) {
      setState(() {
        _isPressed = true;
      });
      
      _feedbackController.forward().then((_) {
        _feedbackController.reverse();
      });
      
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            _isPressed = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _feedbackController,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.enableVisualFeedback ? _feedbackAnimation.value : 1.0,
          child: Container(
            decoration: widget.enableVisualFeedback && _isPressed
                ? BoxDecoration(
                    color: (widget.feedbackColor ?? Colors.white).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  )
                : null,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onTap != null
                  ? () {
                      _triggerFeedback();
                      widget.onTap!();
                    }
                  : null,
              onDoubleTap: widget.onDoubleTap != null
                  ? () {
                      _triggerFeedback();
                      widget.onDoubleTap!();
                    }
                  : null,
              onLongPress: widget.onLongPress != null
                  ? () {
                      _triggerFeedback();
                      widget.onLongPress!();
                    }
                  : null,
              onPanStart: widget.onPanStart != null
                  ? (details) {
                      _triggerFeedback();
                      widget.onPanStart!(details);
                    }
                  : null,
              onPanEnd: widget.onPanEnd != null
                  ? (details) {
                      widget.onPanEnd!(details);
                    }
                  : null,
              onPanUpdate: widget.onPanUpdate != null
                  ? (details) {
                      widget.onPanUpdate!(details);
                    }
                  : null,
              onScaleStart: widget.onScaleStart != null
                  ? (details) {
                      _triggerFeedback();
                      widget.onScaleStart!(details);
                    }
                  : null,
              onScaleUpdate: widget.onScaleUpdate != null
                  ? (details) {
                      widget.onScaleUpdate!(details);
                    }
                  : null,
              onScaleEnd: widget.onScaleEnd != null
                  ? (details) {
                      widget.onScaleEnd!(details);
                    }
                  : null,
              onRotationStart: widget.onRotationStart != null
                  ? (details) {
                      _triggerFeedback();
                      widget.onRotationStart!(details);
                    }
                  : null,
              onRotationUpdate: widget.onRotationUpdate != null
                  ? (details) {
                      widget.onRotationUpdate!(details);
                    }
                  : null,
              onRotationEnd: widget.onRotationEnd != null
                  ? (details) {
                      widget.onRotationEnd!(details);
                    }
                  : null,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

/// Swipe gesture detector
class SwipeGestureDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onSwipeUp;
  final VoidCallback? onSwipeDown;
  final double? threshold;
  final bool enableHapticFeedback;

  const SwipeGestureDetector({
    Key? key,
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onSwipeUp,
    this.onSwipeDown,
    this.threshold,
    this.enableHapticFeedback = true,
  }) : super(key: key);

  @override
  State<SwipeGestureDetector> createState() => _SwipeGestureDetectorState();
}

class _SwipeGestureDetectorState extends State<SwipeGestureDetector> {
  double _startX = 0.0;
  double _startY = 0.0;
  bool _isSwiping = false;

  void _handleSwipe(double deltaX, double deltaY) {
    final threshold = widget.threshold ?? 50.0;
    
    if (deltaX.abs() > threshold) {
      if (deltaX > 0) {
        widget.onSwipeRight?.call();
      } else {
        widget.onSwipeLeft?.call();
      }
      
      if (widget.enableHapticFeedback) {
        HapticFeedback.mediumImpact();
      }
    } else if (deltaY.abs() > threshold) {
      if (deltaY > 0) {
        widget.onSwipeDown?.call();
      } else {
        widget.onSwipeUp?.call();
      }
      
      if (widget.enableHapticFeedback) {
        HapticFeedback.mediumImpact();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        _startX = details.globalPosition.dx;
        _startY = details.globalPosition.dy;
        _isSwiping = true;
      },
      onPanUpdate: (details) {
        if (_isSwiping) {
          final deltaX = details.globalPosition.dx - _startX;
          final deltaY = details.globalPosition.dy - _startY;
          _handleSwipe(deltaX, deltaY);
        }
      },
      onPanEnd: (details) {
        _isSwiping = false;
      },
      child: widget.child,
    );
  }
}

/// Pinch gesture detector
class PinchGestureDetector extends StatefulWidget {
  final Widget child;
  final Function(double scale)? onPinchStart;
  final Function(double scale)? onPinchUpdate;
  final Function(double scale)? onPinchEnd;
  final double? minScale;
  final double? maxScale;
  final bool enableHapticFeedback;

  const PinchGestureDetector({
    Key? key,
    required this.child,
    this.onPinchStart,
    this.onPinchUpdate,
    this.onPinchEnd,
    this.minScale = 0.5,
    this.maxScale = 3.0,
    this.enableHapticFeedback = true,
  }) : super(key: key);

  @override
  State<PinchGestureDetector> createState() => _PinchGestureDetectorState();
}

class _PinchGestureDetectorState extends State<PinchGestureDetector> {
  double _initialScale = 1.0;

  void _handlePinch(double scale) {
    final clampedScale = scale.clamp(
      widget.minScale ?? 0.5,
      widget.maxScale ?? 3.0,
    );
    
    if (widget.onPinchUpdate != null) {
      widget.onPinchUpdate!(clampedScale);
    }
    
    if (widget.enableHapticFeedback) {
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (details) {
        _initialScale = details.focalPointScale;
        
        if (widget.onPinchStart != null) {
          widget.onPinchStart!(_initialScale);
        }
        
        if (widget.enableHapticFeedback) {
          HapticFeedback.lightImpact();
        }
      },
      onScaleUpdate: (details) {
        _handlePinch(details.focalPointScale);
      },
      onScaleEnd: (details) {
        if (widget.onPinchEnd != null) {
          widget.onPinchEnd!(details.focalPointScale);
        }
        
        if (widget.enableHapticFeedback) {
          HapticFeedback.lightImpact();
        }
      },
      child: widget.child,
    );
  }
}

/// Long press gesture detector
class LongPressGestureDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback? onLongPress;
  final VoidCallback? onLongPressStart;
  final VoidCallback? onLongPressEnd;
  final Duration? longPressDuration;
  final bool enableHapticFeedback;
  final bool enableVisualFeedback;

  const LongPressGestureDetector({
    Key? key,
    required this.child,
    this.onLongPress,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.longPressDuration,
    this.enableHapticFeedback = true,
    this.enableVisualFeedback = true,
  }) : super(key: key);

  @override
  State<LongPressGestureDetector> createState() => _LongPressGestureDetectorState();
}

class _LongPressGestureDetectorState extends State<LongPressGestureDetector>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isLongPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleLongPressStart() {
    setState(() {
      _isLongPressed = true;
    });
    
    _animationController.forward();
    
    if (widget.enableHapticFeedback) {
      HapticFeedback.heavyImpact();
    }
    
    if (widget.onLongPressStart != null) {
      widget.onLongPressStart!();
    }
  }

  void _handleLongPressEnd() {
    setState(() {
      _isLongPressed = false;
    });
    
    _animationController.reverse();
    
    if (widget.onLongPressEnd != null) {
      widget.onLongPressEnd!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.enableVisualFeedback ? _scaleAnimation.value : 1.0,
          child: GestureDetector(
            onLongPressStart: (details) {
              _handleLongPressStart();
            },
            onLongPress: widget.onLongPress != null
                ? () {
                    widget.onLongPress!();
                  }
                : null,
            onLongPressEnd: (details) {
              _handleLongPressEnd();
            },
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Drag gesture detector
class DragGestureDetector extends StatefulWidget {
  final Widget child;
  final Function(Offset)? onDragStart;
  final Function(Offset)? onDragUpdate;
  final Function(Offset)? onDragEnd;
  final Widget Function(Offset)? dragFeedback;
  final bool enableHapticFeedback;
  final bool enableVisualFeedback;

  const DragGestureDetector({
    Key? key,
    required this.child,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.dragFeedback,
    this.enableHapticFeedback = true,
    this.enableVisualFeedback = true,
  }) : super(key: key);

  @override
  State<DragGestureDetector> createState() => _DragGestureDetectorState();
}

class _DragGestureDetectorState extends State<DragGestureDetector> {
  Offset? _dragPosition;
  bool _isDragging = false;

  void _handleDragStart(Offset position) {
    setState(() {
      _dragPosition = position;
      _isDragging = true;
    });
    
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
    
    if (widget.onDragStart != null) {
      widget.onDragStart!(position);
    }
  }

  void _handleDragUpdate(Offset position) {
    setState(() {
      _dragPosition = position;
    });
    
    if (widget.onDragUpdate != null) {
      widget.onDragUpdate!(position);
    }
  }

  void _handleDragEnd() {
    setState(() {
      _isDragging = false;
    });
    
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
    
    if (widget.onDragEnd != null && _dragPosition != null) {
      widget.onDragEnd!(_dragPosition!);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child = widget.child;
    
    if (widget.enableVisualFeedback && _isDragging && widget.dragFeedback != null) {
      child = Stack(
        children: [
          widget.child,
          if (_dragPosition != null)
            Positioned(
              left: _dragPosition!.dx,
              top: _dragPosition!.dy,
              child: widget.dragFeedback!(_dragPosition!),
            ),
        ],
      );
    }
    
    return GestureDetector(
      onPanStart: (details) {
        _handleDragStart(details.globalPosition);
      },
      onPanUpdate: (details) {
        _handleDragUpdate(details.globalPosition);
      },
      onPanEnd: (details) {
        _handleDragEnd();
      },
      child: child,
    );
  }
}

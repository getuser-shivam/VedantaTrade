import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:vedanta_trade/app/theme/enhanced_app_theme.dart';

class LottieAnimations {
  // Success animations
  static Widget success({double? size, bool repeat = false}) {
    return Lottie.asset(
      'assets/lottie/success.json',
      width: size ?? 100,
      height: size ?? 100,
      repeat: repeat,
      delegates: LottieDelegates(
        values: [
          ValueDelegate.color(
            const ['Shape 1', 'Shape 2', 'Shape 3'],
            value: EnhancedAppTheme.successColor,
          ),
        ],
      ),
    );
  }

  // Loading animations
  static Widget loading({double? size, bool repeat = true}) {
    return Lottie.asset(
      'assets/lottie/loading.json',
      width: size ?? 50,
      height: size ?? 50,
      repeat: repeat,
      delegates: LottieDelegates(
        values: [
          ValueDelegate.color(
            const ['Shape 1', 'Shape 2'],
            value: EnhancedAppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  // Error animations
  static Widget error({double? size, bool repeat = false}) {
    return Lottie.asset(
      'assets/lottie/error.json',
      width: size ?? 100,
      height: size ?? 100,
      repeat: repeat,
      delegates: LottieDelegates(
        values: [
          ValueDelegate.color(
            const ['Shape 1', 'Shape 2'],
            value: EnhancedAppTheme.errorColor,
          ),
        ],
      ),
    );
  }

  // Confetti animation for celebrations
  static Widget confetti({double? size, bool repeat = false}) {
    return Lottie.asset(
      'assets/lottie/confetti.json',
      width: size ?? 200,
      height: size ?? 200,
      repeat: repeat,
    );
  }

  // GPS tracking animation
  static Widget gpsTracking({double? size, bool repeat = true}) {
    return Lottie.asset(
      'assets/lottie/gps_tracking.json',
      width: size ?? 60,
      height: size ?? 60,
      repeat: repeat,
      delegates: LottieDelegates(
        values: [
          ValueDelegate.color(
            const ['Shape 1', 'Shape 2'],
            value: EnhancedAppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  // Checkmark animation
  static Widget checkmark({double? size, bool repeat = false}) {
    return Lottie.asset(
      'assets/lottie/checkmark.json',
      width: size ?? 80,
      height: size ?? 80,
      repeat: repeat,
      delegates: LottieDelegates(
        values: [
          ValueDelegate.color(
            const ['Shape 1'],
            value: EnhancedAppTheme.successColor,
          ),
        ],
      ),
    );
  }

  // Heart animation for likes/favorites
  static Widget heart({double? size, bool repeat = false}) {
    return Lottie.asset(
      'assets/lottie/heart.json',
      width: size ?? 60,
      height: size ?? 60,
      repeat: repeat,
      delegates: LottieDelegates(
        values: [
          ValueDelegate.color(
            const ['Shape 1', 'Shape 2'],
            value: EnhancedAppTheme.accentColor,
          ),
        ],
      ),
    );
  }

  // Shopping cart animation
  static Widget shoppingCart({double? size, bool repeat = false}) {
    return Lottie.asset(
      'assets/lottie/shopping_cart.json',
      width: size ?? 60,
      height: size ?? 60,
      repeat: repeat,
      delegates: LottieDelegates(
        values: [
          ValueDelegate.color(
            const ['Shape 1', 'Shape 2'],
            value: EnhancedAppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  // Notification animation
  static Widget notification({double? size, bool repeat = false}) {
    return Lottie.asset(
      'assets/lottie/notification.json',
      width: size ?? 60,
      height: size ?? 60,
      repeat: repeat,
      delegates: LottieDelegates(
        values: [
          ValueDelegate.color(
            const ['Shape 1', 'Shape 2'],
            value: EnhancedAppTheme.secondaryColor,
          ),
        ],
      ),
    );
  }

  // Search animation
  static Widget search({double? size, bool repeat = true}) {
    return Lottie.asset(
      'assets/lottie/search.json',
      width: size ?? 40,
      height: size ?? 40,
      repeat: repeat,
      delegates: LottieDelegates(
        values: [
          ValueDelegate.color(
            const ['Shape 1', 'Shape 2'],
            value: EnhancedAppTheme.textSecondary,
          ),
        ],
      ),
    );
  }

  // Upload animation
  static Widget upload({double? size, bool repeat = false}) {
    return Lottie.asset(
      'assets/lottie/upload.json',
      width: size ?? 80,
      height: size ?? 80,
      repeat: repeat,
      delegates: LottieDelegates(
        values: [
          ValueDelegate.color(
            const ['Shape 1', 'Shape 2'],
            value: EnhancedAppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  // Download animation
  static Widget download({double? size, bool repeat = false}) {
    return Lottie.asset(
      'assets/lottie/download.json',
      width: size ?? 80,
      height: size ?? 80,
      repeat: repeat,
      delegates: LottieDelegates(
        values: [
          ValueDelegate.color(
            const ['Shape 1', 'Shape 2'],
            value: EnhancedAppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  // Settings animation
  static Widget settings({double? size, bool repeat = false}) {
    return Lottie.asset(
      'assets/lottie/settings.json',
      width: size ?? 60,
      height: size ?? 60,
      repeat: repeat,
      delegates: LottieDelegates(
        values: [
          ValueDelegate.color(
            const ['Shape 1', 'Shape 2'],
            value: EnhancedAppTheme.textSecondary,
          ),
        ],
      ),
    );
  }

  // Chart animation
  static Widget chart({double? size, bool repeat = false}) {
    return Lottie.asset(
      'assets/lottie/chart.json',
      width: size ?? 100,
      height: size ?? 100,
      repeat: repeat,
      delegates: LottieDelegates(
        values: [
          ValueDelegate.color(
            const ['Shape 1', 'Shape 2', 'Shape 3'],
            value: EnhancedAppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  // Trophy animation
  static Widget trophy({double? size, bool repeat = false}) {
    return Lottie.asset(
      'assets/lottie/trophy.json',
      width: size ?? 80,
      height: size ?? 80,
      repeat: repeat,
      delegates: LottieDelegates(
        values: [
          ValueDelegate.color(
            const ['Shape 1', 'Shape 2'],
            value: Colors.amber,
          ),
        ],
      ),
    );
  }

  // Rocket animation for launches
  static Widget rocket({double? size, bool repeat = false}) {
    return Lottie.asset(
      'assets/lottie/rocket.json',
      width: size ?? 100,
      height: size ?? 100,
      repeat: repeat,
      delegates: LottieDelegates(
        values: [
          ValueDelegate.color(
            const ['Shape 1', 'Shape 2'],
            value: EnhancedAppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  // Pulse animation for notifications
  static Widget pulse({double? size, bool repeat = true}) {
    return Lottie.asset(
      'assets/lottie/pulse.json',
      width: size ?? 40,
      height: size ?? 40,
      repeat: repeat,
      delegates: LottieDelegates(
        values: [
          ValueDelegate.color(
            const ['Shape 1', 'Shape 2'],
            value: EnhancedAppTheme.accentColor,
          ),
        ],
      ),
    );
  }

  // Sparkle animation for highlights
  static Widget sparkle({double? size, bool repeat = true}) {
    return Lottie.asset(
      'assets/lottie/sparkle.json',
      width: size ?? 60,
      height: size ?? 60,
      repeat: repeat,
      delegates: LottieDelegates(
        values: [
          ValueDelegate.color(
            const ['Shape 1', 'Shape 2', 'Shape 3'],
            value: Colors.white,
          ),
        ],
      ),
    );
  }

  // Money animation for financial transactions
  static Widget money({double? size, bool repeat = false}) {
    return Lottie.asset(
      'assets/lottie/money.json',
      width: size ?? 80,
      height: size ?? 80,
      repeat: repeat,
      delegates: LottieDelegates(
        values: [
          ValueDelegate.color(
            const ['Shape 1', 'Shape 2'],
            value: Colors.green,
          ),
        ],
      ),
    );
  }

  // Package animation for deliveries
  static Widget package({double? size, bool repeat = false}) {
    return Lottie.asset(
      'assets/lottie/package.json',
      width: size ?? 80,
      height: size ?? 80,
      repeat: repeat,
      delegates: LottieDelegates(
        values: [
          ValueDelegate.color(
            const ['Shape 1', 'Shape 2'],
            value: EnhancedAppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  // Medical cross animation
  static Widget medicalCross({double? size, bool repeat = false}) {
    return Lottie.asset(
      'assets/lottie/medical_cross.json',
      width: size ?? 60,
      height: size ?? 60,
      repeat: repeat,
      delegates: LottieDelegates(
        values: [
          ValueDelegate.color(
            const ['Shape 1', 'Shape 2'],
            value: Colors.red,
          ),
        ],
      ),
    );
  }

  // Location pin animation
  static Widget locationPin({double? size, bool repeat = false}) {
    return Lottie.asset(
      'assets/lottie/location_pin.json',
      width: size ?? 50,
      height: size ?? 50,
      repeat: repeat,
      delegates: LottieDelegates(
        values: [
          ValueDelegate.color(
            const ['Shape 1', 'Shape 2'],
            value: EnhancedAppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  // Clock animation for time tracking
  static Widget clock({double? size, bool repeat = true}) {
    return Lottie.asset(
      'assets/lottie/clock.json',
      width: size ?? 60,
      height: size ?? 60,
      repeat: repeat,
      delegates: LottieDelegates(
        values: [
          ValueDelegate.color(
            const ['Shape 1', 'Shape 2'],
            value: EnhancedAppTheme.textSecondary,
          ),
        ],
      ),
    );
  }
}

class AnimatedLottieWrapper extends StatefulWidget {
  final Widget child;
  final String lottieAsset;
  final double? size;
  final bool repeat;
  final Duration duration;
  final VoidCallback? onComplete;

  const AnimatedLottieWrapper({
    super.key,
    required this.child,
    required this.lottieAsset,
    this.size,
    this.repeat = false,
    this.duration = const Duration(milliseconds: 1500),
    this.onComplete,
  });

  @override
  State<AnimatedLottieWrapper> createState() => _AnimatedLottieWrapperState();
}

class _AnimatedLottieWrapperState extends State<AnimatedLottieWrapper>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.8, curve: Curves.elasticOut),
    ));

    _controller.forward();
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
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: widget.child,
          ),
        );
      },
    );
  }
}

class LottieButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final String lottieAsset;
  final double? lottieSize;
  final bool showLottieOnHover;
  final Duration animationDuration;

  const LottieButton({
    super.key,
    required this.child,
    required this.onPressed,
    required this.lottieAsset,
    this.lottieSize,
    this.showLottieOnHover = true,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<LottieButton> createState() => _LottieButtonState();
}

class _LottieButtonState extends State<LottieButton>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
        if (widget.showLottieOnHover) {
          _controller.forward();
        }
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
        if (widget.showLottieOnHover) {
          _controller.reverse();
        }
      },
      child: GestureDetector(
        onTap: () {
          widget.onPressed();
          if (!widget.showLottieOnHover) {
            _controller.forward().then((_) {
              _controller.reverse();
            });
          }
        },
        child: Stack(
          children: [
            widget.child,
            if (_isHovered || !widget.showLottieOnHover)
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _animation.value,
                    child: Lottie.asset(
                      widget.lottieAsset,
                      width: widget.lottieSize ?? 40,
                      height: widget.lottieSize ?? 40,
                      repeat: false,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

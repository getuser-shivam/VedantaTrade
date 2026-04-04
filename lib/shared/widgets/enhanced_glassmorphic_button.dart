import 'package:flutter/material.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';

/// Enhanced Glassmorphic Button with smooth animations and micro-interactions
class EnhancedGlassmorphicButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;
  final bool withHapticFeedback;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;

  const EnhancedGlassmorphicButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.padding,
    this.isLoading = false,
    this.withHapticFeedback = true,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.gradient,
  }) : super(key: key);

  @override
  State<EnhancedGlassmorphicButton> createState() => _EnhancedGlassmorphicButtonState();
}

class _EnhancedGlassmorphicButtonState extends State<EnhancedGlassmorphicButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _scaleController.forward();
    if (widget.withHapticFeedback) {
      _triggerHapticFeedback();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  void _triggerHapticFeedback() {
    // HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return GestureDetector(
      onTapDown: isDisabled ? null : _handleTapDown,
      onTapUp: isDisabled ? null : _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: isDisabled ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.width,
              height: widget.height ?? 48,
              padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: widget.gradient ?? (widget.backgroundColor != null
                    ? LinearGradient(
                        colors: [widget.backgroundColor!, widget.backgroundColor!],
                      )
                    : AppTheme.primaryGradient),
                borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                border: widget.border ??
                    Border.all(
                      color: AppTheme.glassBorderLight,
                      width: 1,
                    ),
                boxShadow: widget.boxShadow ?? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Shimmer effect
                  if (!isDisabled)
                    AnimatedBuilder(
                      animation: _shimmerAnimation,
                      builder: (context, child) {
                        return ClipRRect(
                          borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment(-1.0 + _shimmerAnimation.value, 0),
                                end: Alignment(1.0 + _shimmerAnimation.value, 0),
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withOpacity(0.3),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  // Button content
                  Center(
                    child: widget.isLoading
                        ? _buildLoadingIndicator()
                        : _buildButtonContent(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          widget.textColor ?? Colors.white,
        ),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.icon!,
          const SizedBox(width: 8),
          Text(
            widget.text,
            style: TextStyle(
              color: widget.textColor ?? Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      );
    }

    return Text(
      widget.text,
      style: TextStyle(
        color: widget.textColor ?? Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}

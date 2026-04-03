import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';

class GlassmorphicBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? gradientColors;

  const GlassmorphicBackground({
    Key? key,
    required this.child,
    this.gradientColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgDark,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors ?? [
            AppTheme.bgDark,
            AppTheme.surfaceDark,
            AppTheme.bgDark,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Decorative Blurred Circles
          Positioned(
            top: -100,
            right: -100,
            child: _BlurredCircle(
              color: AppTheme.primary.withOpacity(0.15),
              size: 300,
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: _BlurredCircle(
              color: AppTheme.secondary.withOpacity(0.1),
              size: 250,
            ),
          ),
          Positioned(
            top: 200,
            left: -100,
            child: _BlurredCircle(
              color: AppTheme.accent.withOpacity(0.05),
              size: 200,
            ),
          ),
          
          // Content
          SafeArea(child: child),
        ],
      ),
    );
  }
}

class _BlurredCircle extends StatelessWidget {
  final Color color;
  final double size;

  const _BlurredCircle({
    Key? key,
    required this.color,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 100,
              spreadRadius: 50,
            ),
          ],
        ),
      ),
    );
  }
}

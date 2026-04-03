import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/premium_glassmorphic_theme.dart';

class EnhancedLoadingStates extends StatelessWidget {
  final LoadingStateType type;
  final String? message;
  final double? progress;
  final VoidCallback? onCancel;
  final Widget? customWidget;

  const EnhancedLoadingStates({
    Key? key,
    required this.type,
    this.message,
    this.progress,
    this.onCancel,
    this.customWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case LoadingStateType.skeleton:
        return _buildSkeletonLoading();
      case LoadingStateType.progress:
        return _buildProgressLoading();
      case LoadingStateType.pulse:
        return _buildPulseLoading();
      case LoadingStateType.shimmer:
        return _buildShimmerLoading();
      case LoadingStateType.custom:
        return _buildCustomLoading();
      default:
        return _buildDefaultLoading();
    }
  }

  Widget _buildDefaultLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Loading Circle
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  PremiumGlassmorphicTheme.indigo600,
                  PremiumGlassmorphicTheme.indigo400,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Outer Ring
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: PremiumGlassmorphicTheme.indigo500.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                ),
                
                // Inner Circle
                Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: PremiumGlassmorphicTheme.slate800,
                    ),
                    child: const CircularProgressIndicator(
                      color: PremiumGlassmorphicTheme.indigo500,
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          if (message != null) ...[
            const SizedBox(height: PremiumGlassmorphicTheme.spacingLg),
            
            // Loading Message
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                message!,
                key: ValueKey(message),
                style: const TextStyle(
                  color: PremiumGlassmorphicTheme.textSecondary,
                  fontSize: PremiumGlassmorphicTheme.fontSizeMd,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          
          if (onCancel != null) ...[
            const SizedBox(height: PremiumGlassmorphicTheme.spacingLg),
            
            // Cancel Button
            PremiumGlassmorphicTheme.glassButton(
              onPressed: onCancel,
              child: const Text('Cancel'),
              height: 40,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSkeletonLoading() {
    return Column(
      children: [
        // Skeleton Header
        _buildSkeletonItem(
          height: 60,
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: PremiumGlassmorphicTheme.spacingMd),
        ),
        
        // Skeleton Items
        ...List.generate(5, (index) => _buildSkeletonItem(
          height: 80,
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: PremiumGlassmorphicTheme.spacingSm),
        )),
      ],
    );
  }

  Widget _buildSkeletonItem({
    required double height,
    required double width,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      margin: margin,
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: PremiumGlassmorphicTheme.surfaceLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(PremiumGlassmorphicTheme.radiusMd),
      ),
      child: _buildShimmerEffect(),
    );
  }

  Widget _buildShimmerEffect() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: -1.0, end: 2.0),
      duration: const Duration(seconds: 1),
      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(value - 1, 0),
              end: Alignment(value, 0),
              colors: [
                Colors.transparent,
                Colors.white.withOpacity(0.1),
                Colors.transparent,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Progress Circle
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              children: [
                // Background Circle
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: PremiumGlassmorphicTheme.surfaceLight.withOpacity(0.3),
                  ),
                ),
                
                // Progress Circle
                Center(
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: progress ?? 0.0,
                      backgroundColor: PremiumGlassmorphicTheme.surfaceDark.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        PremiumGlassmorphicTheme.indigo500,
                      ),
                      strokeWidth: 8,
                    ),
                  ),
                ),
                
                // Progress Text
                Center(
                  child: Text(
                    '${((progress ?? 0.0) * 100).toInt()}%',
                    style: const TextStyle(
                      color: PremiumGlassmorphicTheme.textPrimary,
                      fontSize: PremiumGlassmorphicTheme.fontSizeLg,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          if (message != null) ...[
            const SizedBox(height: PremiumGlassmorphicTheme.spacingLg),
            
            // Progress Message
            Text(
              message!,
              style: const TextStyle(
                color: PremiumGlassmorphicTheme.textSecondary,
                fontSize: PremiumGlassmorphicTheme.fontSizeMd,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPulseLoading() {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.8, end: 1.2),
        duration: const Duration(milliseconds: 1000),
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    PremiumGlassmorphicTheme.indigo600,
                    PremiumGlassmorphicTheme.indigo400,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: PremiumGlassmorphicTheme.indigo500.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.sync,
                color: PremiumGlassmorphicTheme.textPrimary,
                size: 40,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Column(
      children: [
        // Shimmer Cards
        ...List.generate(3, (index) => Padding(
          padding: const EdgeInsets.only(bottom: PremiumGlassmorphicTheme.spacingMd),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: PremiumGlassmorphicTheme.surfaceLight.withOpacity(0.3),
              borderRadius: BorderRadius.circular(PremiumGlassmorphicTheme.radiusLg),
            ),
            child: _buildShimmerEffect(),
          ),
        )),
      ],
    );
  }

  Widget _buildCustomLoading() {
    return customWidget ?? _buildDefaultLoading();
  }
}

enum LoadingStateType {
  default,
  skeleton,
  progress,
  pulse,
  shimmer,
  custom,
}

class EnhancedLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final LoadingStateType loadingType;
  final String? loadingMessage;
  final double? progress;
  final VoidCallback? onCancel;
  final Widget? customLoadingWidget;

  const EnhancedLoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
    this.loadingType = LoadingStateType.default,
    this.loadingMessage,
    this.progress,
    this.onCancel,
    this.customLoadingWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        
        // Loading Overlay
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: PremiumGlassmorphicTheme.slate900.withOpacity(0.8),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: EnhancedLoadingStates(
                  type: loadingType,
                  message: loadingMessage,
                  progress: progress,
                  onCancel: onCancel,
                  customWidget: customLoadingWidget,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class EnhancedLoadingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool isLoading;
  final LoadingStateType loadingType;
  final String? loadingText;
  final double? width;
  final double? height;
  final Color? color;
  final Color? disabledColor;
  final BorderRadius? borderRadius;

  const EnhancedLoadingButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.isLoading = false,
    this.loadingType = LoadingStateType.default,
    this.loadingText,
    this.width,
    this.height,
    this.color,
    this.disabledColor,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<EnhancedLoadingButton> createState() => _EnhancedLoadingButtonState();
}

class _EnhancedLoadingButtonState extends State<EnhancedLoadingButton>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.7,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(EnhancedLoadingButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isLoading ? _scaleAnimation.value : 1.0,
          child: GestureDetector(
            onTap: widget.isLoading ? null : widget.onPressed,
            child: Container(
              width: widget.width,
              height: widget.height ?? 48,
              decoration: BoxDecoration(
                color: widget.isLoading
                    ? (widget.disabledColor ?? PremiumGlassmorphicTheme.textTertiary)
                    : (widget.color ?? PremiumGlassmorphicTheme.indigo500),
                borderRadius: widget.borderRadius ?? BorderRadius.circular(PremiumGlassmorphicTheme.radiusMd),
              ),
              child: Center(
                child: widget.isLoading
                    ? _buildLoadingContent()
                    : FadeTransition(
                        opacity: _fadeAnimation,
                        child: widget.child,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingContent() {
    switch (widget.loadingType) {
      case LoadingStateType.progress:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                color: PremiumGlassmorphicTheme.textPrimary,
                strokeWidth: 2,
              ),
            ),
            if (widget.loadingText != null) ...[
              const SizedBox(width: PremiumGlassmorphicTheme.spacingSm),
              Text(
                widget.loadingText!,
                style: const TextStyle(
                  color: PremiumGlassmorphicTheme.textPrimary,
                  fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        );
      case LoadingStateType.pulse:
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.8, end: 1.2),
          duration: const Duration(milliseconds: 800),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Icon(
                Icons.sync,
                color: PremiumGlassmorphicTheme.textPrimary,
                size: 20,
              ),
            );
          },
        );
      default:
        return SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            color: PremiumGlassmorphicTheme.textPrimary,
            strokeWidth: 2,
          ),
        );
    }
  }
}

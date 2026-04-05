import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Authentication Button
/// Custom button with loading states and animations
class AuthButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;
  final Color? backgroundColor;
  final Color? textColor;
  final double? height;
  final double? width;
  final double borderRadius;
  final EdgeInsets? padding;
  final Widget? icon;
  final bool showShadow;
  final bool isOutlined;
  final Animation<double>? animation;

  const AuthButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.backgroundColor,
    this.textColor,
    this.height = 48.0,
    this.width,
    this.borderRadius = 8.0,
    this.padding,
    this.icon,
    this.showShadow = true,
    this.isOutlined = false,
    this.animation,
  }) : super(key: key);

  @override
  State<AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<AuthButton> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

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
    
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.7,
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

  void _handleTapDown(TapDownDetails details) {
    if (widget.isEnabled && !widget.isLoading) {
      _animationController.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTap() {
    if (widget.isEnabled && !widget.isLoading) {
      HapticFeedback.mediumImpact();
      widget.onPressed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final buttonColor = widget.backgroundColor ?? theme.primaryColor;
    final textColor = widget.textColor ?? Colors.white;
    
    final buttonStyle = widget.isOutlined
        ? OutlinedButton.styleFrom(
            primaryColor: buttonColor,
            side: BorderSide(color: buttonColor),
            padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
          )
        : ElevatedButton.styleFrom(
            primaryColor: buttonColor,
            onPrimary: textColor,
            padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            elevation: widget.showShadow ? 4 : 0,
          );

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: SizedBox(
              width: widget.width,
              height: widget.height,
              child: widget.isOutlined
                  ? OutlinedButton(
                      onPressed: widget.isEnabled && !widget.isLoading ? _handleTap : null,
                      style: buttonStyle,
                      child: _buildButtonContent(theme, textColor),
                    )
                  : ElevatedButton(
                      onPressed: widget.isEnabled && !widget.isLoading ? _handleTap : null,
                      style: buttonStyle,
                      child: _buildButtonContent(theme, textColor),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildButtonContent(ThemeData theme, Color textColor) {
    if (widget.isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Please wait...',
            style: theme.textTheme.labelLarge?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          widget.icon!,
          const SizedBox(width: 8),
        ],
        Text(
          widget.text,
          style: theme.textTheme.labelLarge?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Social Auth Button
/// Button for OAuth authentication
class SocialAuthButton extends StatefulWidget {
  final OAuthProvider provider;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;
  final double? height;
  final double? width;
  final String? customText;

  const SocialAuthButton({
    Key? key,
    required this.provider,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.height = 48.0,
    this.width,
    this.customText,
  }) : super(key: key);

  @override
  State<SocialAuthButton> createState() => _SocialAuthButtonState();
}

class _SocialAuthButtonState extends State<SocialAuthButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.isEnabled && !widget.isLoading ? widget.onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            color: _getButtonColor(theme),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: _getBorderColor(theme),
              width: 1.0,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8.0,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: _buildButtonContent(),
        ),
      ),
    );
  }

  Color _getButtonColor(ThemeData theme) {
    switch (widget.provider) {
      case OAuthProvider.google:
        return Colors.white;
      case OAuthProvider.facebook:
        return const Color(0xFF1877F2); // Facebook Blue
      case OAuthProvider.apple:
        return Colors.black;
      case OAuthProvider.microsoft:
        return const Color(0xFF00A4EF); // Microsoft Blue
      default:
        return theme.cardColor;
    }
  }

  Color _getBorderColor(ThemeData theme) {
    switch (widget.provider) {
      case OAuthProvider.google:
        return Colors.grey.shade300;
      case OAuthProvider.facebook:
        return const Color(0xFF1877F2);
      case OAuthProvider.apple:
        return Colors.grey.shade300;
      case OAuthProvider.microsoft:
        return const Color(0xFF00A4EF);
      default:
        return theme.dividerColor;
    }
  }

  Widget _buildButtonContent() {
    if (widget.isLoading) {
      return Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(_getLoadingColor()),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildProviderIcon(),
        const SizedBox(width: 12),
        Text(
          widget.customText ?? 'Continue with ${_getProviderName()}',
          style: TextStyle(
            color: _getTextColor(),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildProviderIcon() {
    switch (widget.provider) {
      case OAuthProvider.google:
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.white,
          ),
          child: Center(
            child: Text(
              'G',
              style: TextStyle(
                color: const Color(0xFF4285F4), // Google Blue
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      case OAuthProvider.facebook:
        return Icon(Icons.facebook, color: Colors.white, size: 24);
      case OAuthProvider.apple:
        return Icon(Icons.apple, color: Colors.white, size: 24);
      case OAuthProvider.microsoft:
        return Icon(Icons.windows, color: Colors.white, size: 24);
      default:
        return Icon(Icons.login, color: Colors.white, size: 24);
    }
  }

  String _getProviderName() {
    switch (widget.provider) {
      case OAuthProvider.google:
        return 'Google';
      case OAuthProvider.facebook:
        return 'Facebook';
      case OAuthProvider.apple:
        return 'Apple';
      case OAuthProvider.microsoft:
        return 'Microsoft';
      default:
        return 'Account';
    }
  }

  Color _getTextColor() {
    switch (widget.provider) {
      case OAuthProvider.google:
        return const Color(0xFF4285F4);
      case OAuthProvider.facebook:
      case OAuthProvider.apple:
      case OAuthProvider.microsoft:
        return Colors.white;
      default:
        return Colors.black;
    }
  }

  Color _getLoadingColor() {
    switch (widget.provider) {
      case OAuthProvider.google:
        return const Color(0xFF4285F4);
      case OAuthProvider.facebook:
      case OAuthProvider.apple:
      case OAuthProvider.microsoft:
        return Colors.white;
      default:
        return Colors.black;
    }
  }
}

/// Biometric Auth Button
/// Button for biometric authentication
class BiometricAuthButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;
  final String? text;
  final BiometricType biometricType;

  const BiometricAuthButton({
    Key? key,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.text,
    required this.biometricType,
  }) : super(key: key);

  @override
  State<BiometricAuthButton> createState() => _BiometricAuthButtonState();
}

class _BiometricAuthButtonState extends State<BiometricAuthButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTap: widget.isEnabled && !widget.isLoading ? widget.onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.primaryColor,
              theme.primaryColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.3),
              blurRadius: _isPressed ? 8 : 4,
              offset: Offset(0, _isPressed ? 2 : 1),
            ),
          ],
        ),
        child: _buildButtonContent(),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (widget.isLoading) {
      return Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildBiometricIcon(),
        const SizedBox(width: 12),
        Text(
          widget.text ?? 'Login with ${_getBiometricName()}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBiometricIcon() {
    switch (widget.biometricType) {
      case BiometricType.fingerprint:
        return const Icon(Icons.fingerprint, color: Colors.white, size: 24);
      case BiometricType.face:
        return const Icon(Icons.face, color: Colors.white, size: 24);
      case BiometricType.iris:
        return const Icon(Icons.visibility, color: Colors.white, size: 24);
      default:
        return const Icon(Icons.security, color: Colors.white, size: 24);
    }
  }

  String _getBiometricName() {
    switch (widget.biometricType) {
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.iris:
        return 'Iris Scanner';
      default:
        return 'Biometric';
    }
  }
}

/// Biometric Type
enum BiometricType {
  fingerprint,
  face,
  iris,
  voice,
}

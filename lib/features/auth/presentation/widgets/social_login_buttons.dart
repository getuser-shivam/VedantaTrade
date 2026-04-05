import 'package:flutter/material.dart';

class SocialLoginButtons extends StatelessWidget {
  final VoidCallback? onGoogleSignIn;
  final VoidCallback? onFacebookSignIn;
  final VoidCallback? onAppleSignIn;
  final bool isLoading;
  final bool showLabels;

  const SocialLoginButtons({
    Key? key,
    this.onGoogleSignIn,
    this.onFacebookSignIn,
    this.onAppleSignIn,
    this.isLoading = false,
    this.showLabels = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Google Sign In
        _buildSocialButton(
          context,
          'Google',
          'Sign in with Google',
          Icons.g_mobile_friendly,
          const Color(0xFF4285F4),
          onGoogleSignIn,
        ),
        const SizedBox(height: 12),
        // Facebook Sign In
        _buildSocialButton(
          context,
          'Facebook',
          'Sign in with Facebook',
          Icons.facebook,
          const Color(0xFF1877F2),
          onFacebookSignIn,
        ),
        const SizedBox(height: 12),
        // Apple Sign In
        _buildSocialButton(
          context,
          'Apple',
          'Sign in with Apple',
          Icons.apple,
          const Color(0xFF000000),
          onAppleSignIn,
        ),
      ],
    );
  }

  Widget _buildSocialButton(
    BuildContext context,
    String platform,
    String label,
    IconData icon,
    Color color,
    VoidCallback? onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
        ),
        label: showLabels
            ? Text(
                label,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              )
            : null,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.grey[700],
          side: BorderSide(color: Colors.grey[300]!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

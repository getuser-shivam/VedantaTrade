import 'package:flutter/material.dart';
import '../../domain/entities/auth_user_entity.dart';

/// OAuth Login Button
class OAuthButton extends StatelessWidget {
  final OAuthProvider provider;
  final VoidCallback onPressed;
  final double? width;
  final double? height;

  const OAuthButton({
    Key? key,
    required this.provider,
    required this.onPressed,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getProviderColor(),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildProviderIcon(),
            const SizedBox(width: 12),
            Text(
              _getProviderLabel(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderIcon() {
    switch (provider) {
      case OAuthProvider.google:
        return Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          child: const Center(
            child: Text(
              'G',
              style: TextStyle(
                color: Color(0xFF4285F4),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      
      case OAuthProvider.facebook:
        return const Icon(
          Icons.facebook,
          color: Colors.white,
          size: 20,
        );
      
      case OAuthProvider.apple:
        return const Icon(
          Icons.apple,
          color: Colors.white,
          size: 20,
        );
      
      case OAuthProvider.microsoft:
        return Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          child: const Center(
            child: Text(
              'M',
              style: TextStyle(
                color: Color(0xFF00A4EF),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      
      case OAuthProvider.twitter:
        return const Icon(
          Icons.alternate_email,
          color: Colors.white,
          size: 20,
        );
      
      case OAuthProvider.linkedin:
        return const Icon(
          Icons.work,
          color: Colors.white,
          size: 20,
        );
      
      case OAuthProvider.github:
        return const Icon(
          Icons.code,
          color: Colors.white,
          size: 20,
        );
    }
  }

  Color _getProviderColor() {
    switch (provider) {
      case OAuthProvider.google:
        return const Color(0xFF4285F4);
      case OAuthProvider.facebook:
        return const Color(0xFF1877F2);
      case OAuthProvider.apple:
        return Colors.black;
      case OAuthProvider.microsoft:
        return const Color(0xFF00A4EF);
      case OAuthProvider.twitter:
        return const Color(0xFF1DA1F2);
      case OAuthProvider.linkedin:
        return const Color(0xFF0077B5);
      case OAuthProvider.github:
        return const Color(0xFF333333);
    }
  }

  String _getProviderLabel() {
    switch (provider) {
      case OAuthProvider.google:
        return 'Google';
      case OAuthProvider.facebook:
        return 'Facebook';
      case OAuthProvider.apple:
        return 'Apple';
      case OAuthProvider.microsoft:
        return 'Microsoft';
      case OAuthProvider.twitter:
        return 'Twitter';
      case OAuthProvider.linkedin:
        return 'LinkedIn';
      case OAuthProvider.github:
        return 'GitHub';
    }
  }
}

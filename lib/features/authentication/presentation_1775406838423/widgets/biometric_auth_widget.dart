import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import '../providers/enhanced_auth_provider.dart';
import '../../../shared/widgets/premium_glassmorphic_theme.dart';

class BiometricAuthWidget extends StatelessWidget {
  final VoidCallback onBiometricLogin;
  final String reason;

  const BiometricAuthWidget({
    Key? key,
    required this.onBiometricLogin,
    this.reason = 'Authenticate to access VedantaTrade',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<EnhancedAuthProvider>(
      builder: (context, authProvider, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withOpacity(0.05),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Biometric icon with animation
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.8, end: 1.0),
                duration: const Duration(seconds: 1),
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: PremiumGlassmorphicTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: PremiumGlassmorphicTheme.primaryColor,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.fingerprint,
                        color: PremiumGlassmorphicTheme.primaryColor,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 20),
              
              // Authentication text
              Text(
                'Biometric Authentication',
                style: TextStyle(
                  color: PremiumGlassmorphicTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Use your fingerprint or face to login instantly',
                style: TextStyle(
                  color: PremiumGlassmorphicTheme.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 20),
              
              // Biometric button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: authProvider.isLoading ? null : onBiometricLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PremiumGlassmorphicTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  icon: authProvider.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.fingerprint),
                  label: Text(
                    authProvider.isLoading 
                        ? 'Authenticating...' 
                        : 'Login with Biometric',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class BiometricSetupWidget extends StatelessWidget {
  final String email;
  final String password;
  final VoidCallback onSuccess;
  final VoidCallback onSkip;

  const BiometricSetupWidget({
    Key? key,
    required this.email,
    required this.password,
    required this.onSuccess,
    required this.onSkip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Setup icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: AppTheme.primaryColor,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.fingerprint,
                  color: AppTheme.primaryColor,
                  size: 40,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Setup text
              Text(
                'Enable Biometric Authentication',
                style: TextStyle(
                  color: AppTheme.textPrimaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              Text(
                'Quickly access your account using your fingerprint or face recognition',
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Enable button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: authProvider.isBiometricLoading 
                      ? null 
                      : () => _handleEnableBiometric(context, authProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: authProvider.isBiometricLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.fingerprint),
                  label: Text(
                    authProvider.isBiometricLoading 
                        ? 'Setting up...' 
                        : 'Enable Biometric',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Skip option
              TextButton(
                onPressed: onSkip,
                child: Text(
                  'Skip for now',
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleEnableBiometric(BuildContext context, AuthProvider authProvider) async {
    try {
// final success = await authProvider.enableBiometric(email, password); // TODO: Move to environment variables
      if (success) {
        onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometric authentication enabled successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to enable biometric: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class SecuritySettingsWidget extends StatelessWidget {
  const SecuritySettingsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section title
              Text(
                'Security Settings',
                style: TextStyle(
                  color: AppTheme.textPrimaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Biometric settings
              _buildSecuritySection(
                title: 'Biometric Authentication',
                icon: Icons.fingerprint,
                children: [
                  SwitchListTile(
                    title: Text(
                      'Enable Biometric Login',
                      style: TextStyle(
                        color: AppTheme.textPrimaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      authProvider.isBiometricAvailable
                          ? 'Use fingerprint or face recognition to login'
                          : 'Biometric not available on this device',
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 14,
                      ),
                    ),
                    value: authProvider.isBiometricEnabled,
                    onChanged: authProvider.isBiometricAvailable
                        ? (value) async {
                            if (value == true) {
                              // Show biometric setup dialog
                              _showBiometricSetupDialog(context, authProvider);
                            } else {
                              await authProvider.disableBiometric();
                            }
                          }
                        : null,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Password settings
              _buildSecuritySection(
                title: 'Password Settings',
                icon: Icons.lock,
                children: [
                  ListTile(
                    title: Text(
                      'Change Password',
                      style: TextStyle(
                        color: AppTheme.textPrimaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      'Update your account password',
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 14,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showChangePasswordDialog(context, authProvider),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Two-factor authentication
              _buildSecuritySection(
                title: 'Two-Factor Authentication',
                icon: Icons.security,
                children: [
                  SwitchListTile(
                    title: Text(
                      'Enable 2FA',
                      style: TextStyle(
                        color: AppTheme.textPrimaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      'Add an extra layer of security',
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 14,
                      ),
                    ),
                    value: false, 
                    onChanged: (value) {
                      
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSecuritySection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.glassColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.glassBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.textPrimaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          // Section content
          ...children,
        ],
      ),
    );
  }

  void _showBiometricSetupDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Biometric Setup'),
        content: const Text(
          'To enable biometric authentication, you\'ll need to:\n\n'
          '1. Enter your password\n'
          '2. Authenticate with your biometric\n'
          '3. Confirm setup',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to biometric setup screen
              
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, AuthProvider authProvider) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text == confirmPasswordController.text) {
                final success = await authProvider.changePassword(
                  currentPassword: currentPasswordController.text,
                  newPassword: newPasswordController.text,
                );
                
                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password changed successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Passwords do not match'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }
}

class TweenAnimationBuilder<T> extends StatefulWidget {
  final Tween<T> tween;
  final Duration duration;
  final Widget Function(BuildContext context, T value, Widget? child) builder;
  final Widget? child;

  const TweenAnimationBuilder({
    Key? key,
    required this.tween,
    required this.duration,
    required this.builder,
    this.child,
  }) : super(key: key);

  @override
  State<TweenAnimationBuilder<T>> createState() => _TweenAnimationBuilderState<T>();
}

class _TweenAnimationBuilderState<T> extends State<TweenAnimationBuilder<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<T> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = widget.tween.animate(_controller);
    _controller.repeat(reverse: true);
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
      builder: (context, child) => widget.builder(context, _animation.value, child),
      child: widget.child,
    );
  }
}

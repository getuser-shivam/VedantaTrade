import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../shared/widgets/premium_glassmorphic_theme.dart';
import '../providers/enhanced_auth_provider.dart';
import '../widgets/biometric_auth_widget.dart';
import '../widgets/security_status_widget.dart';
import '../widgets/two_factor_widget.dart';

class EnhancedAuthenticationScreen extends StatefulWidget {
  const EnhancedAuthenticationScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedAuthenticationScreen> createState() => _EnhancedAuthenticationScreenState();
}

class _EnhancedAuthenticationScreenState extends State<EnhancedAuthenticationScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rememberMeController = ValueNotifier<bool>(false);
  final _obscurePasswordController = ValueNotifier<bool>(true);
  final _isBiometricAvailable = ValueNotifier<bool>(false);
  final _showTwoFactor = ValueNotifier<bool>(false);
  final _twoFactorController = TextEditingController();
  final _securityScore = ValueNotifier<int>(0);

  late AnimationController _backgroundController;
  late AnimationController _formController;
  late AnimationController _buttonController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _formAnimation;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkBiometricAvailability();
    _updateSecurityScore();
  }

  void _initializeAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _formController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_backgroundController);

    _formAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOutCubic,
    ));

    _buttonAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeOutCubic,
    ));

    _formController.forward();
  }

  Future<void> _checkBiometricAvailability() async {
    final authProvider = Provider.of<EnhancedAuthProvider>(context, listen: false);
    _isBiometricAvailable.value = await authProvider.authService.isBiometricAvailable();
  }

  Future<void> _updateSecurityScore() async {
    final authProvider = Provider.of<EnhancedAuthProvider>(context, listen: false);
    final score = await authProvider.authService.getSecurityScore();
    _securityScore.value = score;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _rememberMeController.dispose();
    _obscurePasswordController.dispose();
    _isBiometricAvailable.dispose();
    _showTwoFactor.dispose();
    _twoFactorController.dispose();
    _securityScore.dispose();
    _backgroundController.dispose();
    _formController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              PremiumGlassmorphicTheme.primaryColor.withOpacity(0.1),
              PremiumGlassmorphicTheme.secondaryColor.withOpacity(0.1),
              PremiumGlassmorphicTheme.accentColor.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  _buildBackgroundElements(),
                  _buildMainContent(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundElements() {
    return Positioned.fill(
      child: CustomPaint(
        painter: BackgroundPainter(_backgroundAnimation.value),
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 40),
          _buildHeader(),
          const SizedBox(height: 40),
          _buildSecurityStatus(),
          const SizedBox(height: 30),
          _buildAuthenticationForm(),
          const SizedBox(height: 30),
          _buildBiometricSection(),
          const SizedBox(height: 30),
          _buildQuickLoginSection(),
          const SizedBox(height: 30),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _formAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.3),
          end: Offset.zero,
        ).animate(_formAnimation),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    PremiumGlassmorphicTheme.primaryColor,
                    PremiumGlassmorphicTheme.secondaryColor,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: PremiumGlassmorphicTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.security,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'VedantaTrade',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: PremiumGlassmorphicTheme.textPrimary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Secure Pharmaceutical Distribution',
              style: TextStyle(
                fontSize: 16,
                color: PremiumGlassmorphicTheme.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityStatus() {
    return FadeTransition(
      opacity: _formAnimation,
      child: ValueListenableBuilder<int>(
        valueListenable: _securityScore,
        builder: (context, score, child) {
          return SecurityStatusWidget(
            securityScore: score,
            recommendations: _getSecurityRecommendations(score),
          );
        },
      ),
    );
  }

  List<String> _getSecurityRecommendations(int score) {
    List<String> recommendations = [];
    
    if (score < 50) {
      recommendations.add('Enable two-factor authentication for enhanced security');
      recommendations.add('Set up biometric authentication for faster login');
    }
    
    if (score < 70) {
      recommendations.add('Trust this device for seamless access');
    }
    
    if (score < 90) {
      recommendations.add('Use a strong password with special characters');
    }
    
    return recommendations;
  }

  Widget _buildAuthenticationForm() {
    return FadeTransition(
      opacity: _formAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(_formAnimation),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.1),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secure Login',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: PremiumGlassmorphicTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                _buildEmailField(),
                const SizedBox(height: 16),
                _buildPasswordField(),
                const SizedBox(height: 16),
                _buildRememberMeField(),
                const SizedBox(height: 24),
                ValueListenableBuilder<bool>(
                  valueListenable: _showTwoFactor,
                  builder: (context, show2FA, child) {
                    return Column(
                      children: [
                        if (show2FA) ...[
                          _buildTwoFactorField(),
                          const SizedBox(height: 16),
                        ],
                        _buildLoginButton(),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email Address',
        hintText: 'Enter your email',
        prefixIcon: Icon(
          Icons.email_outlined,
          color: PremiumGlassmorphicTheme.primaryColor,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: PremiumGlassmorphicTheme.primaryColor,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        labelStyle: TextStyle(
          color: PremiumGlassmorphicTheme.textSecondary,
        ),
        hintStyle: TextStyle(
          color: PremiumGlassmorphicTheme.textSecondary.withOpacity(0.6),
        ),
      ),
      style: TextStyle(
        color: PremiumGlassmorphicTheme.textPrimary,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email address';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return ValueListenableBuilder<bool>(
      valueListenable: _obscurePasswordController,
      builder: (context, obscure, child) {
        return TextFormField(
          controller: _passwordController,
          obscureText: obscure,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Enter your password',
            prefixIcon: Icon(
              Icons.lock_outline,
              color: PremiumGlassmorphicTheme.primaryColor,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off : Icons.visibility,
                color: PremiumGlassmorphicTheme.textSecondary,
              ),
              onPressed: () {
                _obscurePasswordController.value = !obscure;
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: PremiumGlassmorphicTheme.primaryColor,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            labelStyle: TextStyle(
              color: PremiumGlassmorphicTheme.textSecondary,
            ),
            hintStyle: TextStyle(
              color: PremiumGlassmorphicTheme.textSecondary.withOpacity(0.6),
            ),
          ),
          style: TextStyle(
            color: PremiumGlassmorphicTheme.textPrimary,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            if (value.length < 8) {
              return 'Password must be at least 8 characters long';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildRememberMeField() {
    return ValueListenableBuilder<bool>(
      valueListenable: _rememberMeController,
      builder: (context, rememberMe, child) {
        return Row(
          children: [
            Checkbox(
              value: rememberMe,
              onChanged: (value) {
                _rememberMeController.value = value ?? false;
              },
              activeColor: PremiumGlassmorphicTheme.primaryColor,
              checkColor: Colors.white,
            ),
            Text(
              'Remember me on this device',
              style: TextStyle(
                color: PremiumGlassmorphicTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTwoFactorField() {
    return TwoFactorWidget(
      controller: _twoFactorController,
      onCodeVerified: (verified) {
        if (verified) {
          _proceedWithLogin();
        }
      },
    );
  }

  Widget _buildLoginButton() {
    return Consumer<EnhancedAuthProvider>(
      builder: (context, authProvider, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: authProvider.isLoading
                  ? [
                      Colors.grey.shade400,
                      Colors.grey.shade500,
                    ]
                  : [
                      PremiumGlassmorphicTheme.primaryColor,
                      PremiumGlassmorphicTheme.secondaryColor,
                    ],
            ),
            boxShadow: [
              BoxShadow(
                color: PremiumGlassmorphicTheme.primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: authProvider.isLoading ? null : _handleLogin,
              child: Center(
                child: authProvider.isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Authenticating...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'Secure Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBiometricSection() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isBiometricAvailable,
      builder: (context, available, child) {
        if (!available) return const SizedBox.shrink();
        
        return FadeTransition(
          opacity: _formAnimation,
          child: BiometricAuthWidget(
            onBiometricLogin: _handleBiometricLogin,
          ),
        );
      },
    );
  }

  Widget _buildQuickLoginSection() {
    return FadeTransition(
      opacity: _formAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.05),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Login (Demo)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: PremiumGlassmorphicTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildQuickLoginButton('Admin', Icons.admin_panel_settings),
                _buildQuickLoginButton('Doctor', Icons.local_hospital),
                _buildQuickLoginButton('MR', Icons.directions_walk),
                _buildQuickLoginButton('Stockist', Icons.inventory),
                _buildQuickLoginButton('Retailer', Icons.store),
                _buildQuickLoginButton('Accountant', Icons.account_balance),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickLoginButton(String role, IconData icon) {
    return Consumer<EnhancedAuthProvider>(
      builder: (context, authProvider, child) {
        return GestureDetector(
          onTap: authProvider.isLoading ? null : () => _handleQuickLogin(role),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white.withOpacity(0.1),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: PremiumGlassmorphicTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  role,
                  style: TextStyle(
                    color: PremiumGlassmorphicTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return FadeTransition(
      opacity: _formAnimation,
      child: Column(
        children: [
          _buildFooterLink('Forgot Password?', _handleForgotPassword),
          const SizedBox(height: 12),
          _buildFooterLink('Create Account', _handleCreateAccount),
          const SizedBox(height: 12),
          _buildFooterLink('Security Settings', _handleSecuritySettings),
          const SizedBox(height: 20),
          Text(
            'Version 3.3.0 • Secure Connection',
            style: TextStyle(
              color: PremiumGlassmorphicTheme.textSecondary.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          color: PremiumGlassmorphicTheme.primaryColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<EnhancedAuthProvider>(context, listen: false);
      
      try {
        await authProvider.login(
          _emailController.text.trim(),
          _passwordController.text,
          _rememberMeController.value,
        );

        // Check if 2FA is required
        if (authProvider.twoFactorEnabled) {
          _showTwoFactor.value = true;
        } else {
          _proceedWithLogin();
        }
      } catch (e) {
        _showErrorSnackBar(e.toString());
      }
    }
  }

  void _proceedWithLogin() {
    // Navigate to main app
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _handleBiometricLogin() async {
    final authProvider = Provider.of<EnhancedAuthProvider>(context, listen: false);
    
    try {
      await authProvider.biometricLogin();
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  void _handleQuickLogin(String role) async {
    final authProvider = Provider.of<EnhancedAuthProvider>(context, listen: false);
    
    try {
      await authProvider.quickLogin(role);
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  void _handleForgotPassword() {
    Navigator.of(context).pushNamed('/forgot-password');
  }

  void _handleCreateAccount() {
    Navigator.of(context).pushNamed('/register');
  }

  void _handleSecuritySettings() {
    Navigator.of(context).pushNamed('/security-settings');
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final double animation;

  BackgroundPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Create animated circles
    for (int i = 0; i < 5; i++) {
      final x = (size.width * 0.2 * (i + 1)) + 
               (size.width * 0.1 * sin(animation * 2 * pi + i));
      final y = (size.height * 0.3) + 
               (size.height * 0.1 * cos(animation * 2 * pi + i));
      
      canvas.drawCircle(
        Offset(x, y),
        30 + (10 * sin(animation * 4 * pi + i)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

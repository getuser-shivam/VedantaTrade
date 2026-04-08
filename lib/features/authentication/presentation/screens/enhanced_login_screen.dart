import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/enhanced_authentication_provider.dart';
import '../widgets/enhanced_auth_form_field.dart';
import '../widgets/oauth_button.dart';
import '../widgets/security_badge.dart';
import '../../../shared/widgets/responsive/responsive_layout.dart';
import '../../../shared/widgets/glassmorphic_widgets.dart';
import '../../../shared/theme/app_theme.dart';

/// Enhanced Login Screen with comprehensive security features
class EnhancedLoginScreen extends StatefulWidget {
  const EnhancedLoginScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedLoginScreen> createState() => _EnhancedLoginScreenState();
}

class _EnhancedLoginScreenState extends State<EnhancedLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _mfaController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _showMFA = false;
  String? _mfaToken;
  List<OAuthProvider> _oauthProviders = [];

  @override
  void initState() {
    super.initState();
    _loadOAuthProviders();
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _mfaController.dispose();
    super.dispose();
  }

  Future<void> _loadOAuthProviders() async {
    final provider = context.read<EnhancedAuthenticationProvider>();
    final providers = await provider.getAvailableOAuthProviders();
    if (mounted) {
      setState(() {
        _oauthProviders = providers;
      });
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final provider = context.read<EnhancedAuthenticationProvider>();
    
    if (_showMFA && _mfaToken != null) {
      await provider.verifyMFACode(
        mfaToken: _mfaToken!,
        verificationCode: _mfaController.text.trim(),
      );
    } else {
      await provider.loginUser(
        identifier: _identifierController.text.trim(),
        password: _passwordController.text,
        rememberMe: _rememberMe,
      );
    }

    setState(() => _isLoading = false);
  }

  Future<void> _handleOAuthLogin(OAuthProvider provider) async {
    final authProvider = context.read<EnhancedAuthenticationProvider>();
    await authProvider.loginWithOAuth(provider);
  }

  void _handleForgotPassword() {
    Navigator.of(context).pushNamed('/forgot-password');
  }

  void _handleRegister() {
    Navigator.of(context).pushNamed('/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 60),
            _buildLogo(),
            const SizedBox(height: 32),
            _buildWelcomeText(),
            const SizedBox(height: 32),
            _buildLoginForm(),
            const SizedBox(height: 24),
            _buildActionButtons(),
            const SizedBox(height: 32),
            _buildOAuthSection(),
            const SizedBox(height: 24),
            _buildSecurityInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLogo(),
                const SizedBox(height: 24),
                _buildWelcomeText(),
                const SizedBox(height: 24),
                _buildLoginForm(),
                const SizedBox(height: 20),
                _buildActionButtons(),
                const SizedBox(height: 24),
                _buildOAuthSection(),
                const SizedBox(height: 16),
                _buildSecurityInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Card(
          elevation: 12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLogo(),
                      const SizedBox(height: 24),
                      _buildWelcomeText(),
                      const SizedBox(height: 32),
                      _buildSecurityFeatures(),
                    ],
                  ),
                ),
                const SizedBox(width: 60),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildLoginForm(),
                      const SizedBox(height: 24),
                      _buildActionButtons(),
                      const SizedBox(height: 32),
                      _buildOAuthSection(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primary, AppTheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.medical_services_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'VedantaTrade',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const Text(
          'Pharmaceutical Distribution Platform',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Sign in to access your dashboard',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Consumer<EnhancedAuthenticationProvider>(
      builder: (context, provider, child) {
        return Form(
          key: _formKey,
          child: Column(
            children: [
              if (provider.state.isMfaRequired) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    border: Border.all(color: Colors.orange),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.security, color: Colors.orange),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Two-factor authentication required. Please check your authenticator app.',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _mfaToken = provider.state.mfaToken,
              ],
              
              if (!_showMFA)
                EnhancedAuthFormField(
                  controller: _identifierController,
                  label: 'Email or Phone',
                  prefixIcon: Icons.person_outline,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email or phone number';
                    }
                    return null;
                  },
                ),
              
              if (!_showMFA) const SizedBox(height: 16),
              
              if (!_showMFA)
                EnhancedAuthFormField(
                  controller: _passwordController,
                  label: 'Password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white54,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
              
              if (_showMFA) ...[
                EnhancedAuthFormField(
                  controller: _mfaController,
                  label: 'Verification Code',
                  prefixIcon: Icons.security,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  validator: (value) {
                    if (value == null || value.length != 6) {
                      return 'Please enter 6-digit verification code';
                    }
                    return null;
                  },
                ),
              ],
              
              if (!_showMFA) const SizedBox(height: 16),
              
              if (!_showMFA)
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) => setState(() => _rememberMe = value ?? false),
                      activeColor: AppTheme.primary,
                    ),
                    const Text(
                      'Remember me',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _handleForgotPassword,
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(color: AppTheme.primary),
                      ),
                    ),
                  ],
                ),
              
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(_showMFA ? 'Verify' : 'Sign In'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account?",
          style: TextStyle(color: Colors.white70),
        ),
        TextButton(
          onPressed: _handleRegister,
          child: const Text(
            'Sign Up',
            style: TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOAuthSection() {
    if (_oauthProviders.isEmpty) return const SizedBox.shrink();
    
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: Colors.white24)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                'OR',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            const Expanded(child: Divider(color: Colors.white24)),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _oauthProviders.map((provider) {
            return OAuthButton(
              provider: provider,
              onPressed: () => _handleOAuthLogin(provider),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSecurityInfo() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SecurityBadge(
              icon: Icons.lock,
              label: 'Secure Login',
              color: Colors.green,
            ),
            const SizedBox(width: 16),
            SecurityBadge(
              icon: Icons.security,
              label: 'MFA Protected',
              color: Colors.blue,
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Your connection is encrypted and secure',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Security Features',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildSecurityFeature(
          icon: Icons.verified_user,
          title: 'Multi-Factor Authentication',
          description: 'Extra layer of security with 2FA',
        ),
        const SizedBox(height: 12),
        _buildSecurityFeature(
          icon: Icons.lock_clock,
          title: 'Account Lockout',
          description: 'Automatic protection against brute force',
        ),
        const SizedBox(height: 12),
        _buildSecurityFeature(
          icon: Icons.security,
          title: 'End-to-End Encryption',
          description: 'Your data is always protected',
        ),
      ],
    );
  }

  Widget _buildSecurityFeature({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

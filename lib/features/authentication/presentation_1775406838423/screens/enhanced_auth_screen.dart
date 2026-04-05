import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/premium_glassmorphic_theme.dart';
import '../providers/enhanced_auth_provider.dart';
import '../widgets/enhanced_login_form.dart';
import '../widgets/enhanced_register_form.dart';
import '../widgets/enhanced_password_reset_form.dart';
import '../widgets/security_status_widget.dart';
import '../widgets/biometric_auth_widget.dart';

class EnhancedAuthScreen extends StatefulWidget {
  const EnhancedAuthScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedAuthScreen> createState() => _EnhancedAuthScreenState();
}

class _EnhancedAuthScreenState extends State<EnhancedAuthScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _showSecurityInfo = false;
  bool _enableBiometric = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PremiumGlassmorphicTheme.glassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Header Section
              _buildHeader(),
              
              // Tab Bar
              _buildTabBar(),
              
              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildLoginTab(),
                    _buildRegisterTab(),
                    _buildPasswordResetTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingXl),
      child: Column(
        children: [
          // Logo and Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: PremiumGlassmorphicTheme.indigo600.withOpacity(0.1),
                  border: Border.all(
                    color: PremiumGlassmorphicTheme.indigo500.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.medication,
                  color: PremiumGlassmorphicTheme.indigo500,
                  size: 30,
                ),
              ),
              const SizedBox(width: PremiumGlassmorphicTheme.spacingMd),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'VedantaTrade',
                    style: TextStyle(
                      color: PremiumGlassmorphicTheme.textPrimary,
                      fontSize: PremiumGlassmorphicTheme.fontSize4xl,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.5,
                    ),
                  ),
                  const SizedBox(height: PremiumGlassmorphicTheme.spacingXs),
                  const Text(
                    'Secure Pharmaceutical Distribution',
                    style: TextStyle(
                      color: PremiumGlassmorphicTheme.textSecondary,
                      fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingXl),
          
          // Security Badge
          PremiumGlassmorphicTheme.glassCard(
            padding: const EdgeInsets.symmetric(
              horizontal: PremiumGlassmorphicTheme.spacingMd,
              vertical: PremiumGlassmorphicTheme.spacingSm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.security,
                  color: PremiumGlassmorphicTheme.success,
                  size: 20,
                ),
                const SizedBox(width: PremiumGlassmorphicTheme.spacingSm),
                const Text(
                  'Enterprise-Grade Security',
                  style: TextStyle(
                    color: PremiumGlassmorphicTheme.textPrimary,
                    fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: PremiumGlassmorphicTheme.spacingSm),
                Icon(
                  Icons.verified_user,
                  color: PremiumGlassmorphicTheme.success,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: PremiumGlassmorphicTheme.spacingLg,
      ),
      child: PremiumGlassmorphicTheme.glassTabBar(
        tabs: ['Login', 'Register', 'Reset Password'],
        selectedIndex: _tabController.index,
        onTap: (index) => _tabController.animateTo(index),
      ),
    );
  }

  Widget _buildLoginTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingLg),
      child: Column(
        children: [
          // Quick Login Options
          _buildQuickLoginOptions(),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingXl),
          
          // Login Form
          EnhancedLoginForm(
            onLogin: _handleLogin,
            isLoading: _isLoading,
            errorMessage: _errorMessage,
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingLg),
          
          // Additional Options
          _buildAdditionalLoginOptions(),
        ],
      ),
    );
  }

  Widget _buildRegisterTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingLg),
      child: Column(
        children: [
          // Registration Header
          _buildRegistrationHeader(),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingLg),
          
          // Registration Form
          EnhancedRegisterForm(
            onRegister: _handleRegister,
            isLoading: _isLoading,
            errorMessage: _errorMessage,
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingLg),
          
          // Terms and Conditions
          _buildTermsSection(),
        ],
      ),
    );
  }

  Widget _buildPasswordResetTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingLg),
      child: Column(
        children: [
          // Password Reset Header
          _buildPasswordResetHeader(),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingXl),
          
          // Password Reset Form
          EnhancedPasswordResetForm(
            onReset: _handlePasswordReset,
            isLoading: _isLoading,
            errorMessage: _errorMessage,
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingLg),
          
          // Support Information
          _buildSupportSection(),
        ],
      ),
    );
  }

  Widget _buildQuickLoginOptions() {
    return PremiumGlassmorphicTheme.glassCard(
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Access',
            style: TextStyle(
              color: PremiumGlassmorphicTheme.textPrimary,
              fontSize: PremiumGlassmorphicTheme.fontSizeLg,
              fontWeight: FontWeight.w700,
            ),
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
          
          // Role-based Quick Login
          Wrap(
            spacing: PremiumGlassmorphicTheme.spacingMd,
            runSpacing: PremiumGlassmorphicTheme.spacingMd,
            children: [
              _buildQuickLoginOption(
                'Admin',
                Icons.admin_panel_settings,
                PremiumGlassmorphicTheme.adminColor,
                () => _quickLogin('admin'),
              ),
              _buildQuickLoginOption(
                'MR',
                Icons.directions_walk,
                PremiumGlassmorphicTheme.mrColor,
                () => _quickLogin('mr'),
              ),
              _buildQuickLoginOption(
                'Stockist',
                Icons.inventory,
                PremiumGlassmorphicTheme.stockistColor,
                () => _quickLogin('stockist'),
              ),
              _buildQuickLoginOption(
                'Retailer',
                Icons.store,
                PremiumGlassmorphicTheme.retailerColor,
                () => _quickLogin('retailer'),
              ),
              _buildQuickLoginOption(
                'Doctor',
                Icons.local_hospital,
                PremiumGlassmorphicTheme.doctorColor,
                () => _quickLogin('doctor'),
              ),
              _buildQuickLoginOption(
                'Accountant',
                Icons.account_balance,
                PremiumGlassmorphicTheme.accountantColor,
                () => _quickLogin('accountant'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLoginOption(
    String role,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingMd),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(PremiumGlassmorphicTheme.radiusMd),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: PremiumGlassmorphicTheme.spacingSm),
            Text(
              role,
              style: TextStyle(
                color: color,
                fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationHeader() {
    return PremiumGlassmorphicTheme.glassCard(
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingLg),
      child: Column(
        children: [
          Icon(
            Icons.app_registration,
            color: PremiumGlassmorphicTheme.indigo500,
            size: 48,
          ),
          const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
          const Text(
            'Create Your Account',
            style: TextStyle(
              color: PremiumGlassmorphicTheme.textPrimary,
              fontSize: PremiumGlassmorphicTheme.fontSizeXl,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: PremiumGlassmorphicTheme.spacingSm),
          const Text(
            'Join the secure pharmaceutical distribution network',
            style: TextStyle(
              color: PremiumGlassmorphicTheme.textSecondary,
              fontSize: PremiumGlassmorphicTheme.fontSizeSm,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordResetHeader() {
    return PremiumGlassmorphicTheme.glassCard(
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingLg),
      child: Column(
        children: [
          Icon(
            Icons.lock_reset,
            color: PremiumGlassmorphicTheme.indigo500,
            size: 48,
          ),
          const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
          const Text(
            'Reset Your Password',
            style: TextStyle(
              color: PremiumGlassmorphicTheme.textPrimary,
              fontSize: PremiumGlassmorphicTheme.fontSizeXl,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: PremiumGlassmorphicTheme.spacingSm),
          const Text(
            'Enter your email to receive a password reset link',
            style: TextStyle(
              color: PremiumGlassmorphicTheme.textSecondary,
              fontSize: PremiumGlassmorphicTheme.fontSizeSm,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalLoginOptions() {
    return Column(
      children: [
        // Remember Me & Forgot Password
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Checkbox(
                  value: false,
                  onChanged: (value) {},
                  activeColor: PremiumGlassmorphicTheme.indigo500,
                ),
                const SizedBox(width: PremiumGlassmorphicTheme.spacingSm),
                const Text(
                  'Remember me',
                  style: TextStyle(
                    color: PremiumGlassmorphicTheme.textSecondary,
                    fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () => _tabController.animateTo(2),
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  color: PremiumGlassmorphicTheme.indigo500,
                  fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: PremiumGlassmorphicTheme.spacingLg),
        
        // Biometric Login
        PremiumGlassmorphicTheme.glassButton(
          onPressed: _handleBiometricLogin,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fingerprint,
                color: PremiumGlassmorphicTheme.textPrimary,
                size: 20,
              ),
              const SizedBox(width: PremiumGlassmorphicTheme.spacingSm),
              const Text(
                'Login with Biometrics',
                style: TextStyle(
                  color: PremiumGlassmorphicTheme.textPrimary,
                  fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTermsSection() {
    return PremiumGlassmorphicTheme.glassCard(
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingMd),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: false,
                onChanged: (value) {},
                activeColor: PremiumGlassmorphicTheme.indigo500,
              ),
              const SizedBox(width: PremiumGlassmorphicTheme.spacingSm),
              const Expanded(
                child: Text(
                  'I agree to the Terms of Service and Privacy Policy',
                  style: TextStyle(
                    color: PremiumGlassmorphicTheme.textSecondary,
                    fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingSm),
          
          Row(
            children: [
              const Text(
                'Read our',
                style: TextStyle(
                  color: PremiumGlassmorphicTheme.textTertiary,
                  fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                ),
              ),
              const SizedBox(width: PremiumGlassmorphicTheme.spacingXs),
              TextButton(
                onPressed: _openTermsOfService,
                child: const Text(
                  'Terms of Service',
                  style: TextStyle(
                    color: PremiumGlassmorphicTheme.indigo500,
                    fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Text(
                ' and ',
                style: TextStyle(
                  color: PremiumGlassmorphicTheme.textTertiary,
                  fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                ),
              ),
              TextButton(
                onPressed: _openPrivacyPolicy,
                child: const Text(
                  'Privacy Policy',
                  style: TextStyle(
                    color: PremiumGlassmorphicTheme.indigo500,
                    fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection() {
    return PremiumGlassmorphicTheme.glassCard(
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingLg),
      child: Column(
        children: [
          const Text(
            'Need Help?',
            style: TextStyle(
              color: PremiumGlassmorphicTheme.textPrimary,
              fontSize: PremiumGlassmorphicTheme.fontSizeLg,
              fontWeight: FontWeight.w700,
            ),
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
          
          const Text(
            'Contact our support team for assistance with your account',
            style: TextStyle(
              color: PremiumGlassmorphicTheme.textSecondary,
              fontSize: PremiumGlassmorphicTheme.fontSizeSm,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingLg),
          
          Row(
            children: [
              Expanded(
                child: PremiumGlassmorphicTheme.glassButton(
                  onPressed: _contactSupport,
                  child: const Text('Email Support'),
                ),
              ),
              ),
              const SizedBox(width: PremiumGlassmorphicTheme.spacingMd),
              Expanded(
                child: PremiumGlassmorphicTheme.glassButton(
                  onPressed: _callSupport,
                  child: const Text('Call Support'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleLogin(String email, String password, bool rememberMe) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.login(email, password, rememberMe);
      
      if (mounted) {
        _showSuccessMessage('Login successful!');
        _navigateToDashboard();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleRegister(Map<String, dynamic> userData) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.register(userData);
      
      if (mounted) {
        _showSuccessMessage('Registration successful! Please check your email.');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handlePasswordReset(String email) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.resetPassword(email);
      
      if (mounted) {
        _showSuccessMessage('Password reset link sent to your email!');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _quickLogin(String role) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.quickLogin(role);
      
      if (mounted) {
        _showSuccessMessage('Logged in as $role!');
        _navigateToDashboard();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleBiometricLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.biometricLogin();
      
      if (mounted) {
        _showSuccessMessage('Biometric login successful!');
        _navigateToDashboard();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToDashboard() {
    context.go('/dashboard');
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: PremiumGlassmorphicTheme.success,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _openTermsOfService() {
    
    context.go('/terms-of-service');
  }

  void _openPrivacyPolicy() {
    
    context.go('/privacy-policy');
  }

  void _contactSupport() {
    
    // launch('mailto:support@vedantatrade.com');
  }

  void _callSupport() {
    
    // launch('tel:+977-XXXXXXX');
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import '../providers/auth_provider.dart';
import '../../../shared/widgets/enhanced_glassmorphic_button.dart';
import '../../../shared/widgets/enhanced_navigation.dart';
import '../../../app/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _resetCodeController;
  late TextEditingController _newPasswordController;
  
  late FocusNode _emailFocusNode;
  late FocusNode _passwordFocusNode;
  late FocusNode _confirmPasswordFocusNode;
  late FocusNode _nameFocusNode;
  late FocusNode _phoneFocusNode;
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Controllers
    _emailController = TextEditingController();
// _passwordController = TextEditingController(); // TODO: Move to environment variables
    _confirmPasswordController = TextEditingController();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _resetCodeController = TextEditingController();
    _newPasswordController = TextEditingController();
    
    // Focus nodes
    _emailFocusNode = FocusNode();
// _passwordFocusNode = FocusNode(); // TODO: Move to environment variables
    _confirmPasswordFocusNode = FocusNode();
    _nameFocusNode = FocusNode();
    _phoneFocusNode = FocusNode();
    
    // Animations
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
    
    // Start animations
    _fadeController.forward();
    _slideController.forward();
    
    // Check biometric availability
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false)._checkBiometricAvailability();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _resetCodeController.dispose();
    _newPasswordController.dispose();
    
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _nameFocusNode.dispose();
    _phoneFocusNode.dispose();
    
    _fadeController.dispose();
    _slideController.dispose();
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
              AppTheme.primaryColor.withOpacity(0.1),
              AppTheme.secondaryColor.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return Column(
                    children: [
                      // Header
                      _buildHeader(),
                      
                      // Tab bar
                      _buildTabBar(),
                      
                      // Content
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildLoginTab(authProvider),
                            _buildRegisterTab(authProvider),
                            _buildPasswordResetTab(authProvider),
                          ],
                        ),
                      ),
                      
                      // Biometric login button
                      if (authProvider.isBiometricAvailable && authProvider.isBiometricEnabled)
                        _buildBiometricLoginButton(authProvider),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Logo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.medical_services,
              color: Colors.white,
              size: 40,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // App name
          Text(
            'VedantaTrade',
            style: TextStyle(
              color: AppTheme.textPrimaryColor,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Tagline
          Text(
            'Pharmaceutical Distribution Platform',
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.glassColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.glassBorderColor),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: AppTheme.textSecondaryColor,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelColor: AppTheme.textSecondaryColor,
        tabs: const [
          Tab(text: 'Login'),
          Tab(text: 'Register'),
          Tab(text: 'Reset'),
        ],
      ),
    );
  }

  Widget _buildLoginTab(AuthProvider authProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Rate limiting warning
          if (authProvider.isRateLimited)
            _buildRateLimitWarning(authProvider),
          
          const SizedBox(height: 24),
          
          // Email field
          _buildEmailField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            label: 'Email Address',
            validator: authProvider.validateEmail,
            onSubmitted: () {
              _passwordFocusNode.requestFocus();
            },
          ),
          
          const SizedBox(height: 16),
          
          // Password field
          _buildPasswordField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            label: 'Password',
            validator: authProvider.validatePassword,
            onSubmitted: () => _handleLogin(authProvider),
          ),
          
          const SizedBox(height: 16),
          
          // Remember me and biometric
          Row(
            children: [
              // Remember me checkbox
              Expanded(
                child: CheckboxListTile(
                  title: Text(
                    'Remember me',
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 14,
                    ),
                  ),
                  value: authProvider.rememberMe,
                  onChanged: (value) => authProvider.setRememberMe(value ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              
              // Enable biometric
              if (authProvider.isBiometricAvailable && !authProvider.isBiometricEnabled)
                Expanded(
                  child: CheckboxListTile(
                    title: Text(
                      'Enable biometric',
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 14,
                      ),
                    ),
                    value: authProvider.enableBiometric,
                    onChanged: (value) => authProvider.setEnableBiometric(value ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Login button
          EnhancedGlassmorphicButton(
            text: 'Sign In',
            isLoading: authProvider.isLoading,
            onPressed: () => _handleLogin(authProvider),
          ),
          
          const SizedBox(height: 16),
          
          // Error message
          if (authProvider.errorMessage != null)
            _buildErrorMessage(authProvider.errorMessage!),
        ],
      ),
    );
  }

  Widget _buildRegisterTab(AuthProvider authProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Name field
          _buildTextField(
            controller: _nameController,
            focusNode: _nameFocusNode,
            label: 'Full Name',
            validator: authProvider.validateName,
            onSubmitted: () => _emailFocusNode.requestFocus(),
          ),
          
          const SizedBox(height: 16),
          
          // Email field
          _buildEmailField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            label: 'Email Address',
            validator: authProvider.validateEmail,
            onSubmitted: () => _phoneFocusNode.requestFocus(),
          ),
          
          const SizedBox(height: 16),
          
          // Phone field
          _buildTextField(
            controller: _phoneController,
            focusNode: _phoneFocusNode,
            label: 'Phone Number',
            keyboardType: TextInputType.phone,
            validator: authProvider.validatePhone,
// onSubmitted: () => _passwordFocusNode.requestFocus(), // TODO: Move to environment variables
          ),
          
          const SizedBox(height: 16),
          
          // Password field
          _buildPasswordField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            label: 'Password',
            validator: authProvider.validatePassword,
            onSubmitted: () => _confirmPasswordFocusNode.requestFocus(),
          ),
          
          const SizedBox(height: 16),
          
          // Confirm password field
          _buildPasswordField(
            controller: _confirmPasswordController,
            focusNode: _confirmPasswordFocusNode,
            label: 'Confirm Password',
            validator: (value) => authProvider.validateConfirmPassword(
              _passwordController.text,
              value ?? '',
            ),
            onSubmitted: () => _handleRegister(authProvider),
          ),
          
          const SizedBox(height: 24),
          
          // Role selection
          _buildRoleSelector(authProvider),
          
          const SizedBox(height: 24),
          
          // Registration code field
          _buildTextField(
            controller: TextEditingController(),
            label: 'Registration Code (Optional)',
            hintText: 'If you have a registration code',
          ),
          
          const SizedBox(height: 24),
          
          // Register button
          EnhancedGlassmorphicButton(
            text: 'Create Account',
            isLoading: authProvider.isLoading,
            onPressed: () => _handleRegister(authProvider),
          ),
          
          const SizedBox(height: 16),
          
          // Error message
          if (authProvider.errorMessage != null)
            _buildErrorMessage(authProvider.errorMessage!),
        ],
      ),
    );
  }

  Widget _buildPasswordResetTab(AuthProvider authProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          if (!authProvider.isPasswordResetCodeSent)
            _buildPasswordResetRequest(authProvider)
          else
            _buildPasswordResetConfirmation(authProvider),
        ],
      ),
    );
  }

  Widget _buildPasswordResetRequest(AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reset Password',
          style: TextStyle(
            color: AppTheme.textPrimaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Text(
          'Enter your email address and we\'ll send you a code to reset your password.',
          style: TextStyle(
            color: AppTheme.textSecondaryColor,
            fontSize: 14,
          ),
        ),
        
        const SizedBox(height: 24),
        
        _buildEmailField(
          controller: _emailController,
          focusNode: _emailFocusNode,
          label: 'Email Address',
          validator: authProvider.validateEmail,
          onSubmitted: () => _handlePasswordResetRequest(authProvider),
        ),
        
        const SizedBox(height: 24),
        
        EnhancedGlassmorphicButton(
          text: 'Send Reset Code',
          isLoading: authProvider.isLoading,
          onPressed: () => _handlePasswordResetRequest(authProvider),
        ),
        
        const SizedBox(height: 16),
        
        if (authProvider.errorMessage != null)
          _buildErrorMessage(authProvider.errorMessage!),
      ],
    );
  }

  Widget _buildPasswordResetConfirmation(AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confirm Password Reset',
          style: TextStyle(
            color: AppTheme.textPrimaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Text(
          'Enter the code sent to your email and your new password.',
          style: TextStyle(
            color: AppTheme.textSecondaryColor,
            fontSize: 14,
          ),
        ),
        
        const SizedBox(height: 24),
        
        _buildTextField(
          controller: _resetCodeController,
          label: 'Reset Code',
          hintText: 'Enter 6-digit code',
          keyboardType: TextInputType.number,
        ),
        
        const SizedBox(height: 16),
        
        _buildPasswordField(
          controller: _newPasswordController,
          label: 'New Password',
          validator: authProvider.validatePassword,
        ),
        
        const SizedBox(height: 24),
        
        EnhancedGlassmorphicButton(
          text: 'Reset Password',
          isLoading: authProvider.isLoading,
          onPressed: () => _handlePasswordResetConfirmation(authProvider),
        ),
        
        const SizedBox(height: 16),
        
        TextButton(
          onPressed: () => authProvider.clearPasswordResetState(),
          child: Text(
            'Back to Login',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        if (authProvider.errorMessage != null)
          _buildErrorMessage(authProvider.errorMessage!),
      ],
    );
  }

  Widget _buildEmailField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    String? Function(String?)? validator,
    VoidCallback? onSubmitted,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.glassColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.glassBorderColor),
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppTheme.textSecondaryColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: Icon(
            Icons.email_outlined,
            color: AppTheme.textSecondaryColor,
          ),
        ),
        style: TextStyle(
          color: AppTheme.textPrimaryColor,
          fontSize: 16,
        ),
        validator: validator,
        onFieldSubmitted: (_) => onSubmitted?.call(),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    String? Function(String?)? validator,
    VoidCallback? onSubmitted,
  }) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.glassColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.glassBorderColor),
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            obscureText: authProvider.obscurePassword,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: AppTheme.textSecondaryColor),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              prefixIcon: Icon(
                Icons.lock_outline,
                color: AppTheme.textSecondaryColor,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  authProvider.obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: AppTheme.textSecondaryColor,
                ),
                onPressed: () => authProvider.togglePasswordVisibility(),
              ),
            ),
            style: TextStyle(
              color: AppTheme.textPrimaryColor,
              fontSize: 16,
            ),
            validator: validator,
            onFieldSubmitted: (_) => onSubmitted?.call(),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    String? hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    VoidCallback? onSubmitted,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.glassColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.glassBorderColor),
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          labelStyle: TextStyle(color: AppTheme.textSecondaryColor),
          hintStyle: TextStyle(color: AppTheme.textSecondaryColor.withOpacity(0.6)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        style: TextStyle(
          color: AppTheme.textPrimaryColor,
          fontSize: 16,
        ),
        validator: validator,
        onFieldSubmitted: (_) => onSubmitted?.call(),
      ),
    );
  }

  Widget _buildRoleSelector(AuthProvider authProvider) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.glassColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.glassBorderColor),
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Select Role',
          labelStyle: TextStyle(color: AppTheme.textSecondaryColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        style: TextStyle(
          color: AppTheme.textPrimaryColor,
          fontSize: 16,
        ),
        items: const [
          DropdownMenuItem(value: 'User', child: Text('User')),
          DropdownMenuItem(value: 'Retailer', child: Text('Retailer')),
          DropdownMenuItem(value: 'Stockist', child: Text('Stockist')),
          DropdownMenuItem(value: 'MR', child: Text('Medical Representative')),
          DropdownMenuItem(value: 'Accountant', child: Text('Accountant')),
          DropdownMenuItem(value: 'Admin', child: Text('Admin')),
        ],
        onChanged: (value) {
          // Store selected role for registration
        },
      ),
    );
  }

  Widget _buildRateLimitWarning(AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber,
                color: Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Too Many Login Attempts',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again in ${authProvider.lockoutEndTime != null ? _formatTimeRemaining(authProvider.lockoutEndTime!) : '15 minutes'}.',
            style: TextStyle(
              color: Colors.red.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricLoginButton(AuthProvider authProvider) {
    return Container(
      margin: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            'Or use biometric authentication',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.glassColor,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppTheme.glassBorderColor),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () => _handleBiometricLogin(authProvider),
                child: Center(
                  child: authProvider.isBiometricLoading
                      ? const CircularProgressIndicator()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.fingerprint,
                              color: AppTheme.primaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Login with Biometrics',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeRemaining(DateTime lockoutEndTime) {
    final now = DateTime.now();
    final difference = lockoutEndTime.difference(now);
    
    if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes';
    } else {
      return '${difference.inSeconds} seconds';
    }
  }

  void _handleLogin(AuthProvider authProvider) async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      return;
    }

    final success = await authProvider.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (success) {
      HapticFeedback.lightImpact();
      context.go('/dashboard');
    }
  }

  void _handleRegister(AuthProvider authProvider) async {
    if (_nameController.text.isEmpty || 
        _emailController.text.isEmpty || 
        _phoneController.text.isEmpty || 
        _passwordController.text.isEmpty || 
        _confirmPasswordController.text.isEmpty) {
      return;
    }

    final success = await authProvider.register(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      phone: _phoneController.text,
      role: 'User', // Default role
    );

    if (success) {
      HapticFeedback.lightImpact();
      _showSuccessDialog('Registration successful! Please check your email for verification.');
      _tabController.animateTo(0); // Switch to login tab
    }
  }

  void _handleBiometricLogin(AuthProvider authProvider) async {
    final success = await authProvider.biometricLogin();
    
    if (success) {
      HapticFeedback.lightImpact();
      context.go('/dashboard');
    }
  }

  void _handlePasswordResetRequest(AuthProvider authProvider) async {
    if (_emailController.text.isEmpty) {
      return;
    }

    final success = await authProvider.requestPasswordReset(_emailController.text);
    
    if (success) {
      HapticFeedback.lightImpact();
      _showSuccessDialog('Reset code sent to your email!');
    }
  }

  void _handlePasswordResetConfirmation(AuthProvider authProvider) async {
    if (_resetCodeController.text.isEmpty || _newPasswordController.text.isEmpty) {
      return;
    }

    final success = await authProvider.confirmPasswordReset(
      email: _emailController.text,
      code: _resetCodeController.text,
      newPassword: _newPasswordController.text,
    );

    if (success) {
      HapticFeedback.lightImpact();
      _showSuccessDialog('Password reset successful! You can now login with your new password.');
      _tabController.animateTo(0); // Switch to login tab
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

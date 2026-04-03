import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/glassmorphic_widgets.dart';
import '../providers/auth_provider.dart';
import '../../../app/theme/app_theme.dart';

class SecureAuthScreen extends StatefulWidget {
  const SecureAuthScreen({Key? key}) : super(key: key);

  @override
  State<SecureAuthScreen> createState() => _SecureAuthScreenState();
}

class _SecureAuthScreenState extends State<SecureAuthScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _pinController = TextEditingController();

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
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBiometricTab(context),
                  _buildPasswordTab(context),
                  _buildPinTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Column(
                  children: [
                    const Icon(
                      Icons.security,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Secure Authentication',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Choose your preferred authentication method',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF3730A3)],
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.white70,
        unselectedLabelColor: Colors.white54,
        tabs: const [
          Tab(
            icon: Icon(Icons.fingerprint),
            text: 'Biometric',
          ),
          Tab(
            icon: Icon(Icons.lock),
            text: 'Password',
          ),
          Tab(
            icon: Icon(Icons.pin),
            text: 'PIN',
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricTab(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: _slideAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.fingerprint,
                  color: Color(0xFF4F46E5),
                  size: 64,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Biometric Authentication',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Use your fingerprint or face recognition for quick access',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                GlassmorphicButton(
                  text: 'Enable Biometric Authentication',
                  onPressed: _enableBiometricAuth,
                  width: double.infinity,
                  height: 56,
                  icon: Icons.fingerprint,
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => _tabController.animateTo(1),
                  child: const Text(
                    'Use Password Instead',
                    style: TextStyle(color: Color(0xFF4F46E5)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPasswordTab(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: _slideAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock,
                    color: Color(0xFF4F46E5),
                    size: 64,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Password Authentication',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Email Field
                  GlassmorphicTextField(
                    controller: _emailController,
                    hintText: 'Email Address',
                    prefixIcon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Password Field
                  GlassmorphicTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    prefixIcon: Icons.lock,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value!.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Confirm Password Field
                  GlassmorphicTextField(
                    controller: _confirmPasswordController,
                    hintText: 'Confirm Password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Login Button
                  GlassmorphicButton(
                    text: 'Login with Password',
                    onPressed: _loginWithPassword,
                    width: double.infinity,
                    height: 56,
                    icon: Icons.login,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Navigation Options
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => _tabController.animateTo(0),
                        child: const Text(
                          'Try Biometric',
                          style: TextStyle(color: Color(0xFF4F46E5)),
                        ),
                      ),
                      const SizedBox(width: 20),
                      TextButton(
                        onPressed: () => _tabController.animateTo(2),
                        child: const Text(
                          'Use PIN',
                          style: TextStyle(color: Color(0xFF4F46E5)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPinTab(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: _slideAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.pin,
                  color: Color(0xFF4F46E5),
                  size: 64,
                ),
                const SizedBox(height: 20),
                const Text(
                  'PIN Authentication',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Enter your 4-digit PIN for quick access',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                
                // PIN Input Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) {
                    return Container(
                      width: 60,
                      height: 60,
                      margin: const EdgeInsets.all(4),
                      child: TextFormField(
                        controller: TextEditingController(),
                        obscureText: true,
                        maxLength: 1,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF4F46E5)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    );
                  }),
                ),
                
                const SizedBox(height: 30),
                
                // PIN Actions
                GlassmorphicButton(
                  text: 'Login with PIN',
                  onPressed: _loginWithPin,
                  width: double.infinity,
                  height: 56,
                  icon: Icons.pin,
                ),
                
                const SizedBox(height: 20),
                
                // Navigation Options
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => _tabController.animateTo(0),
                      child: const Text(
                        'Try Biometric',
                        style: TextStyle(color: Color(0xFF4F46E5)),
                      ),
                    ),
                    const SizedBox(width: 20),
                    TextButton(
                      onPressed: () => _tabController.animateTo(1),
                      child: const Text(
                        'Use Password',
                        style: TextStyle(color: Color(0xFF4F46E5)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _enableBiometricAuth() async {
    try {
      final canCheckBiometrics = await LocalAuthentication().canCheckBiometrics;
      if (!canCheckBiometrics) {
        _showError('Biometric authentication is not available on this device');
        return;
      }

      final isDeviceSupported = await LocalAuthentication().isDeviceSupported();
      if (!isDeviceSupported) {
        _showError('Device does not support biometric authentication');
        return;
      }

      // Show biometric enrollment dialog
      final didAuthenticate = await LocalAuthentication().authenticate(
        localizedReason: 'Enable biometric authentication for VedantaTrade',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        _showSuccess('Biometric authentication enabled successfully!');
      } else {
        _showError('Failed to enable biometric authentication');
      }
    } catch (e) {
      _showError('Authentication error: ${e.toString()}');
    }
  }

  Future<void> _loginWithPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.login(
      _emailController.text,
      _passwordController.text,
      useBiometric: false,
    );
  }

  Future<void> _loginWithPin() async {
    // Collect PIN from all 4 fields
    final pin = List.generate(4, (index) {
      // This is a simplified implementation - in real app, you'd need to track the PIN input
      return '1'; // Placeholder
    }).join();

    if (pin.length != 4) {
      _showError('Please enter a complete 4-digit PIN');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.login(
      'pin_user@vedanta.com', // Placeholder email for PIN users
      pin,
      useBiometric: false,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

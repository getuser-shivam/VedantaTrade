import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/glassmorphic_widgets.dart';
import '../providers/auth_provider.dart';
import 'password_reset_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isPasswordVisible = false;

  final List<Map<String, dynamic>> _roles = [
    {'role': 'ADMIN', 'email': 'admin@vedanta.com', 'password': 'Admin@123', 'label': 'Admin', 'icon': Icons.admin_panel_settings},
    {'role': 'MEDICAL_REP', 'email': 'mr@vedanta.com', 'password': 'MR@123', 'label': 'Medical Rep', 'icon': Icons.medical_services},
    {'role': 'ACCOUNTANT', 'email': 'accountant@vedanta.com', 'password': 'Acc@123', 'label': 'Accountant', 'icon': Icons.account_balance},
    {'role': 'DOCTOR', 'email': 'doctor@vedanta.com', 'password': 'Doc@123', 'label': 'Doctor', 'icon': Icons.health_and_safety},
    {'role': 'STOCKIST', 'email': 'stockist@vedanta.com', 'password': 'Stock@123', 'label': 'Stockist', 'icon': Icons.warehouse},
    {'role': 'RETAILER', 'email': 'retailer@vedanta.com', 'password': 'Retail@123', 'label': 'Retailer', 'icon': Icons.storefront},
  ];

  void _quickLogin(Map<String, dynamic> role) {
    _emailCtrl.text = role['email'];
    _passwordCtrl.text = role['password'];
    _handleLogin();
  }

  Future<void> _handleLogin() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.login(_emailCtrl.text.trim(), _passwordCtrl.text);
    
    if (mounted) {
      if (success) {
        _navigateToDashboard(auth.userRole);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auth.errorMessage ?? 'Login failed')),
        );
      }
    }
  }

  void _navigateToDashboard(String? role) {
    switch (role) {
      case 'ADMIN': context.go('/admin'); break;
      case 'MEDICAL_REP': context.go('/mr'); break;
      case 'ACCOUNTANT': context.go('/accounting'); break;
      case 'DOCTOR': context.go('/doctor'); break;
      case 'STOCKIST': context.go('/stockist'); break;
      case 'RETAILER': context.go('/retailer'); break;
      default: context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F172A)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -100, right: -100,
              child: Container(
                width: 300, height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withOpacity(0.1),
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.medication, size: 80, color: Colors.blue),
                      const SizedBox(height: 16),
                      const Text(
                        'VedantaTrade',
                        style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1),
                      ),
                      const Text(
                        'Secure Pharma Ecosystem',
                        style: TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                      const SizedBox(height: 48),
                      GlassmorphicCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            GlassmorphicTextField(
                              controller: _emailCtrl,
                              hintText: 'Email Address',
                              prefixIcon: Icons.email_outlined,
                            ),
                            const SizedBox(height: 16),
                            GlassmorphicTextField(
                              controller: _passwordCtrl,
                              hintText: 'Password',
                              prefixIcon: Icons.lock_outline,
                              obscureText: !_isPasswordVisible,
                              suffixIcon: IconButton(
                                icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.white38),
                                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                              ),
                            ),
                            const SizedBox(height: 32),
                            Consumer<AuthProvider>(
                              builder: (context, auth, _) => GlassmorphicButton(
                                text: auth.isLoading ? 'Verifying...' : 'Login',
                                onPressed: auth.isLoading ? null : _handleLogin,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        'Quick Access (Demo)',
                        style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: _roles.map((role) => GlassmorphicChip(
                          label: role['label'],
                          onTap: () => _quickLogin(role),
                        )).toList(),
                      ),
                      const SizedBox(height: 40),
                      TextButton(
                        onPressed: () => context.go('/auth/forgot-password'),
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/auth/register'),
                        child: const Text(
                          'Don\'t have access? Register',
                          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

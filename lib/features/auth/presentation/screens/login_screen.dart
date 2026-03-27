import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:vedanta_trade/features/auth/presentation/providers/auth_provider.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  late AnimationController _animCtrl;
  late Animation<double> _slideAnim;
  late Animation<double> _fadeAnim;
  bool? _isBackendOnline;
  Timer? _healthTimer;

  final _roles = [
    {'role': 'ADMIN', 'email': 'admin@vedanta.com', 'password': 'Admin@123', 'color': AppTheme.adminColor, 'icon': Icons.admin_panel_settings_rounded, 'label': 'Admin'},
    {'role': 'MEDICAL_REP', 'email': 'mr@vedanta.com', 'password': 'MR@123', 'color': AppTheme.mrColor, 'icon': Icons.medical_services_rounded, 'label': 'Medical Rep'},
    {'role': 'ACCOUNTANT', 'email': 'accountant@vedanta.com', 'password': 'Acc@123', 'color': AppTheme.accountantColor, 'icon': Icons.account_balance_rounded, 'label': 'Accountant'},
    {'role': 'DOCTOR', 'email': 'doctor@vedanta.com', 'password': 'Doc@123', 'color': AppTheme.doctorColor, 'icon': Icons.health_and_safety_rounded, 'label': 'Doctor'},
    {'role': 'STOCKIST', 'email': 'stockist@vedanta.com', 'password': 'Stock@123', 'color': AppTheme.stockistColor, 'icon': Icons.warehouse_rounded, 'label': 'Stockist'},
    {'role': 'RETAILER', 'email': 'retailer@vedanta.com', 'password': 'Retail@123', 'color': AppTheme.retailerColor, 'icon': Icons.storefront_rounded, 'label': 'Retailer'},
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _slideAnim = Tween<double>(begin: 40, end: 0).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _animCtrl, curve: const Interval(0.2, 1.0, curve: Curves.easeIn)));
    _animCtrl.forward();
    _checkHealth();
    _healthTimer = Timer.periodic(const Duration(seconds: 10), (_) => _checkHealth());
  }

  Future<void> _checkHealth() async {
    final status = await context.read<AuthProvider>().checkHealth();
    if (mounted) setState(() => _isBackendOnline = status);
  }

  @override
  void dispose() { 
    _animCtrl.dispose(); 
    _emailCtrl.dispose(); 
    _passwordCtrl.dispose(); 
    _healthTimer?.cancel();
    super.dispose(); 
  }

  Future<void> _login() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(
      _emailCtrl.text.trim(), 
      _passwordCtrl.text,
      useBiometric: false,
    );
    if (!mounted) return;
    if (ok) {
      final role = auth.userRole;
      _navigateToDashboard(role);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Login failed'), 
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
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

  void _quickLogin(Map<String, dynamic> role) {
    _emailCtrl.text = role['email'] as String;
    _passwordCtrl.text = role['password'] as String;
    _login();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -100, left: -100,
            child: Container(
              width: 400, height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withOpacity(0.05),
                boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.1), blurRadius: 100, spreadRadius: 50)],
              ),
            ),
          ),
          
          Row(
            children: [
              // Left Panel - Branding (Only visible on wide screens)
              if (MediaQuery.of(context).size.width > 900)
                Expanded(
                  flex: 5,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1A1D2E), Color(0xFF0F1117)], 
                        begin: Alignment.topLeft, 
                        end: Alignment.bottomRight
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FadeTransition(
                          opacity: _fadeAnim,
                          child: Container(
                            width: 100, height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.secondary]),
                              boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.35), blurRadius: 40, spreadRadius: 5)],
                            ),
                            child: const Icon(Icons.local_pharmacy_rounded, size: 54, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text('VedantaTrade', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
                        const SizedBox(height: 12),
                        Text('Enterprise Pharma Management\nPrecision, Compliance, & Analytics', 
                          textAlign: TextAlign.center, 
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16, height: 1.6, fontWeight: FontWeight.w300)
                        ),
                        const SizedBox(height: 60),
                        // Quick Login Roles
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 48),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('QUICK ACCESS DEMO', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 20),
                              Wrap(
                                spacing: 10, runSpacing: 10,
                                children: _roles.map((r) => _QuickLoginChip(
                                  label: r['label'] as String,
                                  color: r['color'] as Color,
                                  icon: r['icon'] as IconData,
                                  onTap: () => _quickLogin(r),
                                )).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Right Panel - Login Form
              Expanded(
                flex: 4,
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                      child: AnimatedBuilder(
                        animation: _slideAnim,
                        builder: (_, child) => Transform.translate(
                          offset: Offset(0, _slideAnim.value),
                          child: Opacity(opacity: _fadeAnim.value, child: child),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (MediaQuery.of(context).size.width <= 900) ...[
                              Center(child: Icon(Icons.local_pharmacy_rounded, size: 64, color: AppTheme.primary)),
                              const SizedBox(height: 16),
                              const Center(child: Text('VedantaTrade', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white))),
                              const SizedBox(height: 40),
                            ],
                            const Text('Sign In', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text('Access your secure workspace', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 15)),
                                const Spacer(),
                                _BackendStatusBadge(isOnline: _isBackendOnline),
                              ],
                            ),
                            const SizedBox(height: 48),
                            
                            // Input Fields
                            _CustomTextField(
                              controller: _emailCtrl,
                              label: 'Email Address',
                              icon: Icons.alternate_email_rounded,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 20),
                            _CustomTextField(
                              controller: _passwordCtrl,
                              label: 'Password',
                              icon: Icons.lock_outline_rounded,
                              obscureText: _obscure,
                              suffix: IconButton(
                                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: Colors.white24, size: 20),
                                onPressed: () => setState(() => _obscure = !_obscure),
                              ),
                              onSubmitted: (_) => _login(),
                            ),
                            
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => context.go('/auth/forgot-password'),
                                child: Text('Forgot Password?', style: TextStyle(color: AppTheme.primary.withOpacity(0.8), fontSize: 14)),
                              ),
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: auth.isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 8,
                                  shadowColor: AppTheme.primary.withOpacity(0.4),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                child: auth.isLoading
                                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                                  : const Text('Connect to Workspace', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Don\'t have an account?', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)),
                                TextButton(
                                  onPressed: () => context.go('/auth/register'),
                                  child: const Text('Request Access', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 60),
                            Center(
                              child: Text('Vedanta TradeLink Pvt. Ltd. © 2026', 
                                style: TextStyle(color: Colors.white.withOpacity(0.15), fontSize: 11, letterSpacing: 1)
                              )
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final Function(String)? onSubmitted;

  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppTheme.primary.withOpacity(0.5), size: 20),
            suffixIcon: suffix,
            filled: true,
            fillColor: Colors.white.withOpacity(0.03),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}

class _QuickLoginChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  const _QuickLoginChip({required this.label, required this.color, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, 
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _BackendStatusBadge extends StatelessWidget {
  final bool? isOnline;
  const _BackendStatusBadge({this.isOnline});

  @override
  Widget build(BuildContext context) {
    final color = isOnline == null ? Colors.white10 : (isOnline! ? AppTheme.success : AppTheme.error);
    final text = isOnline == null ? 'Syncing...' : (isOnline! ? 'Network Online' : 'Network Offline');
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:vedanta_trade/features/authentication/presentation/providers/auth_provider.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
// final _passwordCtrl = TextEditingController(); // TODO: Move to environment variables
  bool _obscure = true;
  late AnimationController _animCtrl;
  late Animation<double> _slideAnim;
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
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _slideAnim = Tween<double>(begin: 60, end: 0).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
    _checkHealth();
    _healthTimer = Timer.periodic(const Duration(seconds: 5), (_) => _checkHealth());
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
      switch (role) {
        case 'ADMIN': context.go('/admin'); break;
        case 'MEDICAL_REP': context.go('/mr'); break;
        case 'ACCOUNTANT': context.go('/accounting'); break;
        case 'DOCTOR': context.go('/doctor'); break;
        case 'STOCKIST': context.go('/stockist'); break;
        case 'RETAILER': context.go('/retailer'); break;
        default: {}
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Login failed'), backgroundColor: AppTheme.error),
      );
    }
  }

  void _quickLogin(Map<String, dynamic> role) {
    _emailCtrl.text = role['email'] as String;
// _passwordCtrl.text = role['password'] as String; // TODO: Move to environment variables
    _login();
  }

  Future<void> _biometricLogin() async {
    final auth = context.read<AuthProvider>();
    if (!auth.biometricEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biometric authentication not enabled'), backgroundColor: AppTheme.error),
      );
      return;
    }
    
    // Use stored credentials for biometric login
    final ok = await auth.login('', '', useBiometric: true);
    if (!mounted) return;
    
    if (ok) {
      final role = auth.userRole;
      switch (role) {
        case 'ADMIN': context.go('/admin'); break;
        case 'MEDICAL_REP': context.go('/mr'); break;
        case 'ACCOUNTANT': context.go('/accounting'); break;
        case 'DOCTOR': context.go('/doctor'); break;
        case 'STOCKIST': context.go('/stockist'); break;
        case 'RETAILER': context.go('/retailer'); break;
        default: {}
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Biometric login failed'), backgroundColor: AppTheme.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Row(
        children: [
          // Left Panel - Branding
          Expanded(
            flex: 5,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF1A1D2E), Color(0xFF0F1117)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 88, height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.secondary]),
                      boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.35), blurRadius: 30)],
                    ),
                    child: const Icon(Icons.local_pharmacy_rounded, size: 48, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  const Text('VedantaTrade', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text('Enterprise Pharma\nManagement Platform', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14, height: 1.5)),
                  const SizedBox(height: 48),
                  // Quick Login Roles
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quick Login As:', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11, letterSpacing: 1)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8, runSpacing: 8,
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
            child: AnimatedBuilder(
              animation: _slideAnim,
              builder: (_, child) => Transform.translate(offset: Offset(_slideAnim.value, 0), child: child),
              child: Container(
                color: AppTheme.surfaceDark,
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Welcome back', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text('Sign in to your account', style: TextStyle(color: Colors.white.withOpacity(0.5))),
                        const Spacer(),
                        _BackendStatusBadge(isOnline: _isBackendOnline),
                      ],
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined, color: Colors.white38)),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordCtrl,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.white38),
                        suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: Colors.white38), onPressed: () => setState(() => _obscure = !_obscure)),
                      ),
                      style: const TextStyle(color: Colors.white),
                      onSubmitted: (_) => _login(),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: auth.isLoading ? null : _login,
                        child: auth.isLoading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                          : const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Biometric Login Button
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        if (auth.biometricEnabled) {
                          return SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton(
                              onPressed: auth.isLoading ? null : _biometricLogin,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppTheme.primary),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.fingerprint, color: AppTheme.primary),
                                  SizedBox(width: 8),
                                  Text('Sign in with Biometrics', style: TextStyle(color: AppTheme.primary, fontSize: 14)),
                                ],
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 16),
                    // Forgot Password & Register Links
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
// onTap: () => context.go('/forgot-password'), // TODO: Move to environment variables
                          child: Text(
                            'Forgot password?',
                            style: TextStyle(color: AppTheme.primary, fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/register'),
                          child: Text(
                            'Create account',
                            style: TextStyle(color: AppTheme.primary, fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Center(child: Text('Vedanta TradeLink Pvt. Ltd. © 2024', style: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 11))),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}
class _BackendStatusBadge extends StatelessWidget {
  final bool? isOnline;
  const _BackendStatusBadge({this.isOnline});

  @override
  Widget build(BuildContext context) {
    final color = isOnline == null ? Colors.white24 : (isOnline! ? AppTheme.success : AppTheme.error);
    final text = isOnline == null ? 'Checking...' : (isOnline! ? 'Backend Online' : 'Backend Offline');
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

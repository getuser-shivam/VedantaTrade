import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_trade/features/auth/presentation/providers/auth_provider.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _scale = Tween<double>(begin: 0.7, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _ctrl.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    if (auth.isLoggedIn) {
      final role = auth.userRole;
      switch (role) {
        case 'ADMIN': context.go('/admin'); break;
        case 'MEDICAL_REP': context.go('/mr'); break;
        case 'ACCOUNTANT': context.go('/accounting'); break;
        case 'DOCTOR': context.go('/doctor'); break;
        case 'STOCKIST': context.go('/stockist'); break;
        case 'RETAILER': context.go('/retailer'); break;
        default: context.go('/login');
      }
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.secondary], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 30, spreadRadius: 5)],
                  ),
                  child: const Icon(Icons.local_pharmacy_rounded, size: 52, color: Colors.white),
                ),
                const SizedBox(height: 24),
                const Text('VedantaTrade', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
                const SizedBox(height: 6),
                Text('Enterprise Pharma Management', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.5), letterSpacing: 1)),
                const SizedBox(height: 48),
                SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.primary.withOpacity(0.7))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

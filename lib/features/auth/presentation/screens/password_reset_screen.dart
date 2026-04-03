import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/glassmorphic_widgets.dart';
import '../providers/auth_provider.dart';

class PasswordResetScreen extends StatefulWidget {
  final String? token;
  const PasswordResetScreen({super.key, this.token});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  
  bool _isResetMode = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _isResetMode = widget.token != null;
  }

  Future<void> _handleResetRequest() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.resetPassword(_emailCtrl.text.trim());

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reset instructions sent to your email')),
        );
        context.go('/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auth.errorMessage ?? 'Request failed')),
        );
      }
    }
  }

  Future<void> _handlePasswordReset() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Mock success for now
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset successful!')),
    );
    context.go('/login');
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
              top: 100, left: -50,
              child: Container(
                width: 250, height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withOpacity(0.05),
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
                      const Icon(Icons.lock_reset, size: 70, color: Colors.blue),
                      const SizedBox(height: 16),
                      Text(
                        _isResetMode ? 'New Password' : 'Reset Access',
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -1),
                      ),
                      Text(
                        _isResetMode 
                          ? 'Enter your new secure password' 
                          : 'Enter your email to receive recovery link',
                        style: const TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                      const SizedBox(height: 32),
                      GlassmorphicCard(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              if (!_isResetMode) ...[
                                GlassmorphicTextField(
                                  controller: _emailCtrl,
                                  hintText: 'Email Address',
                                  prefixIcon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (val) => val == null || !val.contains('@') ? 'Invalid email' : null,
                                ),
                              ] else ...[
                                GlassmorphicTextField(
                                  controller: _passwordCtrl,
                                  hintText: 'New Password',
                                  prefixIcon: Icons.lock_outline,
                                  obscureText: !_isPasswordVisible,
                                  validator: (val) => val == null || val.length < 6 ? 'Min 6 chars' : null,
                                ),
                                const SizedBox(height: 16),
                                GlassmorphicTextField(
                                  controller: _confirmPasswordCtrl,
                                  hintText: 'Confirm Password',
                                  prefixIcon: Icons.lock_reset,
                                  obscureText: !_isPasswordVisible,
                                  validator: (val) => val != _passwordCtrl.text ? 'Passwords mismatch' : null,
                                  suffixIcon: IconButton(
                                    icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.white38),
                                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 32),
                              Consumer<AuthProvider>(
                                builder: (context, auth, _) => GlassmorphicButton(
                                  text: auth.isLoading ? 'Processing...' : (_isResetMode ? 'Update Password' : 'Send Reset Link'),
                                  onPressed: auth.isLoading ? null : (_isResetMode ? _handlePasswordReset : _handleResetRequest),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text(
                          'Back to Login',
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


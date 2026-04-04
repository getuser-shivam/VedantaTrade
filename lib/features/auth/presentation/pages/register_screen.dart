import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/glassmorphic_widgets.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _agreeToTerms = false;

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the terms')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      _nameCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
      _phoneCtrl.text.trim(),
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
        context.go('/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auth.errorMessage ?? 'Registration failed')),
        );
      }
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
              bottom: -100, left: -100,
              child: Container(
                width: 300, height: 300,
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
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.app_registration, size: 60, color: Colors.blue),
                      const SizedBox(height: 16),
                      const Text(
                        'Join VedantaTrade',
                        style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -1),
                      ),
                      const Text(
                        'Enterprise Pharma Management Access',
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                      const SizedBox(height: 32),
                      GlassmorphicCard(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              GlassmorphicTextField(
                                controller: _nameCtrl,
                                hintText: 'Full Name',
                                prefixIcon: Icons.person_outline,
                                validator: (val) => val == null || val.isEmpty ? 'Name required' : null,
                              ),
                              const SizedBox(height: 16),
                              GlassmorphicTextField(
                                controller: _emailCtrl,
                                hintText: 'Email Address',
                                prefixIcon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (val) => val == null || !val.contains('@') ? 'Invalid email' : null,
                              ),
                              const SizedBox(height: 16),
                              GlassmorphicTextField(
                                controller: _phoneCtrl,
                                hintText: 'Phone Number',
                                prefixIcon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 16),
                              GlassmorphicTextField(
                                controller: _passwordCtrl,
                                hintText: 'Create Password',
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
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _agreeToTerms,
                                    onChanged: (v) => setState(() => _agreeToTerms = v ?? false),
                                    side: const BorderSide(color: Colors.white24),
                                    activeColor: Colors.blue,
                                  ),
                                  const Expanded(
                                    child: Text(
                                      'I agree to the Terms & Privacy Policy',
                                      style: TextStyle(color: Colors.white54, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Consumer<AuthProvider>(
                                builder: (context, auth, _) => GlassmorphicButton(
                                  text: auth.isLoading ? 'Creating...' : 'Register',
                                  onPressed: auth.isLoading ? null : _handleRegister,
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
                          'Already have an account? Sign in',
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


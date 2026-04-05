import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/premium_glassmorphic_theme.dart';

class EnhancedLoginForm extends StatefulWidget {
  final Function(String email, String password, bool rememberMe) onLogin;
  final bool isLoading;
  final String? errorMessage;

  const EnhancedLoginForm({
    Key? key,
    required this.onLogin,
    this.isLoading = false,
    this.errorMessage,
  }) : super(key: key);

  @override
  State<EnhancedLoginForm> createState() => _EnhancedLoginFormState();
}

class _EnhancedLoginFormState extends State<EnhancedLoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
// final _passwordController = TextEditingController(); // TODO: Move to environment variables
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PremiumGlassmorphicTheme.glassCard(
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingXl),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Email Field
            Text(
              'Email Address',
              style: const TextStyle(
                color: PremiumGlassmorphicTheme.textPrimary,
                fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: PremiumGlassmorphicTheme.spacingSm),
            
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: PremiumGlassmorphicTheme.getInputDecoration(
                hintText: 'Enter your email address',
                prefixIcon: Icons.email_outlined,
                errorText: widget.errorMessage,
              ),
              style: const TextStyle(
                color: PremiumGlassmorphicTheme.textPrimary,
                fontSize: PremiumGlassmorphicTheme.fontSizeMd,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email address';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            
            const SizedBox(height: PremiumGlassmorphicTheme.spacingLg),
            
            // Password Field
            Text(
              'Password',
              style: const TextStyle(
                color: PremiumGlassmorphicTheme.textPrimary,
                fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: PremiumGlassmorphicTheme.spacingSm),
            
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: PremiumGlassmorphicTheme.getInputDecoration(
                hintText: 'Enter your password',
                prefixIcon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: PremiumGlassmorphicTheme.textTertiary,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                errorText: widget.errorMessage,
              ),
              style: const TextStyle(
                color: PremiumGlassmorphicTheme.textPrimary,
                fontSize: PremiumGlassmorphicTheme.fontSizeMd,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 8) {
                  return 'Password must be at least 8 characters long';
                }
                return null;
              },
            ),
            
            const SizedBox(height: PremiumGlassmorphicTheme.spacingLg),
            
            // Remember Me & Forgot Password
            Row(
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
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
                const Spacer(),
                TextButton(
                  onPressed: () {
                    
                  },
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
            
            const SizedBox(height: PremiumGlassmorphicTheme.spacingXl),
            
            // Login Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: PremiumGlassmorphicTheme.glassButton(
                onPressed: widget.isLoading ? null : _handleLogin,
                child: widget.isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: PremiumGlassmorphicTheme.textPrimary,
                              strokeWidth: 2.0,
                            ),
                          ),
                          SizedBox(width: PremiumGlassmorphicTheme.spacingSm),
                          Text('Signing in...'),
                        ],
                      )
                    : const Text(
                        'Sign In',
                        style: TextStyle(
                          color: PremiumGlassmorphicTheme.textPrimary,
                          fontSize: PremiumGlassmorphicTheme.fontSizeMd,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                isLoading: widget.isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onLogin(
        _emailController.text.trim(),
        _passwordController.text,
        _rememberMe,
      );
    }
  }
}

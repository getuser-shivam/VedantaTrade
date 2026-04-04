import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/premium_glassmorphic_theme.dart';

class EnhancedPasswordResetForm extends StatefulWidget {
  final Function(String email) onReset;
  final bool isLoading;
  final String? errorMessage;

  const EnhancedPasswordResetForm({
    Key? key,
    required this.onReset,
    this.isLoading = false,
    this.errorMessage,
  }) : super(key: key);

  @override
  State<EnhancedPasswordResetForm> createState() => _EnhancedPasswordResetFormState();
}

class _EnhancedPasswordResetFormState extends State<EnhancedPasswordResetForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isResetMode = true;
  String _newPassword = '';
  String _confirmPassword = '';
  String _verificationCode = '';
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
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
            // Header
            _buildHeader(),
            
            const SizedBox(height: PremiumGlassmorphicTheme.spacingXl),
            
            // Reset Form
            if (_isResetMode) ...[
              _buildEmailSection(),
              const SizedBox(height: PremiumGlassmorphicTheme.spacingLg),
              _buildResetButton(),
            ] else ...[
              _buildVerificationSection(),
              const SizedBox(height: PremiumGlassmorphicTheme.spacingLg),
              _buildPasswordSection(),
              const SizedBox(height: PremiumGlassmorphicTheme.spacingLg),
              _buildConfirmButton(),
            ],
            
            // Error Message
            if (widget.errorMessage != null) ...[
              const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
              _buildErrorMessage(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(
          _isResetMode ? Icons.lock_reset : Icons.security,
          color: PremiumGlassmorphicTheme.indigo500,
          size: 48,
        ),
        const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
        Text(
          _isResetMode ? 'Reset Your Password' : 'Set New Password',
          style: const TextStyle(
            color: PremiumGlassmorphicTheme.textPrimary,
            fontSize: PremiumGlassmorphicTheme.fontSizeXl,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: PremiumGlassmorphicTheme.spacingSm),
        Text(
          _isResetMode 
              ? 'Enter your email address to receive a password reset link'
              : 'Enter the verification code and your new password',
          style: const TextStyle(
            color: PremiumGlassmorphicTheme.textSecondary,
            fontSize: PremiumGlassmorphicTheme.fontSizeSm,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email Address',
          style: TextStyle(
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
            hintText: 'Enter your registered email address',
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
      ],
    );
  }

  Widget _buildVerificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Verification Code',
          style: TextStyle(
            color: PremiumGlassmorphicTheme.textPrimary,
            fontSize: PremiumGlassmorphicTheme.fontSizeSm,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: PremiumGlassmorphicTheme.spacingSm),
        
        TextFormField(
          initialValue: _verificationCode,
          onChanged: (value) => _verificationCode = value,
          decoration: PremiumGlassmorphicTheme.getInputDecoration(
            hintText: 'Enter 6-digit verification code',
            prefixIcon: Icons.verified_user,
            errorText: widget.errorMessage,
          ),
          style: const TextStyle(
            color: PremiumGlassmorphicTheme.textPrimary,
            fontSize: PremiumGlassmorphicTheme.fontSizeMd,
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the verification code';
            }
            if (value.length != 6) {
              return 'Verification code must be 6 digits';
            }
            if (!RegExp(r'^\d{6}$').hasMatch(value)) {
              return 'Verification code must contain only numbers';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'New Password',
          style: TextStyle(
            color: PremiumGlassmorphicTheme.textPrimary,
            fontSize: PremiumGlassmorphicTheme.fontSizeSm,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: PremiumGlassmorphicTheme.spacingSm),
        
        TextFormField(
          initialValue: _newPassword,
          onChanged: (value) => _newPassword = value,
          obscureText: _obscureNewPassword,
          decoration: PremiumGlassmorphicTheme.getInputDecoration(
            hintText: 'Enter your new password',
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                color: PremiumGlassmorphicTheme.textTertiary,
              ),
              onPressed: () {
                setState(() {
                  _obscureNewPassword = !_obscureNewPassword;
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
              return 'Please enter your new password';
            }
            if (value.length < 8) {
              return 'Password must be at least 8 characters long';
            }
            if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]').hasMatch(value)) {
              return 'Password must contain uppercase, lowercase, number, and special character';
            }
            return null;
          },
        ),
        
        const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
        
        const Text(
          'Confirm Password',
          style: TextStyle(
            color: PremiumGlassmorphicTheme.textPrimary,
            fontSize: PremiumGlassmorphicTheme.fontSizeSm,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: PremiumGlassmorphicTheme.spacingSm),
        
        TextFormField(
          initialValue: _confirmPassword,
          onChanged: (value) => _confirmPassword = value,
          obscureText: _obscureConfirmPassword,
          decoration: PremiumGlassmorphicTheme.getInputDecoration(
            hintText: 'Confirm your new password',
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                color: PremiumGlassmorphicTheme.textTertiary,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
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
              return 'Please confirm your new password';
            }
            if (value != _newPassword) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
        
        const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
        
        // Password Requirements
        Container(
          padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingMd),
          decoration: BoxDecoration(
            color: PremiumGlassmorphicTheme.surfaceLight.withOpacity(0.3),
            borderRadius: BorderRadius.circular(PremiumGlassmorphicTheme.radiusMd),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Password Requirements:',
                style: TextStyle(
                  color: PremiumGlassmorphicTheme.textPrimary,
                  fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: PremiumGlassmorphicTheme.spacingSm),
              _buildPasswordRequirement('At least 8 characters', _newPassword.length >= 8),
              _buildPasswordRequirement('One uppercase letter', _newPassword.contains(RegExp(r'[A-Z]'))),
              _buildPasswordRequirement('One lowercase letter', _newPassword.contains(RegExp(r'[a-z]'))),
              _buildPasswordRequirement('One number', _newPassword.contains(RegExp(r'\d'))),
              _buildPasswordRequirement('One special character', _newPassword.contains(RegExp(r'[@$!%*?&]'))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordRequirement(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isMet ? PremiumGlassmorphicTheme.success : PremiumGlassmorphicTheme.textTertiary,
          size: 16,
        ),
        const SizedBox(width: PremiumGlassmorphicTheme.spacingSm),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isMet ? PremiumGlassmorphicTheme.success : PremiumGlassmorphicTheme.textSecondary,
              fontSize: PremiumGlassmorphicTheme.fontSizeXs,
              decoration: isMet ? TextDecoration.none : TextDecoration.lineThrough,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResetButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: PremiumGlassmorphicTheme.glassButton(
        onPressed: widget.isLoading ? null : _handlePasswordReset,
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
                  Text('Sending Reset Link...'),
                ],
              )
            : const Text(
                'Send Reset Link',
                style: TextStyle(
                  color: PremiumGlassmorphicTheme.textPrimary,
                  fontSize: PremiumGlassmorphicTheme.fontSizeMd,
                  fontWeight: FontWeight.w600,
                ),
              ),
        isLoading: widget.isLoading,
      ),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: PremiumGlassmorphicTheme.glassButton(
        onPressed: widget.isLoading ? null : _handlePasswordConfirm,
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
                  Text('Setting Password...'),
                ],
              )
            : const Text(
                'Set New Password',
                style: TextStyle(
                  color: PremiumGlassmorphicTheme.textPrimary,
                  fontSize: PremiumGlassmorphicTheme.fontSizeMd,
                  fontWeight: FontWeight.w600,
                ),
              ),
        isLoading: widget.isLoading,
      ),
    );
  }

  Widget _buildErrorMessage() {
    return PremiumGlassmorphicTheme.glassMessage(
      message: widget.errorMessage!,
      icon: Icons.error_outline,
      color: PremiumGlassmorphicTheme.error,
      onClose: () {
        
      },
    );
  }

  void _handlePasswordReset() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onReset(_emailController.text.trim());
    }
  }

  void _handlePasswordConfirm() {
    if (_formKey.currentState?.validate() ?? false) {
      
      // This would typically involve calling an API with the verification code and new password
    }
  }
}

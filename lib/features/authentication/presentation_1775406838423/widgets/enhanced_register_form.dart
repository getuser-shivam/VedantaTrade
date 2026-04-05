import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/premium_glassmorphic_theme.dart';

class EnhancedRegisterForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onRegister;
  final bool isLoading;
  final String? errorMessage;

  const EnhancedRegisterForm({
    Key? key,
    required this.onRegister,
    this.isLoading = false,
    this.errorMessage,
  }) : super(key: key);

  @override
  State<EnhancedRegisterForm> createState() => _EnhancedRegisterFormState();
}

class _EnhancedRegisterFormState extends State<EnhancedRegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
// final _passwordController = TextEditingController(); // TODO: Move to environment variables
  final _confirmPasswordController = TextEditingController();
  final _roleController = TextEditingController();
  final _licenseController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _agreeToPrivacy = false;
  String _selectedRole = 'Doctor';

  final List<Map<String, String>> _roles = [
    {'value': 'Doctor', 'label': 'Medical Doctor', 'icon': 'local_hospital'},
    {'value': 'MR', 'label': 'Medical Representative', 'icon': 'directions_walk'},
    {'value': 'Stockist', 'label': 'Stockist/Distributor', 'icon': 'inventory'},
    {'value': 'Retailer', 'label': 'Retailer/Pharmacy', 'icon': 'store'},
    {'value': 'Accountant', 'label': 'Accountant', 'icon': 'account_balance'},
    {'value': 'Admin', 'label': 'System Administrator', 'icon': 'admin_panel_settings'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _roleController.dispose();
    _licenseController.dispose();
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
            // Personal Information Section
            _buildSectionHeader('Personal Information'),
            _buildPersonalInfoSection(),
            
            const SizedBox(height: PremiumGlassmorphicTheme.spacingLg),
            
            // Professional Information Section
            _buildSectionHeader('Professional Information'),
            _buildProfessionalInfoSection(),
            
            const SizedBox(height: PremiumGlassmorphicTheme.spacingLg),
            
            // Security Section
            _buildSectionHeader('Security'),
            _buildSecuritySection(),
            
            const SizedBox(height: PremiumGlassmorphicTheme.spacingLg),
            
            // Terms and Conditions Section
            _buildTermsSection(),
            
            const SizedBox(height: PremiumGlassmorphicTheme.spacingXl),
            
            // Register Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: PremiumGlassmorphicTheme.glassButton(
                onPressed: widget.isLoading ? null : _handleRegister,
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
                          Text('Creating Account...'),
                        ],
                      )
                    : const Text(
                        'Create Account',
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PremiumGlassmorphicTheme.spacingMd),
      child: Text(
        title,
        style: const TextStyle(
          color: PremiumGlassmorphicTheme.textPrimary,
          fontSize: PremiumGlassmorphicTheme.fontSizeLg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Column(
      children: [
        // Full Name
        TextFormField(
          controller: _nameController,
          decoration: PremiumGlassmorphicTheme.getInputDecoration(
            hintText: 'Full Name',
            prefixIcon: Icons.person_outline,
            errorText: widget.errorMessage,
          ),
          style: const TextStyle(
            color: PremiumGlassmorphicTheme.textPrimary,
            fontSize: PremiumGlassmorphicTheme.fontSizeMd,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your full name';
            }
            if (value.length < 3) {
              return 'Name must be at least 3 characters long';
            }
            return null;
          },
        ),
        
        const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
        
        // Email Address
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: PremiumGlassmorphicTheme.getInputDecoration(
            hintText: 'Email Address',
            prefixIcon: Icons.email_outlined,
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
        
        const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
        
        // Phone Number
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: PremiumGlassmorphicTheme.getInputDecoration(
            hintText: 'Phone Number',
            prefixIcon: Icons.phone_outlined,
          ),
          style: const TextStyle(
            color: PremiumGlassmorphicTheme.textPrimary,
            fontSize: PremiumGlassmorphicTheme.fontSizeMd,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone number';
            }
            if (!RegExp(r'^\+?[\d\s-]{10,15}$').hasMatch(value)) {
              return 'Please enter a valid phone number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildProfessionalInfoSection() {
    return Column(
      children: [
        // Role Selection
        Text(
          'Select Your Role',
          style: const TextStyle(
            color: PremiumGlassmorphicTheme.textPrimary,
            fontSize: PremiumGlassmorphicTheme.fontSizeSm,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: PremiumGlassmorphicTheme.spacingSm),
        
        // Role Dropdown
        DropdownButtonFormField<String>(
          value: _selectedRole,
          decoration: PremiumGlassmorphicTheme.getInputDecoration(
            hintText: 'Select your role',
            prefixIcon: Icons.work_outline,
          ),
          style: const TextStyle(
            color: PremiumGlassmorphicTheme.textPrimary,
            fontSize: PremiumGlassmorphicTheme.fontSizeMd,
          ),
          items: _roles.map((role) {
            return DropdownMenuItem<String>(
              value: role['value'],
              child: Row(
                children: [
                  Icon(
                    _getRoleIcon(role['icon']),
                    color: PremiumGlassmorphicTheme.getRoleColor(role['value']),
                    size: 20,
                  ),
                  const SizedBox(width: PremiumGlassmorphicTheme.spacingSm),
                  Expanded(
                    child: Text(
                      role['label'],
                      style: const TextStyle(
                        color: PremiumGlassmorphicTheme.textPrimary,
                        fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedRole = value!;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please select your role';
            }
            return null;
          },
        ),
        
        const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
        
        // License Number (for medical professionals)
        if (_selectedRole == 'Doctor' || _selectedRole == 'MR') ...[
          TextFormField(
            controller: _licenseController,
            decoration: PremiumGlassmorphicTheme.getInputDecoration(
              hintText: 'Professional License Number',
              prefixIcon: Icons.card_membership,
            ),
            style: const TextStyle(
              color: PremiumGlassmorphicTheme.textPrimary,
              fontSize: PremiumGlassmorphicTheme.fontSizeMd,
            ),
            validator: (value) {
              if (_selectedRole == 'Doctor' || _selectedRole == 'MR') {
                if (value == null || value.isEmpty) {
                  return 'License number is required for medical professionals';
                }
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildSecuritySection() {
    return Column(
      children: [
        // Password
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: PremiumGlassmorphicTheme.getInputDecoration(
            hintText: 'Password',
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
              return 'Please enter a password';
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
        
        // Confirm Password
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          decoration: PremiumGlassmorphicTheme.getInputDecoration(
            hintText: 'Confirm Password',
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
          ),
          style: const TextStyle(
            color: PremiumGlassmorphicTheme.textPrimary,
            fontSize: PremiumGlassmorphicTheme.fontSizeMd,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            }
// if (value != _passwordController.text) { // TODO: Move to environment variables
              return 'Passwords do not match';
            }
            return null;
          },
        ),
        
        // Password Requirements
        const SizedBox(height: PremiumGlassmorphicTheme.spacingSm),
        
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
              const SizedBox(height: PremiumGlassmorphicTheme.spacingXs),
// _buildPasswordRequirement('At least 8 characters', _passwordController.text.length >= 8), // TODO: Move to environment variables
              _buildPasswordRequirement('One uppercase letter', _passwordController.text.contains(RegExp(r'[A-Z]'))),
              _buildPasswordRequirement('One lowercase letter', _passwordController.text.contains(RegExp(r'[a-z]'))),
              _buildPasswordRequirement('One number', _passwordController.text.contains(RegExp(r'\d'))),
              _buildPasswordRequirement('One special character', _passwordController.text.contains(RegExp(r'[@$!%*?&]'))),
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

  Widget _buildTermsSection() {
    return Column(
      children: [
        // Terms and Conditions
        Row(
          children: [
            Checkbox(
              value: _agreeToTerms,
              onChanged: (value) {
                setState(() {
                  _agreeToTerms = value ?? false;
                });
              },
              activeColor: PremiumGlassmorphicTheme.indigo500,
            ),
            const SizedBox(width: PremiumGlassmorphicTheme.spacingSm),
            const Expanded(
              child: Text(
                'I agree to the Terms of Service',
                style: TextStyle(
                  color: PremiumGlassmorphicTheme.textSecondary,
                  fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: PremiumGlassmorphicTheme.spacingSm),
        
        // Privacy Policy
        Row(
          children: [
            Checkbox(
              value: _agreeToPrivacy,
              onChanged: (value) {
                setState(() {
                  _agreeToPrivacy = value ?? false;
                });
              },
              activeColor: PremiumGlassmorphicTheme.indigo500,
            ),
            const SizedBox(width: PremiumGlassmorphicTheme.spacingSm),
            const Expanded(
              child: Text(
                'I agree to the Privacy Policy',
                style: TextStyle(
                  color: PremiumGlassmorphicTheme.textSecondary,
                  fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: PremiumGlassmorphicTheme.spacingSm),
        
        // Terms Links
        Row(
          children: [
            const Text(
              'Read our',
              style: TextStyle(
                color: PremiumGlassmorphicTheme.textTertiary,
                fontSize: PremiumGlassmorphicTheme.fontSizeSm,
              ),
            ),
            const SizedBox(width: PremiumGlassmorphicTheme.spacingXs),
            TextButton(
              onPressed: () {
                
              },
              child: const Text(
                'Terms of Service',
                style: TextStyle(
                  color: PremiumGlassmorphicTheme.indigo500,
                  fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Text(
              ' and ',
              style: TextStyle(
                color: PremiumGlassmorphicTheme.textTertiary,
                fontSize: PremiumGlassmorphicTheme.fontSizeSm,
              ),
            ),
            TextButton(
              onPressed: () {
                
              },
              child: const Text(
                'Privacy Policy',
                style: TextStyle(
                  color: PremiumGlassmorphicTheme.indigo500,
                  fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  IconData _getRoleIcon(String iconName) {
    switch (iconName) {
      case 'local_hospital':
        return Icons.local_hospital;
      case 'directions_walk':
        return Icons.directions_walk;
      case 'inventory':
        return Icons.inventory;
      case 'store':
        return Icons.store;
      case 'account_balance':
        return Icons.account_balance;
      case 'admin_panel_settings':
        return Icons.admin_panel_settings;
      default:
        return Icons.work;
    }
  }

  void _handleRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      final userData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'password': _passwordController.text,
        'role': _selectedRole,
        'licenseNumber': _licenseController.text.trim(),
        'agreeToTerms': _agreeToTerms,
        'agreeToPrivacy': _agreeToPrivacy,
        'createdAt': DateTime.now().toIso8601String(),
      };
      
      widget.onRegister(userData);
    }
  }
}

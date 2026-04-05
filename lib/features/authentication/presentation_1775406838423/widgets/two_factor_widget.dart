import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/premium_glassmorphic_theme.dart';
import '../providers/enhanced_auth_provider.dart';

class TwoFactorWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(bool) onCodeVerified;

  const TwoFactorWidget({
    Key? key,
    required this.controller,
    required this.onCodeVerified,
  }) : super(key: key);

  @override
  State<TwoFactorWidget> createState() => _TwoFactorWidgetState();
}

class _TwoFactorWidgetState extends State<TwoFactorWidget> {
  final List<TextEditingController> _codeControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Set up focus navigation
    for (int i = 0; i < 6; i++) {
      _codeControllers[i].addListener(() {
        if (_codeControllers[i].text.length == 1 && i < 5) {
          _focusNodes[i + 1].requestFocus();
        }
        if (_codeControllers[i].text.isEmpty && i > 0) {
          _focusNodes[i - 1].requestFocus();
        }
        _checkCodeComplete();
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _checkCodeComplete() {
    final code = _codeControllers.map((c) => c.text).join();
    if (code.length == 6) {
      _verifyCode(code);
    }
  }

  Future<void> _verifyCode(String code) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<EnhancedAuthProvider>(context, listen: false);
// final isValid = await authProvider.verifyTwoFactorCode('stored_secret', code); // TODO: Move to environment variables
      
      widget.onCodeVerified(isValid);
      
      if (!isValid) {
        setState(() {
          _errorMessage = 'Invalid verification code. Please try again.';
        });
        _clearCode();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Verification failed. Please try again.';
      });
      _clearCode();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearCode() {
    for (var controller in _codeControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.verified_user,
                color: PremiumGlassmorphicTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Two-Factor Authentication',
                style: TextStyle(
                  color: PremiumGlassmorphicTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Description
          Text(
            'Enter the 6-digit verification code from your authenticator app',
            style: TextStyle(
              color: PremiumGlassmorphicTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Code input fields
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              return SizedBox(
                width: 45,
                height: 55,
                child: TextField(
                  controller: _codeControllers[index],
                  focusNode: _focusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: PremiumGlassmorphicTheme.textPrimary,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: PremiumGlassmorphicTheme.primaryColor,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                  ),
                  onChanged: (value) {
                    if (value.length == 1 && index < 5) {
                      _focusNodes[index + 1].requestFocus();
                    }
                  },
                ),
              );
            }),
          ),
          
          const SizedBox(height: 20),
          
          // Error message
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.red.withOpacity(0.1),
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 20),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _clearCode,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: PremiumGlassmorphicTheme.textSecondary.withOpacity(0.5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Clear',
                    style: TextStyle(
                      color: PremiumGlassmorphicTheme.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Consumer<EnhancedAuthProvider>(
                  builder: (context, authProvider, child) {
                    return ElevatedButton(
                      onPressed: _isLoading ? null : () {
                        final code = _codeControllers.map((c) => c.text).join();
                        if (code.length == 6) {
                          _verifyCode(code);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PremiumGlassmorphicTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text('Verifying...'),
                              ],
                            )
                          : Text(
                              'Verify Code',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Help text
          Center(
            child: TextButton(
              onPressed: () {
                _showHelpDialog(context);
              },
              child: Text(
                'Need help with 2FA?',
                style: TextStyle(
                  color: PremiumGlassmorphicTheme.primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Two-Factor Authentication Help',
          style: TextStyle(
            color: PremiumGlassmorphicTheme.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What is 2FA?',
              style: TextStyle(
                color: PremiumGlassmorphicTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Two-factor authentication adds an extra layer of security to your account by requiring a verification code in addition to your password.',
              style: TextStyle(
                color: PremiumGlassmorphicTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'How to get your code:',
              style: TextStyle(
                color: PremiumGlassmorphicTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '1. Open your authenticator app (Google Authenticator, Authy, etc.)\n'
              '2. Find the entry for VedantaTrade\n'
              '3. Enter the 6-digit code shown in the app',
              style: TextStyle(
                color: PremiumGlassmorphicTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it',
              style: TextStyle(
                color: PremiumGlassmorphicTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TwoFactorSetupWidget extends StatefulWidget {
  final Function(String) onSetupComplete;
  final VoidCallback onSkip;

  const TwoFactorSetupWidget({
    Key? key,
    required this.onSetupComplete,
    required this.onSkip,
  }) : super(key: key);

  @override
  State<TwoFactorSetupWidget> createState() => _TwoFactorSetupWidgetState();
}

class _TwoFactorSetupWidgetState extends State<TwoFactorSetupWidget> {
  bool _isLoading = false;
  String? _qrCodeData;
  String? _secretKey;

  @override
  void initState() {
    super.initState();
    _generateTwoFactorSecret();
  }

  Future<void> _generateTwoFactorSecret() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<EnhancedAuthProvider>(context, listen: false);
// final secret = await authProvider.setupTwoFactorAuthentication(); // TODO: Move to environment variables
      
      setState(() {
// _secretKey = secret; // TODO: Move to environment variables
        _qrCodeData = 'otpauth://totp/VedantaTrade:user@example.com?secret=$secret&issuer=VedantaTrade';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to setup 2FA: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.security,
                color: PremiumGlassmorphicTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Setup Two-Factor Authentication',
                style: TextStyle(
                  color: PremiumGlassmorphicTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Description
          Text(
            'Add an extra layer of security to your account with two-factor authentication.',
            style: TextStyle(
              color: PremiumGlassmorphicTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          
          const SizedBox(height: 24),
          
          if (_isLoading)
            Center(
              child: Column(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      PremiumGlassmorphicTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Generating secret key...',
                    style: TextStyle(
                      color: PremiumGlassmorphicTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else if (_qrCodeData != null)
            Column(
              children: [
                // QR Code placeholder (in a real app, you'd use a QR code library)
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    border: Border.all(
                      color: PremiumGlassmorphicTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_2,
                        size: 80,
                        color: PremiumGlassmorphicTheme.primaryColor,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'QR Code',
                        style: TextStyle(
                          color: PremiumGlassmorphicTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Secret key
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white.withOpacity(0.05),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Secret Key: $_secretKey',
                          style: TextStyle(
                            color: PremiumGlassmorphicTheme.textSecondary,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.copy,
                          color: PremiumGlassmorphicTheme.primaryColor,
                        ),
                        onPressed: () {
                          // Copy to clipboard
                          Clipboard.setData(ClipboardData(text: _secretKey!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Secret key copied to clipboard'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Instructions
                Text(
                  '1. Scan the QR code with your authenticator app\n'
                  '2. Or manually enter the secret key\n'
                  '3. Enter the verification code to complete setup',
                  style: TextStyle(
                    color: PremiumGlassmorphicTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.onSkip,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: PremiumGlassmorphicTheme.textSecondary.withOpacity(0.5),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Skip for now',
                          style: TextStyle(
                            color: PremiumGlassmorphicTheme.textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
// if (_secretKey != null) { // TODO: Move to environment variables
                            widget.onSetupComplete(_secretKey!);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PremiumGlassmorphicTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'I\'ve Added the Account',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}

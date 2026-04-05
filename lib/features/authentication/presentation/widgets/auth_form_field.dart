import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Authentication Form Field
/// Custom form field with enhanced validation and styling
class AuthFormField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Function(String)? onFieldSubmitted;
  final Function(String)? onChanged;
  final bool enabled;
  final int? maxLines;
  final String? errorText;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final String? helperText;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  const AuthFormField({
    Key? key,
    required this.controller,
    required this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.onFieldSubmitted,
    this.onChanged,
    this.enabled = true,
    this.maxLines = 1,
    this.errorText,
    this.focusNode,
    this.textInputAction,
    this.autofocus = false,
    this.helperText,
    this.maxLength,
    this.inputFormatters,
  }) : super(key: key);

  @override
  State<AuthFormField> createState() => _AuthFormFieldState();
}

class _AuthFormFieldState extends State<AuthFormField> {
  bool _isFocused = false;
  bool _showPassword = false;
  FocusNode? _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    
    if (widget.obscureText) {
      _showPassword = false;
    }
    
    _focusNode!.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode?.removeListener(_onFocusChange);
    _focusNode?.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode!.hasFocus;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorText = widget.errorText ?? 
                   (_focusNode!.hasFocus ? null : widget.validator?.call(widget.controller.text));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: _isFocused ? theme.primaryColor : theme.hintColor,
              ),
            ),
          ),
        
        // Text Field
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: errorText != null 
                  ? Colors.red.shade400 
                  : (_isFocused ? theme.primaryColor : theme.dividerColor),
              width: 1.5,
            ),
            boxShadow: [
              if (_isFocused)
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.2),
                  blurRadius: 8.0,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText ? !_showPassword : false,
            enabled: widget.enabled,
            maxLines: widget.maxLines,
            textInputAction: widget.textInputAction,
            autofocus: widget.autofocus,
            maxLength: widget.maxLength,
            inputFormatters: widget.inputFormatters,
            validator: widget.validator,
            onFieldSubmitted: widget.onFieldSubmitted,
            onChanged: widget.onChanged,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.textTheme.bodyLarge?.color,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Icon(
                        widget.prefixIcon,
                        size: 20,
                        color: theme.hintColor,
                      ),
                    )
                  : null,
              suffixIcon: widget.obscureText
                  ? IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility_off : Icons.visibility,
                        color: theme.hintColor,
                        size: 20,
                      ),
                      onPressed: _togglePasswordVisibility,
                    )
                  : widget.suffixIcon,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: EdgeInsets.fromLTRB(
                widget.prefixIcon != null ? 48.0 : 16.0,
                16.0,
                16.0,
                widget.obscureText ? 48.0 : 16.0,
              ),
              hintStyle: theme.inputDecorationTheme?.hintStyle?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 4.0),
        
        // Error Text
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 4.0),
            child: Text(
              errorText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.red.shade600,
              ),
            ),
          ),
        
        // Helper Text
        if (widget.helperText != null)
          Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 4.0),
            child: Text(
              widget.helperText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ),
      ],
    );
  }
}

/// Secure Auth Form Field
/// Enhanced form field with security features
class SecureAuthFormField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final Function(String)? onFieldSubmitted;
  final Function(String)? onChanged;
  final bool enabled;
  final String? errorText;
  final FocusNode? focusNode;
  final bool showStrengthIndicator;
  final bool showVisibilityToggle;
  final String? helperText;

  const SecureAuthFormField({
    Key? key,
    required this.controller,
    required this.label,
    this.hintText,
    this.prefixIcon,
    this.validator,
    this.onFieldSubmitted,
    this.onChanged,
    this.enabled = true,
    this.errorText,
    this.focusNode,
    this.showStrengthIndicator = false,
    this.showVisibilityToggle = true,
    this.helperText,
  }) : super(key: key);

  @override
  State<SecureAuthFormField> createState() => _SecureAuthFormFieldState();
}

class _SecureAuthFormFieldState extends State<SecureAuthFormField> {
  bool _isFocused = false;
  bool _showPassword = false;
  bool _showStrength = false;
  String? _passwordStrength;
  FocusNode? _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode!.addListener(_onFocusChange);
    
    if (widget.showStrengthIndicator) {
      widget.controller.addListener(_onPasswordChanged);
    }
  }

  @override
  void dispose() {
    _focusNode?.removeListener(_onFocusChange);
    _focusNode?.dispose();
    if (widget.showStrengthIndicator) {
      widget.controller.removeListener(_onPasswordChanged);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode!.hasFocus;
      if (_isFocused && widget.showStrengthIndicator) {
        _showStrength = true;
      }
    });
  }

  void _onPasswordChanged() {
    if (mounted && widget.showStrengthIndicator) {
      _calculatePasswordStrength();
    }
  }

  void _calculatePasswordStrength() {
// final password = widget.controller.text; // TODO: Move to environment variables
    if (password.isEmpty) {
      setState(() {
// _passwordStrength = null; // TODO: Move to environment variables
      });
      return;
    }

    // Simple password strength calculation
    int strength = 0;
    String strengthText = 'Weak';
    Color strengthColor = Colors.red;

// if (password.length >= 8) strength++; // TODO: Move to environment variables
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    if (strength <= 2) {
      strengthText = 'Weak';
      strengthColor = Colors.red;
    } else if (strength <= 3) {
      strengthText = 'Fair';
      strengthColor = Colors.orange;
    } else if (strength <= 4) {
      strengthText = 'Good';
      strengthColor = Colors.yellow.shade700;
    } else {
      strengthText = 'Strong';
      strengthColor = Colors.green;
    }

    setState(() {
// _passwordStrength = strengthText; // TODO: Move to environment variables
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  Color _getStrengthColor(String strength) {
    switch (strength.toLowerCase()) {
      case 'weak':
        return Colors.red;
      case 'fair':
        return Colors.orange;
      case 'good':
        return Colors.yellow.shade700;
      case 'strong':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorText = widget.errorText ?? 
                   (_focusNode!.hasFocus ? null : widget.validator?.call(widget.controller.text));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: _isFocused ? theme.primaryColor : theme.hintColor,
              ),
            ),
          ),
        
        // Text Field
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: errorText != null 
                  ? Colors.red.shade400 
                  : (_isFocused ? theme.primaryColor : theme.dividerColor),
              width: 1.5,
            ),
            boxShadow: [
              if (_isFocused)
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.2),
                  blurRadius: 8.0,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.showVisibilityToggle ? !_showPassword : true,
            enabled: widget.enabled,
            validator: widget.validator,
            onFieldSubmitted: widget.onFieldSubmitted,
            onChanged: widget.onChanged,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.textTheme.bodyLarge?.color,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Icon(
                        widget.prefixIcon,
                        size: 20,
                        color: theme.hintColor,
                      ),
                    )
                  : null,
              suffixIcon: widget.showVisibilityToggle
                  ? IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility_off : Icons.visibility,
                        color: theme.hintColor,
                        size: 20,
                      ),
                      onPressed: _togglePasswordVisibility,
                    )
                  : null,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: EdgeInsets.fromLTRB(
                widget.prefixIcon != null ? 48.0 : 16.0,
                16.0,
                16.0,
                widget.showVisibilityToggle ? 48.0 : 16.0,
              ),
              hintStyle: theme.inputDecorationTheme?.hintStyle?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 4.0),
        
        // Error Text
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 4.0),
            child: Text(
              errorText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.red.shade600,
              ),
            ),
          ),
        
        // Password Strength Indicator
// if (widget.showStrengthIndicator && _showStrength && _passwordStrength != null) // TODO: Move to environment variables
          Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Password Strength: ',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                    Text(
                      _passwordStrength!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getStrengthColor(_passwordStrength!),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),
                // Strength Bar
                Container(
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                  child: FractionallySizedBox(
                    widthFactor: _getStrengthPercentage(_passwordStrength!),
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getStrengthColor(_passwordStrength!),
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        // Helper Text
        if (widget.helperText != null)
          Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 4.0),
            child: Text(
              widget.helperText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ),
      ],
    );
  }

  double _getStrengthPercentage(String strength) {
    switch (strength.toLowerCase()) {
      case 'weak':
        return 0.25;
      case 'fair':
        return 0.5;
      case 'good':
        return 0.75;
      case 'strong':
        return 1.0;
      default:
        return 0.0;
    }
  }
}

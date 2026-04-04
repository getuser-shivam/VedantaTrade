import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import '../theme/enhanced_theme.dart';

/// Enhanced Accessibility System for VedantaTrade
/// Provides comprehensive accessibility features and support

class EnhancedAccessibility {
  // Accessibility Settings
  static bool _highContrast = false;
  static bool _largeText = false;
  static bool _reducedMotion = false;
  static bool _screenReader = false;
  static double _textScaleFactor = 1.0;
  
  // Getters
  static bool get highContrast => _highContrast;
  static bool get largeText => _largeText;
  static bool get reducedMotion => _reducedMotion;
  static bool get screenReader => _screenReader;
  static double get textScaleFactor => _textScaleFactor;
  
  // Setters
  static set highContrast(bool value) => _highContrast = value;
  static set largeText(bool value) => _largeText = value;
  static set reducedMotion(bool value) => _reducedMotion = value;
  static set screenReader(bool value) => _screenReader = value;
  static set textScaleFactor(double value) => _textScaleFactor = value.clamp(0.8, 3.0);
  
  // Check if accessibility features are enabled
  static bool get hasAccessibilityFeatures {
    return _highContrast || _largeText || _reducedMotion || _screenReader;
  }
  
  // Get accessible colors
  static Color getAccessibleColor(Color color, {bool isBackground = false}) {
    if (_highContrast) {
      if (isBackground) {
        return color == Colors.white ? Colors.black : Colors.white;
      } else {
        return color == Colors.black ? Colors.white : Colors.black;
      }
    }
    return color;
  }
  
  // Get accessible text style
  static TextStyle getAccessibleTextStyle(TextStyle baseStyle) {
    return baseStyle.copyWith(
      fontSize: _largeText ? (baseStyle.fontSize ?? 14) * 1.2 : baseStyle.fontSize,
      fontWeight: _highContrast ? FontWeight.bold : baseStyle.fontWeight,
      letterSpacing: _highContrast ? 1.2 : baseStyle.letterSpacing,
    );
  }
  
  // Announce to screen reader
  static void announce(String message, {bool assertive = false}) {
    if (_screenReader) {
      // Use Semantics service for screen reader announcements
      SemanticsService.announce(message, assertive ? Assertiveness.assertive : Assertiveness.polite);
    }
  }
  
  // Haptic feedback
  static void hapticFeedback({HapticType type = HapticType.light}) {
    if (!_reducedMotion) {
      switch (type) {
        case HapticType.light:
          HapticFeedback.lightImpact();
          break;
        case HapticType.medium:
          HapticFeedback.mediumImpact();
          break;
        case HapticType.heavy:
          HapticFeedback.heavyImpact();
          break;
        case HapticType.selection:
          HapticFeedback.selectionClick();
          break;
        case HapticType.success:
          HapticFeedback.selectionClick();
          break;
        case HapticType.error:
          HapticFeedback.heavyImpact();
          break;
      }
    }
  }
}

// Accessible Widget Wrapper
class AccessibleWidget extends StatelessWidget {
  final Widget child;
  final String? semanticLabel;
  final String? semanticHint;
  final bool? semanticEnabled;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool focusable;
  final bool excludeFromSemantics;
  final Map<String, String>? semanticProperties;

  const AccessibleWidget({
    Key? key,
    required this.child,
    this.semanticLabel,
    this.semanticHint,
    this.semanticEnabled,
    this.onTap,
    this.onLongPress,
    this.focusable = true,
    this.excludeFromSemantics = false,
    this.semanticProperties,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget widget = child;
    
    // Add semantic annotations
    if (!excludeFromSemantics) {
      widget = Semantics(
        label: semanticLabel,
        hint: semanticHint,
        enabled: semanticEnabled,
        button: onTap != null,
        link: onTap != null,
        focused: focusable,
        properties: semanticProperties,
        child: widget,
      );
    }
    
    // Add focus handling
    if (focusable) {
      widget = Focus(
        canRequestFocus: true,
        child: widget,
      );
    }
    
    // Add gesture handling
    if (onTap != null || onLongPress != null) {
      widget = GestureDetector(
        onTap: () {
          EnhancedAccessibility.hapticFeedback(type: HapticType.selection);
          onTap?.call();
        },
        onLongPress: () {
          EnhancedAccessibility.hapticFeedback(type: HapticType.medium);
          onLongPress?.call();
        },
        child: widget,
      );
    }
    
    return widget;
  }
}

// Accessible Button
class AccessibleButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final Widget? icon;
  final String? semanticLabel;
  final String? semanticHint;
  final bool isImportant;
  final bool isDestructive;

  const AccessibleButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.semanticLabel,
    this.semanticHint,
    this.isImportant = false,
    this.isDestructive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getButtonColors(theme);
    
    Widget button = ElevatedButton(
      onPressed: isLoading ? null : () {
        EnhancedAccessibility.hapticFeedback(
          type: isDestructive ? HapticType.error : HapticType.light,
        );
        onPressed?.call();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.backgroundColor,
        foregroundColor: colors.foregroundColor,
        disabledBackgroundColor: colors.disabledBackgroundColor,
        disabledForegroundColor: colors.disabledForegroundColor,
        elevation: 2,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: _buildButtonContent(theme),
    );
    
    // Add accessibility
    return AccessibleWidget(
      semanticLabel: semanticLabel ?? text,
      semanticHint: semanticHint ?? (isDestructive ? 'Destructive action' : 'Button'),
      onTap: onPressed,
      excludeFromSemantics: false,
      child: button,
    );
  }

  Widget _buildButtonContent(ThemeData theme) {
    if (isLoading) {
      return SizedBox(
        height: _getIconSize(),
        width: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getButtonColors(theme).foregroundColor,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: _getIconSize(),
            color: _getButtonColors(theme).foregroundColor,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: _getTextStyle(theme),
          ),
        ],
      );
    }

    return Text(
      text,
      style: _getTextStyle(theme),
    );
  }

  ButtonColors _getButtonColors(ThemeData theme) {
    switch (type) {
      case ButtonType.primary:
        return ButtonColors(
          backgroundColor: EnhancedAccessibility.getAccessibleColor(theme.colorScheme.primary),
          foregroundColor: Colors.white,
          disabledBackgroundColor: theme.colorScheme.primary.withOpacity(0.5),
          disabledForegroundColor: Colors.white.withOpacity(0.7),
        );
      case ButtonType.secondary:
        return ButtonColors(
          backgroundColor: EnhancedAccessibility.getAccessibleColor(theme.colorScheme.secondary),
          foregroundColor: Colors.white,
          disabledBackgroundColor: theme.colorScheme.secondary.withOpacity(0.5),
          disabledForegroundColor: Colors.white.withOpacity(0.7),
        );
      case ButtonType.success:
        return ButtonColors(
          backgroundColor: EnhancedAccessibility.getAccessibleColor(EnhancedTheme.successGreen),
          foregroundColor: Colors.white,
          disabledBackgroundColor: EnhancedTheme.successGreen.withOpacity(0.5),
          disabledForegroundColor: Colors.white.withOpacity(0.7),
        );
      case ButtonType.warning:
        return ButtonColors(
          backgroundColor: EnhancedAccessibility.getAccessibleColor(EnhancedTheme.warningAmber),
          foregroundColor: Colors.white,
          disabledBackgroundColor: EnhancedTheme.warningAmber.withOpacity(0.5),
          disabledForegroundColor: Colors.white.withOpacity(0.7),
        );
      case ButtonType.error:
        return ButtonColors(
          backgroundColor: EnhancedAccessibility.getAccessibleColor(EnhancedTheme.errorRed),
          foregroundColor: Colors.white,
          disabledBackgroundColor: EnhancedTheme.errorRed.withOpacity(0.5),
          disabledForegroundColor: Colors.white.withOpacity(0.7),
        );
      case ButtonType.outlined:
        return ButtonColors(
          backgroundColor: Colors.transparent,
          foregroundColor: EnhancedAccessibility.getAccessibleColor(theme.colorScheme.primary),
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: theme.colorScheme.primary.withOpacity(0.5),
        );
      case ButtonType.text:
        return ButtonColors(
          backgroundColor: Colors.transparent,
          foregroundColor: EnhancedAccessibility.getAccessibleColor(theme.colorScheme.primary),
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: theme.colorScheme.primary.withOpacity(0.5),
        );
    }
  }

  TextStyle _getTextStyle(ThemeData theme) {
    final baseStyle = theme.textTheme.labelLarge ?? const TextStyle(fontSize: 14);
    return EnhancedAccessibility.getAccessibleTextStyle(baseStyle).copyWith(
      fontSize: _getFontSize(),
      fontWeight: _getFontWeight(),
      color: _getButtonColors(theme).foregroundColor,
    );
  }

  double _getFontSize() {
    switch (size) {
      case ButtonSize.small:
        return 12;
      case ButtonSize.medium:
        return 14;
      case ButtonSize.large:
        return 16;
    }
  }

  FontWeight _getFontWeight() {
    switch (size) {
      case ButtonSize.small:
        return FontWeight.w500;
      case ButtonSize.medium:
        return FontWeight.w600;
      case ButtonSize.large:
        return FontWeight.w600;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 18;
      case ButtonSize.large:
        return 20;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }
}

// Accessible Input Field
class AccessibleInputField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final String? helperText;
  final TextEditingController? controller;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final bool showCounter;
  final FocusNode? focusNode;
  final AutovalidateMode autovalidateMode;
  final String? semanticLabel;
  final String? semanticHint;
  final bool isRequired;
  final String? accessibilityHint;
  final ScrollViewKeyboardDismissBehavior? keyboardDismissBehavior;

  const AccessibleInputField({
    Key? key,
    this.label,
    this.hint,
    this.errorText,
    this.helperText,
    this.controller,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.showCounter = false,
    this.focusNode,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.semanticLabel,
    this.semanticHint,
    this.isRequired = false,
    this.accessibilityHint,
    this.keyboardDismissBehavior,
  }) : super(key: key);

  @override
  State<AccessibleInputField> createState() => _AccessibleInputFieldState();
}

class _AccessibleInputFieldState extends State<AccessibleInputField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    
    if (_isFocused) {
      EnhancedAccessibility.announce(
        widget.accessibilityHint ?? 'Editing ${widget.label ?? 'field'}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Row(
            children: [
              Text(
                widget.label!,
                style: EnhancedAccessibility.getAccessibleTextStyle(
                  theme.textTheme.labelMedium ?? const TextStyle(fontSize: 14),
                ).copyWith(
                  color: widget.enabled
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (widget.isRequired) ...[
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: EnhancedAccessibility.getAccessibleTextStyle(
                    theme.textTheme.labelMedium ?? const TextStyle(fontSize: 14),
                  ).copyWith(
                    color: EnhancedTheme.errorRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
        ],
        AccessibleWidget(
          semanticLabel: widget.semanticLabel ?? widget.label,
          semanticHint: widget.semanticHint ?? widget.hint,
          focusable: true,
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.obscureText,
            readOnly: widget.readOnly,
            enabled: widget.enabled,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            onChanged: (value) {
              if (widget.onChanged != null) {
                widget.onChanged!(value);
              }
              // Announce character count for screen readers
              if (EnhancedAccessibility.screenReader && widget.maxLength != null) {
                EnhancedAccessibility.announce(
                  '${value.length} of ${widget.maxLength} characters',
                );
              }
            },
            onFieldSubmitted: widget.onSubmitted,
            validator: widget.validator,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            focusNode: _focusNode,
            autovalidateMode: widget.autovalidateMode,
            keyboardDismissBehavior: widget.keyboardDismissBehavior ?? ScrollViewKeyboardDismissBehavior.manual,
            decoration: InputDecoration(
              hintText: widget.hint,
              errorText: widget.errorText,
              helperText: widget.helperText,
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.suffixIcon,
              counterText: widget.showCounter && widget.maxLength != null
                  ? '${widget.controller?.text.length ?? 0}/${widget.maxLength}'
                  : null,
              filled: true,
              fillColor: widget.enabled
                  ? theme.colorScheme.surfaceVariant
                  : theme.colorScheme.surfaceVariant.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: EnhancedAccessibility.getAccessibleColor(theme.colorScheme.outline),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: EnhancedAccessibility.getAccessibleColor(theme.colorScheme.outline),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: EnhancedAccessibility.getAccessibleColor(theme.colorScheme.primary),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: EnhancedAccessibility.getAccessibleColor(theme.colorScheme.error),
                  width: 2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: EnhancedAccessibility.getAccessibleColor(theme.colorScheme.error),
                  width: 2,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.5),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            style: EnhancedAccessibility.getAccessibleTextStyle(
              theme.textTheme.bodyLarge ?? const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}

// Accessible Card
class AccessibleCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? elevation;
  final double? borderRadius;
  final VoidCallback? onTap;
  final bool isClickable;
  final String? semanticLabel;
  final String? semanticHint;
  final bool isImportant;
  final bool isInteractive;

  const AccessibleCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.elevation,
    this.borderRadius,
    this.onTap,
    this.isClickable = false,
    this.semanticLabel,
    this.semanticHint,
    this.isImportant = false,
    this.isInteractive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget cardChild = Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );

    if (isClickable || onTap != null) {
      cardChild = InkWell(
        onTap: () {
          EnhancedAccessibility.hapticFeedback(type: HapticType.selection);
          onTap?.call();
        },
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
        child: cardChild,
      );
    }

    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
        border: borderColor != null
            ? Border.all(color: borderColor!)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 2),
            blurRadius: elevation ?? 8,
          ),
        ],
      ),
      child: cardChild,
    );

    return AccessibleWidget(
      semanticLabel: semanticLabel,
      semanticHint: semanticHint ?? (isImportant ? 'Important information' : 'Card'),
      onTap: onTap,
      excludeFromSemantics: false,
      child: card,
    );
  }
}

// Accessibility Settings Panel
class AccessibilitySettings extends StatefulWidget {
  final VoidCallback? onSettingsChanged;

  const AccessibilitySettings({
    Key? key,
    this.onSettingsChanged,
  }) : super(key: key);

  @override
  State<AccessibilitySettings> createState() => _AccessibilitySettingsState();
}

class _AccessibilitySettingsState extends State<AccessibilitySettings> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // High Contrast
        SwitchListTile(
          title: Text(
            'High Contrast',
            style: EnhancedAccessibility.getAccessibleTextStyle(theme.textTheme.titleMedium),
          ),
          subtitle: Text(
            'Increase contrast for better visibility',
            style: EnhancedAccessibility.getAccessibleTextStyle(theme.textTheme.bodyMedium),
          ),
          value: EnhancedAccessibility.highContrast,
          onChanged: (value) {
            setState(() {
              EnhancedAccessibility.highContrast = value;
            });
            widget.onSettingsChanged?.call();
            EnhancedAccessibility.announce(
              value ? 'High contrast enabled' : 'High contrast disabled',
            );
          },
        ),
        
        // Large Text
        SwitchListTile(
          title: Text(
            'Large Text',
            style: EnhancedAccessibility.getAccessibleTextStyle(theme.textTheme.titleMedium),
          ),
          subtitle: Text(
            'Increase text size for better readability',
            style: EnhancedAccessibility.getAccessibleTextStyle(theme.textTheme.bodyMedium),
          ),
          value: EnhancedAccessibility.largeText,
          onChanged: (value) {
            setState(() {
              EnhancedAccessibility.largeText = value;
            });
            widget.onSettingsChanged?.call();
            EnhancedAccessibility.announce(
              value ? 'Large text enabled' : 'Large text disabled',
            );
          },
        ),
        
        // Reduced Motion
        SwitchListTile(
          title: Text(
            'Reduced Motion',
            style: EnhancedAccessibility.getAccessibleTextStyle(theme.textTheme.titleMedium),
          ),
          subtitle: Text(
            'Reduce animations and transitions',
            style: EnhancedAccessibility.getAccessibleTextStyle(theme.textTheme.bodyMedium),
          ),
          value: EnhancedAccessibility.reducedMotion,
          onChanged: (value) {
            setState(() {
              EnhancedAccessibility.reducedMotion = value;
            });
            widget.onSettingsChanged?.call();
            EnhancedAccessibility.announce(
              value ? 'Reduced motion enabled' : 'Reduced motion disabled',
            );
          },
        ),
        
        // Screen Reader
        SwitchListTile(
          title: Text(
            'Screen Reader Support',
            style: EnhancedAccessibility.getAccessibleTextStyle(theme.textTheme.titleMedium),
          ),
          subtitle: Text(
            'Enable screen reader announcements',
            style: EnhancedAccessibility.getAccessibleTextStyle(theme.textTheme.bodyMedium),
          ),
          value: EnhancedAccessibility.screenReader,
          onChanged: (value) {
            setState(() {
              EnhancedAccessibility.screenReader = value;
            });
            widget.onSettingsChanged?.call();
            EnhancedAccessibility.announce(
              value ? 'Screen reader support enabled' : 'Screen reader support disabled',
            );
          },
        ),
        
        // Text Scale
        ListTile(
          title: Text(
            'Text Size',
            style: EnhancedAccessibility.getAccessibleTextStyle(theme.textTheme.titleMedium),
          ),
          subtitle: Text(
            'Adjust text scale factor',
            style: EnhancedAccessibility.getAccessibleTextStyle(theme.textTheme.bodyMedium),
          ),
          trailing: Text(
            '${(EnhancedAccessibility.textScaleFactor * 100).toInt()}%',
            style: EnhancedAccessibility.getAccessibleTextStyle(theme.textTheme.bodyMedium),
          ),
        ),
        
        Slider(
          value: EnhancedAccessibility.textScaleFactor,
          min: 0.8,
          max: 3.0,
          divisions: 22,
          label: '${(EnhancedAccessibility.textScaleFactor * 100).toInt()}%',
          onChanged: (value) {
            setState(() {
              EnhancedAccessibility.textScaleFactor = value;
            });
            widget.onSettingsChanged?.call();
            EnhancedAccessibility.announce(
              'Text size set to ${(value * 100).toInt()} percent',
            );
          },
        ),
      ],
    );
  }
}

// Enums and Helper Classes
enum ButtonType {
  primary,
  secondary,
  success,
  warning,
  error,
  outlined,
  text,
}

enum ButtonSize {
  small,
  medium,
  large,
}

enum HapticType {
  light,
  medium,
  heavy,
  selection,
  success,
  error,
}

class ButtonColors {
  final Color backgroundColor;
  final Color foregroundColor;
  final Color disabledBackgroundColor;
  final Color disabledForegroundColor;

  const ButtonColors({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.disabledBackgroundColor,
    required this.disabledForegroundColor,
  });
}

// Accessibility Extensions
extension AccessibilityExtension on Widget {
  Widget makeAccessible({
    String? semanticLabel,
    String? semanticHint,
    bool? semanticEnabled,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    bool focusable = true,
    bool excludeFromSemantics = false,
    Map<String, String>? semanticProperties,
  }) {
    return AccessibleWidget(
      semanticLabel: semanticLabel,
      semanticHint: semanticHint,
      semanticEnabled: semanticEnabled,
      onTap: onTap,
      onLongPress: onLongPress,
      focusable: focusable,
      excludeFromSemantics: excludeFromSemantics,
      semanticProperties: semanticProperties,
      child: this,
    );
  }
}

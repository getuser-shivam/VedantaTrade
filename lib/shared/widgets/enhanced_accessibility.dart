import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EnhancedAccessibility {
  static void announceForAccessibility(BuildContext context, String message) {
    // Announce message for screen readers
    SemanticsService.announce(message, TextDirection.ltr);
  }

  static bool isAccessibleMode(BuildContext context) {
    return MediaQuery.of(context).accessibleNavigation;
  }

  static void handleAccessibilityAction(BuildContext context, String action) {
    // Handle accessibility-specific actions
    switch (action) {
      case 'increment':
        _announceValueChange(context, 'Increased');
        break;
      case 'decrement':
        _announceValueChange(context, 'Decreased');
        break;
      case 'activate':
        _announceValueChange(context, 'Activated');
        break;
      case 'select':
        _announceValueChange(context, 'Selected');
        break;
    }
  }

  static void _announceValueChange(BuildContext context, String action) {
    announceForAccessibility(context, '$action');
  }

  static Widget makeAccessibleButton({
    required Widget child,
    required VoidCallback onPressed,
    String? semanticLabel,
    bool enabled = true,
    Key? key,
  }) {
    return Semantics(
      button: true,
      label: semanticLabel,
      enabled: enabled,
      child: ExcludeSemantics(
        child: ElevatedButton(
          key: key,
          onPressed: enabled ? onPressed : null,
          child: child,
        ),
      ),
    );
  }

  static Widget makeAccessibleTextField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool enabled = true,
    Key? key,
  }) {
    return Semantics(
      textField: true,
      label: label,
      child: ExcludeSemantics(
        child: TextFormField(
          key: key,
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            hintText: hintText,
            border: const OutlineInputBorder(),
          ),
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          enabled: enabled,
        ),
      ),
    );
  }

  static Widget makeAccessibleSlider({
    required double value,
    required ValueChanged<double> onChanged,
    required String label,
    double min = 0.0,
    double max = 100.0,
    int? divisions,
    Key? key,
  }) {
    return Semantics(
      slider: true,
      label: label,
      value: value,
      child: ExcludeSemantics(
        child: Slider(
          key: key,
          value: value,
          onChanged: onChanged,
          min: min,
          max: max,
          divisions: divisions,
        ),
      ),
    );
  }

  static Widget makeAccessibleSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
    required String label,
    Key? key,
  }) {
    return Semantics(
      switch: true,
      label: label,
      value: value,
      child: ExcludeSemantics(
        child: Switch(
          key: key,
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }

  static Widget makeAccessibleListTile({
    required Widget title,
    required Widget subtitle,
    required VoidCallback onTap,
    String? semanticLabel,
    bool enabled = true,
    Key? key,
  }) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: ListTile(
          key: key,
          title: title,
          subtitle: subtitle,
          onTap: enabled ? onTap : null,
          enabled: enabled,
        ),
      ),
    );
  }

  static void setupAccessibilityShortcuts(BuildContext context) {
    // Setup accessibility shortcuts
    FocusScope.of(context).shortcutManager.addAll([
      const SingleActivator(LogicalKeyboardKey.tab),
      const SingleActivator(LogicalKeyboardKey.enter),
      const SingleActivator(LogicalKeyboardKey.space),
    ]);
  }

  static void handleAccessibilityFocusChange(BuildContext context, FocusNode focusNode) {
    if (isAccessibleMode(context)) {
      announceForAccessibility(context, 'Focused on ${focusNode.debugLabel ?? 'element'}');
    }
  }

  static Widget makeAccessibleCard({
    required Widget child,
    String? semanticLabel,
    bool semanticContainer = true,
    Key? key,
  }) {
    return Semantics(
      container: semanticContainer,
      label: semanticLabel,
      child: Card(
        key: key,
        child: child,
      ),
    );
  }

  static void announcePageChange(BuildContext context, String pageName) {
    announceForAccessibility(context, 'Navigated to $pageName');
  }

  static void announceError(BuildContext context, String error) {
    announceForAccessibility(context, 'Error: $error');
  }

  static void announceSuccess(BuildContext context, String success) {
    announceForAccessibility(context, 'Success: $success');
  }
}

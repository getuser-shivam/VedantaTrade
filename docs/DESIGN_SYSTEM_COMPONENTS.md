# VedantaTrade Design System Components Library

## Overview

This document outlines the unified design system components library for VedantaTrade, consolidating existing components into a single, consistent, and accessible component library.

## Component Architecture

### Library Structure
```
lib/shared/design_system/
├── components/
│   ├── buttons/
│   │   ├── primary_button.dart
│   │   ├── secondary_button.dart
│   │   ├── outlined_button.dart
│   │   ├── text_button.dart
│   │   ├── icon_button.dart
│   │   └── floating_action_button.dart
│   ├── cards/
│   │   ├── base_card.dart
│   │   ├── elevated_card.dart
│   │   ├── interactive_card.dart
│   │   ├── selected_card.dart
│   │   └── glass_card.dart
│   ├── inputs/
│   │   ├── text_field.dart
│   │   ├── search_field.dart
│   │   ├── dropdown_field.dart
│   │   ├── date_field.dart
│   │   └── checkbox_field.dart
│   ├── navigation/
│   │   ├── navigation_bar.dart
│   │   ├── navigation_item.dart
│   │   ├── breadcrumb.dart
│   │   └── tab_bar.dart
│   ├── feedback/
│   │   ├── loading_indicator.dart
│   │   ├── progress_bar.dart
│   │   ├── toast_notification.dart
│   │   ├── alert_dialog.dart
│   │   └── snackbar.dart
│   ├── data_display/
│   │   ├── data_table.dart
│   │   ├── list_tile.dart
│   │   ├── chip.dart
│   │   ├── badge.dart
│   │   └── avatar.dart
│   ├── layout/
│   │   ├── container.dart
│   │   ├── section.dart
│   │   ├── divider.dart
│   │   └── spacer.dart
│   └── typography/
│       ├── heading.dart
│       ├── body_text.dart
│       ├── caption.dart
│       └── label.dart
├── theme/
│   ├── app_theme.dart
│   ├── color_palette.dart
│   ├── typography.dart
│   ├── spacing.dart
│   ├── shadows.dart
│   └── border_radius.dart
├── utilities/
│   ├── validators.dart
│   ├── formatters.dart
│   └── converters.dart
└── tokens/
    ├── color_tokens.dart
    ├── typography_tokens.dart
    ├── spacing_tokens.dart
    └── animation_tokens.dart
```

## Component Specifications

### Buttons

#### Primary Button
```dart
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? icon;
  final ButtonSize size;
  final String? semanticLabel;

  const PrimaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.size = ButtonSize.medium,
    this.semanticLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final designSystem = DesignSystem.of(context);

    return Semantics(
      button: true,
      label: semanticLabel ?? text,
      hint: isLoading ? 'Loading' : 'Double tap to activate',
      excludeSemantics: true,
      child: SizedBox(
        width: isFullWidth ? double.infinity : null,
        height: designSystem.spacing.buttonHeight(size),
        child: ElevatedButton(
          onPressed: isLoading ? null : () {
            HapticFeedback.lightImpact();
            onPressed?.call();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(designSystem.borderRadius.button),
            ),
            padding: designSystem.spacing.buttonPadding(size),
            textStyle: designSystem.typography.button(size),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : icon != null
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        icon,
                        const SizedBox(width: 8),
                        Text(text),
                      ],
                    )
                  : Text(text),
        ),
      ),
    );
  }
}

enum ButtonSize {
  small,
  medium,
  large,
}
```

#### Secondary Button
```dart
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? icon;
  final ButtonSize size;

  const SecondaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.size = ButtonSize.medium,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final designSystem = DesignSystem.of(context);

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: designSystem.spacing.buttonHeight(size),
      child: ElevatedButton(
        onPressed: isLoading ? null : () {
          HapticFeedback.lightImpact();
          onPressed?.call();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.secondary,
          foregroundColor: theme.colorScheme.onSecondary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(designSystem.borderRadius.button),
          ),
          padding: designSystem.spacing.buttonPadding(size),
          textStyle: designSystem.typography.button(size),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : icon != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      icon,
                      const SizedBox(width: 8),
                      Text(text),
                    ],
                  )
                : Text(text),
      ),
    );
  }
}
```

#### Outlined Button
```dart
class OutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? icon;
  final ButtonSize size;

  const OutlinedButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.size = ButtonSize.medium,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final designSystem = DesignSystem.of(context);

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: designSystem.spacing.buttonHeight(size),
      child: OutlinedButton(
        onPressed: isLoading ? null : () {
          HapticFeedback.lightImpact();
          onPressed?.call();
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          side: BorderSide(
            color: theme.colorScheme.primary,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(designSystem.borderRadius.button),
          ),
          padding: designSystem.spacing.buttonPadding(size),
          textStyle: designSystem.typography.button(size),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              )
            : icon != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      icon,
                      const SizedBox(width: 8),
                      Text(text),
                    ],
                  )
                : Text(text),
      ),
    );
  }
}
```

### Cards

#### Base Card
```dart
class BaseCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final bool isInteractive;

  const BaseCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.isInteractive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final designSystem = DesignSystem.of(context);

    final card = Container(
      margin: margin ?? designSystem.spacing.cardMargin,
      padding: padding ?? designSystem.spacing.cardPadding,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(designSystem.borderRadius.card),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: child,
    );

    if (isInteractive || onTap != null) {
      return InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        borderRadius: BorderRadius.circular(designSystem.borderRadius.card),
        child: card,
      );
    }

    return card;
  }
}
```

#### Elevated Card
```dart
class ElevatedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;

  const ElevatedCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final designSystem = DesignSystem.of(context);

    final card = Container(
      margin: margin ?? designSystem.spacing.cardMargin,
      padding: padding ?? designSystem.spacing.cardPadding,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(designSystem.borderRadius.card),
        boxShadow: designSystem.shadows.card,
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        borderRadius: BorderRadius.circular(designSystem.borderRadius.card),
        child: card,
      );
    }

    return card;
  }
}
```

#### Glass Card
```dart
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? blur;
  final double? opacity;
  final VoidCallback? onTap;

  const GlassCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.blur,
    this.opacity,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final designSystem = DesignSystem.of(context);

    final card = Container(
      margin: margin ?? designSystem.spacing.cardMargin,
      padding: padding ?? designSystem.spacing.cardPadding,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(opacity ?? 0.8),
        borderRadius: BorderRadius.circular(designSystem.borderRadius.card),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: blur ?? 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(designSystem.borderRadius.card),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur ?? 10, sigmaY: blur ?? 10),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        borderRadius: BorderRadius.circular(designSystem.borderRadius.card),
        child: card,
      );
    }

    return card;
  }
}
```

### Inputs

#### Text Field
```dart
class DesignTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final bool obscureText;
  final bool enabled;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final String? semanticLabel;

  const DesignTextField({
    Key? key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.semanticLabel,
  }) : super(key: key);

  @override
  State<DesignTextField> createState() => _DesignTextFieldState();
}

class _DesignTextFieldState extends State<DesignTextField> {
  late TextEditingController _controller;
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _obscureText = widget.obscureText;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final designSystem = DesignSystem.of(context);

    return Semantics(
      textField: true,
      label: widget.semanticLabel ?? widget.label ?? widget.hint,
      hint: widget.hint,
      child: TextFormField(
        controller: _controller,
        obscureText: _obscureText,
        enabled: widget.enabled,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        validator: widget.validator,
        onChanged: widget.onChanged,
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        style: designSystem.typography.bodyMedium,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.suffixIcon ??
              (widget.obscureText
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : null),
          filled: true,
          fillColor: theme.colorScheme.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(designSystem.borderRadius.input),
            borderSide: BorderSide(color: theme.colorScheme.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(designSystem.borderRadius.input),
            borderSide: BorderSide(color: theme.colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(designSystem.borderRadius.input),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(designSystem.borderRadius.input),
            borderSide: BorderSide(
              color: theme.colorScheme.error,
              width: 2,
            ),
          ),
          contentPadding: designSystem.spacing.inputPadding,
          labelStyle: designSystem.typography.labelLarge.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          hintStyle: designSystem.typography.bodyMedium.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}
```

#### Search Field
```dart
class SearchField extends StatefulWidget {
  final String? hint;
  final void Function(String)? onSearch;
  final void Function()? onClear;
  final Widget? prefixIcon;
  final String? semanticLabel;

  const SearchField({
    Key? key,
    this.hint,
    this.onSearch,
    this.onClear,
    this.prefixIcon,
    this.semanticLabel,
  }) : super(key: key);

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final designSystem = DesignSystem.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(designSystem.borderRadius.search),
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onSearch,
        decoration: InputDecoration(
          hintText: widget.hint ?? 'Search...',
          prefixIcon: widget.prefixIcon ??
              Icon(
                Icons.search,
                color: theme.colorScheme.onSurfaceVariant,
              ),
          suffixIcon: _hasText
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    _controller.clear();
                    widget.onSearch?.call('');
                    widget.onClear?.call();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: designSystem.spacing.searchPadding,
          hintStyle: designSystem.typography.bodyMedium.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
          ),
        ),
        style: designSystem.typography.bodyMedium,
      ),
    );
  }
}
```

### Navigation

#### Navigation Bar
```dart
class DesignNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavigationItem> items;
  final NavigationStyle style;

  const DesignNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.style = NavigationStyle.auto,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1200;
    final isTablet = MediaQuery.of(context).size.width >= 768;

    switch (style) {
      case NavigationStyle.desktop:
        return _DesktopNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          items: items,
        );
      case NavigationStyle.tablet:
        return _TabletNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          items: items,
        );
      case NavigationStyle.mobile:
        return _MobileNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          items: items,
        );
      case NavigationStyle.auto:
        if (isDesktop) {
          return _DesktopNavigationBar(
            currentIndex: currentIndex,
            onTap: onTap,
            items: items,
          );
        } else if (isTablet) {
          return _TabletNavigationBar(
            currentIndex: currentIndex,
            onTap: onTap,
            items: items,
          );
        } else {
          return _MobileNavigationBar(
            currentIndex: currentIndex,
            onTap: onTap,
            items: items,
          );
        }
    }
  }
}

class NavigationItem {
  final String id;
  final String label;
  final IconData icon;
  final String? badge;
  final bool showBadge;

  const NavigationItem({
    required this.id,
    required this.label,
    required this.icon,
    this.badge,
    this.showBadge = false,
  });
}

enum NavigationStyle {
  desktop,
  tablet,
  mobile,
  auto,
}
```

### Feedback Components

#### Loading Indicator
```dart
class LoadingIndicator extends StatelessWidget {
  final double? size;
  final Color? color;
  final String? semanticLabel;

  const LoadingIndicator({
    Key? key,
    this.size,
    this.color,
    this.semanticLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: semanticLabel ?? 'Loading',
      child: SizedBox(
        width: size ?? 24,
        height: size ?? 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
```

#### Toast Notification
```dart
class ToastNotification extends StatelessWidget {
  final String message;
  final ToastType type;
  final Duration duration;
  final VoidCallback? onDismiss;
  final VoidCallback? onTap;

  const ToastNotification({
    Key? key,
    required this.message,
    this.type = ToastType.info,
    this.duration = const Duration(seconds: 3),
    this.onDismiss,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final designSystem = DesignSystem.of(context);

    return Container(
      margin: designSystem.spacing.toastMargin,
      padding: designSystem.spacing.toastPadding,
      decoration: BoxDecoration(
        color: _getBackgroundColor(theme),
        borderRadius: BorderRadius.circular(designSystem.borderRadius.toast),
        boxShadow: designSystem.shadows.toast,
      ),
      child: Row(
        children: [
          Icon(
            _getIcon(),
            color: _getIconColor(theme),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: designSystem.typography.bodyMedium.copyWith(
                color: _getTextColor(theme),
              ),
            ),
          ),
          if (onTap != null)
            IconButton(
              icon: Icon(
                Icons.close,
                color: _getTextColor(theme),
                size: 18,
              ),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  Color _getBackgroundColor(ThemeData theme) {
    switch (type) {
      case ToastType.success:
        return theme.colorScheme.primary;
      case ToastType.error:
        return theme.colorScheme.error;
      case ToastType.warning:
        return theme.colorScheme.tertiary;
      case ToastType.info:
      default:
        return theme.colorScheme.secondary;
    }
  }

  IconData _getIcon() {
    switch (type) {
      case ToastType.success:
        return Icons.check_circle;
      case ToastType.error:
        return Icons.error;
      case ToastType.warning:
        return Icons.warning;
      case ToastType.info:
      default:
        return Icons.info;
    }
  }

  Color _getIconColor(ThemeData theme) {
    return theme.colorScheme.onPrimary;
  }

  Color _getTextColor(ThemeData theme) {
    return theme.colorScheme.onPrimary;
  }
}

enum ToastType {
  success,
  error,
  warning,
  info,
}
```

### Data Display

#### Data Table
```dart
class DesignDataTable<T> extends StatelessWidget {
  final List<T> data;
  final List<DataColumn<T>> columns;
  final Widget Function(T, int) rowBuilder;
  final bool showCheckboxColumn;
  final Function(Set<T>)? onSelectionChanged;
  final String? emptyStateMessage;

  const DesignDataTable({
    Key? key,
    required this.data,
    required this.columns,
    required this.rowBuilder,
    this.showCheckboxColumn = false,
    this.onSelectionChanged,
    this.emptyStateMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final designSystem = DesignSystem.of(context);

    if (data.isEmpty) {
      return Container(
        padding: designSystem.spacing.emptyStatePadding,
        child: Column(
          children: [
            Icon(
              Icons.inbox,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              emptyStateMessage ?? 'No data available',
              style: designSystem.typography.bodyMedium.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        showCheckboxColumn: showCheckboxColumn,
        columns: columns.map((column) => DataColumn(
          label: column.label,
          numeric: column.numeric,
          tooltip: column.tooltip,
        )).toList(),
        rows: List.generate(data.length, (index) {
          return DataRow(
            selected: column.selected?.call(data[index]) ?? false,
            onSelectChanged: onSelectionChanged != null
                ? (selected) {
                    final selectedSet = <T>{};
                    if (selected) {
                      selectedSet.add(data[index]);
                    }
                    onSelectionChanged!(selectedSet);
                  }
                : null,
            cells: [
              for (var column in columns)
                DataCell(
                  column.cellBuilder(data[index], index),
                ),
            ],
          );
        }),
        headingRowColor: MaterialStateProperty.all(
          theme.colorScheme.surfaceVariant,
        ),
        dataRowColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return theme.colorScheme.primaryContainer;
          }
          if (states.contains(MaterialState.hovered)) {
            return theme.colorScheme.surfaceVariant.withOpacity(0.5);
          }
          return null;
        }),
      ),
    );
  }
}

class DataColumn<T> {
  final Widget label;
  final bool numeric;
  final String? tooltip;
  final bool Function(T)? selected;
  final Widget Function(T, int) cellBuilder;

  const DataColumn({
    required this.label,
    this.numeric = false,
    this.tooltip,
    this.selected,
    required this.cellBuilder,
  });
}
```

#### Chip
```dart
class DesignChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool selected;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const DesignChip({
    Key? key,
    required this.label,
    this.onTap,
    this.onDelete,
    this.selected = false,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final designSystem = DesignSystem.of(context);

    return Chip(
      label: Text(
        label,
        style: designSystem.typography.labelLarge.copyWith(
          color: foregroundColor ?? 
              (selected 
                  ? theme.colorScheme.onPrimary 
                  : theme.colorScheme.onSurface),
        ),
      ),
      backgroundColor: backgroundColor ?? 
          (selected 
              ? theme.colorScheme.primary 
              : theme.colorScheme.surfaceVariant),
      onDeleted: onDelete,
      deleteIcon: Icon(
        Icons.close,
        size: 18,
        color: foregroundColor ?? theme.colorScheme.onSurface,
      ),
      padding: designSystem.spacing.chipPadding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(designSystem.borderRadius.chip),
      ),
    );
  }
}
```

### Layout Components

#### Section
```dart
class DesignSection extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final List<Widget> children;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final bool showDivider;

  const DesignSection({
    Key? key,
    this.title,
    this.subtitle,
    this.trailing,
    required this.children,
    this.padding,
    this.margin,
    this.showDivider = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final designSystem = DesignSystem.of(context);

    return Container(
      margin: margin ?? designSystem.spacing.sectionMargin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title!,
                        style: designSystem.typography.headlineSmall,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: designSystem.typography.bodySmall.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 16),
          ],
          ...children,
          if (showDivider)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Divider(
                color: theme.colorScheme.outlineVariant,
                thickness: 1,
              ),
            ),
        ],
      ),
    );
  }
}
```

#### Spacer
```dart
class DesignSpacer extends StatelessWidget {
  final SpacerSize size;
  final Axis axis;

  const DesignSpacer({
    Key? key,
    this.size = SpacerSize.medium,
    this.axis = Axis.vertical,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final designSystem = DesignSystem.of(context);
    final spacing = designSystem.spacing.getSpacerSize(size);

    if (axis == Axis.vertical) {
      return SizedBox(height: spacing);
    } else {
      return SizedBox(width: spacing);
    }
  }
}

enum SpacerSize {
  xxs,
  xs,
  small,
  medium,
  large,
  xl,
  xxl,
}
```

### Typography Components

#### Heading
```dart
class Heading extends StatelessWidget {
  final String text;
  final HeadingLevel level;
  final TextAlign? textAlign;
  final Color? color;
  final int? maxLines;
  final TextOverflow? overflow;

  const Heading({
    Key? key,
    required this.text,
    required this.level,
    this.textAlign,
    this.color,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final designSystem = DesignSystem.of(context);

    return Text(
      text,
      style: designSystem.typography.getHeading(level).copyWith(
        color: color ?? theme.colorScheme.onSurface,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

enum HeadingLevel {
  h1,
  h2,
  h3,
  h4,
  h5,
  h6,
}
```

#### Body Text
```dart
class BodyText extends StatelessWidget {
  final String text;
  final BodySize size;
  final TextAlign? textAlign;
  final Color? color;
  final bool isBold;
  final int? maxLines;
  final TextOverflow? overflow;

  const BodyText({
    Key? key,
    required this.text,
    this.size = BodySize.medium,
    this.textAlign,
    this.color,
    this.isBold = false,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final designSystem = DesignSystem.of(context);

    return Text(
      text,
      style: designSystem.typography.getBody(size).copyWith(
        color: color ?? theme.colorScheme.onSurface,
        fontWeight: isBold ? FontWeight.w600 : null,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

enum BodySize {
  small,
  medium,
  large,
}
```

## Design System Provider

### DesignSystem Class
```dart
class DesignSystem extends InheritedWidget {
  final DesignSystemData data;

  const DesignSystem({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  static DesignSystemData of(BuildContext context) {
    final DesignSystem? result = context.dependOnInheritedWidgetOfExactType<DesignSystem>();
    assert(result != null, 'No DesignSystem found in context');
    return result!.data;
  }

  @override
  bool updateShouldNotify(DesignSystem oldWidget) {
    return oldWidget.data != data;
  }
}

class DesignSystemData {
  final DesignSystemSpacing spacing;
  final DesignSystemTypography typography;
  final DesignSystemColorPalette colors;
  final DesignSystemShadows shadows;
  final DesignSystemBorderRadius borderRadius;
  final DesignSystemAnimation animations;

  const DesignSystemData({
    required this.spacing,
    required this.typography,
    required this.colors,
    required this.shadows,
    required this.borderRadius,
    required this.animations,
  });

  static DesignSystemData of(BuildContext context) {
    return DesignSystem.of(context);
  }
}
```

### DesignSystemTokens
```dart
class DesignSystemSpacing {
  const DesignSystemSpacing();

  // Button spacing
  double buttonHeight(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.medium:
        return 44;
      case ButtonSize.large:
        return 52;
    }
  }

  EdgeInsets buttonPadding(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  // Card spacing
  static const cardMargin = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  static const cardPadding = EdgeInsets.all(16);

  // Input spacing
  static const inputPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  static const searchPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 8);

  // Toast spacing
  static const toastMargin = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  static const toastPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);

  // Section spacing
  static const sectionMargin = EdgeInsets.symmetric(vertical: 24);
  static const emptyStatePadding = EdgeInsets.all(32);

  // Chip spacing
  static const chipPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 6);

  // Spacer sizes
  double getSpacerSize(SpacerSize size) {
    switch (size) {
      case SpacerSize.xxs:
        return 4;
      case SpacerSize.xs:
        return 8;
      case SpacerSize.small:
        return 12;
      case SpacerSize.medium:
        return 16;
      case SpacerSize.large:
        return 24;
      case SpacerSize.xl:
        return 32;
      case SpacerSize.xxl:
        return 48;
    }
  }
}

class DesignSystemTypography {
  const DesignSystemTypography();

  // Button styles
  TextStyle button(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return const TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
      case ButtonSize.medium:
        return const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
      case ButtonSize.large:
        return const TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
    }
  }

  // Heading styles
  TextStyle getHeading(HeadingLevel level) {
    switch (level) {
      case HeadingLevel.h1:
        return const TextStyle(fontSize: 48, fontWeight: FontWeight.w700);
      case HeadingLevel.h2:
        return const TextStyle(fontSize: 36, fontWeight: FontWeight.w600);
      case HeadingLevel.h3:
        return const TextStyle(fontSize: 28, fontWeight: FontWeight.w600);
      case HeadingLevel.h4:
        return const TextStyle(fontSize: 24, fontWeight: FontWeight.w600);
      case HeadingLevel.h5:
        return const TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
      case HeadingLevel.h6:
        return const TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
    }
  }

  // Body styles
  TextStyle getBody(BodySize size) {
    switch (size) {
      case BodySize.small:
        return const TextStyle(fontSize: 14, fontWeight: FontWeight.w400);
      case BodySize.medium:
        return const TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
      case BodySize.large:
        return const TextStyle(fontSize: 18, fontWeight: FontWeight.w400);
    }
  }

  // Other styles
  static const headlineSmall = TextStyle(fontSize: 24, fontWeight: FontWeight.w600);
  static const bodyMedium = TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
  static const bodySmall = TextStyle(fontSize: 14, fontWeight: FontWeight.w400);
  static const labelLarge = TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
}

class DesignSystemBorderRadius {
  const DesignSystemBorderRadius();

  static const button = 12.0;
  static const card = 16.0;
  static const input = 12.0;
  static const search = 24.0;
  static const toast = 12.0;
  static const chip = 16.0;
  static const dialog = 20.0;
}

class DesignSystemShadows {
  const DesignSystemShadows();

  static const card = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  static const toast = [
    BoxShadow(
      color: Color(0x1E000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  static const elevated = [
    BoxShadow(
      color: Color(0x1E000000),
      blurRadius: 12,
      offset: Offset(0, 6),
    ),
  ];
}

class DesignSystemAnimation {
  const DesignSystemAnimation();

  static const fast = Duration(milliseconds: 200);
  static const normal = Duration(milliseconds: 300);
  static const slow = Duration(milliseconds: 500);

  static const defaultCurve = Curves.easeInOut;
  static const bounceCurve = Curves.elasticOut;
  static const smoothCurve = Curves.easeOutCubic;
}
```

## Component Usage Guidelines

### Button Selection
- **Primary Button**: Main action on screen
- **Secondary Button**: Alternative or complementary action
- **Outlined Button**: Tertiary or low-emphasis action
- **Text Button**: Navigation or link-style action

### Card Selection
- **Base Card**: Standard content container
- **Elevated Card**: Content that needs emphasis
- **Interactive Card**: Clickable content
- **Glass Card**: Modern, translucent effect

### Input Selection
- **Text Field**: Standard text input
- **Search Field**: Search-specific input with clear button
- **Dropdown Field**: Selection from predefined options
- **Date Field**: Date/time selection

## Migration Guide

### Step 1: Add DesignSystem Provider
```dart
MaterialApp(
  theme: ThemeData(...),
  home: DesignSystem(
    data: DesignSystemData(
      spacing: const DesignSystemSpacing(),
      typography: const DesignSystemTypography(),
      colors: DesignSystemColorPalette.fromTheme(theme),
      shadows: const DesignSystemShadows(),
      borderRadius: const DesignSystemBorderRadius(),
      animations: const DesignSystemAnimation(),
    ),
    child: HomeScreen(),
  ),
)
```

### Step 2: Replace Components
```dart
// Before
ElevatedButton(
  onPressed: () {},
  child: Text('Submit'),
)

// After
PrimaryButton(
  text: 'Submit',
  onPressed: () {},
)
```

### Step 3: Use DesignSystem Tokens
```dart
// Before
SizedBox(height: 16),

// After
const DesignSpacer(size: SpacerSize.medium),
```

## Success Metrics

### Quantitative
- **Component Usage**: 100% of new screens using design system components
- **Consistency**: 100% consistent component usage
- **Code Reduction**: 40% reduction in duplicate component code
- **Accessibility**: WCAG 2.1 AA compliance for all components

### Qualitative
- **Developer Experience**: Faster component development
- **Visual Consistency**: Consistent appearance across app
- **Maintainability**: Easier to update components globally
- **User Experience**: Consistent interaction patterns

## Conclusion

This unified design system components library provides a comprehensive, accessible, and consistent set of components for VedantaTrade. By implementing this library, the application will achieve:

1. **Consistency**: Uniform component appearance and behavior
2. **Accessibility**: Full accessibility support built-in
3. **Maintainability**: Centralized component management
4. **Developer Experience**: Faster development with pre-built components
5. **User Experience**: Predictable and consistent interactions

The implementation plan ensures a smooth migration from the current scattered components to this unified library with minimal disruption to existing functionality.

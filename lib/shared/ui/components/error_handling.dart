import 'package:flutter/material.dart';
import '../design_system/app_colors.dart';
import '../design_system/app_spacing.dart';
import '../design_system/app_typography.dart';

class ErrorStates {
  // Full Screen Error
  static Widget fullScreen({
    required String title,
    String? subtitle,
    String? details,
    IconData? icon,
    Color? iconColor,
    VoidCallback? onRetry,
    String? retryText,
    Widget? customAction,
    ErrorType type = ErrorType.general,
  }) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.paddingScreen,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon ?? _getErrorIcon(type),
                size: 64,
                color: iconColor ?? _getErrorColor(type),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                style: AppTypography.heading3,
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  subtitle,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (details != null) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: AppSpacing.paddingCard,
                  decoration: BoxDecoration(
                    color: AppColors.errorSurface,
                    borderRadius: AppBorderRadius.radiusCard,
                    border: Border.all(color: AppColors.error.withOpacity(0.2)),
                  ),
                  child: Text(
                    details,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.error,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              if (onRetry != null)
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(retryText ?? 'Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getErrorColor(type),
                    foregroundColor: Colors.white,
                    padding: AppSpacing.paddingButtonLG,
                  ),
                ),
              if (customAction != null) ...[
                const SizedBox(height: AppSpacing.sm),
                customAction!,
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Card Error
  static Widget card({
    required String title,
    String? subtitle,
    VoidCallback? onRetry,
    ErrorType type = ErrorType.general,
    bool showIcon = true,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      padding: padding ?? AppSpacing.paddingCard,
      decoration: BoxDecoration(
        color: AppColors.errorSurface,
        borderRadius: AppBorderRadius.radiusCard,
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (showIcon) ...[
                Icon(
                  _getErrorIcon(type),
                  color: _getErrorColor(type),
                  size: AppSizes.iconMD,
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.labelMedium.copyWith(
                        color: _getErrorColor(type),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onRetry != null)
                IconButton(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 20),
                  color: _getErrorColor(type),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Inline Error
  static Widget inline({
    required String message,
    VoidCallback? onRetry,
    ErrorType type = ErrorType.general,
    bool showIcon = true,
  }) {
    return Container(
      padding: AppSpacing.paddingInput,
      decoration: BoxDecoration(
        color: AppColors.errorSurface,
        borderRadius: AppBorderRadius.radiusInput,
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          if (showIcon) ...[
            Icon(
              _getErrorIcon(type),
              color: _getErrorColor(type),
              size: AppSizes.iconSM,
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(
                color: _getErrorColor(type),
              ),
            ),
          ),
          if (onRetry != null)
            GestureDetector(
              onTap: onRetry,
              child: Text(
                'Retry',
                style: AppTypography.labelSmall.copyWith(
                  color: _getErrorColor(type),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  static IconData _getErrorIcon(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off_rounded;
      case ErrorType.server:
        return Icons.error_outline_rounded;
      case ErrorType.permission:
        return Icons.lock_outline_rounded;
      case ErrorType.notFound:
        return Icons.search_off_rounded;
      case ErrorType.timeout:
        return Icons.access_time_rounded;
      case ErrorType.validation:
        return Icons.warning_amber_rounded;
      case ErrorType.general:
      default:
        return Icons.error_outline_rounded;
    }
  }

  static Color _getErrorColor(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return AppColors.warning;
      case ErrorType.server:
        return AppColors.error;
      case ErrorType.permission:
        return AppColors.warning;
      case ErrorType.notFound:
        return AppColors.info;
      case ErrorType.timeout:
        return AppColors.warning;
      case ErrorType.validation:
        return AppColors.warning;
      case ErrorType.general:
      default:
        return AppColors.error;
    }
  }
}

class EnhancedErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget? errorWidget;
  final void Function(dynamic error, StackTrace stackTrace)? onError;
  final bool showRetry;
  final String? retryText;

  const EnhancedErrorBoundary({
    Key? key,
    required this.child,
    this.errorWidget,
    this.onError,
    this.showRetry = true,
    this.retryText,
  }) : super(key: key);

  @override
  State<EnhancedErrorBoundary> createState() => _EnhancedErrorBoundaryState();
}

class _EnhancedErrorBoundaryState extends State<EnhancedErrorBoundary> {
  dynamic _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    _error = null;
    _stackTrace = null;
  }

  void _handleError(dynamic error, StackTrace stackTrace) {
    setState(() {
      _error = error;
      _stackTrace = stackTrace;
    });
    widget.onError?.call(error, stackTrace);
  }

  void _retry() {
    setState(() {
      _error = null;
      _stackTrace = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorWidget ??
          ErrorStates.fullScreen(
            title: 'Something went wrong',
            subtitle: 'An unexpected error occurred',
            details: _error.toString(),
            onRetry: widget.showRetry ? _retry : null,
            retryText: widget.retryText,
            type: ErrorType.general,
          );
    }

    return ErrorWidget(
      error: _error,
      stackTrace: _stackTrace,
      onError: _handleError,
      child: widget.child,
    );
  }
}

class ErrorWidget extends StatelessWidget {
  final Widget child;
  final dynamic error;
  final StackTrace? stackTrace;
  final void Function(dynamic error, StackTrace stackTrace)? onError;

  const ErrorWidget({
    Key? key,
    required this.child,
    this.error,
    this.stackTrace,
    this.onError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class ValidationErrorDisplay extends StatelessWidget {
  final List<String> errors;
  final ErrorType type;
  final VoidCallback? onRetry;

  const ValidationErrorDisplay({
    Key? key,
    required this.errors,
    this.type = ErrorType.validation,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (errors.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: AppSpacing.marginBottomSM,
      padding: AppSpacing.paddingCard,
      decoration: BoxDecoration(
        color: AppColors.errorSurface,
        borderRadius: AppBorderRadius.radiusCard,
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                ErrorStates._getErrorIcon(type),
                color: ErrorStates._getErrorColor(type),
                size: AppSizes.iconSM,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Validation Error',
                style: AppTypography.labelMedium.copyWith(
                  color: ErrorStates._getErrorColor(type),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (onRetry != null)
                GestureDetector(
                  onTap: onRetry,
                  child: Icon(
                    Icons.close,
                    color: ErrorStates._getErrorColor(type),
                    size: AppSizes.iconSM,
                  ),
                ),
            ],
          ),
          if (errors.length > 1) ...[
            const SizedBox(height: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: errors
                  .map((error) => Padding(
                        padding: AppSpacing.marginBottomXS,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 4,
                              height: 4,
                              margin: EdgeInsets.only(top: 6),
                              decoration: BoxDecoration(
                                color: ErrorStates._getErrorColor(type),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                error,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ] else ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              errors.first,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? message;
  final bool showIcon;

  const NetworkErrorWidget({
    Key? key,
    this.onRetry,
    this.message,
    this.showIcon = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingScreen,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showIcon) ...[
              Icon(
                Icons.wifi_off_rounded,
                size: 64,
                color: AppColors.warning,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            Text(
              'No Internet Connection',
              style: AppTypography.heading3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message ?? 'Please check your internet connection and try again',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            if (onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                  padding: AppSpacing.paddingButtonLG,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onAction;
  final String? actionText;
  final Widget? customAction;

  const EmptyStateWidget({
    Key? key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.onAction,
    this.actionText,
    this.customAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: AppSpacing.paddingScreen,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 64,
                color: iconColor ?? (isDark ? AppColors.darkTextTertiary : AppColors.textTertiary),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            Text(
              title,
              style: isDark 
                  ? AppTypography.darkHeading3
                  : AppTypography.heading3,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                style: isDark 
                    ? AppTypography.darkBodyMedium.copyWith(color: AppColors.darkTextSecondary)
                    : AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            if (customAction != null)
              customAction!
            else if (onAction != null)
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionText ?? 'Get Started'),
                style: ElevatedButton.styleFrom(
                  padding: AppSpacing.paddingButtonLG,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

enum ErrorType {
  network,
  server,
  permission,
  notFound,
  timeout,
  validation,
  general,
}

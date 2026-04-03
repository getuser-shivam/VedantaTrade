import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/premium_glassmorphic_theme.dart';

class EnhancedErrorStates extends StatelessWidget {
  final ErrorStateType type;
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final Widget? customWidget;
  final List<ErrorAction>? actions;

  const EnhancedErrorStates({
    Key? key,
    required this.type,
    required this.title,
    required this.message,
    this.onRetry,
    this.onDismiss,
    this.customWidget,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case ErrorStateType.network:
        return _buildNetworkError();
      case ErrorStateType.server:
        return _buildServerError();
      case ErrorStateType.empty:
        return _buildEmptyState();
      case ErrorStateType.permission:
        return _buildPermissionError();
      case ErrorStateType.notFound:
        return _buildNotFoundError();
      case ErrorStateType.custom:
        return _buildCustomError();
      default:
        return _buildGenericError();
    }
  }

  Widget _buildNetworkError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Error Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withOpacity(0.1),
              border: Border.all(
                color: Colors.red.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.wifi_off,
              color: Colors.red,
              size: 60,
            ),
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingXl),
          
          // Error Title
          Text(
            title,
            style: const TextStyle(
              color: PremiumGlassmorphicTheme.textPrimary,
              fontSize: PremiumGlassmorphicTheme.fontSizeXl,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
          
          // Error Message
          Text(
            message,
            style: const TextStyle(
              color: PremiumGlassmorphicTheme.textSecondary,
              fontSize: PremiumGlassmorphicTheme.fontSizeMd,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingXl),
          
          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildServerError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Error Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.orange.withOpacity(0.1),
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.error_outline,
              color: Colors.orange,
              size: 60,
            ),
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingXl),
          
          // Error Title
          Text(
            title,
            style: const TextStyle(
              color: PremiumGlassmorphicTheme.textPrimary,
              fontSize: PremiumGlassmorphicTheme.fontSizeXl,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
          
          // Error Message
          Text(
            message,
            style: const TextStyle(
              color: PremiumGlassmorphicTheme.textSecondary,
              fontSize: PremiumGlassmorphicTheme.fontSizeMd,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingXl),
          
          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty State Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withOpacity(0.1),
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.inbox_outlined,
              color: Colors.blue,
              size: 60,
            ),
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingXl),
          
          // Empty State Title
          Text(
            title,
            style: const TextStyle(
              color: PremiumGlassmorphicTheme.textPrimary,
              fontSize: PremiumGlassmorphicTheme.fontSizeXl,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
          
          // Empty State Message
          Text(
            message,
            style: const TextStyle(
              color: PremiumGlassmorphicTheme.textSecondary,
              fontSize: PremiumGlassmorphicTheme.fontSizeMd,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingXl),
          
          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildPermissionError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Permission Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.amber.withOpacity(0.1),
              border: Border.all(
                color: Colors.amber.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.lock_outline,
              color: Colors.amber,
              size: 60,
            ),
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingXl),
          
          // Permission Title
          Text(
            title,
            style: const TextStyle(
              color: PremiumGlassmorphicTheme.textPrimary,
              fontSize: PremiumGlassmorphicTheme.fontSizeXl,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
          
          // Permission Message
          Text(
            message,
            style: const TextStyle(
              color: PremiumGlassmorphicTheme.textSecondary,
              fontSize: PremiumGlassmorphicTheme.fontSizeMd,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingXl),
          
          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildNotFoundError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Not Found Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.withOpacity(0.1),
              border: Border.all(
                color: Colors.grey.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.search_off,
              color: Colors.grey,
              size: 60,
            ),
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingXl),
          
          // Not Found Title
          Text(
            title,
            style: const TextStyle(
              color: PremiumGlassmorphicTheme.textPrimary,
              fontSize: PremiumGlassmorphicTheme.fontSizeXl,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
          
          // Not Found Message
          Text(
            message,
            style: const TextStyle(
              color: PremiumGlassmorphicTheme.textSecondary,
              fontSize: PremiumGlassmorphicTheme.fontSizeMd,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingXl),
          
          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildGenericError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Generic Error Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.purple.withOpacity(0.1),
              border: Border.all(
                color: Colors.purple.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.error,
              color: Colors.purple,
              size: 60,
            ),
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingXl),
          
          // Generic Error Title
          Text(
            title,
            style: const TextStyle(
              color: PremiumGlassmorphicTheme.textPrimary,
              fontSize: PremiumGlassmorphicTheme.fontSizeXl,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
          
          // Generic Error Message
          Text(
            message,
            style: const TextStyle(
              color: PremiumGlassmorphicTheme.textSecondary,
              fontSize: PremiumGlassmorphicTheme.fontSizeMd,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingXl),
          
          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildCustomError() {
    return customWidget ?? _buildGenericError();
  }

  Widget _buildActionButtons() {
    if (actions != null && actions!.isNotEmpty) {
      return Column(
        children: actions!.map((action) => _buildAction(action)).toList(),
      );
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (onRetry != null)
          PremiumGlassmorphicTheme.glassButton(
            onPressed: onRetry,
            child: const Text('Retry'),
            height: 48,
          ),
        
        if (onRetry != null && onDismiss != null)
          const SizedBox(width: PremiumGlassmorphicTheme.spacingMd),
        
        if (onDismiss != null)
          PremiumGlassmorphicTheme.glassButton(
            onPressed: onDismiss,
            child: const Text('Dismiss'),
            height: 48,
          ),
      ],
    );
  }

  Widget _buildAction(ErrorAction action) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PremiumGlassmorphicTheme.spacingSm),
      child: PremiumGlassmorphicTheme.glassButton(
        onPressed: action.onTap,
        child: Text(action.label),
        height: 48,
        color: action.color,
      ),
    );
  }
}

class EnhancedErrorOverlay extends StatelessWidget {
  final bool hasError;
  final Widget child;
  final ErrorStateType errorType;
  final String errorTitle;
  final String errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final Widget? customErrorWidget;
  final List<ErrorAction>? errorActions;

  const EnhancedErrorOverlay({
    Key? key,
    required this.hasError,
    required this.child,
    this.errorType = ErrorStateType.generic,
    required this.errorTitle,
    required this.errorMessage,
    this.onRetry,
    this.onDismiss,
    this.customErrorWidget,
    this.errorActions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        
        // Error Overlay
        if (hasError)
          Positioned.fill(
            child: Container(
              color: PremiumGlassmorphicTheme.slate900.withOpacity(0.9),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: EnhancedErrorStates(
                  type: errorType,
                  title: errorTitle,
                  message: errorMessage,
                  onRetry: onRetry,
                  onDismiss: onDismiss,
                  customWidget: customErrorWidget,
                  actions: errorActions,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class EnhancedErrorDialog extends StatelessWidget {
  final ErrorStateType type;
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final List<ErrorAction>? actions;

  const EnhancedErrorDialog({
    Key? key,
    required this.type,
    required this.title,
    required this.message,
    this.onRetry,
    this.onDismiss,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingXl),
        decoration: BoxDecoration(
          color: PremiumGlassmorphicTheme.slate800.withOpacity(0.95),
          borderRadius: BorderRadius.circular(PremiumGlassmorphicTheme.radiusLg),
          border: Border.all(
            color: PremiumGlassmorphicTheme.borderMedium,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getErrorColor().withOpacity(0.1),
                border: Border.all(
                  color: _getErrorColor().withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                _getErrorIcon(),
                color: _getErrorColor(),
                size: 40,
              ),
            ),
            
            const SizedBox(height: PremiumGlassmorphicTheme.spacingLg),
            
            // Error Title
            Text(
              title,
              style: const TextStyle(
                color: PremiumGlassmorphicTheme.textPrimary,
                fontSize: PremiumGlassmorphicTheme.fontSizeLg,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
            
            // Error Message
            Text(
              message,
              style: const TextStyle(
                color: PremiumGlassmorphicTheme.textSecondary,
                fontSize: PremiumGlassmorphicTheme.fontSizeMd,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: PremiumGlassmorphicTheme.spacingLg),
            
            // Action Buttons
            Row(
              children: [
                if (onDismiss != null)
                  Expanded(
                    child: PremiumGlassmorphicTheme.glassButton(
                      onPressed: onDismiss,
                      child: const Text('Close'),
                      height: 40,
                    ),
                  ),
                
                if (onDismiss != null && onRetry != null)
                  const SizedBox(width: PremiumGlassmorphicTheme.spacingMd),
                
                if (onRetry != null)
                  Expanded(
                    child: PremiumGlassmorphicTheme.glassButton(
                      onPressed: onRetry,
                      child: const Text('Retry'),
                      height: 40,
                      color: _getErrorColor(),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getErrorColor() {
    switch (type) {
      case ErrorStateType.network:
        return Colors.red;
      case ErrorStateType.server:
        return Colors.orange;
      case ErrorStateType.permission:
        return Colors.amber;
      case ErrorStateType.notFound:
        return Colors.grey;
      default:
        return Colors.purple;
    }
  }

  IconData _getErrorIcon() {
    switch (type) {
      case ErrorStateType.network:
        return Icons.wifi_off;
      case ErrorStateType.server:
        return Icons.error_outline;
      case ErrorStateType.permission:
        return Icons.lock_outline;
      case ErrorStateType.notFound:
        return Icons.search_off;
      default:
        return Icons.error;
    }
  }
}

enum ErrorStateType {
  network,
  server,
  empty,
  permission,
  notFound,
  custom,
  generic,
}

class ErrorAction {
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const ErrorAction({
    required this.label,
    required this.onTap,
    this.color,
  });
}

import 'package:flutter/material.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';

/// Toast notification types
enum ToastType { success, error, warning, info }

/// Toast notification widget for user feedback
class ToastNotification extends StatelessWidget {
  final String message;
  final ToastType type;
  final VoidCallback? onDismiss;
  final Duration duration;

  const ToastNotification({
    Key? key,
    required this.message,
    this.type = ToastType.info,
    this.onDismiss,
    this.duration = const Duration(seconds: 3),
  }) : super(key: key);

  Color get _backgroundColor {
    switch (type) {
      case ToastType.success:
        return AppTheme.success.withOpacity(0.9);
      case ToastType.error:
        return AppTheme.error.withOpacity(0.9);
      case ToastType.warning:
        return Colors.orange.withOpacity(0.9);
      case ToastType.info:
        return AppTheme.primary.withOpacity(0.9);
    }
  }

  IconData get _icon {
    switch (type) {
      case ToastType.success:
        return Icons.check_circle_rounded;
      case ToastType.error:
        return Icons.error_rounded;
      case ToastType.warning:
        return Icons.warning_rounded;
      case ToastType.info:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(_icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (onDismiss != null)
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                onPressed: onDismiss,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }
}

/// Toast manager for showing notifications
class ToastManager {
  static final List<OverlayEntry> _toasts = [];

  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 0,
        right: 0,
        child: SafeArea(
          child: Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.up,
            onDismissed: (_) => _removeToast(entry),
            child: ToastNotification(
              message: message,
              type: type,
              onDismiss: () => _removeToast(entry),
              duration: duration,
            ),
          ),
        ),
      ),
    );

    _toasts.add(entry);
    overlay.insert(entry);

    Future.delayed(duration, () => _removeToast(entry));
  }

  static void _removeToast(OverlayEntry entry) {
    if (_toasts.contains(entry)) {
      entry.remove();
      _toasts.remove(entry);
    }
  }

  static void clearAll() {
    for (final toast in _toasts) {
      toast.remove();
    }
    _toasts.clear();
  }
}

/// Extension for easy toast access
extension ToastExtension on BuildContext {
  void showToast(
    String message, {
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    ToastManager.show(this, message: message, type: type, duration: duration);
  }

  void showSuccess(String message) {
    ToastManager.show(this, message: message, type: ToastType.success);
  }

  void showError(String message) {
    ToastManager.show(this, message: message, type: ToastType.error);
  }

  void showWarning(String message) {
    ToastManager.show(this, message: message, type: ToastType.warning);
  }
}

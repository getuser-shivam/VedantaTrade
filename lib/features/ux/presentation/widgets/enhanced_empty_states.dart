import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/premium_glassmorphic_theme.dart';

class EnhancedEmptyStates extends StatelessWidget {
  final EmptyStateType type;
  final String title;
  final String message;
  final VoidCallback? onAction;
  final String? actionText;
  final Widget? customWidget;
  final List<EmptyStateAction>? actions;

  const EnhancedEmptyStates({
    Key? key,
    required this.type,
    required this.title,
    required this.message,
    this.onAction,
    this.actionText,
    this.customWidget,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case EmptyStateType.noData:
        return _buildNoDataState();
      case EmptyStateType.noResults:
        return _buildNoResultsState();
      case EmptyStateType.noInternet:
        return _buildNoInternetState();
      case EmptyStateType.noPermissions:
        return _buildNoPermissionsState();
      case EmptyStateType.noFavorites:
        return _buildNoFavoritesState();
      case EmptyStateType.noHistory:
        return _buildNoHistoryState();
      case EmptyStateType.noNotifications:
        return _buildNoNotificationsState();
      case EmptyStateType.noCart:
        return _buildNoCartState();
      case EmptyStateType.custom:
        return _buildCustomEmptyState();
      default:
        return _buildDefaultEmptyState();
    }
  }

  Widget _buildNoDataState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty State Animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Container(
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
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1200),
                    builder: (context, rotation, child) {
                      return Transform.rotate(
                        angle: rotation * 0.5,
                        child: Icon(
                          Icons.inbox_outlined,
                          color: Colors.blue,
                          size: 60,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
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

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Search Results Empty Animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Container(
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
                    Icons.search_off,
                    color: Colors.orange,
                    size: 60,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingXl),
          
          // No Results Title
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
          
          // No Results Message
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
          
          // Search Suggestions
          _buildSearchSuggestions(),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingLg),
          
          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildNoInternetState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // No Internet Animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Container(
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
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1000),
                    builder: (context, opacity, child) {
                      return Opacity(
                        opacity: 0.5 + (opacity * 0.5),
                        child: Icon(
                          Icons.wifi_off,
                          color: Colors.red,
                          size: 60,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingXl),
          
          // No Internet Title
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
          
          // No Internet Message
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

  Widget _buildNoPermissionsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // No Permissions Animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Container(
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
              );
            },
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingXl),
          
          // No Permissions Title
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
          
          // No Permissions Message
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

  Widget _buildNoFavoritesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // No Favorites Animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.pink.withOpacity(0.1),
                    border: Border.all(
                      color: Colors.pink.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: 0.8 + (scale * 0.4),
                        child: Icon(
                          Icons.favorite_border,
                          color: Colors.pink,
                          size: 60,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingXl),
          
          // No Favorites Title
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
          
          // No Favorites Message
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

  Widget _buildNoHistoryState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // No History Animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withOpacity(0.1),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.history,
                    color: Colors.green,
                    size: 60,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingXl),
          
          // No History Title
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
          
          // No History Message
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

  Widget _buildNoNotificationsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // No Notifications Animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Container(
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
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1000),
                    builder: (context, rotation, child) {
                      return Transform.rotate(
                        angle: rotation * 0.1,
                        child: Icon(
                          Icons.notifications_none,
                          color: Colors.purple,
                          size: 60,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingXl),
          
          // No Notifications Title
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
          
          // No Notifications Message
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

  Widget _buildNoCartState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // No Cart Animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.indigo.withOpacity(0.1),
                    border: Border.all(
                      color: Colors.indigo.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.indigo,
                    size: 60,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingXl),
          
          // No Cart Title
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
          
          // No Cart Message
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

  Widget _buildDefaultEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Default Empty Animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Container(
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
                    Icons.inbox_outlined,
                    color: Colors.grey,
                    size: 60,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingXl),
          
          // Default Empty Title
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
          
          // Default Empty Message
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

  Widget _buildCustomEmptyState() {
    return customWidget ?? _buildDefaultEmptyState();
  }

  Widget _buildSearchSuggestions() {
    return Container(
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingLg),
      decoration: BoxDecoration(
        color: PremiumGlassmorphicTheme.surfaceLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(PremiumGlassmorphicTheme.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Search Tips:',
            style: TextStyle(
              color: PremiumGlassmorphicTheme.textSecondary,
              fontSize: PremiumGlassmorphicTheme.fontSizeSm,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
          
          _buildSearchTip('Try different keywords'),
          _buildSearchTip('Check spelling'),
          _buildSearchTip('Use broader terms'),
          _buildSearchTip('Remove filters'),
        ],
      ),
    );
  }

  Widget _buildSearchTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PremiumGlassmorphicTheme.spacingSm),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: PremiumGlassmorphicTheme.textTertiary,
            size: 16,
          ),
          const SizedBox(width: PremiumGlassmorphicTheme.spacingSm),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(
                color: PremiumGlassmorphicTheme.textSecondary,
                fontSize: PremiumGlassmorphicTheme.fontSizeSm,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (actions != null && actions!.isNotEmpty) {
      return Column(
        children: actions!.map((action) => _buildAction(action)).toList(),
      );
    }
    
    if (onAction != null) {
      return PremiumGlassmorphicTheme.glassButton(
        onPressed: onAction,
        child: Text(
          actionText ?? 'Get Started',
          style: const TextStyle(
            color: PremiumGlassmorphicTheme.textPrimary,
            fontSize: PremiumGlassmorphicTheme.fontSizeMd,
            fontWeight: FontWeight.w600,
          ),
        ),
        height: 48,
      );
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildAction(EmptyStateAction action) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PremiumGlassmorphicTheme.spacingSm),
      child: PremiumGlassmorphicTheme.glassButton(
        onPressed: action.onTap,
        child: Text(
          action.label,
          style: const TextStyle(
            color: PremiumGlassmorphicTheme.textPrimary,
            fontSize: PremiumGlassmorphicTheme.fontSizeMd,
            fontWeight: FontWeight.w600,
          ),
        ),
        height: 48,
        color: action.color,
      ),
    );
  }
}

class EnhancedEmptyOverlay extends StatelessWidget {
  final bool isEmpty;
  final Widget child;
  final EmptyStateType emptyType;
  final String emptyTitle;
  final String emptyMessage;
  final VoidCallback? onAction;
  final String? actionText;
  final Widget? customEmptyWidget;
  final List<EmptyStateAction>? emptyActions;

  const EnhancedEmptyOverlay({
    Key? key,
    required this.isEmpty,
    required this.child,
    this.emptyType = EmptyStateType.noData,
    required this.emptyTitle,
    required this.emptyMessage,
    this.onAction,
    this.actionText,
    this.customEmptyWidget,
    this.emptyActions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        
        // Empty State Overlay
        if (isEmpty)
          Positioned.fill(
            child: Container(
              color: PremiumGlassmorphicTheme.slate900.withOpacity(0.95),
              child: EnhancedEmptyStates(
                type: emptyType,
                title: emptyTitle,
                message: emptyMessage,
                onAction: onAction,
                actionText: actionText,
                customWidget: customEmptyWidget,
                actions: emptyActions,
              ),
            ),
          ),
      ],
    );
  }
}

enum EmptyStateType {
  noData,
  noResults,
  noInternet,
  noPermissions,
  noFavorites,
  noHistory,
  noNotifications,
  noCart,
  custom,
}

class EmptyStateAction {
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const EmptyStateAction({
    required this.label,
    required this.onTap,
    this.color,
  });
}

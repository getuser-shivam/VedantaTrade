import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';
import 'package:vedanta_trade/app/theme/enhanced_app_theme.dart';

/// Enhanced Navigation with Hero animations and smooth transitions
class EnhancedNavigation extends StatelessWidget {
  final Widget child;
  final bool enableHeroAnimations;
  final Duration transitionDuration;
  final Curve transitionCurve;

  const EnhancedNavigation({
    Key? key,
    required this.child,
    this.enableHeroAnimations = true,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.transitionCurve = Curves.easeInOut,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'VedantaTrade',
      theme: EnhancedAppTheme.lightTheme,
      darkTheme: EnhancedAppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: _buildRouterConfig(),
      builder: (context, child) {
        return _buildEnhancedApp(context, child!);
      },
    );
  }

  ThemeData _buildTheme() {
    return EnhancedAppTheme.lightTheme;
  }

  GoRouter _buildRouterConfig() {
    // Implementation would go here
    return GoRouter(
      routes: [],
      initialLocation: '/',
    );
  }

  Widget _buildEnhancedApp(BuildContext context, Widget child) {
    return EnhancedUIWrapper(
      child: child,
    );
  }
}

/// Enhanced UI Wrapper for global improvements
class EnhancedUIWrapper extends StatefulWidget {
  final Widget child;

  const EnhancedUIWrapper({Key? key, required this.child}) : super(key: key);

  @override
  State<EnhancedUIWrapper> createState() => _EnhancedUIWrapperState();
}

class _EnhancedUIWrapperState extends State<EnhancedUIWrapper>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_fadeController, _scaleController]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Material(
              color: Theme.of(context).colorScheme.surface,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

/// Enhanced Bottom Navigation Bar
class EnhancedBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<EnhancedBottomNavigationBarItem> items;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final bool showLabels;
  final bool enableLottie;

  const EnhancedBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.showLabels = true,
    this.enableLottie = false,
  }) : super(key: key);

  @override
  State<EnhancedBottomNavigationBar> createState() => _EnhancedBottomNavigationBarState();
}

class _EnhancedBottomNavigationBarState extends State<EnhancedBottomNavigationBar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _animation.value) * 100),
          child: Opacity(
            opacity: _animation.value,
            child: Container(
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: widget.items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final isSelected = index == widget.currentIndex;
                      
                      return _buildNavItem(item, isSelected, index);
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(EnhancedBottomNavigationBarItem item, bool isSelected, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected 
                ? (widget.selectedItemColor ?? EnhancedAppTheme.primaryColor).withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon or Lottie
              Container(
                width: 24,
                height: 24,
                child: widget.enableLottie && item.lottieAsset != null
                    ? Lottie.asset(
                        item.lottieAsset!,
                        animate: isSelected,
                      )
                    : Icon(
                        item.icon,
                        color: isSelected
                            ? widget.selectedItemColor ?? EnhancedAppTheme.primaryColor
                            : widget.unselectedItemColor ?? Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        size: 24,
                      ),
              ),
              
              // Label
              if (widget.showLabels) ...[
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    color: isSelected
                        ? widget.selectedItemColor ?? EnhancedAppTheme.primaryColor
                        : widget.unselectedItemColor ?? Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontSize: isSelected ? 12 : 10,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  child: Text(item.label),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class EnhancedBottomNavigationBarItem {
  final IconData icon;
  final String label;
  final String? lottieAsset;

  EnhancedBottomNavigationBarItem({
    required this.icon,
    required this.label,
    this.lottieAsset,
  });
}

/// Enhanced App Bar
class EnhancedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool centerTitle;
  final TextStyle? titleStyle;
  final bool enableLottie;
  final String? lottieAsset;
  final bool showSearch;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final bool isSearchExpanded;
  final VoidCallback? onSearchToggle;

  const EnhancedAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.centerTitle = true,
    this.titleStyle,
    this.enableLottie = false,
    this.lottieAsset,
    this.showSearch = false,
    this.searchController,
    this.onSearchChanged,
    this.isSearchExpanded = false,
    this.onSearchToggle,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 16);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.surface,
        boxShadow: elevation != null && elevation! > 0
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Leading widget
              if (leading != null)
                leading!
              else if (automaticallyImplyLeading)
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.arrow_back,
                    color: foregroundColor ?? Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              
              // Lottie or Title
              if (enableLottie && lottieAsset != null && !isSearchExpanded)
                Expanded(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: Lottie.asset(lottieAsset!),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: titleStyle ??
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: foregroundColor ?? Theme.of(context).colorScheme.onSurface,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )
              else if (!isSearchExpanded)
                Expanded(
                  child: Text(
                    title,
                    style: titleStyle ??
                        Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: foregroundColor ?? Theme.of(context).colorScheme.onSurface,
                            ),
                    textAlign: centerTitle ? TextAlign.center : TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              
              // Search bar
              if (showSearch) ...[
                if (isSearchExpanded)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                        ),
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: onSearchChanged,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                          suffixIcon: IconButton(
                            onPressed: onSearchToggle,
                            icon: Icon(
                              Icons.close,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  IconButton(
                    onPressed: onSearchToggle,
                    icon: Icon(
                      Icons.search,
                      color: foregroundColor ?? Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
              ],
              
              // Actions
              if (actions != null) ...actions,
            ],
          ),
        ),
      ),
    );
  }
}

/// Enhanced Floating Action Button
class EnhancedFloatingActionButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool enableLottie;
  final String? lottieAsset;
  final bool mini;
  final ShapeBorder? shape;

  const EnhancedFloatingActionButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.enableLottie = false,
    this.lottieAsset,
    this.mini = false,
    this.shape,
  }) : super(key: key);

  @override
  State<EnhancedFloatingActionButton> createState() => _EnhancedFloatingActionButtonState();
}

class _EnhancedFloatingActionButtonState extends State<EnhancedFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.mediumImpact();
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.mini ? 48 : 56,
            height: widget.mini ? 48 : 56,
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? Theme.of(context).colorScheme.primary,
              shape: widget.shape ?? const CircleBorder(),
              boxShadow: [
                BoxShadow(
                  color: (widget.backgroundColor ?? Theme.of(context).colorScheme.primary).withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(widget.mini ? 24 : 28),
                onTap: _handleTap,
                child: Center(
                  child: widget.enableLottie && widget.lottieAsset != null
                      ? SizedBox(
                          width: widget.mini ? 20 : 24,
                          height: widget.mini ? 20 : 24,
                          child: Lottie.asset(widget.lottieAsset!),
                        )
                      : IconTheme(
                          data: IconThemeData(
                            color: widget.foregroundColor ?? Theme.of(context).colorScheme.onPrimary,
                            size: widget.mini ? 20 : 24,
                          ),
                          child: widget.child,
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

  Widget _buildEnhancedApp(BuildContext context, Widget child) {
    return Material(
      color: AppTheme.bgDark,
      child: AnimatedTheme(
        duration: transitionDuration,
        curve: transitionCurve,
        child: child,
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppTheme.primary,
        secondary: AppTheme.secondary,
        surface: AppTheme.surfaceDark,
        background: AppTheme.bgDark,
        error: AppTheme.error,
      ),
      scaffoldBackgroundColor: AppTheme.bgDark,
      appBarTheme: AppBarTheme(
        backgroundColor: AppTheme.surfaceDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 24,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      cardTheme: CardTheme(
        color: AppTheme.cardDark,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  GoRouter _buildRouterConfig() {
    // This would be implemented with actual routes
    return GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('VedantaTrade')),
          ),
        ),
      ],
    );
  }
}

/// Hero Animation Wrapper for smooth transitions
class HeroWrapper extends StatelessWidget {
  final String tag;
  final Widget child;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final BoxShape? shape;

  const HeroWrapper({
    Key? key,
    required this.tag,
    required this.child,
    this.backgroundColor,
    this.borderRadius,
    this.shape,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      flightShuttleBuilder: (flightContext, animation, direction, fromContext, toContext) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                color: backgroundColor ?? AppTheme.glassBg,
                borderRadius: borderRadius ?? BorderRadius.circular(16),
                shape: shape ?? BoxShape.rectangle,
              ),
              child: child,
            );
          },
          child: child,
        );
      },
      child: Material(
        color: Colors.transparent,
        child: child,
      ),
    );
  }
}

/// Animated Page Transition
class AnimatedPageTransition extends PageRouteBuilder {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final SlideDirection direction;

  AnimatedPageTransition({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.direction = SlideDirection.right,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _buildTransition(animation, child);
          },
        );

  Widget _buildTransition(Animation<double> animation, Widget child) {
    Offset begin;
    switch (direction) {
      case SlideDirection.up:
        begin = const Offset(0, 1);
        break;
      case SlideDirection.down:
        begin = const Offset(0, -1);
        break;
      case SlideDirection.left:
        begin = const Offset(1, 0);
        break;
      case SlideDirection.right:
        begin = const Offset(-1, 0);
        break;
    }

    return SlideTransition(
      position: Tween<Offset>(
        begin: begin,
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: curve,
      )),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}

enum SlideDirection { up, down, left, right }

/// Enhanced Bottom Navigation with animations
class EnhancedBottomNavigation extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<EnhancedBottomNavItem> items;

  const EnhancedBottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  }) : super(key: key);

  @override
  State<EnhancedBottomNavigation> createState() => _EnhancedBottomNavigationState();
}

class _EnhancedBottomNavigationState extends State<EnhancedBottomNavigation>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animations = List.generate(
      widget.items.length,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOut,
        ),
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(
          top: BorderSide(
            color: AppTheme.glassBorderLight,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: widget.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == widget.currentIndex;

              return Expanded(
                child: GestureDetector(
                  onTap: () => widget.onTap(index),
                  child: AnimatedBuilder(
                    animation: _animations[index],
                    builder: (context, child) {
                      return Transform.scale(
                        scale: isSelected ? 1.1 : 1.0,
                        child: _buildNavItem(item, isSelected, _animations[index].value),
                      );
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(EnhancedBottomNavItem item, bool isSelected, double animationValue) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: isSelected ? const EdgeInsets.all(8) : EdgeInsets.zero,
            decoration: isSelected
                ? BoxDecoration(
                    color: item.color?.withOpacity(0.2) ?? AppTheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  )
                : null,
            child: Icon(
              item.icon,
              size: 24,
              color: isSelected
                  ? (item.color ?? AppTheme.primary)
                  : AppTheme.glassBorderLight,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedOpacity(
            opacity: isSelected ? 1.0 : 0.6,
            duration: const Duration(milliseconds: 200),
            child: Text(
              item.label,
              style: TextStyle(
                color: isSelected
                    ? (item.color ?? AppTheme.primary)
                    : AppTheme.glassBorderLight,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EnhancedBottomNavItem {
  final IconData icon;
  final String label;
  final Color? color;

  const EnhancedBottomNavItem({
    required this.icon,
    required this.label,
    this.color,
  });
}

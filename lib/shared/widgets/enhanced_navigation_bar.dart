import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'premium_glassmorphic_theme.dart';

/// Enhanced Navigation Bar with Glassmorphic Design
/// Modern navigation with haptic feedback and animations
class EnhancedNavigationBar extends StatefulWidget implements PreferredSizeWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final List<NavigationItem> items;
  final bool showLabels;
  final double? height;
  final Color? backgroundColor;
  final bool enableHapticFeedback;

  const EnhancedNavigationBar({
    Key? key,
    required this.currentIndex,
    this.onTap,
    required this.items,
    this.showLabels = true,
    this.height,
    this.backgroundColor,
    this.enableHapticFeedback = true,
  }) : super(key: key);

  @override
  State<EnhancedNavigationBar> createState() => _EnhancedNavigationBarState();

  @override
  Size get preferredSize => const Size.fromHeight(65);

  static double _calculateHeight(bool showLabels) {
    return showLabels ? 65.0 : 56.0;
  }
}

class _EnhancedNavigationBarState extends State<EnhancedNavigationBar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _itemAnimations;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: PremiumGlassmorphicTheme._mediumAnimation,
      vsync: this,
    );
    
    _itemAnimations = List.generate(
      widget.items.length,
      (index) => Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          index * 0.1,
          (index + 1) * 0.1,
          curve: Curves.easeOutCubic,
        ),
      )),
    );

    _scaleAnimations = List.generate(
      widget.items.length,
      (index) => Tween<double>(
        begin: 1.0,
        end: 1.2,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          index * 0.1,
          (index + 1) * 0.1,
          curve: Curves.elasticOut,
        ),
      )),
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
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenHeight > 800;

    return Container(
      height: widget.height ?? _calculateHeight(widget.showLabels),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: PremiumGlassmorphicTheme._spacingMD,
            vertical: PremiumGlassmorphicTheme._spacingSM,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildNavigationItems(context, isTablet),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNavigationItems(BuildContext context, bool isTablet) {
    return widget.items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isSelected = index == widget.currentIndex;

      return Expanded(
        child: GestureDetector(
          onTap: () {
            if (widget.enableHapticFeedback) {
              PremiumGlassmorphicTheme.triggerHapticFeedback(
                isSelected ? HapticFeedbackType.selection : HapticFeedbackType.light,
              );
            }
            widget.onTap?.call(index);
          },
          child: AnimatedBuilder(
            animation: _scaleAnimations[index],
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimations[index].value,
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: isTablet 
                        ? PremiumGlassmorphicTheme._spacingSM 
                        : PremiumGlassmorphicTheme._spacingXS,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Navigation Icon
                      AnimatedBuilder(
                        animation: _itemAnimations[index],
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, (1 - _itemAnimations[index].value) * 10),
                            child: Container(
                              padding: EdgeInsets.all(
                                isSelected 
                                    ? PremiumGlassmorphicTheme._spacingSM 
                                    : PremiumGlassmorphicTheme._spacingXS,
                              ),
                              decoration: isSelected
                                  ? PremiumGlassmorphicTheme.getGlassmorphicCardDecoration(
                                      backgroundColor: item.activeColor ?? PremiumGlassmorphicTheme._primaryColor,
                                      opacity: 0.3,
                                    )
                                  : null,
                              child: Icon(
                                item.icon,
                                size: isTablet ? 24 : 20,
                                color: isSelected
                                    ? Colors.white
                                    : item.color ?? theme.iconTheme.color,
                              ),
                            ),
                          );
                        },
                      ),
                      
                      // Navigation Label
                      if (widget.showLabels) ...[
                        SizedBox(height: PremiumGlassmorphicTheme._spacingXS),
                        AnimatedOpacity(
                          opacity: _itemAnimations[index].value,
                          duration: PremiumGlassmorphicTheme._shortAnimation,
                          child: Text(
                            item.label,
                            style: isTablet 
                                ? PremiumGlassmorphicTheme._bodyMedium.copyWith(
                                    color: isSelected ? Colors.white : item.color,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  )
                                : PremiumGlassmorphicTheme._bodySmall.copyWith(
                                    color: isSelected ? Colors.white : item.color,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      
                      // Active Indicator
                      if (isSelected) ...[
                        SizedBox(height: PremiumGlassmorphicTheme._spacingXS),
                        AnimatedContainer(
                          duration: PremiumGlassmorphicTheme._shortAnimation,
                          decoration: BoxDecoration(
                            color: item.activeColor ?? PremiumGlassmorphicTheme._primaryColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}

/// Navigation Item Model
class NavigationItem {
  final IconData icon;
  final String label;
  final Color? color;
  final Color? activeColor;
  final String? badge;
  final bool showBadge;

  const NavigationItem({
    required this.icon,
    required this.label,
    this.color,
    this.activeColor,
    this.badge,
    this.showBadge = false,
  });
}

/// Bottom Navigation Bar with Glassmorphic Design
class EnhancedBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final List<NavigationItem> items;
  final Color? backgroundColor;
  final bool enableHapticFeedback;
  final double? elevation;

  const EnhancedBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    this.onTap,
    required this.items,
    this.backgroundColor,
    this.enableHapticFeedback = true,
    this.elevation,
  }) : super(key: key);

  @override
  State<EnhancedBottomNavigationBar> createState() => _EnhancedBottomNavigationBarState();
}

class _EnhancedBottomNavigationBarState extends State<EnhancedBottomNavigationBar>
    with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late List<Animation<double>> _rippleAnimations;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      duration: PremiumGlassmorphicTheme._shortAnimation,
      vsync: this,
    );
    
    _rippleAnimations = List.generate(
      widget.items.length,
      (index) => Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _rippleController,
        curve: Curves.easeOut,
      )),
    );
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenHeight > 800;

    return Container(
      height: isTablet ? 80 : 70,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 25,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
          bottom: Radius.circular(0),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(_glassBlur, TileMode.mirror),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PremiumGlassmorphicTheme._spacingSM,
                  vertical: PremiumGlassmorphicTheme._spacingXS,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: widget.items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isSelected = index == widget.currentIndex;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (widget.enableHapticFeedback) {
                            PremiumGlassmorphicTheme.triggerHapticFeedback(
                              HapticFeedbackType.light,
                            );
                          }
                          
                          // Start ripple animation
                          _rippleController.reset();
                          _rippleController.forward();
                          
                          widget.onTap?.call(index);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: PremiumGlassmorphicTheme._spacingSM,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Navigation Icon
                              Container(
                                padding: EdgeInsets.all(
                                  isSelected 
                                      ? PremiumGlassmorphicTheme._spacingSM 
                                      : PremiumGlassmorphicTheme._spacingXS,
                                ),
                                decoration: isSelected
                                    ? PremiumGlassmorphicTheme.getGlassmorphicCardDecoration(
                                        backgroundColor: item.activeColor ?? PremiumGlassmorphicTheme._primaryColor,
                                        opacity: 0.4,
                                      )
                                    : null,
                                child: Icon(
                                  item.icon,
                                  size: isTablet ? 26 : 22,
                                  color: isSelected
                                      ? Colors.white
                                      : item.color ?? theme.iconTheme.color,
                                ),
                              ),
                              
                              // Navigation Label
                              if (widget.showLabels) ...[
                                SizedBox(height: PremiumGlassmorphicTheme._spacingXS),
                                Text(
                                  item.label,
                                  style: isTablet 
                                      ? PremiumGlassmorphicTheme._bodySmall.copyWith(
                                          color: isSelected ? Colors.white : item.color,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                        )
                                      : PremiumGlassmorphicTheme._bodySmall.copyWith(
                                          color: isSelected ? Colors.white : item.color,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                        ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              
                              // Badge
                              if (item.showBadge && item.badge != null) ...[
                                SizedBox(height: PremiumGlassmorphicTheme._spacingXS),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: PremiumGlassmorphicTheme._spacingXS,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: PremiumGlassmorphicTheme._errorColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    item.badge!,
                                    style: PremiumGlassmorphicTheme._bodySmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                              
                              // Active Indicator
                              if (isSelected) ...[
                                SizedBox(height: PremiumGlassmorphicTheme._spacingXS),
                                AnimatedContainer(
                                  duration: PremiumGlassmorphicTheme._shortAnimation,
                                  decoration: BoxDecoration(
                                    color: item.activeColor ?? PremiumGlassmorphicTheme._primaryColor,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

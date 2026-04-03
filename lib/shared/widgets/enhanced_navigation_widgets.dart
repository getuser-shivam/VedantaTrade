import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/enhanced_theme_provider.dart';

class AnimatedBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavigationItem> items;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double? iconSize;
  final double? elevation;
  final bool enableAnimation;
  final Duration animationDuration;
  final Curve animationCurve;

  const AnimatedBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.iconSize = 24.0,
    this.elevation = 8.0,
    this.enableAnimation = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
  }) : super(key: key);

  @override
  State<AnimatedBottomNavigationBar> createState() => _AnimatedBottomNavigationBarState();
}

class _AnimatedBottomNavigationBarState extends State<AnimatedBottomNavigationBar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<AnimationController> _itemControllers;
  late List<Animation<double>> _itemAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _itemControllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: widget.animationDuration,
        vsync: this,
      ),
    );
    
    _itemAnimations = _itemControllers
        .map((controller) => Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: controller,
              curve: widget.animationCurve,
            )))
        .toList();
    
    // Initialize selected item
    _itemControllers[widget.currentIndex].forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var controller in _itemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == widget.currentIndex) return;
    
    // Animate previous item out
    _itemControllers[widget.currentIndex].reverse();
    
    // Animate new item in
    _itemControllers[index].forward();
    
    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<EnhancedThemeProvider>();
    final backgroundColor = widget.backgroundColor ?? themeProvider.backgroundSecondary;
    final selectedItemColor = widget.selectedItemColor ?? themeProvider.primaryColor;
    final unselectedItemColor = widget.unselectedItemColor ?? themeProvider.textSecondary;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: widget.elevation!,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: widget.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == widget.currentIndex;
              
              return _buildNavigationItem(
                index: index,
                item: item,
                isSelected: isSelected,
                selectedItemColor: selectedItemColor,
                unselectedItemColor: unselectedItemColor,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem({
    required int index,
    required NavigationItem item,
    required bool isSelected,
    required Color selectedItemColor,
    required Color unselectedItemColor,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        child: AnimatedBuilder(
          animation: _itemAnimations[index],
          builder: (context, child) {
            final animationValue = _itemAnimations[index].value;
            
            return Transform.scale(
              scale: 0.8 + (animationValue * 0.2),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: widget.animationDuration,
                      curve: widget.animationCurve,
                      padding: EdgeInsets.all(animationValue * 8),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [
                                  selectedItemColor.withOpacity(0.2),
                                  selectedItemColor.withOpacity(0.1),
                                ],
                              )
                            : null,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        item.icon,
                        size: widget.iconSize,
                        color: isSelected
                            ? selectedItemColor
                            : unselectedItemColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedOpacity(
                      duration: widget.animationDuration,
                      opacity: isSelected ? 1.0 : 0.6,
                      child: Text(
                        item.label,
                        style: TextStyle(
                          color: isSelected
                              ? selectedItemColor
                              : unselectedItemColor,
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final String? badge;

  const NavigationItem({
    required this.icon,
    required this.label,
    this.badge,
  });
}

// Enhanced Floating Action Button with animations
class EnhancedFloatingActionButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool enableAnimation;
  final Duration animationDuration;
  final Curve animationCurve;
  final List<Widget> children;

  const EnhancedFloatingActionButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 6.0,
    this.enableAnimation = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutBack,
    this.children = const [],
  }) : super(key: key);

  @override
  State<EnhancedFloatingActionButton> createState() => _EnhancedFloatingActionButtonState();
}

class _EnhancedFloatingActionButtonState extends State<EnhancedFloatingActionButton>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.75,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: widget.animationCurve,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: widget.animationCurve,
    ));
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    if (_isExpanded) {
      _rotationController.forward();
      _scaleController.forward();
    } else {
      _rotationController.reverse();
      _scaleController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<EnhancedThemeProvider>();
    final backgroundColor = widget.backgroundColor ?? themeProvider.primaryColor;
    final foregroundColor = widget.foregroundColor ?? Colors.white;

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Expanded children
        if (widget.children.isNotEmpty)
          ...widget.children.asMap().entries.map((entry) {
            final index = entry.key;
            final child = entry.value;
            
            return AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, _) {
                return Transform.translate(
                  offset: Offset(
                    0,
                    -(_isExpanded ? (index + 1) * 70 : 0) * _scaleAnimation.value,
                  ),
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Opacity(
                      opacity: _scaleAnimation.value,
                      child: child,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        
        // Main FAB
        Positioned(
          bottom: 16,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Label
              if (widget.label != null && _isExpanded)
                AnimatedContainer(
                  duration: widget.animationDuration,
                  curve: widget.animationCurve,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    widget.label!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              
              // FAB Button
              AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationAnimation.value * 2 * 3.14159,
                    child: FloatingActionButton(
                      onPressed: widget.children.isNotEmpty
                          ? _toggleExpanded
                          : widget.onPressed,
                      backgroundColor: backgroundColor,
                      foregroundColor: foregroundColor,
                      elevation: widget.elevation,
                      child: Icon(widget.icon),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Enhanced App Bar with animations
class EnhancedAppBar extends StatefulWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool enableAnimation;
  final Duration animationDuration;
  final Curve animationCurve;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const EnhancedAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0.0,
    this.enableAnimation = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
    this.showBackButton = true,
    this.onBackPressed,
  }) : super(key: key);

  @override
  State<EnhancedAppBar> createState() => _EnhancedAppBarState();
}

class _EnhancedAppBarState extends State<EnhancedAppBar>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: widget.animationCurve,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: widget.animationCurve,
    ));
    
    // Start animations
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<EnhancedThemeProvider>();
    final backgroundColor = widget.backgroundColor ?? Colors.transparent;
    final foregroundColor = widget.foregroundColor ?? themeProvider.textPrimary;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            boxShadow: widget.elevation! > 0
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: widget.elevation!,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: SafeArea(
            child: Row(
              children: [
                // Leading widget
                if (widget.leading != null)
                  widget.leading!
                else if (widget.showBackButton && widget.automaticallyImplyLeading)
                  IconButton(
                    onPressed: widget.onBackPressed ?? () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.arrow_back,
                      color: foregroundColor,
                    ),
                  ),
                
                // Title
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      color: foregroundColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                // Actions
                if (widget.actions != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: widget.actions!,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Enhanced Sliver App Bar with hero animation
class EnhancedSliverAppBar extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Widget? background;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final double? expandedHeight;
  final double? collapsedHeight;
  final bool floating;
  final bool pinned;
  final bool snap;
  final bool enableAnimation;
  final Duration animationDuration;
  final Curve animationCurve;
  final VoidCallback? onBackPressed;

  const EnhancedSliverAppBar({
    Key? key,
    required this.title,
    this.subtitle,
    this.background,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.expandedHeight = 200.0,
    this.collapsedHeight = kToolbarHeight,
    this.floating = false,
    this.pinned = true,
    this.snap = false,
    this.enableAnimation = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
    this.onBackPressed,
  }) : super(key: key);

  @override
  State<EnhancedSliverAppBar> createState() => _EnhancedSliverAppBarState();
}

class _EnhancedSliverAppBarState extends State<EnhancedSliverAppBar>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: widget.animationCurve,
    ));
    
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<EnhancedThemeProvider>();

    return SliverAppBar(
      expandedHeight: widget.expandedHeight,
      collapsedHeight: widget.collapsedHeight,
      floating: widget.floating,
      pinned: widget.pinned,
      snap: widget.snap,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: widget.leading,
      automaticallyImplyLeading: widget.automaticallyImplyLeading,
      actions: widget.actions,
      flexibleSpace: FlexibleSpaceBar(
        title: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (widget.subtitle != null)
                Text(
                  widget.subtitle!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ),
        background: widget.background ??
            Container(
              decoration: BoxDecoration(
                gradient: themeProvider.primaryGradient,
              ),
              child: Stack(
                children: [
                  // Decorative elements
                  Positioned(
                    top: 50,
                    right: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                left: -50,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
                ],
              ),
            ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/enhanced_app_theme.dart';
import '../constants/app_constants.dart';

class EnhancedNavigation extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isExpanded;
  final VoidCallback? onToggleExpansion;
  final List<NavigationItem> items;
  final String? selectedCategory;
  final Function(String?)? onCategorySelected;

  const EnhancedNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.isExpanded = true,
    this.onToggleExpansion,
    this.items = const [],
    this.selectedCategory,
    this.onCategorySelected,
  }) : super(key: key);

  @override
  State<EnhancedNavigation> createState() => _EnhancedNavigationState();
}

class _EnhancedNavigationState extends State<EnhancedNavigation>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  String? _hoveredItem;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.defaultAnimationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1200;
    final isTablet = MediaQuery.of(context).size.width >= 768;

    if (isDesktop) {
      return _buildDesktopNavigation();
    } else if (isTablet) {
      return _buildTabletNavigation();
    } else {
      return _buildMobileNavigation();
    }
  }

  Widget _buildDesktopNavigation() {
    return Container(
      height: double.infinity,
      width: widget.isExpanded ? 280 : 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            EnhancedAppTheme.getPrimaryColor(context).withOpacity(0.95),
            EnhancedAppTheme.getPrimaryColor(context),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildNavigationItems()),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildTabletNavigation() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            EnhancedAppTheme.getPrimaryColor(context).withOpacity(0.95),
            EnhancedAppTheme.getPrimaryColor(context),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          _buildTabletLogo(),
          const Spacer(),
          _buildTabletNavigationItems(),
          const Spacer(),
          _buildUserAvatar(),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _buildMobileNavigation() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            EnhancedAppTheme.getPrimaryColor(context).withOpacity(0.95),
            EnhancedAppTheme.getPrimaryColor(context),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          _buildMobileLogo(),
          const Spacer(),
          _buildMobileNavigationItems(),
          const Spacer(),
          _buildUserAvatar(),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              );
            },
            child: Container(
              width: widget.isExpanded ? 40 : 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.medical_services,
                  color: EnhancedAppTheme.getPrimaryColor(context),
                  size: 24,
                ),
              ),
            ),
          ),
          if (widget.isExpanded) ...[
            const SizedBox(width: 12),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VedantaTrade',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Pharma Distribution',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (widget.isExpanded) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: widget.onToggleExpansion,
              child: Icon(
                Icons.menu_open,
                color: Colors.white.withOpacity(0.8),
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabletLogo() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.medical_services,
          color: EnhancedAppTheme.getPrimaryColor(context),
          size: 24,
        ),
      ),
    );
  }

  Widget _buildMobileLogo() {
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.medical_services,
          color: EnhancedAppTheme.getPrimaryColor(context),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildNavigationItems() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: widget.items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final item = widget.items[index];
        final isSelected = widget.currentIndex == index;
        
        return _NavigationItemWidget(
          item: item,
          isSelected: isSelected,
          isExpanded: widget.isExpanded,
          onTap: () => _handleNavigationTap(index),
          onHover: (isHovered) {
            setState(() {
              _hoveredItem = isHovered ? item.id : null;
            });
          },
          isHovered: _hoveredItem == item.id,
        );
      },
    );
  }

  Widget _buildTabletNavigationItems() {
    return Row(
      children: widget.items.map((item) {
        final index = widget.items.indexOf(item);
        final isSelected = widget.currentIndex == index;
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: _TabletNavigationItem(
            item: item,
            isSelected: isSelected,
            onTap: () => _handleNavigationTap(index),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMobileNavigationItems() {
    return Row(
      children: widget.items.map((item) {
        final index = widget.items.indexOf(item);
        final isSelected = widget.currentIndex == index;
        
        return Expanded(
          child: _MobileNavigationItem(
            item: item,
            isSelected: isSelected,
            onTap: () => _handleNavigationTap(index),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUserAvatar() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // Show user menu
      },
      child: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.person,
            color: EnhancedAppTheme.getPrimaryColor(context),
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    if (!widget.isExpanded) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Divider(color: Colors.white24),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.white.withOpacity(0.6),
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Version ${AppConstants.appVersion}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleNavigationTap(int index) {
    HapticFeedback.selectionClick();
    widget.onTap(index);
  }
}

class _NavigationItemWidget extends StatefulWidget {
  final NavigationItem item;
  final bool isSelected;
  final bool isExpanded;
  final VoidCallback onTap;
  final Function(bool) onHover;
  final bool isHovered;

  const _NavigationItemWidget({
    Key? key,
    required this.item,
    required this.isSelected,
    required this.isExpanded,
    required this.onTap,
    required this.onHover,
    required this.isHovered,
  }) : super(key: key);

  @override
  State<_NavigationItemWidget> createState() => _NavigationItemWidgetState();
}

class _NavigationItemWidgetState extends State<_NavigationItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _colorAnimation = ColorTween(
      begin: Colors.white.withOpacity(0.8),
      end: Colors.white,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => widget.onHover(true),
      onExit: (_) => widget.onHover(false),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => _animationController.forward(),
        onTapUp: (_) => _animationController.reverse(),
        onTapCancel: () => _animationController.reverse(),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: widget.isHovered ? _scaleAnimation.value : 1.0,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                padding: EdgeInsets.symmetric(
                  horizontal: widget.isExpanded ? 16 : 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? Colors.white.withOpacity(0.2)
                      : (widget.isHovered
                          ? Colors.white.withOpacity(0.1)
                          : Colors.transparent),
                  borderRadius: BorderRadius.circular(12),
                  border: widget.isSelected
                      ? Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 1,
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.item.icon,
                      color: widget.isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(0.8),
                      size: 24,
                    ),
                    if (widget.isExpanded) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.item.label,
                              style: TextStyle(
                                color: widget.isSelected
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.8),
                                fontSize: 14,
                                fontWeight: widget.isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (widget.item.subtitle != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                widget.item.subtitle!,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    if (widget.item.badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          widget.item.badge!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
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

class _TabletNavigationItem extends StatelessWidget {
  final NavigationItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabletNavigationItem({
    Key? key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: isSelected
                  ? Colors.white
                  : Colors.white.withOpacity(0.8),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withOpacity(0.8),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileNavigationItem extends StatelessWidget {
  final NavigationItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _MobileNavigationItem({
    Key? key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: isSelected
                  ? Colors.white
                  : Colors.white.withOpacity(0.6),
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withOpacity(0.6),
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationItem {
  final String id;
  final String label;
  final String? subtitle;
  final IconData icon;
  final String? badge;
  final List<NavigationItem>? children;
  final String? route;

  const NavigationItem({
    required this.id,
    required this.label,
    this.subtitle,
    required this.icon,
    this.badge,
    this.children,
    this.route,
  });
}

class NavigationCategories extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final Function(String?) onCategorySelected;

  const NavigationCategories({
    Key? key,
    required this.categories,
    this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.category,
            color: EnhancedAppTheme.getPrimaryColor(context),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length + 1,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _CategoryChip(
                    label: 'All',
                    isSelected: selectedCategory == null,
                    onTap: () => onCategorySelected(null),
                  );
                }
                
                final category = categories[index - 1];
                return _CategoryChip(
                  label: category,
                  isSelected: selectedCategory == category,
                  onTap: () => onCategorySelected(category),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? EnhancedAppTheme.getPrimaryColor(context)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(color: Colors.grey[300]!),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : Colors.grey[700],
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class QuickActions extends StatelessWidget {
  final List<QuickAction> actions;

  const QuickActions({
    Key? key,
    required this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: EnhancedAppTheme.getTextColor(context),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: actions.map((action) => _QuickActionWidget(action: action)).toList(),
          ),
        ],
      ),
    );
  }
}

class _QuickActionWidget extends StatelessWidget {
  final QuickAction action;

  const _QuickActionWidget({
    Key? key,
    required this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        width: 100,
        height: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: action.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: action.color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              action.icon,
              color: action.color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              action.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: action.color,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class BreadcrumbNavigation extends StatelessWidget {
  final List<BreadcrumbItem> items;

  const BreadcrumbNavigation({
    Key? key,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.home,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  if (i > 0) ...[
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 8),
                  ],
                  GestureDetector(
                    onTap: items[i].onTap,
                    child: Text(
                      items[i].label,
                      style: TextStyle(
                        color: i == items.length - 1
                            ? EnhancedAppTheme.getPrimaryColor(context)
                            : Colors.grey[600],
                        fontSize: 14,
                        fontWeight: i == items.length - 1
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BreadcrumbItem {
  final String label;
  final VoidCallback? onTap;

  const BreadcrumbItem({
    required this.label,
    this.onTap,
  });
}

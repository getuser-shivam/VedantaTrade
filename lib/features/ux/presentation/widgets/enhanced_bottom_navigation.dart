import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/premium_glassmorphic_theme.dart';

class EnhancedBottomNavigation extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavigationBarItem> items;

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
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _animations = List.generate(
      widget.items.length,
      (index) => Tween<double>(
        begin: 0.8,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          index * 0.1,
          (index + 1) * 0.2,
          curve: Curves.easeOutCubic,
        ),
      )),
    );
    
    _slideAnimations = List.generate(
      widget.items.length,
      (index) => Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          index * 0.1,
          (index + 1) * 0.2,
          curve: Curves.easeOutCubic,
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            PremiumGlassmorphicTheme.slate800.withOpacity(0.95),
            PremiumGlassmorphicTheme.slate900.withOpacity(0.98),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: PremiumGlassmorphicTheme.borderMedium,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PremiumGlassmorphicTheme.spacingMd,
            vertical: PremiumGlassmorphicTheme.spacingSm,
          ),
          child: Row(
            children: List.generate(
              widget.items.length,
              (index) => _buildNavigationItem(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem(int index) {
    final item = widget.items[index];
    final isSelected = index == widget.currentIndex;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onTap(index),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                return SlideTransition(
                  position: _slideAnimations[index],
                  child: FadeTransition(
                    opacity: _animations[index],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon Container
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? PremiumGlassmorphicTheme.indigo600.withOpacity(0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(PremiumGlassmorphicTheme.radiusLg),
                            border: isSelected
                                ? Border.all(
                                    color: PremiumGlassmorphicTheme.indigo500.withOpacity(0.5),
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: Stack(
                            children: [
                              // Icon
                              Center(
                                child: Icon(
                                  item.icon,
                                  color: isSelected
                                      ? PremiumGlassmorphicTheme.indigo500
                                      : PremiumGlassmorphicTheme.textSecondary,
                                  size: 24,
                                ),
                              ),
                              
                              // Badge
                              if (item.badge != null)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: item.badgeColor ?? PremiumGlassmorphicTheme.error,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: PremiumGlassmorphicTheme.slate900,
                                        width: 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        item.badge!,
                                        style: const TextStyle(
                                          color: PremiumGlassmorphicTheme.textPrimary,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: PremiumGlassmorphicTheme.spacingXs),
                        
                        // Label
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            item.label,
                            key: ValueKey(item.label),
                            style: TextStyle(
                              color: isSelected
                                  ? PremiumGlassmorphicTheme.indigo500
                                  : PremiumGlassmorphicTheme.textSecondary,
                              fontSize: PremiumGlassmorphicTheme.fontSizeXs,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class BottomNavigationBarItem {
  final IconData icon;
  final String label;
  final String? badge;
  final Color? badgeColor;

  const BottomNavigationBarItem({
    required this.icon,
    required this.label,
    this.badge,
    this.badgeColor,
  });
}

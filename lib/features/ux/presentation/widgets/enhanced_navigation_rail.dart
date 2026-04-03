import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/premium_glassmorphic_theme.dart';

class EnhancedNavigationRail extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavigationRailItem> items;

  const EnhancedNavigationRail({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  }) : super(key: key);

  @override
  State<EnhancedNavigationRail> createState() => _EnhancedNavigationRailState();
}

class _EnhancedNavigationRailState extends State<EnhancedNavigationRail>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
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
    return SlideTransition(
      position: Offset(0.0, _slideAnimation.value),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: 280,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                PremiumGlassmorphicTheme.slate800.withOpacity(0.95),
                PremiumGlassmorphicTheme.slate900.withOpacity(0.95),
              ],
            ),
            border: Border(
              right: BorderSide(
                color: PremiumGlassmorphicTheme.borderMedium,
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Navigation Items
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    vertical: PremiumGlassmorphicTheme.spacingSm,
                  ),
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    final isSelected = index == widget.currentIndex;
                    
                    return _buildNavigationItem(
                      item,
                      isSelected,
                      () => widget.onTap(index),
                    );
                  },
                ),
              ),
              
              // Footer
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingLg),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: PremiumGlassmorphicTheme.borderMedium,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: PremiumGlassmorphicTheme.indigo600.withOpacity(0.2),
              border: Border.all(
                color: PremiumGlassmorphicTheme.indigo500.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.medication,
              color: PremiumGlassmorphicTheme.indigo500,
              size: 30,
            ),
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
          
          // App Name
          const Text(
            'VedantaTrade',
            style: TextStyle(
              color: PremiumGlassmorphicTheme.textPrimary,
              fontSize: PremiumGlassmorphicTheme.fontSizeLg,
              fontWeight: FontWeight.w700,
            ),
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingXs),
          
          // Subtitle
          const Text(
            'Enterprise Pharma',
            style: TextStyle(
              color: PremiumGlassmorphicTheme.textSecondary,
              fontSize: PremiumGlassmorphicTheme.fontSizeSm,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItem(
    NavigationRailItem item,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PremiumGlassmorphicTheme.spacingMd,
        vertical: PremiumGlassmorphicTheme.spacingXs,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingMd),
          decoration: BoxDecoration(
            color: isSelected
                ? PremiumGlassmorphicTheme.indigo600.withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(PremiumGlassmorphicTheme.radiusMd),
            border: isSelected
                ? Border.all(
                    color: PremiumGlassmorphicTheme.indigo500.withOpacity(0.5),
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            children: [
              // Icon
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  item.icon,
                  color: isSelected
                      ? PremiumGlassmorphicTheme.indigo500
                      : PremiumGlassmorphicTheme.textSecondary,
                  size: 24,
                ),
              ),
              
              const SizedBox(width: PremiumGlassmorphicTheme.spacingMd),
              
              // Text
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    item.label,
                    style: TextStyle(
                      color: isSelected
                          ? PremiumGlassmorphicTheme.indigo500
                          : PremiumGlassmorphicTheme.textPrimary,
                      fontSize: PremiumGlassmorphicTheme.fontSizeMd,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
              
              // Badge
              if (item.badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PremiumGlassmorphicTheme.spacingXs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: item.badgeColor ?? PremiumGlassmorphicTheme.error,
                    borderRadius: BorderRadius.circular(PremiumGlassmorphicTheme.radiusXs),
                  ),
                  child: Text(
                    item.badge!,
                    style: const TextStyle(
                      color: PremiumGlassmorphicTheme.textPrimary,
                      fontSize: PremiumGlassmorphicTheme.fontSizeXs,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingLg),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: PremiumGlassmorphicTheme.borderMedium,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // User Profile
          Consumer<UXEnhancementProvider>(
            builder: (context, provider, child) {
              return GestureDetector(
                onTap: () => _showUserMenu(),
                child: Container(
                  padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingMd),
                  decoration: BoxDecoration(
                    color: PremiumGlassmorphicTheme.surfaceLight.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(PremiumGlassmorphicTheme.radiusMd),
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        backgroundColor: PremiumGlassmorphicTheme.indigo500.withOpacity(0.2),
                        child: const Icon(
                          Icons.person,
                          color: PremiumGlassmorphicTheme.indigo500,
                          size: 20,
                        ),
                      ),
                      
                      const SizedBox(width: PremiumGlassmorphicTheme.spacingMd),
                      
                      // User Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'John Doe', // TODO: Get from user provider
                              style: TextStyle(
                                color: PremiumGlassmorphicTheme.textPrimary,
                                fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: PremiumGlassmorphicTheme.spacingXs),
                            Text(
                              'Administrator', // TODO: Get from user provider
                              style: TextStyle(
                                color: PremiumGlassmorphicTheme.textSecondary,
                                fontSize: PremiumGlassmorphicTheme.fontSizeXs,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Menu Icon
                      const Icon(
                        Icons.keyboard_arrow_up,
                        color: PremiumGlassmorphicTheme.textTertiary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
          
          // Quick Actions
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  Icons.settings,
                  'Settings',
                  () => _showSettings(),
                ),
              ),
              const SizedBox(width: PremiumGlassmorphicTheme.spacingSm),
              Expanded(
                child: _buildQuickActionButton(
                  Icons.help,
                  'Help',
                  () => _showHelp(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingSm),
        decoration: BoxDecoration(
          color: PremiumGlassmorphicTheme.surfaceLight.withOpacity(0.2),
          borderRadius: BorderRadius.circular(PremiumGlassmorphicTheme.radiusSm),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: PremiumGlassmorphicTheme.textSecondary,
              size: 20,
            ),
            const SizedBox(height: PremiumGlassmorphicTheme.spacingXs),
            Text(
              label,
              style: const TextStyle(
                color: PremiumGlassmorphicTheme.textTertiary,
                fontSize: PremiumGlassmorphicTheme.fontSizeXs,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUserMenu() {
    // TODO: Implement user menu
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User menu coming soon!'),
        backgroundColor: PremiumGlassmorphicTheme.success,
      ),
    );
  }

  void _showSettings() {
    // TODO: Navigate to settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings coming soon!'),
        backgroundColor: PremiumGlassmorphicTheme.success,
      ),
    );
  }

  void _showHelp() {
    // TODO: Navigate to help
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Help center coming soon!'),
        backgroundColor: PremiumGlassmorphicTheme.success,
      ),
    );
  }
}

class NavigationRailItem {
  final IconData icon;
  final String label;
  final String? badge;
  final Color? badgeColor;

  const NavigationRailItem({
    required this.icon,
    required this.label,
    this.badge,
    this.badgeColor,
  });
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/premium_glassmorphic_theme.dart';
import '../providers/ux_enhancement_provider.dart';
import '../widgets/enhanced_navigation_rail.dart';
import '../widgets/enhanced_bottom_navigation.dart';
import '../widgets/enhanced_search_bar.dart';
import '../widgets/enhanced_loading_states.dart';
import '../widgets/enhanced_error_states.dart';
import '../widgets/enhanced_empty_states.dart';

class UXEnhancementScreen extends StatefulWidget {
  const UXEnhancementScreen({Key? key}) : super(key: key);

  @override
  State<UXEnhancementScreen> createState() => _UXEnhancementScreenState();
}

class _UXEnhancementScreenState extends State<UXEnhancementScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  bool _isDarkMode = false;
  bool _isCompactMode = false;
  double _textScale = 1.0;
  String _selectedTheme = 'slate';
  bool _isHighContrast = false;
  bool _isReducedMotion = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserPreferences();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
  }

  Future<void> _loadUserPreferences() async {
    final provider = Provider.of<UXEnhancementProvider>(context, listen: false);
    await provider.loadUserPreferences();
    
    setState(() {
      _isDarkMode = provider.isDarkMode;
      _isCompactMode = provider.isCompactMode;
      _textScale = provider.textScale;
      _selectedTheme = provider.selectedTheme;
      _isHighContrast = provider.isHighContrast;
      _isReducedMotion = provider.isReducedMotion;
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UXEnhancementProvider>(
      builder: (context, provider, child) {
        return PremiumGlassmorphicTheme.glassBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: _buildAppBar(),
            body: _buildBody(provider),
            bottomNavigationBar: _buildBottomNavigation(),
            floatingActionButton: _buildFloatingActionButton(),
            drawer: _isCompactMode ? _buildNavigationDrawer() : null,
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PremiumGlassmorphicTheme.glassAppBar(
      title: 'UX Enhancement',
      actions: [
        // Theme Toggle
        IconButton(
          onPressed: _toggleTheme,
          icon: Icon(
            _isDarkMode ? Icons.light_mode : Icons.dark_mode,
            color: PremiumGlassmorphicTheme.textPrimary,
          ),
          tooltip: _isDarkMode ? 'Light Mode' : 'Dark Mode',
        ),
        
        // Accessibility Menu
        PopupMenuButton<String>(
          icon: Icon(
            Icons.accessibility,
            color: PremiumGlassmorphicTheme.textPrimary,
          ),
          tooltip: 'Accessibility Options',
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'high_contrast',
              child: Row(
                children: [
                  Icon(
                    Icons.contrast,
                    color: _isHighContrast ? Colors.blue : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  const Text('High Contrast'),
                  if (_isHighContrast) ...[
                    const Spacer(),
                    const Icon(Icons.check, color: Colors.blue),
                  ],
                ],
              ),
            ),
            PopupMenuItem(
              value: 'reduced_motion',
              child: Row(
                children: [
                  Icon(
                    Icons.motion_photos_pause,
                    color: _isReducedMotion ? Colors.blue : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  const Text('Reduced Motion'),
                  if (_isReducedMotion) ...[
                    const Spacer(),
                    const Icon(Icons.check, color: Colors.blue),
                  ],
                ],
              ),
            ),
            PopupMenuItem(
              value: 'text_size',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Text Size'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildTextSizeButton('A-', () => _adjustTextSize(-0.1)),
                      const SizedBox(width: 8),
                      Text('${_textScale.toStringAsFixed(1)}x'),
                      const SizedBox(width: 8),
                      _buildTextSizeButton('A+', () => _adjustTextSize(0.1)),
                    ],
                  ),
                ],
              ),
            ),
          ],
          onSelected: _handleAccessibilityMenu,
        ),
      ],
    );
  }

  Widget _buildTextSizeButton(String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: PremiumGlassmorphicTheme.surfaceLight.withOpacity(0.3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: PremiumGlassmorphicTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(UXEnhancementProvider provider) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            children: [
              // Enhanced Search Bar
              EnhancedSearchBar(
                onSearch: (query) => _handleSearch(query),
                onFilter: () => _showFilterOptions(),
                placeholder: 'Search products, orders, or users...',
              ),
              
              const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
              
              // Main Content Area
              Expanded(
                child: _buildMainContent(provider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(UXEnhancementProvider provider) {
    return TabBarView(
      children: [
        _buildEnhancedDashboard(),
        _buildAccessibilitySettings(),
        _buildThemeCustomization(),
        _buildPerformanceSettings(),
      ],
    );
  }

  Widget _buildEnhancedDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Actions
          _buildQuickActionsSection(),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingXl),
          
          // Enhanced Cards
          _buildEnhancedCardsSection(),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingXl),
          
          // Interactive Elements
          _buildInteractiveElementsSection(),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return PremiumGlassmorphicTheme.glassCard(
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              color: PremiumGlassmorphicTheme.textPrimary,
              fontSize: PremiumGlassmorphicTheme.fontSizeXl,
              fontWeight: FontWeight.w700,
            ),
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingLg),
          
          Wrap(
            spacing: PremiumGlassmorphicTheme.spacingMd,
            runSpacing: PremiumGlassmorphicTheme.spacingMd,
            children: [
              _buildQuickActionCard(
                'New Order',
                Icons.add_shopping_cart,
                Colors.green,
                () => context.push('/orders/new'),
              ),
              _buildQuickActionCard(
                'Product Search',
                Icons.search,
                Colors.blue,
                () => context.push('/catalog'),
              ),
              _buildQuickActionCard(
                'Customer Support',
                Icons.support_agent,
                Colors.orange,
                () => context.push('/support'),
              ),
              _buildQuickActionCard(
                'Analytics',
                Icons.analytics,
                Colors.purple,
                () => context.push('/analytics'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(PremiumGlassmorphicTheme.radiusLg),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: PremiumGlassmorphicTheme.spacingSm),
            Text(
              title,
              style: const TextStyle(
                color: PremiumGlassmorphicTheme.textPrimary,
                fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedCardsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enhanced Features',
          style: TextStyle(
            color: PremiumGlassmorphicTheme.textPrimary,
            fontSize: PremiumGlassmorphicTheme.fontSizeLg,
            fontWeight: FontWeight.w700,
          ),
        ),
        
        const SizedBox(height: PremiumGlassmorphicTheme.spacingLg),
        
        // Haptic Feedback Card
        PremiumGlassmorphicTheme.glassCard(
          padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingMd),
          child: Row(
            children: [
              Icon(
                Icons.vibration,
                color: PremiumGlassmorphicTheme.indigo500,
                size: 24,
              ),
              const SizedBox(width: PremiumGlassmorphicTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Haptic Feedback',
                      style: TextStyle(
                        color: PremiumGlassmorphicTheme.textPrimary,
                        fontSize: PremiumGlassmorphicTheme.fontSizeMd,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: PremiumGlassmorphicTheme.spacingXs),
                    const Text(
                      'Get tactile feedback for better interaction',
                      style: TextStyle(
                        color: PremiumGlassmorphicTheme.textSecondary,
                        fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: true, 
                onChanged: (value) => _toggleHapticFeedback(value),
                activeColor: PremiumGlassmorphicTheme.indigo500,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
        
        // Smooth Animations Card
        PremiumGlassmorphicTheme.glassCard(
          padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingMd),
          child: Row(
            children: [
              Icon(
                Icons.animation,
                color: PremiumGlassmorphicTheme.indigo500,
                size: 24,
              ),
              const SizedBox(width: PremiumGlassmorphicTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Smooth Animations',
                      style: TextStyle(
                        color: PremiumGlassmorphicTheme.textPrimary,
                        fontSize: PremiumGlassmorphicTheme.fontSizeMd,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: PremiumGlassmorphicTheme.spacingXs),
                    const Text(
                      'Enjoy fluid transitions and micro-interactions',
                      style: TextStyle(
                        color: PremiumGlassmorphicTheme.textSecondary,
                        fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: !_isReducedMotion,
                onChanged: (value) => _toggleReducedMotion(!value),
                activeColor: PremiumGlassmorphicTheme.indigo500,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInteractiveElementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Interactive Elements',
          style: TextStyle(
            color: PremiumGlassmorphicTheme.textPrimary,
            fontSize: PremiumGlassmorphicTheme.fontSizeLg,
            fontWeight: FontWeight.w700,
          ),
        ),
        
        const SizedBox(height: PremiumGlassmorphicTheme.spacingLg),
        
        // Gesture-based Navigation
        PremiumGlassmorphicTheme.glassCard(
          padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gesture-based Navigation',
                style: TextStyle(
                  color: PremiumGlassmorphicTheme.textPrimary,
                  fontSize: PremiumGlassmorphicTheme.fontSizeMd,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
              Row(
                children: [
                  _buildGestureButton('←', () => _handleGesture('left')),
                  const SizedBox(width: PremiumGlassmorphicTheme.spacingMd),
                  _buildGestureButton('↑', () => _handleGesture('up')),
                  const SizedBox(width: PremiumGlassmorphicTheme.spacingMd),
                  _buildGestureButton('↓', () => _handleGesture('down')),
                  const SizedBox(width: PremiumGlassmorphicTheme.spacingMd),
                  _buildGestureButton('→', () => _handleGesture('right')),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGestureButton(String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: PremiumGlassmorphicTheme.surfaceLight.withOpacity(0.3),
          borderRadius: BorderRadius.circular(PremiumGlassmorphicTheme.radiusMd),
          border: Border.all(
            color: PremiumGlassmorphicTheme.borderMedium,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: PremiumGlassmorphicTheme.textPrimary,
              fontSize: PremiumGlassmorphicTheme.fontSizeLg,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccessibilitySettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Accessibility Settings',
            style: TextStyle(
              color: PremiumGlassmorphicTheme.textPrimary,
              fontSize: PremiumGlassmorphicTheme.fontSizeXl,
              fontWeight: FontWeight.w700,
            ),
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingXl),
          
          // Visual Accessibility
          _buildAccessibilitySection(
            'Visual',
            [
              _buildAccessibilityOption(
                'High Contrast',
                _isHighContrast,
                (value) => _toggleHighContrast(value),
                Icons.contrast,
              ),
              _buildAccessibilityOption(
                'Large Text',
                _textScale > 1.0,
                (value) => _toggleLargeText(value),
                Icons.text_fields,
              ),
              _buildAccessibilityOption(
                'Color Blind Friendly',
                false, 
                (value) => _toggleColorBlindFriendly(value),
                Icons.color_lens,
              ),
            ],
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingXl),
          
          // Motor Accessibility
          _buildAccessibilitySection(
            'Motor',
            [
              _buildAccessibilityOption(
                'Reduced Motion',
                _isReducedMotion,
                (value) => _toggleReducedMotion(value),
                Icons.motion_photos_pause,
              ),
              _buildAccessibilityOption(
                'Large Touch Targets',
                _isCompactMode,
                (value) => _toggleLargeTouchTargets(value),
                Icons.touch_app,
              ),
              _buildAccessibilityOption(
                'Voice Navigation',
                false, 
                (value) => _toggleVoiceNavigation(value),
                Icons.mic,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccessibilitySection(String title, List<Widget> options) {
    return PremiumGlassmorphicTheme.glassCard(
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: PremiumGlassmorphicTheme.textPrimary,
              fontSize: PremiumGlassmorphicTheme.fontSizeLg,
              fontWeight: FontWeight.w700,
            ),
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingLg),
          
          ...options,
        ],
      ),
    );
  }

  Widget _buildAccessibilityOption(
    String title,
    bool value,
    Function(bool) onChanged,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PremiumGlassmorphicTheme.spacingMd),
      child: Row(
        children: [
          Icon(icon, color: PremiumGlassmorphicTheme.indigo500, size: 24),
          const SizedBox(width: PremiumGlassmorphicTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: PremiumGlassmorphicTheme.textPrimary,
                    fontSize: PremiumGlassmorphicTheme.fontSizeMd,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: PremiumGlassmorphicTheme.spacingXs),
                Text(
                  _getAccessibilityDescription(title),
                  style: const TextStyle(
                    color: PremiumGlassmorphicTheme.textSecondary,
                    fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: PremiumGlassmorphicTheme.indigo500,
          ),
        ],
      ),
    );
  }

  String _getAccessibilityDescription(String title) {
    switch (title) {
      case 'High Contrast':
        return 'Increase contrast for better visibility';
      case 'Large Text':
        return 'Increase text size for better readability';
      case 'Color Blind Friendly':
        return 'Optimize colors for color blind users';
      case 'Reduced Motion':
        return 'Reduce animations for users with motion sensitivity';
      case 'Large Touch Targets':
        return 'Increase touch target size for easier interaction';
      case 'Voice Navigation':
        return 'Navigate the app using voice commands';
      default:
        return 'Accessibility option';
    }
  }

  Widget _buildThemeCustomization() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Theme Customization',
            style: TextStyle(
              color: PremiumGlassmorphicTheme.textPrimary,
              fontSize: PremiumGlassmorphicTheme.fontSizeXl,
              fontWeight: FontWeight.w700,
            ),
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingXl),
          
          // Theme Selection
          _buildThemeSelection(),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingXl),
          
          // Color Customization
          _buildColorCustomization(),
        ],
      ),
    );
  }

  Widget _buildThemeSelection() {
    return PremiumGlassmorphicTheme.glassCard(
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Theme Selection',
            style: TextStyle(
              color: PremiumGlassmorphicTheme.textPrimary,
              fontSize: PremiumGlassmorphicTheme.fontSizeLg,
              fontWeight: FontWeight.w700,
            ),
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingLg),
          
          Wrap(
            spacing: PremiumGlassmorphicTheme.spacingMd,
            runSpacing: PremiumGlassmorphicTheme.spacingMd,
            children: [
              _buildThemeOption('Slate', Colors.grey[800]!),
              _buildThemeOption('Indigo', Colors.indigo[600]!),
              _buildThemeOption('Emerald', Colors.emerald[600]!),
              _buildThemeOption('Amber', Colors.amber[600]!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(String name, Color color) {
    final isSelected = _selectedTheme.toLowerCase() == name.toLowerCase();
    
    return GestureDetector(
      onTap: () => _selectTheme(name),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(PremiumGlassmorphicTheme.radiusLg),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(PremiumGlassmorphicTheme.radiusMd),
              ),
            ),
            const SizedBox(height: PremiumGlassmorphicTheme.spacingSm),
            Text(
              name,
              style: TextStyle(
                color: isSelected ? color : PremiumGlassmorphicTheme.textPrimary,
                fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorCustomization() {
    return PremiumGlassmorphicTheme.glassCard(
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Color Customization',
            style: TextStyle(
              color: PremiumGlassmorphicTheme.textPrimary,
              fontSize: PremiumGlassmorphicTheme.fontSizeLg,
              fontWeight: FontWeight.w700,
            ),
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingLg),
          
          // Primary Color
          _buildColorPicker('Primary Color', Colors.blue),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingMd),
          
          // Accent Color
          _buildColorPicker('Accent Color', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildColorPicker(String label, Color currentColor) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: PremiumGlassmorphicTheme.textPrimary,
            fontSize: PremiumGlassmorphicTheme.fontSizeMd,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: PremiumGlassmorphicTheme.spacingMd),
        Expanded(
          child: Row(
            children: [
              Colors.red,
              Colors.orange,
              Colors.yellow,
              Colors.green,
              Colors.blue,
              Colors.indigo,
              Colors.purple,
            ].map((color) {
              final isSelected = color.value == currentColor.value;
              return GestureDetector(
                onTap: () => _selectColor(color),
                child: Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(right: PremiumGlassmorphicTheme.spacingSm),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(PremiumGlassmorphicTheme.radiusMd),
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Settings',
            style: TextStyle(
              color: PremiumGlassmorphicTheme.textPrimary,
              fontSize: PremiumGlassmorphicTheme.fontSizeXl,
              fontWeight: FontWeight.w700,
            ),
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingXl),
          
          // Performance Options
          _buildPerformanceSection(
            'Rendering',
            [
              _buildPerformanceOption(
                'Hardware Acceleration',
                true,
                (value) => _toggleHardwareAcceleration(value),
                Icons.speed,
              ),
              _buildPerformanceOption(
                'Adaptive Performance',
                true,
                (value) => _toggleAdaptivePerformance(value),
                Icons.auto_awesome,
              ),
            ],
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingXl),
          
          _buildPerformanceSection(
            'Network',
            [
              _buildPerformanceOption(
                'Offline Mode',
                false,
                (value) => _toggleOfflineMode(value),
                Icons.offline_bolt,
              ),
              _buildPerformanceOption(
                'Data Saver',
                false,
                (value) => _toggleDataSaver(value),
                Icons.savings,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSection(String title, List<Widget> options) {
    return PremiumGlassmorphicTheme.glassCard(
      padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: PremiumGlassmorphicTheme.textPrimary,
              fontSize: PremiumGlassmorphicTheme.fontSizeLg,
              fontWeight: FontWeight.w700,
            ),
          ),
          
          const SizedBox(height: PremiumGlassmorphicTheme.spacingLg),
          
          ...options,
        ],
      ),
    );
  }

  Widget _buildPerformanceOption(
    String title,
    bool value,
    Function(bool) onChanged,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PremiumGlassmorphicTheme.spacingMd),
      child: Row(
        children: [
          Icon(icon, color: PremiumGlassmorphicTheme.indigo500, size: 24),
          const SizedBox(width: PremiumGlassmorphicTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: PremiumGlassmorphicTheme.textPrimary,
                    fontSize: PremiumGlassmorphicTheme.fontSizeMd,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: PremiumGlassmorphicTheme.spacingXs),
                Text(
                  _getPerformanceDescription(title),
                  style: const TextStyle(
                    color: PremiumGlassmorphicTheme.textSecondary,
                    fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: PremiumGlassmorphicTheme.indigo500,
          ),
        ],
      ),
    );
  }

  String _getPerformanceDescription(String title) {
    switch (title) {
      case 'Hardware Acceleration':
        return 'Use GPU acceleration for better performance';
      case 'Adaptive Performance':
        return 'Automatically adjust performance based on device capabilities';
      case 'Offline Mode':
        return 'Cache data for offline access';
      case 'Data Saver':
        return 'Reduce data usage by optimizing network requests';
      default:
        return 'Performance option';
    }
  }

  Widget _buildBottomNavigation() {
    return EnhancedBottomNavigation(
      currentIndex: 0, 
      onTap: (index) => _handleBottomNavigationTap(index),
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.accessibility),
          label: 'Accessibility',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.palette),
          label: 'Theme',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.speed),
          label: 'Performance',
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _showQuickActions,
      icon: const Icon(Icons.menu),
      label: const Text('Quick Actions'),
      backgroundColor: PremiumGlassmorphicTheme.indigo500,
    );
  }

  Widget _buildNavigationDrawer() {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              PremiumGlassmorphicTheme.slate800.withOpacity(0.95),
              PremiumGlassmorphicTheme.slate900.withOpacity(0.95),
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: PremiumGlassmorphicTheme.indigo600.withOpacity(0.1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'VedantaTrade',
                    style: TextStyle(
                      color: PremiumGlassmorphicTheme.textPrimary,
                      fontSize: PremiumGlassmorphicTheme.fontSizeXl,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: PremiumGlassmorphicTheme.spacingSm),
                  Text(
                    'Enhanced UX Experience',
                    style: TextStyle(
                      color: PremiumGlassmorphicTheme.textSecondary,
                      fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(Icons.home, 'Home', () => context.go('/')),
            _buildDrawerItem(Icons.person, 'Profile', () => context.go('/profile')),
            _buildDrawerItem(Icons.settings, 'Settings', () => context.go('/settings')),
            _buildDrawerItem(Icons.help, 'Help', () => context.go('/help')),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: PremiumGlassmorphicTheme.textPrimary),
      title: Text(
        title,
        style: const TextStyle(
          color: PremiumGlassmorphicTheme.textPrimary,
          fontSize: PremiumGlassmorphicTheme.fontSizeMd,
        ),
      ),
      onTap: onTap,
    );
  }

  // Event Handlers
  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    
    final provider = Provider.of<UXEnhancementProvider>(context, listen: false);
    provider.setDarkMode(_isDarkMode);
    
    _fadeController.forward().then((_) {
      _fadeController.reverse();
    });
  }

  void _handleAccessibilityMenu(String value) {
    switch (value) {
      case 'high_contrast':
        _toggleHighContrast(!_isHighContrast);
        break;
      case 'reduced_motion':
        _toggleReducedMotion(!_isReducedMotion);
        break;
      case 'text_size':
        _showTextSizeDialog();
        break;
    }
  }

  void _toggleHighContrast(bool value) {
    setState(() {
      _isHighContrast = value;
    });
    
    final provider = Provider.of<UXEnhancementProvider>(context, listen: false);
    provider.setHighContrast(value);
  }

  void _toggleReducedMotion(bool value) {
    setState(() {
      _isReducedMotion = value;
    });
    
    final provider = Provider.of<UXEnhancementProvider>(context, listen: false);
    provider.setReducedMotion(value);
  }

  void _adjustTextSize(double delta) {
    setState(() {
      _textScale = (_textScale + delta).clamp(0.8, 2.0);
    });
    
    final provider = Provider.of<UXEnhancementProvider>(context, listen: false);
    provider.setTextScale(_textScale);
  }

  void _toggleLargeText(bool value) {
    setState(() {
      _textScale = value ? 1.5 : 1.0;
    });
    
    final provider = Provider.of<UXEnhancementProvider>(context, listen: false);
    provider.setTextScale(_textScale);
  }

  void _selectTheme(String theme) {
    setState(() {
      _selectedTheme = theme;
    });
    
    final provider = Provider.of<UXEnhancementProvider>(context, listen: false);
    provider.setTheme(theme);
    
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });
  }

  void _selectColor(Color color) {
    final provider = Provider.of<UXEnhancementProvider>(context, listen: false);
    provider.setAccentColor(color);
  }

  void _handleSearch(String query) {
    final provider = Provider.of<UXEnhancementProvider>(context, listen: false);
    provider.search(query);
  }

  void _showFilterOptions() {
    
  }

  void _handleGesture(String direction) {
    
    _slideController.forward().then((_) {
      _slideController.reverse();
    });
  }

  void _toggleHapticFeedback(bool value) {
    final provider = Provider.of<UXEnhancementProvider>(context, listen: false);
    provider.setHapticFeedback(value);
  }

  void _toggleColorBlindFriendly(bool value) {
    final provider = Provider.of<UXEnhancementProvider>(context, listen: false);
    provider.setColorBlindFriendly(value);
  }

  void _toggleLargeTouchTargets(bool value) {
    setState(() {
      _isCompactMode = !value;
    });
    
    final provider = Provider.of<UXEnhancementProvider>(context, listen: false);
    provider.setCompactMode(_isCompactMode);
  }

  void _toggleVoiceNavigation(bool value) {
    final provider = Provider.of<UXEnhancementProvider>(context, listen: false);
    provider.setVoiceNavigation(value);
  }

  void _toggleHardwareAcceleration(bool value) {
    final provider = Provider.of<UXEnhancementProvider>(context, listen: false);
    provider.setHardwareAcceleration(value);
  }

  void _toggleAdaptivePerformance(bool value) {
    final provider = Provider.of<UXEnhancementProvider>(context, listen: false);
    provider.setAdaptivePerformance(value);
  }

  void _toggleOfflineMode(bool value) {
    final provider = Provider.of<UXEnhancementProvider>(context, listen: false);
    provider.setOfflineMode(value);
  }

  void _toggleDataSaver(bool value) {
    final provider = Provider.of<UXEnhancementProvider>(context, listen: false);
    provider.setDataSaver(value);
  }

  void _handleBottomNavigationTap(int index) {
    
    _slideController.forward().then((_) {
      _slideController.reverse();
    });
  }

  void _showQuickActions() {
    
  }

  void _showTextSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Text Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current: ${_textScale.toStringAsFixed(1)}x'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTextSizeButton('A-', () => _adjustTextSize(-0.1)),
                _buildTextSizeButton('A', () => _adjustTextSize(-_textScale + 1.0)),
                _buildTextSizeButton('A+', () => _adjustTextSize(0.1)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

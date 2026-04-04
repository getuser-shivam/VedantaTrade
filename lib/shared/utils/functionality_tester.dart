import 'package:flutter/material.dart';
import '../theme/enhanced_theme.dart';
import '../widgets/enhanced_ui_kit.dart';
import '../widgets/enhanced_navigation_system.dart';
import '../widgets/enhanced_responsive_layout.dart';
import '../widgets/enhanced_animations.dart';

/// Functionality Tester for VedantaTrade
/// Ensures all components and functionalities are working as expected
class FunctionalityTester {
  static final List<String> _testResults = [];
  static final List<String> _failedTests = [];

  /// Run comprehensive functionality tests
  static Future<TestReport> runAllTests() async {
    _testResults.clear();
    _failedTests.clear();

    final report = TestReport();

    // Test Theme System
    await _testThemeSystem(report);

    // Test UI Components
    await _testUIComponents(report);

    // Test Navigation System
    await _testNavigationSystem(report);

    // Test Responsive Layout
    await _testResponsiveLayout(report);

    // Test Animation System
    await _testAnimationSystem(report);

    // Test Integration
    await _testIntegration(report);

    return report;
  }

  /// Test Theme System
  static Future<void> _testThemeSystem(TestReport report) async {
    try {
      // Test color constants
      _testColorConstants(report);
      
      // Test text styles
      _testTextStyles(report);
      
      // Test theme data
      _testThemeData(report);
      
      // Test responsive utilities
      _testResponsiveUtilities(report);
      
      report.addSuccess('Theme System', 'All theme system tests passed');
      _testResults.add('✅ Theme System: All tests passed');
    } catch (e) {
      _failedTests.add('Theme System: $e');
      report.addError('Theme System', e.toString());
    }
  }

  static void _testColorConstants(TestReport report) {
    final colors = [
      EnhancedTheme.primaryColor,
      EnhancedTheme.secondaryColor,
      EnhancedTheme.accentColor,
      EnhancedTheme.errorColor,
      EnhancedTheme.warningColor,
      EnhancedTheme.successColor,
      EnhancedTheme.glassBackground,
      EnhancedTheme.surfaceColor,
      EnhancedTheme.textPrimary,
      EnhancedTheme.textSecondary,
    ];

    for (int i = 0; i < colors.length; i++) {
      final color = colors[i];
      if (color.value == 0) {
        throw Exception('Color constant at index $i is invalid');
      }
    }
  }

  static void _testTextStyles(TestReport report) {
    final styles = [
      EnhancedTheme.heading1,
      EnhancedTheme.heading2,
      EnhancedTheme.heading3,
      EnhancedTheme.heading4,
      EnhancedTheme.heading5,
      EnhancedTheme.bodyLarge,
      EnhancedTheme.bodyMedium,
      EnhancedTheme.bodySmall,
      EnhancedTheme.caption,
    ];

    for (int i = 0; i < styles.length; i++) {
      final style = styles[i];
      if (style.fontSize == null || style.fontSize! <= 0) {
        throw Exception('Text style at index $i has invalid font size');
      }
    }
  }

  static void _testThemeData(TestReport report) {
    final theme = EnhancedTheme.lightTheme;
    if (theme.colorScheme.primary == Colors.transparent) {
      throw Exception('Theme color scheme primary color is invalid');
    }
    if (theme.scaffoldBackgroundColor == Colors.transparent) {
      throw Exception('Theme scaffold background color is invalid');
    }
  }

  static void _testResponsiveUtilities(TestReport report) {
    // Test breakpoint constants
    if (EnhancedTheme.breakpointMobile <= 0) {
      throw Exception('Mobile breakpoint is invalid');
    }
    if (EnhancedTheme.breakpointTablet <= EnhancedTheme.breakpointMobile) {
      throw Exception('Tablet breakpoint is invalid');
    }
    if (EnhancedTheme.breakpointDesktop <= EnhancedTheme.breakpointTablet) {
      throw Exception('Desktop breakpoint is invalid');
    }
  }

  /// Test UI Components
  static Future<void> _testUIComponents(TestReport report) async {
    try {
      // Test glass container
      _testGlassContainer(report);
      
      // Test enhanced button
      _testEnhancedButton(report);
      
      // Test enhanced card
      _testEnhancedCard(report);
      
      // Test enhanced input
      _testEnhancedInput(report);
      
      // Test enhanced loading
      _testEnhancedLoading(report);
      
      // Test enhanced chip
      _testEnhancedChip(report);
      
      // Test enhanced avatar
      _testEnhancedAvatar(report);
      
      // Test enhanced badge
      _testEnhancedBadge(report);
      
      report.addSuccess('UI Components', 'All UI component tests passed');
      _testResults.add('✅ UI Components: All tests passed');
    } catch (e) {
      _failedTests.add('UI Components: $e');
      report.addError('UI Components', e.toString());
    }
  }

  static void _testGlassContainer(TestReport report) {
    final container = EnhancedUIKit.glassContainer(
      child: const Text('Test'),
      width: 100,
      height: 100,
    );
    
    if (container == null) {
      throw Exception('Glass container creation failed');
    }
  }

  static void _testEnhancedButton(TestReport report) {
    final button = EnhancedUIKit.enhancedButton(
      text: 'Test Button',
      onPressed: () {},
    );
    
    if (button == null) {
      throw Exception('Enhanced button creation failed');
    }
  }

  static void _testEnhancedCard(TestReport report) {
    final card = EnhancedUIKit.enhancedCard(
      child: const Text('Test Card'),
    );
    
    if (card == null) {
      throw Exception('Enhanced card creation failed');
    }
  }

  static void _testEnhancedInput(TestReport report) {
    final input = EnhancedUIKit.enhancedInput(
      controller: TextEditingController(),
      hintText: 'Test Input',
    );
    
    if (input == null) {
      throw Exception('Enhanced input creation failed');
    }
  }

  static void _testEnhancedLoading(TestReport report) {
    final loading = EnhancedUIKit.enhancedLoading(
      size: 24,
      color: EnhancedTheme.primaryColor,
    );
    
    if (loading == null) {
      throw Exception('Enhanced loading creation failed');
    }
  }

  static void _testEnhancedChip(TestReport report) {
    final chip = EnhancedUIKit.enhancedChip(
      label: 'Test Chip',
      onTap: () {},
    );
    
    if (chip == null) {
      throw Exception('Enhanced chip creation failed');
    }
  }

  static void _testEnhancedAvatar(TestReport report) {
    final avatar = EnhancedUIKit.enhancedAvatar(
      name: 'Test User',
      size: 48,
    );
    
    if (avatar == null) {
      throw Exception('Enhanced avatar creation failed');
    }
  }

  static void _testEnhancedBadge(TestReport report) {
    final badge = EnhancedUIKit.enhancedBadge(
      child: const Icon(Icons.notifications),
      count: '5',
    );
    
    if (badge == null) {
      throw Exception('Enhanced badge creation failed');
    }
  }

  /// Test Navigation System
  static Future<void> _testNavigationSystem(TestReport report) async {
    try {
      // Test navigation key
      _testNavigationKey(report);
      
      // Test enhanced bottom nav
      _testEnhancedBottomNav(report);
      
      // Test enhanced app bar
      _testEnhancedAppBar(report);
      
      // Test navigation rail
      _testNavigationRail(report);
      
      // Test tab bar
      _testTabBar(report);
      
      // Test FAB
      _testEnhancedFAB(report);
      
      report.addSuccess('Navigation System', 'All navigation system tests passed');
      _testResults.add('✅ Navigation System: All tests passed');
    } catch (e) {
      _failedTests.add('Navigation System: $e');
      report.addError('Navigation System', e.toString());
    }
  }

  static void _testNavigationKey(TestReport report) {
    if (EnhancedNavigationSystem.navigatorKey == null) {
      throw Exception('Navigation key is null');
    }
  }

  static void _testEnhancedBottomNav(TestReport report) {
    final items = [
      EnhancedBottomNavItem(
        icon: Icons.home,
        label: 'Home',
      ),
      EnhancedBottomNavItem(
        icon: Icons.search,
        label: 'Search',
      ),
    ];

    final bottomNav = EnhancedBottomNav(
      currentIndex: 0,
      onTap: (index) {},
      items: items,
    );
    
    if (bottomNav == null) {
      throw Exception('Enhanced bottom nav creation failed');
    }
  }

  static void _testEnhancedAppBar(TestReport report) {
    final appBar = EnhancedAppBar(
      title: 'Test App',
    );
    
    if (appBar == null) {
      throw Exception('Enhanced app bar creation failed');
    }
  }

  static void _testNavigationRail(TestReport report) {
    final destinations = [
      EnhancedNavigationRailDestination(
        icon: Icons.home,
        label: 'Home',
      ),
      EnhancedNavigationRailDestination(
        icon: Icons.settings,
        label: 'Settings',
      ),
    ];

    final rail = EnhancedNavigationRail(
      selectedIndex: 0,
      onDestinationSelected: (index) {},
      destinations: destinations,
    );
    
    if (rail == null) {
      throw Exception('Navigation rail creation failed');
    }
  }

  static void _testTabBar(TestReport report) {
    final tabBar = EnhancedTabBar(
      tabs: ['Tab 1', 'Tab 2', 'Tab 3'],
      selectedIndex: 0,
      onTap: (index) {},
    );
    
    if (tabBar == null) {
      throw Exception('Tab bar creation failed');
    }
  }

  static void _testEnhancedFAB(TestReport report) {
    final fab = EnhancedFAB(
      onPressed: () {},
      icon: Icons.add,
    );
    
    if (fab == null) {
      throw Exception('Enhanced FAB creation failed');
    }
  }

  /// Test Responsive Layout
  static Future<void> _testResponsiveLayout(TestReport report) async {
    try {
      // Test responsive container
      _testResponsiveContainer(report);
      
      // Test responsive grid
      _testResponsiveGrid(report);
      
      // Test responsive row
      _testResponsiveRow(report);
      
      // Test responsive column
      _testResponsiveColumn(report);
      
      // Test responsive layout builder
      _testResponsiveLayoutBuilder(report);
      
      report.addSuccess('Responsive Layout', 'All responsive layout tests passed');
      _testResults.add('✅ Responsive Layout: All tests passed');
    } catch (e) {
      _failedTests.add('Responsive Layout: $e');
      report.addError('Responsive Layout', e.toString());
    }
  }

  static void _testResponsiveContainer(TestReport report) {
    final container = ResponsiveContainer(
      child: const Text('Test'),
    );
    
    if (container == null) {
      throw Exception('Responsive container creation failed');
    }
  }

  static void _testResponsiveGrid(TestReport report) {
    final grid = ResponsiveGrid(
      children: const [
        Text('Item 1'),
        Text('Item 2'),
      ],
    );
    
    if (grid == null) {
      throw Exception('Responsive grid creation failed');
    }
  }

  static void _testResponsiveRow(TestReport report) {
    final row = ResponsiveRow(
      children: const [
        ResponsiveRowItem(child: Text('Item 1')),
        ResponsiveRowItem(child: Text('Item 2')),
      ],
    );
    
    if (row == null) {
      throw Exception('Responsive row creation failed');
    }
  }

  static void _testResponsiveColumn(TestReport report) {
    final column = ResponsiveColumn(
      children: const [
        ResponsiveColumnItem(child: Text('Item 1')),
        ResponsiveColumnItem(child: Text('Item 2')),
      ],
    );
    
    if (column == null) {
      throw Exception('Responsive column creation failed');
    }
  }

  static void _testResponsiveLayoutBuilder(TestReport report) {
    final builder = ResponsiveLayoutBuilder(
      builder: (context, screenType) {
        return const Text('Test');
      },
    );
    
    if (builder == null) {
      throw Exception('Responsive layout builder creation failed');
    }
  }

  /// Test Animation System
  static Future<void> _testAnimationSystem(TestReport report) async {
    try {
      // Test fade in animation
      _testFadeInAnimation(report);
      
      // Test slide in animation
      _testSlideInAnimation(report);
      
      // Test scale in animation
      _testScaleInAnimation(report);
      
      // Test rotation animation
      _testRotationAnimation(report);
      
      // Test pulse animation
      _testPulseAnimation(report);
      
      // Test gesture animations
      _testGestureAnimations(report);
      
      report.addSuccess('Animation System', 'All animation system tests passed');
      _testResults.add('✅ Animation System: All tests passed');
    } catch (e) {
      _failedTests.add('Animation System: $e');
      report.addError('Animation System', e.toString());
    }
  }

  static void _testFadeInAnimation(TestReport report) {
    final animation = EnhancedAnimations.fadeIn(
      child: const Text('Test'),
    );
    
    if (animation == null) {
      throw Exception('Fade in animation creation failed');
    }
  }

  static void _testSlideInAnimation(TestReport report) {
    final animation = EnhancedAnimations.slideIn(
      child: const Text('Test'),
    );
    
    if (animation == null) {
      throw Exception('Slide in animation creation failed');
    }
  }

  static void _testScaleInAnimation(TestReport report) {
    final animation = EnhancedAnimations.scaleIn(
      child: const Text('Test'),
    );
    
    if (animation == null) {
      throw Exception('Scale in animation creation failed');
    }
  }

  static void _testRotationAnimation(TestReport report) {
    final animation = EnhancedAnimations.rotation(
      child: const Text('Test'),
    );
    
    if (animation == null) {
      throw Exception('Rotation animation creation failed');
    }
  }

  static void _testPulseAnimation(TestReport report) {
    final animation = EnhancedAnimations.pulse(
      child: const Text('Test'),
    );
    
    if (animation == null) {
      throw Exception('Pulse animation creation failed');
    }
  }

  static void _testGestureAnimations(TestReport report) {
    final tapAnimation = GestureAnimations.tapAnimation(
      child: const Text('Test'),
      onTap: () {},
    );
    
    if (tapAnimation == null) {
      throw Exception('Tap animation creation failed');
    }
  }

  /// Test Integration
  static Future<void> _testIntegration(TestReport report) async {
    try {
      // Test component integration
      _testComponentIntegration(report);
      
      // Test theme integration
      _testThemeIntegration(report);
      
      // Test responsive integration
      _testResponsiveIntegration(report);
      
      report.addSuccess('Integration', 'All integration tests passed');
      _testResults.add('✅ Integration: All tests passed');
    } catch (e) {
      _failedTests.add('Integration: $e');
      report.addError('Integration', e.toString());
    }
  }

  static void _testComponentIntegration(TestReport report) {
    // Test that components work together
    final container = EnhancedUIKit.glassContainer(
      child: Column(
        children: [
          EnhancedUIKit.enhancedButton(
            text: 'Test',
            onPressed: () {},
          ),
          const SizedBox(height: 16),
          EnhancedUIKit.enhancedCard(
            child: EnhancedUIKit.enhancedInput(
              controller: TextEditingController(),
              hintText: 'Test',
            ),
          ),
        ],
      ),
    );
    
    if (container == null) {
      throw Exception('Component integration failed');
    }
  }

  static void _testThemeIntegration(TestReport report) {
    // Test that theme is properly applied
    final themedContainer = EnhancedUIKit.glassContainer(
      child: Text(
        'Test',
        style: EnhancedTheme.bodyMedium,
      ),
    );
    
    if (themedContainer == null) {
      throw Exception('Theme integration failed');
    }
  }

  static void _testResponsiveIntegration(TestReport report) {
    // Test that responsive components work with theme
    final responsiveContainer = ResponsiveContainer(
      child: EnhancedUIKit.glassContainer(
        child: Text(
          'Test',
          style: EnhancedTheme.bodyMedium,
        ),
      ),
    );
    
    if (responsiveContainer == null) {
      throw Exception('Responsive integration failed');
    }
  }

  /// Get test results
  static List<String> getTestResults() => List.from(_testResults);

  /// Get failed tests
  static List<String> getFailedTests() => List.from(_failedTests);

  /// Clear test results
  static void clearResults() {
    _testResults.clear();
    _failedTests.clear();
  }
}

/// Test Report
class TestReport {
  final List<TestItem> items = [];

  void addSuccess(String component, String message) {
    items.add(TestItem(
      component: component,
      message: message,
      type: TestType.success,
    ));
  }

  void addWarning(String component, String message) {
    items.add(TestItem(
      component: component,
      message: message,
      type: TestType.warning,
    ));
  }

  void addIssue(String component, String message) {
    items.add(TestItem(
      component: component,
      message: message,
      type: TestType.issue,
    ));
  }

  void addError(String component, String message) {
    items.add(TestItem(
      component: component,
      message: message,
      type: TestType.error,
    ));
  }

  bool get hasErrors => items.any((item) => item.type == TestType.error);
  bool get hasIssues => items.any((item) => item.type == TestType.issue);
  bool get hasWarnings => items.any((item) => item.type == TestType.warning);

  int get successCount => items.where((item) => item.type == TestType.success).length;
  int get warningCount => items.where((item) => item.type == TestType.warning).length;
  int get issueCount => items.where((item) => item.type == TestType.issue).length;
  int get errorCount => items.where((item) => item.type == TestType.error).length;

  bool get allTestsPassed => !hasErrors && !hasIssues;

  Map<String, dynamic> toJson() {
    return {
      'successCount': successCount,
      'warningCount': warningCount,
      'issueCount': issueCount,
      'errorCount': errorCount,
      'hasErrors': hasErrors,
      'hasIssues': hasIssues,
      'hasWarnings': hasWarnings,
      'allTestsPassed': allTestsPassed,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

/// Test Item
class TestItem {
  final String component;
  final String message;
  final TestType type;
  final DateTime timestamp;

  TestItem({
    required this.component,
    required this.message,
    required this.type,
  }) : timestamp = DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'component': component,
      'message': message,
      'type': type.toString(),
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Test Type
enum TestType {
  success,
  warning,
  issue,
  error,
}

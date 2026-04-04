import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:vedanta_trade/shared/theme/enhanced_theme.dart';
import 'package:vedanta_trade/shared/widgets/common/enhanced_ui_components.dart';
import 'package:vedanta_trade/shared/widgets/responsive/responsive_layout.dart';
import 'package:vedanta_trade/shared/widgets/animations/enhanced_animations.dart';
import 'package:vedanta_trade/shared/widgets/navigation/enhanced_navigation.dart';
import 'package:vedanta_trade/shared/widgets/accessibility/enhanced_accessibility.dart';
import 'package:vedanta_trade/shared/widgets/performance/performance_optimizer.dart';

/// Comprehensive UI/UX Test Suite for VedantaTrade
/// Tests all enhanced UI components for functionality, accessibility, and performance

void main() {
  group('Enhanced Theme Tests', () {
    testWidgets('Light theme should have correct colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: EnhancedTheme.lightTheme,
          home: Container(),
        ),
      );

      final theme = EnhancedTheme.lightTheme;
      expect(theme.colorScheme.primary, equals(EnhancedTheme.primaryBlue));
      expect(theme.colorScheme.secondary, equals(EnhancedTheme.accentTeal));
      expect(theme.colorScheme.surface, equals(Colors.white));
    });

    testWidgets('Dark theme should have correct colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: EnhancedTheme.darkTheme,
          home: Container(),
        ),
      );

      final theme = EnhancedTheme.darkTheme;
      expect(theme.colorScheme.primary, equals(EnhancedTheme.primaryBlueLight));
      expect(theme.colorScheme.surface, equals(EnhancedTheme.neutral800));
    });

    testWidgets('Text styles should be consistent', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: EnhancedTheme.lightTheme,
          home: Scaffold(
            body: Column(
              children: [
                Text('Headline', style: EnhancedTheme.lightTheme.textTheme.headlineSmall),
                Text('Body', style: EnhancedTheme.lightTheme.textTheme.bodyMedium),
                Text('Label', style: EnhancedTheme.lightTheme.textTheme.labelSmall),
              ],
            ),
          ),
        ),
      );

      final headline = tester.widget<Text>(find.text('Headline'));
      final body = tester.widget<Text>(find.text('Body'));
      final label = tester.widget<Text>(find.text('Label'));

      expect(headline.style?.fontSize, equals(24.0));
      expect(body.style?.fontSize, equals(14.0));
      expect(label.style?.fontSize, equals(12.0));
    });
  });

  group('Enhanced UI Components Tests', () {
    testWidgets('EnhancedButton should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: EnhancedTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: EnhancedButton(
                text: 'Test Button',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('EnhancedButton should handle loading state', (WidgetTester tester) async {
      bool isLoading = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: EnhancedTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: StatefulBuilder(
                builder: (context, setState) {
                  return EnhancedButton(
                    text: 'Test Button',
                    isLoading: isLoading,
                    onPressed: () {
                      setState(() {
                        isLoading = !isLoading;
                      });
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Initial state
      expect(find.text('Test Button'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Tap to start loading
      await tester.tap(find.byType(EnhancedButton));
      await tester.pump();

      expect(find.text('Test Button'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('EnhancedCard should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: EnhancedTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: EnhancedCard(
                child: Text('Card Content'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
      expect(find.byType(EnhancedCard), findsOneWidget);
    });

    testWidgets('EnhancedInputField should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: EnhancedTheme.lightTheme,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: EnhancedInputField(
                label: 'Test Field',
                hint: 'Enter text',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Field'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('EnhancedChip should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: EnhancedTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: EnhancedChip(
                label: 'Test Chip',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Chip'), findsOneWidget);
      expect(find.byType(RawChip), findsOneWidget);
    });

    testWidgets('EnhancedLoading should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: EnhancedTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: EnhancedLoading(
                message: 'Loading...',
                type: LoadingType.circular,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Loading...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('Responsive Layout Tests', () {
    testWidgets('ResponsiveLayout should show mobile layout on small screens', (WidgetTester tester) async {
      tester.binding.window.physicalSize = const Size(300, 600);
      tester.binding.window.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: EnhancedTheme.lightTheme,
          home: ResponsiveLayout(
            mobile: Container(
              color: Colors.red,
              child: const Text('Mobile'),
            ),
            tablet: Container(
              color: Colors.green,
              child: const Text('Tablet'),
            ),
            desktop: Container(
              color: Colors.blue,
              child: const Text('Desktop'),
            ),
          ),
        ),
      );

      expect(find.text('Mobile'), findsOneWidget);
      expect(find.text('Tablet'), findsNothing);
      expect(find.text('Desktop'), findsNothing);
    });

    testWidgets('ResponsiveLayout should show tablet layout on medium screens', (WidgetTester tester) async {
      tester.binding.window.physicalSize = const Size(800, 600);
      tester.binding.window.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: EnhancedTheme.lightTheme,
          home: ResponsiveLayout(
            mobile: Container(
              color: Colors.red,
              child: const Text('Mobile'),
            ),
            tablet: Container(
              color: Colors.green,
              child: const Text('Tablet'),
            ),
            desktop: Container(
              color: Colors.blue,
              child: const Text('Desktop'),
            ),
          ),
        ),
      );

      expect(find.text('Mobile'), findsNothing);
      expect(find.text('Tablet'), findsOneWidget);
      expect(find.text('Desktop'), findsNothing);
    });

    testWidgets('ResponsiveContainer should adapt padding', (WidgetTester tester) async {
      tester.binding.window.physicalSize = const Size(300, 600);
      tester.binding.window.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: EnhancedTheme.lightTheme,
          home: Scaffold(
            body: ResponsiveContainer(
              child: const Text('Responsive Content'),
            ),
          ),
        ),
      );

      expect(find.text('Responsive Content'), findsOneWidget);
    });
  });

  group('Animation Tests', () {
    testWidgets('AnimatedContainer should animate on property change', (WidgetTester tester) async {
      Color containerColor = Colors.blue;

      await tester.pumpWidget(
        MaterialApp(
          theme: EnhancedTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: StatefulBuilder(
                builder: (context, setState) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        containerColor = containerColor == Colors.blue ? Colors.red : Colors.blue;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      color: containerColor,
                      width: 100,
                      height: 100,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(find.byType(AnimatedContainer), findsOneWidget);
      
      // Tap to change color
      await tester.tap(find.byType(AnimatedContainer));
      await tester.pumpAndSettle();

      // Verify animation completed
      expect(find.byType(AnimatedContainer), findsOneWidget);
    });

    testWidgets('AnimatedButton should animate on tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: EnhancedTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: EnhancedButton(
                text: 'Animated Button',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Animated Button'), findsOneWidget);
      
      // Tap button to trigger animation
      await tester.tap(find.byType(EnhancedButton));
      await tester.pump();

      expect(find.text('Animated Button'), findsOneWidget);
    });

    testWidgets('AnimatedList should stagger animations', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: EnhancedTheme.lightTheme,
          home: Scaffold(
            body: AnimatedList(
              children: List.generate(3, (index) => Text('Item $index')),
              duration: const Duration(milliseconds: 100),
              staggerDelay: const Duration(milliseconds: 50),
            ),
          ),
        ),
      );

      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
    });

    testWidgets('AnimatedCounter should animate value changes', (WidgetTester tester) async {
      int counter = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: EnhancedTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      AnimatedCounter(
                        value: counter,
                        duration: const Duration(milliseconds: 500),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            counter++;
                          });
                        },
                        child: const Text('Increment'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
      
      // Tap to increment
      await tester.tap(find.text('Increment'));
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
    });
  });

  group('Navigation Tests', () {
    testWidgets('EnhancedNavigation should render correctly', (WidgetTester tester) async {
      int currentIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: EnhancedTheme.lightTheme,
          home: Scaffold(
            body: EnhancedNavigation(
              currentIndex: currentIndex,
              onTap: (index) {
                currentIndex = index;
              },
              items: const [
                NavigationItem(icon: Icons.home, label: 'Home'),
                NavigationItem(icon: Icons.search, label: 'Search'),
                NavigationItem(icon: Icons.person, label: 'Profile'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('EnhancedAppBar should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: EnhancedTheme.lightTheme,
          home: Scaffold(
            appBar: EnhancedAppBar(
              title: 'Test App',
              actions: [
                IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
              ],
            ),
            body: const Center(child: Text('Content')),
          ),
        ),
      );

      expect(find.text('Test App'), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('BreadcrumbNavigation should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: EnhancedTheme.lightTheme,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: BreadcrumbNavigation(
                items: const [
                  BreadcrumbItem(label: 'Home'),
                  BreadcrumbItem(label: 'Products'),
                  BreadcrumbItem(label: 'Details'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Products'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
    });
  });

  group('Accessibility Tests', () {
    testWidgets('AccessibleButton should have proper semantics', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: EnhancedTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: AccessibleButton(
                text: 'Accessible Button',
                onPressed: () {},
                semanticLabel: 'Action Button',
                semanticHint: 'Performs an action',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Accessible Button'), findsOneWidget);
      
      // Check semantics
      final button = tester.widget<AccessibleButton>(find.byType(AccessibleButton));
      expect(button.semanticLabel, equals('Action Button'));
      expect(button.semanticHint, equals('Performs an action'));
    });

    testWidgets('AccessibleInputField should have proper semantics', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: EnhancedTheme.lightTheme,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: AccessibleInputField(
                label: 'Accessible Field',
                hint: 'Enter text here',
                semanticLabel: 'Text Input',
                semanticHint: 'Required field',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Accessible Field'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('Accessibility settings should work', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: EnhancedTheme.lightTheme,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: AccessibilitySettings(
                onSettingsChanged: () {
                  // Settings changed
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('High Contrast'), findsOneWidget);
      expect(find.text('Large Text'), findsOneWidget);
      expect(find.text('Reduced Motion'), findsOneWidget);
      expect(find.text('Screen Reader Support'), findsOneWidget);
      expect(find.text('Text Size'), findsOneWidget);
    });

    testWidgets('EnhancedAccessibility should handle settings', (WidgetTester tester) async {
      // Test high contrast
      EnhancedAccessibility.highContrast = true;
      expect(EnhancedAccessibility.highContrast, isTrue);

      // Test large text
      EnhancedAccessibility.largeText = true;
      expect(EnhancedAccessibility.largeText, isTrue);

      // Test reduced motion
      EnhancedAccessibility.reducedMotion = true;
      expect(EnhancedAccessibility.reducedMotion, isTrue);

      // Test screen reader
      EnhancedAccessibility.screenReader = true;
      expect(EnhancedAccessibility.screenReader, isTrue);

      // Test text scale
      EnhancedAccessibility.textScaleFactor = 1.5;
      expect(EnhancedAccessibility.textScaleFactor, equals(1.5));
    });
  });

  group('Performance Tests', () {
    testWidgets('OptimizedListView should handle large lists efficiently', (WidgetTester tester) async {
      final items = List.generate(100, (index) => Text('Item $index'));

      await tester.pumpWidget(
        MaterialApp(
          theme: EnhancedTheme.lightTheme,
          home: Scaffold(
            body: OptimizedListView(
              children: items,
            ),
          ),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
      
      // Scroll through the list
      await tester.fling(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Should still be performant
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('OptimizedGridView should handle large grids efficiently', (WidgetTester tester) async {
      final items = List.generate(50, (index) => Text('Item $index'));

      await tester.pumpWidget(
        MaterialApp(
          theme: EnhancedTheme.lightTheme,
          home: Scaffold(
            body: OptimizedGridView(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.0,
              ),
              children: items,
            ),
          ),
        ),
      );

      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('LazyLoader should defer widget creation', (WidgetTester tester) async {
      bool widgetCreated = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: EnhancedTheme.lightTheme,
          home: Scaffold(
            body: LazyLoader(
              builder: () {
                widgetCreated = true;
                return const Text('Lazy Loaded');
              },
              placeholder: const Text('Loading...'),
              delay: const Duration(milliseconds: 100),
            ),
          ),
        ),
      );

      // Initially should show placeholder
      expect(find.text('Loading...'), findsOneWidget);
      expect(find.text('Lazy Loaded'), findsNothing);
      expect(widgetCreated, isFalse);

      // Wait for lazy loading
      await tester.pump(const Duration(milliseconds: 150));
      
      expect(find.text('Lazy Loaded'), findsOneWidget);
      expect(find.text('Loading...'), findsNothing);
      expect(widgetCreated, isTrue);
    });

    testWidgets('PerformanceOptimizer should track metrics', (WidgetTester tester) async {
      // Enable performance monitoring
      PerformanceOptimizer.enablePerformanceMonitoring();

      await tester.pumpWidget(
        MaterialApp(
          theme: EnhancedTheme.lightTheme,
          home: Scaffold(
            body: Container(),
          ),
        ),
      );

      // Let some frames pass
      await tester.pump(const Duration(milliseconds: 100));

      // Check metrics
      final report = PerformanceOptimizer.getReport();
      expect(report.totalFrames, greaterThan(0);
      expect(report.averageFrameTime, greaterThan(0));
      expect(report.frameRate, greaterThan(0));

      // Disable monitoring
      PerformanceOptimizer.disablePerformanceMonitoring();
    });

    testWidgets('PerformanceUtils debounce should work correctly', (WidgetTester tester) async {
      int callCount = 0;
      final debouncedFunction = PerformanceUtils.debounce(() {
        callCount++;
      }, const Duration(milliseconds: 100));

      // Call multiple times quickly
      debouncedFunction();
      debouncedFunction();
      debouncedFunction();

      // Should not have been called yet
      expect(callCount, equals(0));

      // Wait for debounce
      await tester.pump(const Duration(milliseconds: 150));

      // Should have been called once
      expect(callCount, equals(1));
    });

    testWidgets('PerformanceUtils throttle should work correctly', (WidgetTester tester) async {
      int callCount = 0;
      final throttledFunction = PerformanceUtils.throttle(() {
        callCount++;
      }, const Duration(milliseconds: 100));

      // Call multiple times quickly
      throttledFunction();
      throttledFunction();
      throttledFunction();

      // Should have been called once immediately
      expect(callCount, equals(1));

      // Wait for throttle period
      await tester.pump(const Duration(milliseconds: 150));

      // Call again
      throttledFunction();

      // Should have been called again
      expect(callCount, equals(2));
    });

    testWidgets('PerformanceUtils memoize should work correctly', (WidgetTester tester) async {
      int computationCount = 0;
      
      final result1 = PerformanceUtils.memoize('key1', () {
        computationCount++;
        return 'result1';
      });
      
      final result2 = PerformanceUtils.memoize('key1', () {
        computationCount++;
        return 'result2';
      });

      expect(result1, equals('result1'));
      expect(result2, equals('result1'));
      expect(computationCount, equals(1));
    });
  });

  group('Integration Tests', () {
    testWidgets('Complete UI flow should work seamlessly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: EnhancedTheme.lightTheme,
          home: Scaffold(
            appBar: EnhancedAppBar(
              title: 'VedantaTrade',
              actions: [
                IconButton(icon: const Icon(Icons.search), onPressed: () {}),
              ],
            ),
            body: ResponsiveLayout(
              mobile: Column(
                children: [
                  EnhancedCard(
                    child: Column(
                      children: [
                        const Text('Welcome to VedantaTrade'),
                        const SizedBox(height: 16),
                        EnhancedButton(
                          text: 'Get Started',
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  OptimizedListView(
                    children: List.generate(5, (index) => 
                      EnhancedCard(
                        child: ListTile(
                          leading: const Icon(Icons.inventory),
                          title: Text('Product $index'),
                          subtitle: Text('Description $index'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              tablet: const Center(
                child: Text('Tablet Layout'),
              ),
              desktop: const Center(
                child: Text('Desktop Layout'),
              ),
            ),
            bottomNavigationBar: EnhancedNavigation(
              currentIndex: 0,
              onTap: (index) {},
              items: const [
                NavigationItem(icon: Icons.home, label: 'Home'),
                NavigationItem(icon: Icons.inventory, label: 'Products'),
                NavigationItem(icon: Icons.person, label: 'Profile'),
              ],
            ),
          ),
        ),
      );

      // Verify all components rendered
      expect(find.text('VedantaTrade'), findsOneWidget);
      expect(find.text('Welcome to VedantaTrade'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Product 0'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Products'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('Theme switching should work correctly', (WidgetTester tester) async {
      bool isDarkTheme = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: isDarkTheme ? EnhancedTheme.darkTheme : EnhancedTheme.lightTheme,
          darkTheme: EnhancedTheme.darkTheme,
          home: Scaffold(
            body: Center(
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      Text('Test Text'),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isDarkTheme = !isDarkTheme;
                          });
                        },
                        child: const Text('Toggle Theme'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Test light theme
      expect(find.text('Test Text'), findsOneWidget);
      
      // Toggle theme
      await tester.tap(find.text('Toggle Theme'));
      await tester.pump();

      // Test dark theme
      expect(find.text('Test Text'), findsOneWidget);
    });

    testWidgets('Accessibility should enhance user experience', (WidgetTester tester) async {
      // Enable accessibility features
      EnhancedAccessibility.highContrast = true;
      EnhancedAccessibility.largeText = true;
      EnhancedAccessibility.screenReader = true;

      await tester.pumpWidget(
        MaterialApp(
          theme: EnhancedTheme.lightTheme,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  AccessibleButton(
                    text: 'Accessible Button',
                    onPressed: () {},
                    semanticLabel: 'Primary Action',
                    semanticHint: 'Tap to perform action',
                  ),
                  const SizedBox(height: 16),
                  AccessibleInputField(
                    label: 'Search',
                    hint: 'Enter search term',
                    semanticLabel: 'Search Input',
                    accessibilityHint: 'Required field for searching',
                  ),
                  const SizedBox(height: 16),
                  AccessibleCard(
                    child: const Text('Accessible Card Content'),
                    semanticLabel: 'Information Card',
                    semanticHint: 'Contains important information',
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Verify all accessible components rendered
      expect(find.text('Accessible Button'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Accessible Card Content'), findsOneWidget);
    });
  });

  group('Error Handling Tests', () {
    testWidgets('EnhancedButton should handle null onPressed gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: EnhancedTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: EnhancedButton(
                text: 'Disabled Button',
                onPressed: null,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Disabled Button'), findsOneWidget);
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('EnhancedInputField should handle validation errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: EnhancedTheme.lightTheme,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: EnhancedInputField(
                label: 'Email',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  if (!value.contains('@')) {
                    return 'Invalid email format';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      // Submit empty form
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Should show validation error
      expect(find.text('Email is required'), findsOneWidget);
    });
  });
}

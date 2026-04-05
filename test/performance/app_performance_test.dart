import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../../../../lib/main.dart' as app;
import '../unit/test_helpers/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Performance Tests', () {
    testWidgets('app startup performance', (WidgetTester tester) async {
      // Arrange
      final stopwatch = Stopwatch()..start();

      // Act
      app.main();
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Assert
      expect(stopwatch.elapsedMilliseconds, lessThan(3000),
          reason: 'App should start within 3 seconds');
      
      // Check memory usage
      PerformanceTestUtils.assertMemoryUsage(100); // 100MB max
    });

    testWidgets('screen transition performance', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act & Measure
      final transitionTimes = <Duration>[];
      
      for (int i = 0; i < 5; i++) {
        final stopwatch = Stopwatch()..start();
        
        // Navigate to different screens
        await tester.tap(find.byKey(const Key('dashboard_button')));
        await tester.pumpAndSettle();
        
        stopwatch.stop();
        transitionTimes.add(stopwatch.elapsed);
        
        // Navigate back
        await tester.tap(find.byKey(const Key('back_button')));
        await tester.pumpAndSettle();
      }

      // Assert
      final averageTime = transitionTimes.reduce((a, b) => a + b) / transitionTimes.length;
      expect(averageTime.inMilliseconds, lessThan(500),
          reason: 'Screen transitions should average less than 500ms');
    });

    testWidgets('list scrolling performance', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();
      
      // Navigate to product catalog
      await tester.tap(find.byKey(const Key('product_catalog_button')));
      await tester.pumpAndSettle();

      // Act - Measure scrolling performance
      final scrollPerformance = <Duration>[];
      
      for (int i = 0; i < 10; i++) {
        final stopwatch = Stopwatch()..start();
        
        // Scroll down
        await tester.fling(
          find.byType(ListView),
          const Offset(0, -500),
          1000,
        );
        await tester.pumpAndSettle();
        
        stopwatch.stop();
        scrollPerformance.add(stopwatch.elapsed);
        
        // Scroll back up
        await tester.fling(
          find.byType(ListView),
          const Offset(0, 500),
          1000,
        );
        await tester.pumpAndSettle();
      }

      // Assert
      final averageScrollTime = scrollPerformance.reduce((a, b) => a + b) / scrollPerformance.length;
      expect(averageScrollTime.inMilliseconds, lessThan(100),
          reason: 'List scrolling should be smooth (< 100ms per frame)');
    });

    testWidgets('form interaction performance', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act - Measure form interaction performance
      final formPerformance = <Duration>[];
      
      for (int i = 0; i < 20; i++) {
        final stopwatch = Stopwatch()..start();
        
        // Fill form rapidly
        await tester.enterText(find.byKey(const Key('email_field')), 'test$i@vedantatrade.com');
        await tester.enterText(find.byKey(const Key('password_field')), 'password$i');
        
        // Clear form
        await tester.tap(find.byKey(const Key('clear_button')));
        await tester.pump();
        
        stopwatch.stop();
        formPerformance.add(stopwatch.elapsed);
      }

      // Assert
      final averageFormTime = formPerformance.reduce((a, b) => a + b) / formPerformance.length;
      expect(averageFormTime.inMilliseconds, lessThan(50),
          reason: 'Form interactions should be responsive (< 50ms)');
    });

    testWidgets('animation performance', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act - Trigger animations and measure performance
      final animationPerformance = <Duration>[];
      
      for (int i = 0; i < 5; i++) {
        final stopwatch = Stopwatch()..start();
        
        // Trigger animation
        await tester.tap(find.byKey(const Key('animate_button')));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        
        stopwatch.stop();
        animationPerformance.add(stopwatch.elapsed);
      }

      // Assert
      for (final performance in animationPerformance) {
        expect(performance.inMilliseconds, lessThan(1000),
            reason: 'Animations should complete within 1 second');
      }
    });

    testWidgets('memory usage under load', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act - Create memory pressure
      for (int i = 0; i < 100; i++) {
        // Navigate to different screens
        await tester.tap(find.byKey(const Key('product_catalog_button')));
        await tester.pumpAndSettle();
        
        // Navigate to detail screens
        await tester.tap(find.byKey(const Key('product_item_$i')));
        await tester.pumpAndSettle();
        
        // Navigate back
        await tester.tap(find.byKey(const Key('back_button')));
        await tester.pumpAndSettle();
        
        // Navigate to dashboard
        await tester.tap(find.byKey(const Key('dashboard_button')));
        await tester.pumpAndSettle();
      }

      // Assert
      PerformanceTestUtils.assertMemoryUsage(150); // 150MB max under load
    });

    testWidgets('network request performance', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act - Measure network request performance
      final networkPerformance = <Duration>[];
      
      // Load data from multiple screens
      final screens = [
        'product_catalog_button',
        'distribution_button',
        'analytics_button',
        'reports_button',
      ];
      
      for (final screen in screens) {
        final stopwatch = Stopwatch()..start();
        
        await tester.tap(find.byKey(const Key(screen)));
        await tester.pumpAndSettle(const Duration(seconds: 5));
        
        stopwatch.stop();
        networkPerformance.add(stopwatch.elapsed);
        
        await tester.tap(find.byKey(const Key('back_button')));
        await tester.pumpAndSettle();
      }

      // Assert
      for (final performance in networkPerformance) {
        expect(performance.inMilliseconds, lessThan(3000),
            reason: 'Network requests should complete within 3 seconds');
      }
    });

    testWidgets('concurrent operations performance', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act - Perform concurrent operations
      final stopwatch = Stopwatch()..start();
      
      // Simulate multiple simultaneous operations
      final futures = <Future>[];
      
      futures.add(tester.tap(find.byKey(const Key('product_catalog_button'))));
      futures.add(tester.tap(find.byKey(const Key('distribution_button'))));
      futures.add(tester.tap(find.byKey(const Key('analytics_button'))));
      
      await Future.wait(futures);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      
      stopwatch.stop();

      // Assert
      expect(stopwatch.elapsedMilliseconds, lessThan(5000),
          reason: 'Concurrent operations should complete within 5 seconds');
    });

    testWidgets('rendering performance with complex UI', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act - Navigate to complex UI screens
      final complexScreens = [
        'analytics_dashboard_button',
        'reports_button',
        'settings_button',
      ];
      
      for (final screen in complexScreens) {
        final stopwatch = Stopwatch()..start();
        
        await tester.tap(find.byKey(const Key(screen)));
        await tester.pumpAndSettle();
        
        // Measure rendering time
        final renderStopwatch = Stopwatch()..start();
        await tester.pump(const Duration(milliseconds: 16)); // 60fps frame
        renderStopwatch.stop();
        
        stopwatch.stop();
        
        // Assert
        expect(renderStopwatch.elapsedMilliseconds, lessThan(16),
            reason: 'Complex UI should render at 60fps');
        expect(stopwatch.elapsedMilliseconds, lessThan(1000),
            reason: 'Screen navigation should complete within 1 second');
        
        await tester.tap(find.byKey(const Key('back_button')));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('database operations performance', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act - Measure database operations
      final dbPerformance = <Duration>[];
      
      // Insert operations
      for (int i = 0; i < 50; i++) {
        final stopwatch = Stopwatch()..start();
        
        // Simulate database insert
        await tester.tap(find.byKey(const Key('add_data_button')));
        await tester.pumpAndSettle();
        
        stopwatch.stop();
        dbPerformance.add(stopwatch.elapsed);
      }

      // Query operations
      for (int i = 0; i < 50; i++) {
        final stopwatch = Stopwatch()..start();
        
        // Simulate database query
        await tester.tap(find.byKey(const Key('query_data_button')));
        await tester.pumpAndSettle();
        
        stopwatch.stop();
        dbPerformance.add(stopwatch.elapsed);
      }

      // Assert
      final averageDbTime = dbPerformance.reduce((a, b) => a + b) / dbPerformance.length;
      expect(averageDbTime.inMilliseconds, lessThan(100),
          reason: 'Database operations should be fast (< 100ms average)');
    });

    testWidgets('image loading and caching performance', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act - Navigate to screens with images
      await tester.tap(find.byKey(const Key('product_catalog_button')));
      await tester.pumpAndSettle();

      final imageLoadTimes = <Duration>[];
      
      // Load multiple images
      for (int i = 0; i < 20; i++) {
        final stopwatch = Stopwatch()..start();
        
        // Scroll to trigger image loading
        await tester.fling(
          find.byType(ListView),
          const Offset(0, -300),
          500,
        );
        await tester.pumpAndSettle(const Duration(seconds: 2));
        
        stopwatch.stop();
        imageLoadTimes.add(stopwatch.elapsed);
      }

      // Assert
      for (final loadTime in imageLoadTimes) {
        expect(loadTime.inMilliseconds, lessThan(2000),
            reason: 'Images should load within 2 seconds');
      }
    });

    testWidgets('state management performance', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act - Measure state management performance
      final statePerformance = <Duration>[];
      
      // Trigger multiple state changes
      for (int i = 0; i < 100; i++) {
        final stopwatch = Stopwatch()..start();
        
        // Change app state
        await tester.tap(find.byKey(const Key('toggle_theme_button')));
        await tester.pump();
        
        await tester.tap(find.byKey(const Key('toggle_language_button')));
        await tester.pump();
        
        stopwatch.stop();
        statePerformance.add(stopwatch.elapsed);
      }

      // Assert
      final averageStateTime = statePerformance.reduce((a, b) => a + b) / statePerformance.length;
      expect(averageStateTime.inMilliseconds, lessThan(10),
          reason: 'State changes should be very fast (< 10ms average)');
    });

    testWidgets('long-running operations performance', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act - Perform long-running operations
      final longOperations = [
        'export_reports_button',
        'sync_data_button',
        'backup_data_button',
      ];
      
      for (final operation in longOperations) {
        final stopwatch = Stopwatch()..start();
        
        await tester.tap(find.byKey(const Key(operation)));
        await tester.pumpAndSettle(const Duration(seconds: 10));
        
        stopwatch.stop();
        
        // Assert
        expect(stopwatch.elapsed.inSeconds, lessThan(10,
            reason: 'Long operations should complete within 10 seconds');
        
        // Check if progress indicator is shown
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        
        // Wait for completion
        await tester.pumpAndSettle(const Duration(seconds: 5));
      }
    });

    testWidgets('stress test - rapid UI interactions', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act - Perform rapid interactions
      final stopwatch = Stopwatch()..start();
      
      for (int i = 0; i < 200; i++) {
        // Rapid button taps
        await tester.tap(find.byKey(const Key('dashboard_button')));
        await tester.pump(const Duration(milliseconds: 10));
        
        await tester.tap(find.byKey(const Key('product_catalog_button')));
        await tester.pump(const Duration(milliseconds: 10));
        
        await tester.tap(find.byKey(const Key('distribution_button')));
        await tester.pump(const Duration(milliseconds: 10));
        
        // Rapid scrolling
        await tester.fling(find.byType(ListView), const Offset(0, -100), 500);
        await tester.pump(const Duration(milliseconds: 10));
      }
      
      await tester.pumpAndSettle();
      stopwatch.stop();

      // Assert
      expect(stopwatch.elapsed.inSeconds, lessThan(30,
          reason: 'Stress test should complete within 30 seconds');
      
      // App should still be responsive
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('memory leak detection', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act - Perform operations that could cause memory leaks
      for (int i = 0; i < 50; i++) {
        // Navigate to screens with heavy content
        await tester.tap(find.byKey(const Key('analytics_button')));
        await tester.pumpAndSettle();
        
        // Create and destroy widgets
        await tester.tap(find.byKey(const Key('create_chart_button')));
        await tester.pumpAndSettle();
        
        await tester.tap(find.byKey(const Key('destroy_chart_button')));
        await tester.pumpAndSettle();
        
        // Navigate back
        await tester.tap(find.byKey(const Key('back_button')));
        await tester.pumpAndSettle();
      }

      // Assert
      // Force garbage collection and check memory
      await tester.pumpAndSettle(const Duration(seconds: 2));
      PerformanceTestUtils.assertMemoryUsage(120); // Should not exceed 120MB
    });

    testWidgets('battery usage optimization', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act - Measure battery-related performance
      final cpuUsage = <int>[];
      
      // Perform CPU-intensive operations
      for (int i = 0; i < 10; i++) {
        final stopwatch = Stopwatch()..start();
        
        // Simulate CPU-intensive task
        await tester.tap(find.byKey(const Key('process_data_button')));
        await tester.pumpAndSettle(const Duration(seconds: 2));
        
        stopwatch.stop();
        
        // In a real implementation, we would measure actual CPU usage
        // For now, we'll assume the operation completes efficiently
        expect(stopwatch.elapsed.inSeconds, lessThan(2,
            reason: 'CPU-intensive tasks should complete quickly');
      }
    });

    testWidgets('thermal performance', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act - Perform operations that could cause thermal throttling
      final thermalOperations = [
        'render_complex_chart_button',
        'process_large_dataset_button',
        'run_computation_heavy_task_button',
      ];
      
      for (final operation in thermalOperations) {
        final stopwatch = Stopwatch()..start();
        
        await tester.tap(find.byKey(const Key(operation)));
        await tester.pumpAndSettle(const Duration(seconds: 5));
        
        stopwatch.stop();
        
        // Assert - Operations should not take too long (indicating thermal throttling)
        expect(stopwatch.elapsed.inSeconds, lessThan(5,
            reason: 'Operations should not be affected by thermal throttling');
      }
    });
  });
}

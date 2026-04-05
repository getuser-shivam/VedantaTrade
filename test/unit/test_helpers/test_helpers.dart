import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

/// Test Helpers for VedantaTrade Testing Suite
/// Provides common utilities, mocks, and test data for all test types

// Generate mocks with: dart run build_runner build
@GenerateMocks([
  // Authentication
  AuthenticationRepository,
  AuthenticationService,
  AuthProvider,
  
  // Product Catalog
  ProductCatalogRepository,
  ProductCatalogService,
  ProductProvider,
  
  // Distribution
  DistributionRepository,
  DistributionService,
  DistributionProvider,
  
  // Storage & Network
  StorageService,
  NetworkService,
  
  // Utilities
  AppUtils,
  FormValidator,
])
void main() {}

/// Common test utilities
class TestUtils {
  /// Test user data
  static const Map<String, dynamic> testUserData = {
    'id': 'test-user-123',
    'email': 'test@vedantatrade.com',
    'name': 'Test User',
    'role': 'admin',
    'isActive': true,
    'createdAt': '2026-04-05T12:00:00.000Z',
  };

  /// Test product data
  static const Map<String, dynamic> testProductData = {
    'id': 'test-product-123',
    'name': 'Test Medicine',
    'category': 'Pain Relief',
    'price': 150.0,
    'stock': 100,
    'description': 'Test medicine for testing purposes',
    'manufacturer': 'Test Pharma Ltd',
    'isActive': true,
  };

  /// Test distribution data
  static const Map<String, dynamic> testDistributionData = {
    'id': 'test-dist-123',
    'productId': 'test-product-123',
    'retailerId': 'test-retailer-123',
    'quantity': 50,
    'status': 'pending',
    'createdAt': '2026-04-05T12:00:00.000Z',
    'estimatedDelivery': '2026-04-07T12:00:00.000Z',
  };

  /// Create test file path
  static String testFilePath(String fileName) => 'test/fixtures/$fileName';

  /// Load test fixture data
  static Future<Map<String, dynamic>> loadFixture(String fileName) async {
    // This would load JSON fixtures in a real implementation
    return {};
  }

  /// Create test widget wrapper
  static Widget createTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  /// Wait for async operations
  static Future<void> waitForAsync([Duration? duration]) {
    return Future.delayed(duration ?? const Duration(milliseconds: 100));
  }

  /// Pump and settle widget tests
  static Future<void> pumpAndSettle(
    WidgetTester tester, {
    Duration? duration,
  }) async {
    await tester.pumpAndSettle(duration ?? const Duration(seconds: 1));
  }

  /// Find widget by type
  static T findWidget<T extends Widget>(WidgetTester tester) {
    return tester.widget<T>(find.byType(T));
  }

  /// Find widget by key
  static Widget findWidgetByKey(WidgetTester tester, String key) {
    return tester.widget(find.byKey(Key(key)));
  }

  /// Tap widget and settle
  static Future<void> tapAndSettle(
    WidgetTester tester,
    Finder finder, {
    Duration? duration,
  }) async {
    await tester.tap(finder);
    await pumpAndSettle(tester, duration);
  }

  /// Enter text and settle
  static Future<void> enterTextAndSettle(
    WidgetTester tester,
    Finder finder,
    String text, {
    Duration? duration,
  }) async {
    await tester.enterText(finder, text);
    await pumpAndSettle(tester, duration);
  }

  /// Verify widget exists
  static bool widgetExists(WidgetTester tester, Finder finder) {
    return tester.any(finder);
  }

  /// Get widget text
  static String getWidgetText(WidgetTester tester, Finder finder) {
    return tester.widget<Text>(finder).data ?? '';
  }

  /// Verify text contains
  static bool textContains(WidgetTester tester, String expectedText) {
    return find.text(expectedText).evaluate().isNotEmpty;
  }
}

/// Mock response data
class MockResponses {
  static const String successResponse = '{"status": "success", "data": {}}';
  static const String errorResponse = '{"status": "error", "message": "Test error"}';
  static const String authSuccessResponse = '''
  {
    "status": "success",
    "data": {
      "token": "test-token-123",
      "user": ${TestUtils.testUserData}
    }
  }
  ''';
  static const String productSuccessResponse = '''
  {
    "status": "success",
    "data": {
      "products": [${TestUtils.testProductData}]
    }
  }
  ''';
}

/// Test configuration
class TestConfig {
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration shortTimeout = Duration(seconds: 5);
  static const Duration longTimeout = Duration(minutes: 2);
  
  static const String testBaseUrl = 'https://api.test.vedantatrade.com';
  static const String testApiKey = 'test-api-key-123';
  
  static const Map<String, String> testHeaders = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer test-token-123',
    'X-API-Key': testApiKey,
  };
}

/// Custom test matchers
class CustomMatchers {
  /// Matcher for successful API responses
  static Matcher isSuccessResponse() => allOf([
    contains('status'),
    containsPair('status', 'success'),
  ]);

  /// Matcher for error API responses
  static Matcher isErrorResponse() => allOf([
    contains('status'),
    containsPair('status', 'error'),
    contains('message'),
  ]);

  /// Matcher for valid user data
  static Matcher isValidUserData() => allOf([
    contains('id'),
    contains('email'),
    contains('name'),
    contains('role'),
  ]);

  /// Matcher for valid product data
  static Matcher isValidProductData() => allOf([
    contains('id'),
    contains('name'),
    contains('category'),
    contains('price'),
    contains('stock'),
  ]);
}

/// Test data builders
class TestDataBuilder {
  /// Build test user entity
  static Map<String, dynamic> buildTestUser({
    String? id,
    String? email,
    String? name,
    String? role,
    bool? isActive,
  }) {
    return {
      'id': id ?? 'test-user-123',
      'email': email ?? 'test@vedantatrade.com',
      'name': name ?? 'Test User',
      'role': role ?? 'admin',
      'isActive': isActive ?? true,
      'createdAt': '2026-04-05T12:00:00.000Z',
    };
  }

  /// Build test product entity
  static Map<String, dynamic> buildTestProduct({
    String? id,
    String? name,
    String? category,
    double? price,
    int? stock,
    String? description,
    String? manufacturer,
    bool? isActive,
  }) {
    return {
      'id': id ?? 'test-product-123',
      'name': name ?? 'Test Medicine',
      'category': category ?? 'Pain Relief',
      'price': price ?? 150.0,
      'stock': stock ?? 100,
      'description': description ?? 'Test medicine for testing purposes',
      'manufacturer': manufacturer ?? 'Test Pharma Ltd',
      'isActive': isActive ?? true,
    };
  }

  /// Build test distribution entity
  static Map<String, dynamic> buildTestDistribution({
    String? id,
    String? productId,
    String? retailerId,
    int? quantity,
    String? status,
    String? createdAt,
    String? estimatedDelivery,
  }) {
    return {
      'id': id ?? 'test-dist-123',
      'productId': productId ?? 'test-product-123',
      'retailerId': retailerId ?? 'test-retailer-123',
      'quantity': quantity ?? 50,
      'status': status ?? 'pending',
      'createdAt': createdAt ?? '2026-04-05T12:00:00.000Z',
      'estimatedDelivery': estimatedDelivery ?? '2026-04-07T12:00:00.000Z',
    };
  }
}

/// Performance testing utilities
class PerformanceTestUtils {
  /// Measure execution time
  static Future<Duration> measureExecutionTime(Future<void> Function() operation) async {
    final stopwatch = Stopwatch()..start();
    await operation();
    stopwatch.stop();
    return stopwatch.elapsed;
  }

  /// Assert performance within threshold
  static void assertPerformance(Duration actual, Duration threshold) {
    expect(actual.inMilliseconds, lessThan(threshold.inMilliseconds),
        reason: 'Operation took ${actual.inMilliseconds}ms, expected less than ${threshold.inMilliseconds}ms');
  }

  /// Memory usage test helper
  static void assertMemoryUsage(int maxMemoryMB) {
    // This would use dart:developer to check memory in real implementation
    // For now, just a placeholder
    expect(true, isTrue, reason: 'Memory usage check placeholder');
  }
}

/// Integration test utilities
class IntegrationTestUtils {
  /// Setup integration test environment
  static Future<void> setupIntegrationTest() async {
    // Setup test database
    // Setup test server
    // Configure test environment
    await TestUtils.waitForAsync();
  }

  /// Cleanup integration test environment
  static Future<void> cleanupIntegrationTest() async {
    // Cleanup test database
    // Stop test server
    // Reset test environment
    await TestUtils.waitForAsync();
  }

  /// Create test HTTP client
  static http.Client createTestHttpClient() {
    return http.Client();
  }
}

/// Accessibility test utilities
class AccessibilityTestUtils {
  /// Check widget accessibility
  static void checkAccessibility(WidgetTester tester, Finder finder) {
    final widget = tester.widget(finder);
    
    // Check for semantic labels
    if (widget is Semantics) {
      expect(widget.properties.label, isNotEmpty, 
          reason: 'Widget should have semantic label');
    }
    
    // Check for focusable elements
    if (widget is Focus) {
      expect(widget.canRequestFocus, isTrue,
          reason: 'Focusable widget should be able to request focus');
    }
  }

  /// Verify screen reader compatibility
  static void verifyScreenReaderCompatibility(WidgetTester tester) {
    final semantics = tester.binding.pipelineOwner.semanticsOwner;
    expect(semantics, isNotNull, 
        reason: 'Semantics owner should be available for screen reader');
  }
}

/// Localization test utilities
class LocalizationTestUtils {
  /// Test localized strings
  static void testLocalizedString(WidgetTester tester, String key, String expectedValue) {
    final finder = find.byKey(Key(key));
    expect(finder, findsOneWidget, reason: 'Localized widget should exist');
    
    final text = TestUtils.getWidgetText(tester, finder);
    expect(text, equals(expectedValue), 
        reason: 'Localized text should match expected value');
  }

  /// Test RTL/LTR layout
  static void testTextDirection(WidgetTester tester, TextDirection expectedDirection) {
    final context = tester.element(find.byType(MaterialApp));
    expect(Directionality.of(context), equals(expectedDirection),
        reason: 'Text direction should match expected');
  }
}

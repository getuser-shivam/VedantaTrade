import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test Configuration for VedantaTrade Testing Suite
/// Centralized configuration for all test types and environments

class TestConfig {
  // Test Environment Configuration
  static const String testEnvironment = 'test';
  static const String stagingEnvironment = 'staging';
  static const String productionEnvironment = 'production';
  
  // Test Timeouts
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration shortTimeout = Duration(seconds: 10);
  static const Duration longTimeout = Duration(minutes: 2);
  static const Duration networkTimeout = Duration(seconds: 15);
  static const Duration animationTimeout = Duration(seconds: 5);
  
  // Test Data Configuration
  static const int maxTestUsers = 10;
  static const int maxTestProducts = 50;
  static const int maxTestDistributions = 20;
  static const int maxTestOrders = 100;
  
  // Performance Thresholds
  static const Duration maxAppStartupTime = Duration(seconds: 3);
  static const Duration maxScreenTransitionTime = Duration(milliseconds: 500);
  static const Duration maxScrollingFrameTime = Duration(milliseconds: 16);
  static const Duration maxFormInteractionTime = Duration(milliseconds: 50);
  static const Duration maxNetworkRequestTime = Duration(seconds: 3);
  static const int maxMemoryUsageMB = 150;
  static const int maxMemoryUnderLoadMB = 200;
  
  // Test Server Configuration
  static const String testApiBaseUrl = 'https://api.test.vedantatrade.com';
  static const String stagingApiBaseUrl = 'https://api.staging.vedantatrade.com';
  static const String testApiKey = 'test-api-key-123456';
  static const String testDatabaseName = 'vedantatrade_test';
  
  // Authentication Test Configuration
  static const String testUserEmail = 'test@vedantatrade.com';
  static const String testUserPassword = 'password123';
  static const String testAdminEmail = 'admin@vedantatrade.com';
  static const String testAdminPassword = 'admin123';
  static const String testInvalidEmail = 'invalid-email';
  static const String testInvalidPassword = 'wrongpassword';
  
  // Feature Flags
  static const bool enableBiometricTests = true;
  static const bool enableSocialLoginTests = true;
  static const bool enableNetworkTests = true;
  static const bool enablePerformanceTests = true;
  static const bool enableAccessibilityTests = true;
  static const bool enableLocalizationTests = true;
  
  // Test Categories
  static const List<String> unitTestCategories = [
    'authentication',
    'product_catalog',
    'distribution',
    'analytics',
    'utilities',
    'services',
  ];
  
  static const List<String> widgetTestCategories = [
    'authentication',
    'product_catalog',
    'distribution',
    'dashboard',
    'forms',
    'navigation',
  ];
  
  static const List<String> integrationTestCategories = [
    'authentication_flow',
    'product_catalog_flow',
    'distribution_flow',
    'analytics_flow',
    'end_to_end',
  ];
  
  static const List<String> performanceTestCategories = [
    'app_performance',
    'ui_performance',
    'network_performance',
    'memory_performance',
    'battery_performance',
  ];
  
  // Test Data Paths
  static const String testFixturesPath = 'test/fixtures';
  static const String testDataPath = 'test/data';
  static const String testImagesPath = 'test/assets/images';
  static const String testFontsPath = 'test/assets/fonts';
  
  // Mock Configuration
  static const bool useMockNetwork = true;
  static const bool useMockDatabase = true;
  static const bool useMockStorage = true;
  static const bool useMockLocation = true;
  static const bool useMockCamera = true;
  
  // Coverage Configuration
  static const double minCodeCoverage = 80.0;
  static const double minLineCoverage = 85.0;
  static const double minBranchCoverage = 75.0;
  static const double minFunctionCoverage = 90.0;
  
  // Reporting Configuration
  static const bool generateHtmlReports = true;
  static const bool generateJsonReports = true;
  static const bool generateCoverageReports = true;
  static const bool generatePerformanceReports = true;
  
  // CI/CD Configuration
  static const bool runOnEveryCommit = true;
  static const bool runOnPullRequest = true;
  static const bool runOnSchedule = true;
  static const bool failOnCoverageThreshold = true;
  static const bool failOnPerformanceThreshold = true;
  
  // Device Configuration
  static const List<TestDevice> testDevices = [
    TestDevice('iPhone 14', 'iOS', '16.0', 'iPhone'),
    TestDevice('Pixel 6', 'Android', '13.0', 'Pixel'),
    TestDevice('iPad Pro', 'iOS', '16.0', 'iPad'),
    TestDevice('Galaxy Tab', 'Android', '13.0', 'Tablet'),
    TestDevice('Web Chrome', 'Web', 'Latest', 'Web'),
  ];
  
  // Screen Sizes for Responsive Testing
  static const List<ScreenSize> screenSizes = [
    ScreenSize(320, 568, 'iPhone SE'),
    ScreenSize(375, 667, 'iPhone 8'),
    ScreenSize(414, 736, 'iPhone 11'),
    ScreenSize(428, 926, 'iPhone 14 Pro Max'),
    ScreenSize(768, 1024, 'iPad'),
    ScreenSize(1024, 1366, 'iPad Pro'),
    ScreenSize(1920, 1080, 'Desktop HD'),
    ScreenSize(2560, 1440, 'Desktop 2K'),
  ];
  
  // Network Conditions
  static const List<NetworkCondition> networkConditions = [
    NetworkCondition('WiFi', 'Fast', Duration(milliseconds: 100)),
    NetworkCondition('4G', 'Medium', Duration(milliseconds: 500)),
    NetworkCondition('3G', 'Slow', Duration(seconds: 2)),
    NetworkCondition('Offline', 'None', Duration(seconds: 10)),
  ];
  
  // Accessibility Configuration
  static const List<String> accessibilityFeatures = [
    'screen_reader',
    'voice_control',
    'switch_control',
    'high_contrast',
    'large_text',
    'reduced_motion',
  ];
  
  // Localization Configuration
  static const List<String> supportedLanguages = [
    'en', // English
    'ne', // Nepali
    'hi', // Hindi
    'zh', // Chinese
    'ar', // Arabic
  ];
  
  static const List<String> rtlLanguages = ['ar'];
  
  // Theme Configuration
  static const List<String> supportedThemes = [
    'light',
    'dark',
    'system',
  ];
  
  // Error Scenarios
  static const List<ErrorScenario> errorScenarios = [
    ErrorScenario('network_timeout', 'Network timeout occurred'),
    ErrorScenario('server_error', 'Internal server error'),
    ErrorScenario('invalid_credentials', 'Invalid credentials'),
    ErrorScenario('permission_denied', 'Permission denied'),
    ErrorScenario('not_found', 'Resource not found'),
    ErrorScenario('rate_limit', 'Rate limit exceeded'),
    ErrorScenario('maintenance', 'Service under maintenance'),
  ];
  
  // Security Test Configuration
  static const List<SecurityTest> securityTests = [
    SecurityTest('sql_injection', 'SQL Injection Protection'),
    SecurityTest('xss_protection', 'XSS Protection'),
    SecurityTest('csrf_protection', 'CSRF Protection'),
    SecurityTest('input_validation', 'Input Validation'),
    SecurityTest('authentication_bypass', 'Authentication Bypass'),
    SecurityTest('data_leakage', 'Data Leakage Prevention'),
  ];
  
  // Load Testing Configuration
  static const int maxConcurrentUsers = 100;
  static const Duration loadTestDuration = Duration(minutes: 5);
  static const int rampUpTimeSeconds = 30;
  static const int coolDownTimeSeconds = 30;
  
  // Stress Testing Configuration
  static const int stressTestUsers = 500;
  static const Duration stressTestDuration = Duration(minutes: 10);
  static const int stressTestRampUp = 60;
  
  // Regression Testing Configuration
  static const List<String> regressionTestSuites = [
    'smoke_tests',
    'critical_path_tests',
    'core_functionality_tests',
    'ui_regression_tests',
    'api_regression_tests',
  ];
  
  // User Journey Tests
  static const List<UserJourney> userJourneys = [
    UserJourney('new_user_registration', 'New User Registration Flow'),
    UserJourney('existing_user_login', 'Existing User Login Flow'),
    UserJourney('product_browsing', 'Product Browsing Flow'),
    UserJourney('order_placement', 'Order Placement Flow'),
    UserJourney('payment_processing', 'Payment Processing Flow'),
    UserJourney('order_tracking', 'Order Tracking Flow'),
  ];
  
  // Cross-Browser Testing
  static const List<String> supportedBrowsers = [
    'Chrome',
    'Firefox',
    'Safari',
    'Edge',
  ];
  
  static const List<String> supportedBrowserVersions = [
    'Latest',
    'Latest-1',
    'Latest-2',
  ];
}

/// Test Device Configuration
class TestDevice {
  final String name;
  final String platform;
  final String version;
  final String type;
  
  const TestDevice(this.name, this.platform, this.version, this.type);
  
  @override
  String toString() => '$name ($platform $version)';
}

/// Screen Size Configuration
class ScreenSize {
  final int width;
  final int height;
  final String name;
  
  const ScreenSize(this.width, this.height, this.name);
  
  Size get size => Size(width.toDouble(), height.toDouble());
  
  @override
  String toString() => '$name (${width}x$height)';
}

/// Network Condition Configuration
class NetworkCondition {
  final String name;
  final String speed;
  final Duration latency;
  
  const NetworkCondition(this.name, this.speed, this.latency);
  
  @override
  String toString() => '$name ($speed, ${latency.inMilliseconds}ms latency)';
}

/// Error Scenario Configuration
class ErrorScenario {
  final String type;
  final String message;
  
  const ErrorScenario(this.type, this.message);
  
  @override
  String toString() => '$type: $message';
}

/// Security Test Configuration
class SecurityTest {
  final String name;
  final String description;
  
  const SecurityTest(this.name, this.description);
  
  @override
  String toString() => '$name: $description';
}

/// User Journey Configuration
class UserJourney {
  final String id;
  final String description;
  
  const UserJourney(this.id, this.description);
  
  @override
  String toString() => '$id: $description';
}

/// Test Environment Helper
class TestEnvironmentHelper {
  static String getApiBaseUrl(String environment) {
    switch (environment) {
      case TestConfig.testEnvironment:
        return TestConfig.testApiBaseUrl;
      case TestConfig.stagingEnvironment:
        return TestConfig.stagingApiBaseUrl;
      case TestConfig.productionEnvironment:
        return 'https://api.vedantatrade.com';
      default:
        return TestConfig.testApiBaseUrl;
    }
  }
  
  static String getDatabaseName(String environment) {
    return '${TestConfig.testDatabaseName}_$environment';
  }
  
  static bool isMockEnabled(String feature) {
    switch (feature) {
      case 'network':
        return TestConfig.useMockNetwork;
      case 'database':
        return TestConfig.useMockDatabase;
      case 'storage':
        return TestConfig.useMockStorage;
      case 'location':
        return TestConfig.useMockLocation;
      case 'camera':
        return TestConfig.useMockCamera;
      default:
        return false;
    }
  }
}

/// Test Data Helper
class TestDataHelper {
  static Map<String, dynamic> getTestUser({String? email, String? password}) {
    return {
      'email': email ?? TestConfig.testUserEmail,
      'password': password ?? TestConfig.testUserPassword,
      'name': 'Test User',
      'role': 'user',
      'isActive': true,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
  
  static Map<String, dynamic> getTestAdminUser({String? email, String? password}) {
    return {
      'email': email ?? TestConfig.testAdminEmail,
      'password': password ?? TestConfig.testAdminPassword,
      'name': 'Test Admin',
      'role': 'admin',
      'isActive': true,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
  
  static Map<String, dynamic> getTestProduct({int? id}) {
    return {
      'id': id ?? 1,
      'name': 'Test Medicine',
      'category': 'Pain Relief',
      'price': 150.0,
      'stock': 100,
      'description': 'Test medicine for testing purposes',
      'manufacturer': 'Test Pharma Ltd',
      'isActive': true,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
  
  static Map<String, dynamic> getTestDistribution({int? id}) {
    return {
      'id': id ?? 1,
      'productId': 1,
      'retailerId': 1,
      'quantity': 50,
      'status': 'pending',
      'createdAt': DateTime.now().toIso8601String(),
      'estimatedDelivery': DateTime.now().add(const Duration(days: 2)).toIso8601String(),
    };
  }
}

/// Test Assertion Helper
class TestAssertionHelper {
  static void assertPerformance(Duration actual, Duration threshold, String operation) {
    expect(actual.inMilliseconds, lessThan(threshold.inMilliseconds),
        reason: '$operation should complete within ${threshold.inMilliseconds}ms, took ${actual.inMilliseconds}ms');
  }
  
  static void assertMemoryUsage(int actualMB, int maxMB, String operation) {
    expect(actualMB, lessThan(maxMB),
        reason: '$operation should use less than ${maxMB}MB, used ${actualMB}MB');
  }
  
  static void assertCodeCoverage(double actual, double minimum, String category) {
    expect(actual, greaterThanOrEqualTo(minimum),
        reason: '$category code coverage should be at least ${minimum}%, was ${actual}%');
  }
  
  static void assertResponseTime(Duration actual, Duration maxTime, String endpoint) {
    expect(actual.inMilliseconds, lessThan(maxTime.inMilliseconds),
        reason: '$endpoint should respond within ${maxTime.inMilliseconds}ms, took ${actual.inMilliseconds}ms');
  }
}

/// Test Reporting Helper
class TestReportingHelper {
  static Map<String, dynamic> generateTestReport({
    required String testName,
    required bool passed,
    required Duration duration,
    String? errorMessage,
    Map<String, dynamic>? metrics,
  }) {
    return {
      'testName': testName,
      'passed': passed,
      'duration': duration.inMilliseconds,
      'timestamp': DateTime.now().toIso8601String(),
      'errorMessage': errorMessage,
      'metrics': metrics ?? {},
    };
  }
  
  static Map<String, dynamic> generatePerformanceReport({
    required String testName,
    required Duration duration,
    required int memoryUsageMB,
    Map<String, dynamic>? additionalMetrics,
  }) {
    return {
      'testName': testName,
      'duration': duration.inMilliseconds,
      'memoryUsage': memoryUsageMB,
      'timestamp': DateTime.now().toIso8601String(),
      'additionalMetrics': additionalMetrics ?? {},
    };
  }
  
  static Map<String, dynamic> generateCoverageReport({
    required double lineCoverage,
    required double branchCoverage,
    required double functionCoverage,
    Map<String, double>? fileCoverage,
  }) {
    return {
      'lineCoverage': lineCoverage,
      'branchCoverage': branchCoverage,
      'functionCoverage': functionCoverage,
      'fileCoverage': fileCoverage ?? {},
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

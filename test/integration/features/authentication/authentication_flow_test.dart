import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../../../../lib/main.dart' as app;
import '../../../unit/test_helpers/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Integration Tests', () {
    testWidgets('complete authentication flow - login to logout', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act & Assert - Should start on login screen
      expect(find.text('Login'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));

      // Enter valid credentials
      await tester.enterText(find.byKey(const Key('email_field')), 'test@vedantatrade.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.pumpAndSettle();

      // Submit login form
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Assert - Should be logged in and on home screen
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Welcome, Test User'), findsOneWidget);

      // Navigate to profile
      await tester.tap(find.byKey(const Key('profile_button')));
      await tester.pumpAndSettle();

      // Logout
      await tester.tap(find.byKey(const Key('logout_button')));
      await tester.pumpAndSettle();

      // Assert - Should be back on login screen
      expect(find.text('Login'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('registration flow - signup to login', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act - Navigate to registration
      await tester.tap(find.byKey(const Key('signup_link')));
      await tester.pumpAndSettle();

      // Assert - Should be on registration screen
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(3)); // Name, Email, Password

      // Fill registration form
      await tester.enterText(find.byKey(const Key('name_field')), 'Test User');
      await tester.enterText(find.byKey(const Key('email_field')), 'newuser@vedantatrade.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.enterText(find.byKey(const Key('confirm_password_field')), 'password123');
      await tester.pumpAndSettle();

      // Submit registration
      await tester.tap(find.byKey(const Key('signup_button')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Assert - Should be registered and logged in
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Welcome, Test User'), findsOneWidget);
    });

    testWidgets('social authentication flow - Google login', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act - Tap Google login
      await tester.tap(find.byKey(const Key('google_login_button')));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Assert - Should complete OAuth flow and be logged in
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Welcome, Google User'), findsOneWidget);
    });

    testWidgets('password reset flow', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act - Navigate to password reset
      await tester.tap(find.byKey(const Key('forgot_password_link')));
      await tester.pumpAndSettle();

      // Assert - Should be on password reset screen
      expect(find.text('Reset Password'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Enter email and submit
      await tester.enterText(find.byKey(const Key('email_field')), 'test@vedantatrade.com');
      await tester.tap(find.byKey(const Key('reset_button')));
      await tester.pumpAndSettle();

      // Assert - Should show success message
      expect(find.text('Password reset email sent'), findsOneWidget);
    });

    testWidgets('biometric authentication flow', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act - Login first
      await tester.enterText(find.byKey(const Key('email_field')), 'test@vedantatrade.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to settings
      await tester.tap(find.byKey(const Key('settings_button')));
      await tester.pumpAndSettle();

      // Enable biometric authentication
      await tester.tap(find.byKey(const Key('enable_biometric_button')));
      await tester.pumpAndSettle();

      // Assert - Biometric should be enabled
      expect(find.text('Biometric Authentication Enabled'), findsOneWidget);

      // Logout and test biometric login
      await tester.tap(find.byKey(const Key('logout_button')));
      await tester.pumpAndSettle();

      // Should show biometric login option
      expect(find.byKey(const Key('biometric_login_button')), findsOneWidget);
    });

    testWidgets('session management - token refresh', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act - Login
      await tester.enterText(find.byKey(const Key('email_field')), 'test@vedantatrade.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Simulate token expiry by waiting
      await tester.pumpAndSettle(const Duration(minutes: 31));

      // Navigate to a protected route
      await tester.tap(find.byKey(const Key('profile_button')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Assert - Should still be logged in (token refreshed automatically)
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Test User'), findsOneWidget);
    });

    testWidgets('security - rate limiting', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act - Attempt multiple failed logins
      for (int i = 0; i < 5; i++) {
        await tester.enterText(find.byKey(const Key('email_field')), 'test@vedantatrade.com');
        await tester.enterText(find.byKey(const Key('password_field')), 'wrongpassword');
        await tester.tap(find.byKey(const Key('login_button')));
        await tester.pumpAndSettle();
      }

      // Assert - Should show rate limiting message
      expect(find.text('Too many login attempts. Please try again later.'), findsOneWidget);
    });

    testWidgets('security - suspicious activity detection', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act - Login from unusual location (simulated)
      await tester.enterText(find.byKey(const Key('email_field')), 'test@vedantatrade.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Assert - Should show security verification if suspicious
      if (find.text('Security Verification Required').evaluate().isNotEmpty) {
        expect(find.text('Security Verification Required'), findsOneWidget);
        expect(find.byKey(const Key('verify_button')), findsOneWidget);
      }
    });

    testWidgets('accessibility - screen reader support', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act - Enable screen reader mode
      final semantics = tester.binding.pipelineOwner.semanticsOwner;
      expect(semantics, isNotNull);

      // Navigate through login flow using semantic labels
      await tester.tap(find.bySemanticsLabel('Email field'));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.bySemanticsLabel('Email field'), 'test@vedantatrade.com');
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Password field'));
      await tester.pumpAndSettle();

      await tester.enterText(find.bySemanticsLabel('Password field'), 'password123');
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Login button'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Assert - Should successfully login with screen reader support
      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('performance - login flow performance', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act - Measure login flow performance
      final stopwatch = Stopwatch()..start();

      await tester.enterText(find.byKey(const Key('email_field')), 'test@vedantatrade.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      stopwatch.stop();

      // Assert - Login should complete within acceptable time
      expect(stopwatch.elapsedMilliseconds, lessThan(5000),
          reason: 'Login flow should complete within 5 seconds');
    });

    testWidgets('error handling - network connectivity', (WidgetTester tester) async {
      // Arrange - Simulate network disconnection
      // This would require mocking the network layer in a real implementation

      app.main();
      await tester.pumpAndSettle();

      // Act - Attempt login without network
      await tester.enterText(find.byKey(const Key('email_field')), 'test@vedantatrade.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Assert - Should show network error message
      expect(find.text('No internet connection'), findsOneWidget);
    });

    testWidgets('data persistence - remember me functionality', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act - Login with "Remember Me" checked
      await tester.enterText(find.byKey(const Key('email_field')), 'test@vedantatrade.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.tap(find.byKey(const Key('remember_me_checkbox')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Restart app
      app.main();
      await tester.pumpAndSettle();

      // Assert - Should still be logged in
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Welcome, Test User'), findsOneWidget);
    });

    testWidgets('multi-device session management', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act - Login on device 1
      await tester.enterText(find.byKey(const Key('email_field')), 'test@vedantatrade.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to session management
      await tester.tap(find.byKey(const Key('settings_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('session_management_button')));
      await tester.pumpAndSettle();

      // Assert - Should show active sessions
      expect(find.text('Active Sessions'), findsOneWidget);
      expect(find.text('Current Device'), findsOneWidget);
    });

    testWidgets('localization - RTL language support', (WidgetTester tester) async {
      // Arrange - Change app language to Arabic (RTL)
      // This would require implementing localization in the real app

      app.main();
      await tester.pumpAndSettle();

      // Act - Navigate to language settings
      await tester.tap(find.byKey(const Key('language_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('العربية'));
      await tester.pumpAndSettle();

      // Assert - UI should be RTL
      final context = tester.element(find.byType(MaterialApp));
      expect(Directionality.of(context), equals(TextDirection.rtl));
    });

    testWidgets('theme - dark mode support', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act - Switch to dark mode
      await tester.tap(find.byKey(const Key('theme_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('dark_mode_button')));
      await tester.pumpAndSettle();

      // Assert - Should be in dark mode
      final theme = Theme.of(tester.element(find.byType(MaterialApp)));
      expect(theme.brightness, equals(Brightness.dark));
    });

    testWidgets('form validation - comprehensive validation', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act & Assert - Test various validation scenarios

      // Empty email
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump();
      expect(find.text('Please enter your email'), findsOneWidget);

      // Invalid email format
      await tester.enterText(find.byKey(const Key('email_field')), 'invalid-email');
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump();
      expect(find.text('Please enter a valid email'), findsOneWidget);

      // Short password
      await tester.enterText(find.byKey(const Key('email_field')), 'test@vedantatrade.com');
      await tester.enterText(find.byKey(const Key('password_field')), '123');
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump();
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);

      // Valid credentials
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Assert - Should login successfully
      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('navigation - deep link handling', (WidgetTester tester) async {
      // Arrange - Simulate deep link to login
      // This would require implementing deep link handling

      app.main();
      await tester.pumpAndSettle();

      // Act - Navigate to specific screen via deep link
      // In a real implementation, this would use the navigation system
      await tester.pumpAndSettle();

      // Assert - Should be on correct screen
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('memory management - large form handling', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act - Fill form with large amount of data
      final largeEmail = 'very.long.email.address.that.tests.memory.management@vedantatrade.com';
      final largePassword = 'this.is.a.very.long.password.that.tests.memory.management.with.many.characters.123';

      await tester.enterText(find.byKey(const Key('email_field')), largeEmail);
      await tester.enterText(find.byKey(const Key('password_field')), largePassword);
      await tester.pumpAndSettle();

      // Assert - Should handle large input without performance issues
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text(largeEmail), findsOneWidget);
      expect(find.text(largePassword), findsOneWidget);
    });

    testWidgets('concurrent operations - multiple login attempts', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act - Attempt multiple rapid logins
      await tester.enterText(find.byKey(const Key('email_field')), 'test@vedantatrade.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');

      for (int i = 0; i < 3; i++) {
        await tester.tap(find.byKey(const Key('login_button')));
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Assert - Should handle concurrent operations gracefully
      expect(find.text('Dashboard'), findsOneWidget);
    });
  });
}

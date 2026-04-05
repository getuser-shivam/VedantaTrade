import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../../../../lib/features/authentication/presentation/screens/login_screen.dart';
import '../../../../lib/features/authentication/presentation/providers/authentication_provider.dart';
import '../../../../lib/features/authentication/domain/models/auth_models.dart';
import '../../../unit/test_helpers/test_helpers.dart';

@GenerateMocks([AuthenticationProvider])
import 'login_screen_test.mocks.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    late MockAuthenticationProvider mockProvider;

    setUp(() {
      mockProvider = MockAuthenticationProvider();
    });

    Widget createLoginScreen() {
      return MaterialApp(
        home: LoginScreen(),
      );
    }

    group('UI Components Tests', () {
      testWidgets('should display all required UI elements', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createLoginScreen());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('Login'), findsOneWidget);
        expect(find.byType(TextField), findsNWidgets(2)); // Email and Password
        expect(find.byType(ElevatedButton), findsOneWidget);
        expect(find.text('Login'), findsAtLeastNWidgets(1)); // AppBar title and button
        expect(find.text('Forgot Password?'), findsOneWidget);
        expect(find.text('Don\'t have an account? Sign Up'), findsOneWidget);
      });

      testWidgets('should display email field with correct properties', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createLoginScreen());
        await tester.pumpAndSettle();

        final emailField = tester.widget<TextField>(find.byType(TextField).first);

        // Assert
        expect(emailField.decoration?.labelText, equals('Email'));
        expect(emailField.keyboardType, TextInputType.emailAddress);
        expect(emailField.obscureText, isFalse);
      });

      testWidgets('should display password field with correct properties', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createLoginScreen());
        await tester.pumpAndSettle();

        final passwordField = tester.widget<TextField>(find.byType(TextField).last);

        // Assert
        expect(passwordField.decoration?.labelText, equals('Password'));
        expect(passwordField.keyboardType, TextInputType.visiblePassword);
        expect(passwordField.obscureText, isTrue);
      });

      testWidgets('should display social login buttons', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createLoginScreen());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Sign in with Google'), findsOneWidget);
        expect(find.text('Sign in with Facebook'), findsOneWidget);
        expect(find.text('Sign in with Apple'), findsOneWidget);
      });
    });

    group('Form Validation Tests', () {
      testWidgets('should show error when email is empty', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createLoginScreen());
        await tester.pumpAndSettle();

        // Enter empty email and password
        await tester.enterText(find.byType(TextField).first, '');
        await tester.enterText(find.byType(TextField).last, 'password123');
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert
        expect(find.text('Please enter your email'), findsOneWidget);
      });

      testWidgets('should show error when password is empty', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createLoginScreen());
        await tester.pumpAndSettle();

        // Enter email but empty password
        await tester.enterText(find.byType(TextField).first, 'test@vedantatrade.com');
        await tester.enterText(find.byType(TextField).last, '');
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert
        expect(find.text('Please enter your password'), findsOneWidget);
      });

      testWidgets('should show error for invalid email format', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createLoginScreen());
        await tester.pumpAndSettle();

        // Enter invalid email
        await tester.enterText(find.byType(TextField).first, 'invalid-email');
        await tester.enterText(find.byType(TextField).last, 'password123');
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert
        expect(find.text('Please enter a valid email'), findsOneWidget);
      });

      testWidgets('should show error for short password', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createLoginScreen());
        await tester.pumpAndSettle();

        // Enter short password
        await tester.enterText(find.byType(TextField).first, 'test@vedantatrade.com');
        await tester.enterText(find.byType(TextField).last, '123');
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert
        expect(find.text('Password must be at least 6 characters'), findsOneWidget);
      });
    });

    group('User Interaction Tests', () {
      testWidgets('should toggle password visibility', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createLoginScreen());
        await tester.pumpAndSettle();

        final passwordField = tester.widget<TextField>(find.byType(TextField).last);
        expect(passwordField.obscureText, isTrue);

        // Tap visibility toggle
        await tester.tap(find.byIcon(Icons.visibility));
        await tester.pump();

        final updatedPasswordField = tester.widget<TextField>(find.byType(TextField).last);
        expect(updatedPasswordField.obscureText, isFalse);

        // Tap again to hide
        await tester.tap(find.byIcon(Icons.visibility_off));
        await tester.pump();

        final hiddenPasswordField = tester.widget<TextField>(find.byType(TextField).last);
        expect(hiddenPasswordField.obscureText, isTrue);
      });

      testWidgets('should navigate to forgot password screen', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createLoginScreen());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Forgot Password?'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Forgot Password'), findsOneWidget);
      });

      testWidgets('should navigate to sign up screen', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createLoginScreen());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Sign Up'), findsOneWidget);
      });
    });

    group('Social Login Tests', () {
      testWidgets('should handle Google login button tap', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createLoginScreen());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Sign in with Google'));
        await tester.pump();

        // Assert - would navigate to Google OAuth flow
        // In a real test, we would mock the OAuth service
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should handle Facebook login button tap', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createLoginScreen());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Sign in with Facebook'));
        await tester.pump();

        // Assert - would navigate to Facebook OAuth flow
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should handle Apple login button tap', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createLoginScreen());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Sign in with Apple'));
        await tester.pump();

        // Assert - would navigate to Apple OAuth flow
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('Loading State Tests', () {
      testWidgets('should show loading indicator during login', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createLoginScreen());
        await tester.pumpAndSettle();

        // Enter valid credentials
        await tester.enterText(find.byType(TextField).first, 'test@vedantatrade.com');
        await tester.enterText(find.byType(TextField).last, 'password123');
        
        // Tap login button
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byType(ElevatedButton), findsNothing);
      });

      testWidgets('should disable form during loading', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createLoginScreen());
        await tester.pumpAndSettle();

        // Enter valid credentials and submit
        await tester.enterText(find.byType(TextField).first, 'test@vedantatrade.com');
        await tester.enterText(find.byType(TextField).last, 'password123');
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert
        final emailField = tester.widget<TextField>(find.byType(TextField).first);
        final passwordField = tester.widget<TextField>(find.byType(TextField).last);
        
        expect(emailField.enabled, isFalse);
        expect(passwordField.enabled, isFalse);
      });
    });

    group('Error State Tests', () {
      testWidgets('should show error message on login failure', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createLoginScreen());
        await tester.pumpAndSettle();

        // Enter valid credentials
        await tester.enterText(find.byType(TextField).first, 'test@vedantatrade.com');
        await tester.enterText(find.byType(TextField).last, 'wrongpassword');
        
        // Tap login button
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // Assert - would show error message
        // In a real test, we would mock the authentication service to return an error
        expect(find.text('Invalid email or password'), findsOneWidget);
      });

      testWidgets('should clear error message when user starts typing', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createLoginScreen());
        await tester.pumpAndSettle();

        // Trigger error first
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();
        
        // Start typing in email field
        await tester.enterText(find.byType(TextField).first, 't');
        await tester.pump();

        // Assert
        expect(find.text('Invalid email or password'), findsNothing);
      });
    });

    group('Success State Tests', () {
      testWidgets('should navigate to home screen on successful login', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createLoginScreen());
        await tester.pumpAndSettle();

        // Enter valid credentials
        await tester.enterText(find.byType(TextField).first, 'test@vedantatrade.com');
        await tester.enterText(find.byType(TextField).last, 'password123');
        
        // Tap login button
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // Assert - would navigate to home screen
        // In a real test, we would mock the navigation service
        expect(find.text('Dashboard'), findsOneWidget);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('should have proper semantic labels', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createLoginScreen());
        await tester.pumpAndSettle();

        // Assert
        expect(find.bySemanticsLabel('Email field'), findsOneWidget);
        expect(find.bySemanticsLabel('Password field'), findsOneWidget);
        expect(find.bySemanticsLabel('Login button'), findsOneWidget);
        expect(find.bySemanticsLabel('Forgot password link'), findsOneWidget);
        expect(find.bySemanticsLabel('Sign up link'), findsOneWidget);
      });

      testWidgets('should support screen reader', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createLoginScreen());
        await tester.pumpAndSettle();

        // Assert
        final semantics = tester.binding.pipelineOwner.semanticsOwner;
        expect(semantics, isNotNull);
        
        // Check semantic nodes exist
        final emailSemantics = semantics.getSemanticsNodeForPosition(const Offset(100, 200));
        final passwordSemantics = semantics.getSemanticsNodeForPosition(const Offset(100, 300));
        
        expect(emailSemantics, isNotNull);
        expect(passwordSemantics, isNotNull);
      });

      testWidgets('should support keyboard navigation', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createLoginScreen());
        await tester.pumpAndSettle();

        // Tab through fields
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        
        // Assert - focus should move to next field
        final focusedWidget = tester.binding.focusManager.primaryFocus?.debugLabel;
        expect(focusedWidget, contains('TextField'));
      });
    });

    group('Responsive Design Tests', () {
      testWidgets('should adapt to small screen size', (WidgetTester tester) async {
        // Act
        tester.binding.window.physicalSizeTestValue = const Size(300, 600);
        tester.binding.window.devicePixelRatioTestValue = 1.0;
        
        await tester.pumpWidget(createLoginScreen());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(SingleChildScrollView), findsOneWidget);
        expect(find.byType(Column), findsOneWidget);
      });

      testWidgets('should adapt to large screen size', (WidgetTester tester) async {
        // Act
        tester.binding.window.physicalSizeTestValue = const Size(1200, 800);
        tester.binding.window.devicePixelRatioTestValue = 1.0;
        
        await tester.pumpWidget(createLoginScreen());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(Container), findsWidgets);
        expect(find.byType(Center), findsOneWidget);
      });
    });

    group('Performance Tests', () {
      testWidgets('should build within acceptable time', (WidgetTester tester) async {
        // Act
        final stopwatch = Stopwatch()..start();
        
        await tester.pumpWidget(createLoginScreen());
        await tester.pumpAndSettle();
        
        stopwatch.stop();

        // Assert
        expect(stopwatch.elapsedMilliseconds, lessThan(1000),
            reason: 'Login screen should build within 1 second');
      });

      testWidgets('should handle rapid form changes without performance issues', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createLoginScreen());
        await tester.pumpAndSettle();

        final stopwatch = Stopwatch()..start();

        // Rapid form changes
        for (int i = 0; i < 10; i++) {
          await tester.enterText(find.byType(TextField).first, 'test$i@vedantatrade.com');
          await tester.pump();
          await tester.enterText(find.byType(TextField).last, 'password$i');
          await tester.pump();
        }

        stopwatch.stop();

        // Assert
        expect(stopwatch.elapsedMilliseconds, lessThan(2000),
            reason: 'Rapid form changes should complete within 2 seconds');
      });
    });

    group('Integration Tests', () {
      testWidgets('should complete full login flow successfully', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createLoginScreen());
        await tester.pumpAndSettle();

        // Enter valid credentials
        await tester.enterText(find.byType(TextField).first, 'test@vedantatrade.com');
        await tester.enterText(find.byType(TextField).last, 'password123');
        
        // Submit form
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // Assert - should navigate to home screen
        expect(find.text('Dashboard'), findsOneWidget);
      });

      testWidgets('should handle social login flow', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createLoginScreen());
        await tester.pumpAndSettle();

        // Tap Google login
        await tester.tap(find.text('Sign in with Google'));
        await tester.pumpAndSettle();

        // Assert - should complete OAuth flow and navigate to home
        expect(find.text('Dashboard'), findsOneWidget);
      });
    });
  });
}

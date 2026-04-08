# VedantaTrade Development Guidelines

## Overview

This document provides comprehensive development guidelines for the VedantaTrade pharmaceutical distribution platform, ensuring consistency, quality, and maintainability across the entire codebase.

**Important References:**
- [Project Structure Standard](./PROJECT_STRUCTURE_STANDARD.md) - Standardized directory structure
- [Naming Conventions](./NAMING_CONVENTIONS.md) - Detailed naming conventions
- [Project Structure Analysis](./PROJECT_STRUCTURE_ANALYSIS.md) - Current structure analysis

## Project Structure Standards

### Feature Structure Requirements

All new features must follow the standardized Clean Architecture structure:

```
features/feature_name/
├── feature_name.dart              # Entry point (exports public API)
├── feature_name_feature.dart      # Feature registration
├── data/                          # Data layer
│   ├── models/                    # Data models
│   ├── repositories/              # Repository implementations
│   ├── datasources/               # API/local storage
│   └── services/                  # Data services
├── domain/                        # Domain layer
│   ├── entities/                  # Domain entities
│   ├── repositories/              # Repository interfaces
│   ├── usecases/                  # Business logic
│   └── services/                  # Domain services
└── presentation/                  # Presentation layer
    ├── screens/                   # Full-screen widgets
    ├── widgets/                   # Reusable widgets
    └── providers/                 # State management
```

### Structure Compliance Rules

1. **No files at feature root level** (except entry point files)
2. **All layers must exist** (data, domain, presentation)
3. **Clean Architecture separation** - layers must not violate dependency rules
4. **Consistent naming** - follow naming conventions (see NAMING_CONVENTIONS.md)
5. **Entry point files** - every feature must have `{feature_name}.dart` and `{feature_name}_feature.dart`

### Migration Priority

Features requiring restructuring (from PROJECT_STRUCTURE_ANALYSIS.md):

**Critical (Immediate):**
- field_force
- admin
- retailer

**Medium Priority:**
- stockist
- notifications
- reviews
- accounting
- orders

**Low Priority:**
- profile
- splash
- ux

## Code Standards

### Dart/Flutter Standards

#### 1. Naming Conventions

**For detailed naming conventions, see [NAMING_CONVENTIONS.md](./NAMING_CONVENTIONS.md)**

```dart
// Classes - PascalCase
class AuthenticationRepository {}
class UserProfileWidget {}

// Variables and Functions - camelCase
final String userName = 'john_doe';
void authenticateUser() {}

// Constants - camelCase (feature-specific) or UPPER_CASE (global)
const String apiBaseUrl = 'https://api.vedantatrade.com';
const int maxRetryAttempts = 3;
const String API_BASE_URL = 'https://api.vedantatrade.com'; // Global constant

// Private members - prefix with underscore
String _privateMethod() {}
final int _privateVariable = 0;

// Files - camelCase (new standard)
// authenticationRepository.dart
// userService.dart
// productListScreen.dart

// Directories - snake_case
// authentication/
// user_profile/
// product_list/
```

#### 2. File Organization

**For detailed project structure, see [PROJECT_STRUCTURE_STANDARD.md](./PROJECT_STRUCTURE_STANDARD.md)**

```dart
// Import order:
// 1. Dart imports
// 2. Flutter imports
// 3. Package imports
// 4. Core imports
// 5. Feature imports (current feature first, then other features)
// 6. Relative imports

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
```

#### 3. Class Structure

```dart
class AuthenticationRepository {
  // 1. Static constants
  static const String _baseUrl = 'https://api.example.com';
  
  // 2. Private fields
  final HttpClient _client;
  final StorageService _storage;
  
  // 3. Constructor
  AuthenticationRepository({
    required HttpClient client,
    required StorageService storage,
  }) : _client = client, _storage = storage;
  
  // 4. Public methods
  Future<User> login(String email, String password) async {
    // Implementation
  }
  
  // 5. Private methods
  String _hashPassword(String password) {
    // Implementation
  }
  
  // 6. Getters
  bool get isAuthenticated => _storage.hasToken();
}
```

#### 4. Error Handling

```dart
// Use custom exceptions
class AuthenticationException implements Exception {
  final String message;
  final String? code;
  
  const AuthenticationException(this.message, {this.code});
  
  @override
  String toString() => 'AuthenticationException: $message';
}

// Handle errors gracefully
Future<User> login(String email, String password) async {
  try {
    final response = await _client.post('/login', data: {
      'email': email,
      'password': password,
    });
    
    if (response.statusCode == 200) {
      return User.fromJson(response.data);
    } else {
      throw AuthenticationException(
        'Login failed',
        code: response.statusCode.toString(),
      );
    }
  } on SocketException {
    throw NetworkException('No internet connection');
  } catch (e) {
    throw AuthenticationException('Unexpected error: $e');
  }
}
```

### State Management Guidelines

#### 1. Provider Pattern

```dart
// Provider setup
class AuthenticationProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  
  Future<void> login(String email, String password) async {
    _setLoading(true);
    _error = null;
    
    try {
      final user = await _authRepository.login(email, password);
      _user = user;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
```

#### 2. State Management Best Practices

- Use `ChangeNotifier` for simple state management
- Use `FutureBuilder` for async operations
- Use `StreamBuilder` for real-time data
- Avoid deep nesting of providers
- Use `Selector` for optimized rebuilds

### UI/UX Guidelines

#### 1. Widget Structure

```dart
class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildLoginForm(),
              const SizedBox(height: 16),
              _buildLoginButton(),
              const SizedBox(height: 16),
              _buildForgotPasswordLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Text(
      'Welcome Back',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildLoginForm() {
    return Form(
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
```

#### 2. Responsive Design

```dart
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  const ResponsiveLayout({
    Key? key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 768) {
          return mobile;
        } else if (constraints.maxWidth < 1024) {
          return tablet;
        } else {
          return desktop;
        }
      },
    );
  }
}
```

#### 3. Accessibility Guidelines

```dart
// Use semantic widgets
Semantics(
  button: true,
  label: 'Login button',
  hint: 'Tap to login to your account',
  child: ElevatedButton(
    onPressed: _handleLogin,
    child: const Text('Login'),
  ),
),

// Add accessibility properties
TextField(
  decoration: const InputDecoration(
    labelText: 'Email',
    hintText: 'Enter your email address',
  ),
  keyboardType: TextInputType.emailAddress,
  textInputAction: TextInputAction.next,
  autofocus: true,
),

// Use semantic labels for images
Image.asset(
  'assets/images/logo.png',
  semanticLabel: 'VedantaTrade Logo',
),
```

### Testing Guidelines

#### 1. Unit Tests

```dart
// test/unit/auth/authentication_repository_test.dart
void main() {
  group('AuthenticationRepository', () {
    late AuthenticationRepository repository;
    late MockHttpClient mockClient;
    late MockStorageService mockStorage;

    setUp(() {
      mockClient = MockHttpClient();
      mockStorage = MockStorageService();
      repository = AuthenticationRepository(
        client: mockClient,
        storage: mockStorage,
      );
    });

    test('should return user when login is successful', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';
      final response = {
        'id': '1',
        'email': email,
        'name': 'Test User',
      };
      
      when(mockClient.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(response, 200));

      // Act
      final result = await repository.login(email, password);

      // Assert
      expect(result.email, equals(email));
      verify(mockClient.post('/login', data: any(named: 'data'))).called(1);
    });

    test('should throw AuthenticationException when login fails', () async {
      // Arrange
      when(mockClient.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response({'error': 'Invalid credentials'}, 401));

      // Act & Assert
      expect(
        () => repository.login('test@example.com', 'wrongpassword'),
        throwsA(isA<AuthenticationException>()),
      );
    });
  });
}
```

#### 2. Widget Tests

```dart
// test/widget/auth/login_screen_test.dart
void main() {
  group('LoginScreen', () {
    testWidgets('should display login form', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(),
        ),
      );

      // Assert
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should validate email field', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(),
        ),
      );

      // Act
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(find.text('Please enter your email'), findsOneWidget);
    });
  });
}
```

#### 3. Integration Tests

```dart
// test/integration/auth_flow_test.dart
void main() {
  group('Authentication Flow', () {
    testWidgets('should complete login flow successfully', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AuthenticationProvider(),
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Act
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(DashboardScreen), findsOneWidget);
    });
  });
}
```

### Performance Guidelines

#### 1. Memory Management

```dart
// Dispose resources properly
class ProductListProvider extends ChangeNotifier {
  StreamSubscription<List<Product>>? _subscription;

  void startListening() {
    _subscription = _productService.getProducts().listen((products) {
      _products = products;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

// Use const constructors where possible
const EdgeInsets all16 = EdgeInsets.all(16.0);
const TextStyle headlineStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
);

// Use ListView.builder for large lists
ListView.builder(
  itemCount: products.length,
  itemBuilder: (context, index) {
    return ProductCard(product: products[index]);
  },
)
```

#### 2. Image Optimization

```dart
// Use cached network images
CachedNetworkImage(
  imageUrl: product.imageUrl,
  placeholder: (context, url) => const CircularProgressIndicator(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
  fit: BoxFit.cover,
  width: 100,
  height: 100,
)

// Optimize image sizes
Image.asset(
  'assets/images/product_image.png',
  width: 100,
  height: 100,
  fit: BoxFit.cover,
)
```

### Security Guidelines

#### 1. Data Protection

```dart
// Use secure storage
class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  Future<void> storeToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }
}

// Hash sensitive data
String hashPassword(String password) {
  final bytes = utf8.encode(password);
  final digest = sha256.convert(bytes);
  return digest.toString();
}
```

#### 2. API Security

```dart
// Add authentication headers
class AuthenticatedHttpClient extends HttpClient {
  final String _token;

  AuthenticatedHttpClient(this._token);

  @override
  Future<Response> post(String path, {Map<String, dynamic>? data}) async {
    final headers = {
      'Authorization': 'Bearer $_token',
      'Content-Type': 'application/json',
    };
    return super.post(path, data: data, headers: headers);
  }
}

// Validate input data
class InputValidator {
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[0-9]'));
  }
}
```

### Code Review Guidelines

#### 1. Review Checklist

**Project Structure:**
- [ ] Feature follows standardized directory structure (see PROJECT_STRUCTURE_STANDARD.md)
- [ ] Files are in correct layer (data/domain/presentation)
- [ ] No files at feature root level (except entry point files)
- [ ] Entry point file exists: `{feature_name}.dart`
- [ ] Feature registration file exists: `{feature_name}_feature.dart`

**Naming Conventions:**
- [ ] Code follows naming conventions (see NAMING_CONVENTIONS.md)
- [ ] Directories use snake_case
- [ ] Files use camelCase
- [ ] Classes use PascalCase
- [ ] Variables use camelCase
- [ ] Boolean variables use is/has/should/can prefix

**Code Quality:**
- [ ] Functions and classes are properly documented
- [ ] Error handling is implemented
- [ ] Tests are written for new functionality
- [ ] Performance implications are considered
- [ ] Security best practices are followed
- [ ] Accessibility guidelines are met
- [ ] Code is properly formatted

#### 2. Review Process

1. **Self-Review**: Review your own code before submitting
2. **Peer Review**: Request review from at least one team member
3. **Automated Checks**: Ensure all automated checks pass
4. **Documentation**: Update relevant documentation
5. **Testing**: Verify all tests pass

### Git Workflow

#### 1. Branch Naming

```bash
# Feature branches
feature/authentication-system
feature/product-catalog

# Bugfix branches
bugfix/login-validation
bugfix/memory-leak

# Hotfix branches
hotfix/critical-security-update
hotfix/api-downtime
```

#### 2. Commit Messages

```bash
# Format: type(scope): description
feat(auth): add multi-factor authentication
fix(products): resolve image loading issue
docs(readme): update installation guide
test(auth): add unit tests for login service
refactor(ui): extract reusable button component
```

#### 3. Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Widget tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows project guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Tests added/updated
```

## Development Environment Setup

### 1. Prerequisites

- Flutter SDK (>= 3.0.0)
- Dart SDK (>= 3.0.0)
- VS Code or Android Studio
- Git

### 2. Setup Steps

```bash
# Clone repository
git clone https://github.com/getuser-shivam/VedantaTrade.git
cd VedantaTrade

# Install dependencies
flutter pub get

# Run setup script
dart scripts/setup.dart

# Run tests
flutter test

# Run app
flutter run
```

### 3. Development Tools

- **Flutter Inspector**: For widget inspection
- **Flutter Performance**: For performance profiling
- **Flutter DevTools**: For debugging and profiling
- **Dart Code Metrics**: For code quality analysis

## Deployment Guidelines

### 1. Build Process

```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

### 2. Environment Configuration

```dart
// lib/config/environment.dart
class Environment {
  static const String _environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  static bool get isDevelopment => _environment == 'development';
  static bool get isStaging => _environment == 'staging';
  static bool get isProduction => _environment == 'production';

  static String get apiBaseUrl {
    switch (_environment) {
      case 'development':
        return 'https://dev-api.vedantatrade.com';
      case 'staging':
        return 'https://staging-api.vedantatrade.com';
      case 'production':
        return 'https://api.vedantatrade.com';
      default:
        return 'https://dev-api.vedantatrade.com';
    }
  }
}
```

These guidelines ensure consistent, high-quality code across the VedantaTrade project while promoting maintainability and scalability.

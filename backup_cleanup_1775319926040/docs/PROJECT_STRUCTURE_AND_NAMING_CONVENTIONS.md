# VedantaTrade - Project Structure & Naming Conventions

## 📁 **Project Directory Structure**

This document outlines the standardized directory structure and naming conventions for the VedantaTrade project to ensure maintainability, scalability, and team collaboration.

---

## 🏗️ **Root Directory Structure**

```
vedanta_trade/
├── lib/                          # Main source code
│   ├── app/                      # App-level configuration
│   │   ├── app.dart              # Main app widget and router setup
│   │   ├── router/               # Navigation configuration
│   │   │   └── app_router.dart
│   │   └── theme/                # App-wide theming
│   │       ├── app_theme.dart
│   │       └── colors.dart
│   ├── core/                     # Core utilities and configurations
│   │   ├── api_config.dart        # API endpoints and configuration
│   │   ├── constants/            # App constants
│   │   │   ├── app_constants.dart
│   │   │   └── route_constants.dart
│   │   ├── services/             # Core services
│   │   │   ├── storage_service.dart
│   │   │   └── network_service.dart
│   │   └── utils/                # Utility functions
│   │       ├── date_utils.dart
│   │       ├── validation_utils.dart
│   │       └── format_utils.dart
│   ├── data/                     # Global data models and repositories
│   │   ├── models/               # Global data models
│   │   │   ├── user_model.dart
│   │   │   └── response_model.dart
│   │   └── repositories/         # Global repositories
│   │       └── user_repository.dart
│   ├── features/                 # Feature-based modules
│   │   ├── auth/                # Authentication feature
│   │   ├── catalog/             # Product catalog feature
│   │   ├── distribution/         # Distribution management
│   │   ├── mr/                  # Medical Representative
│   │   ├── stockist/            # Stockist management
│   │   ├── retailer/             # Retailer management
│   │   ├── doctor/               # Doctor management
│   │   ├── accountant/           # Accountant management
│   │   └── admin/                # Admin management
│   ├── shared/                   # Shared widgets and utilities
│   │   ├── app_scaffold.dart     # Common app scaffold
│   │   ├── theme/                # Shared theming
│   │   │   ├── premium_glassmorphic_theme.dart
│   │   │   └── theme_extensions.dart
│   │   ├── ui/                   # Reusable UI components
│   │   │   ├── buttons/
│   │   │   ├── forms/
│   │   │   ├── cards/
│   │   │   └── dialogs/
│   │   └── widgets/             # Shared widgets
│   │       ├── glassmorphic_widgets.dart
│   │       └── common_widgets.dart
│   └── main.dart                 # App entry point
├── test/                         # Test files
│   ├── unit/                     # Unit tests
│   ├── widget/                   # Widget tests
│   ├── integration/              # Integration tests
│   └── e2e/                      # End-to-end tests
├── test_driver/                   # E2E test drivers
├── assets/                       # Asset files
│   ├── images/                   # Images
│   ├── icons/                    # Icons
│   └── fonts/                    # Custom fonts
├── docs/                         # Documentation
│   ├── PROJECT_STRUCTURE.md      # This file
│   ├── API_DOCUMENTATION.md      # API documentation
│   └── DEVELOPMENT_GUIDE.md      # Development guide
├── tools/                        # Development tools and scripts
│   ├── build_runner/             # Code generation
│   └── scripts/                 # Utility scripts
├── .github/                      # GitHub configuration
│   └── workflows/               # CI/CD workflows
├── pubspec.yaml                  # Dependencies and metadata
├── README.md                     # Project documentation
├── CHANGELOG.md                  # Version history
├── TODO.md                       # Task tracking
└── .gitignore                   # Git ignore rules
```

---

## 🏛️ **Feature Module Structure**

Each feature follows **Clean Architecture** with consistent structure:

```
features/
├── feature_name/                 # Feature module (e.g., auth, catalog)
│   ├── domain/                   # Business logic layer
│   │   ├── entities/            # Domain entities
│   │   │   └── user_entity.dart
│   │   ├── repositories/        # Repository interfaces
│   │   │   └── auth_repository.dart
│   │   └── usecases/           # Business use cases
│   │       ├── login_usecase.dart
│   │       └── register_usecase.dart
│   ├── data/                     # Data layer
│   │   ├── models/              # Data models
│   │   │   ├── user_model.dart
│   │   │   └── response_model.dart
│   │   ├── repositories/        # Repository implementations
│   │   │   └── auth_repository_impl.dart
│   │   ├── services/            # API services
│   │   │   ├── auth_service.dart
│   │   │   └── user_service.dart
│   │   └── datasources/         # Data sources
│   │       ├── local/            # Local data sources
│   │       │   └── auth_local_datasource.dart
│   │       └── remote/           # Remote data sources
│   │           └── auth_remote_datasource.dart
│   ├── presentation/             # UI layer
│   │   ├── providers/           # State management
│   │   │   ├── auth_provider.dart
│   │   │   └── user_provider.dart
│   │   ├── screens/             # Screen widgets
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   └── auth_screen.dart
│   │   ├── widgets/             # Feature-specific widgets
│   │   │   ├── login_form.dart
│   │   │   ├── register_form.dart
│   │   │   └── password_reset_form.dart
│   │   └── pages/               # Page widgets (if needed)
│   │       └── auth_page.dart
│   └── feature_name.dart         # Barrel exports
```

---

## 📝 **Naming Conventions**

### **📁 Directory Names**
- **Lowercase snake_case**: `auth`, `product_catalog`, `user_management`
- **Plural for collections**: `widgets`, `screens`, `providers`
- **Singular for single items**: `theme`, `router`, `service`

### **📄 File Names**
- **Lowercase snake_case**: `login_screen.dart`, `user_model.dart`, `auth_service.dart`
- **Suffixes for clarity**:
  - `_screen.dart` for screen widgets
  - `_provider.dart` for state management
  - `_model.dart` for data models
  - `_service.dart` for API services
  - `_repository.dart` for repositories
  - `_widget.dart` for reusable widgets
  - `_extension.dart` for extensions
  - `_util.dart` for utilities

### **🏷️ Class Names**
- **PascalCase**: `LoginScreen`, `UserModel`, `AuthService`
- **Descriptive and context-specific**: `ProductCatalogScreen`, `UserAuthenticationProvider`
- **Avoid abbreviations**: `Authentication` instead of `Auth`, `User` instead of `U`

### **🔤 Variable Names**
- **camelCase**: `userName`, `isLoading`, `productList`
- **Descriptive**: `isUserLoggedIn` instead of `isLoggedIn`
- **Boolean prefixes**: `is`, `has`, `can`, `should`
- **Constants**: `UPPER_SNAKE_CASE`: `MAX_RETRY_ATTEMPTS`, `API_BASE_URL`

### **🔧 Function Names**
- **camelCase**: `handleLogin()`, `validateEmail()`, `fetchProducts()`
- **Verb-first for actions**: `submitForm()`, `navigateToScreen()`
- **Boolean-returning**: `isValidEmail()`, `hasPermission()`
- **Private methods**: `_handleLogin()`, `_validateInput()`

### **🏷️ Widget Names**
- **PascalCase**: `LoginScreen`, `ProductCard`, `UserAvatar`
- **Descriptive**: `EnhancedProductCard`, `GlassmorphicButton`
- **Screen suffix**: `LoginScreen`, `ProductCatalogScreen`
- **Widget suffix**: `ProductCard`, `UserAvatar`, `LoadingWidget`

---

## 🎨 **UI Component Organization**

### **📱 Screen Components**
```
screens/
├── login_screen.dart              # Login screen
├── register_screen.dart           # Registration screen
├── dashboard_screen.dart          # Main dashboard
├── product_catalog_screen.dart     # Product catalog
└── profile_screen.dart           # User profile
```

### **🧩 Widget Components**
```
widgets/
├── forms/                       # Form widgets
│   ├── login_form.dart
│   ├── register_form.dart
│   └── search_form.dart
├── cards/                       # Card widgets
│   ├── product_card.dart
│   ├── user_card.dart
│   └── analytics_card.dart
├── buttons/                      # Button widgets
│   ├── primary_button.dart
│   ├── secondary_button.dart
│   └── glassmorphic_button.dart
└── dialogs/                      # Dialog widgets
    ├── confirmation_dialog.dart
    └── error_dialog.dart
```

### **🎨 Theme Components**
```
theme/
├── app_theme.dart                # Main theme configuration
├── colors.dart                   # Color definitions
├── text_styles.dart              # Text styles
├── spacing.dart                 # Spacing constants
└── theme_extensions.dart        # Theme extensions
```

---

## 📊 **Data Layer Organization**

### **🏗️ Model Structure**
```dart
// models/user_model.dart
class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final DateTime createdAt;

  // Constructor
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  // From JSON factory
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  // To JSON method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Copy with method
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
```

### **🔌 Service Structure**
```dart
// services/auth_service.dart
class AuthService {
  static const String _baseUrl = 'https://api.vedantatrade.com/v1';

  // API methods
  Future<LoginResponse> login(String email, String password) async {
    // Implementation
  }

  Future<User> register(Map<String, dynamic> userData) async {
    // Implementation
  }

  Future<void> logout() async {
    // Implementation
  }
}
```

### **📦 Provider Structure**
```dart
// providers/auth_provider.dart
class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Methods
  Future<void> login(String email, String password) async {
    // Implementation
  }

  void logout() {
    // Implementation
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
```

---

## 🔧 **Development Guidelines**

### **📋 Code Organization Rules**
1. **Single Responsibility**: Each class has one reason to change
2. **Dependency Inversion**: Depend on abstractions, not concretions
3. **Interface Segregation**: Small, focused interfaces
4. **Open/Closed**: Open for extension, closed for modification

### **🎯 File Size Guidelines**
- **Maximum 500 lines** per file
- **Split large files** into smaller, focused modules
- **Use barrel exports** for clean imports

### **📦 Import Organization**
```dart
// Import order: Flutter → External → Internal → Local

// Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// External packages
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

// Internal imports (from lib/)
import '../../../shared/widgets/premium_glassmorphic_theme.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';

// Local imports (same directory)
import 'auth_service.dart';
import 'user_repository.dart';
```

### **📝 Comment Standards**
```dart
/// User model class
/// 
/// Represents a user in the VedantaTrade system with authentication
/// and role-based access control.
class User {
  /// Unique identifier for the user
  final String id;

  /// User's full name
  final String name;

  /// User's email address
  final String email;

  /// User's role in the system (Admin, MR, Stockist, etc.)
  final String role;

  /// Account creation timestamp
  final DateTime createdAt;

  /// Creates a new User instance
  /// 
  /// [id] - Unique user identifier
  /// [name] - User's full name
  /// [email] - User's email address
  /// [role] - User's role in system
  /// [createdAt] - Account creation date
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  // Method documentation
  /// Creates a User from JSON data
  /// 
  /// [json] - Map containing user data
  /// Returns User instance or throws FormatException
  factory User.fromJson(Map<String, dynamic> json) {
    // Implementation
  }
}
```

---

## 🔄 **Refactoring Guidelines**

### **📊 When to Refactor**
- **File > 500 lines**: Split into smaller modules
- **Class > 300 lines**: Consider breaking into smaller classes
- **Method > 50 lines**: Extract into smaller methods
- **Deep nesting**: Use early returns or extract methods
- **Repeated code**: Create shared utilities

### **🧹 Code Cleanup**
- **Remove unused imports**: Use IDE tools to clean up
- **Remove dead code**: Delete unused methods and classes
- **Consistent formatting**: Use dart format
- **Update documentation**: Keep comments current

### **📦 Dependency Management**
- **Pin versions**: Use specific versions in pubspec.yaml
- **Regular updates**: Update dependencies monthly
- **Security updates**: Prioritize security patches
- **License compatibility**: Ensure all licenses are compatible

---

## 🧪 **Testing Structure**

### **📁 Test Organization**
```
test/
├── unit/                         # Unit tests
│   ├── features/
│   │   ├── auth/
│   │   │   ├── auth_provider_test.dart
│   │   │   └── auth_service_test.dart
│   │   └── catalog/
│   │       ├── catalog_provider_test.dart
│   │       └── catalog_service_test.dart
│   └── shared/
│       └── widgets_test.dart
├── widget/                       # Widget tests
│   ├── screens/
│   │   ├── login_screen_test.dart
│   │   └── catalog_screen_test.dart
│   └── widgets/
│       ├── product_card_test.dart
│       └── glassmorphic_button_test.dart
├── integration/                  # Integration tests
│   ├── auth_flow_test.dart
│   └── catalog_flow_test.dart
└── e2e/                         # End-to-end tests
    ├── user_registration_test.dart
    └── product_purchase_test.dart
```

### **🧪 Test Naming Conventions**
- **File names**: `*_test.dart` suffix
- **Test methods**: `test_` prefix, descriptive names
- **Group tests**: Use `group()` for related tests
- **Setup/teardown**: Use `setUp()` and `tearDown()`

---

## 📋 **Maintenance Checklist**

### **🔄 Regular Tasks**
- [ ] **Weekly**: Code review and refactoring
- [ ] **Monthly**: Dependency updates and security patches
- [ ] **Quarterly**: Architecture review and optimization
- [ ] **Annually**: Technology stack evaluation

### **📊 Quality Metrics**
- **Code coverage**: Target >90%
- **Static analysis**: Zero critical issues
- **Performance**: <3s app startup time
- **Security**: Zero high-severity vulnerabilities

### **📚 Documentation**
- [ ] **README.md**: Always up-to-date
- [ ] **API docs**: Current with latest changes
- [ ] **Architecture docs**: Reflect current structure
- [ ] **Development guide**: New developer onboarding

---

*Last Updated: April 3, 2026*  
*Project: VedantaTrade - Enterprise Pharmaceutical Distribution*  
*Version: v3.2.1-alpha*

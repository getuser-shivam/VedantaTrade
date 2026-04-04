# VedantaTrade - Project Structure Guidelines

## Directory Organization

### Root Structure
```
lib/
├── app/                    # App-level configuration
│   ├── app.dart           # Main app widget and router setup
│   ├── router/            # Navigation configuration
│   └── theme/             # App-wide theming
├── core/                  # Core utilities and configurations
│   ├── api_config.dart    # API endpoints and configuration
│   ├── constants/         # App constants
│   ├── services/          # Core services
│   └── utils/             # Utility functions
├── data/                  # Global data models and repositories
├── features/              # Feature-based modules
├── shared/                # Shared widgets and utilities
│   ├── app_scaffold.dart  # Common app scaffold
│   ├── theme/             # Shared theming
│   ├── ui/                # Reusable UI components
│   └── widgets/           # Shared widgets
└── main.dart             # App entry point
```

### Feature Structure (Clean Architecture)
```
features/
├── feature_name/
│   ├── domain/            # Business logic
│   │   ├── models/        # Domain models
│   │   └── repositories/  # Repository interfaces
│   ├── data/              # Data layer
│   │   ├── models/        # Data models
│   │   ├── repositories/  # Repository implementations
│   │   └── services/      # API services
│   ├── presentation/      # UI layer
│   │   ├── providers/     # State management
│   │   ├── screens/       # Screen widgets
│   │   └── widgets/       # Feature-specific widgets
│   └── feature_name.dart  # Barrel exports
```

## Naming Conventions

### Files
- **Screens**: `snake_case` with `_screen.dart` suffix
  - ✅ `login_screen.dart`, `product_catalog_screen.dart`
  - ❌ `LoginScreen.dart`, `productcatalog.dart`

- **Providers**: `snake_case` with `_provider.dart` suffix
  - ✅ `auth_provider.dart`, `cart_provider.dart`
  - ❌ `AuthProvider.dart`, `cartprovider.dart`

- **Models**: `snake_case.dart` (no suffix)
  - ✅ `product.dart`, `user.dart`
  - ❌ `ProductModel.dart`, `user_model.dart`

- **Services**: `snake_case` with `_service.dart` suffix
  - ✅ `auth_service.dart`, `distribution_service.dart`
  - ❌ `AuthService.dart`, `distributionservice.dart`

- **Widgets**: `snake_case.dart` (no suffix)
  - ✅ `product_card.dart`, `glassmorphic_button.dart`
  - ❌ `ProductCard.dart`, `glassmorphicbutton.dart`

- **Constants**: `snake_case.dart` (no suffix)
  - ✅ `app_constants.dart`, `api_endpoints.dart`
  - ❌ `AppConstants.dart`, `apiendpoints.dart`

### Directories
- Use `snake_case` for all directory names
- ✅ `presentation/`, `data/`, `domain/`
- ❌ `Presentation/`, `Data/`, `Domain/`

### Classes
- Use `PascalCase` for class names
- ✅ `class ProductProvider`, `class LoginScreen`
- ❌ `class productprovider`, `class login_screen`

### Variables & Methods
- Use `camelCase` for variables and methods
- ✅ `final userName`, `void loadProducts()`
- ❌ `final user_name`, `void LoadProducts()`

### Constants
- Use `SCREAMING_SNAKE_CASE` for constants
- ✅ `const String API_BASE_URL`, `static const int MAX_ITEMS`
- ❌ `const String apiBaseUrl`, `static const int maxItems`

## Barrel Exports

Each feature should have a barrel export file (`feature_name.dart`) that exports all public APIs:

```dart
// feature_name.dart

// Domain
export 'domain/models/product.dart';
export 'domain/repositories/product_repository.dart';

// Data
export 'data/services/product_service.dart';
export 'data/repositories/product_repository_impl.dart';

// Presentation
export 'presentation/providers/product_provider.dart';
export 'presentation/screens/product_screen.dart';
export 'presentation/widgets/product_card.dart';
```

## Import Organization

### Import Order
1. Dart core libraries
2. Flutter framework
3. Third-party packages
4. App core modules
5. Feature modules (alphabetical)
6. Relative imports

### Example
```dart
// Dart core
import 'dart:async';
import 'dart:convert';

// Flutter framework
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Third-party packages
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

// App core
import 'package:vedanta_trade/core/api_config.dart';
import 'package:vedanta_trade/shared/widgets/glassmorphic_widgets.dart';

// Feature modules
import 'package:vedanta_trade/features/auth/auth.dart';
import 'package:vedanta_trade/features/catalog/catalog.dart';

// Relative imports
import '../widgets/custom_button.dart';
```

## Clean Architecture Guidelines

### Domain Layer
- Contains business logic only
- No framework dependencies
- Pure Dart classes

### Data Layer
- Repository implementations
- API services
- Data transfer objects

### Presentation Layer
- UI components and state management
- Framework dependencies allowed
- No business logic

## File Organization Rules

### 1. Feature-Based Organization
- Group related functionality by feature
- Each feature is self-contained
- Avoid cross-feature dependencies

### 2. Separation of Concerns
- Keep UI, business logic, and data separate
- Use dependency injection
- Follow SOLID principles

### 3. Consistent Structure
- All features follow the same structure
- Use barrel exports for clean imports
- Maintain consistent naming

### 4. Shared Code
- Put reusable widgets in `shared/widgets/`
- Put reusable utilities in `core/utils/`
- Put shared models in `data/models/`

## Migration Strategy

### Phase 1: Standardize Naming
1. Rename files to follow conventions
2. Update class names
3. Fix variable/method names

### Phase 2: Reorganize Structure
1. Move files to correct directories
2. Create barrel exports
3. Update imports

### Phase 3: Clean Architecture
1. Separate domain/data/presentation
2. Create repository interfaces
3. Implement dependency injection

## Code Quality

### Linting Rules
- Use `flutter analyze` to check for issues
- Follow Dart style guide
- Enable strict analysis options

### Documentation
- Add package-level documentation
- Document public APIs
- Include usage examples

### Testing
- Place tests in corresponding `test/` directories
- Follow naming conventions for test files
- Maintain high test coverage
│
├── features/                     # Feature modules (Clean Architecture)
│   ├── auth/                     # Authentication feature
│   ├── admin/                    # Admin dashboard
│   ├── accountant/               # Accountant role
│   ├── stockist/                 # Stockist role
│   ├── mr/                       # Medical Representative
│   ├── retailer/                 # Retailer role
│   ├── doctor/                   # Doctor role
│   ├── catalog/                  # Product catalog
│   ├── distribution/             # Distribution management
│   ├── orders/                   # Order management
│   └── gallery/                  # App gallery
│
├── shared/                       # Shared components
│   ├── widgets/                  # Reusable widgets
│   ├── theme/                    # Shared theme elements
│   └── ui/                       # UI utilities
│
└── main.dart                     # App entry point
```

## Feature Module Structure (Clean Architecture)

Each feature follows Clean Architecture:

```
features/{feature_name}/
├── domain/                       # Business logic
│   ├── entities/                 # Data models/entities
│   ├── repositories/             # Repository interfaces
│   └── usecases/                 # Use cases (optional)
│
├── data/                         # Data layer
│   ├── models/                   # DTOs and data models
│   ├── repositories/             # Repository implementations
│   └── datasources/              # API and local data sources
│
└── presentation/                 # UI layer
    ├── screens/                  # Screen widgets (ends with _screen.dart)
    ├── widgets/                  # Feature-specific widgets
    └── providers/                # State management providers
```

## Naming Conventions

### Files

| Type | Pattern | Example |
|------|---------|---------|
| Screens | `{name}_screen.dart` | `login_screen.dart` |
| Widgets | `{name}_widget.dart` or `{name}.dart` | `product_card.dart` |
| Models | `{name}_model.dart` or `{name}.dart` | `product.dart` |
| Providers | `{name}_provider.dart` | `auth_provider.dart` |
| Services | `{name}_service.dart` | `api_service.dart` |
| Repositories | `{name}_repository.dart` | `product_repository.dart` |

### Classes

| Type | Pattern | Example |
|------|---------|---------|
| Screens | `{PascalCase}Screen` | `LoginScreen` |
| Widgets | `{PascalCase}Widget` or `{PascalCase}` | `ProductCard` |
| Models | `{PascalCase}` | `Product` |
| Providers | `{PascalCase}Provider` | `AuthProvider` |
| Services | `{PascalCase}Service` | `ApiService` |

## Current Refactoring Status

### Completed
- [x] Background GPS Service moved to `core/services/`
- [x] Product catalog with Clean Architecture
- [x] Distribution service with sales tracking

### In Progress
- [ ] Standardize feature folder structure
- [ ] Remove empty root-level directories
- [ ] Consolidate duplicate widgets

### Pending
- [ ] Move legacy screens to `presentation/screens/`
- [ ] Rename files to follow conventions
- [ ] Update imports throughout project

## Migration Guide

### Moving Screens
```bash
# Old location
lib/features/stockist/stockist_dashboard.dart

# New location
lib/features/stockist/presentation/screens/stockist_dashboard_screen.dart
```

### Updating Imports
```dart
// Old
import '../../stockist/stockist_dashboard.dart';

// New
import '../../stockist/presentation/screens/stockist_dashboard_screen.dart';
```

## Best Practices

1. **One feature per directory** - Keep all related code together
2. **Presentation layer only imports from domain** - No direct data layer access
3. **Use barrel files** - Export public API from `index.dart` or `{feature}.dart`
4. **Consistent suffixes** - Always use `_screen.dart` for screens
5. **Feature isolation** - Features should not import from other features' internals

---

Last Updated: April 3, 2026

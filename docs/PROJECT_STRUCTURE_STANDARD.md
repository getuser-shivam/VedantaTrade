# VedantaTrade - Standardized Project Directory Structure

## Overview

This document establishes the standardized directory structure for the VedantaTrade project, ensuring consistency, scalability, and maintainability across all features and modules.

## Principles

1. **Clean Architecture**: Strict separation of concerns with data, domain, and presentation layers
2. **Feature-Based Organization**: Each feature is self-contained with its own architecture
3. **Consistent Naming**: Snake_case for directories, camelCase for files
4. **Scalability**: Structure supports easy addition of new features and modules
5. **Maintainability**: Clear hierarchy makes code easy to locate and modify

## Root Directory Structure

```
vedanta_trade/
├── android/                    # Android-specific files
├── ios/                       # iOS-specific files
├── web/                       # Web-specific files
├── linux/                     # Linux-specific files
├── macos/                     # macOS-specific files
├── windows/                   # Windows-specific files
├── lib/                       # Main source code
│   ├── main.dart             # Application entry point
│   ├── app/                  # App-level configuration
│   ├── core/                 # Core utilities and shared code
│   ├── features/             # Feature modules
│   ├── shared/               # Shared widgets and utilities
│   └── data/                 # Global data configurations
├── assets/                   # Static assets (images, fonts, etc.)
├── test/                     # Test files
├── docs/                     # Documentation
├── scripts/                  # Build and deployment scripts
├── tools/                    # Development tools
├── backend/                  # Backend API code
├── deployment/              # Deployment configurations
└── pubspec.yaml            # Dependencies
```

## lib/ Directory Structure

### app/
Application-level configuration and initialization

```
app/
├── app.dart                 # Main app widget
├── router/                  # Navigation routing
│   └── app_router.dart
└── theme/                   # App-wide theming
    ├── app_theme.dart
    └── color_scheme.dart
```

### core/
Core utilities, constants, and shared services

```
core/
├── constants/               # App-wide constants
│   ├── app_constants.dart
│   └── api_endpoints.dart
├── network/                 # Network utilities
│   ├── api_client.dart
│   └── api_config.dart
├── errors/                  # Custom error types
│   └── app_exceptions.dart
├── extensions/              # Dart extensions
│   └── string_extensions.dart
├── security/                # Security utilities
│   └── encryption_service.dart
├── storage/                 # Storage utilities
│   └── secure_storage.dart
├── utils/                   # Utility functions
│   └── date_utils.dart
└── widgets/                 # Core widgets
    └── loading_widget.dart
```

### features/
Feature modules following Clean Architecture

```
features/
├── feature_name/            # Feature directory (snake_case)
│   ├── feature_name.dart     # Feature entry point (exports public API)
│   ├── feature_name_feature.dart  # Feature registration
│   ├── data/                # Data layer
│   │   ├── models/          # Data models
│   │   │   └── feature_model.dart
│   │   ├── repositories/    # Repository implementations
│   │   │   └── feature_repository_impl.dart
│   │   ├── datasources/     # Data sources (API, local storage)
│   │   │   ├── feature_remote_datasource.dart
│   │   │   └── feature_local_datasource.dart
│   │   └── services/        # Data services
│   │       └── feature_service.dart
│   ├── domain/              # Domain layer
│   │   ├── entities/        # Domain entities
│   │   │   └── feature_entity.dart
│   │   ├── repositories/    # Repository interfaces
│   │   │   └── feature_repository.dart
│   │   ├── usecases/        # Business logic use cases
│   │   │   └── feature_usecase.dart
│   │   └── services/        # Domain services
│   │       └── feature_domain_service.dart
│   └── presentation/        # Presentation layer
│       ├── screens/         # Full-screen widgets
│       │   └── feature_screen.dart
│       ├── widgets/         # Reusable widgets
│       │   └── feature_widget.dart
│       ├── providers/       # State management (ChangeNotifier, Bloc, etc.)
│       │   └── feature_provider.dart
│       └── pages/           # Page-level widgets (if needed)
│           └── feature_page.dart
```

### shared/
Shared widgets, utilities, and components used across features

```
shared/
├── widgets/                 # Shared UI widgets
│   ├── common_widgets.dart
│   ├── buttons.dart
│   └── cards.dart
├── utils/                   # Shared utility functions
│   ├── validators.dart
│   └── formatters.dart
├── theme/                   # Shared theme components
│   ├── app_colors.dart
│   └── app_text_styles.dart
├── services/                # Shared services
│   └── notification_service.dart
├── navigation/              # Navigation helpers
│   └── navigation_service.dart
└── constants/               # Shared constants
    └── shared_constants.dart
```

### data/
Global data configurations (deprecated - move to core/)

```
data/
├── config/                  # Configuration files
├── models/                  # Global models
└── providers/               # Global providers
```

## Feature Structure Standards

### Required Files
Every feature must have:
1. `feature_name.dart` - Entry point exporting public API
2. `feature_name_feature.dart` - Feature registration in app router

### Layer Responsibilities

**Data Layer** (`data/`):
- Models for API responses and local storage
- Repository implementations
- Data sources (remote API, local storage, cache)
- Data services (API clients, storage services)

**Domain Layer** (`domain/`):
- Entities (pure business objects)
- Repository interfaces (contracts)
- Use cases (business logic)
- Domain services (business rules)

**Presentation Layer** (`presentation/`):
- Screens (full-screen widgets)
- Widgets (reusable components)
- Providers (state management)
- Pages (if using multi-page navigation)

## Naming Conventions

### Directories
- Use **snake_case** for all directory names
- Examples: `product_catalog`, `user_profile`, `order_management`

### Files
- Use **camelCase** for all file names
- Examples: `productCatalog.dart`, `userProfileScreen.dart`, `orderService.dart`

### Classes
- Use **PascalCase** for class names
- Examples: `ProductCatalog`, `UserProfileScreen`, `OrderService`

### Variables
- Use **camelCase** for variable names
- Examples: `userName`, `orderTotal`, `isAuthenticated`

### Constants
- Use **camelCase** with descriptive names or UPPER_CASE for global constants
- Examples: `apiBaseUrl`, `MAX_RETRY_COUNT`

### Private Members
- Prefix with underscore
- Examples: `_userName`, `_calculateTotal()`

## File Naming Patterns

### Screens
Pattern: `{feature}_screen.dart`
Examples: `login_screen.dart`, `product_detail_screen.dart`

### Widgets
Pattern: `{widget_name}_widget.dart`
Examples: `product_card_widget.dart`, `search_bar_widget.dart`

### Providers
Pattern: `{feature}_provider.dart`
Examples: `authentication_provider.dart`, `product_catalog_provider.dart`

### Models
Pattern: `{entity}_model.dart` (data layer) or `{entity}.dart` (domain layer)
Examples: `user_model.dart`, `product.dart`

### Services
Pattern: `{service}_service.dart`
Examples: `api_service.dart`, `storage_service.dart`

### Use Cases
Pattern: `{action}_usecase.dart`
Examples: `login_usecase.dart`, `fetch_products_usecase.dart`

## Import Organization

Standard import order:
1. Dart SDK imports
2. Flutter imports
3. Package imports
4. Core imports
5. Feature imports (current feature first, then other features)
6. Relative imports

```dart
// Dart SDK
import 'dart:async';
import 'dart:convert';

// Flutter
import 'package:flutter/material.dart';

// Packages
import 'package:dio/dio.dart';

// Core
import 'package:vedanta_trade/core/constants/app_constants.dart';

// Current Feature
import 'package:vedanta_trade/features/authentication/data/models/user_model.dart';

// Other Features
import 'package:vedanta_trade/features/product_catalog/domain/entities/product.dart';

// Relative
import '../widgets/auth_button.dart';
```

## Directory Creation Guidelines

### New Feature Creation
When creating a new feature:
1. Create feature directory: `lib/features/new_feature/`
2. Create standard subdirectories: `data/`, `domain/`, `presentation/`
3. Create required subdirectories in each layer
4. Create entry point files: `new_feature.dart`, `new_feature_feature.dart`
5. Follow naming conventions for all files

### Adding to Existing Feature
When adding to existing feature:
1. Place files in appropriate layer (data/domain/presentation)
2. Use appropriate subdirectory (models/repositories/screens/widgets)
3. Follow naming patterns for file type
4. Export from feature entry point if public API

## Best Practices

1. **One Class Per File**: Each file should contain one primary class
2. **Barrel Files**: Use index files to group related exports
3. **Avoid Deep Nesting**: Keep directory depth to 3-4 levels maximum
4. **Logical Grouping**: Group related files together
5. **Clear Naming**: File names should clearly indicate purpose
6. **Consistent Structure**: All features should follow same pattern
7. **Minimal Dependencies**: Features should have minimal cross-dependencies
8. **Public API**: Export only what's needed from feature entry point

## Migration Plan

### Phase 1: Documentation
- Document current structure
- Identify inconsistencies
- Create this standard document

### Phase 2: New Features
- Apply structure to all new features
- Enforce naming conventions

### Phase 3: Existing Features
- Gradually refactor existing features
- Update file names to match conventions
- Reorganize directories as needed

### Phase 4: Validation
- Verify consistency across all features
- Update development guidelines
- Train team on new standards

## Examples

### Example Feature: User Authentication

```
features/authentication/
├── authentication.dart
├── authentication_feature.dart
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   └── auth_response_model.dart
│   ├── repositories/
│   │   └── authentication_repository_impl.dart
│   ├── datasources/
│   │   ├── auth_remote_datasource.dart
│   │   └── auth_local_datasource.dart
│   └── services/
│       ├── jwt_service.dart
│       └── oauth_service.dart
├── domain/
│   ├── entities/
│   │   └── user_entity.dart
│   ├── repositories/
│   │   └── authentication_repository.dart
│   ├── usecases/
│   │   ├── login_usecase.dart
│   │   ├── logout_usecase.dart
│   │   └── register_usecase.dart
│   └── services/
│       └── auth_domain_service.dart
└── presentation/
    ├── screens/
    │   ├── login_screen.dart
    │   ├── register_screen.dart
    │   └── forgot_password_screen.dart
    ├── widgets/
    │   ├── login_form_widget.dart
    │   └── auth_button_widget.dart
    └── providers/
        └── authentication_provider.dart
```

## Checklist for New Features

- [ ] Feature directory created with snake_case name
- [ ] Standard subdirectories created (data/domain/presentation)
- [ ] Entry point file created: `{feature_name}.dart`
- [ ] Feature registration file created: `{feature_name}_feature.dart`
- [ ] Data layer subdirectories created (models/repositories/datasources/services)
- [ ] Domain layer subdirectories created (entities/repositories/usecases/services)
- [ ] Presentation layer subdirectories created (screens/widgets/providers)
- [ ] All files use camelCase naming
- [ ] Classes use PascalCase naming
- [ ] Public API exported from entry point
- [ ] Imports organized according to standards
- [ ] One class per file
-  - No deep nesting (max 3-4 levels)
- [ ] Feature follows Clean Architecture principles

## Maintenance

This document should be reviewed and updated:
- When adding new feature types
- When Flutter best practices change
- When team consensus on structure changes
- Annually for general review

## References

- [Flutter Project Structure Best Practices](https://flutter.dev/docs/development/data-and-backend/state-mgmt/options)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)

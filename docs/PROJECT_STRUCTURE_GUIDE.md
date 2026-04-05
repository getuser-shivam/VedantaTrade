# VedantaTrade - Standardized Project Structure Guide

## 📋 Overview

This document outlines the standardized directory structure and naming conventions for the VedantaTrade pharmaceutical distribution platform. The structure is designed to promote maintainability, scalability, and collaboration while following Flutter/Dart best practices.

## 🏗️ Core Principles

### 1. Separation of Concerns
- **Domain Layer**: Business logic and entities
- **Data Layer**: Data sources and repositories
- **Presentation Layer**: UI components and state management
- **Shared Layer**: Reusable components and utilities

### 2. Feature-Based Organization
- Each feature is self-contained with its own domain, data, and presentation layers
- Features are independent and can be developed in parallel
- Clear boundaries between features reduce coupling

### 3. Consistent Naming Conventions
- **Files**: `snake_case.dart` for Dart files
- **Directories**: `snake_case` for folders
- **Classes**: `PascalCase` for class names
- **Variables**: `camelCase` for variable names

## 📁 Project Structure

```
VedantaTrade/
├── README.md                           # Project overview and setup instructions
├── CHANGELOG.md                        # Version history and changes
├── pubspec.yaml                        # Flutter dependencies and configuration
├── analysis_options.yaml              # Dart analysis configuration
├── .gitignore                          # Git ignore patterns
├── .github/                           # GitHub Actions and CI/CD
│   └── workflows/                      # Workflow definitions
├── docs/                              # Documentation
│   ├── PROJECT_STRUCTURE_GUIDE.md      # This file
│   ├── DEVELOPMENT_GUIDE.md           # Development guidelines
│   ├── API_DOCUMENTATION.md            # API documentation
│   ├── DEPLOYMENT_GUIDE.md           # Deployment instructions
│   └── USER_GUIDE.md                 # User documentation
├── lib/                               # Main application source code
│   ├── app/                           # Application entry point
│   │   ├── main.dart                 # Main application file
│   │   ├── app.dart                   # App widget configuration
│   │   ├── routes/                   # Route definitions
│   │   │   ├── app_router.dart      # Main router
│   │   │   └── route_names.dart    # Route constants
│   │   └── theme/                    # App theme configuration
│   │       ├── app_theme.dart        # Main theme
│   │       └── theme_extensions.dart # Theme extensions
│   ├── core/                          # Core shared functionality
│   │   ├── constants/                # App-wide constants
│   │   │   ├── app_constants.dart   # General constants
│   │   │   ├── api_constants.dart    # API endpoints
│   │   │   ├── storage_constants.dart # Storage keys
│   │   │   └── validation_constants.dart # Validation rules
│   │   ├── errors/                   # Error handling
│   │   │   ├── app_exceptions.dart  # Custom exceptions
│   │   │   ├── error_handler.dart    # Error handling logic
│   │   │   └── failure_types.dart   # Failure type definitions
│   │   ├── utils/                    # Utility functions
│   │   │   ├── app_utils.dart       # General utilities
│   │   │   ├── date_utils.dart      # Date utilities
│   │   │   ├── formatters.dart      # Data formatters
│   │   │   ├── validators.dart       # Input validators
│   │   │   └── crypto_utils.dart    # Cryptography utilities
│   │   ├── services/                 # Core services
│   │   │   ├── storage_service.dart # Storage service
│   │   │   ├── network_service.dart # Network service
│   │   │   ├── notification_service.dart # Notifications
│   │   │   └── analytics_service.dart # Analytics service
│   │   ├── extensions/                # Dart extensions
│   │   │   ├── string_extensions.dart # String extensions
│   │   │   ├── datetime_extensions.dart # DateTime extensions
│   │   │   └── num_extensions.dart   # Number extensions
│   │   └── widgets/                  # Shared widgets
│   │       ├── enhanced_app_theme.dart # Theme system
│   │       ├── loading_overlay.dart   # Loading overlay
│   │       ├── error_widget.dart     # Error display
│   │       ├── empty_state_widget.dart # Empty state
│   │       └── responsive_layout.dart # Responsive layout
│   └── features/                      # Feature modules
│       ├── authentication/              # Authentication feature
│       │   ├── domain/              # Domain layer
│       │   │   ├── entities/        # Data entities
│       │   │   │   ├── auth_user_entity.dart
│       │   │   │   ├── user_session_entity.dart
│       │   │   │   └── security_settings_entity.dart
│       │   │   └── repositories/     # Repository interfaces
│       │   │       └── authentication_repository.dart
│       │   └── data/                # Data layer
│       │       ├── datasources/     # Data sources
│       │       │   ├── auth_local_datasource.dart
│       │       │   └── auth_remote_datasource.dart
│       │       ├── models/           # Data models
│       │       │   ├── auth_models.dart
│       │       │   └── token_models.dart
│       │       └── repositories/     # Repository implementations
│       │           └── authentication_repository_impl.dart
│       │       └── presentation/      # Presentation layer
│       │           ├── providers/       # State management
│       │           │   └── authentication_provider.dart
│       │           ├── screens/         # UI screens
│       │           │   ├── login_screen.dart
│       │           │   ├── register_screen.dart
│       │           │   └── profile_screen.dart
│       │           └── widgets/         # Reusable widgets
│       │               ├── auth_form_field.dart
│       │               ├── auth_button.dart
│       │               └── social_login_buttons.dart
│       ├── product_catalog/             # Product catalog feature
│       │   ├── domain/              # Domain layer
│       │   │   ├── entities/        # Product entities
│       │   │   │   ├── product_entity.dart
│       │   │   │   ├── product_variant_entity.dart
│       │   │   │   ├── product_category_entity.dart
│       │   │   │   └── product_filter_entity.dart
│       │   │   └── repositories/     # Repository interfaces
│       │   │       └── product_catalog_repository.dart
│       │   └── data/                # Data layer
│       │       ├── datasources/     # Data sources
│       │       │   ├── product_local_datasource.dart
│       │       │   └── product_remote_datasource.dart
│       │       ├── models/           # Data models
│       │       │   └── product_models.dart
│       │       └── repositories/     # Repository implementations
│       │           └── product_catalog_repository_impl.dart
│       │       └── presentation/      # Presentation layer
│       │           ├── providers/       # State management
│       │           │   └── product_catalog_provider.dart
│       │           ├── screens/         # UI screens
│       │           │   ├── enhanced_product_catalog_screen.dart
│       │           │   ├── product_detail_screen.dart
│       │           │   └── product_comparison_screen.dart
│       │           └── widgets/         # Reusable widgets
│       │               ├── enhanced_product_card.dart
│       │               ├── enhanced_search_filter_bar.dart
│       │               └── category_chips.dart
│       ├── distribution/               # Distribution management
│       │   ├── domain/              # Domain layer
│       │   │   ├── entities/        # Distribution entities
│       │   │   │   ├── distribution_entity.dart
│       │   │   │   ├── marketing_campaign_entity.dart
│       │   │   │   └── warehouse_inventory_entity.dart
│       │   │   └── repositories/     # Repository interfaces
│       │   │       └── distribution_repository.dart
│       │   └── data/                # Data layer
│       │       ├── datasources/     # Data sources
│       │       │   ├── distribution_local_datasource.dart
│       │       │   └── distribution_remote_datasource.dart
│       │       ├── models/           # Data models
│       │       │   └── distribution_models.dart
│       │       └── repositories/     # Repository implementations
│       │           └── distribution_repository_impl.dart
│       │       └── presentation/      # Presentation layer
│       │           ├── providers/       # State management
│       │           │   └── distribution_provider.dart
│       │           ├── screens/         # UI screens
│       │           │   ├── distribution_dashboard_screen.dart
│       │           │   ├── order_management_screen.dart
│       │           │   └── route_optimization_screen.dart
│       │           └── widgets/         # Reusable widgets
│       │               ├── distribution_overview_card.dart
│       │               └── route_optimization_panel.dart
│       └── shared/                    # Shared features
│           ├── shared_widgets/         # Common widgets
│           ├── shared_services/         # Common services
│           └── shared_models/           # Common models
├── test/                              # Test files
│   ├── unit/                        # Unit tests
│   ├── widget/                       # Widget tests
│   ├── integration/                  # Integration tests
│   └── e2e/                         # End-to-end tests
├── assets/                            # Static assets
│   ├── images/                       # Image assets
│   │   ├── logos/                  # Logo files
│   │   ├── icons/                  # Icon files
│   │   └── products/               # Product images
│   ├── fonts/                        # Font files
│   └── data/                         # Static data files
├── tools/                             # Development tools
│   ├── scripts/                       # Build and deployment scripts
│   ├── generators/                    # Code generators
│   └── linters/                      # Custom linters
└── backend/                            # Backend code (if applicable)
    ├── src/                           # Source code
    ├── prisma/                        # Database schema
    ├── tests/                          # Backend tests
    └── docs/                           # Backend documentation
│   └── routes/                   # Navigation routes
└── feature_name.dart             # Barrel export file
```

## 🎯 Feature Organization

### Core Features
- **auth/** - Authentication and authorization
- **user_management/** - User profile and settings
- **product_catalog/** - Product browsing and search
- **orders/** - Order management and tracking
- **inventory/** - Inventory management
- **distribution/** - Distribution and logistics
- **marketing/** - Marketing campaigns and analytics
- **accounting/** - Financial management
- **notifications/** - Push notifications and alerts

### Supporting Features
- **gallery/** - App gallery and showcase
- **ux/** - UX components and themes
- **shared/** - Shared utilities and widgets

## 📦 Package Organization

### Core Package
```
core/
├── constants/                    # App-wide constants
├── errors/                       # Custom error classes
├── network/                      # Network configuration
├── storage/                      # Local storage
├── utils/                        # Utility functions
├── extensions/                   # Dart extensions
└── core.dart                      # Core barrel export
```

### Shared Package
```
shared/
├── widgets/                      # Reusable widgets
│   ├── common/                   # Common UI components
│   ├── forms/                    # Form widgets
│   ├── charts/                   # Chart widgets
│   └── loaders/                  # Loading widgets
├── themes/                       # App themes and styles
├── extensions/                   # Widget extensions
├── validators/                   # Input validators
└── shared.dart                   # Shared barrel export
```

## 🔧 Development Tools Structure

```
tools/
├── build/                        # Build automation
├── analysis/                     # Code analysis tools
├── generation/                   # Code generation
├── deployment/                   # Deployment tools
└── maintenance/                  # Maintenance scripts
```

## 📝 File Naming Patterns

### Models
- `user_model.dart` - Main model class
- `user_entity.dart` - Domain entity
- `user_dto.dart` - Data transfer object

### Services
- `user_service.dart` - API service
- `user_repository.dart` - Repository implementation
- `user_usecase.dart` - Business logic use case

### UI Components
- `user_page.dart` - Full-screen page
- `user_card.dart` - Card widget
- `user_form.dart` - Form widget
- `user_list.dart` - List widget

### Providers
- `user_provider.dart` - State management
- `user_controller.dart` - Controller logic

## 🎨 Widget Organization

### Common Widgets
```
shared/widgets/common/
├── buttons/                      # Button components
├── forms/                        # Form components
├── cards/                        # Card components
├── lists/                        # List components
├── dialogs/                      # Dialog components
└── loaders/                      # Loading components
```

### Feature Widgets
```
features/feature_name/presentation/widgets/
├── feature_name_card.dart
├── feature_name_form.dart
├── feature_name_list.dart
└── feature_name_detail.dart
```

## 🔄 Import Organization

### Import Order
1. Dart core imports
2. Flutter framework imports
3. Third-party package imports
4. Core package imports
5. Shared package imports
6. Feature imports (current feature first)
7. Relative imports

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
import 'package:http/http.dart' as http;

// Core package
import 'package:vedanta_trade/core/constants/app_constants.dart';
import 'package:vedanta_trade/core/errors/app_exceptions.dart';

// Shared package
import 'package:vedanta_trade/shared/widgets/common/app_button.dart';

// Feature imports
import 'package:vedanta_trade/features/auth/data/models/user_model.dart';
import 'package:vedanta_trade/features/auth/presentation/providers/auth_provider.dart';

// Relative imports
import '../widgets/user_card.dart';
```

## 📊 Asset Organization

```
assets/
├── images/
│   ├── icons/                    # App icons
│   ├── logos/                    # Brand logos
│   ├── banners/                  # Banner images
│   └── products/                 # Product images
├── fonts/                        # Custom fonts
├── animations/                   # Lottie animations
├── data/                         # Static data files
│   ├── mock/                     # Mock data
│   └── config/                   # Configuration files
└── docs/                         # Asset documentation
```

## 🧪 Test Organization

```
test/
├── unit/                         # Unit tests
│   ├── core/                     # Core package tests
│   ├── shared/                   # Shared package tests
│   └── features/                # Feature tests
├── widget/                       # Widget tests
├── integration/                  # Integration tests
├── e2e/                          # End-to-end tests
├── fixtures/                     # Test fixtures
│   ├── data/                     # Test data
│   └── mocks/                    # Mock objects
└── test_helpers.dart             # Test utilities
```

## 📋 Migration Guidelines

### When Adding New Features
1. Create feature directory following the standard structure
2. Implement data layer first (models, services)
3. Add domain layer (entities, use cases)
4. Create presentation layer (pages, widgets, providers)
5. Add barrel export file
6. Write tests
7. Update documentation

### When Refactoring Existing Code
1. Identify the target feature/module
2. Create proper directory structure if missing
3. Move files to appropriate locations
4. Update import statements
5. Run tests to ensure functionality
6. Update documentation

## 🚀 Best Practices

### Directory Structure
- Keep related files together in feature modules
- Use barrel exports to simplify imports
- Avoid deep nesting (max 3-4 levels)
- Keep public API files at feature root

### File Organization
- One class per file when possible
- Group related functionality in directories
- Use descriptive file names
- Keep files focused and small (<300 lines preferred)

### Import Management
- Use barrel exports for clean imports
- Avoid circular dependencies
- Group imports logically
- Use relative imports only for same feature

## 📖 Documentation

### Code Documentation
- Document public APIs with dartdoc comments
- Include usage examples for complex widgets
- Document business logic in use cases
- Keep documentation up-to-date

### README Files
- Feature-level README in each feature directory
- Component documentation in widget directories
- API documentation in service directories

## 🔍 Maintenance

### Regular Tasks
- Review and clean up unused imports
- Ensure consistent naming conventions
- Update documentation as features change
- Run static analysis tools regularly

### Quality Checks
- Use dart analyze for code quality
- Run test coverage reports
- Check for circular dependencies
- Validate import organization

This structure provides a solid foundation for maintaining and scaling the VedantaTrade application while ensuring code quality and team productivity.

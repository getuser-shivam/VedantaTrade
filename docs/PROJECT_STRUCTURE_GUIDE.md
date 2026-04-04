# VedantaTrade - Project Structure Guide

## 📁 Standardized Directory Structure

This document outlines the standardized directory structure and naming conventions for the VedantaTrade project to ensure maintainability, scalability, and team collaboration.

## 🏗️ Overall Structure

```
vedanta_trade/
├── lib/                          # Main application source code
│   ├── main.dart                 # Application entry point
│   ├── app/                      # App-level configuration
│   ├── core/                     # Core shared functionality
│   ├── shared/                   # Shared utilities and widgets
│   ├── features/                 # Feature-based modules
│   └── data/                     # Data layer (models, services)
├── test/                         # Test files
├── assets/                       # Static assets
├── docs/                         # Documentation
├── scripts/                      # Build and automation scripts
├── tools/                        # Development tools
├── .github/                      # GitHub workflows and templates
├── android/                      # Android platform code
├── ios/                          # iOS platform code
└── web/                          # Web platform code
```

## 📋 Naming Conventions

### Files and Directories
- **snake_case** for files and directories: `user_profile.dart`, `order_management/`
- **PascalCase** for classes: `UserProfile`, `OrderManagementService`
- **camelCase** for variables and functions: `userName`, `getUserProfile()`
- **SCREAMING_SNAKE_CASE** for constants: `API_BASE_URL`, `MAX_RETRY_COUNT`
- **kebab-case** for package names: `vedanta_trade`

### Feature Module Structure
Each feature follows a consistent structure:

```
feature_name/
├── data/
│   ├── models/                   # Data models
│   ├── repositories/             # Repository implementations
│   ├── services/                 # API and external services
│   └── datasources/              # Local and remote data sources
├── domain/
│   ├── entities/                 # Business entities
│   ├── repositories/             # Repository interfaces
│   └── usecases/                 # Business logic use cases
├── presentation/
│   ├── pages/                    # Full-screen pages
│   ├── widgets/                  # Reusable UI components
│   ├── providers/                # State management
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

# VedantaTrade Development Guide

## 📋 Table of Contents
- [Project Overview](#project-overview)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Build and Deployment](#build-and-deployment)
- [Troubleshooting](#troubleshooting)

## 🎯 Project Overview

VedantaTrade is a comprehensive pharmaceutical distribution management system built with Flutter. The app serves as a B2B platform connecting manufacturers, distributors, retailers, and healthcare providers in Nepal's pharmaceutical supply chain.

### Key Features
- **Product Catalog**: Comprehensive pharmaceutical product database
- **Order Management**: Complete order lifecycle management
- **Inventory Tracking**: Real-time inventory monitoring
- **Distribution Network**: Multi-tier distribution management
- **Sales Analytics**: Comprehensive sales dashboard and reporting
- **Marketing Campaigns**: Campaign management and analytics
- **Customer Relationship Management**: Complete CRM system
- **Accounting**: Financial management and reporting

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.19.0 or higher
- Dart SDK compatible with Flutter version
- Android Studio / VS Code with Flutter extensions
- Git for version control

### Setup Instructions

1. **Clone the Repository**
   ```bash
   git clone https://github.com/your-org/vedanta-trade.git
   cd vedanta-trade
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the Application**
   ```bash
   flutter run
   ```

4. **Build for Release**
   ```bash
   # Android
   flutter build apk --release
   
   # iOS
   flutter build ios --release
   
   # Web
   flutter build web --release
   ```

## 📁 Project Structure

### Overview
The project follows a clean architecture pattern with feature-based organization:

```
vedanta_trade/
├── lib/                          # Main application source
│   ├── main.dart                 # Application entry point
│   ├── app/                      # App-level configuration
│   ├── core/                     # Core shared functionality
│   ├── shared/                   # Shared utilities and widgets
│   ├── features/                 # Feature-based modules
│   └── data/                     # Global data models
├── test/                         # Test files
├── assets/                       # Static assets
├── docs/                         # Documentation
├── scripts/                      # Build and automation scripts
└── tools/                        # Development tools
```

### Core Package (`lib/core/`)
Contains application-wide functionality:

```
core/
├── constants/          # App constants and enums
├── errors/             # Custom error classes
├── network/            # Network configuration and utilities
├── security/           # Security utilities and encryption
├── storage/            # Local storage management
├── theme/              # App themes and styling
├── utils/              # Utility functions and extensions
├── config/             # Configuration management
└── core.dart           # Barrel export
```

### Shared Package (`lib/shared/`)
Reusable components and utilities:

```
shared/
├── widgets/
│   ├── common/         # Common UI components
│   ├── charts/          # Chart and graph widgets
│   ├── forms/           # Form-specific widgets
│   └── loaders/         # Loading and progress widgets
├── themes/             # Theme configurations
├── extensions/         # Dart extensions
├── validators/         # Input validation utilities
└── shared.dart          # Barrel export
```

### Feature Structure
Each feature follows clean architecture principles:

```
features/feature_name/
├── data/
│   ├── models/          # Data models and DTOs
│   ├── repositories/    # Repository implementations
│   ├── services/        # API and external services
│   └── datasources/     # Local and remote data sources
├── domain/
│   ├── entities/        # Business entities
│   ├── repositories/    # Repository interfaces
│   └── usecases/        # Business logic use cases
├── presentation/
│   ├── pages/           # Full-screen pages
│   ├── widgets/         # Feature-specific widgets
│   ├── providers/       # State management
│   └── routes/          # Navigation routes
└── feature_name.dart   # Barrel export
```

## 🔄 Development Workflow

### Branch Strategy
- `main`: Production-ready code
- `develop`: Integration branch for features
- `feature/*`: Feature development branches
- `hotfix/*`: Critical fixes for production

### Code Review Process
1. Create feature branch from `develop`
2. Implement changes following coding standards
3. Write comprehensive tests
4. Submit pull request to `develop`
5. Code review by team members
6. Address feedback and merge

### Commit Guidelines
Use conventional commit format:
```
type(scope): description

feat(auth): add user authentication
fix(inventory): resolve stock calculation bug
docs(readme): update setup instructions
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Code formatting
- `refactor`: Code refactoring
- `test`: Test additions
- `chore`: Maintenance tasks

## 📝 Coding Standards

### Naming Conventions
- **Files**: `snake_case.dart`
- **Directories**: `snake_case`
- **Classes**: `PascalCase`
- **Variables**: `camelCase`
- **Constants**: `SCREAMING_SNAKE_CASE`
- **Private members**: `_camelCase`

### Code Organization
1. Import statements organized by type
2. Class declarations
3. Static properties
4. Instance properties
5. Constructors
6. Methods (public then private)
6. Getters and setters

### Import Order
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
import 'package:vedanta_trade/core/core.dart';

// Shared package
import 'package:vedanta_trade/shared/shared.dart';

// Feature imports
import 'package:vedanta_trade/features/auth/auth.dart';

// Relative imports
import '../widgets/custom_widget.dart';
```

### Documentation Standards
- Public classes and methods require dartdoc comments
- Include parameter descriptions and return types
- Provide usage examples for complex components
- Document business logic in use cases

## 🧪 Testing Guidelines

### Test Structure
```
test/
├── unit/                        # Unit tests
│   ├── core/                   # Core package tests
│   ├── shared/                 # Shared package tests
│   └── features/               # Feature tests
├── widget/                     # Widget tests
├── integration/                # Integration tests
├── e2e/                        # End-to-end tests
└── fixtures/                   # Test data and mocks
```

### Testing Standards
1. **Unit Tests**: Test individual functions and classes
2. **Widget Tests**: Test UI components in isolation
3. **Integration Tests**: Test feature interactions
4. **E2E Tests**: Test complete user flows

### Test Naming
```dart
// Unit tests
test('should return user when valid id provided', () {});
test('should throw exception when invalid id provided', () {});

// Widget tests
testWidgets('should display login form', (tester) async {});
testWidgets('should validate email format', (tester) async {});
```

### Coverage Requirements
- Core package: 90%+ coverage
- Shared package: 85%+ coverage
- Features: 80%+ coverage
- Overall project: 85%+ coverage

## 🔧 Build and Deployment

### Local Development
```bash
# Install dependencies
flutter pub get

# Run in debug mode
flutter run

# Run with specific device
flutter run -d chrome
flutter run -d android
```

### Build Commands
```bash
# Development builds
flutter build apk --debug
flutter build web --debug

# Production builds
flutter build apk --release
flutter build web --release
flutter build ios --release
```

### CI/CD Pipeline
The project uses GitHub Actions for automated:
- Code quality checks
- Unit and widget tests
- Build verification
- Deployment to staging/production

### Environment Configuration
- **Development**: Local development environment
- **Staging**: Pre-production testing
- **Production**: Live application

## 🐛 Troubleshooting

### Common Issues

#### Build Errors
1. **Missing Dependencies**: Run `flutter pub get`
2. **Version Conflicts**: Check pubspec.yaml versions
3. **Import Errors**: Verify file paths and barrel exports

#### Runtime Errors
1. **Null Safety**: Ensure proper null handling
2. **State Management**: Check provider initialization
3. **Network Issues**: Verify API connectivity

#### Performance Issues
1. **Widget Rebuilds**: Optimize with const constructors
2. **Memory Leaks**: Dispose controllers and streams
3. **Large Lists**: Implement lazy loading

### Debugging Tools
- Flutter Inspector for UI debugging
- Dart DevTools for performance analysis
- Logging system for runtime debugging
- Analytics for production monitoring

### Performance Optimization
1. Use `const` constructors where possible
2. Implement proper widget lifecycle management
3. Optimize image loading and caching
4. Use efficient data structures

## 📚 Additional Resources

### Documentation
- [API Documentation](docs/API_DOCUMENTATION.md)
- [Architecture Guide](docs/ARCHITECTURE.md)
- [UI/UX Guidelines](docs/UI_UX_GUIDELINES.md)
- [Database Schema](docs/DATABASE_SCHEMA.md)

### Tools and Scripts
- [Project Organization](scripts/organize_project_structure.dart)
- [Naming Conventions](scripts/naming_conventions_enforcer.dart)
- [Import Updates](scripts/update_imports.dart)
- [Build Automation](tools/build_automation.dart)

### External Resources
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Guide](https://dart.dev/guides)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)

## 🤝 Contributing Guidelines

### Before Contributing
1. Read this development guide
2. Set up local development environment
3. Review existing code and patterns
4. Create issue for significant changes

### Contribution Process
1. Fork the repository
2. Create feature branch
3. Implement changes with tests
4. Ensure code quality standards
5. Submit pull request
6. Address review feedback

### Code Quality Standards
- Follow naming conventions
- Write comprehensive tests
- Document public APIs
- Use consistent formatting
- Optimize for performance

## 📞 Support

For questions or issues:
1. Check existing documentation
2. Search for similar issues
3. Create detailed bug report
4. Contact development team

---

**Last Updated**: ${DateTime.now().toString().split('.')[0]}
**Version**: 1.0.0
**Maintainers**: VedantaTrade Development Team

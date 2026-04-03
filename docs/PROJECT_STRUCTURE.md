# VedantaTrade Project Structure

## Overview

This document defines the standardized directory structure and naming conventions for the VedantaTrade Flutter application.

## Directory Structure

```
lib/
├── app/                          # App-level configurations
│   ├── routes/                   # GoRouter route definitions
│   ├── theme/                    # AppTheme, colors, typography
│   └── app.dart                  # MaterialApp configuration
│
├── core/                         # Core utilities and services
│   ├── constants/                # App constants (API endpoints, etc.)
│   ├── services/                 # Core services (API, GPS, etc.)
│   ├── utils/                    # Utility functions
│   └── extensions/               # Dart extensions
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

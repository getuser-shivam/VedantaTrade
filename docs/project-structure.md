# VedantaTrade Project Structure Documentation

## Overview

This document outlines the standardized and scalable project directory structure for the VedantaTrade pharmaceutical distribution platform. The structure follows clean architecture principles, Flutter best practices, and industry standards for maintainability and scalability.

## Project Root Structure

```
VedantaTrade/
├── lib/                          # Main application source code
├── test/                         # Test files
├── assets/                       # Static assets (images, fonts, etc.)
├── docs/                         # Project documentation
├── scripts/                      # Build and utility scripts
├── .github/                      # GitHub workflows and configuration
├── .dart_tool/                   # Dart tool generated files
├── .vscode/                      # VS Code configuration
├── android/                      # Android platform specific code
├── ios/                          # iOS platform specific code
├── web/                          # Web platform specific code
├── build/                        # Build output directory
├── .gitignore                    # Git ignore file
├── .metadata                    # Flutter metadata
├── pubspec.yaml                  # Flutter dependencies
├── README.md                     # Project overview
├── CHANGELOG.md                  # Version history
├── LICENSE                       # License file
└── TODO.md                       # Project roadmap
```

## Application Source Structure (lib/)

The `lib/` directory follows clean architecture principles with clear separation of concerns:

```
lib/
├── main.dart                     # Application entry point
├── app/                          # Application-level configuration
│   ├── app.dart                  # Main app widget
│   ├── routes/                   # Route definitions
│   ├── theme/                    # App theme and styling
│   └── constants/               # App-wide constants
├── core/                         # Core functionality
│   ├── errors/                   # Custom error classes
│   ├── utils/                    # Utility functions
│   ├── services/                 # Shared services
│   ├── network/                  # Network configuration
│   └── storage/                  # Storage management
├── shared/                       # Shared components
│   ├── widgets/                  # Reusable UI widgets
│   ├── models/                   # Shared data models
│   ├── extensions/               # Dart extensions
│   └── providers/                # Shared state management
└── features/                     # Feature modules
    ├── auth/                     # Authentication feature
    ├── dashboard/                # Dashboard feature
    ├── products/                 # Product catalog feature
    ├── distribution/            # Distribution management
    ├── inventory/                # Inventory management
    ├── orders/                   # Order processing
    ├── campaigns/                # Marketing campaigns
    ├── analytics/                # Analytics and reporting
    ├── profile/                  # User profile
    └── settings/                 # App settings
```

## Feature Module Structure

Each feature module follows a consistent structure for maintainability:

```
features/
├── auth/                         # Authentication feature example
│   ├── domain/                   # Business logic layer
│   │   ├── entities/             # Business entities
│   │   ├── repositories/         # Repository interfaces
│   │   ├── usecases/             # Business use cases
│   │   └── services/            # Domain services
│   ├── data/                     # Data layer
│   │   ├── models/               # Data models
│   │   ├── repositories/         # Repository implementations
│   │   ├── datasources/          # Data sources
│   │   └── mappers/              # Data mappers
│   ├── presentation/             # Presentation layer
│   │   ├── pages/                # Screen widgets
│   │   ├── widgets/              # Feature-specific widgets
│   │   ├── providers/            # State management
│   │   └── controllers/         # View controllers
│   └── tests/                    # Feature tests
│       ├── unit/                 # Unit tests
│       ├── widget/               # Widget tests
│       └── integration/          # Integration tests
```

## Naming Conventions

### Files and Directories

- **Directories**: Use `snake_case` (e.g., `authentication_repository.dart`)
- **Files**: Use `snake_case` with descriptive names (e.g., `user_profile_service.dart`)
- **Dart Files**: 
  - Classes: `PascalCase` (e.g., `AuthenticationRepository`)
  - Functions/Variables: `camelCase` (e.g., `authenticateUser`)
  - Constants: `SCREAMING_SNAKE_CASE` (e.g., `API_BASE_URL`)
  - Private members: Prefix with `_` (e.g., `_privateMethod`)

### Feature Naming

- **Feature Directories**: Use singular nouns (e.g., `auth/`, `product/`, `order/`)
- **Repository Classes**: `[Feature]Repository` (e.g., `AuthenticationRepository`)
- **Use Case Classes**: `[Feature][Action]UseCase` (e.g., `LoginUseCase`)
- **Entity Classes**: `[Feature]Entity` (e.g., `UserEntity`)
- **Model Classes**: `[Feature]Model` (e.g., `UserModel`)
- **Provider Classes**: `[Feature]Provider` (e.g., `AuthenticationProvider`)
- **Screen Classes**: `[Feature]Screen` (e.g., `LoginScreen`)
- **Widget Classes**: `[Feature][Widget]Widget` (e.g., `LoginButtonWidget`)

## Architecture Layers

### 1. Domain Layer (`domain/`)
Contains business logic and is completely independent of frameworks and external dependencies.

```
domain/
├── entities/                     # Business entities
│   ├── user_entity.dart
│   ├── product_entity.dart
│   └── order_entity.dart
├── repositories/                 # Repository interfaces
│   ├── authentication_repository.dart
│   ├── product_repository.dart
│   └── order_repository.dart
├── usecases/                     # Business use cases
│   ├── login_usecase.dart
│   ├── get_products_usecase.dart
│   └── create_order_usecase.dart
└── services/                    # Domain services
    ├── auth_service.dart
    └── notification_service.dart
```

### 2. Data Layer (`data/`)
Handles data persistence, external APIs, and data transformation.

```
data/
├── models/                       # Data transfer objects
│   ├── user_model.dart
│   ├── product_model.dart
│   └── order_model.dart
├── repositories/                 # Repository implementations
│   ├── authentication_repository_impl.dart
│   ├── product_repository_impl.dart
│   └── order_repository_impl.dart
├── datasources/                  # Data sources
│   ├── remote/                   # Remote data sources
│   │   ├── auth_remote_datasource.dart
│   │   └── product_remote_datasource.dart
│   └── local/                    # Local data sources
│       ├── auth_local_datasource.dart
│       └── product_local_datasource.dart
└── mappers/                      # Data mappers
    ├── user_mapper.dart
    ├── product_mapper.dart
    └── order_mapper.dart
```

### 3. Presentation Layer (`presentation/`)
Handles UI components, state management, and user interactions.

```
presentation/
├── pages/                        # Screen widgets
│   ├── login_screen.dart
│   ├── dashboard_screen.dart
│   └── product_list_screen.dart
├── widgets/                      # Feature-specific widgets
│   ├── login_form_widget.dart
│   ├── product_card_widget.dart
│   └── loading_widget.dart
├── providers/                    # State management
│   ├── authentication_provider.dart
│   ├── product_provider.dart
│   └── order_provider.dart
└── controllers/                   # View controllers
    ├── login_controller.dart
    └── product_controller.dart
```

## Shared Components Structure

### Core Services (`core/`)

```
core/
├── errors/                       # Custom error handling
│   ├── exceptions/
│   │   ├── authentication_exception.dart
│   │   ├── network_exception.dart
│   │   └── validation_exception.dart
│   └── failures/
│       ├── authentication_failure.dart
│       └── network_failure.dart
├── utils/                        # Utility functions
│   ├── app_utils.dart
│   ├── date_utils.dart
│   ├── validation_utils.dart
│   └── format_utils.dart
├── services/                     # Shared services
│   ├── storage_service.dart
│   ├── network_service.dart
│   ├── notification_service.dart
│   └── analytics_service.dart
├── network/                      # Network configuration
│   ├── api_client.dart
│   ├── interceptors.dart
│   └── api_endpoints.dart
└── storage/                      # Storage management
    ├── secure_storage.dart
    ├── cache_storage.dart
    └── database_storage.dart
```

### Shared Widgets (`shared/widgets/`)

```
shared/widgets/
├── forms/                        # Form widgets
│   ├── text_input_widget.dart
│   ├── dropdown_widget.dart
│   └── date_picker_widget.dart
├── buttons/                      # Button widgets
│   ├── primary_button_widget.dart
│   ├── secondary_button_widget.dart
│   └── icon_button_widget.dart
├── cards/                        # Card widgets
│   ├── product_card_widget.dart
│   ├── user_card_widget.dart
│   └── order_card_widget.dart
├── dialogs/                      # Dialog widgets
│   ├── confirmation_dialog.dart
│   ├── error_dialog.dart
│   └── success_dialog.dart
└── layouts/                      # Layout widgets
    ├── app_scaffold.dart
    ├── page_layout.dart
    └── section_layout.dart
```

## Test Structure

### Test Organization

```
test/
├── unit/                         # Unit tests
│   ├── core/
│   │   ├── utils/
│   │   ├── services/
│   │   └── errors/
│   └── features/
│       ├── auth/
│       ├── products/
│       └── orders/
├── widget/                       # Widget tests
│   ├── shared/
│   │   ├── widgets/
│   │   └── forms/
│   └── features/
│       ├── auth/
│       ├── products/
│       └── orders/
├── integration/                  # Integration tests
│   ├── auth_flow_test.dart
│   ├── product_flow_test.dart
│   └── order_flow_test.dart
├── e2e/                          # End-to-end tests
│   ├── app_test.dart
│   ├── auth_test.dart
│   └── product_test.dart
└── test_utils/                   # Test utilities
    ├── mock_data.dart
    ├── test_helpers.dart
    └── widget_test_utils.dart
```

## Asset Structure

### Asset Organization

```
assets/
├── images/                       # Image assets
│   ├── logos/
│   ├── icons/
│   ├── illustrations/
│   └── backgrounds/
├── fonts/                        # Font files
│   ├── primary/
│   ├── secondary/
│   └── icons/
├── animations/                   # Animation files
│   ├── lottie/
│   └── rive/
└── data/                         # Static data files
    ├── json/
    ├── csv/
    └── config/
```

## Configuration Structure

### App Configuration

```
app/
├── app.dart                      # Main app widget
├── constants/                    # App constants
│   ├── app_constants.dart
│   ├── api_constants.dart
│   ├── theme_constants.dart
│   └── route_constants.dart
├── theme/                        # App theme
│   ├── app_theme.dart
│   ├── light_theme.dart
│   ├── dark_theme.dart
│   └── text_styles.dart
├── routes/                       # Route configuration
│   ├── app_router.dart
│   ├── route_names.dart
│   └── route_guards.dart
└── localization/                 # Localization
    ├── app_localizations.dart
    ├── en/
    ├── ne/
    └── hi/
```

## Best Practices

### 1. File Organization
- Keep related files together in logical groups
- Use index files to export multiple related files
- Avoid deeply nested directory structures (max 3-4 levels)
- Use descriptive names that clearly indicate purpose

### 2. Import Organization
- Group imports by type (dart, flutter, packages, local)
- Use relative imports for files within the same feature
- Use absolute imports for shared components
- Keep import statements organized and clean

### 3. Dependency Management
- Keep dependencies in `pubspec.yaml` organized by category
- Use dependency injection for better testability
- Avoid circular dependencies between modules
- Keep feature modules as independent as possible

### 4. Code Organization
- Follow single responsibility principle
- Keep classes and functions focused and small
- Use meaningful names for variables and functions
- Add comprehensive documentation for complex logic

### 5. Testing Strategy
- Write tests for all business logic in the domain layer
- Test UI components in the presentation layer
- Mock external dependencies in tests
- Maintain high test coverage for critical features

## Migration Guidelines

When migrating existing code to this structure:

1. **Analyze Current Structure**: Identify existing files and their purposes
2. **Plan Migration**: Create a migration plan for each feature
3. **Move Gradually**: Migrate one feature at a time
4. **Update Imports**: Fix all import references
5. **Run Tests**: Ensure all tests pass after migration
6. **Update Documentation**: Keep documentation current

## Maintenance Guidelines

To maintain the project structure:

1. **Regular Reviews**: Periodically review adherence to structure
2. **Code Reviews**: Include structure compliance in code reviews
3. **Automated Checks**: Use linting rules to enforce naming conventions
4. **Documentation Updates**: Update docs when structure changes
5. **Team Training**: Ensure team members understand the structure

This standardized structure provides a solid foundation for the VedantaTrade project, ensuring scalability, maintainability, and collaboration efficiency.

# VedantaTrade - Project Structure & Organization Guide

## 📁 Standardized Directory Structure

### Backend Structure (Node.js/TypeScript)
```
backend/
├── src/
│   ├── controllers/           # Request handlers and business logic
│   │   ├── auth.controller.ts
│   │   ├── distribution.controller.ts
│   │   ├── inventory.controller.ts
│   │   ├── marketing.controller.ts
│   │   └── analytics.controller.ts
│   ├── middleware/            # Express middleware
│   │   ├── auth.middleware.ts
│   │   ├── validation.middleware.ts
│   │   ├── error.middleware.ts
│   │   └── rate-limit.middleware.ts
│   ├── routes/              # Route definitions
│   │   ├── auth.routes.ts
│   │   ├── distribution.routes.ts
│   │   ├── inventory.routes.ts
│   │   ├── marketing.routes.ts
│   │   └── analytics.routes.ts
│   ├── services/             # Business logic and external services
│   │   ├── auth.service.ts
│   │   ├── distribution.service.ts
│   │   ├── inventory.service.ts
│   │   ├── marketing.service.ts
│   │   ├── analytics.service.ts
│   │   └── websocket.service.ts
│   ├── models/              # Data models and interfaces
│   │   ├── user.model.ts
│   │   ├── distribution.model.ts
│   │   ├── inventory.model.ts
│   │   └── marketing.model.ts
│   ├── database/             # Database configuration and utilities
│   │   ├── connection.ts
│   │   ├── migrations/
│   │   └── seeds/
│   ├── types/                # TypeScript type definitions
│   │   ├── auth.types.ts
│   │   ├── distribution.types.ts
│   │   └── common.types.ts
│   ├── utils/                # Utility functions
│   │   ├── logger.ts
│   │   ├── validation.ts
│   │   └── helpers.ts
│   ├── config/               # Configuration files
│   │   ├── database.config.ts
│   │   ├── jwt.config.ts
│   │   └── app.config.ts
│   └── tests/               # Test files
│       ├── unit/
│       ├── integration/
│       └── e2e/
├── prisma/                  # Prisma ORM files
│   ├── schema.prisma
│   ├── migrations/
│   └── seeds/
├── docs/                    # Documentation
├── scripts/                 # Build and deployment scripts
└── logs/                    # Log files
```

### Frontend Structure (Flutter)
```
lib/
├── app/                     # App-level configuration
│   ├── app.dart
│   ├── routes/
│   │   ├── app_routes.dart
│   │   └── route_names.dart
│   └── theme/
│       ├── app_theme.dart
│       └── colors.dart
├── core/                    # Core functionality
│   ├── constants/
│   │   ├── api_constants.dart
│   │   └── app_constants.dart
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/
│   │   ├── api_client.dart
│   │   └── network_info.dart
│   ├── utils/
│   │   ├── logger.dart
│   │   ├── validators.dart
│   │   └── helpers.dart
│   └── services/
│       ├── storage_service.dart
│       └── notification_service.dart
├── features/                # Feature-based organization
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── pages/
│   │       ├── widgets/
│   │       └── providers/
│   ├── distribution/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── distribution_remote_datasource.dart
│   │   │   │   └── websocket_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── distribution_center_model.dart
│   │   │   │   ├── inventory_allocation_model.dart
│   │   │   │   └── marketing_campaign_model.dart
│   │   │   └── repositories/
│   │   │       └── distribution_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── distribution_center.dart
│   │   │   │   ├── inventory_allocation.dart
│   │   │   │   └── marketing_campaign.dart
│   │   │   ├── repositories/
│   │   │   │   └── distribution_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_distribution_centers.dart
│   │   │       ├── allocate_inventory.dart
│   │   │       └── create_campaign.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── distribution_dashboard_page.dart
│   │       │   ├── inventory_management_page.dart
│   │       │   └── marketing_campaigns_page.dart
│   │       ├── widgets/
│   │       │   ├── distribution_center_card.dart
│   │       │   ├── inventory_allocation_card.dart
│   │       │   └── campaign_card.dart
│   │       └── providers/
│   │           ├── distribution_provider.dart
│   │           └── marketing_provider.dart
│   ├── catalog/
│   ├── analytics/
│   └── shared/
│       ├── data/
│       ├── domain/
│       └── presentation/
│           ├── widgets/
│           │   ├── custom_button.dart
│           │   ├── custom_text_field.dart
│           │   ├── loading_widget.dart
│           │   └── error_widget.dart
│           └── providers/
│               └── app_provider.dart
├── main.dart                # App entry point
└── generated/               # Auto-generated files
```

## 📝 Naming Conventions

### File Naming

#### TypeScript/JavaScript Files
- **Use kebab-case for files**: `auth-service.ts`, `distribution-controller.ts`
- **Use descriptive names**: `user-authentication.service.ts` (not just `auth.ts`)
- **Test files**: `auth.service.test.ts`, `distribution.controller.integration.test.ts`
- **Configuration files**: `database.config.ts`, `jwt.config.ts`

#### Dart Files
- **Use snake_case for files**: `distribution_center_model.dart`, `auth_provider.dart`
- **Pages**: `distribution_dashboard_page.dart`
- **Widgets**: `distribution_center_card.dart`, `custom_button.dart`
- **Test files**: `distribution_provider_test.dart`

### Class/Interface Naming

#### TypeScript
- **Use PascalCase for classes and interfaces**: `DistributionCenter`, `InventoryAllocation`
- **Prefix interfaces with 'I'**: `IDistributionRepository`, `IAuthService`
- **Use descriptive names**: `DistributionCenterService` (not just `Service`)

#### Dart
- **Use PascalCase for classes**: `DistributionCenter`, `InventoryAllocation`
- **Use descriptive names**: `DistributionCenterModel`, `InventoryAllocationProvider`

### Variable/Function Naming

#### TypeScript
- **Use camelCase for variables and functions**: `distributionCenter`, `getDistributionCenters`
- **Use descriptive names**: `userAuthenticationService` (not just `auth`)
- **Boolean variables**: `isActive`, `hasPermission`, `isLoading`
- **Constants**: `UPPER_SNAKE_CASE`: `API_BASE_URL`, `MAX_RETRY_ATTEMPTS`

#### Dart
- **Use camelCase for variables and functions**: `distributionCenter`, `getDistributionCenters`
- **Use descriptive names**: `userAuthenticationService`
- **Boolean variables**: `isActive`, `hasPermission`, `isLoading`
- **Constants**: `UPPER_SNAKE_CASE`: `apiBaseUrl`, `maxRetryAttempts`

### API Endpoint Naming

- **Use RESTful conventions**:
  - `GET /api/distribution/centers` - Get all centers
  - `GET /api/distribution/centers/:id` - Get specific center
  - `POST /api/distribution/centers` - Create center
  - `PUT /api/distribution/centers/:id` - Update center
  - `DELETE /api/distribution/centers/:id` - Delete center
- **Use plural nouns for collections**: `centers`, `products`, `campaigns`
- **Use descriptive names**: `inventory/allocate`, `inventory/transfer`

### Database Naming

- **Use snake_case for table names**: `distribution_centers`, `inventory_allocations`
- **Use snake_case for column names**: `created_at`, `updated_at`, `user_id`
- **Use descriptive names**: `distribution_center_id` (not just `center_id`)
- **Use consistent prefixes**: `is_` for booleans, `_id` for foreign keys

### Component Naming

#### Flutter Widgets
- **Use descriptive names**: `DistributionCenterCard`, `InventoryAllocationWidget`
- **Prefix custom widgets**: `CustomButton`, `CustomTextField`
- **Use consistent suffixes**: `Page`, `Card`, `Widget`, `Provider`, `Model`

## 🗂️ Organization Rules

### 1. Feature-Based Structure
- Group related files by feature, not by type
- Each feature has its own data, domain, and presentation layers
- Shared functionality goes in the `shared/` directory

### 2. Separation of Concerns
- **Data Layer**: Handles data sources, models, and repositories
- **Domain Layer**: Contains business logic, entities, and use cases
- **Presentation Layer**: Manages UI, widgets, and state management

### 3. Import Organization
- Group imports by type: external, internal, relative
- Use absolute imports where possible
- Avoid circular dependencies

### 4. File Size Management
- Keep files under 300 lines when possible
- Split large files into smaller, focused modules
- Use barrel exports for cleaner imports

### 5. Documentation
- Add JSDoc comments for public APIs
- Document complex business logic
- Keep README files in major directories

## 🔄 Migration Plan

### Phase 1: Backend Reorganization
1. Create new directory structure
2. Move files to appropriate locations
3. Update import paths
4. Update route definitions
5. Test all endpoints

### Phase 2: Frontend Reorganization
1. Create feature-based directory structure
2. Move files to appropriate locations
3. Update import paths
4. Update provider registrations
5. Test all screens

### Phase 3: Cleanup
1. Remove duplicate/unused files
2. Update documentation
3. Update build scripts
4. Run comprehensive tests

## 📋 Checklist

### Before Committing
- [ ] File names follow conventions
- [ ] Class names follow conventions
- [ ] Variable names follow conventions
- [ ] Import statements are organized
- [ ] No circular dependencies
- [ ] All tests pass
- [ ] Documentation is updated

### Code Review Points
- [ ] Consistent naming throughout the file
- [ ] Descriptive and meaningful names
- [ ] No abbreviations unless widely understood
- [ ] Proper separation of concerns
- [ ] Correct directory placement

## 🛠️ Tools & Scripts

### Automated Organization
- ESLint rules for naming conventions
- Prettier for consistent formatting
- Pre-commit hooks for validation
- Scripts for file organization

### Documentation Generation
- Automatic API documentation
- Component documentation
- Architecture diagrams

This structure ensures maintainability, scalability, and ease of navigation for the VedantaTrade project.

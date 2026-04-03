# VedantaTrade - Naming Conventions Guide

## 📋 Overview

This document establishes consistent naming conventions across the entire VedantaTrade project to ensure maintainability, readability, and developer productivity.

## 🎯 Core Principles

1. **Clarity**: Names should clearly describe what they represent
2. **Consistency**: Same naming patterns across similar elements
3. **Brevity**: Keep names concise but descriptive
4. **Language**: Use English for all naming
5. **Context**: Names should be meaningful within their context

## 📁 File Naming Conventions

### Backend (TypeScript/JavaScript)

| File Type | Convention | Examples |
|------------|-------------|-----------|
| Controllers | kebab-case with `.controller.ts` suffix | `auth.controller.ts`, `distribution.controller.ts` |
| Services | kebab-case with `.service.ts` suffix | `auth.service.ts`, `distribution.service.ts` |
| Models | kebab-case with `.model.ts` suffix | `user.model.ts`, `distribution-center.model.ts` |
| Routes | kebab-case with `.routes.ts` suffix | `auth.routes.ts`, `distribution.routes.ts` |
| Middleware | kebab-case with `.middleware.ts` suffix | `auth.middleware.ts`, `validation.middleware.ts` |
| Types | kebab-case with `.types.ts` suffix | `auth.types.ts`, `distribution.types.ts` |
| Utils | kebab-case with `.ts` suffix | `logger.ts`, `validation.ts` |
| Config | kebab-case with `.config.ts` suffix | `database.config.ts`, `jwt.config.ts` |
| Tests | kebab-case with `.test.ts` or `.spec.ts` suffix | `auth.service.test.ts`, `distribution.controller.spec.ts` |

### Frontend (Dart)

| File Type | Convention | Examples |
|------------|-------------|-----------|
| Pages | snake_case with `_page.dart` suffix | `distribution_dashboard_page.dart`, `login_page.dart` |
| Widgets | snake_case with `.dart` suffix | `distribution_center_card.dart`, `custom_button.dart` |
| Models | snake_case with `_model.dart` suffix | `user_model.dart`, `distribution_center_model.dart` |
| Providers | snake_case with `_provider.dart` suffix | `auth_provider.dart`, `distribution_provider.dart` |
| Services | snake_case with `_service.dart` suffix | `api_service.dart`, `storage_service.dart` |
| Repositories | snake_case with `_repository.dart` suffix | `auth_repository.dart`, `distribution_repository.dart` |
| Use Cases | snake_case with `_usecase.dart` suffix | `login_usecase.dart`, `get_distribution_centers_usecase.dart` |
| Entities | snake_case with `_entity.dart` suffix | `user_entity.dart`, `distribution_center_entity.dart` |
| Tests | snake_case with `_test.dart` suffix | `auth_provider_test.dart`, `distribution_service_test.dart` |

## 🏷️ Variable and Function Naming

### TypeScript/JavaScript

| Element | Convention | Examples |
|----------|-------------|-----------|
| Variables | camelCase | `userName`, `distributionCenter`, `isActive` |
| Functions | camelCase with verb prefix | `getUser()`, `createDistributionCenter()`, `validateInput()` |
| Classes | PascalCase | `UserService`, `DistributionCenter`, `InventoryAllocation` |
| Interfaces | PascalCase with 'I' prefix | `IUserService`, `IDistributionRepository` |
| Constants | UPPER_SNAKE_CASE | `API_BASE_URL`, `MAX_RETRY_ATTEMPTS`, `DEFAULT_PAGE_SIZE` |
| Enums | PascalCase | `UserRole`, `DistributionStatus`, `InventoryType` |
| Boolean variables | camelCase with is/has/can prefix | `isActive`, `hasPermission`, `canEdit` |

### Dart

| Element | Convention | Examples |
|----------|-------------|-----------|
| Variables | camelCase | `userName`, `distributionCenter`, `isActive` |
| Functions | camelCase with verb prefix | `getUser()`, `createDistributionCenter()`, `validateInput()` |
| Classes | PascalCase | `UserService`, `DistributionCenter`, `InventoryAllocation` |
| Constants | UPPER_SNAKE_CASE | `apiBaseUrl`, `maxRetryAttempts`, `defaultPageSize` |
| Enums | PascalCase | `UserRole`, `DistributionStatus`, `InventoryType` |
| Boolean variables | camelCase with is/has/can prefix | `isActive`, `hasPermission`, `canEdit` |
| Private members | camelCase with underscore prefix | `_privateMethod()`, `_privateVariable` |

## 🗄️ Database Naming Conventions

### Tables and Columns

| Element | Convention | Examples |
|----------|-------------|-----------|
| Table names | snake_case, plural | `users`, `distribution_centers`, `inventory_allocations` |
| Column names | snake_case | `user_id`, `created_at`, `updated_at`, `is_active` |
| Primary keys | table_name + `_id` | `user_id`, `distribution_center_id` |
| Foreign keys | referenced_table + `_id` | `user_id`, `distribution_center_id` |
| Boolean columns | is_ prefix | `is_active`, `is_verified`, `is_deleted` |
| Timestamp columns | _at suffix | `created_at`, `updated_at`, `deleted_at` |
| JSON columns | _json suffix | `metadata_json`, `settings_json` |

### Indexes and Constraints

| Element | Convention | Examples |
|----------|-------------|-----------|
| Indexes | idx_table_name_column_name | `idx_users_email`, `idx_distribution_centers_code` |
| Foreign key constraints | fk_table_column_reference | `fk_inventory_allocations_product_id` |
| Unique constraints | uk_table_column | `uk_users_email`, `uk_distribution_centers_code` |

## 🌐 API Endpoint Naming Conventions

### RESTful API

| Method | Pattern | Examples |
|---------|----------|----------|
| GET | `/api/resource` | `GET /api/distribution/centers` |
| GET | `/api/resource/:id` | `GET /api/distribution/centers/123` |
| POST | `/api/resource` | `POST /api/distribution/centers` |
| PUT | `/api/resource/:id` | `PUT /api/distribution/centers/123` |
| DELETE | `/api/resource/:id` | `DELETE /api/distribution/centers/123` |
| GET | `/api/resource/search` | `GET /api/distribution/centers/search` |
| POST | `/api/resource/action` | `POST /api/inventory/allocate`, `POST /api/inventory/transfer` |

### Query Parameters

| Parameter | Convention | Examples |
|------------|-------------|-----------|
| Pagination | `page`, `limit` | `?page=1&limit=20` |
| Sorting | `sort_by`, `order` | `?sort_by=name&order=asc` |
| Filtering | `filter_by`, `filter_value` | `?filter_by=status&filter_value=active` |
| Search | `search`, `q` | `?search=mumbai`, `?=distribution` |

## 📱 Component Naming Conventions

### Flutter Components

| Component Type | Convention | Examples |
|----------------|-------------|-----------|
| Pages | PascalCase + Page | `DistributionDashboardPage`, `LoginPage` |
| Widgets | PascalCase + Widget | `DistributionCenterCard`, `CustomButton` |
| Custom Widgets | PascalCase + Custom + Type | `CustomTextField`, `CustomDatePicker` |
| State Widgets | PascalCase + State | `DistributionDashboardPageState` |
| Provider Classes | PascalCase + Provider | `DistributionProvider`, `AuthProvider` |

### Component Files

| Component | File Name | Example |
|------------|-------------|---------|
| Page Widget | snake_case + `_page.dart` | `distribution_dashboard_page.dart` |
| Custom Widget | snake_case + `.dart` | `distribution_center_card.dart` |
| Provider | snake_case + `_provider.dart` | `distribution_provider.dart` |
| Model | snake_case + `_model.dart` | `distribution_center_model.dart` |

## 🔧 Configuration and Environment

### Environment Variables

| Variable Type | Convention | Examples |
|----------------|-------------|-----------|
| Database | DB_ + UPPER_SNAKE_CASE | `DB_HOST`, `DB_PORT`, `DB_NAME` |
| API | API_ + UPPER_SNAKE_CASE | `API_BASE_URL`, `API_VERSION`, `API_TIMEOUT` |
| JWT | JWT_ + UPPER_SNAKE_CASE | `JWT_SECRET`, `JWT_EXPIRES_IN` |
| App | APP_ + UPPER_SNAKE_CASE | `APP_NAME`, `APP_ENV`, `APP_PORT` |

### Configuration Files

| Config Type | Convention | Examples |
|--------------|-------------|-----------|
| Database | `database.config.ts` | `database.config.ts` |
| Server | `server.config.ts` | `server.config.ts` |
| Authentication | `auth.config.ts` | `auth.config.ts` |
| Environment | `.env.development`, `.env.production` | `.env.development` |

## 📝 Documentation Naming

| Document Type | Convention | Examples |
|----------------|-------------|-----------|
| README | `README.md` | `README.md` |
| API Docs | `API_DOCUMENTATION.md` | `API_DOCUMENTATION.md` |
| Technical Specs | `TECHNICAL_SPECIFICATIONS.md` | `TECHNICAL_SPECIFICATIONS.md` |
| User Guides | `USER_GUIDE.md` | `USER_GUIDE.md` |
| Changelog | `CHANGELOG.md` | `CHANGELOG.md` |

## 🧪 Testing Naming Conventions

### Test Files

| Test Type | Convention | Examples |
|------------|-------------|-----------|
| Unit Tests | `filename.test.ts` | `auth.service.test.ts` |
| Integration Tests | `filename.integration.test.ts` | `auth.service.integration.test.ts` |
| End-to-End Tests | `filename.e2e.test.ts` | `user-login.e2e.test.ts` |
| Widget Tests | `filename_test.dart` | `distribution_center_card_test.dart` |
| Integration Tests (Flutter) | `filename_integration_test.dart` | `distribution_screen_integration_test.dart` |

### Test Functions

| Test Type | Convention | Examples |
|------------|-------------|-----------|
| Unit Tests | `should + expected behavior` | `shouldCreateUserSuccessfully()`, `shouldReturnErrorForInvalidInput()` |
| Integration Tests | `should + expected behavior` | `shouldCompleteLoginFlow()`, `shouldHandleNetworkError()` |
| Widget Tests | `should + expected behavior` | `shouldDisplayCorrectTitle()`, `shouldCallCallbackOnTap()` |

## 🔄 Git Branch and Commit Naming

### Branch Names

| Branch Type | Convention | Examples |
|--------------|-------------|-----------|
| Feature | `feature/feature-name` | `feature/distribution-management` |
| Bugfix | `bugfix/bug-description` | `bugfix/inventory-allocation-error` |
| Hotfix | `hotfix/urgent-fix` | `hotfix/security-vulnerability` |
| Release | `release/version-number` | `release/v1.2.0` |

### Commit Messages

| Commit Type | Convention | Examples |
|-------------|-------------|-----------|
| Feature | `feat: description` | `feat: add distribution center management` |
| Bugfix | `fix: description` | `fix: resolve inventory allocation issue` |
| Documentation | `docs: description` | `docs: update API documentation` |
| Style | `style: description` | `style: format code with prettier` |
| Refactor | `refactor: description` | `refactor: simplify authentication flow` |
| Test | `test: description` | `test: add unit tests for distribution service` |

## 📦 Package and Module Naming

### Node.js Packages

| Package Type | Convention | Examples |
|--------------|-------------|-----------|
| Main Package | kebab-case | `@vedantatrade/core`, `@vedantatrade/utils` |
| Utils Package | kebab-case + utils | `@vedantatrade/auth-utils`, `@vedantatrade/api-utils` |
| Type Package | kebab-case + types | `@vedantatrade/auth-types`, `@vedantatrade/api-types` |

### Dart Packages

| Package Type | Convention | Examples |
|--------------|-------------|-----------|
| Main Package | snake_case | `vedantatrade_core`, `vedantatrade_utils` |
| Feature Package | snake_case + feature | `vedantatrade_distribution`, `vedantatrade_auth` |

## 🎨 UI/UX Naming

### CSS/Style Classes

| Class Type | Convention | Examples |
|------------|-------------|-----------|
| Component | BEM - Block__Element--Modifier | `.distribution-center__header--active` |
| Utility | kebab-case with u- prefix | `.u-text-center`, `.u-margin-top` |
| Layout | kebab-case with l- prefix | `.l-container`, `.l-grid` |

### Flutter Theme Names

| Theme Element | Convention | Examples |
|---------------|-------------|-----------|
| Colors | PascalCase + Color | `primaryColor`, `secondaryColor`, `accentColor` |
| Text Styles | PascalCase + TextStyle | `headlineTextStyle`, `bodyTextStyle` |
| Sizes | PascalCase + Size | `smallPadding`, `mediumMargin`, `largeBorderRadius` |

## ✅ Validation Rules

### Automated Checks

1. **File Name Validation**: Enforce naming conventions via linting rules
2. **Import Organization**: Group and sort imports automatically
3. **Variable Naming**: ESLint/Dart analyzer rules for naming patterns
4. **API Endpoint Validation**: Ensure RESTful naming patterns
5. **Database Naming**: Validate table and column naming conventions

### Manual Checklist

- [ ] File names follow appropriate convention
- [ ] Variable names are descriptive and follow camelCase
- [ ] Class names use PascalCase
- [ ] Constants use UPPER_SNAKE_CASE
- [ ] Boolean variables use is/has/can prefix
- [ ] API endpoints follow RESTful patterns
- [ ] Database tables use snake_case and are plural
- [ ] Test files follow naming conventions
- [ ] Commit messages follow conventional format

## 🚀 Migration Strategy

### Phase 1: Setup
1. Configure linting rules for naming conventions
2. Set up automated validation scripts
3. Create pre-commit hooks for enforcement

### Phase 2: Backend Migration
1. Rename files to follow conventions
2. Update variable and function names
3. Refactor API endpoints
4. Update database schema naming

### Phase 3: Frontend Migration
1. Rename Dart files to follow conventions
2. Update class and variable names
3. Refactor widget naming
4. Update provider and model names

### Phase 4: Documentation
1. Update all documentation
2. Create style guides
3. Train team on conventions
4. Establish review processes

This naming conventions guide ensures consistency, maintainability, and clarity across the entire VedantaTrade project.

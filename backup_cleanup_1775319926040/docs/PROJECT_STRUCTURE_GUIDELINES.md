# VedantaTrade Project Structure & Naming Conventions

## Overview
This document defines the standardized project structure and naming conventions for the VedantaTrade Flutter application to ensure maintainability, scalability, and consistency across the codebase.

## 📁 Project Structure Guidelines

### Root Directory Structure
```
lib/
├── app/                    # App-level configuration
├── core/                   # Core utilities and constants
├── data/                   # Global data layer
├── features/               # Feature-based modules
├── shared/                 # Shared widgets and utilities
└── main.dart              # App entry point
```

### Feature Directory Structure
Each feature should follow this standardized Clean Architecture pattern:

```
features/
└── feature_name/           # snake_case directory name
    ├── data/               # Data layer
    │   ├── datasources/    # Remote/local data sources
    │   ├── models/         # Data transfer objects
    │   └── repositories/    # Repository implementations
    ├── domain/             # Business logic
    │   ├── entities/       # Business objects
    │   ├── repositories/   # Repository interfaces
    │   └── usecases/       # Business use cases
    ├── presentation/       # UI layer
    │   ├── providers/     # State management
    │   ├── screens/       # Full-screen widgets
    │   └── widgets/       # Reusable UI components
    └── feature_name.dart   # Public exports
```

## 📝 Naming Conventions

### Files and Directories

#### 1. Directory Names
- **Rule**: Use `snake_case` for all directory names
- **Examples**:
  - ✅ `user_profile/`
  - ✅ `order_management/`
  - ✅ `inventory_tracking/`
  - ❌ `UserProfile/`
  - ❌ `orderManagement/`

#### 2. File Names
- **Rule**: Use `snake_case.dart` for all Dart files
- **Examples**:
  - ✅ `user_profile_screen.dart`
  - ✅ `order_repository.dart`
  - ✅ `product_list_widget.dart`
  - ❌ `UserProfileScreen.dart`
  - ❌ `orderRepository.dart`

#### 3. Feature Export Files
- **Rule**: Use feature directory name + `.dart`
- **Examples**:
  - ✅ `user_profile/user_profile.dart`
  - ✅ `order_management/order_management.dart`
  - ❌ `user_profile/exports.dart`

### Code Naming

#### 1. Classes and Types
- **Rule**: Use `PascalCase` for classes, enums, and typedefs
- **Examples**:
  ```dart
  class UserProfileScreen extends StatelessWidget {}
  enum OrderStatus { pending, completed, cancelled }
  typedef UserId = String;
  ```

#### 2. Variables and Functions
- **Rule**: Use `camelCase` for variables and functions
- **Examples**:
  ```dart
  String userName = 'John';
  void loadUserData() {}
  final List<Order> pendingOrders = [];
  ```

#### 3. Constants
- **Rule**: Use `SCREAMING_SNAKE_CASE` for constants
- **Examples**:
  ```dart
  const String API_BASE_URL = 'https://api.vedantatrade.com';
  const int MAX_RETRY_ATTEMPTS = 3;
  ```

#### 4. Private Members
- **Rule**: Prefix with underscore `_` for private members
- **Examples**:
  ```dart
  class UserProfileProvider {
    String _userName;
    void _loadUserData() {}
  }
  ```

### Widget Naming

#### 1. Screen Widgets
- **Rule**: Use `[Feature]Screen` pattern
- **Examples**:
  - ✅ `UserProfileScreen`
  - ✅ `OrderListScreen`
  - ✅ `ProductDetailScreen`
  - ❌ `UserProfile`
  - ❌ `user_profile_screen`

#### 2. Provider/Controller Classes
- **Rule**: Use `[Feature]Provider` or `[Feature]Controller`
- **Examples**:
  - ✅ `UserProfileProvider`
  - ✅ `OrderManagementProvider`
  - ❌ `UserProfile`
  - ❌ `userProfileProvider`

#### 3. Reusable Widgets
- **Rule**: Use descriptive names with `Widget` suffix
- **Examples**:
  - ✅ `CustomButtonWidget`
  - ✅ `ProductCardWidget`
  - ✅ `LoadingIndicatorWidget`
  - ❌ `Button`
  - ❌ `productCard`

### Model and Entity Naming

#### 1. Data Models
- **Rule**: Use `[Entity]Model` pattern
- **Examples**:
  - ✅ `UserModel`
  - ✅ `OrderModel`
  - ✅ `ProductModel`

#### 2. Domain Entities
- **Rule**: Use `[Entity]` pattern
- **Examples**:
  - ✅ `User`
  - ✅ `Order`
  - ✅ `Product`

#### 3. Repository Classes
- **Rule**: Use `[Entity]Repository` pattern
- **Examples**:
  - ✅ `UserRepository`
  - ✅ `OrderRepository`
  - ✅ `ProductRepository`

### Service Naming

#### 1. API Services
- **Rule**: Use `[Feature]Service` pattern
- **Examples**:
  - ✅ `AuthService`
  - ✅ `OrderService`
  - ✅ `ProductService`

#### 2. Use Cases
- **Rule**: Use `[Action][Entity]UseCase` pattern
- **Examples**:
  - ✅ `GetUserUseCase`
  - ✅ `CreateOrderUseCase`
  - ✅ `UpdateProductUseCase`

## 🔄 Migration Strategy

### Phase 1: Directory Structure
1. Reorganize existing features to follow the standard structure
2. Move misplaced files to correct directories
3. Create missing directories

### Phase 2: File Naming
1. Rename all files to `snake_case.dart` format
2. Update feature export files
3. Ensure consistent naming patterns

### Phase 3: Code Refactoring
1. Update class names to follow conventions
2. Refactor variable and function names
3. Standardize widget and provider naming

### Phase 4: Import Updates
1. Update all import statements
2. Fix broken references
3. Verify functionality

## 📋 Current Issues Identified

### Structural Issues
1. **Inconsistent Directory Names**: Mix of snake_case and PascalCase
2. **Misplaced Files**: Some files in wrong directories
3. **Missing Standard Structure**: Some features don't follow Clean Architecture

### Naming Issues
1. **File Names**: Mix of snake_case and PascalCase
2. **Class Names**: Inconsistent patterns
3. **Widget Names**: Missing standardized suffixes

### Examples of Issues Found
```
❌ Current Issues:
├── features/
│   ├── accountant/                 # ✅ Good
│   ├── doctors_list/              # ✅ Good
│   ├── user_profile/              # ✅ Good
│   └── UserProfile/               # ❌ Should be user_profile
│       ├── UserProfileScreen.dart # ❌ Should be user_profile_screen.dart
│       └── userProfile.dart       # ✅ Good
```

## 🎯 Implementation Checklist

### Directory Structure
- [ ] All feature directories use `snake_case`
- [ ] Each feature has standard Clean Architecture structure
- [ ] All files are in correct directories

### File Naming
- [ ] All Dart files use `snake_case.dart` format
- [ ] Feature export files follow naming convention
- [ ] No duplicate or conflicting file names

### Code Naming
- [ ] Classes use `PascalCase`
- [ ] Variables and functions use `camelCase`
- [ ] Constants use `SCREAMING_SNAKE_CASE`
- [ ] Private members use `_` prefix

### Widget Naming
- [ ] Screen widgets use `[Feature]Screen` pattern
- [ ] Providers use `[Feature]Provider` pattern
- [ ] Reusable widgets have `Widget` suffix

### Documentation
- [ ] All public APIs are documented
- [ ] Complex business logic has comments
- [ ] Architecture decisions are documented

## 📚 Best Practices

### 1. Consistency
- Always follow the established conventions
- Use the same naming patterns across the entire project
- Keep file and directory names descriptive but concise

### 2. Clarity
- Names should clearly indicate purpose and functionality
- Avoid abbreviations unless widely understood
- Use meaningful names that don't require comments

### 3. Maintainability
- Keep related files grouped together
- Use feature-based organization
- Make it easy for new developers to understand the structure

### 4. Scalability
- Structure should accommodate future features
- Avoid deep nesting of directories
- Keep the architecture flexible for changes

## 🔍 Validation Tools

### Automated Checks
1. Use linting rules to enforce naming conventions
2. Implement pre-commit hooks for file naming
3. Use IDE plugins for consistent formatting

### Manual Review
1. Regular code reviews for naming consistency
2. Architecture review meetings
3. Documentation updates when structure changes

---

*This document should be updated whenever the project structure or naming conventions change.*

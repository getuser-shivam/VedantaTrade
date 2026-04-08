# VedantaTrade - Naming Conventions Guide

## Overview

This document establishes standardized naming conventions for the VedantaTrade project to ensure consistency, readability, and maintainability across all code, files, and directories.

## General Principles

1. **Be Descriptive**: Names should clearly indicate purpose and functionality
2. **Be Consistent**: Use the same naming pattern throughout the project
3. **Follow Standards**: Adhere to Dart and Flutter conventions where applicable
4. **Avoid Abbreviations**: Use full words unless widely understood
5. **Use English**: All names should be in English

## Directory Naming

### Convention
- Use **snake_case** for all directory names
- All lowercase with underscores separating words

### Examples
```
✅ Good:
product_catalog/
user_authentication/
order_management/
inventory_tracking/

❌ Bad:
productCatalog/
UserAuthentication/
order-management/
```

### Feature Directories
Feature directories should be named after the feature they represent:
- `authentication/`
- `product_catalog/`
- `distribution/`
- `marketing/`
- `accounting/`

## File Naming

### Convention
- Use **camelCase** for all file names
- First letter lowercase, subsequent words capitalized
- No underscores in file names

### Examples
```
✅ Good:
userProfile.dart
authenticationProvider.dart
productDetailScreen.dart
orderService.dart

❌ Bad:
user_profile.dart
authentication_provider.dart
product-detail-screen.dart
```

### File Type Suffixes
Use descriptive suffixes to indicate file type:

| File Type | Suffix Pattern | Example |
|-----------|---------------|---------|
| Screens | `_screen.dart` | `loginScreen.dart` |
| Widgets | `_widget.dart` | `productCardWidget.dart` |
| Providers | `_provider.dart` | `authenticationProvider.dart` |
| Services | `_service.dart` | `apiService.dart` |
| Models (Data) | `_model.dart` | `userModel.dart` |
| Entities (Domain) | `.dart` (no suffix) | `user.dart` |
| Repositories (Data) | `_repository_impl.dart` | `userRepositoryImpl.dart` |
| Repositories (Domain) | `_repository.dart` | `userRepository.dart` |
| Use Cases | `_usecase.dart` | `loginUsecase.dart` |
| Data Sources | `_datasource.dart` | `authRemoteDatasource.dart` |
| Constants | `.dart` (no suffix) | `appConstants.dart` |
| Utilities | `.dart` (no suffix) | `dateUtils.dart` |

## Class Naming

### Convention
- Use **PascalCase** (UpperCamelCase) for all class names
- First letter of each word capitalized
- No underscores

### Examples
```
✅ Good:
class UserProfile { }
class AuthenticationProvider { }
class ProductDetailScreen { }
class OrderService { }

❌ Bad:
class userProfile { }
class authentication_provider { }
class product_detail_screen { }
```

### Class Name Patterns

| Class Type | Pattern | Example |
|------------|---------|---------|
| Screens | `FeatureScreen` | `LoginScreen`, `ProductDetailScreen` |
| Widgets | `FeatureWidget` | `ProductCardWidget`, `SearchBarWidget` |
| Providers | `FeatureProvider` | `AuthenticationProvider`, `ProductCatalogProvider` |
| Services | `FeatureService` | `ApiService`, `StorageService` |
| Models (Data) | `FeatureModel` | `UserModel`, `ProductModel` |
| Entities (Domain) | `Feature` | `User`, `Product`, `Order` |
| Repositories (Data) | `FeatureRepositoryImpl` | `UserRepositoryImpl` |
| Repositories (Domain) | `FeatureRepository` | `UserRepository` |
| Use Cases | `FeatureUsecase` | `LoginUsecase`, `FetchProductsUsecase` |
| Data Sources | `FeatureDatasource` | `AuthRemoteDatasource`, `AuthLocalDatasource` |

## Variable Naming

### Convention
- Use **camelCase** for all variable names
- First letter lowercase, subsequent words capitalized
- Descriptive names that indicate purpose

### Examples
```
✅ Good:
String userName;
int orderTotal;
bool isAuthenticated;
List<Product> products;

❌ Bad:
String user_name;
int order_total;
bool is_authenticated;
List<Product> p;
```

### Variable Name Patterns

| Variable Type | Pattern | Example |
|---------------|---------|---------|
| Local variables | camelCase | `userName`, `orderTotal` |
| Parameters | camelCase | `userId`, `pageNumber` |
| Private members | `_camelCase` | `_userName`, `_calculateTotal()` |
| Constants | camelCase or UPPER_CASE | `apiBaseUrl`, `MAX_RETRY_COUNT` |
| Boolean | `is/has/should/can` prefix | `isActive`, `hasPermission`, `shouldRefresh` |

### Boolean Variables
Use prefixes to make boolean variables clear:
- `is` for state: `isLoading`, `isAuthenticated`
- `has` for possession: `hasPermission`, `hasError`
- `should` for recommendations: `shouldRefresh`, `shouldRetry`
- `can` for capability: `canEdit`, `canDelete`

## Constant Naming

### Convention
- Use **camelCase** for feature-specific constants
- Use **UPPER_CASE** for global constants
- All uppercase with underscores for global constants

### Examples
```
✅ Good:
// Feature-specific
const String apiBaseUrl = 'https://api.example.com';
const int maxRetryCount = 3;

// Global constants
const String APP_NAME = 'VedantaTrade';
const int MAX_ITEMS_PER_PAGE = 50;

❌ Bad:
const String API_BASE_URL = 'https://api.example.com';
const int Max_Retry_Count = 3;
```

## Function/Method Naming

### Convention
- Use **camelCase** for all function and method names
- Verbs or verb phrases that indicate action
- Descriptive names that indicate what the function does

### Examples
```
✅ Good:
Future<void> loginUser() { }
String formatCurrency(double amount) { }
bool validateEmail(String email) { }

❌ Bad:
Future<void> login_user() { }
String format_currency(double amount) { }
bool validate_email(String email) { }
```

### Function Name Patterns

| Function Type | Pattern | Example |
|---------------|---------|---------|
| Actions | `verbNoun` | `loginUser`, `fetchProducts` |
| Getters | `getNoun` | `getUser`, `getProduct` |
| Setters | `setNoun` | `setUser`, `setProduct` |
| Validators | `validateNoun` | `validateEmail`, `validatePassword` |
| Formatters | `formatNoun` | `formatCurrency`, `formatDate` |
| Converters | `toNoun` or `fromNoun` | `toJson`, `fromJson` |
| Checkers | `is/has/should/can + Noun` | `isValid`, `hasPermission` |

### Async Functions
Prefix async functions with descriptive verbs:
- `fetch`: `fetchUser()`, `fetchProducts()`
- `load`: `loadData()`, `loadSettings()`
- `save`: `saveUser()`, `saveSettings()`
- `delete`: `deleteUser()`, `deleteProduct()`

## Enum Naming

### Convention
- Use **PascalCase** for enum type names
- Use **camelCase** for enum values

### Examples
```
✅ Good:
enum OrderStatus {
  pending,
  processing,
  completed,
  cancelled,
}

enum PaymentMethod {
  creditCard,
  debitCard,
  cash,
  bankTransfer,
}

❌ Bad:
enum order_status { }
enum ORDER_STATUS { }
enum OrderStatus { PENDING, PROCESSING, COMPLETED, CANCELLED }
```

## Parameter Naming

### Convention
- Use **camelCase** for all parameter names
- Descriptive names that indicate purpose
- Avoid single-letter parameters (except for generic types)

### Examples
```
✅ Good:
void updateUser(String userId, String userName) { }
Future<List<Product>> fetchProducts(int pageNumber, int pageSize) { }

❌ Bad:
void updateUser(String id, String name) { }
Future<List<Product>> fetchProducts(int p, int s) { }
```

### Callback Parameters
Use descriptive names for callback parameters:
```dart
void onUserChanged(User user) { }
void onOrderCompleted(Order order, bool success) { }
```

## Extension Naming

### Convention
- Use **PascalCase** for extension names
- Descriptive names indicating what is being extended

### Examples
```
✅ Good:
extension StringExtensions on String { }
extension DateTimeExtensions on DateTime { }

❌ Bad:
extension string_extensions on String { }
extension date_time_extensions on DateTime { }
```

## Mixin Naming

### Convention
- Use **PascalCase** for mixin names
- Descriptive names indicating functionality

### Examples
```
✅ Good:
mixin Validatable { }
mixin Serializable { }
mixin Cacheable { }

❌ Bad:
mixin validatable { }
mixin serializable { }
```

## Import Naming

### Convention
- Use **snake_case** for package names
- Import files using their actual file names (camelCase)

### Examples
```
✅ Good:
import 'package:vedanta_trade/features/authentication/authentication.dart';
import 'package:vedanta_trade/core/constants/app_constants.dart';
import 'user_model.dart';

❌ Bad:
import 'package:vedanta_trade/features/authentication/Authentication.dart';
import 'package:vedanta_trade/core/constants/AppConstants.dart';
import 'user_model.dart' as um;
```

### Import Aliases
Only use import aliases when necessary to avoid naming conflicts:
```dart
import 'package:vedanta_trade/features/authentication/data/models/user_model.dart' as auth;
import 'package:vedanta_trade/features/profile/data/models/user_model.dart' as profile;
```

## Widget Naming

### Convention
- Use **PascalCase** for widget class names
- Descriptive names indicating widget purpose
- Include type suffix (Screen, Widget, etc.)

### Examples
```
✅ Good:
class LoginScreen extends StatelessWidget { }
class ProductCardWidget extends StatelessWidget { }
class SearchBarWidget extends StatefulWidget { }

❌ Bad:
class loginScreen extends StatelessWidget { }
class product_card extends StatelessWidget { }
class SearchBar extends StatefulWidget { }
```

### Widget Parameters
- Use **camelCase** for widget parameters
- Descriptive names that indicate purpose

```dart
ProductCardWidget({
  required Product product,
  bool showPrice = true,
  VoidCallback? onTap,
})
```

## API Endpoint Naming

### Convention
- Use **kebab-case** for URL paths
- Use **camelCase** for query parameters
- Use **PascalCase** for API models

### Examples
```
✅ Good:
GET /api/users/{userId}
POST /api/orders/create
GET /api/products?pageNumber=1&pageSize=20

❌ Bad:
GET /api/Users/{userId}
POST /api/orders/create_order
GET /api/products?page_number=1&page_size=20
```

## Database Naming

### Table Naming
- Use **snake_case** for table names
- Plural form for entity tables

### Examples
```
✅ Good:
users
orders
products
order_items

❌ Bad:
User
Orders
product
orderItems
```

### Column Naming
- Use **snake_case** for column names

### Examples
```
✅ Good:
user_id
order_date
total_amount

❌ Bad:
userId
orderDate
totalAmount
```

## Asset Naming

### Convention
- Use **snake_case** for asset file names
- Descriptive names indicating content
- Include dimensions for images when relevant

### Examples
```
✅ Good:
logo.png
user_avatar_placeholder.png
product_image_200x200.png
icon_home.png

❌ Bad:
Logo.png
userAvatarPlaceholder.png
productImage.png
icon-home.png
```

## Test File Naming

### Convention
- Use **camelCase** with `_test.dart` suffix
- Name after the file/class being tested

### Examples
```
✅ Good:
authentication_provider_test.dart
user_service_test.dart
product_detail_screen_test.dart

❌ Bad:
authentication_provider.spec.dart
user_service.test.dart
product_detail_screen_tests.dart
```

## Documentation File Naming

### Convention
- Use **snake_case** for documentation files
- Descriptive names indicating content
- Use `.md` extension for Markdown files

### Examples
```
✅ Good:
project_structure.md
naming_conventions.md
api_documentation.md
deployment_guide.md

❌ Bad:
ProjectStructure.md
Naming-Conventions.md
API-Documentation.md
```

## JSON Key Naming

### Convention
- Use **snake_case** for JSON keys
- Consistent with database naming

### Examples
```json
✅ Good:
{
  "user_id": "123",
  "user_name": "John Doe",
  "order_date": "2024-01-01"
}

❌ Bad:
{
  "userId": "123",
  "userName": "John Doe",
  "orderDate": "2024-01-01"
}
```

## Common Mistakes to Avoid

### Inconsistent Casing
```dart
❌ Bad:
String userName;
String user_name;
String UserName;
```

### Abbreviations
```dart
❌ Bad:
String usrNm;
int ordTot;
bool isAuth;

✅ Good:
String userName;
int orderTotal;
bool isAuthenticated;
```

### Non-Descriptive Names
```dart
❌ Bad:
var data;
var item;
var value;

✅ Good:
var userData;
var cartItem;
var totalValue;
```

### Magic Numbers
```dart
❌ Bad:
if (items.length > 10) { }
setTimeout(() {}, 3000);

✅ Good:
const int maxItemsPerPage = 10;
const Duration defaultTimeout = Duration(seconds: 3);
if (items.length > maxItemsPerPage) { }
setTimeout(() {}, defaultTimeout);
```

## Naming Checklist

Before committing code, verify:

- [ ] Directories use snake_case
- [ ] Files use camelCase
- [ ] Classes use PascalCase
- [ ] Variables use camelCase
- [ ] Constants use appropriate casing (camelCase or UPPER_CASE)
- [ ] Functions use camelCase
- [ ] Enums use PascalCase with camelCase values
- [ ] Parameters use camelCase
- [ ] Names are descriptive and clear
- [ ] No abbreviations (unless widely understood)
- [ ] Boolean variables use appropriate prefixes
- [ ] Async functions use appropriate prefixes
- [ ] Widget names include type suffixes
- [ ] Test files include _test.dart suffix

## Tools and Linting

### Recommended Lint Rules
Enable these lint rules in `analysis_options.yaml`:
```yaml
linter:
  rules:
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_const_literals_to_create_immutables
    - avoid_print
    - avoid_unnecessary_containers
    - prefer_single_quotes
    - sort_constructors_first
    - always_declare_return_types
    - avoid_dynamic_calls
    - avoid_types_on_closure_parameters
```

### IDE Configuration
Configure your IDE to:
- Auto-format on save
- Show naming convention warnings
- Suggest refactoring for naming improvements

## Migration Strategy

### Phase 1: New Code
- Apply naming conventions to all new code
- Enforce during code review

### Phase 2: Critical Files
- Update naming in frequently modified files
- Focus on shared/core components

### Phase 3: Feature by Feature
- Refactor one feature at a time
- Test thoroughly after each refactor

### Phase 4: Cleanup
- Update remaining files
- Remove deprecated naming patterns

## References

- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [Flutter Style Guide](https://flutter.dev/docs/development/style-guide)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)

# VedantaTrade Feature Template

This document provides a standardized template for creating new features in the VedantaTrade project.

## 📁 Feature Directory Structure

```
lib/features/{feature_name}/
├── domain/                           # Business logic layer
│   ├── entities/                     # Domain entities
│   │   └── {feature}_entity.dart
│   ├── repositories/                  # Repository interfaces
│   │   └── {feature}_repository.dart
│   ├── usecases/                     # Business use cases
│   │   ├── get_{feature}_usecase.dart
│   │   ├── create_{feature}_usecase.dart
│   │   ├── update_{feature}_usecase.dart
│   │   └── delete_{feature}_usecase.dart
│   └── models/                       # Domain models
│       └── {feature}_model.dart
├── data/                             # Data layer
│   ├── datasources/                  # Data sources
│   │   ├── remote_{feature}_datasource.dart
│   │   └── local_{feature}_datasource.dart
│   ├── repositories/                  # Repository implementations
│   │   └── {feature}_repository_impl.dart
│   ├── models/                       # Data models
│   │   ├── {feature}_response_model.dart
│   │   └── {feature}_request_model.dart
│   └── services/                     # External services
│       └── {feature}_service.dart
├── presentation/                     # UI layer
│   ├── pages/                        # Screen pages
│   │   ├── {feature}_page.dart
│   │   └── {feature}_detail_page.dart
│   ├── widgets/                      # Feature widgets
│   │   ├── {feature}_card_widget.dart
│   │   ├── {feature}_list_widget.dart
│   │   └── {feature}_form_widget.dart
│   ├── providers/                    # State management
│   │   └── {feature}_provider.dart
│   └── screens/                      # Screen implementations
│       ├── {feature}_screen.dart
│       └── {feature}_edit_screen.dart
└── {feature}.dart                    # Feature barrel export
```

## 🏷️ File Naming Conventions

### General Rules
- Use `snake_case` for all file names
- Use descriptive names that clearly indicate purpose
- Include feature name as prefix for clarity
- Use `_entity`, `_provider`, `_service`, etc. suffixes

### Domain Layer
```dart
// Entities
user_entity.dart
product_entity.dart
order_entity.dart

// Repositories (interfaces)
user_repository.dart
product_repository.dart
order_repository.dart

// Use Cases
get_user_usecase.dart
create_user_usecase.dart
update_user_usecase.dart
delete_user_usecase.dart

// Domain Models
user_model.dart
product_model.dart
order_model.dart
```

### Data Layer
```dart
// Data Sources
remote_user_datasource.dart
local_user_datasource.dart

// Repository Implementations
user_repository_impl.dart
product_repository_impl.dart

// Data Models
user_response_model.dart
user_request_model.dart

// Services
api_service.dart
user_service.dart
```

### Presentation Layer
```dart
// Pages
user_page.dart
user_detail_page.dart

// Widgets
user_card_widget.dart
user_list_widget.dart
user_form_widget.dart

// Providers
user_provider.dart

// Screens
user_screen.dart
user_edit_screen.dart
```

## 📝 Code Structure Templates

### Entity Template
```dart
import 'package:equatable/equatable.dart';

class {Feature}Entity extends Equatable {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  const {Feature}Entity({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, name, createdAt, updatedAt];

  {Feature}Entity copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return {Feature}Entity(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory {Feature}Entity.fromJson(Map<String, dynamic> json) {
    return {Feature}Entity(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt']),
      updatedAt: DateTime.parse(json['updated_at'] ?? json['updatedAt']),
    );
  }
}
```

### Repository Interface Template
```dart
import '../entities/{feature}_entity.dart';

abstract class {Feature}Repository {
  Future<List<{Feature}Entity>> get{Feature}s({
    int page = 1,
    int limit = 20,
    String? search,
  });

  Future<{Feature}Entity?> get{Feature}ById(String id);

  Future<Map<String, dynamic>> create{Feature}({Feature}Entity {feature});

  Future<Map<String, dynamic>> update{Feature}({
    required String id,
    required Map<String, dynamic> updates,
  });

  Future<Map<String, dynamic>> delete{Feature}(String id);
}
```

### Use Case Template
```dart
import '../entities/{feature}_entity.dart';
import '../repositories/{feature}_repository.dart';

class Get{Feature}sUseCase {
  final {Feature}Repository _repository;

  Get{Feature}sUseCase(this._repository);

  Future<List<{Feature}Entity>> call({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    return await _repository.get{Feature}s(
      page: page,
      limit: limit,
      search: search,
    );
  }
}
```

### Service Template
```dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/api_config.dart';
import '../models/{feature}_response_model.dart';

class {Feature}Service {
  late final Dio _dio;

  {Feature}Service() {
    _dio = Dio();
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.headers = {'Content-Type': 'application/json'};
  }

  Future<List<{Feature}ResponseModel>> get{Feature}s({
    int page = 1,
    int limit = 20,
    String? search,
    String? token,
  }) async {
    try {
      final response = await _dio.get(
        '/api/{feature}s',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search != null) 'search': search,
        },
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : {},
        ),
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => {Feature}ResponseModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Failed to load {feature}s: $e');
      return [];
    }
  }

  Future<{Feature}ResponseModel?> get{Feature}ById(String id, {String? token}) async {
    try {
      final response = await _dio.get(
        '/api/{feature}s/$id',
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : {},
        ),
      );

      if (response.data['success'] == true) {
        return {Feature}ResponseModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Failed to load {feature}: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> create{Feature}({
    required {Feature}RequestModel {feature},
    String? token,
  }) async {
    try {
      final response = await _dio.post(
        '/api/{feature}s',
        data: {feature}.toJson(),
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : {},
        ),
      );

      return response.data;
    } catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }

  Future<Map<String, dynamic>> update{Feature}({
    required String id,
    required Map<String, dynamic> updates,
    String? token,
  }) async {
    try {
      final response = await _dio.put(
        '/api/{feature}s/$id',
        data: updates,
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : {},
        ),
      );

      return response.data;
    } catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }

  Future<Map<String, dynamic>> delete{Feature}(String id, {String? token}) async {
    try {
      final response = await _dio.delete(
        '/api/{feature}s/$id',
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : {},
        ),
      );

      return response.data;
    } catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }

  String _getErrorMessage(dynamic e) {
    if (e is DioException) {
      return e.response?.data?['message'] ?? e.message ?? 'Network error occurred';
    }
    return 'An unexpected error occurred';
  }
}
```

### Provider Template
```dart
import 'package:flutter/foundation.dart';
import '../domain/entities/{feature}_entity.dart';
import '../domain/usecases/get_{feature}s_usecase.dart';
import '../domain/usecases/create_{feature}_usecase.dart';
import '../domain/usecases/update_{feature}_usecase.dart';
import '../domain/usecases/delete_{feature}_usecase.dart';

class {Feature}Provider extends ChangeNotifier {
  final Get{Feature}sUseCase _get{Feature}sUseCase;
  final Create{Feature}UseCase _create{Feature}UseCase;
  final Update{Feature}UseCase _update{Feature}UseCase;
  final Delete{Feature}UseCase _delete{Feature}UseCase;

  List<{Feature}Entity> _{feature}s = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMoreData = true;

  // Getters
  List<{Feature}Entity> get {feature}s => _{feature}s;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMoreData => _hasMoreData;

  {Feature}Provider({
    required Get{Feature}sUseCase get{Feature}sUseCase,
    required Create{Feature}UseCase create{Feature}UseCase,
    required Update{Feature}UseCase update{Feature}UseCase,
    required Delete{Feature}UseCase delete{Feature}UseCase,
  })  : _get{Feature}sUseCase = get{Feature}sUseCase,
        _create{Feature}UseCase = create{Feature}UseCase,
        _update{Feature}UseCase = update{Feature}UseCase,
        _delete{Feature}UseCase = delete{Feature}UseCase;

  Future<void> load{Feature}s({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreData = true;
      _{feature}s.clear();
    }

    if (_isLoading || !_hasMoreData) return;

    _setLoading(true);
    _clearError();

    try {
      final result = await _get{Feature}sUseCase(
        page: _currentPage,
        limit: 20,
      );

      if (refresh) {
        _{feature}s = result;
      } else {
        _{feature}s.addAll(result);
      }

      _currentPage++;
      _hasMoreData = result.length == 20;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load {feature}s: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> create{Feature}({Feature}Entity {feature}) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _create{Feature}UseCase({feature});
      
      if (result['success'] == true) {
        _{feature}s.insert(0, {feature});
        notifyListeners();
        return true;
      } else {
        _setError(result['message'] ?? 'Failed to create {feature}');
        return false;
      }
    } catch (e) {
      _setError('Failed to create {feature}: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> update{Feature}({
    required String id,
    required Map<String, dynamic> updates,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _update{Feature}UseCase(id: id, updates: updates);
      
      if (result['success'] == true) {
        final index = _{feature}s.indexWhere((item) => item.id == id);
        if (index != -1) {
          _{feature}s[index] = _{feature}s[index].copyWith(
            // Update fields based on updates
          );
          notifyListeners();
        }
        return true;
      } else {
        _setError(result['message'] ?? 'Failed to update {feature}');
        return false;
      }
    } catch (e) {
      _setError('Failed to update {feature}: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> delete{Feature}(String id) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _delete{Feature}UseCase(id);
      
      if (result['success'] == true) {
        _{feature}s.removeWhere((item) => item.id == id);
        notifyListeners();
        return true;
      } else {
        _setError(result['message'] ?? 'Failed to delete {feature}');
        return false;
      }
    } catch (e) {
      _setError('Failed to delete {feature}: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
```

## 🚀 Getting Started

### 1. Create Feature Directory
```bash
mkdir lib/features/{feature_name}
cd lib/features/{feature_name}
mkdir -p domain/entities domain/repositories domain/usecases domain/models
mkdir -p data/datasources data/repositories data/models data/services
mkdir -p presentation/pages presentation/widgets presentation/providers presentation/screens
```

### 2. Create Files Using Templates
- Copy and adapt the templates above
- Replace `{feature}` with your feature name
- Replace `{Feature}` with PascalCase feature name

### 3. Update Feature Barrel Export
Add to `{feature}.dart`:
```dart
// Domain
export 'domain/entities/{feature}_entity.dart';
export 'domain/repositories/{feature}_repository.dart';
export 'domain/usecases/get_{feature}_usecase.dart';
export 'domain/usecases/create_{feature}_usecase.dart';
export 'domain/usecases/update_{feature}_usecase.dart';
export 'domain/usecases/delete_{feature}_usecase.dart';

// Data
export 'data/services/{feature}_service.dart';
export 'data/repositories/{feature}_repository_impl.dart';

// Presentation
export 'presentation/providers/{feature}_provider.dart';
export 'presentation/screens/{feature}_screen.dart';
```

## 📋 Checklist for New Features

- [ ] Create directory structure
- [ ] Create domain entities
- [ ] Create repository interfaces
- [ ] Create use cases
- [ ] Create data models
- [ ] Create data sources
- [ ] Create repository implementations
- [ ] Create services
- [ ] Create providers
- [ ] Create screens and widgets
- [ ] Create feature barrel export
- [ ] Update main app imports
- [ ] Test compilation
- [ ] Test functionality

## 🔗 Integration

### Add to Main App
```dart
// In main.dart or app.dart
import 'features/{feature}/{feature}.dart';

// Register providers in MultiProvider
MultiProvider(
  providers: [
    // ... existing providers
    ChangeNotifierProvider(create: (_) => {Feature}Provider(...)),
  ],
  child: MyApp(),
)
```

### Add to Router
```dart
// In router configuration
GoRoute(
  path: '/{feature}',
  builder: (context, state) => {Feature}Screen(),
),
```

This template ensures consistency across all features and follows Clean Architecture principles for maintainability and scalability.

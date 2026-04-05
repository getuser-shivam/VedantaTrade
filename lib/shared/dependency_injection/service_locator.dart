import 'dart:async';
import 'dart:collection';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../services/storage_service.dart';
import '../services/app_utils.dart';
import '../services/location_service.dart';
import '../services/network_service.dart';
import '../services/notification_service.dart';
import '../services/cache_service.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import '../services/logger_service.dart';
import '../services/validation_service.dart';
import '../services/encryption_service.dart';
import '../services/backup_service.dart';
import '../services/analytics_service.dart';
import '../services/theme_service.dart';
import '../services/preferences_service.dart';
import '../websocket/websocket_manager.dart';
import '../workflow/workflow_manager.dart';
import '../workflow/workflow_execution_engine.dart';

/// Service Locator with Dependency Injection
/// Comprehensive dependency injection system for managing service lifecycles
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  final Map<Type, ServiceRegistration> _services = {};
  final Map<Type, dynamic> _instances = {};
  final Map<Type, StreamController> _streams = {};
  final Map<String, Timer> _timers = {};
  final List<ServiceDependency> _dependencies = [];
  bool _isInitialized = false;
  bool _isDisposed = false;

  /// Initialize service locator
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
// print('🔧 Initializing Service Locator...'); // Removed for production

      // Register core services
      await _registerCoreServices();

      // Register feature services
      await _registerFeatureServices();

      // Register utility services
      await _registerUtilityServices();

      // Register infrastructure services
      await _registerInfrastructureServices();

      // Initialize all services
      await _initializeServices();

      _isInitialized = true;
// print('✅ Service Locator initialized successfully'); // Removed for production
    } catch (e) {
// print('❌ Failed to initialize Service Locator: $e'); // Removed for production
      rethrow;
    }
  }

  /// Register core services
  Future<void> _registerCoreServices() async {
    // SharedPreferences
    register<SharedPreferences>(
      () async => await SharedPreferences.getInstance(),
      lifetime: ServiceLifetime.singleton,
      dependencies: [],
    );

    // Database Service
    register<DatabaseService>(
      () => DatabaseServiceImpl(),
      lifetime: ServiceLifetime.singleton,
      dependencies: [],
    );

    // Logger Service
    register<LoggerService>(
      () => LoggerServiceImpl(),
      lifetime: ServiceLifetime.singleton,
      dependencies: [],
    );

    // Encryption Service
    register<EncryptionService>(
      () => EncryptionServiceImpl(),
      lifetime: ServiceLifetime.singleton,
      dependencies: [],
    );

    // Cache Service
    register<CacheService>(
      () => CacheServiceImpl(),
      lifetime: ServiceLifetime.singleton,
      dependencies: [LoggerService],
    );

    // Storage Service
    register<StorageService>(
      () => StorageServiceImpl(),
      lifetime: ServiceLifetime.singleton,
      dependencies: [DatabaseService, LoggerService, CacheService],
    );

    // Network Service
    register<NetworkService>(
      () => NetworkServiceImpl(),
      lifetime: ServiceLifetime.singleton,
      dependencies: [LoggerService],
    );

    // API Service
    register<ApiService>(
      () => ApiServiceImplementation(),
      lifetime: ServiceLifetime.singleton,
      dependencies: [NetworkService, LoggerService, EncryptionService],
    );

    // Authentication Service
    register<AuthService>(
      () => AuthServiceImplementation(),
      lifetime: ServiceLifetime.singleton,
      dependencies: [ApiService, StorageService, LoggerService, EncryptionService],
    );

    // WebSocket Manager
    register<WebSocketManager>(
      () => WebSocketManager(url: 'ws://localhost:8080/ws'),
      lifetime: ServiceLifetime.singleton,
      dependencies: [LoggerService],
    );

// print('✅ Core services registered'); // Removed for production
  }

  /// Register feature services
  Future<void> _registerFeatureServices() async {
    // Location Service
    register<LocationService>(
      () => LocationServiceImpl(
        get<DatabaseService>(),
        get<SharedPreferences>(),
      ),
      lifetime: ServiceLifetime.singleton,
      dependencies: [DatabaseService, SharedPreferences, LoggerService],
    );

    // Notification Service
    register<NotificationService>(
      () => NotificationServiceImpl(),
      lifetime: ServiceLifetime.singleton,
      dependencies: [LoggerService, PreferencesService],
    );

    // Workflow Manager
    register<WorkflowManager>(
      () => WorkflowManager(),
      lifetime: ServiceLifetime.singleton,
      dependencies: [LoggerService],
    );

    // Workflow Execution Engine
    register<WorkflowExecutionEngine>(
      () => WorkflowExecutionEngine(get<WorkflowManager>()),
      lifetime: ServiceLifetime.singleton,
      dependencies: [WorkflowManager, LoggerService],
    );

// print('✅ Feature services registered'); // Removed for production
  }

  /// Register utility services
  Future<void> _registerUtilityServices() async {
    // App Utils
    register<AppUtils>(
      () => AppUtilsImplementation(),
      lifetime: ServiceLifetime.singleton,
      dependencies: [LoggerService],
    );

    // Validation Service
    register<ValidationService>(
      () => ValidationServiceImpl(),
      lifetime: ServiceLifetime.singleton,
      dependencies: [LoggerService],
    );

    // Theme Service
    register<ThemeService>(
      () => ThemeServiceImpl(),
      lifetime: ServiceLifetime.singleton,
      dependencies: [SharedPreferences, LoggerService],
    );

    // Preferences Service
    register<PreferencesService>(
      () => PreferencesServiceImpl(get<SharedPreferences>()),
      lifetime: ServiceLifetime.singleton,
      dependencies: [SharedPreferences, LoggerService],
    );

    // Analytics Service
    register<AnalyticsService>(
      () => AnalyticsServiceImpl(),
      lifetime: ServiceLifetime.singleton,
      dependencies: [LoggerService, PreferencesService],
    );

    // Backup Service
    register<BackupService>(
      () => BackupServiceImpl(),
      lifetime: ServiceLifetime.singleton,
      dependencies: [StorageService, LoggerService, EncryptionService],
    );

// print('✅ Utility services registered'); // Removed for production
  }

  /// Register infrastructure services
  Future<void> _registerInfrastructureServices() async {
    // Connectivity monitoring
    register<Connectivity>(
      () => Connectivity(),
      lifetime: ServiceLifetime.singleton,
      dependencies: [],
    );

    // Geolocator
    register<GeolocatorPlatform>(
      () => GeolocatorPlatform.instance,
      lifetime: ServiceLifetime.singleton,
      dependencies: [],
    );

// print('✅ Infrastructure services registered'); // Removed for production
  }

  /// Initialize all services
  Future<void> _initializeServices() async {
    for (final registration in _services.values) {
      if (registration.lifetime == ServiceLifetime.singleton && !_instances.containsKey(registration.type)) {
        await _initializeService(registration);
      }
    }
  }

  /// Initialize individual service
  Future<void> _initializeService(ServiceRegistration registration) async {
    try {
// print('🔧 Initializing service: ${registration.type}'); // Removed for production

      // Check dependencies
      for (final dependency in registration.dependencies) {
        if (!_instances.containsKey(dependency)) {
          final depRegistration = _services[dependency];
          if (depRegistration != null) {
            await _initializeService(depRegistration);
          }
        }
      }

      // Create instance
      final instance = await registration.factory();
      _instances[registration.type] = instance;

      // Initialize if it's an InitializableService
      if (instance is InitializableService) {
        await instance.initialize();
      }

// print('✅ Service initialized: ${registration.type}'); // Removed for production
    } catch (e) {
// print('❌ Failed to initialize service ${registration.type}: $e'); // Removed for production
      rethrow;
    }
  }

  /// Register a service
  void register<T>(
    Future<T> Function() factory, {
    ServiceLifetime lifetime = ServiceLifetime.transient,
    List<Type> dependencies = const [],
  }) {
    if (_isDisposed) {
      throw StateError('ServiceLocator has been disposed');
    }

    _services[T] = ServiceRegistration<T>(
      type: T,
      factory: factory,
      lifetime: lifetime,
      dependencies: dependencies,
    );

// print('📝 Service registered: $T'); // Removed for production
  }

  /// Get a service instance
  T get<T>() {
    if (_isDisposed) {
      throw StateError('ServiceLocator has been disposed');
    }

    final registration = _services[T];
    if (registration == null) {
      throw ArgumentError('Service of type $T is not registered');
    }

    switch (registration.lifetime) {
      case ServiceLifetime.singleton:
        if (!_instances.containsKey(T)) {
          throw StateError('Singleton service $T is not initialized');
        }
        return _instances[T] as T;

      case ServiceLifetime.scoped:
        // For now, treat scoped as transient
        return _createTransientInstance<T>(registration);

      case ServiceLifetime.transient:
        return _createTransientInstance<T>(registration);
    }
  }

  /// Create transient instance
  T _createTransientInstance<T>(ServiceRegistration registration) {
    // Check dependencies
    for (final dependency in registration.dependencies) {
      if (!_instances.containsKey(dependency)) {
        final depRegistration = _services[dependency];
        if (depRegistration != null) {
          _initializeService(depRegistration);
        }
      }
    }

    // Create instance synchronously if possible
    final factory = registration.factory;
    if (factory is T Function()) {
      return factory();
    }

    throw StateError('Cannot create transient instance of type $T synchronously');
  }

  /// Get service asynchronously
  Future<T> getAsync<T>() async {
    if (_isDisposed) {
      throw StateError('ServiceLocator has been disposed');
    }

    final registration = _services[T];
    if (registration == null) {
      throw ArgumentError('Service of type $T is not registered');
    }

    switch (registration.lifetime) {
      case ServiceLifetime.singleton:
        if (!_instances.containsKey(T)) {
          await _initializeService(registration);
        }
        return _instances[T] as T;

      case ServiceLifetime.scoped:
        // For now, treat scoped as transient
        return await _createTransientInstanceAsync<T>(registration);

      case ServiceLifetime.transient:
        return await _createTransientInstanceAsync<T>(registration);
    }
  }

  /// Create transient instance asynchronously
  Future<T> _createTransientInstanceAsync<T>(ServiceRegistration registration) async {
    // Check dependencies
    for (final dependency in registration.dependencies) {
      if (!_instances.containsKey(dependency)) {
        final depRegistration = _services[dependency];
        if (depRegistration != null) {
          await _initializeService(depRegistration);
        }
      }
    }

    // Create instance
    final instance = await registration.factory();
    return instance as T;
  }

  /// Check if service is registered
  bool isRegistered<T>() {
    return _services.containsKey(T);
  }

  /// Check if service is initialized
  bool isInitialized<T>() {
    return _instances.containsKey(T);
  }

  /// Get all registered services
  List<Type> getRegisteredServices() {
    return _services.keys.toList();
  }

  /// Get all initialized services
  List<Type> getInitializedServices() {
    return _instances.keys.toList();
  }

  /// Create scope
  ServiceScope createScope() {
    return ServiceScope(this);
  }

  /// Reset service locator
  Future<void> reset() async {
    try {
// print('🔄 Resetting Service Locator...'); // Removed for production

      // Dispose all instances
      for (final instance in _instances.values) {
        if (instance is DisposableService) {
          await instance.dispose();
        }
      }

      // Clear instances
      _instances.clear();

      // Clear streams
      for (final controller in _streams.values) {
        controller.close();
      }
      _streams.clear();

      // Clear timers
      for (final timer in _timers.values) {
        timer.cancel();
      }
      _timers.clear();

      // Reinitialize
      await _initializeServices();

// print('✅ Service Locator reset successfully'); // Removed for production
    } catch (e) {
// print('❌ Failed to reset Service Locator: $e'); // Removed for production
      rethrow;
    }
  }

  /// Dispose service locator
  Future<void> dispose() async {
    if (_isDisposed) return;

    try {
// print('🗑️ Disposing Service Locator...'); // Removed for production

      // Cancel all timers
      for (final timer in _timers.values) {
        timer.cancel();
      }
      _timers.clear();

      // Close all streams
      for (final controller in _streams.values) {
        controller.close();
      }
      _streams.clear();

      // Dispose all instances
      for (final instance in _instances.values) {
        if (instance is DisposableService) {
          try {
            await instance.dispose();
          } catch (e) {
// print('❌ Failed to dispose service: $e'); // Removed for production
          }
        }
      }

      // Clear all collections
      _instances.clear();
      _services.clear();
      _dependencies.clear();

      _isDisposed = true;
// print('✅ Service Locator disposed successfully'); // Removed for production
    } catch (e) {
// print('❌ Failed to dispose Service Locator: $e'); // Removed for production
    }
  }

  /// Get service statistics
  ServiceStatistics getStatistics() {
    return ServiceStatistics(
      totalRegistered: _services.length,
      totalInitialized: _instances.length,
      singletonCount: _services.values
          .where((r) => r.lifetime == ServiceLifetime.singleton)
          .length,
      transientCount: _services.values
          .where((r) => r.lifetime == ServiceLifetime.transient)
          .length,
      scopedCount: _services.values
          .where((r) => r.lifetime == ServiceLifetime.scoped)
          .length,
      dependencyCount: _dependencies.length,
      streamCount: _streams.length,
      timerCount: _timers.length,
    );
  }

  /// Register stream controller
  void registerStream<T>(StreamController<T> controller) {
    if (_isDisposed) return;
    _streams[T] = controller;
  }

  /// Get stream controller
  StreamController<T>? getStream<T>() {
    return _streams[T] as StreamController<T>?;
  }

  /// Register timer
  void registerTimer(String key, Timer timer) {
    if (_isDisposed) return;
    _timers[key] = timer;
  }

  /// Cancel timer
  void cancelTimer(String key) {
    final timer = _timers.remove(key);
    timer?.cancel();
  }

  /// Register dependency
  void registerDependency(ServiceDependency dependency) {
    _dependencies.add(dependency);
  }

  /// Check for circular dependencies
  bool hasCircularDependencies() {
    final visited = <Type>{};
    final recursionStack = <Type>{};

    bool hasCycle(Type type) {
      if (recursionStack.contains(type)) {
        return true;
      }

      if (visited.contains(type)) {
        return false;
      }

      visited.add(type);
      recursionStack.add(type);

      final registration = _services[type];
      if (registration != null) {
        for (final dependency in registration.dependencies) {
          if (hasCycle(dependency)) {
            return true;
          }
        }
      }

      recursionStack.remove(type);
      return false;
    }

    for (final type in _services.keys) {
      if (hasCycle(type)) {
        return true;
      }
    }

    return false;
  }

  /// Validate dependencies
  List<String> validateDependencies() {
    final errors = <String>[];

    for (final registration in _services.values) {
      for (final dependency in registration.dependencies) {
        if (!_services.containsKey(dependency)) {
          errors.add('Service ${registration.type} depends on unregistered service $dependency');
        }
      }
    }

    return errors;
  }
}

/// Service Scope for managing scoped services
class ServiceScope {
  final ServiceLocator _locator;
  final Map<Type, dynamic> _scopedInstances = {};
  bool _isDisposed = false;

  ServiceScope(this._locator);

  /// Get service from scope
  T get<T>() {
    if (_isDisposed) {
      throw StateError('ServiceScope has been disposed');
    }

    final registration = _locator._services[T];
    if (registration == null) {
      throw ArgumentError('Service of type $T is not registered');
    }

    switch (registration.lifetime) {
      case ServiceLifetime.singleton:
        return _locator.get<T>();

      case ServiceLifetime.scoped:
        if (!_scopedInstances.containsKey(T)) {
          _scopedInstances[T] = _locator._createTransientInstance<T>(registration);
        }
        return _scopedInstances[T] as T;

      case ServiceLifetime.transient:
        return _locator._createTransientInstance<T>(registration);
    }
  }

  /// Get service asynchronously from scope
  Future<T> getAsync<T>() async {
    if (_isDisposed) {
      throw StateError('ServiceScope has been disposed');
    }

    final registration = _locator._services[T];
    if (registration == null) {
      throw ArgumentError('Service of type $T is not registered');
    }

    switch (registration.lifetime) {
      case ServiceLifetime.singleton:
        return await _locator.getAsync<T>();

      case ServiceLifetime.scoped:
        if (!_scopedInstances.containsKey(T)) {
          _scopedInstances[T] = await _locator._createTransientInstanceAsync<T>(registration);
        }
        return _scopedInstances[T] as T;

      case ServiceLifetime.transient:
        return await _locator._createTransientInstanceAsync<T>(registration);
    }
  }

  /// Dispose scope
  void dispose() {
    if (_isDisposed) return;

    // Dispose scoped instances
    for (final instance in _scopedInstances.values) {
      if (instance is DisposableService) {
        instance.dispose();
      }
    }

    _scopedInstances.clear();
    _isDisposed = true;
  }
}

/// Service Registration
class ServiceRegistration<T> {
  final Type type;
  final Future<T> Function() factory;
  final ServiceLifetime lifetime;
  final List<Type> dependencies;

  ServiceRegistration({
    required this.type,
    required this.factory,
    required this.lifetime,
    required this.dependencies,
  });
}

/// Service Dependency
class ServiceDependency {
  final Type dependent;
  final Type dependency;
  final bool required;

  ServiceDependency({
    required this.dependent,
    required this.dependency,
    this.required = true,
  });
}

/// Service Statistics
class ServiceStatistics {
  final int totalRegistered;
  final int totalInitialized;
  final int singletonCount;
  final int transientCount;
  final int scopedCount;
  final int dependencyCount;
  final int streamCount;
  final int timerCount;

  const ServiceStatistics({
    required this.totalRegistered,
    required this.totalInitialized,
    required this.singletonCount,
    required this.transientCount,
    required this.scopedCount,
    required this.dependencyCount,
    required this.streamCount,
    required this.timerCount,
  });
}

/// Service Lifetime
enum ServiceLifetime {
  singleton,
  scoped,
  transient,
}

/// Service Interfaces
abstract class InitializableService {
  Future<void> initialize();
}

abstract class DisposableService {
  void dispose();
}

/// Global service locator instance
final serviceLocator = ServiceLocator();

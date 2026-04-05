import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';
import '../services/network_service.dart';
import '../navigation/app_router.dart';
import '../utils/app_utils.dart';
import '../../core/services/background_gps_service.dart';
import '../../core/utils/validation_utils.dart';
import '../../core/utils/nepal_vat_expense_generator.dart';
import '../../core/utils/vat_pdf_generator.dart';
import '../../features/accounting/data/services/accounting_service.dart';
import '../../features/accounting/presentation/providers/accounting_provider.dart';

/// Dependency Container
/// Centralized dependency injection container with lifecycle management
class DependencyContainer {
  static final DependencyContainer _instance = DependencyContainer._internal();
  factory DependencyContainer() => _instance;
  DependencyContainer._internal();

  final Map<Type, dynamic> _instances = {};
  final Map<Type, FactoryFunction> _factories = {};
  final Map<Type, ServiceLifetime> _lifetimes = {};
  final Map<Type, StreamController> _controllers = {};
  final Map<String, Timer> _timers = {};
  bool _isInitialized = false;
  bool _isDisposed = false;

  /// Initialize the container
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
// print('🔧 Initializing Dependency Container...'); // Removed for production

      // Register core services
      await _registerCoreServices();

      // Register shared services
      await _registerSharedServices();

      // Register feature services
      await _registerFeatureServices();

      // Initialize singleton instances
      await _initializeSingletons();

      _isInitialized = true;
// print('✅ Dependency Container initialized successfully'); // Removed for production
    } catch (e) {
// print('❌ Failed to initialize Dependency Container: $e'); // Removed for production
      rethrow;
    }
  }

  /// Register core services
  Future<void> _registerCoreServices() async {
    register<StorageService>(
      () => StorageService.instance,
      ServiceLifetime.singleton,
    );

    register<ValidationUtils>(
      () => ValidationUtils(),
      ServiceLifetime.singleton,
    );

    register<NepalVATExpenseGenerator>(
      () => NepalVATExpenseGenerator(),
      ServiceLifetime.singleton,
    );

    register<VATPDFGenerator>(
      () => VATPDFGenerator(),
      ServiceLifetime.singleton,
    );

    register<BackgroundGPSService>(
      () => BackgroundGPSService(),
      ServiceLifetime.singleton,
    );

// print('✅ Core services registered'); // Removed for production
  }

  /// Register shared services
  Future<void> _registerSharedServices() async {
    register<NetworkService>(
      () => NetworkService(),
      ServiceLifetime.singleton,
    );

    register<AppRouter>(
      () => AppRouter(),
      ServiceLifetime.singleton,
    );

    register<AppUtils>(
      () => AppUtils(),
      ServiceLifetime.singleton,
    );

// print('✅ Shared services registered'); // Removed for production
  }

  /// Register feature services
  Future<void> _registerFeatureServices() async {
    register<AccountingService>(
      () => AccountingService(),
      ServiceLifetime.singleton,
    );

    register<AccountingProvider>(
      () => AccountingProvider(),
      ServiceLifetime.singleton,
    );

// print('✅ Feature services registered'); // Removed for production
  }

  /// Initialize singleton instances
  Future<void> _initializeSingletons() async {
    for (final entry in _lifetimes.entries) {
      if (entry.value == ServiceLifetime.singleton && !_instances.containsKey(entry.key)) {
        final instance = await _createInstance(entry.key);
        _instances[entry.key] = instance;
      }
    }
  }

  /// Register a dependency
  void register<T>(
    FactoryFunction factory, {
    ServiceLifetime lifetime = ServiceLifetime.transient,
  }) {
    if (_isDisposed) {
      throw StateError('Container has been disposed');
    }

    _factories[T] = factory;
    _lifetimes[T] = lifetime;

// print('📝 Dependency registered: $T'); // Removed for production
  }

  /// Get a dependency
  T get<T>() {
    if (_isDisposed) {
      throw StateError('Container has been disposed');
    }

    final lifetime = _lifetimes[T];
    if (lifetime == null) {
      throw ArgumentError('Dependency $T is not registered');
    }

    switch (lifetime) {
      case ServiceLifetime.singleton:
        if (!_instances.containsKey(T)) {
          throw StateError('Singleton $T is not initialized');
        }
        return _instances[T] as T;

      case ServiceLifetime.scoped:
        return _createInstance<T>(T);

      case ServiceLifetime.transient:
        return _createInstance<T>(T);
    }
  }

  /// Get a dependency asynchronously
  Future<T> getAsync<T>() async {
    if (_isDisposed) {
      throw StateError('Container has been disposed');
    }

    final lifetime = _lifetimes[T];
    if (lifetime == null) {
      throw ArgumentError('Dependency $T is not registered');
    }

    switch (lifetime) {
      case ServiceLifetime.singleton:
        if (!_instances.containsKey(T)) {
          final instance = await _createInstance<T>(T);
          _instances[T] = instance;
        }
        return _instances[T] as T;

      case ServiceLifetime.scoped:
        return await _createInstanceAsync<T>(T);

      case ServiceLifetime.transient:
        return await _createInstanceAsync<T>(T);
    }
  }

  /// Create an instance
  T _createInstance<T>(Type type) {
    final factory = _factories[type];
    if (factory == null) {
      throw ArgumentError('Factory for $type not found');
    }

    try {
      return factory() as T;
    } catch (e) {
// print('❌ Failed to create instance of $type: $e'); // Removed for production
      rethrow;
    }
  }

  /// Create an instance asynchronously
  Future<T> _createInstanceAsync<T>(Type type) async {
    final factory = _factories[type];
    if (factory == null) {
      throw ArgumentError('Factory for $type not found');
    }

    try {
      final instance = await factory();
      return instance as T;
    } catch (e) {
// print('❌ Failed to create async instance of $type: $e'); // Removed for production
      rethrow;
    }
  }

  /// Check if a dependency is registered
  bool isRegistered<T>() {
    return _factories.containsKey(T);
  }

  /// Check if a dependency is initialized
  bool isInitialized<T>() {
    return _instances.containsKey(T);
  }

  /// Get all registered types
  List<Type> getRegisteredTypes() {
    return _factories.keys.toList();
  }

  /// Get all initialized instances
  List<Type> getInitializedTypes() {
    return _instances.keys.toList();
  }

  /// Create a scoped container
  DependencyContainer createScope() {
    final scope = DependencyContainer._internal();
    scope._factories.addAll(_factories);
    scope._lifetimes.addAll(_lifetimes);
    return scope;
  }

  /// Reset the container
  Future<void> reset() async {
    try {
// print('🔄 Resetting Dependency Container...'); // Removed for production

      // Dispose all instances
      for (final instance in _instances.values) {
        if (instance is DisposableService) {
          await instance.dispose();
        }
      }

      // Clear instances
      _instances.clear();

      // Clear streams
      for (final controller in _controllers.values) {
        controller.close();
      }
      _controllers.clear();

      // Clear timers
      for (final timer in _timers.values) {
        timer.cancel();
      }
      _timers.clear();

      // Reinitialize singletons
      await _initializeSingletons();

// print('✅ Dependency Container reset successfully'); // Removed for production
    } catch (e) {
// print('❌ Failed to reset Dependency Container: $e'); // Removed for production
    }
  }

  /// Dispose the container
  Future<void> dispose() async {
    if (_isDisposed) return;

    try {
// print('🗑️ Disposing Dependency Container...'); // Removed for production

      // Cancel all timers
      for (final timer in _timers.values) {
        timer.cancel();
      }
      _timers.clear();

      // Close all streams
      for (final controller in _controllers.values) {
        controller.close();
      }
      _controllers.clear();

      // Dispose all instances
      for (final instance in _instances.values) {
        if (instance is DisposableService) {
          try {
            await instance.dispose();
          } catch (e) {
// print('❌ Failed to dispose instance: $e'); // Removed for production
          }
        }
      }

      // Clear all collections
      _instances.clear();
      _factories.clear();
      _lifetimes.clear();

      _isDisposed = true;
// print('✅ Dependency Container disposed successfully'); // Removed for production
    } catch (e) {
// print('❌ Failed to dispose Dependency Container: $e'); // Removed for production
    }
  }

  /// Register a stream controller
  void registerStreamController<T>(StreamController<T> controller) {
    if (_isDisposed) return;
    _controllers[T] = controller;
  }

  /// Get a stream controller
  StreamController<T>? getStreamController<T>() {
    return _controllers[T] as StreamController<T>?;
  }

  /// Register a timer
  void registerTimer(String key, Timer timer) {
    if (_isDisposed) return;
    _timers[key] = timer;
  }

  /// Cancel a timer
  void cancelTimer(String key) {
    final timer = _timers.remove(key);
    timer?.cancel();
  }

  /// Get container statistics
  ContainerStatistics getStatistics() {
    return ContainerStatistics(
      totalRegistered: _factories.length,
      totalInitialized: _instances.length,
      singletonCount: _lifetimes.values
          .where((lifetime) => lifetime == ServiceLifetime.singleton)
          .length,
      transientCount: _lifetimes.values
          .where((lifetime) => lifetime == ServiceLifetime.transient)
          .length,
      scopedCount: _lifetimes.values
          .where((lifetime) => lifetime == ServiceLifetime.scoped)
          .length,
      streamControllerCount: _controllers.length,
      timerCount: _timers.length,
    );
  }

  /// Validate dependencies
  List<String> validateDependencies() {
    final errors = <String>[];

    for (final entry in _factories.entries) {
      try {
        final instance = _createInstance(entry.key);
        if (instance == null) {
          errors.add('Factory for ${entry.key} returned null');
        }
      } catch (e) {
        errors.add('Failed to create instance of ${entry.key}: $e');
      }
    }

    return errors;
  }

  /// Optimize container
  Future<void> optimize() async {
    try {
// print('🔧 Optimizing Dependency Container...'); // Removed for production

      // Clear expired cache entries
      // This would be implemented based on specific caching needs

      // Dispose unused instances
      final unusedInstances = <Type>[];
      for (final entry in _instances.entries) {
        if (entry.value is DisposableService) {
          final service = entry.value as DisposableService;
          if (service.isDisposed) {
            unusedInstances.add(entry.key);
          }
        }
      }

      for (final type in unusedInstances) {
        _instances.remove(type);
// print('🗑️ Removed unused instance: $type'); // Removed for production
      }

// print('✅ Dependency Container optimized successfully'); // Removed for production
    } catch (e) {
// print('❌ Failed to optimize Dependency Container: $e'); // Removed for production
    }
  }
}

/// Service lifetime enum
enum ServiceLifetime {
  singleton,
  scoped,
  transient,
}

/// Factory function type
typedef FactoryFunction = dynamic Function();

/// Disposable service interface
abstract class DisposableService {
  bool get isDisposed;
  Future<void> dispose();
}

/// Container statistics
class ContainerStatistics {
  final int totalRegistered;
  final int totalInitialized;
  final int singletonCount;
  final int transientCount;
  final int scopedCount;
  final int streamControllerCount;
  final int timerCount;

  const ContainerStatistics({
    required this.totalRegistered,
    required this.totalInitialized,
    required this.singletonCount,
    required this.transientCount,
    required this.scopedCount,
    required this.streamControllerCount,
    required this.timerCount,
  });
}

/// Global container instance
final dependencyContainer = DependencyContainer();

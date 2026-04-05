import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../app/theme/app_theme.dart';

class AuthMiddleware extends NavigatorObserver {
  final AuthProvider authProvider;
  
  AuthMiddleware({required this.authProvider});
  
  @override
  void didPush(Route route, Route? previousRoute) {
    _checkAuthentication(route);
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (newRoute != null) {
      _checkAuthentication(newRoute);
    }
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  void _checkAuthentication(Route route) {
    // Check if route requires authentication
    if (_requiresAuthentication(route)) {
      if (!authProvider.isAuthenticated) {
        // Redirect to login
        _redirectToLogin();
      }
    }
  }

  bool _requiresAuthentication(Route route) {
    final routeName = route.settings.name;
    
    // Routes that don't require authentication
    final publicRoutes = [
      '/login',
      '/register',
      '/reset-password',
      '/forgot-password',
      '/splash',
      '/onboarding',
    ];
    
    return !publicRoutes.contains(routeName);
  }

  void _redirectToLogin() {
    // Navigate to login screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigator?.pushNamed('/login');
    });
  }
}

class AuthGuard {
  static final AuthGuard _instance = AuthGuard._internal();
  factory AuthGuard() => _instance;
  AuthGuard._internal();

  final Map<String, List<String>> _roleBasedAccess = {
    '/admin': ['Admin'],
    '/accounting': ['Admin', 'Accountant'],
    '/distribution': ['Admin', 'Stockist'],
    '/mr-dashboard': ['Admin', 'MR'],
    '/ordering': ['Admin', 'Stockist', 'Retailer'],
  };

  bool canAccessRoute(String route, String? userRole) {
    if (userRole == null) return false;
    
    final requiredRoles = _roleBasedAccess[route];
    if (requiredRoles == null) return true;
    
    return requiredRoles.contains(userRole);
  }

  String? getRedirectRoute(String? userRole) {
    if (userRole == null) return '/login';
    
    switch (userRole) {
      case 'Admin':
        return '/admin/dashboard';
      case 'Accountant':
        return '/accountant/dashboard';
      case 'Stockist':
        return '/stockist/dashboard';
      case 'MR':
        return '/mr/dashboard';
      case 'Retailer':
        return '/retailer/dashboard';
      case 'Doctor':
        return '/doctor/dashboard';
      default:
        return '/dashboard';
    }
  }
}

class SecureRoute extends GoRoute {
  final List<String>? requiredRoles;
  
  const SecureRoute({
    required String path,
    required Widget Function(BuildContext, GoRouterState) builder,
    this.requiredRoles,
    String? name,
    String? parentNavigatorKey,
  }) : super(
    path: path,
    builder: builder,
    name: name,
    parentNavigatorKey: parentNavigatorKey,
  );

  @override
  Widget Function(BuildContext, GoRouterState) get builder {
    return (context, state) {
      return Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (!authProvider.isAuthenticated) {
            return _buildUnauthorizedScreen(context);
          }
          
          if (requiredRoles != null) {
            final userRole = authProvider.userRole;
            if (userRole == null || !requiredRoles.contains(userRole)) {
              return _buildAccessDeniedScreen(context);
            }
          }
          
          return super.builder(context, state);
        },
      );
    };
  }

  Widget _buildUnauthorizedScreen(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withOpacity(0.1),
              AppTheme.secondaryColor.withOpacity(0.1),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 80,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 24),
              Text(
                'Authentication Required',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Please login to access this page',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Go to Login',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccessDeniedScreen(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withOpacity(0.1),
              AppTheme.secondaryColor.withOpacity(0.1),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.block,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 24),
              Text(
                'Access Denied',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You don\'t have permission to access this page',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Go Back',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SessionManager {
  final AuthProvider authProvider;
  final VoidCallback? onSessionExpired;
  Timer? _sessionTimer;
  
  SessionManager({
    required this.authProvider,
    this.onSessionExpired,
  }) {
    _startSessionTimer();
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(
      const Duration(minutes: 1),
      (timer) => _checkSession(),
    );
  }

  void _checkSession() {
    if (authProvider.isTokenExpired) {
      _handleSessionExpired();
    }
  }

  void _handleSessionExpired() {
    _sessionTimer?.cancel();
    authProvider.logout();
    onSessionExpired?.call();
  }

  void dispose() {
    _sessionTimer?.cancel();
  }
}

class SecurityMonitor {
  final AuthProvider authProvider;
  final Map<String, DateTime> _failedAttempts = {};
  final int _maxAttempts = 5;
  final Duration _lockoutDuration = const Duration(minutes: 15);
  
  SecurityMonitor({required this.authProvider});

  void recordFailedAttempt(String identifier) {
    _failedAttempts[identifier] = DateTime.now();
    
    // Check if user should be locked out
    if (_getAttemptCount(identifier) >= _maxAttempts) {
      _lockoutUser(identifier);
    }
  }

  void recordSuccessfulAttempt(String identifier) {
    _failedAttempts.remove(identifier);
  }

  bool isLockedOut(String identifier) {
    final lastAttempt = _failedAttempts[identifier];
    if (lastAttempt == null) return false;
    
    final now = DateTime.now();
    final timeSinceLastAttempt = now.difference(lastAttempt);
    
    return timeSinceLastAttempt < _lockoutDuration;
  }

  DateTime? getLockoutEndTime(String identifier) {
    final lastAttempt = _failedAttempts[identifier];
    if (lastAttempt == null) return null;
    
    return lastAttempt.add(_lockoutDuration);
  }

  int _getAttemptCount(String identifier) {
    return _failedAttempts.entries
        .where((entry) => entry.key == identifier)
        .length;
  }

  void _lockoutUser(String identifier) {
    // Additional security measures can be implemented here
    
  }

  void clearFailedAttempts(String identifier) {
    _failedAttempts.remove(identifier);
  }
}

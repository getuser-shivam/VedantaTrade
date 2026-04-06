import 'package:vedanta_trade/app/theme/enhanced_app_theme.dart';

class VersionData {
  static final List<VersionInfo> versions = [
    VersionInfo(
      version: '3.3.0',
      releaseDate: '2024-04-04',
      title: 'Advanced UI/UX Framework',
      description: 'Complete glassmorphic design system with comprehensive testing utilities',
      features: [
        'Enhanced UI Components Library with glassmorphic design',
        'Advanced Theme System with light/dark mode support',
        'Enhanced Navigation System with smooth animations',
        'Testing & Cleanup Utilities for code quality',
        'Haptic Feedback utilities for tactile interactions',
        'Modern Snackbar and Dialog components',
        'Animation Utilities (fade, slide, scale, staggered)',
        'Responsive Layout System for adaptive design',
      ],
      screenshots: [
        'assets/screenshots/v3.3.0/gallery_home.png',
        'assets/screenshots/v3.3.0/enhanced_components.png',
        'assets/screenshots/v3.3.0/theme_system.png',
        'assets/screenshots/v3.3.0/navigation_system.png',
        'assets/screenshots/v3.3.0/testing_utilities.png',
      ],
      primaryColor: EnhancedAppTheme.primaryColor,
      flutterVersion: '3.16.0',
      buildNumber: '330',
      platformSupport: 'iOS, Android, Web',
      status: 'Production Ready',
    ),
    VersionInfo(
      version: '3.2.1-alpha',
      releaseDate: '2026-04-03',
      title: 'Comprehensive CI/CD Pipeline',
      description: 'Enterprise-grade automation with quality gates and security scanning',
      features: [
        'Complete CI/CD workflow with quality gates',
        'Automated testing suite with coverage reporting',
        'Multi-platform deployment automation',
        'Security vulnerability scanning',
        'Performance monitoring and optimization',
        'Release management with semantic versioning',
      ],
      screenshots: [
        'assets/screenshots/v3.2.1-alpha/ci_cd_dashboard.png',
        'assets/screenshots/v3.2.1-alpha/testing_suite.png',
        'assets/screenshots/v3.2.1-alpha/deployment_automation.png',
      ],
      primaryColor: EnhancedAppTheme.secondaryColor,
      flutterVersion: '3.16.0',
      buildNumber: '321',
      platformSupport: 'iOS, Android, Web',
      status: 'Alpha',
    ),
    VersionInfo(
      version: '3.2.0-alpha',
      releaseDate: '2026-04-03',
      title: 'Production Hardening',
      description: 'Production-ready infrastructure with enhanced monitoring',
      features: [
        'Production deployment automation',
        'Health checks and monitoring',
        'Performance optimization',
        'Security enhancements',
        'Documentation updates',
      ],
      screenshots: [
        'assets/screenshots/v3.2.0-alpha/production_dashboard.png',
        'assets/screenshots/v3.2.0-alpha/monitoring_system.png',
      ],
      primaryColor: EnhancedAppTheme.accentColor,
      flutterVersion: '3.16.0',
      buildNumber: '320',
      platformSupport: 'iOS, Android, Web',
      status: 'Alpha',
    ),
    VersionInfo(
      version: '3.1.0',
      releaseDate: '2024-04-01',
      title: 'Core Business Features',
      description: 'Complete business functionality with multi-role system',
      features: [
        'Multi-role user system (Admin, Accountant, Stockist, MR, Retailer)',
        'Product management with SKU tracking',
        'Order management with status tracking',
        'Inventory management with stock alerts',
        'Financial accounting with transaction tracking',
        'Visit logging for medical representatives',
        'Tour planning with route optimization',
      ],
      screenshots: [
        'assets/screenshots/v3.1.0/dashboard.png',
        'assets/screenshots/v3.1.0/product_management.png',
        'assets/screenshots/v3.1.0/order_tracking.png',
        'assets/screenshots/v3.1.0/user_roles.png',
      ],
      primaryColor: Colors.green,
      flutterVersion: '3.15.0',
      buildNumber: '310',
      platformSupport: 'iOS, Android, Web',
      status: 'Production Ready',
    ),
    VersionInfo(
      version: '3.0.0',
      releaseDate: '2024-03-15',
      title: 'Major Release',
      description: 'Complete Flutter application rewrite with modern architecture',
      features: [
        'Complete Flutter application rewrite',
        'Clean Architecture implementation',
        'Modern UI/UX design system',
        'Comprehensive feature set for pharmaceutical distribution',
        'Multi-platform support (iOS, Android, Web)',
        'Real-time data synchronization',
        'Advanced security features',
        'Performance optimizations',
      ],
      screenshots: [
        'assets/screenshots/v3.0.0/home_screen.png',
        'assets/screenshots/v3.0.0/login_screen.png',
        'assets/screenshots/v3.0.0/product_catalog.png',
        'assets/screenshots/v3.0.0/user_dashboard.png',
      ],
      primaryColor: Colors.blue,
      flutterVersion: '3.15.0',
      buildNumber: '300',
      platformSupport: 'iOS, Android, Web',
      status: 'Production Ready',
    ),
    VersionInfo(
      version: '2.5.0',
      releaseDate: '2024-02-15',
      title: 'Feature Complete',
      description: 'Complete feature implementation with enhanced UI',
      features: [
        '6-role architecture implementation',
        'Geospatial field force tracking',
        'Product catalog with search',
        'Distribution management',
        'Marketing system',
      ],
      screenshots: [
        'assets/screenshots/v2.5.0/feature_dashboard.png',
        'assets/screenshots/v2.5.0/geospatial_tracking.png',
        'assets/screenshots/v2.5.0/product_catalog.png',
      ],
      primaryColor: Colors.purple,
      flutterVersion: '3.12.0',
      buildNumber: '250',
      platformSupport: 'iOS, Android',
      status: 'Stable',
    ),
    VersionInfo(
      version: '2.0.0',
      releaseDate: '2024-01-15',
      title: 'Architecture Overhaul',
      description: 'Clean Architecture implementation with modern design',
      features: [
        'Clean Architecture refactoring',
        'Modern UI implementation',
        'Enhanced authentication system',
        'Improved performance',
      ],
      screenshots: [
        'assets/screenshots/v2.0.0/architecture_overview.png',
        'assets/screenshots/v2.0.0/modern_ui.png',
        'assets/screenshots/v2.0.0/authentication.png',
      ],
      primaryColor: Colors.orange,
      flutterVersion: '3.10.0',
      buildNumber: '200',
      platformSupport: 'iOS, Android',
      status: 'Stable',
    ),
  ];
}

class VersionInfo {
  final String version;
  final String releaseDate;
  final String title;
  final String description;
  final List<String> features;
  final List<String> screenshots;
  final Color primaryColor;
  final String flutterVersion;
  final String buildNumber;
  final String platformSupport;
  final String status;

  VersionInfo({
    required this.version,
    required this.releaseDate,
    required this.title,
    required this.description,
    required this.features,
    required this.screenshots,
    required this.primaryColor,
    required this.flutterVersion,
    required this.buildNumber,
    required this.platformSupport,
    required this.status,
  });

  bool get isLatest => version == VersionData.versions.first.version;
  bool get isNew => status.contains('Alpha') || status.contains('Beta');
  bool get isProductionReady => status == 'Production Ready';
  
  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'production ready':
        return '✅ Production Ready';
      case 'alpha':
        return '🧪 Alpha';
      case 'beta':
        return '🧪 Beta';
      case 'stable':
        return '✅ Stable';
      default:
        return status;
    }
  }
}

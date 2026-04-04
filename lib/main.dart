import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_trade/app/app.dart';
import 'package:vedanta_trade/features/auth/presentation/providers/auth_provider.dart';
import 'package:vedanta_trade/providers/theme_provider.dart';
import 'package:vedanta_trade/features/catalog/presentation/providers/product_provider.dart';
import 'package:vedanta_trade/features/catalog/data/services/product_catalog_service.dart';
import 'package:vedanta_trade/shared/theme/enhanced_theme.dart';
import 'package:vedanta_trade/shared/widgets/accessibility/enhanced_accessibility.dart';
import 'package:vedanta_trade/shared/widgets/performance/performance_optimizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize enhanced UI/UX features
  _initializeEnhancedFeatures();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ProductProvider>(
          create: (_) => ProductProvider(catalogService: ProductCatalogService()),
          update: (context, auth, previous) => ProductProvider(
            catalogService: ProductCatalogService(),
            token: auth?.token,
          ),
        ),
      ],
      child: const VedantaTradeApp(),
    ),
  );
}

void _initializeEnhancedFeatures() {
  // Enable performance monitoring in debug mode
  if (const bool.fromEnvironment('dart.vm.product') == false) {
    PerformanceOptimizer.enablePerformanceMonitoring();
  }
  
  // Initialize accessibility settings
  EnhancedAccessibility.screenReader = false;
  EnhancedAccessibility.highContrast = false;
  EnhancedAccessibility.largeText = false;
  EnhancedAccessibility.reducedMotion = false;
  EnhancedAccessibility.textScaleFactor = 1.0;
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_trade/app/app.dart';
import 'package:vedanta_trade/features/auth/presentation/providers/auth_provider.dart';
import 'package:vedanta_trade/providers/theme_provider.dart';
import 'package:vedanta_trade/features/catalog/presentation/providers/product_provider.dart';
import 'package:vedanta_trade/features/catalog/data/services/product_catalog_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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

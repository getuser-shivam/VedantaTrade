import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_trade/app/app.dart';
import 'package:vedanta_trade/providers/auth_provider.dart';
import 'package:vedanta_trade/providers/theme_provider.dart';
import 'package:vedanta_trade/providers/product_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: const VedantaTradeApp(),
    ),
  );
}

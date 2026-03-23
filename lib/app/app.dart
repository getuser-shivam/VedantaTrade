import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_trade/providers/auth_provider.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';

// Screens
import 'package:vedanta_trade/features/auth/login_screen.dart';
import 'package:vedanta_trade/features/splash/splash_screen.dart';
import 'package:vedanta_trade/features/admin/admin_dashboard.dart';
import 'package:vedanta_trade/features/admin/admin_media_upload_screen.dart';
import 'package:vedanta_trade/features/admin/user_management_screen.dart';
import 'package:vedanta_trade/features/admin/scraper_screen.dart';
import 'package:vedanta_trade/features/mr/mr_dashboard.dart';
import 'package:vedanta_trade/features/mr/visit_log_screen.dart';
import 'package:vedanta_trade/features/mr/tour_plan_screen.dart';
import 'package:vedanta_trade/features/mr/expense_screen.dart';
import 'package:vedanta_trade/features/accounting/accountant_dashboard.dart';
import 'package:vedanta_trade/features/accounting/invoice_screen.dart';
import 'package:vedanta_trade/features/accounting/ledger_screen.dart';
import 'package:vedanta_trade/features/accounting/gst_screen.dart';
import 'package:vedanta_trade/features/doctor/doctor_dashboard.dart';
import 'package:vedanta_trade/features/stockist/stockist_dashboard.dart';
import 'package:vedanta_trade/features/retailer/retailer_dashboard.dart';
import 'package:vedanta_trade/features/products/products_screen.dart';
import 'package:vedanta_trade/features/doctors_list/doctors_list_screen.dart';
import 'package:vedanta_trade/features/orders/orders_screen.dart';
import 'package:vedanta_trade/features/profile/profile_screen.dart';

class VedantaTradeApp extends StatelessWidget {
  const VedantaTradeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Consumer(
          builder: (context, _, __) => MaterialApp.router(
            title: 'VedantaTrade',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark,
            routerConfig: _buildRouter(auth),
          ),
        );
      },
    );
  }

  GoRouter _buildRouter(AuthProvider auth) {
    return GoRouter(
      initialLocation: '/splash',
      redirect: (context, state) {
        final isLoggedIn = auth.isLoggedIn;
        final location = state.matchedLocation;

        if (location == '/splash') return null;
        if (!isLoggedIn && location != '/login') return '/login';
        if (isLoggedIn && location == '/login') return _dashboardForRole(auth.userRole);
        return null;
      },
      routes: [
        GoRoute(path: '/splash', builder: (c, s) => const SplashScreen()),
        GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
        GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen()),
        GoRoute(path: '/products', builder: (c, s) => const ProductsScreen()),
        GoRoute(path: '/doctors-list', builder: (c, s) => const DoctorsListScreen()),
        GoRoute(path: '/orders', builder: (c, s) => const OrdersScreen()),

        // Admin routes
        GoRoute(path: '/admin', builder: (c, s) => const AdminDashboard()),
        GoRoute(path: '/admin/users', builder: (c, s) => const UserManagementScreen()),
        GoRoute(path: '/admin/scraper', builder: (c, s) => const ScraperScreen()),
        GoRoute(path: '/admin/media-upload', builder: (c, s) => const AdminMediaUploadScreen()),

        // MR routes
        GoRoute(path: '/mr', builder: (c, s) => const MrDashboard()),
        GoRoute(path: '/mr/visits', builder: (c, s) => const VisitLogScreen()),
        GoRoute(path: '/mr/tour-plan', builder: (c, s) => const TourPlanScreen()),
        GoRoute(path: '/mr/expenses', builder: (c, s) => const ExpenseScreen()),

        // Accounting routes
        GoRoute(path: '/accounting', builder: (c, s) => const AccountantDashboard()),
        GoRoute(path: '/accounting/invoices', builder: (c, s) => const InvoiceScreen()),
        GoRoute(path: '/accounting/ledger', builder: (c, s) => const LedgerScreen()),
        GoRoute(path: '/accounting/gst', builder: (c, s) => const GstScreen()),

        // Doctor routes
        GoRoute(path: '/doctor', builder: (c, s) => const DoctorDashboard()),

        // Stockist routes
        GoRoute(path: '/stockist', builder: (c, s) => const StockistDashboard()),

        // Retailer routes
        GoRoute(path: '/retailer', builder: (c, s) => const RetailerDashboard()),
      ],
    );
  }

  String _dashboardForRole(String? role) {
    switch (role) {
      case 'ADMIN': return '/admin';
      case 'MEDICAL_REP': return '/mr';
      case 'ACCOUNTANT': return '/accounting';
      case 'DOCTOR': return '/doctor';
      case 'STOCKIST': return '/stockist';
      case 'RETAILER': return '/retailer';
      default: return '/login';
    }
  }
}

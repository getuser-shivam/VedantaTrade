import 'package:flutter/material.dart';
import 'navigation_item.dart';
import 'app_routes.dart';

/// Navigation Configuration
/// Provides navigation items for different user roles and contexts
class NavigationConfig {
  NavigationConfig._();

  /// Main navigation items for general users
  static const List<NavigationItem> mainNavigationItems = [
    NavigationItem(
      id: 'home',
      label: 'Home',
      icon: Icons.home_rounded,
      activeIcon: Icons.home_filled,
      route: AppRoutes.home,
    ),
    NavigationItem(
      id: 'catalog',
      label: 'Catalog',
      icon: Icons.inventory_2_rounded,
      activeIcon: Icons.inventory_2,
      route: AppRoutes.catalog,
    ),
    NavigationItem(
      id: 'orders',
      label: 'Orders',
      icon: Icons.shopping_bag_rounded,
      activeIcon: Icons.shopping_bag,
      route: AppRoutes.orders,
    ),
    NavigationItem(
      id: 'notifications',
      label: 'Notifications',
      icon: Icons.notifications_rounded,
      activeIcon: Icons.notifications,
      route: AppRoutes.notifications,
      badge: '5',
    ),
    NavigationItem(
      id: 'profile',
      label: 'Profile',
      icon: Icons.person_rounded,
      activeIcon: Icons.person,
      route: AppRoutes.profile,
    ),
  ];

  /// Admin navigation items
  static const List<NavigationItem> adminNavigationItems = [
    NavigationItem(
      id: 'admin-dashboard',
      label: 'Dashboard',
      icon: Icons.dashboard_rounded,
      route: AppRoutes.adminDashboard,
    ),
    NavigationItem(
      id: 'users',
      label: 'Users',
      icon: Icons.people_rounded,
      route: AppRoutes.users,
    ),
    NavigationItem(
      id: 'products',
      label: 'Products',
      icon: Icons.inventory_2_rounded,
      route: AppRoutes.products,
    ),
    NavigationItem(
      id: 'media-upload',
      label: 'Media',
      icon: Icons.cloud_upload_rounded,
      route: AppRoutes.mediaUpload,
    ),
    NavigationItem(
      id: 'scraper',
      label: 'Scraper',
      icon: Icons.travel_explore_rounded,
      route: AppRoutes.scraper,
    ),
    NavigationItem(
      id: 'map',
      label: 'Map',
      icon: Icons.map_rounded,
      route: AppRoutes.map,
    ),
    NavigationItem(
      id: 'profile',
      label: 'Profile',
      icon: Icons.person_rounded,
      route: AppRoutes.profile,
    ),
  ];

  /// Medical Rep navigation items
  static const List<NavigationItem> medicalRepNavigationItems = [
    NavigationItem(
      id: 'mr-dashboard',
      label: 'Dashboard',
      icon: Icons.dashboard_rounded,
      route: AppRoutes.fieldForceDashboard,
    ),
    NavigationItem(
      id: 'expenses',
      label: 'Expenses',
      icon: Icons.receipt_long_rounded,
      route: AppRoutes.expenseSubmission,
    ),
    NavigationItem(
      id: 'gps-tracking',
      label: 'GPS Tracking',
      icon: Icons.location_on_rounded,
      route: AppRoutes.gpsTracking,
    ),
    NavigationItem(
      id: 'routes',
      label: 'Routes',
      icon: Icons.route_rounded,
      route: AppRoutes.routeOptimization,
    ),
    NavigationItem(
      id: 'visits',
      label: 'Visits',
      icon: Icons.calendar_today_rounded,
      route: AppRoutes.customerVisits,
    ),
    NavigationItem(
      id: 'profile',
      label: 'Profile',
      icon: Icons.person_rounded,
      route: AppRoutes.profile,
    ),
  ];

  /// Accountant navigation items
  static const List<NavigationItem> accountantNavigationItems = [
    NavigationItem(
      id: 'accounting-dashboard',
      label: 'Dashboard',
      icon: Icons.dashboard_rounded,
      route: AppRoutes.accountingDashboard,
    ),
    NavigationItem(
      id: 'vat-returns',
      label: 'VAT Returns',
      icon: Icons.receipt_long_rounded,
      route: AppRoutes.vatReturns,
    ),
    NavigationItem(
      id: 'expenses',
      label: 'Expenses',
      icon: Icons.money_off_rounded,
      route: AppRoutes.expenses,
    ),
    NavigationItem(
      id: 'reports',
      label: 'Reports',
      icon: Icons.analytics_rounded,
      route: AppRoutes.reports,
    ),
    NavigationItem(
      id: 'invoices',
      label: 'Invoices',
      icon: Icons.description_rounded,
      route: AppRoutes.invoices,
    ),
    NavigationItem(
      id: 'ledger',
      label: 'Ledger',
      icon: Icons.menu_book_rounded,
      route: AppRoutes.ledger,
    ),
    NavigationItem(
      id: 'profile',
      label: 'Profile',
      icon: Icons.person_rounded,
      route: AppRoutes.profile,
    ),
  ];

  /// Doctor navigation items
  static const List<NavigationItem> doctorNavigationItems = [
    NavigationItem(
      id: 'doctor-dashboard',
      label: 'Dashboard',
      icon: Icons.dashboard_rounded,
      route: AppRoutes.doctorDashboard,
    ),
    NavigationItem(
      id: 'prescriptions',
      label: 'Prescriptions',
      icon: Icons.medication_rounded,
      route: AppRoutes.doctorPrescriptions,
    ),
    NavigationItem(
      id: 'patients',
      label: 'Patients',
      icon: Icons.people_rounded,
      route: AppRoutes.doctorPatients,
    ),
    NavigationItem(
      id: 'analytics',
      label: 'Analytics',
      icon: Icons.analytics_rounded,
      route: AppRoutes.doctorAnalytics,
    ),
    NavigationItem(
      id: 'profile',
      label: 'Profile',
      icon: Icons.person_rounded,
      route: AppRoutes.profile,
    ),
  ];

  /// Stockist navigation items
  static const List<NavigationItem> stockistNavigationItems = [
    NavigationItem(
      id: 'stockist-dashboard',
      label: 'Dashboard',
      icon: Icons.dashboard_rounded,
      route: AppRoutes.stockistDashboard,
    ),
    NavigationItem(
      id: 'inventory',
      label: 'Inventory',
      icon: Icons.inventory_2_rounded,
      route: AppRoutes.stockistInventory,
    ),
    NavigationItem(
      id: 'orders',
      label: 'Orders',
      icon: Icons.shopping_bag_rounded,
      route: AppRoutes.stockistOrders,
    ),
    NavigationItem(
      id: 'transfers',
      label: 'Transfers',
      icon: Icons.local_shipping_rounded,
      route: AppRoutes.stockistTransfers,
    ),
    NavigationItem(
      id: 'reports',
      label: 'Reports',
      icon: Icons.analytics_rounded,
      route: AppRoutes.stockistReports,
    ),
    NavigationItem(
      id: 'profile',
      label: 'Profile',
      icon: Icons.person_rounded,
      route: AppRoutes.profile,
    ),
  ];

  /// Retailer navigation items
  static const List<NavigationItem> retailerNavigationItems = [
    NavigationItem(
      id: 'retailer-dashboard',
      label: 'Dashboard',
      icon: Icons.dashboard_rounded,
      route: AppRoutes.retailerDashboard,
    ),
    NavigationItem(
      id: 'catalog',
      label: 'Catalog',
      icon: Icons.inventory_2_rounded,
      route: AppRoutes.catalog,
    ),
    NavigationItem(
      id: 'orders',
      label: 'Orders',
      icon: Icons.shopping_bag_rounded,
      route: AppRoutes.retailerOrders,
    ),
    NavigationItem(
      id: 'wishlist',
      label: 'Wishlist',
      icon: Icons.favorite_rounded,
      route: AppRoutes.wishlist,
    ),
    NavigationItem(
      id: 'profile',
      label: 'Profile',
      icon: Icons.person_rounded,
      route: AppRoutes.profile,
    ),
  ];

  /// Distribution navigation items
  static const List<NavigationItem> distributionNavigationItems = [
    NavigationItem(
      id: 'distribution-dashboard',
      label: 'Dashboard',
      icon: Icons.dashboard_rounded,
      route: AppRoutes.distributionDashboard,
    ),
    NavigationItem(
      id: 'centers',
      label: 'Centers',
      icon: Icons.warehouse_rounded,
      route: AppRoutes.distributionCenters,
    ),
    NavigationItem(
      id: 'sales',
      label: 'Sales',
      icon: Icons.trending_up_rounded,
      route: AppRoutes.salesDashboard,
    ),
    NavigationItem(
      id: 'marketing',
      label: 'Marketing',
      icon: Icons.campaign_rounded,
      route: AppRoutes.marketingCampaigns,
    ),
    NavigationItem(
      id: 'profile',
      label: 'Profile',
      icon: Icons.person_rounded,
      route: AppRoutes.profile,
    ),
  ];

  /// Get navigation items for a specific role
  static List<NavigationItem> getNavigationItemsForRole(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return adminNavigationItems;
      case 'MEDICAL_REP':
      case 'MR':
        return medicalRepNavigationItems;
      case 'ACCOUNTANT':
        return accountantNavigationItems;
      case 'DOCTOR':
        return doctorNavigationItems;
      case 'STOCKIST':
        return stockistNavigationItems;
      case 'RETAILER':
        return retailerNavigationItems;
      case 'DISTRIBUTION':
        return distributionNavigationItems;
      default:
        return mainNavigationItems;
    }
  }

  /// Check if a route is accessible for a given role
  static bool isRouteAccessible(String route, String role) {
    final items = getNavigationItemsForRole(role);
    return items.any((item) => route.startsWith(item.route));
  }

  /// Get navigation item by route
  static NavigationItem? getNavigationItemByRoute(String route, String role) {
    final items = getNavigationItemsForRole(role);
    for (final item in items) {
      if (route.startsWith(item.route)) {
        return item;
      }
    }
    return null;
  }

  /// Get navigation index by route
  static int getNavigationIndexByRoute(String route, String role) {
    final items = getNavigationItemsForRole(role);
    for (int i = 0; i < items.length; i++) {
      if (route.startsWith(items[i].route)) {
        return i;
      }
    }
    return 0;
  }
}

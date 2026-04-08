/// App Routes Constants
/// Centralized route definitions for the entire application
class AppRoutes {
  AppRoutes._();

  // Authentication Routes
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String verifyEmail = '/verify-email';

  // Main Navigation Routes
  static const String home = '/';
  static const String catalog = '/catalog';
  static const String orders = '/orders';
  static const String profile = '/profile';
  static const String notifications = '/notifications';
  static const String settings = '/settings';

  // Product Catalog Routes
  static const String productDetail = '/product/:id';
  static const String productComparison = '/products/compare';
  static const String categoryProducts = '/category/:id';
  static const String searchResults = '/search';

  // Distribution Routes
  static const String distributionDashboard = '/distribution';
  static const String distributionCenters = '/distribution/centers';
  static const String addDistributionCenter = '/distribution/centers/add';
  static const String editDistributionCenter = '/distribution/centers/:id/edit';
  static const String salesDashboard = '/distribution/sales';
  static const String salesAnalytics = '/distribution/sales/analytics';
  static const String marketingCampaigns = '/distribution/marketing';
  static const String marketingAnalytics = '/distribution/marketing/analytics';

  // Accounting Routes
  static const String accountingDashboard = '/accounting';
  static const String vatReturns = '/accounting/vat';
  static const String vatReturnDetails = '/accounting/vat/:id';
  static const String expenses = '/accounting/expenses';
  static const String expenseDetails = '/accounting/expenses/:id';
  static const String expenseCreate = '/accounting/expenses/create';
  static const String reports = '/accounting/reports';
  static const String invoices = '/accounting/invoices';
  static const String invoiceDetails = '/accounting/invoices/:id';
  static const String ledger = '/accounting/ledger';

  // Admin Routes
  static const String adminDashboard = '/admin';
  static const String users = '/admin/users';
  static const String userDetails = '/admin/users/:id';
  static const String userCreate = '/admin/users/create';
  static const String products = '/admin/products';
  static const String productDetails = '/admin/products/:id';
  static const String productCreate = '/admin/products/create';
  static const String mediaUpload = '/admin/media';
  static const String scraper = '/admin/scraper';
  static const String map = '/admin/map';
  static const String reportsAdmin = '/admin/reports';

  // Field Force Routes
  static const String fieldForceDashboard = '/field-force';
  static const String expenseSubmission = '/field-force/expense';
  static const String gpsTracking = '/field-force/gps';
  static const String routeOptimization = '/field-force/routes';
  static const String customerVisits = '/field-force/visits';

  // Retailer Routes
  static const String retailerDashboard = '/retailer';
  static const String retailerOrders = '/retailer/orders';
  static const String orderDetails = '/orders/:id';
  static const String checkout = '/retailer/checkout';
  static const String payment = '/retailer/payment';
  static const String paymentSuccess = '/retailer/payment/success';
  static const String paymentFailed = '/retailer/payment/failed';
  static const String wishlist = '/retailer/wishlist';

  // Stockist Routes
  static const String stockistDashboard = '/stockist';
  static const String stockistInventory = '/stockist/inventory';
  static const String stockistOrders = '/stockist/orders';
  static const String stockistTransfers = '/stockist/transfers';
  static const String stockistReports = '/stockist/reports';

  // Doctor Routes
  static const String doctorDashboard = '/doctor';
  static const String doctorPrescriptions = '/doctor/prescriptions';
  static const String doctorPatients = '/doctor/patients';
  static const String doctorAnalytics = '/doctor/analytics';

  // Cart Routes
  static const String cart = '/cart';
  static const String cartCheckout = '/cart/checkout';

  // Get all routes for validation
  static List<String> get allRoutes => [
        // Authentication
        login,
        register,
        forgotPassword,
        resetPassword,
        verifyEmail,
        // Main Navigation
        home,
        catalog,
        orders,
        profile,
        notifications,
        settings,
        // Product Catalog
        productDetail,
        productComparison,
        categoryProducts,
        searchResults,
        // Distribution
        distributionDashboard,
        distributionCenters,
        addDistributionCenter,
        editDistributionCenter,
        salesDashboard,
        salesAnalytics,
        marketingCampaigns,
        marketingAnalytics,
        // Accounting
        accountingDashboard,
        vatReturns,
        vatReturnDetails,
        expenses,
        expenseDetails,
        expenseCreate,
        reports,
        invoices,
        invoiceDetails,
        ledger,
        // Admin
        adminDashboard,
        users,
        userDetails,
        userCreate,
        products,
        productDetails,
        productCreate,
        mediaUpload,
        scraper,
        map,
        reportsAdmin,
        // Field Force
        fieldForceDashboard,
        expenseSubmission,
        gpsTracking,
        routeOptimization,
        customerVisits,
        // Retailer
        retailerDashboard,
        retailerOrders,
        orderDetails,
        checkout,
        payment,
        paymentSuccess,
        paymentFailed,
        wishlist,
        // Stockist
        stockistDashboard,
        stockistInventory,
        stockistOrders,
        stockistTransfers,
        stockistReports,
        // Doctor
        doctorDashboard,
        doctorPrescriptions,
        doctorPatients,
        doctorAnalytics,
        // Cart
        cart,
        cartCheckout,
      ];

  // Public routes (no authentication required)
  static const List<String> publicRoutes = [
    login,
    register,
    forgotPassword,
    resetPassword,
    verifyEmail,
  ];

  // Check if route is public
  static bool isPublic(String route) {
    return publicRoutes.contains(route);
  }

  // Get base route from a route with parameters
  static String getBaseRoute(String route) {
    return route.split('/').first;
  }

  // Check if route has parameters
  static bool hasParameters(String route) {
    return route.contains(':');
  }
}

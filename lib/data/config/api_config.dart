class ApiConfig {
  static const String baseUrl = 'AppConstants.localApiUrl/api';
  
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Endpoints
  static const String productsCatalog = '/products/catalog';
  static const String productDetails = '/products/';
  static const String productCategories = '/products/categories';
  static const String productManufacturers = '/products/manufacturers';
  static const String productSearch = '/products/search';
  
  // Authentication endpoints
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refresh = '/auth/refresh';
  
  // User endpoints
  static const String userProfile = '/users/profile';
  static const String userFavorites = '/users/favorites';
  
  // Inventory endpoints
  static const String inventoryItems = '/inventory/items';
  static const String inventoryTransactions = '/inventory/transactions';
  
  // Analytics endpoints
  static const String analyticsSales = '/analytics/sales';
  static const String analyticsInventory = '/analytics/inventory';
  static const String analyticsPerformance = '/analytics/performance';
  
  // Order management endpoints
  static const String orders = '/orders';
  static const String orderDetails = '/orders/';
  
  // Financial endpoints
  static const String transactions = '/financial/transactions';
  static const String vatReturns = '/financial/vat-returns';
  static const String expenses = '/financial/expenses';
}

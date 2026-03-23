class ApiConfig {
  static const String baseUrl = 'http://192.168.1.79:3001/api';
  static const String health = '$baseUrl/health';
  
  // Auth endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String me = '$baseUrl/auth/me';
  
  // MR endpoints
  static const String mrDashboard = '$baseUrl/mr/dashboard';
  static const String mrVisits = '$baseUrl/mr/visits';
  
  // Admin endpoints
  static const String adminDashboard = '$baseUrl/users/admin/dashboard';
  static const String adminUsers = '$baseUrl/users';
  static const String scraperJobs = '$baseUrl/scraper/jobs';
  
  // Accounting endpoints
  static const String accountantDashboard = '$baseUrl/accounting/dashboard';
}

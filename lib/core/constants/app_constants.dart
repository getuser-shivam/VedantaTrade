/// Application-wide constants
class AppConstants {
  // App information
  static const String appName = 'VedantaTrade';
  static const String appVersion = '3.4.0';
  static const String appDescription = 'Pharmaceutical Distribution System';
  
  // Nepal-specific constants
  static const String defaultCurrency = 'NPR';
  static const String defaultCountry = 'NP';
  static const String defaultTimezone = 'Asia/Kathmandu';
  static const double vatRate = 0.13; // 13% VAT
  
  // API constants
  static const String apiBaseUrl = 'AppConstants.apiBaseUrl';
  static const int apiTimeout = 30000; // 30 seconds
  static const int connectTimeout = 10000; // 10 seconds
  static const int receiveTimeout = 10000; // 10 seconds
  
  // Storage keys
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String biometricEnabledKey = 'biometric_enabled';
  static const String deviceIdKey = 'device_id';
  static const String lastLoginKey = 'last_login';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // File upload limits
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx'];
  
  // Cache duration
  static const Duration defaultCacheDuration = Duration(hours: 24);
  static const Duration shortCacheDuration = Duration(minutes: 15);
  static const Duration longCacheDuration = Duration(days: 7);
  
  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);
  
  // Layout constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  
  // Text constants
  static const int maxUsernameLength = 50;
  static const int maxPasswordLength = 128;
  static const int minPasswordLength = 8;
  static const int maxPhoneNumberLength = 15;
  static const int maxEmailLength = 100;
  
  // Business constants
  static const int maxRetries = 3;
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);
  static const Duration sessionTimeout = Duration(hours: 8);
  
  // Feature flags
  static const bool enableBiometricAuth = true;
  static const bool enableTwoFactorAuth = true;
  static const bool enableOfflineMode = true;
  static const bool enableAnalytics = true;
  static const bool enableNotifications = true;
  
  // Development constants
  static const bool isDebugMode = true;
  static const bool enableLogging = true;
  static const bool enableCrashReporting = true;
  
  // Nepal business constants
  static const List<String> nepalProvinces = [
    'Province No. 1',
    'Province No. 2',
    'Bagmati Province',
    'Gandaki Province',
    'Province No. 5',
    'Karnali Province',
    'Sudurpaschim Province'
  ];
  
  static const Map<String, List<String>> nepalDistricts = {
    'Province No. 1': ['Bhojpur', 'Dhankuta', 'Ilam', 'Jhapa', 'Khotang', 'Morang', 'Okhaldhunga', 'Panchthar', 'Sankhuwasabha', 'Solukhumbu', 'Sunsari', 'Taplejung', 'Terhathum', 'Udayapur'],
    'Province No. 2': ['Bara', 'Dhanusha', 'Mahottari', 'Parsa', 'Rautahat', 'Saptari', 'Sarlahi', 'Siraha'],
    'Bagmati Province': ['Bhaktapur', 'Chitwan', 'Dhading', 'Dolakha', 'Kathmandu', 'Kavrepalanchok', 'Lalitpur', 'Makwanpur', 'Nuwakot', 'Ramechhap', 'Rasuwa', 'Sindhuli', 'Sindhupalchok'],
    'Gandaki Province': ['Baglung', 'Gorkha', 'Kaski', 'Lamjung', 'Manang', 'Mustang', 'Myagdi', 'Nawalpur', 'Parbat', 'Syangja', 'Tanahu'],
    'Province No. 5': ['Arghakhanchi', 'Banke', 'Bardiya', 'Dang', 'East Rukum', 'Gulmi', 'Kapilvastu', 'Navalparasi', 'Palpa', 'Pyuthan', 'Rolpa', 'Rupandehi', 'West Rukum'],
    'Karnali Province': ['Dailekh', 'Dolpa', 'Humla', 'Jajarkot', 'Jumla', 'Kalikot', 'Mugu', 'Salyan', 'Surkhet'],
    'Sudurpaschim Province': ['Achham', 'Bajhang', 'Bajura', 'Baitadi', 'Dadeldhura', 'Darchula', 'Doti', 'Kailali', 'Kanchanpur'],
  };
  
  // Private constructor to prevent instantiation
  AppConstants._();
}

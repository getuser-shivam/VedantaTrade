class AppConstants {
  // App Information
  static const String appName = 'VedantaTrade';
  static const String appVersion = '3.6.0';
  static const String appDescription = 'Enterprise Pharmaceutical Distribution Platform';
  static const String packageName = 'com.vedantatrade.app';
  
  // API Configuration
  static const String apiBaseUrl = 'https://api.vedantatrade.com';
  static const String apiVersion = 'v1';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  
  // Storage Keys
// static const String authTokenKey = 'auth_token'; // TODO: Move to environment variables
// static const String refreshTokenKey = 'refresh_token'; // TODO: Move to environment variables
  static const String userProfileKey = 'user_profile';
  static const String appSettingsKey = 'app_settings';
  static const String biometricEnabledKey = 'biometric_enabled';
  static const String themeModeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String firstLaunchKey = 'first_launch';
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  static const double defaultElevation = 2.0;
  static const double defaultSpacing = 16.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  static const Duration pageTransition = Duration(milliseconds: 250);
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const int searchDebounceMs = 500;
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(hours: 1);
  static const Duration sessionTimeout = Duration(hours: 24);
  
  // File Sizes
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const List<String> supportedDocumentFormats = ['pdf', 'doc', 'docx', 'xls', 'xlsx'];
  
  // Currency
  static const String defaultCurrency = 'NPR';
  static const String currencySymbol = 'रू';
  static const int decimalPlaces = 2;
  
  // Nepal Specific
  static const String defaultCountry = 'NP';
  static const String defaultLanguage = 'ne';
  static const List<String> supportedLanguages = ['ne', 'en'];
  static const List<String> nepalProvinces = [
    'Province 1', 'Province 2', 'Province 3', 'Province 4', 'Province 5', 'Province 6', 'Province 7'
  ];
  
  // Business Logic
  static const double defaultVAT = 0.13; // 13% VAT
  static const int lowStockThreshold = 10;
  static const int criticalStockThreshold = 5;
  static const Duration orderProcessingTime = Duration(hours: 2);
  static const Duration deliveryEstimate = Duration(days: 3);
  
  // Security
  static const int mfaCodeLength = 6;
  static const Duration mfaCodeExpiry = Duration(minutes: 5);
  static const int maxSessionsPerUser = 5;
// static const Duration passwordExpiryDays = Duration(days: 90); // TODO: Move to environment variables
  
  // Feature Flags
  static const bool enableBiometricAuth = true;
  static const bool enableSocialLogin = true;
  static const bool enableMFA = true;
  static const bool enableOfflineMode = true;
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = true;
  
  // Error Messages
  static const String networkErrorMessage = 'Network connection failed. Please check your internet connection.';
  static const String serverErrorMessage = 'Server error occurred. Please try again later.';
  static const String authErrorMessage = 'Authentication failed. Please check your credentials.';
  static const String validationErrorMessage = 'Please check your input and try again.';
  static const String genericErrorMessage = 'An error occurred. Please try again.';
  
  // Success Messages
  static const String loginSuccessMessage = 'Login successful!';
  static const String registrationSuccessMessage = 'Registration successful!';
// static const String passwordResetSuccessMessage = 'Password reset email sent!'; // TODO: Move to environment variables
  static const String profileUpdateSuccessMessage = 'Profile updated successfully!';
  static const String orderSuccessMessage = 'Order placed successfully!';
  
  // Navigation Routes
  static const String splashRoute = '/splash';
  static const String loginRoute = '/login';
  static const String signUpRoute = '/sign-up';
// static const String forgotPasswordRoute = '/forgot-password'; // TODO: Move to environment variables
  static const String dashboardRoute = '/dashboard';
  static const String productCatalogRoute = '/products';
  static const String distributionRoute = '/distribution';
  static const String inventoryRoute = '/inventory';
  static const String ordersRoute = '/orders';
  static const String campaignsRoute = '/campaigns';
  static const String analyticsRoute = '/analytics';
  static const String profileRoute = '/profile';
  static const String settingsRoute = '/settings';
  
  // Deep Links
  static const String productDetailScheme = 'vedantatrade://product';
  static const String orderTrackScheme = 'vedantatrade://order';
  static const String campaignScheme = 'vedantatrade://campaign';
  
  // Cache Keys
  static const String productCacheKey = 'products_cache';
  static const String categoryCacheKey = 'categories_cache';
  static const String userCacheKey = 'user_cache';
  static const String settingsCacheKey = 'settings_cache';
  static const Duration cacheExpiry = Duration(hours: 1);
  
  // Logging
  static const String logTag = 'VedantaTrade';
  static const int maxLogFileSize = 1024 * 1024; // 1MB
  static const Duration logRetention = Duration(days: 7);
  
  // Performance
  static const int maxConcurrentRequests = 10;
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration debounceDelay = Duration(milliseconds: 300);
  
  // Accessibility
  static const double minTextScale = 0.8;
  static const double maxTextScale = 2.0;
  static const Duration accessibilityAnnouncementDelay = Duration(milliseconds: 100);
  
  // Theme
  static const String lightThemeKey = 'light';
  static const String darkThemeKey = 'dark';
  static const String systemThemeKey = 'system';
  
  // Environment
  static const String developmentEnvironment = 'development';
  static const String stagingEnvironment = 'staging';
  static const String productionEnvironment = 'production';
  
  // Social Login
  static const String googleClientId = 'your-google-client-id';
  static const String facebookAppId = 'your-facebook-app-id';
  static const String appleClientId = 'your-apple-client-id';
  static const List<String> socialLoginScopes = ['email', 'profile'];
  
  // Push Notifications
  static const String fcmServerKey = 'your-fcm-server-key';
  static const String notificationChannelId = 'vedantatrade_notifications';
  static const String notificationChannelName = 'VedantaTrade Notifications';
  static const String notificationChannelDescription = 'Important updates and notifications';
  
  // Analytics
  static const String analyticsMeasurementId = 'your-ga-measurement-id';
  static const bool enableCrashReporting = true;
  static const bool enablePerformanceMonitoring = true;
  
  // Legal
  static const String privacyPolicyUrl = 'https://vedantatrade.com/privacy';
  static const String termsOfServiceUrl = 'https://vedantatrade.com/terms';
  static const String supportEmail = 'support@vedantatrade.com';
  static const String supportPhone = '+977-1-123456';
  
  // Regional
  static const String nepalTimeZone = 'Asia/Kathmandu';
  static const String nepalDateFormat = 'dd/MM/yyyy';
  static const String nepalTimeFormat = 'HH:mm';
  static const String nepalDateTimeFormat = 'dd/MM/yyyy HH:mm';
  
  // Database
  static const String databaseName = 'vedantatrade.db';
  static const int databaseVersion = 1;
  static const bool enableDatabaseEncryption = true;
  
  // File Paths
  static const String imagesPath = 'assets/images';
  static const String iconsPath = 'assets/icons';
  static const String fontsPath = 'assets/fonts';
  static const String animationsPath = 'assets/animations';
  
  // Default Values
  static const double defaultLatitude = 27.7172; // Kathmandu
  static const double defaultLongitude = 85.3240; // Kathmandu
  static const int defaultZoom = 12;
  
  // Rate Limiting
  static const int maxApiCallsPerMinute = 60;
  static const int maxSearchRequestsPerMinute = 30;
  static const Duration rateLimitWindow = Duration(minutes: 1);
  
  // Business Hours
  static const TimeOfDay businessStart = TimeOfDay(hour: 9, minute: 0);
  static const TimeOfDay businessEnd = TimeOfDay(hour: 18, minute: 0);
  static const List<int> businessDays = [1, 2, 3, 4, 5]; // Monday to Friday
  
  // Validation Patterns
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String phonePattern = r'^\+?[\d\s\-\(\)]{10,15}$';
// static const String passwordPattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$%^&*(),.?":{}|<>]).{8,}$'; // TODO: Move to environment variables
  static const String namePattern = r'^[a-zA-Z\s]{2,50}$';
  
  // File Upload
  static const int maxConcurrentUploads = 3;
  static const Duration uploadTimeout = Duration(minutes: 5);
  static const List<String> allowedMimeTypes = [
    'image/jpeg',
    'image/png',
    'image/gif',
    'image/webp',
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  ];
  
  // Localization
  static const Map<String, String> countryCodes = {
    'NP': 'Nepal',
    'IN': 'India',
    'CN': 'China',
    'US': 'United States',
  };
  
  static const Map<String, String> currencySymbols = {
    'NPR': 'रू',
    'USD': '$',
    'EUR': '€',
    'GBP': '£',
    'CNY': '¥',
  };
  
  // Feature Toggles (for A/B testing)
  static const bool enableNewDashboard = true;
  static const bool enableAdvancedSearch = true;
  static const bool enableSmartRecommendations = true;
  static const bool enableVoiceSearch = false;
  static const bool enableARFeatures = false;
  
  // Performance Metrics
  static const double targetFrameRate = 60.0;
  static const Duration maxLoadTime = Duration(seconds: 3);
  static const int maxMemoryUsage = 150 * 1024 * 1024; // 150MB
  static const double maxCpuUsage = 80.0; // 80%
  
  // Security Headers
  static const String contentTypeHeader = 'Content-Type';
  static const String authorizationHeader = 'Authorization';
  static const String userAgentHeader = 'User-Agent';
  static const String acceptHeader = 'Accept';
  static const String apiKeyHeader = 'X-API-Key';
  
  // Cache Strategies
  static const Duration shortCache = Duration(minutes: 5);
  static const Duration mediumCache = Duration(hours: 1);
  static const Duration longCache = Duration(days: 1);
  static const int maxCacheSize = 50 * 1024 * 1024; // 50MB
  
  // Error Codes
  static const int networkErrorCode = 1001;
  static const int serverErrorCode = 1002;
  static const int authErrorCode = 1003;
  static const int validationErrorCode = 1004;
  static const int permissionErrorCode = 1005;
  static const int rateLimitErrorCode = 1006;
  static const int maintenanceErrorCode = 1007;
  
  // Success Codes
  static const int successCode = 200;
  static const int createdCode = 201;
  static const int acceptedCode = 202;
  static const int noContentCode = 204;
  
  // HTTP Methods
  static const String getMethod = 'GET';
  static const String postMethod = 'POST';
  static const String putMethod = 'PUT';
  static const String deleteMethod = 'DELETE';
  static const String patchMethod = 'PATCH';
  
  // Content Types
  static const String jsonContentType = 'application/json';
  static const String formDataContentType = 'application/x-www-form-urlencoded';
  static const String multipartFormDataContentType = 'multipart/form-data';
  static const String textPlainContentType = 'text/plain';
  static const String htmlContentType = 'text/html';
  
  // Response Codes
  static const Map<int, String> responseMessages = {
    200: 'OK',
    201: 'Created',
    400: 'Bad Request',
    401: 'Unauthorized',
    403: 'Forbidden',
    404: 'Not Found',
    409: 'Conflict',
    422: 'Unprocessable Entity',
    429: 'Too Many Requests',
    500: 'Internal Server Error',
    502: 'Bad Gateway',
    503: 'Service Unavailable',
    504: 'Gateway Timeout',
  };
  
  // App Configuration
  static const bool enableDebugMode = false;
  static const bool enableLogging = true;
  static const bool enableCrashReporting = true;
  static const bool enableAnalytics = true;
  static const bool enableRemoteConfig = true;
  
  // Build Configuration
  static const String buildFlavor = 'production';
  static const String buildNumber = '1';
  static const String buildDate = '2024-04-04';
  
  // Feature Limits
  static const int maxProductsPerCategory = 1000;
  static const int maxOrdersPerDay = 100;
  static const int maxCampaignsPerUser = 10;
  static const int maxNotificationsPerDay = 50;
  static const int maxFileSizeUpload = 10 * 1024 * 1024; // 10MB
  
  // Integration Endpoints
  static const String paymentGatewayUrl = 'https://payment.vedantatrade.com';
  static const String smsGatewayUrl = 'https://sms.vedantatrade.com';
  static const String emailServiceUrl = 'https://email.vedantatrade.com';
  static const String analyticsServiceUrl = 'https://analytics.vedantatrade.com';
  static const String pushNotificationServiceUrl = 'https://push.vedantatrade.com';
  
  // Third-party Services
  static const String googleMapsApiKey = 'your-google-maps-api-key';
  static const String weatherApiKey = 'your-weather-api-key';
  static const String currencyApiKey = 'your-currency-api-key';
  static const String translationApiKey = 'your-translation-api-key';
  
  // Monitoring
  static const String sentryDsn = 'your-sentry-dsn';
  static const String firebaseProjectId = 'your-firebase-project-id';
  static const String crashlyticsApiKey = 'your-crashlytics-api-key';
  static const String performanceMonitoringKey = 'your-performance-key';
  
  // Backup and Recovery
  static const Duration autoBackupInterval = Duration(hours: 24);
  static const int maxBackupRetries = 3;
  static const String backupEncryptionKey = 'your-backup-encryption-key';
  static const Duration backupRetention = Duration(days: 30);
  
  // Migration
  static const int currentDatabaseVersion = 1;
  static const int targetDatabaseVersion = 2;
  static const String migrationScriptPath = 'assets/migrations/';
  
  // Testing
  static const String testEnvironment = 'test';
  static const String stagingEnvironment = 'staging';
  static const String productionEnvironment = 'production';
  static const bool enableMockData = false;
  static const bool enableTestUsers = false;
  
  // Development Tools
  static const bool enableFlipper = false;
  static const bool enableDebugMenu = false;
  static const bool enableNetworkInspector = false;
  static const bool enablePerformanceOverlay = false;
  
  // Legal and Compliance
  static const String gdprComplianceVersion = '1.0';
  static const String hipaaComplianceVersion = '1.0';
  static const String pciDssComplianceVersion = '3.2.1';
  static const bool enableDataRetention = true;
  static const Duration dataRetentionPeriod = Duration(days: 365);
  
  // Accessibility
  static const bool enableHighContrastMode = false;
  static const bool enableLargeTextMode = false;
  static const bool enableReduceMotionMode = false;
  static const bool enableScreenReaderMode = false;
  static const bool enableVoiceOverMode = false;
  
  // Performance Optimization
  static const bool enableImageCaching = true;
  static const bool enableDataCompression = true;
  static const bool enableLazyLoading = true;
  static const bool enableVirtualScrolling = true;
  static const bool enableMemoryOptimization = true;
  
  // Security Enhancements
  static const bool enableTwoFactorAuth = true;
  static const bool enableBiometricAuth = true;
  static const bool enableDeviceBinding = true;
  static const bool enableSessionManagement = true;
  static const bool enableAuditLogging = true;
  
  // User Experience
  static const bool enablePersonalization = true;
  static const bool enableRecommendations = true;
  static const bool enableSearchSuggestions = true;
  static const bool enableQuickActions = true;
  static const bool enableOfflineMode = true;
  
  // Data Synchronization
  static const Duration syncInterval = Duration(minutes: 15);
  static const int maxSyncRetries = 3;
  static const Duration syncTimeout = Duration(minutes: 5);
  static const bool enableBackgroundSync = true;
  
  // Error Handling
  static const bool enableGlobalErrorHandler = true;
  static const bool enableCrashReporting = true;
  static const bool enableErrorLogging = true;
  static const bool enableUserFeedback = true;
  
  // Analytics and Tracking
  static const bool enableUserTracking = true;
  static const bool enableEventTracking = true;
  static const bool enablePerformanceTracking = true;
  static const bool enableErrorTracking = true;
  static const bool enableFeatureUsageTracking = true;
  
  // Notifications
  static const bool enableEmailNotifications = true;
  static const bool enablePushNotifications = true;
  static const bool enableInAppNotifications = true;
  static const bool enableBadgeNotifications = true;
  
  // Localization Support
  static const bool enableMultiLanguage = true;
  static const bool enableRTLSupport = true;
  static const bool enableCurrencyConversion = true;
  static const bool enableDateFormatting = true;
  
  // Theme Customization
  static const bool enableDarkMode = true;
  static const bool enableCustomThemes = true;
  static const bool enableDynamicColors = true;
  static const bool enableBrandCustomization = true;
  
  // Integration APIs
  static const bool enableGoogleMaps = true;
  static const bool enableFacebookSDK = true;
  static const bool enableGoogleAnalytics = true;
  static const bool enableFirebase = true;
  static const bool enablePaymentGateway = true;
  
  // Advanced Features
  static const bool enableAIRecommendations = false;
  static const bool enableMachineLearning = false;
  static const bool enablePredictiveAnalytics = false;
  static const bool enableChatSupport = false;
  static const bool enableVoiceAssistant = false;
  
  // Experimental Features
  static const bool enableARView = false;
  static const bool enableVRSupport = false;
  static const bool enableBlockchain = false;
  static const bool enableIoTIntegration = false;
  static const bool enableAdvancedSecurity = false;
}

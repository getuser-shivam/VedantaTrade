import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/premium_glassmorphic_theme.dart';

class UXEnhancementProvider extends ChangeNotifier {
  // Theme Settings
  bool _isDarkMode = false;
  String _selectedTheme = 'slate';
  Color _accentColor = Colors.indigo;
  bool _isHighContrast = false;
  bool _isColorBlindFriendly = false;

  // Accessibility Settings
  bool _isReducedMotion = false;
  bool _isHapticFeedbackEnabled = true;
  double _textScale = 1.0;
  bool _isLargeTouchTargets = false;
  bool _isVoiceNavigationEnabled = false;

  // Performance Settings
  bool _isHardwareAccelerationEnabled = true;
  bool _isAdaptivePerformanceEnabled = true;
  bool _isOfflineModeEnabled = false;
  bool _isDataSaverEnabled = false;

  // UI Settings
  bool _isCompactMode = false;
  double _animationSpeed = 1.0;
  bool _isGestureNavigationEnabled = false;
  String _navigationStyle = 'bottom'; // bottom, rail, drawer

  // Search and Filter Settings
  String _lastSearchQuery = '';
  List<String> _recentSearches = [];
  Map<String, dynamic> _savedFilters = {};

  // Getters
  bool get isDarkMode => _isDarkMode;
  String get selectedTheme => _selectedTheme;
  Color get accentColor => _accentColor;
  bool get isHighContrast => _isHighContrast;
  bool get isColorBlindFriendly => _isColorBlindFriendly;

  bool get isReducedMotion => _isReducedMotion;
  bool get isHapticFeedbackEnabled => _isHapticFeedbackEnabled;
  double get textScale => _textScale;
  bool get isLargeTouchTargets => _isLargeTouchTargets;
  bool get isVoiceNavigationEnabled => _isVoiceNavigationEnabled;

  bool get isHardwareAccelerationEnabled => _isHardwareAccelerationEnabled;
  bool get isAdaptivePerformanceEnabled => _isAdaptivePerformanceEnabled;
  bool get isOfflineModeEnabled => _isOfflineModeEnabled;
  bool get isDataSaverEnabled => _isDataSaverEnabled;

  bool get isCompactMode => _isCompactMode;
  double get animationSpeed => _animationSpeed;
  bool get isGestureNavigationEnabled => _isGestureNavigationEnabled;
  String get navigationStyle => _navigationStyle;

  String get lastSearchQuery => _lastSearchQuery;
  List<String> get recentSearches => _recentSearches;
  Map<String, dynamic> get savedFilters => _savedFilters;

  // Load user preferences from storage
  Future<void> loadUserPreferences() async {
    // TODO: Implement actual storage
    // final prefs = await SharedPreferences.getInstance();
    
    // Mock data for demonstration
    _isDarkMode = false;
    _selectedTheme = 'slate';
    _accentColor = Colors.indigo;
    _isHighContrast = false;
    _isColorBlindFriendly = false;
    _isReducedMotion = false;
    _isHapticFeedbackEnabled = true;
    _textScale = 1.0;
    _isLargeTouchTargets = false;
    _isVoiceNavigationEnabled = false;
    _isHardwareAccelerationEnabled = true;
    _isAdaptivePerformanceEnabled = true;
    _isOfflineModeEnabled = false;
    _isDataSaverEnabled = false;
    _isCompactMode = false;
    _animationSpeed = 1.0;
    _isGestureNavigationEnabled = false;
    _navigationStyle = 'bottom';
    _recentSearches = [];
    _savedFilters = {};

    notifyListeners();
  }

  // Save user preferences to storage
  Future<void> saveUserPreferences() async {
    // TODO: Implement actual storage
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setString('theme', _selectedTheme);
    // await prefs.setBool('isDarkMode', _isDarkMode);
    // ... save all preferences

    debugPrint('User preferences saved');
  }

  // Theme Settings
  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    await saveUserPreferences();
    notifyListeners();
  }

  Future<void> setTheme(String theme) async {
    _selectedTheme = theme;
    await saveUserPreferences();
    notifyListeners();
  }

  Future<void> setAccentColor(Color color) async {
    _accentColor = color;
    await saveUserPreferences();
    notifyListeners();
  }

  Future<void> setHighContrast(bool value) async {
    _isHighContrast = value;
    await saveUserPreferences();
    notifyListeners();
  }

  Future<void> setColorBlindFriendly(bool value) async {
    _isColorBlindFriendly = value;
    await saveUserPreferences();
    notifyListeners();
  }

  // Accessibility Settings
  Future<void> setReducedMotion(bool value) async {
    _isReducedMotion = value;
    await saveUserPreferences();
    notifyListeners();
  }

  Future<void> setHapticFeedback(bool value) async {
    _isHapticFeedbackEnabled = value;
    await saveUserPreferences();
    notifyListeners();
  }

  Future<void> setTextScale(double value) async {
    _textScale = value.clamp(0.8, 2.0);
    await saveUserPreferences();
    notifyListeners();
  }

  Future<void> setLargeTouchTargets(bool value) async {
    _isLargeTouchTargets = value;
    await saveUserPreferences();
    notifyListeners();
  }

  Future<void> setVoiceNavigation(bool value) async {
    _isVoiceNavigationEnabled = value;
    await saveUserPreferences();
    notifyListeners();
  }

  // Performance Settings
  Future<void> setHardwareAcceleration(bool value) async {
    _isHardwareAccelerationEnabled = value;
    await saveUserPreferences();
    notifyListeners();
  }

  Future<void> setAdaptivePerformance(bool value) async {
    _isAdaptivePerformanceEnabled = value;
    await saveUserPreferences();
    notifyListeners();
  }

  Future<void> setOfflineMode(bool value) async {
    _isOfflineModeEnabled = value;
    await saveUserPreferences();
    notifyListeners();
  }

  Future<void> setDataSaver(bool value) async {
    _isDataSaverEnabled = value;
    await saveUserPreferences();
    notifyListeners();
  }

  // UI Settings
  Future<void> setCompactMode(bool value) async {
    _isCompactMode = value;
    await saveUserPreferences();
    notifyListeners();
  }

  Future<void> setAnimationSpeed(double value) async {
    _animationSpeed = value.clamp(0.5, 2.0);
    await saveUserPreferences();
    notifyListeners();
  }

  Future<void> setGestureNavigation(bool value) async {
    _isGestureNavigationEnabled = value;
    await saveUserPreferences();
    notifyListeners();
  }

  Future<void> setNavigationStyle(String style) async {
    _navigationStyle = style;
    await saveUserPreferences();
    notifyListeners();
  }

  // Search and Filter Settings
  void search(String query) {
    _lastSearchQuery = query;
    
    // Add to recent searches if not empty and not already present
    if (query.isNotEmpty && !_recentSearches.contains(query)) {
      _recentSearches.insert(0, query);
      // Keep only last 10 searches
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.take(10).toList();
      }
      saveUserPreferences();
    }
    
    notifyListeners();
  }

  void clearRecentSearches() {
    _recentSearches.clear();
    saveUserPreferences();
    notifyListeners();
  }

  Future<void> saveFilter(String name, Map<String, dynamic> filter) async {
    _savedFilters[name] = filter;
    await saveUserPreferences();
    notifyListeners();
  }

  Future<void> removeFilter(String name) async {
    _savedFilters.remove(name);
    await saveUserPreferences();
    notifyListeners();
  }

  Future<void> clearAllFilters() async {
    _savedFilters.clear();
    await saveUserPreferences();
    notifyListeners();
  }

  // Utility Methods
  ThemeData getEffectiveTheme() {
    if (_isHighContrast) {
      return _buildHighContrastTheme();
    }
    
    if (_isColorBlindFriendly) {
      return _buildColorBlindFriendlyTheme();
    }
    
    return _buildStandardTheme();
  }

  ThemeData _buildStandardTheme() {
    final baseTheme = _isDarkMode ? ThemeData.dark() : ThemeData.light();
    
    return baseTheme.copyWith(
      primaryColor: _accentColor,
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: _accentColor,
        secondary: _accentColor.withOpacity(0.7),
      ),
      textTheme: baseTheme.textTheme.copyWith(
        bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(
          fontSize: (baseTheme.textTheme.bodyLarge?.fontSize ?? 16) * _textScale,
        ),
        bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(
          fontSize: (baseTheme.textTheme.bodyMedium?.fontSize ?? 14) * _textScale,
        ),
        bodySmall: baseTheme.textTheme.bodySmall?.copyWith(
          fontSize: (baseTheme.textTheme.bodySmall?.fontSize ?? 12) * _textScale,
        ),
      ),
    );
  }

  ThemeData _buildHighContrastTheme() {
    final baseTheme = _isDarkMode ? ThemeData.dark() : ThemeData.light();
    
    return baseTheme.copyWith(
      primaryColor: _accentColor,
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: _accentColor,
        secondary: _accentColor.withOpacity(0.9),
        surface: _isDarkMode ? Colors.black : Colors.white,
        onSurface: _isDarkMode ? Colors.white : Colors.black,
        background: _isDarkMode ? Colors.black : Colors.white,
        onBackground: _isDarkMode ? Colors.white : Colors.black,
      ),
      textTheme: baseTheme.textTheme.copyWith(
        bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(
          fontSize: (baseTheme.textTheme.bodyLarge?.fontSize ?? 16) * _textScale,
          fontWeight: FontWeight.bold,
        ),
        bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(
          fontSize: (baseTheme.textTheme.bodyMedium?.fontSize ?? 14) * _textScale,
          fontWeight: FontWeight.bold,
        ),
        bodySmall: baseTheme.textTheme.bodySmall?.copyWith(
          fontSize: (baseTheme.textTheme.bodySmall?.fontSize ?? 12) * _textScale,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  ThemeData _buildColorBlindFriendlyTheme() {
    final baseTheme = _isDarkMode ? ThemeData.dark() : ThemeData.light();
    
    // Use colorblind-friendly palette
    final colorblindPalette = {
      'primary': Colors.blue[700]!,
      'secondary': Colors.orange[700]!,
      'success': Colors.green[700]!,
      'warning': Colors.amber[700]!,
      'error': Colors.red[700]!,
    };
    
    return baseTheme.copyWith(
      primaryColor: colorblindPalette['primary'],
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: colorblindPalette['primary'],
        secondary: colorblindPalette['secondary'],
        error: colorblindPalette['error'],
        surface: _isDarkMode ? Colors.grey[900]! : Colors.grey[100]!,
      ),
    );
  }

  // Animation Configuration
  Duration getAnimationDuration(Duration baseDuration) {
    if (_isReducedMotion) {
      return Duration.zero;
    }
    
    return Duration(
      milliseconds: (baseDuration.inMilliseconds / _animationSpeed).round(),
    );
  }

  Curve getAnimationCurve() {
    if (_isReducedMotion) {
      return Curves.linear;
    }
    
    return Curves.easeInOut;
  }

  // Touch Target Configuration
  double getTouchTargetSize(double baseSize) {
    if (_isLargeTouchTargets) {
      return baseSize * 1.5;
    }
    
    return baseSize;
  }

  // Performance Optimization
  bool shouldUseLowPerformanceMode() {
    return _isDataSaverEnabled || !_isAdaptivePerformanceEnabled;
  }

  // Haptic Feedback
  void triggerHapticFeedback(HapticFeedbackType type) {
    if (!_isHapticFeedbackEnabled) return;
    
    switch (type) {
      case HapticFeedbackType.light:
        // TODO: Implement light haptic feedback
        break;
      case HapticFeedbackType.medium:
        // TODO: Implement medium haptic feedback
        break;
      case HapticFeedbackType.heavy:
        // TODO: Implement heavy haptic feedback
        break;
      case HapticFeedbackType.success:
        // TODO: Implement success haptic feedback
        break;
      case HapticFeedbackType.error:
        // TODO: Implement error haptic feedback
        break;
    }
  }

  // Reset to defaults
  Future<void> resetToDefaults() async {
    _isDarkMode = false;
    _selectedTheme = 'slate';
    _accentColor = Colors.indigo;
    _isHighContrast = false;
    _isColorBlindFriendly = false;
    _isReducedMotion = false;
    _isHapticFeedbackEnabled = true;
    _textScale = 1.0;
    _isLargeTouchTargets = false;
    _isVoiceNavigationEnabled = false;
    _isHardwareAccelerationEnabled = true;
    _isAdaptivePerformanceEnabled = true;
    _isOfflineModeEnabled = false;
    _isDataSaverEnabled = false;
    _isCompactMode = false;
    _animationSpeed = 1.0;
    _isGestureNavigationEnabled = false;
    _navigationStyle = 'bottom';
    _recentSearches.clear();
    _savedFilters.clear();

    await saveUserPreferences();
    notifyListeners();
  }

  // Export settings
  Map<String, dynamic> exportSettings() {
    return {
      'theme': {
        'isDarkMode': _isDarkMode,
        'selectedTheme': _selectedTheme,
        'accentColor': _accentColor.value.toString(),
        'isHighContrast': _isHighContrast,
        'isColorBlindFriendly': _isColorBlindFriendly,
      },
      'accessibility': {
        'isReducedMotion': _isReducedMotion,
        'isHapticFeedbackEnabled': _isHapticFeedbackEnabled,
        'textScale': _textScale,
        'isLargeTouchTargets': _isLargeTouchTargets,
        'isVoiceNavigationEnabled': _isVoiceNavigationEnabled,
      },
      'performance': {
        'isHardwareAccelerationEnabled': _isHardwareAccelerationEnabled,
        'isAdaptivePerformanceEnabled': _isAdaptivePerformanceEnabled,
        'isOfflineModeEnabled': _isOfflineModeEnabled,
        'isDataSaverEnabled': _isDataSaverEnabled,
      },
      'ui': {
        'isCompactMode': _isCompactMode,
        'animationSpeed': _animationSpeed,
        'isGestureNavigationEnabled': _isGestureNavigationEnabled,
        'navigationStyle': _navigationStyle,
      },
      'search': {
        'recentSearches': _recentSearches,
        'savedFilters': _savedFilters,
      },
    };
  }

  // Import settings
  Future<void> importSettings(Map<String, dynamic> settings) async {
    try {
      final theme = settings['theme'] as Map<String, dynamic>?;
      if (theme != null) {
        _isDarkMode = theme['isDarkMode'] ?? false;
        _selectedTheme = theme['selectedTheme'] ?? 'slate';
        _accentColor = Color(int.parse(theme['accentColor']?.toString() ?? '0xFF3F51B5'));
        _isHighContrast = theme['isHighContrast'] ?? false;
        _isColorBlindFriendly = theme['isColorBlindFriendly'] ?? false;
      }

      final accessibility = settings['accessibility'] as Map<String, dynamic>?;
      if (accessibility != null) {
        _isReducedMotion = accessibility['isReducedMotion'] ?? false;
        _isHapticFeedbackEnabled = accessibility['isHapticFeedbackEnabled'] ?? true;
        _textScale = (accessibility['textScale'] ?? 1.0).toDouble();
        _isLargeTouchTargets = accessibility['isLargeTouchTargets'] ?? false;
        _isVoiceNavigationEnabled = accessibility['isVoiceNavigationEnabled'] ?? false;
      }

      final performance = settings['performance'] as Map<String, dynamic>?;
      if (performance != null) {
        _isHardwareAccelerationEnabled = performance['isHardwareAccelerationEnabled'] ?? true;
        _isAdaptivePerformanceEnabled = performance['isAdaptivePerformanceEnabled'] ?? true;
        _isOfflineModeEnabled = performance['isOfflineModeEnabled'] ?? false;
        _isDataSaverEnabled = performance['isDataSaverEnabled'] ?? false;
      }

      final ui = settings['ui'] as Map<String, dynamic>?;
      if (ui != null) {
        _isCompactMode = ui['isCompactMode'] ?? false;
        _animationSpeed = (ui['animationSpeed'] ?? 1.0).toDouble();
        _isGestureNavigationEnabled = ui['isGestureNavigationEnabled'] ?? false;
        _navigationStyle = ui['navigationStyle'] ?? 'bottom';
      }

      final search = settings['search'] as Map<String, dynamic>?;
      if (search != null) {
        _recentSearches = List<String>.from(search['recentSearches'] ?? []);
        _savedFilters = Map<String, dynamic>.from(search['savedFilters'] ?? {});
      }

      await saveUserPreferences();
      notifyListeners();
    } catch (e) {
      debugPrint('Error importing settings: $e');
    }
  }
}

enum HapticFeedbackType {
  light,
  medium,
  heavy,
  success,
  error,
}

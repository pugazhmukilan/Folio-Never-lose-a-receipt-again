import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class PreferencesHelper {
  static SharedPreferences? _preferences;
  
  /// Initialize shared preferences
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }
  
  /// Get SharedPreferences instance
  static SharedPreferences get instance {
    if (_preferences == null) {
      throw Exception('PreferencesHelper not initialized. Call init() first.');
    }
    return _preferences!;
  }
  
  // Theme Mode
  static Future<void> setThemeMode(String mode) async {
    await instance.setString(AppConstants.prefKeyThemeMode, mode);
  }
  
  static String getThemeMode() {
    return instance.getString(AppConstants.prefKeyThemeMode) ?? 'system';
  }
  
  // Default Warranty Duration
  static Future<void> setDefaultWarrantyDuration(int months) async {
    await instance.setInt(AppConstants.prefKeyDefaultWarrantyDuration, months);
  }
  
  static int getDefaultWarrantyDuration() {
    return instance.getInt(AppConstants.prefKeyDefaultWarrantyDuration) ?? 12;
  }
  
  // Notification Enabled
  static Future<void> setNotificationEnabled(bool enabled) async {
    await instance.setBool(AppConstants.prefKeyNotificationEnabled, enabled);
  }
  
  static bool isNotificationEnabled() {
    return instance.getBool(AppConstants.prefKeyNotificationEnabled) ?? true;
  }
  
  // Last Backup Date
  static Future<void> setLastBackupDate(String date) async {
    await instance.setString(AppConstants.prefKeyLastBackupDate, date);
  }
  
  static String? getLastBackupDate() {
    return instance.getString(AppConstants.prefKeyLastBackupDate);
  }
  
  // Onboarding Complete
  static Future<void> setOnboardingComplete(bool complete) async {
    await instance.setBool(AppConstants.prefKeyOnboardingComplete, complete);
  }
  
  static bool isOnboardingComplete() {
    return instance.getBool(AppConstants.prefKeyOnboardingComplete) ?? false;
  }
  
  // Grid Columns
  static Future<void> setGridColumns(int columns) async {
    await instance.setInt(AppConstants.prefKeyGridColumns, columns);
  }
  
  static int getGridColumns() {
    return instance.getInt(AppConstants.prefKeyGridColumns) ?? 2;
  }
  
  // Sort By
  static Future<void> setSortBy(String sortBy) async {
    await instance.setString(AppConstants.prefKeySortBy, sortBy);
  }
  
  static String getSortBy() {
    return instance.getString(AppConstants.prefKeySortBy) ?? 
        AppConstants.sortByDateAdded;
  }
  
  // Clear all preferences
  static Future<void> clearAll() async {
    await instance.clear();
  }
}

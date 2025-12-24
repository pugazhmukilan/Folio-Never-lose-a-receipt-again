class AppConstants {
  // App Information
  static const String appName = 'Folio';
  static const String appVersion = '1.0.0';
  
  // Database
  static const String databaseName = 'warranty_vault.db';
  static const int databaseVersion = 4;  // v2: reserved, v3: warranty_months, v4: rental_data
  
  // Tables
  static const String tableProducts = 'products';
  static const String tableAttachments = 'attachments';
  static const String tableNotes = 'notes';
  
  // Product Categories
  static const List<String> productCategories = [
    'Electronics',
    'Appliances',
    'Furniture',
    'Automotive',
    'Tools',
    'Home & Garden',
    'Fashion',
    'Sports & Outdoors',
    'Books & Media',
    'House Rental',
    'Other',
  ];
  
  // Image Types
  static const String imageTypeBill = 'bill';
  static const String imageTypeProduct = 'product';
  static const String imageTypeManual = 'manual';
  
  // Warranty Durations (in months)
  static const List<int> warrantyDurations = [
    3, 6, 12, 18, 24, 36, 48, 60,
  ];
  
  // Notification Settings
  static const int notificationReminderDays = 30;
  static const String notificationChannelId = 'warranty_expiry_channel';
  static const String notificationChannelName = 'Warranty Expiry Reminders';
  static const String notificationChannelDescription = 'Notifications for product warranty expiry';
  
  // Shared Preferences Keys
  static const String prefKeyThemeMode = 'theme_mode';
  static const String prefKeyDefaultWarrantyDuration = 'default_warranty_duration';
  static const String prefKeyNotificationEnabled = 'notification_enabled';
  static const String prefKeyLastBackupDate = 'last_backup_date';
  static const String prefKeyOnboardingComplete = 'onboarding_complete';
  static const String prefKeyGridColumns = 'grid_columns';
  static const String prefKeySortBy = 'sort_by';
  
  // Image Settings
  static const int imageCacheWidthThumbnail = 400;
  static const int imageCacheWidthDetail = 1200;
  static const int imageQuality = 85;
  
  // Backup/Restore
  static const String backupFileName = 'warranty_vault_backup';
  static const String backupDataFileName = 'data.json';
  static const String backupImagesFolder = 'images';
  
  // Date Formats
  static const String dateFormatDisplay = 'MMM dd, yyyy';
  static const String dateFormatISO = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
  static const String dateFormatStorage = 'yyyy-MM-dd HH:mm:ss';
  
  // Sort Options
  static const String sortByDateAdded = 'date_added';
  static const String sortByExpiryDate = 'expiry_date';
  static const String sortByName = 'name';
  static const String sortByCategory = 'category';
}

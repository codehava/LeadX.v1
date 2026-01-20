/// Application constants for LeadX CRM.
abstract class AppConstants {
  /// App name
  static const String appName = 'LeadX CRM';
  
  /// App version
  static const String appVersion = '1.0.0';
  
  /// Company name
  static const String companyName = 'PT Askrindo (Persero)';

  // ============================================
  // PAGINATION
  // ============================================
  
  /// Default page size for list queries
  static const int defaultPageSize = 20;
  
  /// Maximum page size allowed
  static const int maxPageSize = 100;

  // ============================================
  // TIMEOUTS
  // ============================================
  
  /// API request timeout in seconds
  static const int apiTimeout = 30;
  
  /// Sync operation timeout in seconds
  static const int syncTimeout = 60;
  
  /// GPS location timeout in seconds
  static const int gpsTimeout = 15;

  // ============================================
  // SYNC
  // ============================================
  
  /// Background sync interval in seconds
  static const int syncIntervalSeconds = 30;
  
  /// Maximum retry attempts for failed sync operations
  static const int maxSyncRetries = 3;
  
  /// Delay between sync retries (exponential backoff base)
  static const int syncRetryBaseDelayMs = 1000;

  // ============================================
  // GPS & LOCATION
  // ============================================
  
  /// Foreground GPS distance filter in meters
  static const int gpsDistanceFilterForeground = 10;
  
  /// Background GPS distance filter in meters
  static const int gpsDistanceFilterBackground = 50;
  
  /// Visit distance threshold in meters (for validation)
  static const int visitDistanceThreshold = 500;
  
  /// Minimum acceptable GPS accuracy in meters
  static const int minGpsAccuracy = 100;

  // ============================================
  // CACHE
  // ============================================
  
  /// Cache duration for master data in hours
  static const int masterDataCacheHours = 24;
  
  /// Maximum image cache size in MB
  static const int maxImageCacheSizeMb = 100;

  // ============================================
  // VALIDATION
  // ============================================
  
  /// Minimum password length
  static const int minPasswordLength = 6;
  
  /// Maximum file upload size in MB
  static const int maxUploadSizeMb = 10;
  
  /// Allowed image extensions
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png'];

  // ============================================
  // UI
  // ============================================
  
  /// Default animation duration
  static const Duration animationDuration = Duration(milliseconds: 300);
  
  /// Snackbar display duration
  static const Duration snackbarDuration = Duration(seconds: 3);
  
  /// Splash screen minimum display time
  static const Duration splashDuration = Duration(seconds: 2);
}

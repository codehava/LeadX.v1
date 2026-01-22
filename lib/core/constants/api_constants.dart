/// API constants for LeadX CRM.
abstract class ApiConstants {
  // ============================================
  // API ENDPOINTS
  // ============================================
  
  /// Base path for REST API
  static const String basePath = '/rest/v1';
  
  /// Auth endpoints
  static const String authSignIn = '/auth/v1/token?grant_type=password';
  static const String authSignUp = '/auth/v1/signup';
  static const String authSignOut = '/auth/v1/logout';
  static const String authRefresh = '/auth/v1/token?grant_type=refresh_token';
  static const String authResetPassword = '/auth/v1/recover';
  static const String authUser = '/auth/v1/user';

  // ============================================
  // TABLE NAMES
  // ============================================
  
  // Organization
  static const String tableUsers = 'users';
  static const String tableUserHierarchy = 'user_hierarchy';
  static const String tableBranches = 'branches';
  static const String tableRegionalOffices = 'regional_offices';
  
  // Geography
  static const String tableProvinces = 'provinces';
  static const String tableCities = 'cities';
  
  // Master Data
  static const String tableCompanyTypes = 'company_types';
  static const String tableOwnershipTypes = 'ownership_types';
  static const String tableIndustries = 'industries';
  static const String tableCob = 'cob';
  static const String tableLob = 'lob';
  static const String tablePipelineStages = 'pipeline_stages';
  static const String tablePipelineStatuses = 'pipeline_statuses';
  static const String tableActivityTypes = 'activity_types';
  static const String tableLeadSources = 'lead_sources';
  static const String tableDeclineReasons = 'decline_reasons';
  
  // Business Data
  static const String tableCustomers = 'customers';
  static const String tableKeyPersons = 'key_persons';
  static const String tablePipelines = 'pipelines';
  static const String tableActivities = 'activities';
  static const String tableActivityPhotos = 'activity_photos';
  
  // HVC & Broker
  static const String tableHvc = 'hvcs';
  static const String tableHvcTypes = 'hvc_types';
  static const String tableCustomerHvcLinks = 'customer_hvc_links';
  static const String tableBrokers = 'brokers';
  
  // 4DX
  static const String tableMeasureDefinitions = 'measure_definitions';
  static const String tableScoringPeriods = 'scoring_periods';
  static const String tableUserTargets = 'user_targets';
  static const String tableUserScores = 'user_scores';
  
  // Cadence
  static const String tableCadenceScheduleConfig = 'cadence_schedule_config';
  static const String tableCadenceMeetings = 'cadence_meetings';
  static const String tableCadenceParticipants = 'cadence_participants';
  
  // System
  static const String tableSyncQueue = 'sync_queue';
  static const String tableAuditLog = 'audit_log';
  static const String tableNotifications = 'notifications';

  // ============================================
  // STORAGE BUCKETS
  // ============================================
  
  static const String bucketActivityPhotos = 'activity-photos';
  static const String bucketProfilePhotos = 'profile-photos';
  static const String bucketDocuments = 'documents';

  // ============================================
  // RPC FUNCTIONS
  // ============================================
  
  static const String rpcGetSubordinates = 'get_subordinates';
  static const String rpcGetUserHierarchy = 'get_user_hierarchy';
  static const String rpcCalculateScore = 'calculate_user_score';
}

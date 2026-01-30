/// Route names for LeadX CRM navigation.
abstract class RouteNames {
  // ============================================
  // AUTH ROUTES
  // ============================================
  
  static const String splash = 'splash';
  static const String login = 'login';
  static const String forgotPassword = 'forgot-password';
  static const String resetPassword = 'reset-password';

  // ============================================
  // MAIN ROUTES
  // ============================================
  
  static const String home = 'home';
  static const String dashboard = 'dashboard';

  // ============================================
  // CUSTOMER ROUTES
  // ============================================
  
  static const String customers = 'customers';
  static const String customerDetail = 'customer-detail';
  static const String customerCreate = 'customer-create';
  static const String customerEdit = 'customer-edit';

  // ============================================
  // PIPELINE ROUTES
  // ============================================
  
  static const String pipelineDetail = 'pipeline-detail';
  static const String pipelineCreate = 'pipeline-create';
  static const String pipelineEdit = 'pipeline-edit';

  // ============================================
  // ACTIVITY ROUTES
  // ============================================
  
  static const String activities = 'activities';
  static const String activityDetail = 'activity-detail';
  static const String activityCreate = 'activity-create';
  static const String activityCalendar = 'activity-calendar';

  // ============================================
  // HVC ROUTES
  // ============================================
  
  static const String hvc = 'hvc';
  static const String hvcDetail = 'hvc-detail';
  static const String hvcCreate = 'hvc-create';
  static const String hvcEdit = 'hvc-edit';

  // ============================================
  // BROKER ROUTES
  // ============================================

  static const String brokers = 'brokers';
  static const String brokerDetail = 'broker-detail';
  static const String brokerCreate = 'broker-create';
  static const String brokerEdit = 'broker-edit';

  // ============================================
  // REFERRAL ROUTES
  // ============================================

  static const String referrals = 'referrals';
  static const String referralDetail = 'referral-detail';
  static const String referralCreate = 'referral-create';
  static const String managerApprovals = 'manager-approvals';

  // ============================================
  // 4DX ROUTES
  // ============================================
  
  static const String scoreboard = 'scoreboard';
  static const String targets = 'targets';
  static const String cadence = 'cadence';
  static const String cadenceDetail = 'cadence-detail';
  static const String cadenceHost = 'cadence-host';
  static const String cadenceForm = 'cadence-form';

  // ============================================
  // PROFILE & SETTINGS
  // ============================================
  
  static const String profile = 'profile';
  static const String editProfile = 'edit-profile';
  static const String changePassword = 'change-password';
  static const String settings = 'settings';
  static const String about = 'about';
  static const String notifications = 'notifications';

  // ============================================
  // ADMIN ROUTES
  // ============================================

  static const String admin = 'admin';
  static const String unauthorized = 'unauthorized';

  // User Management
  static const String adminUsers = 'admin-users';
  static const String adminUserCreate = 'admin-user-create';
  static const String adminUserDetail = 'admin-user-detail';
  static const String adminUserEdit = 'admin-user-edit';

  // Master Data Management
  static const String adminMasterData = 'admin-master-data';
  static const String adminMasterDataList = 'admin-master-data-list';
  static const String adminMasterDataCreate = 'admin-master-data-create';
  static const String adminMasterDataEdit = 'admin-master-data-edit';

  // 4DX Configuration
  static const String admin4dx = 'admin-4dx';
  static const String adminMeasures = 'admin-measures';
  static const String adminMeasureForm = 'admin-measure-form';
  static const String adminPeriods = 'admin-periods';
  static const String adminPeriodForm = 'admin-period-form';

  // Bulk Upload
  static const String adminBulkUpload = 'admin-bulk-upload';
  static const String adminBulkUploadEntity = 'admin-bulk-upload-entity';

  // Cadence Configuration
  static const String adminCadence = 'admin-cadence';
  static const String adminCadenceCreate = 'admin-cadence-create';
}

/// Route paths for LeadX CRM navigation.
abstract class RoutePaths {
  // Auth
  static const String splash = '/';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // Main
  static const String home = '/home';
  static const String dashboard = '/home/dashboard';

  // Customers
  static const String customers = '/home/customers';
  static const String customerDetail = '/home/customers/:id';
  static const String customerCreate = '/home/customers/create';
  static const String customerEdit = '/home/customers/:id/edit';

  // Pipelines (nested under customer)
  static const String pipelineDetail = '/home/customers/:customerId/pipelines/:id';
  static const String pipelineCreate = '/home/customers/:customerId/pipelines/create';
  static const String pipelineEdit = '/home/customers/:customerId/pipelines/:id/edit';

  // Activities
  static const String activities = '/home/activities';
  static const String activityDetail = '/home/activities/:id';
  static const String activityCreate = '/home/activities/create';
  static const String activityCalendar = '/activity/calendar';

  // HVC
  static const String hvc = '/home/hvcs';
  static const String hvcDetail = '/home/hvcs/:id';
  static const String hvcCreate = '/home/hvcs/new';
  static const String hvcEdit = '/home/hvcs/:id/edit';

  // Brokers
  static const String brokers = '/home/brokers';
  static const String brokerDetail = '/home/brokers/:id';
  static const String brokerCreate = '/home/brokers/create';
  static const String brokerEdit = '/home/brokers/:id/edit';

  // Referrals
  static const String referrals = '/home/referrals';
  static const String referralDetail = '/home/referrals/:id';
  static const String referralCreate = '/home/referrals/new';
  static const String managerApprovals = '/home/referrals/approvals';

  // 4DX
  static const String scoreboard = '/home/scoreboard';
  static const String targets = '/home/targets';
  static const String cadence = '/home/cadence';
  static const String cadenceDetail = '/home/cadence/:id';

  // Profile & Settings
  static const String profile = '/home/profile';
  static const String editProfile = '/home/profile/edit';
  static const String changePassword = '/home/profile/change-password';
  static const String settings = '/home/settings';
  static const String about = '/home/about';
  static const String notifications = '/home/notifications';

  // Admin
  static const String admin = '/admin';
  static const String unauthorized = '/unauthorized';

  // User Management
  static const String adminUsers = '/admin/users';
  static const String adminUserCreate = '/admin/users/create';
  static const String adminUserDetail = '/admin/users/:id';
  static const String adminUserEdit = '/admin/users/:id/edit';

  // Master Data Management
  static const String adminMasterData = '/admin/master-data';
  static const String adminMasterDataList = '/admin/master-data/:entityType';
  static const String adminMasterDataCreate = '/admin/master-data/:entityType/create';
  static const String adminMasterDataEdit = '/admin/master-data/:entityType/:id/edit';

  // 4DX Configuration
  static const String admin4dx = '/admin/4dx';
  static const String adminMeasures = '/admin/4dx/measures';
  static const String adminMeasureForm = '/admin/4dx/measures/form';
  static const String adminPeriods = '/admin/4dx/periods';
  static const String adminPeriodForm = '/admin/4dx/periods/form';

  // Bulk Upload
  static const String adminBulkUpload = '/admin/bulk-upload';
  static const String adminBulkUploadEntity = '/admin/bulk-upload/:entityType';

  // Cadence Configuration
  static const String adminCadence = '/admin/cadence';
  static const String adminCadenceCreate = '/admin/cadence/form';
}

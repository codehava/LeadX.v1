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
  // 4DX ROUTES
  // ============================================
  
  static const String scoreboard = 'scoreboard';
  static const String targets = 'targets';
  static const String cadence = 'cadence';
  static const String cadenceDetail = 'cadence-detail';

  // ============================================
  // PROFILE & SETTINGS
  // ============================================
  
  static const String profile = 'profile';
  static const String settings = 'settings';
  static const String notifications = 'notifications';

  // ============================================
  // ADMIN ROUTES
  // ============================================
  
  static const String admin = 'admin';
  static const String adminUsers = 'admin-users';
  static const String adminMasterData = 'admin-master-data';
  static const String admin4dx = 'admin-4dx';
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

  // 4DX
  static const String scoreboard = '/home/scoreboard';
  static const String targets = '/home/targets';
  static const String cadence = '/home/cadence';
  static const String cadenceDetail = '/home/cadence/:id';

  // Profile & Settings
  static const String profile = '/home/profile';
  static const String settings = '/home/settings';
  static const String notifications = '/home/notifications';

  // Admin
  static const String admin = '/admin';
  static const String adminUsers = '/admin/users';
  static const String adminMasterData = '/admin/master-data';
  static const String admin4dx = '/admin/4dx';
}

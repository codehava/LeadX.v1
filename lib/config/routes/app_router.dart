import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/providers/auth_providers.dart';
import '../../presentation/screens/activity/activity_calendar_screen.dart';
import '../../presentation/screens/activity/activity_detail_screen.dart';
import '../../presentation/screens/activity/activity_form_screen.dart';
import '../../presentation/screens/admin/admin_home_screen.dart';
import '../../presentation/screens/admin/4dx/admin_4dx_home_screen.dart';
import '../../presentation/screens/admin/4dx/measures/admin_measure_list_screen.dart';
import '../../presentation/screens/admin/4dx/measures/admin_measure_form_screen.dart';
import '../../presentation/screens/admin/4dx/periods/admin_period_list_screen.dart';
import '../../presentation/screens/admin/4dx/periods/admin_period_form_screen.dart';
import '../../presentation/screens/admin/master_data/master_data_form_screen.dart';
import '../../presentation/screens/admin/master_data/master_data_list_screen.dart';
import '../../presentation/screens/admin/master_data/master_data_menu_screen.dart';
import '../../presentation/screens/admin/cadence/cadence_config_form_screen.dart';
import '../../presentation/screens/admin/cadence/cadence_config_list_screen.dart';
import '../../presentation/screens/admin/unauthorized_screen.dart';
import '../../presentation/screens/admin/users/user_detail_screen.dart';
import '../../presentation/screens/admin/users/user_form_screen.dart';
import '../../presentation/screens/admin/users/user_list_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/reset_password_screen.dart';
import '../../presentation/screens/auth/splash_screen.dart';
import '../../presentation/screens/customer/customer_detail_screen.dart';
import '../../presentation/screens/customer/customer_form_screen.dart';
import '../../presentation/screens/customer/customer_history_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/hvc/hvc_detail_screen.dart';
import '../../presentation/screens/hvc/hvc_form_screen.dart';
import '../../presentation/screens/hvc/hvc_list_screen.dart';
import '../../presentation/screens/broker/broker_detail_screen.dart';
import '../../presentation/screens/broker/broker_form_screen.dart';
import '../../presentation/screens/broker/broker_list_screen.dart';
import '../../presentation/screens/pipeline/pipeline_detail_screen.dart';
import '../../presentation/screens/pipeline/pipeline_form_screen.dart';
import '../../presentation/screens/pipeline/pipeline_history_screen.dart';
import '../../presentation/screens/profile/about_screen.dart';
import '../../presentation/screens/profile/change_password_screen.dart';
import '../../presentation/screens/profile/edit_profile_screen.dart';
import '../../presentation/screens/profile/notification_settings_screen.dart';
import '../../presentation/screens/profile/settings_screen.dart';
import '../../presentation/screens/referral/manager_approval_screen.dart';
import '../../presentation/screens/referral/referral_create_screen.dart';
import '../../presentation/screens/referral/referral_detail_screen.dart';
import '../../presentation/screens/referral/referral_list_screen.dart';
import '../../presentation/screens/admin/4dx/scoring_summary_screen.dart';
import '../../presentation/screens/admin/4dx/targets/admin_target_list_screen.dart';
import '../../presentation/screens/admin/4dx/targets/admin_target_form_screen.dart';
import '../../presentation/screens/team_targets/team_target_list_screen.dart';
import '../../presentation/screens/team_targets/team_target_form_screen.dart';
import '../../presentation/screens/scoreboard/leaderboard_screen.dart';
import '../../presentation/screens/scoreboard/my_targets_screen.dart';
import '../../presentation/screens/scoreboard/scoreboard_screen.dart';
import '../../presentation/screens/scoreboard/measure_detail_screen.dart';
import '../../presentation/screens/sync/sync_queue_screen.dart';
import '../../presentation/screens/cadence/cadence_list_screen.dart';
import '../../presentation/screens/cadence/cadence_detail_screen.dart';
import '../../presentation/screens/cadence/cadence_form_screen.dart';
import '../../presentation/screens/cadence/host_dashboard_screen.dart';
import '../../presentation/widgets/shell/responsive_shell.dart';
import '../../domain/entities/cadence.dart';
import '../../domain/entities/scoring_entities.dart';
import 'route_names.dart';

/// Root navigator key for routes that should NOT be wrapped by the shell.
/// Detail screens, form screens, etc. use this to render full-screen without bottom nav.
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Stores the intended location when user navigates directly via URL bar
/// This is used to restore the location after authentication check completes
String? _pendingDeepLink;

/// Admin route guard - checks if user has admin privileges.
/// Returns redirect path if user is not admin, null otherwise.
String? _adminGuard(Ref ref) {
  final isAdmin = ref.read(isAdminProvider);
  if (!isAdmin) {
    return RoutePaths.unauthorized;
  }
  return null; // Allow navigation
}

/// Provider for the app router.
final appRouterProvider = Provider<GoRouter>((ref) {
  // Watch auth state for redirects
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    
    // Redirect based on auth state
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final isLoggedIn = authState.maybeWhen(
        data: (auth) => auth.maybeWhen(
          authenticated: (_) => true,
          orElse: () => false,
        ),
        orElse: () => false,
      );
      final isPasswordRecovery = authState.maybeWhen(
        data: (auth) => auth.maybeWhen(
          passwordRecovery: () => true,
          orElse: () => false,
        ),
        orElse: () => false,
      );

      final currentLocation = state.matchedLocation;
      final fullUri = state.uri.toString();
      final isSplash = currentLocation == RoutePaths.splash;
      final isLogin = currentLocation == RoutePaths.login;
      final isForgotPassword = currentLocation == RoutePaths.forgotPassword;
      final isResetPassword = currentLocation == RoutePaths.resetPassword;
      final isAuthPage = isSplash || isLogin || isForgotPassword || isResetPassword;

      // Password recovery flow - redirect to reset password screen
      if (isPasswordRecovery && !isResetPassword) {
        return RoutePaths.resetPassword;
      }

      // Still loading - save intended location and redirect to splash
      // Exception: Don't redirect away from reset-password - it handles its own auth check
      if (isLoading && !isResetPassword) {
        // Only save the deep link if it's not an auth page
        if (!isAuthPage && _pendingDeepLink == null) {
          _pendingDeepLink = fullUri;
        }
        return isSplash ? null : RoutePaths.splash;
      }

      // Not logged in - redirect to login (unless already on auth pages)
      if (!isLoggedIn && !isAuthPage) {
        // Save intended location for after login
        _pendingDeepLink = fullUri;
        return RoutePaths.login;
      }

      // Logged in but on login/splash - check for pending deep link first
      // Note: Don't redirect away from reset-password - user needs to set new password
      if (isLoggedIn && (isLogin || isSplash) && !isResetPassword) {
        final pendingLink = _pendingDeepLink;
        _pendingDeepLink = null; // Clear pending link after use
        
        // If there's a pending deep link, go there instead of home
        if (pendingLink != null && pendingLink != RoutePaths.splash && pendingLink != RoutePaths.login) {
          return pendingLink;
        }
        return RoutePaths.home;
      }

      // Clear pending link if we've reached a valid destination
      _pendingDeepLink = null;
      
      return null;
    },

    routes: [
      // ============================================
      // AUTH ROUTES
      // ============================================
      
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RoutePaths.resetPassword,
        name: RouteNames.resetPassword,
        builder: (context, state) => const ResetPasswordScreen(),
      ),

      // ============================================
      // MAIN ROUTES
      // ============================================
      
      GoRoute(
        path: RoutePaths.home,
        name: RouteNames.home,
        pageBuilder: (context, state) => NoTransitionPage(
          child: ResponsiveShell(
            currentRoute: state.matchedLocation,
            child: const HomeScreen(),
          ),
        ),
        routes: [
          // Dashboard
          GoRoute(
            path: 'dashboard',
            name: RouteNames.dashboard,
            pageBuilder: (context, state) => NoTransitionPage(
              child: ResponsiveShell(
                currentRoute: state.matchedLocation,
                child: const Placeholder(
                  child: Center(child: Text('Dashboard')),
                ),
              ),
            ),
          ),

          // Customers (tab route)
          GoRoute(
            path: 'customers',
            name: RouteNames.customers,
            pageBuilder: (context, state) => NoTransitionPage(
              child: ResponsiveShell(
                currentRoute: state.matchedLocation,
                child: const HomeScreen(initialTab: 1),
              ),
            ),
            routes: [
              GoRoute(
                path: 'create',
                name: RouteNames.customerCreate,
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const CustomerFormScreen(),
              ),
              GoRoute(
                path: ':id',
                name: RouteNames.customerDetail,
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return CustomerDetailScreen(customerId: id);
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: RouteNames.customerEdit,
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return CustomerFormScreen(customerId: id);
                    },
                  ),
                  GoRoute(
                    path: 'history',
                    name: 'customerHistory',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return CustomerHistoryScreen(customerId: id);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Pipelines (standalone routes for navigation from CustomerDetailScreen)
          GoRoute(
            path: 'pipelines/new',
            name: RouteNames.pipelineCreate,
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) {
              final customerId = state.uri.queryParameters['customerId']!;
              return PipelineFormScreen(customerId: customerId);
            },
          ),
          GoRoute(
            path: 'pipelines/:id',
            name: RouteNames.pipelineDetail,
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              final customerId = state.uri.queryParameters['customerId'] ?? '';
              return PipelineDetailScreen(pipelineId: id, customerId: customerId);
            },
            routes: [
              GoRoute(
                path: 'edit',
                name: RouteNames.pipelineEdit,
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  final customerId = state.uri.queryParameters['customerId'] ?? '';
                  return PipelineFormScreen(customerId: customerId, pipelineId: id);
                },
              ),
              GoRoute(
                path: 'history',
                name: 'pipelineHistory',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return PipelineHistoryScreen(pipelineId: id);
                },
              ),
            ],
          ),

          // Activities (tab route)
          GoRoute(
            path: 'activities',
            name: RouteNames.activities,
            pageBuilder: (context, state) => NoTransitionPage(
              child: ResponsiveShell(
                currentRoute: state.matchedLocation,
                child: const HomeScreen(initialTab: 2),
              ),
            ),
            routes: [
              GoRoute(
                path: 'create',
                name: RouteNames.activityCreate,
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final objectType = state.uri.queryParameters['objectType'];
                  final objectId = state.uri.queryParameters['objectId'];
                  final objectName = state.uri.queryParameters['objectName'];
                  final immediate = state.uri.queryParameters['immediate'] == 'true';
                  return ActivityFormScreen(
                    objectType: objectType,
                    objectId: objectId,
                    objectName: objectName,
                    isImmediate: immediate,
                  );
                },
              ),
              // Immediate activity route (for entity detail pages)
              GoRoute(
                path: 'immediate',
                name: 'activityImmediate',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final objectType = state.uri.queryParameters['objectType'];
                  final objectId = state.uri.queryParameters['objectId'];
                  final objectName = state.uri.queryParameters['objectName'];
                  return ActivityFormScreen(
                    objectType: objectType,
                    objectId: objectId,
                    objectName: objectName,
                    isImmediate: true,
                  );
                },
              ),
              GoRoute(
                path: ':id',
                name: RouteNames.activityDetail,
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ActivityDetailScreen(activityId: id);
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: RouteNames.activityEdit,
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return ActivityFormScreen(activityId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          
          // Activity Calendar (top-level route accessible from Dashboard)
          GoRoute(
            path: 'activity/calendar',
            name: RouteNames.activityCalendar,
            builder: (context, state) => ResponsiveShell(
              currentRoute: state.matchedLocation,
              child: const ActivityCalendarScreen(),
            ),
          ),

          // HVC
          GoRoute(
            path: 'hvcs',
            name: RouteNames.hvc,
            pageBuilder: (context, state) => NoTransitionPage(
              child: ResponsiveShell(
                currentRoute: state.matchedLocation,
                child: const HvcListScreen(),
              ),
            ),
            routes: [
              GoRoute(
                path: 'new',
                name: RouteNames.hvcCreate,
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const HvcFormScreen(),
              ),
              GoRoute(
                path: ':id',
                name: RouteNames.hvcDetail,
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return HvcDetailScreen(hvcId: id);
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: RouteNames.hvcEdit,
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return HvcFormScreen(hvcId: id);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Brokers
          GoRoute(
            path: 'brokers',
            name: RouteNames.brokers,
            pageBuilder: (context, state) => NoTransitionPage(
              child: ResponsiveShell(
                currentRoute: state.matchedLocation,
                child: const BrokerListScreen(),
              ),
            ),
            routes: [
              GoRoute(
                path: 'new',
                name: RouteNames.brokerCreate,
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const BrokerFormScreen(),
              ),
              GoRoute(
                path: ':id',
                name: RouteNames.brokerDetail,
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return BrokerDetailScreen(brokerId: id);
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: RouteNames.brokerEdit,
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return BrokerFormScreen(brokerId: id);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Referrals
          GoRoute(
            path: 'referrals',
            name: RouteNames.referrals,
            pageBuilder: (context, state) => NoTransitionPage(
              child: ResponsiveShell(
                currentRoute: state.matchedLocation,
                child: const ReferralListScreen(),
              ),
            ),
            routes: [
              GoRoute(
                path: 'new',
                name: RouteNames.referralCreate,
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const ReferralCreateScreen(),
              ),
              GoRoute(
                path: 'approvals',
                name: RouteNames.managerApprovals,
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const ManagerApprovalScreen(),
              ),
              GoRoute(
                path: ':id',
                name: RouteNames.referralDetail,
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ReferralDetailScreen(referralId: id);
                },
              ),
            ],
          ),

          // Scoreboard
          GoRoute(
            path: 'scoreboard',
            name: RouteNames.scoreboard,
            pageBuilder: (context, state) => NoTransitionPage(
              child: ResponsiveShell(
                currentRoute: state.matchedLocation,
                child: const ScoreboardScreen(),
              ),
            ),
            routes: [
              // Leaderboard
              GoRoute(
                path: 'leaderboard',
                name: RouteNames.leaderboard,
                pageBuilder: (context, state) => const MaterialPage(
                  child: LeaderboardScreen(),
                ),
              ),
              // Measure Detail
              GoRoute(
                path: 'measure/:measureId',
                name: RouteNames.measureDetail,
                pageBuilder: (context, state) {
                  final measureId = state.pathParameters['measureId']!;
                  return MaterialPage(
                    child: MeasureDetailScreen(measureId: measureId),
                  );
                },
              ),
            ],
          ),

          // Cadence
          GoRoute(
            path: 'cadence',
            name: RouteNames.cadence,
            pageBuilder: (context, state) => NoTransitionPage(
              child: ResponsiveShell(
                currentRoute: state.matchedLocation,
                child: const CadenceListScreen(),
              ),
            ),
            routes: [
              GoRoute(
                path: 'host',
                name: RouteNames.cadenceHost,
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const HostDashboardScreen(),
              ),
              GoRoute(
                path: ':id',
                name: RouteNames.cadenceDetail,
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return CadenceDetailScreen(meetingId: id);
                },
                routes: [
                  GoRoute(
                    path: 'form',
                    name: RouteNames.cadenceForm,
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      final participation = state.extra as CadenceParticipant?;
                      return CadenceFormScreen(
                        meetingId: id,
                        participation: participation,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // Targets (My Targets - user-facing)
          GoRoute(
            path: 'targets',
            name: RouteNames.targets,
            pageBuilder: (context, state) => NoTransitionPage(
              child: ResponsiveShell(
                currentRoute: state.matchedLocation,
                child: const MyTargetsScreen(),
              ),
            ),
          ),

          // Team Targets (Manager-facing: BH/BM/ROH assign subordinate targets)
          GoRoute(
            path: 'team-targets',
            name: RouteNames.teamTargets,
            pageBuilder: (context, state) => NoTransitionPage(
              child: ResponsiveShell(
                currentRoute: state.matchedLocation,
                child: const TeamTargetListScreen(),
              ),
            ),
            routes: [
              GoRoute(
                path: ':userId',
                name: RouteNames.teamTargetForm,
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final userId = state.pathParameters['userId']!;
                  final period = state.extra! as ScoringPeriod;
                  return TeamTargetFormScreen(
                    userId: userId,
                    period: period,
                  );
                },
              ),
            ],
          ),

          // Profile (tab route)
          GoRoute(
            path: 'profile',
            name: RouteNames.profile,
            pageBuilder: (context, state) => NoTransitionPage(
              child: ResponsiveShell(
                currentRoute: state.matchedLocation,
                child: const HomeScreen(initialTab: 3),
              ),
            ),
            routes: [
              GoRoute(
                path: 'edit',
                name: RouteNames.editProfile,
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const EditProfileScreen(),
              ),
              GoRoute(
                path: 'change-password',
                name: RouteNames.changePassword,
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const ChangePasswordScreen(),
              ),
            ],
          ),

          // Settings
          GoRoute(
            path: 'settings',
            name: RouteNames.settings,
            pageBuilder: (context, state) => NoTransitionPage(
              child: ResponsiveShell(
                currentRoute: state.matchedLocation,
                child: const SettingsScreen(),
              ),
            ),
          ),

          // About
          GoRoute(
            path: 'about',
            name: RouteNames.about,
            pageBuilder: (context, state) => NoTransitionPage(
              child: ResponsiveShell(
                currentRoute: state.matchedLocation,
                child: const AboutScreen(),
              ),
            ),
          ),

          // Notifications
          GoRoute(
            path: 'notifications',
            name: RouteNames.notifications,
            pageBuilder: (context, state) => NoTransitionPage(
              child: ResponsiveShell(
                currentRoute: state.matchedLocation,
                child: const NotificationSettingsScreen(),
              ),
            ),
          ),

          // Debug: Sync Queue
          GoRoute(
            path: 'sync-queue',
            name: 'syncQueue',
            builder: (context, state) {
              final entityId = state.uri.queryParameters['entityId'];
              return ResponsiveShell(
                currentRoute: state.matchedLocation,
                child: SyncQueueScreen(entityId: entityId),
              );
            },
          ),
        ],
      ),

      // ============================================
      // ADMIN ROUTES
      // ============================================

      GoRoute(
        path: RoutePaths.admin,
        name: RouteNames.admin,
        redirect: (context, state) => _adminGuard(ref),
        pageBuilder: (context, state) => NoTransitionPage(
          child: ResponsiveShell(
            currentRoute: state.matchedLocation,
            child: const AdminHomeScreen(),
          ),
        ),
        routes: [
          // User Management
          GoRoute(
            path: 'users',
            name: RouteNames.adminUsers,
            pageBuilder: (context, state) => NoTransitionPage(
              child: ResponsiveShell(
                currentRoute: state.matchedLocation,
                child: const UserListScreen(),
              ),
            ),
            routes: [
              GoRoute(
                path: 'create',
                name: RouteNames.adminUserCreate,
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const UserFormScreen(),
              ),
              GoRoute(
                path: ':id',
                name: RouteNames.adminUserDetail,
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return UserDetailScreen(userId: id);
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: RouteNames.adminUserEdit,
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return UserFormScreen(userId: id);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Master Data Management
          GoRoute(
            path: 'master-data',
            name: RouteNames.adminMasterData,
            pageBuilder: (context, state) => NoTransitionPage(
              child: ResponsiveShell(
                currentRoute: state.matchedLocation,
                child: const MasterDataMenuScreen(),
              ),
            ),
            routes: [
              GoRoute(
                path: ':entityType',
                name: RouteNames.adminMasterDataList,
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final entityType = state.pathParameters['entityType']!;
                  return MasterDataListScreen(entityType: entityType);
                },
                routes: [
                  GoRoute(
                    path: 'create',
                    name: RouteNames.adminMasterDataCreate,
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final entityType = state.pathParameters['entityType']!;
                      final id = state.uri.queryParameters['id'];
                      return MasterDataFormScreen(
                        entityType: entityType,
                        itemId: id,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // 4DX Configuration
          GoRoute(
            path: '4dx',
            name: RouteNames.admin4dx,
            pageBuilder: (context, state) => NoTransitionPage(
              child: ResponsiveShell(
                currentRoute: state.matchedLocation,
                child: const Admin4DXHomeScreen(),
              ),
            ),
            routes: [
              // Measures List
              GoRoute(
                path: 'measures',
                name: RouteNames.adminMeasures,
                pageBuilder: (context, state) => NoTransitionPage(
                  child: ResponsiveShell(
                    currentRoute: state.matchedLocation,
                    child: const AdminMeasureListScreen(),
                  ),
                ),
                routes: [
                  // Create Measure
                  GoRoute(
                    path: 'create',
                    name: RouteNames.adminMeasureCreate,
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const AdminMeasureFormScreen(),
                  ),
                  // Edit Measure
                  GoRoute(
                    path: ':id',
                    name: RouteNames.adminMeasureEdit,
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return AdminMeasureFormScreen(measureId: id);
                    },
                  ),
                ],
              ),
              // Periods List
              GoRoute(
                path: 'periods',
                name: RouteNames.adminPeriods,
                pageBuilder: (context, state) => NoTransitionPage(
                  child: ResponsiveShell(
                    currentRoute: state.matchedLocation,
                    child: const AdminPeriodListScreen(),
                  ),
                ),
                routes: [
                  // Create Period
                  GoRoute(
                    path: 'create',
                    name: RouteNames.adminPeriodCreate,
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) =>
                        const AdminPeriodFormScreen(),
                  ),
                  // Edit Period
                  GoRoute(
                    path: ':id',
                    name: RouteNames.adminPeriodEdit,
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return AdminPeriodFormScreen(periodId: id);
                    },
                  ),
                ],
              ),
              // Targets Management
              GoRoute(
                path: 'targets',
                name: RouteNames.adminTargets,
                pageBuilder: (context, state) => NoTransitionPage(
                  child: ResponsiveShell(
                    currentRoute: state.matchedLocation,
                    child: const AdminTargetListScreen(),
                  ),
                ),
                routes: [
                  // User Target Form
                  GoRoute(
                    path: ':userId',
                    name: RouteNames.adminTargetForm,
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final userId = state.pathParameters['userId']!;
                      final period = state.extra! as ScoringPeriod;
                      return AdminTargetFormScreen(
                        userId: userId,
                        period: period,
                      );
                    },
                  ),
                ],
              ),
              // Scoring Summary Grid
              GoRoute(
                path: 'scoring-summary',
                name: RouteNames.adminScoringSummary,
                pageBuilder: (context, state) => NoTransitionPage(
                  child: ResponsiveShell(
                    currentRoute: state.matchedLocation,
                    child: const ScoringSummaryScreen(),
                  ),
                ),
              ),
            ],
          ),

          // Cadence Management
          GoRoute(
            path: 'cadence',
            name: RouteNames.adminCadence,
            pageBuilder: (context, state) => NoTransitionPage(
              child: ResponsiveShell(
                currentRoute: state.matchedLocation,
                child: const CadenceConfigListScreen(),
              ),
            ),
            routes: [
              GoRoute(
                path: 'form',
                name: RouteNames.adminCadenceCreate,
                pageBuilder: (context, state) {
                  final configId = state.uri.queryParameters['id'];
                  return NoTransitionPage(
                    child: ResponsiveShell(
                      currentRoute: state.matchedLocation,
                      child: CadenceConfigFormScreen(configId: configId),
                    ),
                  );
                },
              ),
            ],
          ),

          // Bulk Upload (placeholders for Phase 5)
          GoRoute(
            path: 'bulk-upload',
            name: RouteNames.adminBulkUpload,
            pageBuilder: (context, state) => NoTransitionPage(
              child: ResponsiveShell(
                currentRoute: state.matchedLocation,
                child: const Placeholder(
                  child: Center(child: Text('Bulk Upload')),
                ),
              ),
            ),
          ),
        ],
      ),

      // Unauthorized screen (outside admin routes)
      GoRoute(
        path: RoutePaths.unauthorized,
        name: RouteNames.unauthorized,
        builder: (context, state) => const UnauthorizedScreen(),
      ),
    ],

    // ============================================
    // ERROR HANDLING
    // ============================================
    
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(RoutePaths.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

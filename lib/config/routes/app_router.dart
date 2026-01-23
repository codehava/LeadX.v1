import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/providers/auth_providers.dart';
import '../../presentation/screens/activity/activity_calendar_screen.dart';
import '../../presentation/screens/activity/activity_detail_screen.dart';
import '../../presentation/screens/activity/activity_form_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
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
import '../../presentation/screens/profile/settings_screen.dart';
import '../../presentation/screens/scoreboard/scoreboard_screen.dart';
import '../../presentation/screens/sync/sync_queue_screen.dart';
import '../../presentation/widgets/shell/responsive_shell.dart';
import 'route_names.dart';

/// Stores the intended location when user navigates directly via URL bar
/// This is used to restore the location after authentication check completes
String? _pendingDeepLink;

/// Provider for the app router.
final appRouterProvider = Provider<GoRouter>((ref) {
  // Watch auth state for redirects
  final authState = ref.watch(authStateProvider);

  return GoRouter(
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

      final currentLocation = state.matchedLocation;
      final fullUri = state.uri.toString();
      final isSplash = currentLocation == RoutePaths.splash;
      final isLogin = currentLocation == RoutePaths.login;
      final isForgotPassword = currentLocation == RoutePaths.forgotPassword;
      final isAuthPage = isSplash || isLogin || isForgotPassword;

      // Still loading - save intended location and redirect to splash
      if (isLoading) {
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
      if (isLoggedIn && (isLogin || isSplash)) {
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
                builder: (context, state) => ResponsiveShell(
                  currentRoute: state.matchedLocation,
                  child: const CustomerFormScreen(),
                ),
              ),
              GoRoute(
                path: ':id',
                name: RouteNames.customerDetail,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ResponsiveShell(
                    currentRoute: state.matchedLocation,
                    child: CustomerDetailScreen(customerId: id),
                  );
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: RouteNames.customerEdit,
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return ResponsiveShell(
                        currentRoute: state.matchedLocation,
                        child: CustomerFormScreen(customerId: id),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'history',
                    name: 'customerHistory',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return ResponsiveShell(
                        currentRoute: state.matchedLocation,
                        child: CustomerHistoryScreen(customerId: id),
                      );
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
            builder: (context, state) {
              final customerId = state.uri.queryParameters['customerId']!;
              return ResponsiveShell(
                currentRoute: state.matchedLocation,
                child: PipelineFormScreen(customerId: customerId),
              );
            },
          ),
          GoRoute(
            path: 'pipelines/:id',
            name: RouteNames.pipelineDetail,
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              final customerId = state.uri.queryParameters['customerId'] ?? '';
              return ResponsiveShell(
                currentRoute: state.matchedLocation,
                child: PipelineDetailScreen(pipelineId: id, customerId: customerId),
              );
            },
            routes: [
              GoRoute(
                path: 'edit',
                name: RouteNames.pipelineEdit,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  final customerId = state.uri.queryParameters['customerId'] ?? '';
                  return ResponsiveShell(
                    currentRoute: state.matchedLocation,
                    child: PipelineFormScreen(customerId: customerId, pipelineId: id),
                  );
                },
              ),
              GoRoute(
                path: 'history',
                name: 'pipelineHistory',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ResponsiveShell(
                    currentRoute: state.matchedLocation,
                    child: PipelineHistoryScreen(pipelineId: id),
                  );
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
                builder: (context, state) {
                  final objectType = state.uri.queryParameters['objectType'];
                  final objectId = state.uri.queryParameters['objectId'];
                  final objectName = state.uri.queryParameters['objectName'];
                  final immediate = state.uri.queryParameters['immediate'] == 'true';
                  return ResponsiveShell(
                    currentRoute: state.matchedLocation,
                    child: ActivityFormScreen(
                      objectType: objectType,
                      objectId: objectId,
                      objectName: objectName,
                      isImmediate: immediate,
                    ),
                  );
                },
              ),
              // Immediate activity route (for entity detail pages)
              GoRoute(
                path: 'immediate',
                name: 'activityImmediate',
                builder: (context, state) {
                  final objectType = state.uri.queryParameters['objectType'];
                  final objectId = state.uri.queryParameters['objectId'];
                  final objectName = state.uri.queryParameters['objectName'];
                  return ResponsiveShell(
                    currentRoute: state.matchedLocation,
                    child: ActivityFormScreen(
                      objectType: objectType,
                      objectId: objectId,
                      objectName: objectName,
                      isImmediate: true,
                    ),
                  );
                },
              ),
              GoRoute(
                path: ':id',
                name: RouteNames.activityDetail,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ResponsiveShell(
                    currentRoute: state.matchedLocation,
                    child: ActivityDetailScreen(activityId: id),
                  );
                },
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
                builder: (context, state) => ResponsiveShell(
                  currentRoute: state.matchedLocation,
                  child: const HvcFormScreen(),
                ),
              ),
              GoRoute(
                path: ':id',
                name: RouteNames.hvcDetail,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ResponsiveShell(
                    currentRoute: state.matchedLocation,
                    child: HvcDetailScreen(hvcId: id),
                  );
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: RouteNames.hvcEdit,
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return ResponsiveShell(
                        currentRoute: state.matchedLocation,
                        child: HvcFormScreen(hvcId: id),
                      );
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
                builder: (context, state) => ResponsiveShell(
                  currentRoute: state.matchedLocation,
                  child: const BrokerFormScreen(),
                ),
              ),
              GoRoute(
                path: ':id',
                name: RouteNames.brokerDetail,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ResponsiveShell(
                    currentRoute: state.matchedLocation,
                    child: BrokerDetailScreen(brokerId: id),
                  );
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: RouteNames.brokerEdit,
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return ResponsiveShell(
                        currentRoute: state.matchedLocation,
                        child: BrokerFormScreen(brokerId: id),
                      );
                    },
                  ),
                ],
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
          ),

          // Cadence
          GoRoute(
            path: 'cadence',
            name: RouteNames.cadence,
            pageBuilder: (context, state) => NoTransitionPage(
              child: ResponsiveShell(
                currentRoute: state.matchedLocation,
                child: const Placeholder(
                  child: Center(child: Text('Cadence')),
                ),
              ),
            ),
          ),

          // Targets
          GoRoute(
            path: 'targets',
            name: RouteNames.targets,
            pageBuilder: (context, state) => NoTransitionPage(
              child: ResponsiveShell(
                currentRoute: state.matchedLocation,
                child: const Placeholder(
                  child: Center(child: Text('Targets')),
                ),
              ),
            ),
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
                builder: (context, state) => ResponsiveShell(
                  currentRoute: state.matchedLocation,
                  child: const EditProfileScreen(),
                ),
              ),
              GoRoute(
                path: 'change-password',
                name: RouteNames.changePassword,
                builder: (context, state) => ResponsiveShell(
                  currentRoute: state.matchedLocation,
                  child: const ChangePasswordScreen(),
                ),
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
                child: const Placeholder(
                  child: Center(child: Text('Notifications')),
                ),
              ),
            ),
          ),

          // Debug: Sync Queue
          GoRoute(
            path: 'sync-queue',
            name: 'syncQueue',
            builder: (context, state) => ResponsiveShell(
              currentRoute: state.matchedLocation,
              child: const SyncQueueScreen(),
            ),
          ),
        ],
      ),

      // ============================================
      // ADMIN ROUTES
      // ============================================
      
      GoRoute(
        path: RoutePaths.admin,
        name: RouteNames.admin,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: Placeholder(
            child: Center(child: Text('Admin Panel')),
          ),
        ),
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

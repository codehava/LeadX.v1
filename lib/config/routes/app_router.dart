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
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/pipeline/pipeline_detail_screen.dart';
import '../../presentation/screens/pipeline/pipeline_form_screen.dart';
import '../../presentation/screens/sync/sync_queue_screen.dart';
import 'route_names.dart';

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

      final isSplash = state.matchedLocation == RoutePaths.splash;
      final isLogin = state.matchedLocation == RoutePaths.login;

      // Still loading - stay on splash
      if (isLoading && isSplash) {
        return null;
      }

      // Not logged in - redirect to login (unless already there)
      if (!isLoggedIn && !isLogin && !isSplash) {
        return RoutePaths.login;
      }

      // Logged in but on login/splash - go to home
      if (isLoggedIn && (isLogin || isSplash)) {
        return RoutePaths.home;
      }

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
        builder: (context, state) => const HomeScreen(),
        routes: [
          // Dashboard
          GoRoute(
            path: 'dashboard',
            name: RouteNames.dashboard,
            builder: (context, state) => const Placeholder(
              child: Center(child: Text('Dashboard')),
            ),
          ),

          // Customers (tab route)
          GoRoute(
            path: 'customers',
            name: RouteNames.customers,
            builder: (context, state) => const HomeScreen(initialTab: 1),
            routes: [
              GoRoute(
                path: 'create',
                name: RouteNames.customerCreate,
                builder: (context, state) => const CustomerFormScreen(),
              ),
              GoRoute(
                path: ':id',
                name: RouteNames.customerDetail,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return CustomerDetailScreen(customerId: id);
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: RouteNames.customerEdit,
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return CustomerFormScreen(customerId: id);
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
              return PipelineFormScreen(customerId: customerId);
            },
          ),
          GoRoute(
            path: 'pipelines/:id',
            name: RouteNames.pipelineDetail,
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              final customerId = state.uri.queryParameters['customerId'] ?? '';
              return PipelineDetailScreen(pipelineId: id, customerId: customerId);
            },
            routes: [
              GoRoute(
                path: 'edit',
                name: RouteNames.pipelineEdit,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  final customerId = state.uri.queryParameters['customerId'] ?? '';
                  return PipelineFormScreen(customerId: customerId, pipelineId: id);
                },
              ),
            ],
          ),

          // Activities (tab route)
          GoRoute(
            path: 'activities',
            name: RouteNames.activities,
            builder: (context, state) => const HomeScreen(initialTab: 3),
            routes: [
              GoRoute(
                path: 'create',
                name: RouteNames.activityCreate,
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
              GoRoute(
                path: ':id',
                name: RouteNames.activityDetail,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ActivityDetailScreen(activityId: id);
                },
              ),
            ],
          ),
          
          // Activity Calendar (top-level route accessible from Dashboard)
          GoRoute(
            path: 'activity/calendar',
            name: RouteNames.activityCalendar,
            builder: (context, state) => const ActivityCalendarScreen(),
          ),

          // HVC
          GoRoute(
            path: 'hvc',
            name: RouteNames.hvc,
            builder: (context, state) => const Placeholder(
              child: Center(child: Text('HVC')),
            ),
          ),

          // Brokers
          GoRoute(
            path: 'brokers',
            name: RouteNames.brokers,
            builder: (context, state) => const Placeholder(
              child: Center(child: Text('Brokers')),
            ),
          ),

          // Scoreboard
          GoRoute(
            path: 'scoreboard',
            name: RouteNames.scoreboard,
            builder: (context, state) => const Placeholder(
              child: Center(child: Text('Scoreboard')),
            ),
          ),

          // Cadence
          GoRoute(
            path: 'cadence',
            name: RouteNames.cadence,
            builder: (context, state) => const Placeholder(
              child: Center(child: Text('Cadence')),
            ),
          ),

          // Profile (tab route)
          GoRoute(
            path: 'profile',
            name: RouteNames.profile,
            builder: (context, state) => const HomeScreen(initialTab: 4),
          ),

          // Settings
          GoRoute(
            path: 'settings',
            name: RouteNames.settings,
            builder: (context, state) => const Placeholder(
              child: Center(child: Text('Settings')),
            ),
          ),

          // Notifications
          GoRoute(
            path: 'notifications',
            name: RouteNames.notifications,
            builder: (context, state) => const Placeholder(
              child: Center(child: Text('Notifications')),
            ),
          ),

          // Debug: Sync Queue
          GoRoute(
            path: 'sync-queue',
            name: 'syncQueue',
            builder: (context, state) => const SyncQueueScreen(),
          ),
        ],
      ),

      // ============================================
      // ADMIN ROUTES
      // ============================================
      
      GoRoute(
        path: RoutePaths.admin,
        name: RouteNames.admin,
        builder: (context, state) => const Placeholder(
          child: Center(child: Text('Admin Panel')),
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

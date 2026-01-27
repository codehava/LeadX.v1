import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/route_names.dart';
import '../../providers/auth_providers.dart';

/// Splash screen shown on app launch.
///
/// Checks authentication state and redirects accordingly.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Minimum splash duration for branding
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check auth state via provider
    // This will wait for session restoration to complete
    final authState = await ref.read(authRepositoryProvider).getAuthState();

    if (!mounted) return;

    authState.when(
      initial: () {
        debugPrint('[Splash] Initial state - redirecting to login');
        context.go(RoutePaths.login);
      },
      loading: () {
        debugPrint('[Splash] Still loading - keeping splash visible');
        // Keep showing splash
      },
      authenticated: (user) {
        debugPrint('[Splash] Authenticated - redirecting to home (user: ${user.email})');
        context.go(RoutePaths.home);
      },
      unauthenticated: () {
        debugPrint('[Splash] Unauthenticated - redirecting to login');
        context.go(RoutePaths.login);
      },
      error: (message) {
        debugPrint('[Splash] Auth error: $message - redirecting to login');
        context.go(RoutePaths.login);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo placeholder
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: colorScheme.onPrimary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  'LX',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // App name
            Text(
              'LeadX CRM',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // Tagline
            Text(
              '4DX Sales Excellence',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onPrimary.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 48),

            // Loading indicator
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

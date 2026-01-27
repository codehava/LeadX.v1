import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/route_names.dart';
import '../../providers/auth_providers.dart';
import '../../providers/sync_providers.dart';
import '../../widgets/sync/sync_progress_sheet.dart';

/// Login screen for user authentication.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(loginNotifierProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );

    if (success && mounted) {
      // Check if initial sync is needed
      final appSettings = ref.read(appSettingsServiceProvider);
      final hasInitialSynced = await appSettings.hasInitialSyncCompleted();

      print('[LoginScreen] Login success, hasInitialSynced=$hasInitialSynced');

      if (!hasInitialSynced) {
        // Show sync progress sheet
        print('[LoginScreen] Starting initial sync...');
        if (mounted) {
          await SyncProgressSheet.show(context);
          // Mark as completed after sync
          await appSettings.markInitialSyncCompleted();
          print('[LoginScreen] Initial sync completed');
        }
      } else {
        print('[LoginScreen] Initial sync already completed, skipping');
      }

      if (mounted) {
        context.go(RoutePaths.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loginState = ref.watch(loginNotifierProvider);

    // Show error snackbar
    ref.listen<AsyncValue<void>>(loginNotifierProvider, (prev, next) {
      next.whenOrNull(
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              backgroundColor: colorScheme.error,
            ),
          );
        },
      );
    });

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Hero section with new design
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 20 : 40,
                        vertical: isMobile ? 32 : 48,
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 768;

                          if (isWide) {
                            // Desktop/Tablet layout - side by side
                            return Row(
                              children: [
                                // Left side - Logo in white circle
                                Expanded(
                                  child: Center(
                                    child: Container(
                                      width: 220,
                                      height: 220,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.15),
                                            blurRadius: 20,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Image.asset(
                                          'assets/images/logo.png',
                                          width: 140,
                                          height: 140,
                                          fit: BoxFit.contain,
                                          filterQuality: FilterQuality.high,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: isWide ? 40 : 24),
                                // Right side - Title, subtitle, and features
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Title
                                      Text(
                                        'LeadX',
                                        style: TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onPrimary,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Text(
                                        'Leading Execution',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.onPrimary
                                              .withValues(alpha: 0.9),
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      // Subtitle
                                      Text(
                                        'Tajam, Cepat, Decisive.\nDominasi pipeline\ndengan disiplin harian',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: colorScheme.onPrimary
                                              .withValues(alpha: 0.85),
                                          fontWeight: FontWeight.w500,
                                          height: 1.6,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 28),
                                      // Features grid - 3 columns on wide
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          _FeatureHighlight(
                                            title: 'AI-Powered',
                                            backgroundColor: Colors.white
                                                .withValues(alpha: 0.15),
                                          ),
                                          _FeatureHighlight(
                                            title: 'Realtime Score',
                                            backgroundColor: Colors.white
                                                .withValues(alpha: 0.15),
                                          ),
                                          _FeatureHighlight(
                                            title: 'Action-First',
                                            backgroundColor: Colors.white
                                                .withValues(alpha: 0.15),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          } else {
                            // Mobile layout - compact and optimized
                            return Column(
                              children: [
                                // Logo in white circle - smaller for mobile
                                Container(
                                  width: 130,
                                  height: 130,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.15),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      'assets/images/logo.png',
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.contain,
                                      filterQuality: FilterQuality.high,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Title
                                Text(
                                  'LeadX',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onPrimary,
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  'Leading Execution',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onPrimary
                                        .withValues(alpha: 0.9),
                                    letterSpacing: 0.3,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 10),
                                // Subtitle
                                Text(
                                  'Tajam, Cepat, Decisive.\nDominasi pipeline\ndengan disiplin harian',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onPrimary
                                        .withValues(alpha: 0.85),
                                    fontWeight: FontWeight.w500,
                                    height: 1.5,
                                    letterSpacing: 0.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 14),
                                // Features - optimized for mobile
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  runSpacing: 8,
                                  spacing: 8,
                                  children: [
                                    _FeatureHighlight(
                                      title: 'AI-Powered',
                                      backgroundColor: Colors.white
                                          .withValues(alpha: 0.15),
                                    ),
                                    _FeatureHighlight(
                                      title: 'Realtime Score',
                                      backgroundColor: Colors.white
                                          .withValues(alpha: 0.15),
                                    ),
                                    _FeatureHighlight(
                                      title: 'Action-First',
                                      backgroundColor:
                                          Colors.white.withValues(alpha: 0.15),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),

                // Form section
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 24 : 48,
                    vertical: isMobile ? 32 : 48,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Email field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            decoration: const InputDecoration(
                              labelText: 'Alamat Email',
                              hintText: 'Masukkan email Anda',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Mohon masukkan email Anda';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Email tidak valid';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Password field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            onFieldSubmitted: (_) => _handleLogin(),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Masukkan password Anda',
                              prefixIcon: const Icon(Icons.lock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() => _obscurePassword = !_obscurePassword);
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Mohon masukkan password Anda';
                              }
                              if (value.length < 6) {
                                return 'Password minimal 6 karakter';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Forgot password link
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => context.go(RoutePaths.forgotPassword),
                              child: const Text('Lupa Password?'),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Login button
                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: loginState.isLoading ? null : _handleLogin,
                              child: loginState.isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Masuk',
                                      style: TextStyle(
                                        fontSize: isMobile ? 16 : 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Footer text

                          const SizedBox(height: 16),
                          Text(
                            'PT Askrindo (Persero)',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Feature highlight card widget
class _FeatureHighlight extends StatelessWidget {
  final String title;
  final Color backgroundColor;

  const _FeatureHighlight({
    required this.title,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

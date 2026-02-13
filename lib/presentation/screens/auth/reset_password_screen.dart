import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../config/routes/route_names.dart';
import '../../../core/logging/app_logger.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/password_strength_indicator.dart';

/// Screen for resetting user password after email verification.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _sessionValid = true;
  bool _checkingSession = true;

  @override
  void initState() {
    super.initState();
    _waitForAuthState();
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Wait for auth state to settle and check for valid session.
  /// This handles the timing issue where the URL code may not be processed yet.
  Future<void> _waitForAuthState() async {
    // Give Supabase time to process the URL code parameter
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // Check Supabase session directly (faster than waiting for profile fetch)
    var session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      // Still no session - try to process URL code manually (web only)
      await _tryProcessUrlCode();

      if (!mounted) return;

      // Check again after manual processing
      session = Supabase.instance.client.auth.currentSession;
    }

    if (!mounted) return;

    setState(() => _checkingSession = false);

    if (session == null) {
      _showExpiredTokenDialog();
    }
  }

  /// Try to get session from URL (web platform only).
  /// Uses getSessionFromUrl() which handles both PKCE and implicit flows.
  /// Note: For PKCE, the reset link must be opened in the same browser
  /// where the password reset was requested.
  Future<void> _tryProcessUrlCode() async {
    if (!kIsWeb) return;

    try {
      AppLogger.instance.debug('auth | ResetPassword: Attempting to get session from URL...');
      await Supabase.instance.client.auth.getSessionFromUrl(Uri.base);
      AppLogger.instance.info('auth | ResetPassword: Session retrieved from URL successfully');
    } catch (e) {
      AppLogger.instance.warning('auth | ResetPassword: Failed to get session from URL: $e');
    }
  }

  void _showExpiredTokenDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.error_outline,
          color: Theme.of(context).colorScheme.error,
          size: 48,
        ),
        title: const Text('Reset Link Expired'),
        content: const Text(
          'The password reset link has expired. Please request a new one.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go(RoutePaths.forgotPassword);
            },
            child: const Text('Request New Link'),
          ),
        ],
      ),
    );

    setState(() => _sessionValid = false);
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authRepo = ref.read(authRepositoryProvider);

      // Call updatePassword
      final result = await authRepo.updatePassword(
        newPassword: _newPasswordController.text,
      );

      if (!mounted) return;

      result.fold(
        (failure) {
          // Show error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        },
        (_) async {
          // Success - show dialog and redirect to login
          if (!mounted) return;
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              icon: const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 48,
              ),
              title: const Text('Password Reset Successful'),
              content: const Text(
                'Your password has been reset successfully. Please log in with your new password.',
              ),
              actions: [
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );

          // Redirect to login
          if (mounted) {
            context.go(RoutePaths.login);
          }
        },
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Show loading while checking session
    if (_checkingSession) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Verifying reset link...',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    if (!_sessionValid) {
      return const Scaffold(
        body: SizedBox.expand(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon
                Center(
                  child: Icon(
                    Icons.lock_reset,
                    size: 64,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  'Create New Password',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                Text(
                  'Enter a strong password for your account',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Info Card with Requirements
                Card(
                  color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.security_outlined,
                              color: colorScheme.onSecondaryContainer,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Password Requirements',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildRequirement('Minimum 8 characters'),
                        _buildRequirement('Contains lowercase letter (a-z)'),
                        _buildRequirement('Contains uppercase letter (A-Z)'),
                        _buildRequirement('Contains number (0-9)'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // New Password
                TextFormField(
                  controller: _newPasswordController,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscureNewPassword = !_obscureNewPassword);
                      },
                    ),
                  ),
                  obscureText: _obscureNewPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (!PasswordStrengthIndicator.isPasswordValid(value)) {
                      return 'Password does not meet minimum requirements';
                    }
                    return null;
                  },
                  onChanged: (_) => setState(() {}),
                  textInputAction: TextInputAction.next,
                ),

                // Password Strength Indicator
                PasswordStrengthIndicator(
                  password: _newPasswordController.text,
                ),

                const SizedBox(height: 16),

                // Confirm Password
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                      },
                    ),
                  ),
                  obscureText: _obscureConfirmPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleResetPassword(),
                ),

                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _handleResetPassword,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Reset Password'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 32, top: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

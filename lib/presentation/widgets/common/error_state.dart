import 'package:flutter/material.dart';

/// Error state widget for displaying errors.
class AppErrorState extends StatelessWidget {
  final String title;
  final String? message;
  final String? retryLabel;
  final VoidCallback? onRetry;
  final IconData icon;

  const AppErrorState({
    super.key,
    required this.title,
    this.message,
    this.retryLabel = 'Retry',
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  /// Factory for general error
  factory AppErrorState.general({
    String title = 'Something went wrong',
    String? message,
    VoidCallback? onRetry,
  }) =>
      AppErrorState(
        title: title,
        message: message,
        onRetry: onRetry,
      );

  /// Factory for network error
  factory AppErrorState.network({VoidCallback? onRetry}) => AppErrorState(
        icon: Icons.wifi_off,
        title: 'Connection Error',
        message: 'Please check your internet connection and try again.',
        onRetry: onRetry,
      );

  /// Factory for not found error
  factory AppErrorState.notFound({String? message}) => AppErrorState(
        icon: Icons.search_off,
        title: 'Not Found',
        message: message ?? 'The requested resource was not found.',
      );

  /// Factory for permission denied
  factory AppErrorState.permissionDenied() => const AppErrorState(
        icon: Icons.lock_outlined,
        title: 'Access Denied',
        message: 'You do not have permission to access this resource.',
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: colorScheme.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: Text(retryLabel!),
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

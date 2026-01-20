import 'package:flutter/material.dart';

/// Empty state widget for lists and screens.
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  /// Factory for empty list state
  factory AppEmptyState.noData({
    required String title,
    String? subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) =>
      AppEmptyState(
        icon: Icons.inbox_outlined,
        title: title,
        subtitle: subtitle,
        actionLabel: actionLabel,
        onAction: onAction,
      );

  /// Factory for search with no results
  factory AppEmptyState.noSearchResults({
    String title = 'No results found',
    String? subtitle,
  }) =>
      AppEmptyState(
        icon: Icons.search_off,
        title: title,
        subtitle: subtitle ?? 'Try adjusting your search criteria',
      );

  /// Factory for offline state
  factory AppEmptyState.offline({
    VoidCallback? onRetry,
  }) =>
      AppEmptyState(
        icon: Icons.wifi_off,
        title: 'You are offline',
        subtitle: 'Check your internet connection',
        actionLabel: 'Retry',
        onAction: onRetry,
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
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

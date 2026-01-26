import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/route_names.dart';

/// Screen displayed when a user tries to access an admin-only page
/// without proper permissions.
class UnauthorizedScreen extends StatelessWidget {
  const UnauthorizedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lock Icon
              Icon(
                Icons.lock_outline,
                size: 80,
                color: colorScheme.error,
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Akses Ditolak',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Message
              Text(
                'Anda tidak memiliki izin untuk mengakses halaman ini.\nHubungi administrator untuk informasi lebih lanjut.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Go Back Button
              FilledButton.icon(
                onPressed: () => context.go(RoutePaths.home),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Kembali ke Beranda'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

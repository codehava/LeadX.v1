import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/sync_providers.dart';

/// A compact banner that shows when the device is offline.
///
/// Watches [connectivityStreamProvider] and displays a staleness warning
/// when the device is disconnected. Defaults to "connected" during loading
/// to avoid false offline flash on startup.
///
/// Place at the top of a Column/ListView -- it shows/hides itself.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityStreamProvider);
    final isConnected = connectivityAsync.valueOrNull ?? true;

    if (isConnected) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.orange.shade100,
      child: Row(
        children: [
          Icon(
            Icons.wifi_off,
            size: 16,
            color: Colors.orange.shade800,
          ),
          const SizedBox(width: 8),
          Text(
            'Offline - data may be stale',
            style: TextStyle(
              fontSize: 13,
              color: Colors.orange.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

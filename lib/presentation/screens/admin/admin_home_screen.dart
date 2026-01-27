import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/route_names.dart';
import '../../widgets/admin/admin_menu_card.dart';

/// Admin panel home screen with main menu options.
///
/// Provides access to:
/// - User Management
/// - Master Data Management
/// - 4DX Configuration
/// - Cadence Management
/// - Bulk Upload
class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Admin'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Text(
            'Selamat Datang di Panel Admin',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kelola pengguna, data master, dan konfigurasi sistem',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Menu Items (Vertical List)
          // User Management
          AdminMenuCard(
            icon: Icons.people,
            title: 'Manajemen Pengguna',
            subtitle: 'Kelola pengguna dan hierarki',
            color: Colors.blue,
            onTap: () => context.push(RoutePaths.adminUsers),
          ),
          const SizedBox(height: 12),

          // Master Data Management
          AdminMenuCard(
            icon: Icons.storage,
            title: 'Data Master',
            subtitle: 'Kelola tipe perusahaan, industri, dll',
            color: Colors.green,
            onTap: () => context.push(RoutePaths.adminMasterData),
          ),
          const SizedBox(height: 12),

          // 4DX Configuration
          AdminMenuCard(
            icon: Icons.dashboard,
            title: 'Konfigurasi 4DX',
            subtitle: 'Kelola ukuran dan periode penilaian',
            color: Colors.orange,
            onTap: () => context.push(RoutePaths.admin4dx),
          ),
          const SizedBox(height: 12),

          // Cadence Management
          AdminMenuCard(
            icon: Icons.calendar_today,
            title: 'Manajemen Cadence',
            subtitle: 'Kelola jadwal dan komitmen',
            color: Colors.purple,
            onTap: () => context.push(RoutePaths.adminCadence),
          ),
          const SizedBox(height: 12),

          // Bulk Upload
          AdminMenuCard(
            icon: Icons.upload_file,
            title: 'Upload Massal',
            subtitle: 'Import data dari file CSV',
            color: Colors.teal,
            onTap: () => context.push(RoutePaths.adminBulkUpload),
          ),
        ],
      ),
    );
  }
}

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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

            // Menu Grid
            LayoutBuilder(
              builder: (context, constraints) {
                // Calculate grid columns based on screen width
                int crossAxisCount;
                if (constraints.maxWidth >= 1200) {
                  crossAxisCount = 3; // Desktop: 3 columns
                } else if (constraints.maxWidth >= 600) {
                  crossAxisCount = 2; // Tablet: 2 columns
                } else {
                  crossAxisCount = 1; // Mobile: 1 column
                }

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    // User Management
                    AdminMenuCard(
                      icon: Icons.people,
                      title: 'Manajemen Pengguna',
                      subtitle: 'Kelola pengguna dan hierarki',
                      color: Colors.blue,
                      onTap: () => context.push(RoutePaths.adminUsers),
                    ),

                    // Master Data Management
                    AdminMenuCard(
                      icon: Icons.storage,
                      title: 'Data Master',
                      subtitle: 'Kelola tipe perusahaan, industri, dll',
                      color: Colors.green,
                      onTap: () => context.push(RoutePaths.adminMasterData),
                    ),

                    // 4DX Configuration
                    AdminMenuCard(
                      icon: Icons.dashboard,
                      title: 'Konfigurasi 4DX',
                      subtitle: 'Kelola ukuran dan periode penilaian',
                      color: Colors.orange,
                      onTap: () => context.push(RoutePaths.admin4dx),
                    ),

                    // Cadence Management
                    AdminMenuCard(
                      icon: Icons.calendar_today,
                      title: 'Manajemen Cadence',
                      subtitle: 'Kelola jadwal dan komitmen',
                      color: Colors.purple,
                      onTap: () => context.push(RoutePaths.adminCadence),
                    ),

                    // Bulk Upload
                    AdminMenuCard(
                      icon: Icons.upload_file,
                      title: 'Upload Massal',
                      subtitle: 'Import data dari file CSV',
                      color: Colors.teal,
                      onTap: () => context.push(RoutePaths.adminBulkUpload),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

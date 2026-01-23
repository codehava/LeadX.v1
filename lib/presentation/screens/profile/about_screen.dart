import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// About screen showing app information.
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() => _packageInfo = info);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Logo and Name
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.business_center,
                    size: 60,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'LeadX CRM',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                if (_packageInfo != null)
                  Text(
                    'Versi ${_packageInfo!.version} (${_packageInfo!.buildNumber})',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  )
                else
                  const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Description
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'LeadX CRM adalah aplikasi manajemen hubungan pelanggan yang dirancang untuk membantu tim sales mengelola leads, aktivitas, dan pipeline dengan lebih efisien.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Links Section
          _buildSectionHeader(context, 'Informasi'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Syarat dan Ketentuan'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _launchUrl('https://example.com/terms'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Kebijakan Privasi'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _launchUrl('https://example.com/privacy'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.gavel_outlined),
                  title: const Text('Lisensi Open Source'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showLicensePage(
                      context: context,
                      applicationName: 'LeadX CRM',
                      applicationVersion: _packageInfo?.version ?? 'Unknown',
                      applicationIcon: Icon(
                        Icons.business_center,
                        size: 48,
                        color: colorScheme.primary,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Support Section
          _buildSectionHeader(context, 'Dukungan'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Email Support'),
                  subtitle: const Text('support@leadxcrm.com'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _launchUrl('mailto:support@leadxcrm.com'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: const Text('Hubungi Kami'),
                  subtitle: const Text('+62 21 1234 5678'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _launchUrl('tel:+622112345678'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Copyright
          Center(
            child: Text(
              '© 2026 LeadX CRM. All rights reserved.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tidak dapat membuka: $urlString'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}

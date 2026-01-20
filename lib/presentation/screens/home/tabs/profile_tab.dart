import 'package:flutter/material.dart';

/// Profile tab showing user profile.
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: const Center(
        child: Text('Profile - Coming Soon'),
      ),
    );
  }
}

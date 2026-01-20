import 'package:flutter/material.dart';

/// Activities tab showing activity calendar.
class ActivitiesTab extends StatelessWidget {
  const ActivitiesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aktivitas'),
      ),
      body: const Center(
        child: Text('Activity Calendar - Coming Soon'),
      ),
    );
  }
}

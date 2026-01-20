import 'package:flutter/material.dart';

/// Activity card widget for displaying activity items on dashboard.
class ActivityCard extends StatelessWidget {
  final String title;
  final String time;
  final IconData icon;
  final Color statusColor;
  final String status;
  final VoidCallback? onTap;

  const ActivityCard({
    super.key,
    required this.title,
    required this.time,
    required this.icon,
    required this.statusColor,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.1),
          child: Icon(icon, color: statusColor),
        ),
        title: Text(title),
        subtitle: Text(time),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

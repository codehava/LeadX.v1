import 'package:flutter/material.dart';

import '../../../domain/entities/pipeline_referral.dart';

/// Badge widget for displaying referral status with color coding.
class ReferralStatusBadge extends StatelessWidget {
  const ReferralStatusBadge({
    super.key,
    required this.status,
    this.showIcon = true,
    this.compact = false,
  });

  final ReferralStatus status;
  final bool showIcon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _getStatusStyle(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 10,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(compact ? 4 : 8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(icon, size: compact ? 12 : 14, color: color),
            SizedBox(width: compact ? 2 : 4),
          ],
          Text(
            status.displayName,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: compact ? 10 : 12,
            ),
          ),
        ],
      ),
    );
  }

  (Color, IconData) _getStatusStyle(ReferralStatus status) {
    return switch (status) {
      ReferralStatus.pendingReceiver => (Colors.orange, Icons.hourglass_empty),
      ReferralStatus.receiverAccepted => (Colors.blue, Icons.check_circle_outline),
      ReferralStatus.receiverRejected => (Colors.red, Icons.cancel_outlined),
      ReferralStatus.pendingBm => (Colors.purple, Icons.pending_actions),
      ReferralStatus.bmApproved => (Colors.green, Icons.verified),
      ReferralStatus.bmRejected => (Colors.red, Icons.block),
      ReferralStatus.completed => (Colors.green, Icons.check_circle),
      ReferralStatus.cancelled => (Colors.grey, Icons.cancel),
    };
  }
}

/// Badge widget for displaying approver type (BM or ROH).
class ApproverTypeBadge extends StatelessWidget {
  const ApproverTypeBadge({
    super.key,
    required this.approverType,
    this.approverName,
    this.compact = false,
  });

  final ApproverType approverType;
  final String? approverName;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = approverType == ApproverType.bm
        ? Colors.indigo
        : Colors.teal;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            approverType == ApproverType.bm
                ? Icons.business
                : Icons.location_city,
            size: compact ? 12 : 14,
            color: color,
          ),
          SizedBox(width: compact ? 2 : 4),
          Text(
            approverName ?? approverType.shortName,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: compact ? 10 : 11,
            ),
          ),
        ],
      ),
    );
  }
}

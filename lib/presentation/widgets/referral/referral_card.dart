import 'package:flutter/material.dart';

import '../../../domain/entities/pipeline_referral.dart';
import '../common/app_card.dart';
import '../common/sync_status_badge.dart';
import 'referral_status_badge.dart';

/// Card widget for displaying pipeline referral in a list.
class ReferralCard extends StatelessWidget {
  const ReferralCard({
    super.key,
    required this.referral,
    this.onTap,
    this.onLongPress,
    this.showSyncStatus = true,
    this.currentUserId,
  });

  final PipelineReferral referral;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showSyncStatus;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine perspective (incoming or outgoing)
    final isIncoming = currentUserId != null && referral.isReceiver(currentUserId!);
    final isOutgoing = currentUserId != null && referral.isReferrer(currentUserId!);

    return AppCard.elevated(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with icon, code, and status
          Row(
            children: [
              // Direction icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (isIncoming ? Colors.green : Colors.blue)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isIncoming
                      ? Icons.call_received
                      : isOutgoing
                          ? Icons.call_made
                          : Icons.swap_horiz,
                  size: 20,
                  color: isIncoming ? Colors.green : Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              // Code and transfer direction
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      referral.code,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      referral.transferDisplay,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              ReferralStatusBadge(
                status: referral.status,
                compact: true,
              ),
              // Sync status
              if (showSyncStatus && referral.isPendingSync) ...[
                const SizedBox(width: 8),
                const SyncStatusBadge(status: SyncStatus.pending),
              ],
            ],
          ),

          const SizedBox(height: 12),

          // Customer info
          Row(
            children: [
              Icon(
                Icons.business_outlined,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  referral.customerName ?? 'Unknown Customer',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Footer with approver type and date
          Row(
            children: [
              // Approver type badge
              ApproverTypeBadge(
                approverType: referral.approverType,
                approverName: referral.approverName,
                compact: true,
              ),
              const Spacer(),
              // Date
              Icon(
                Icons.schedule,
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                _formatDate(referral.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          // Action hint for pending items
          if (_showActionHint(isIncoming, isOutgoing)) ...[
            const SizedBox(height: 8),
            _buildActionHint(context, isIncoming),
          ],
        ],
      ),
    );
  }

  bool _showActionHint(bool isIncoming, bool isOutgoing) {
    if (isIncoming && referral.status == ReferralStatus.pendingReceiver) {
      return true;
    }
    if (isOutgoing && referral.canBeCancelled) {
      return true;
    }
    return false;
  }

  Widget _buildActionHint(BuildContext context, bool isIncoming) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    String text;
    Color color;

    if (isIncoming && referral.status == ReferralStatus.pendingReceiver) {
      text = 'Menunggu respon Anda';
      color = Colors.orange;
    } else {
      text = 'Dapat dibatalkan';
      color = colorScheme.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

/// A simpler card for manager approval queue.
class ReferralApprovalCard extends StatelessWidget {
  const ReferralApprovalCard({
    super.key,
    required this.referral,
    this.onTap,
    this.onApprove,
    this.onReject,
  });

  final PipelineReferral referral;
  final VoidCallback? onTap;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppCard.elevated(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.approval,
                  size: 20,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      referral.customerName ?? 'Unknown Customer',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      referral.code,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              ReferralStatusBadge(
                status: referral.status,
                compact: true,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Transfer info
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dari',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        referral.referrerRmName ?? 'Unknown',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (referral.referrerBranchName != null)
                        Text(
                          referral.referrerBranchName!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward,
                  color: colorScheme.onSurfaceVariant,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Kepada',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        referral.receiverRmName ?? 'Unknown',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                      if (referral.receiverBranchName != null)
                        Text(
                          referral.receiverBranchName!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          if (onApprove != null || onReject != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (onReject != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Tolak'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                if (onApprove != null && onReject != null)
                  const SizedBox(width: 12),
                if (onApprove != null)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onApprove,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Setujui'),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

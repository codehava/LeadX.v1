import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/pipeline.dart';
import '../../providers/pipeline_providers.dart';
import '../../widgets/common/loading_indicator.dart';
import 'pipeline_stage_update_sheet.dart';
import 'pipeline_status_update_sheet.dart';

/// Detail screen for viewing pipeline information.
class PipelineDetailScreen extends ConsumerWidget {
  const PipelineDetailScreen({
    super.key,
    required this.pipelineId,
    required this.customerId,
  });

  final String pipelineId;
  final String customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pipelineAsync = ref.watch(pipelineDetailProvider(pipelineId));
    final theme = Theme.of(context);

    return pipelineAsync.when(
      data: (pipeline) {
        if (pipeline == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Pipeline')),
            body: const Center(child: Text('Pipeline tidak ditemukan')),
          );
        }
        return _buildContent(context, ref, pipeline, theme);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Pipeline')),
        body: const Center(child: AppLoadingIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Pipeline')),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    Pipeline pipeline,
    ThemeData theme,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pipeline.code),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push(
              '/home/pipelines/${pipeline.id}/edit?customerId=$customerId',
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, ref, value, pipeline),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'stage', child: Text('Pindah Stage')),
              const PopupMenuItem(value: 'status', child: Text('Update Status')),
              const PopupMenuItem(value: 'delete', child: Text('Hapus')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stage Badge
            _buildStageCard(pipeline, theme),
            
            const SizedBox(height: 24),
            
            // Product Info
            _InfoSection(
              title: 'Informasi Produk',
              children: [
                _InfoRow(label: 'Kode', value: pipeline.code),
                _InfoRow(label: 'COB', value: pipeline.cobName ?? '-'),
                _InfoRow(label: 'LOB', value: pipeline.lobName ?? '-'),
                _InfoRow(label: 'Lead Source', value: pipeline.leadSourceName ?? '-'),
                if (pipeline.brokerName != null)
                  _InfoRow(label: 'Broker', value: pipeline.brokerName!),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Financial Info
            _InfoSection(
              title: 'Informasi Finansial',
              children: [
                _InfoRow(label: 'Potensi Premi', value: pipeline.formattedPotentialPremium),
                _InfoRow(label: 'Weighted Value', value: pipeline.formattedWeightedValue),
                if (pipeline.tsi != null)
                  _InfoRow(label: 'TSI', value: pipeline.formattedTsi),
                if (pipeline.finalPremium != null)
                  _InfoRow(label: 'Final Premi', value: pipeline.formattedFinalPremium),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Status & Dates
            _InfoSection(
              title: 'Status & Tanggal',
              children: [
                _InfoRow(label: 'Stage', value: pipeline.stageName ?? '-'),
                _InfoRow(label: 'Status', value: pipeline.statusName ?? '-'),
                if (pipeline.expectedCloseDate != null)
                  _InfoRow(
                    label: 'Perkiraan Closing',
                    value: _formatDate(pipeline.expectedCloseDate!),
                  ),
                if (pipeline.closedAt != null)
                  _InfoRow(
                    label: 'Tanggal Closing',
                    value: _formatDate(pipeline.closedAt!),
                  ),
                _InfoRow(
                  label: 'Tender',
                  value: pipeline.isTender ? 'Ya' : 'Tidak',
                ),
              ],
            ),
            
            if (pipeline.policyNumber != null) ...[
              const SizedBox(height: 24),
              _InfoSection(
                title: 'Hasil',
                children: [
                  _InfoRow(label: 'Nomor Polis', value: pipeline.policyNumber!),
                ],
              ),
            ],
            
            if (pipeline.declineReason != null) ...[
              const SizedBox(height: 24),
              _InfoSection(
                title: 'Hasil',
                children: [
                  _InfoRow(label: 'Alasan Ditolak', value: pipeline.declineReason!),
                ],
              ),
            ],
            
            if (pipeline.notes != null) ...[
              const SizedBox(height: 24),
              _InfoSection(
                title: 'Catatan',
                children: [
                  Text(pipeline.notes!, style: theme.textTheme.bodyMedium),
                ],
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Metadata
            _InfoSection(
              title: 'Informasi Lainnya',
              children: [
                _InfoRow(label: 'Customer', value: pipeline.customerName ?? '-'),
                _InfoRow(label: 'RM', value: pipeline.assignedRmName ?? '-'),
                _InfoRow(label: 'Dibuat', value: _formatDateTime(pipeline.createdAt)),
                _InfoRow(label: 'Diupdate', value: _formatDateTime(pipeline.updatedAt)),
              ],
            ),
          ],
        ),
      ),
      // Quick action buttons
      bottomNavigationBar: _buildQuickActions(context, pipeline, theme),
    );
  }

  Widget _buildStageCard(Pipeline pipeline, ThemeData theme) {
    final stageColor = _parseColor(pipeline.stageColor);
    final probability = pipeline.stageProbability ?? 0;
    
    return Card(
      color: stageColor?.withAlpha(30),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: stageColor ?? theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$probability%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pipeline.stageName ?? 'Unknown Stage',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: stageColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pipeline.statusName ?? 'Unknown Status',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (pipeline.isWon) ...[
                    const SizedBox(height: 8),
                    Chip(
                      label: const Text('WON'),
                      backgroundColor: Colors.green.shade100,
                      labelStyle: TextStyle(color: Colors.green.shade800),
                    ),
                  ],
                  if (pipeline.isLost) ...[
                    const SizedBox(height: 8),
                    Chip(
                      label: const Text('LOST'),
                      backgroundColor: Colors.red.shade100,
                      labelStyle: TextStyle(color: Colors.red.shade800),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, Pipeline pipeline, ThemeData theme) {
    if (pipeline.isClosed) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => PipelineStageUpdateSheet.show(context, pipeline),
              icon: const Icon(Icons.trending_up),
              label: const Text('Pindah Stage'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => PipelineStatusUpdateSheet.show(context, pipeline),
              icon: const Icon(Icons.flag),
              label: const Text('Update Status'),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: () => context.push(
              '/home/pipelines/${pipeline.id}/edit?customerId=$customerId',
            ),
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    String action,
    Pipeline pipeline,
  ) {
    switch (action) {
      case 'delete':
        _showDeleteConfirmation(context, ref, pipeline);
      case 'stage':
        PipelineStageUpdateSheet.show(context, pipeline);
      case 'status':
        PipelineStatusUpdateSheet.show(context, pipeline);
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Pipeline pipeline,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pipeline?'),
        content: Text('Apakah Anda yakin ingin menghapus ${pipeline.code}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(pipelineFormNotifierProvider.notifier)
                  .deletePipeline(pipeline.id);
              if (context.mounted) {
                context.pop();
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Color? _parseColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) return null;
    try {
      final hex = colorHex.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return null;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/dtos/pipeline_dtos.dart';
import '../../../domain/entities/pipeline.dart';
import '../../providers/pipeline_providers.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/loading_indicator.dart';

/// Bottom sheet for updating pipeline status within the current stage.
/// This is for changing the status without changing the stage.
class PipelineStatusUpdateSheet extends ConsumerStatefulWidget {
  const PipelineStatusUpdateSheet({
    super.key,
    required this.pipeline,
  });

  final Pipeline pipeline;

  /// Show the status update sheet.
  static Future<void> show(BuildContext context, Pipeline pipeline) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => PipelineStatusUpdateSheet(pipeline: pipeline),
    );
  }

  @override
  ConsumerState<PipelineStatusUpdateSheet> createState() =>
      _PipelineStatusUpdateSheetState();
}

class _PipelineStatusUpdateSheetState
    extends ConsumerState<PipelineStatusUpdateSheet> {
  String? _selectedStatusId;
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedStatusId = widget.pipeline.statusId;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final statusesAsync = ref.watch(
      pipelineStatusesByStageProvider(widget.pipeline.stageId),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withAlpha(100),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Update Status',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Stage/Status Info
                    _buildCurrentInfo(theme),
                    const SizedBox(height: 24),

                    // Status Selection
                    Text(
                      'Pilih Status Baru',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    statusesAsync.when(
                      data: (List<PipelineStatusInfo> statuses) => 
                          _buildStatusList(statuses, theme),
                      loading: () => const Center(child: AppLoadingIndicator()),
                      error: (e, _) => Text('Error: $e'),
                    ),

                    // Notes field
                    const SizedBox(height: 24),
                    AppTextField(
                      controller: _notesController,
                      label: 'Catatan',
                      hint: 'Catatan perubahan status (opsional)',
                      maxLines: 2,
                    ),

                    const SizedBox(height: 24),

                    // Submit Button
                    AppButton(
                      label: 'Update Status',
                      isLoading: _isLoading,
                      onPressed: _handleSubmit,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentInfo(ThemeData theme) {
    final stageColor = _parseColor(widget.pipeline.stageColor);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.flag, color: stageColor ?? theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: stageColor?.withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.pipeline.stageName ?? 'Unknown Stage',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: stageColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Status Saat Ini: ${widget.pipeline.statusName ?? "Unknown"}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusList(List<PipelineStatusInfo> statuses, ThemeData theme) {
    if (statuses.isEmpty) {
      return Text(
        'Tidak ada status tersedia untuk stage ini',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: statuses.map((status) {
        final isSelected = status.id == _selectedStatusId;
        final isCurrent = status.id == widget.pipeline.statusId;
        
        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(status.name),
              if (isCurrent) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.check,
                  size: 14,
                  color: isSelected
                      ? theme.colorScheme.onSecondaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ],
          ),
          selected: isSelected,
          labelStyle: TextStyle(
            color: isSelected
                ? theme.colorScheme.onSecondaryContainer
                : theme.colorScheme.onSurface,
          ),
          onSelected: (selected) {
            if (selected) {
              setState(() => _selectedStatusId = status.id);
            }
          },
        );
      }).toList(),
    );
  }

  Future<void> _handleSubmit() async {
    if (_selectedStatusId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih status baru'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Don't allow submitting if selecting the same status
    if (_selectedStatusId == widget.pipeline.statusId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih status yang berbeda'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(pipelineRepositoryProvider);
      
      final dto = PipelineStatusUpdateDto(
        statusId: _selectedStatusId!,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      final result = await repo.updatePipelineStatus(widget.pipeline.id, dto);

      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (pipeline) {
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Status berhasil diupdate'),
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
}

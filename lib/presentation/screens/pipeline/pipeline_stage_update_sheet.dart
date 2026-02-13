import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/result.dart';
import '../../../data/dtos/pipeline_dtos.dart';
import '../../../data/dtos/master_data_dtos.dart';
import '../../../domain/entities/pipeline.dart';
import '../../providers/pipeline_providers.dart';
import '../../providers/master_data_providers.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/loading_indicator.dart';

/// Bottom sheet for updating pipeline stage.
/// This is for moving a pipeline from one stage to another.
/// Status is automatically assigned to the default status of the new stage.
class PipelineStageUpdateSheet extends ConsumerStatefulWidget {
  const PipelineStageUpdateSheet({
    super.key,
    required this.pipeline,
  });

  final Pipeline pipeline;

  /// Show the stage update sheet.
  static Future<void> show(BuildContext context, Pipeline pipeline) {
    // Guard against updating closed pipelines
    if (pipeline.isClosed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pipeline sudah ditutup dan tidak dapat diubah'),
          backgroundColor: Colors.orange,
        ),
      );
      return Future.value();
    }

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => PipelineStageUpdateSheet(pipeline: pipeline),
    );
  }

  @override
  ConsumerState<PipelineStageUpdateSheet> createState() =>
      _PipelineStageUpdateSheetState();
}

class _PipelineStageUpdateSheetState
    extends ConsumerState<PipelineStageUpdateSheet> {
  String? _selectedStageId;
  final _policyNumberController = TextEditingController();
  final _declineReasonController = TextEditingController();
  final _finalPremiumController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedStageId = widget.pipeline.stageId;
  }

  @override
  void dispose() {
    _policyNumberController.dispose();
    _declineReasonController.dispose();
    _finalPremiumController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final stagesAsync = ref.watch(pipelineStagesStreamProvider);

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
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
                    'Pindah Stage',
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
                    // Current Stage Info
                    _buildCurrentStageInfo(theme),
                    const SizedBox(height: 24),

                    // Stage Selection
                    Text(
                      'Pilih Stage Baru',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Status akan otomatis diatur ke status default stage yang dipilih',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    stagesAsync.when(
                      data: (List<PipelineStageDto> stages) => _buildStageList(stages, theme),
                      loading: () => const Center(child: AppLoadingIndicator()),
                      error: (e, _) => Text('Error: $e'),
                    ),

                    // Notes field
                    const SizedBox(height: 24),
                    AppTextField(
                      controller: _notesController,
                      label: 'Catatan',
                      hint: 'Catatan perubahan stage (opsional)',
                      maxLines: 2,
                    ),

                    // Final Stage Fields
                    _buildFinalStageFields(theme),

                    const SizedBox(height: 24),

                    // Submit Button
                    AppButton(
                      label: 'Pindah Stage',
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

  Widget _buildCurrentStageInfo(ThemeData theme) {
    final stageColor = _parseColor(widget.pipeline.stageColor);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.trending_up, color: stageColor ?? theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stage Saat Ini',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  widget.pipeline.stageName ?? 'Unknown',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: stageColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.pipeline.statusName != null)
                  Text(
                    'Status: ${widget.pipeline.statusName}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: stageColor?.withAlpha(30),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${widget.pipeline.stageProbability ?? 0}%',
              style: theme.textTheme.labelLarge?.copyWith(
                color: stageColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageList(List<PipelineStageDto> stages, ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: stages.map((stage) {
        final isSelected = stage.id == _selectedStageId;
        final isCurrent = stage.id == widget.pipeline.stageId;
        final stageColor = _parseColor(stage.color);
        
        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${stage.name} (${stage.probability}%)'),
              if (stage.isFinal) ...[
                const SizedBox(width: 4),
                Icon(
                  stage.isWon ? Icons.check_circle : Icons.cancel,
                  size: 16,
                  color: stage.isWon ? Colors.green : Colors.red,
                ),
              ],
              if (isCurrent) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_back,
                  size: 14,
                  color: isSelected
                      ? theme.colorScheme.onSecondaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ],
          ),
          selected: isSelected,
          selectedColor: stageColor?.withAlpha(50),
          labelStyle: TextStyle(
            color: isSelected
                ? theme.colorScheme.onSecondaryContainer
                : theme.colorScheme.onSurface,
          ),
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _selectedStageId = stage.id;
                // Pre-populate final premium with potential premium for won stages
                if (stage.isFinal && stage.isWon && _finalPremiumController.text.isEmpty) {
                  _finalPremiumController.text =
                      widget.pipeline.potentialPremium.toStringAsFixed(0);
                }
              });
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildFinalStageFields(ThemeData theme) {
    final stagesAsync = ref.watch(pipelineStagesStreamProvider);

    return stagesAsync.when(
      data: (stages) {
        final selectedStage = stages.where((s) => s.id == _selectedStageId).firstOrNull;
        if (selectedStage == null || !selectedStage.isFinal) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              selectedStage.isWon ? 'Detail Kemenangan' : 'Detail Penolakan',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            if (selectedStage.isWon) ...[
              AppTextField(
                controller: _policyNumberController,
                label: 'Nomor Polis *',
                hint: 'Masukkan nomor polis',
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _finalPremiumController,
                label: 'Premi Final (Rp) *',
                hint: 'Masukkan premi final',
                keyboardType: TextInputType.number,
              ),
            ] else ...[
              AppTextField(
                controller: _declineReasonController,
                label: 'Alasan Penolakan *',
                hint: 'Masukkan alasan penolakan',
                maxLines: 3,
              ),
            ],
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Future<void> _handleSubmit() async {
    if (_selectedStageId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih stage baru'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Don't allow submitting if selecting the same stage
    if (_selectedStageId == widget.pipeline.stageId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih stage yang berbeda'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validate final stage fields (use same provider as UI for consistency)
    final stagesAsync = ref.read(pipelineStagesStreamProvider);
    final stages = stagesAsync.value ?? <PipelineStageDto>[];
    final selectedStage = stages.where((s) => s.id == _selectedStageId).firstOrNull;
    
    if (selectedStage?.isFinal == true) {
      if (selectedStage!.isWon) {
        if (_policyNumberController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nomor polis wajib diisi'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        if (_finalPremiumController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Premi final wajib diisi'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        final parsedPremium = double.tryParse(
          _finalPremiumController.text.replaceAll(',', ''),
        );
        if (parsedPremium == null || parsedPremium <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Masukkan premi final yang valid'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
      if (!selectedStage.isWon && _declineReasonController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alasan penolakan wajib diisi'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(pipelineRepositoryProvider);
      final finalPremium = _finalPremiumController.text.isNotEmpty
          ? double.tryParse(_finalPremiumController.text.replaceAll(',', ''))
          : null;

      final dto = PipelineStageUpdateDto(
        stageId: _selectedStageId!,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        policyNumber: _policyNumberController.text.isEmpty
            ? null
            : _policyNumberController.text,
        declineReason: _declineReasonController.text.isEmpty
            ? null
            : _declineReasonController.text,
        finalPremium: finalPremium,
      );

      final result = await repo.updatePipelineStage(widget.pipeline.id, dto);

      switch (result) {
        case Success():
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Stage berhasil diubah ke ${selectedStage?.name ?? ""}'),
              ),
            );
          }
        case ResultFailure(:final failure):
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
      }
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

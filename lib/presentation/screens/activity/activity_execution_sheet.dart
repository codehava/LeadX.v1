import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/dtos/activity_dtos.dart';
import '../../../data/services/camera_service.dart';
import '../../../domain/entities/activity.dart';
import '../../providers/activity_providers.dart';

/// Bottom sheet for executing a planned activity with GPS validation.
class ActivityExecutionSheet extends ConsumerStatefulWidget {
  final Activity activity;
  final double? targetLat;
  final double? targetLon;
  final VoidCallback? onSuccess;

  const ActivityExecutionSheet({
    super.key,
    required this.activity,
    this.targetLat,
    this.targetLon,
    this.onSuccess,
  });

  /// Show the execution sheet as a modal bottom sheet.
  static Future<bool?> show(
    BuildContext context, {
    required Activity activity,
    double? targetLat,
    double? targetLon,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => ActivityExecutionSheet(
        activity: activity,
        targetLat: targetLat,
        targetLon: targetLon,
      ),
    );
  }

  @override
  ConsumerState<ActivityExecutionSheet> createState() =>
      _ActivityExecutionSheetState();
}

class _ActivityExecutionSheetState
    extends ConsumerState<ActivityExecutionSheet> {
  final _notesController = TextEditingController();
  final _overrideReasonController = TextEditingController();
  bool _showOverrideForm = false;
  final List<CapturedPhoto> _capturedPhotos = [];
  bool _requiresPhoto = false;

  @override
  void initState() {
    super.initState();
    // Auto-validate proximity when sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validateProximity();
      _checkPhotoRequirement();
    });
  }

  void _checkPhotoRequirement() {
    // Check if activity type requires photo
    final activityTypesAsync = ref.read(activityTypesProvider);
    activityTypesAsync.whenData((types) {
      final activityType = types.firstWhere(
        (t) => t.id == widget.activity.activityTypeId,
        orElse: () => types.first,
      );
      if (mounted) {
        setState(() {
          _requiresPhoto = activityType.requirePhoto;
        });
      }
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    _overrideReasonController.dispose();
    super.dispose();
  }

  Future<void> _validateProximity() async {
    if (widget.targetLat == null || widget.targetLon == null) {
      // No target location - skip validation
      return;
    }

    await ref.read(activityExecutionNotifierProvider.notifier).validateProximity(
          targetLat: widget.targetLat!,
          targetLon: widget.targetLon!,
          radiusMeters: 500,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final executionState = ref.watch(activityExecutionNotifierProvider);
    final formState = ref.watch(activityFormNotifierProvider);

    // Listen for successful execution
    ref.listen<ActivityFormState>(activityFormNotifierProvider, (prev, next) {
      if (prev?.savedActivity == null && next.savedActivity != null) {
        Navigator.of(context).pop(true);
        widget.onSuccess?.call();
      }
    });

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Eksekusi Aktivitas',
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Activity info card
                    Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.info.withValues(alpha: 0.2),
                          child: Icon(
                            Icons.event,
                            color: AppColors.info,
                          ),
                        ),
                        title: Text(widget.activity.displayName),
                        subtitle: widget.activity.objectName != null
                            ? Text(widget.activity.objectName!)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // GPS Status
                    _buildGpsStatus(theme, executionState),
                    const SizedBox(height: 16),

                    // Override form (if needed)
                    if (_showOverrideForm) ...[
                      _buildOverrideForm(theme),
                      const SizedBox(height: 16),
                    ],

                    // Notes
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Catatan Eksekusi (Opsional)',
                        hintText: 'Tambahkan catatan...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Photo section
                    _buildPhotoSection(theme),
                    const SizedBox(height: 24),

                    // Execute button
                    _buildExecuteButton(theme, executionState, formState),

                    // Error message
                    if (formState.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          formState.errorMessage!,
                          style: TextStyle(color: theme.colorScheme.error),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGpsStatus(ThemeData theme, ActivityExecutionState state) {
    if (widget.targetLat == null || widget.targetLon == null) {
      // No target location
      return Card(
        color: AppColors.info.withValues(alpha: 0.1),
        child: const ListTile(
          leading: Icon(Icons.info, color: AppColors.info),
          title: Text('Tidak ada lokasi target'),
          subtitle: Text('Aktivitas dapat dieksekusi tanpa validasi GPS'),
        ),
      );
    }

    if (state.isValidating) {
      return Card(
        child: ListTile(
          leading: const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          title: const Text('Memvalidasi lokasi...'),
          subtitle: const Text('Mengecek jarak ke lokasi target'),
        ),
      );
    }

    if (state.hasError) {
      return Card(
        color: AppColors.error.withValues(alpha: 0.1),
        child: ListTile(
          leading: const Icon(Icons.error, color: AppColors.error),
          title: const Text('Gagal mendapatkan lokasi'),
          subtitle: Text(state.errorMessage ?? 'Terjadi kesalahan'),
          trailing: TextButton(
            onPressed: _validateProximity,
            child: const Text('Coba Lagi'),
          ),
        ),
      );
    }

    if (state.isValid) {
      return Card(
        color: AppColors.success.withValues(alpha: 0.1),
        child: ListTile(
          leading: const Icon(Icons.gps_fixed, color: AppColors.success),
          title: const Text('Lokasi Valid'),
          subtitle: Text('${state.distanceMeters.toInt()}m dari target'),
        ),
      );
    }

    // Not within radius
    return Card(
      color: AppColors.warning.withValues(alpha: 0.1),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.gps_off, color: AppColors.warning),
            title: const Text('Lokasi Terlalu Jauh'),
            subtitle: Text(
              'Anda ${state.distanceMeters.toInt()}m dari target (maks 500m)',
            ),
          ),
          if (!_showOverrideForm)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _validateProximity,
                      child: const Text('Cek Ulang'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: () {
                        setState(() {
                          _showOverrideForm = true;
                        });
                      },
                      child: const Text('Override'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOverrideForm(ThemeData theme) {
    return Card(
      color: AppColors.warning.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber, color: AppColors.warning),
                const SizedBox(width: 8),
                Text(
                  'Override Lokasi',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _overrideReasonController,
              decoration: const InputDecoration(
                labelText: 'Alasan Override *',
                hintText: 'Jelaskan mengapa Anda tidak di lokasi...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            Text(
              'Override akan dicatat dalam audit log',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExecuteButton(
    ThemeData theme,
    ActivityExecutionState executionState,
    ActivityFormState formState,
  ) {
    final hasTarget = widget.targetLat != null && widget.targetLon != null;
    final isValidLocation = executionState.isValid || !hasTarget;
    final hasOverride =
        _showOverrideForm && _overrideReasonController.text.isNotEmpty;
    final locationOk = isValidLocation || hasOverride;
    final photoOk = !_requiresPhoto || _capturedPhotos.isNotEmpty;
    final canExecute = locationOk && photoOk;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_requiresPhoto && _capturedPhotos.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '⚠️ Foto wajib diambil untuk eksekusi aktivitas ini',
              style: TextStyle(
                color: theme.colorScheme.error,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        FilledButton.icon(
          onPressed: canExecute && !formState.isLoading ? _executeActivity : null,
          icon: formState.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check_circle),
          label: Text(formState.isLoading ? 'Memproses...' : 'Eksekusi Aktivitas'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Foto Bukti',
              style: theme.textTheme.titleSmall,
            ),
            if (_requiresPhoto)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Wajib',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Photo preview grid
        if (_capturedPhotos.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _capturedPhotos.length,
              itemBuilder: (context, index) {
                final photo = _capturedPhotos[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: kIsWeb && photo.bytes != null
                            ? Image.memory(
                                photo.bytes!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                            : kIsWeb
                                ? Container(
                                    width: 100,
                                    height: 100,
                                    color: theme.colorScheme.surfaceContainerHighest,
                                    child: const Icon(Icons.photo, size: 40),
                                  )
                                : Image.file(
                                    File(photo.localPath),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _capturedPhotos.removeAt(index);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

        const SizedBox(height: 8),

        // Photo capture buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: kIsWeb ? null : _capturePhoto,
                icon: const Icon(Icons.camera_alt, size: 18),
                label: const Text('Kamera'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickFromGallery, // Works on web too
                icon: const Icon(Icons.photo_library, size: 18),
                label: const Text('Galeri'),
              ),
            ),
          ],
        ),
        
        if (kIsWeb)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Kamera tidak tersedia di web, gunakan galeri untuk upload foto',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Future<void> _capturePhoto() async {
    final cameraService = ref.read(cameraServiceProvider);
    final photo = await cameraService.capturePhoto();
    if (photo != null && mounted) {
      setState(() {
        _capturedPhotos.add(photo);
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final cameraService = ref.read(cameraServiceProvider);
    final photo = await cameraService.pickFromGallery();
    if (photo != null && mounted) {
      setState(() {
        _capturedPhotos.add(photo);
      });
    }
  }

  Future<void> _executeActivity() async {
    final state = ref.read(activityExecutionNotifierProvider);

    final dto = ActivityExecutionDto(
      latitude: state.position?.latitude,
      longitude: state.position?.longitude,
      locationAccuracy: state.position?.accuracy,
      distanceFromTarget: state.distanceMeters,
      isLocationOverride: _showOverrideForm,
      overrideReason:
          _showOverrideForm ? _overrideReasonController.text : null,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    // Execute the activity first
    await ref
        .read(activityFormNotifierProvider.notifier)
        .executeActivity(widget.activity.id, dto);
    
    // Save captured photos if any
    if (_capturedPhotos.isNotEmpty) {
      // Use addPhotosWithBytes which handles both web (bytes) and mobile (paths)
      await ref
          .read(activityFormNotifierProvider.notifier)
          .addPhotosWithBytes(
            widget.activity.id,
            _capturedPhotos,
            latitude: state.position?.latitude,
            longitude: state.position?.longitude,
          );
    }
  }
}


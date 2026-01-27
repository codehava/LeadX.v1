import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/dtos/activity_dtos.dart';
import '../../../data/services/camera_service.dart';
import '../../../domain/entities/activity.dart';
import '../../providers/activity_providers.dart';
import '../../providers/broker_providers.dart';
import '../../providers/customer_providers.dart';
import '../../providers/master_data_providers.dart';
import '../../widgets/common/searchable_dropdown.dart';

/// Bottom sheet for logging an immediate (instant) activity.
class ImmediateActivitySheet extends ConsumerStatefulWidget {
  final String objectType;
  final String objectId;
  final String? objectName;
  final VoidCallback? onSuccess;

  const ImmediateActivitySheet({
    super.key,
    required this.objectType,
    required this.objectId,
    this.objectName,
    this.onSuccess,
  });

  /// Show the immediate activity sheet as a modal bottom sheet.
  static Future<Activity?> show(
    BuildContext context, {
    required String objectType,
    required String objectId,
    String? objectName,
  }) {
    return showModalBottomSheet<Activity>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => ImmediateActivitySheet(
        objectType: objectType,
        objectId: objectId,
        objectName: objectName,
      ),
    );
  }

  @override
  ConsumerState<ImmediateActivitySheet> createState() =>
      _ImmediateActivitySheetState();
}

class _ImmediateActivitySheetState
    extends ConsumerState<ImmediateActivitySheet> {
  String? _selectedActivityTypeId;
  String? _selectedKeyPersonId;
  final _summaryController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isCapturingGps = false;
  final List<CapturedPhoto> _capturedPhotos = [];
  bool _requiresPhoto = false;

  @override
  void initState() {
    super.initState();
    // Auto-capture GPS when sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _captureGps();
    });
  }

  @override
  void dispose() {
    _summaryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _captureGps() async {
    setState(() {
      _isCapturingGps = true;
    });

    final gpsService = ref.read(gpsServiceProvider);
    final position = await gpsService.getCurrentPosition();

    if (mounted) {
      setState(() {
        _isCapturingGps = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activityTypesAsync = ref.watch(activityTypesStreamProvider);
    final formState = ref.watch(activityFormNotifierProvider);
    final executionState = ref.watch(activityExecutionNotifierProvider);

    // Listen for successful creation
    ref.listen<ActivityFormState>(activityFormNotifierProvider, (prev, next) {
      if (prev?.savedActivity == null && next.savedActivity != null) {
        Navigator.of(context).pop(next.savedActivity);
        widget.onSuccess?.call();
      }
    });

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
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
                        'Log Aktivitas Sekarang',
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
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
                    // Object info
                    if (widget.objectName != null)
                      Card(
                        child: ListTile(
                          leading: Icon(
                            _getObjectTypeIcon(widget.objectType),
                            color: theme.colorScheme.primary,
                          ),
                          title: Text(widget.objectName!),
                          subtitle: Text(_getObjectTypeLabel(widget.objectType)),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Key Person selection (if available)
                    _buildKeyPersonField(theme),

                    // Activity Type Selection
                    Text(
                      'Tipe Aktivitas *',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    activityTypesAsync.when(
                      data: (types) {
                        if (types.isEmpty) {
                          return const Text('Belum ada tipe aktivitas');
                        }
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: types.map((type) {
                            final isSelected =
                                _selectedActivityTypeId == type.id;
                            return ChoiceChip(
                              label: Text(type.name),
                              selected: isSelected,
                              onSelected: (selected) {
                                final newTypeId = selected ? type.id : null;
                                setState(() {
                                  _selectedActivityTypeId = newTypeId;
                                });
                                // Check photo requirement after state update
                                _checkPhotoForType(newTypeId);
                              },
                            );
                          }).toList(),
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('Error: $e'),
                    ),
                    const SizedBox(height: 16),

                    // GPS Status
                    _buildGpsStatus(theme),
                    const SizedBox(height: 16),

                    // Summary & Notes
                    TextFormField(
                      controller: _summaryController,
                      decoration: const InputDecoration(
                        labelText: 'Ringkasan (Opsional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Catatan (Opsional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Photo section
                    _buildPhotoSection(theme),
                    const SizedBox(height: 24),

                    // Submit button
                    FilledButton.icon(
                      onPressed: _selectedActivityTypeId != null &&
                              !formState.isLoading
                          ? _submitActivity
                          : null,
                      icon: formState.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.flash_on),
                      label: Text(
                          formState.isLoading ? 'Menyimpan...' : 'Catat Sekarang'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),

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

  Widget _buildGpsStatus(ThemeData theme) {
    if (_isCapturingGps) {
      return Card(
        child: const ListTile(
          leading: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          title: Text('Menangkap lokasi...'),
        ),
      );
    }

    final gpsService = ref.read(gpsServiceProvider);
    return FutureBuilder(
      future: gpsService.getCurrentPosition(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            child: const ListTile(
              leading: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              title: Text('Mendapatkan lokasi...'),
            ),
          );
        }

        if (snapshot.data != null) {
          return Card(
            color: AppColors.success.withValues(alpha: 0.1),
            child: ListTile(
              leading: const Icon(Icons.gps_fixed, color: AppColors.success),
              title: const Text('Lokasi Tersimpan'),
              subtitle: Text(
                'Akurasi: ${snapshot.data!.accuracy.toInt()}m',
              ),
            ),
          );
        }

        return Card(
          color: AppColors.warning.withValues(alpha: 0.1),
          child: const ListTile(
            leading: Icon(Icons.gps_off, color: AppColors.warning),
            title: Text('Lokasi tidak tersedia'),
            subtitle: Text('Aktivitas akan dicatat tanpa GPS'),
          ),
        );
      },
    );
  }

  Future<void> _submitActivity() async {
    final gpsService = ref.read(gpsServiceProvider);
    final position = await gpsService.getCurrentPosition();

    final dto = ImmediateActivityDto(
      objectType: widget.objectType,
      activityTypeId: _selectedActivityTypeId!,
      customerId: widget.objectType == 'CUSTOMER' ? widget.objectId : null,
      hvcId: widget.objectType == 'HVC' ? widget.objectId : null,
      brokerId: widget.objectType == 'BROKER' ? widget.objectId : null,
      keyPersonId: _selectedKeyPersonId,
      summary: _summaryController.text.isNotEmpty
          ? _summaryController.text
          : null,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      latitude: position?.latitude,
      longitude: position?.longitude,
      locationAccuracy: position?.accuracy,
    );

    await ref
        .read(activityFormNotifierProvider.notifier)
        .createImmediateActivity(dto);
    
    // Save captured photos if any
    // Get the created activity ID from form state
    final formState = ref.read(activityFormNotifierProvider);
    if (_capturedPhotos.isNotEmpty && formState.savedActivity != null) {
      // Use addPhotosWithBytes which handles both web (bytes) and mobile (paths)
      await ref
          .read(activityFormNotifierProvider.notifier)
          .addPhotosWithBytes(
            formState.savedActivity!.id,
            _capturedPhotos,
            latitude: position?.latitude,
            longitude: position?.longitude,
          );
    }
  }

  IconData _getObjectTypeIcon(String type) {
    switch (type) {
      case 'CUSTOMER':
        return Icons.business;
      case 'HVC':
        return Icons.star;
      case 'BROKER':
        return Icons.handshake;
      default:
        return Icons.person;
    }
  }

  String _getObjectTypeLabel(String type) {
    switch (type) {
      case 'CUSTOMER':
        return 'Customer';
      case 'HVC':
        return 'High Value Customer';
      case 'BROKER':
        return 'Broker';
      default:
        return type;
    }
  }

  Widget _buildKeyPersonField(ThemeData theme) {
    switch (widget.objectType) {
      case 'CUSTOMER':
        return _buildCustomerKeyPersonField(theme);
      case 'BROKER':
        return _buildBrokerKeyPersonField(theme);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCustomerKeyPersonField(ThemeData theme) {
    final keyPersonsAsync = ref.watch(customerKeyPersonsProvider(widget.objectId));

    return keyPersonsAsync.when(
      data: (keyPersons) {
        if (keyPersons.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Key Person (Opsional)',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SearchableDropdown<String>(
              label: 'Key Person',
              hint: 'Pilih key person customer...',
              modalTitle: 'Pilih Key Person',
              searchHint: 'Cari key person...',
              prefixIcon: Icons.person,
              value: _selectedKeyPersonId,
              items: keyPersons.map((kp) {
                return DropdownItem(
                  value: kp.id,
                  label: kp.displayNameWithPosition,
                  subtitle: kp.position,
                  icon: Icons.person,
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedKeyPersonId = value;
                });
              },
            ),
            const SizedBox(height: 16),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildBrokerKeyPersonField(ThemeData theme) {
    final keyPersonsAsync = ref.watch(brokerKeyPersonsProvider(widget.objectId));

    return keyPersonsAsync.when(
      data: (keyPersons) {
        if (keyPersons.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Key Person (Opsional)',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SearchableDropdown<String>(
              label: 'Key Person',
              hint: 'Pilih key person broker...',
              modalTitle: 'Pilih Key Person',
              searchHint: 'Cari key person...',
              prefixIcon: Icons.person,
              value: _selectedKeyPersonId,
              items: keyPersons.map((kp) {
                return DropdownItem(
                  value: kp.id,
                  label: kp.displayNameWithPosition,
                  subtitle: kp.position,
                  icon: Icons.person,
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedKeyPersonId = value;
                });
              },
            ),
            const SizedBox(height: 16),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
    );
  }

  void _checkPhotoForType(String? activityTypeId) {
    if (activityTypeId == null) {
      setState(() => _requiresPhoto = false);
      return;
    }
    
    final activityTypesAsync = ref.read(activityTypesProvider);
    activityTypesAsync.whenData((types) {
      final activityType = types.firstWhere(
        (t) => t.id == activityTypeId,
        orElse: () => types.first,
      );
      if (mounted) {
        setState(() {
          _requiresPhoto = activityType.requirePhoto;
        });
      }
    });
  }

  Widget _buildPhotoSection(ThemeData theme) {
    // Note: Photo requirement is checked in activity type onSelected callback
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
}

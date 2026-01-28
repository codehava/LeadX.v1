import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/dtos/activity_dtos.dart';
import '../../../data/services/camera_service.dart';
import '../../../domain/entities/activity.dart';
import '../../providers/activity_providers.dart';
import '../../providers/broker_providers.dart';
import '../../providers/customer_providers.dart';
import '../../providers/hvc_providers.dart';
import '../../providers/master_data_providers.dart';
import '../../widgets/common/searchable_dropdown.dart';

/// Screen for creating/scheduling activities.
class ActivityFormScreen extends ConsumerStatefulWidget {
  final String? objectType;
  final String? objectId;
  final String? objectName;
  final bool isImmediate;

  const ActivityFormScreen({
    super.key,
    this.objectType,
    this.objectId,
    this.objectName,
    this.isImmediate = false,
  });

  @override
  ConsumerState<ActivityFormScreen> createState() => _ActivityFormScreenState();
}

class _ActivityFormScreenState extends ConsumerState<ActivityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedObjectType;
  String? _selectedObjectId;
  String? _selectedKeyPersonId;
  String? _selectedActivityTypeId;
  DateTime _scheduledDate = DateTime.now();
  TimeOfDay _scheduledTime = TimeOfDay.now();

  final _summaryController = TextEditingController();
  final _notesController = TextEditingController();
  
  // GPS and Photo state (for immediate activities)
  bool _isCapturingGps = false;
  final List<CapturedPhoto> _capturedPhotos = [];
  bool _requiresPhoto = false;

  @override
  void initState() {
    super.initState();
    _selectedObjectType = widget.objectType;
    _selectedObjectId = widget.objectId;
    
    if (widget.isImmediate) {
      // For immediate activities, set time to now
      _scheduledDate = DateTime.now();
      _scheduledTime = TimeOfDay.now();
      // Auto-capture GPS
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _captureGps();
      });
    }
  }
  
  Future<void> _captureGps() async {
    if (!widget.isImmediate) return;
    setState(() => _isCapturingGps = true);
    
    final gpsService = ref.read(gpsServiceProvider);
    await gpsService.getCurrentPosition();
    
    if (mounted) {
      setState(() => _isCapturingGps = false);
    }
  }

  @override
  void dispose() {
    _summaryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formState = ref.watch(activityFormNotifierProvider);
    final activityTypesAsync = ref.watch(activityTypesStreamProvider);

    // Listen for successful save
    ref.listen<ActivityFormState>(activityFormNotifierProvider, (prev, next) {
      if (prev?.savedActivity == null && next.savedActivity != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isImmediate
                ? 'Aktivitas berhasil dicatat'
                : 'Aktivitas berhasil dijadwalkan'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
      if (next.errorMessage != null && prev?.errorMessage != next.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isImmediate ? 'Log Aktivitas' : 'Jadwalkan Aktivitas'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
            // Object Type Selection (if not pre-selected)
            if (widget.objectType == null) ...[
              Text(
                'Untuk',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'CUSTOMER',
                    label: Text('Customer'),
                    icon: Icon(Icons.business),
                  ),
                  ButtonSegment(
                    value: 'HVC',
                    label: Text('HVC'),
                    icon: Icon(Icons.star),
                  ),
                  ButtonSegment(
                    value: 'BROKER',
                    label: Text('Broker'),
                    icon: Icon(Icons.handshake),
                  ),
                ],
                selected: _selectedObjectType != null
                    ? {_selectedObjectType!}
                    : const {},
                emptySelectionAllowed: true,
                onSelectionChanged: (selected) {
                  setState(() {
                    _selectedObjectType = selected.first;
                    _selectedObjectId = null;
                    _selectedKeyPersonId = null; // Reset key person when object type changes
                  });
                },
              ),
              const SizedBox(height: 16),
              // Entity picker based on selected type
              if (_selectedObjectType != null)
                _buildEntityPicker(theme),
            ],

            // Object name display (if pre-selected)
            if (widget.objectName != null) ...[
              Card(
                child: ListTile(
                  leading: Icon(
                    _getObjectTypeIcon(widget.objectType ?? ''),
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(widget.objectName!),
                  subtitle: Text(_getObjectTypeLabel(widget.objectType ?? '')),
                ),
              ),
              const SizedBox(height: 16),
              // Key Person selection (if object is selected)
              if (widget.objectType != null)
                _buildKeyPersonField(theme),
              const SizedBox(height: 16),
            ],

            // Key Person selection for dynamically selected objects
            if (widget.objectType == null && _selectedObjectId != null)
              _buildKeyPersonField(theme),
            if (widget.objectType == null && _selectedObjectId != null)
              const SizedBox(height: 16),

            // Activity Type Selection
            Text(
              'Tipe Aktivitas',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            activityTypesAsync.when(
              data: (types) {
                if (types.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Belum ada tipe aktivitas',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ),
                  );
                }

                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: types.map((type) {
                    final isSelected = _selectedActivityTypeId == type.id;
                    return ChoiceChip(
                      label: Text(type.name),
                      selected: isSelected,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? theme.colorScheme.onSecondaryContainer
                            : theme.colorScheme.onSurface,
                      ),
                      onSelected: (selected) {
                        final newTypeId = selected ? type.id : null;
                        setState(() {
                          _selectedActivityTypeId = newTypeId;
                        });
                        // Check photo requirement for immediate activities
                        if (widget.isImmediate) {
                          _checkPhotoForType(newTypeId);
                        }
                      },
                      avatar: Icon(
                        _getActivityTypeIcon(type.icon),
                        size: 18,
                        color: isSelected
                            ? theme.colorScheme.onSecondaryContainer
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (e, _) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error loading types: $e'),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Date & Time (for scheduled activities)
            if (!widget.isImmediate) ...[
              Text(
                'Tanggal & Waktu',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text(_formatDate(_scheduledDate)),
                        onTap: () => _selectDate(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      child: ListTile(
                        leading: const Icon(Icons.access_time),
                        title: Text(_formatTime(_scheduledTime)),
                        onTap: () => _selectTime(context),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // Summary
            TextFormField(
              controller: _summaryController,
              decoration: const InputDecoration(
                labelText: 'Ringkasan (Opsional)',
                hintText: 'Deskripsi singkat aktivitas',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Catatan (Opsional)',
                hintText: 'Catatan tambahan',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // GPS Status (for immediate activities)
            if (widget.isImmediate) ...[
              _buildGpsStatus(theme),
              const SizedBox(height: 16),
              _buildPhotoSection(theme),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 16),

            // Submit Button
            FilledButton(
              onPressed: formState.isLoading ? null : _submitForm,
              child: formState.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.isImmediate
                      ? 'Catat Aktivitas'
                      : 'Jadwalkan Aktivitas'),
            ),
            // Safe area bottom padding
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _scheduledDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _scheduledTime,
    );
    if (picked != null) {
      setState(() {
        _scheduledTime = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_selectedActivityTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tipe aktivitas'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final objectType = _selectedObjectType ?? widget.objectType;
    final objectId = _selectedObjectId ?? widget.objectId;

    if (objectType == null || objectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih untuk siapa aktivitas ini'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final scheduledDatetime = DateTime(
      _scheduledDate.year,
      _scheduledDate.month,
      _scheduledDate.day,
      _scheduledTime.hour,
      _scheduledTime.minute,
    );

    if (widget.isImmediate) {
      // Get GPS position for immediate activity
      final gpsService = ref.read(gpsServiceProvider);
      final position = await gpsService.getCurrentPosition();
      
      // Create immediate activity
      final dto = ImmediateActivityDto(
        objectType: objectType,
        activityTypeId: _selectedActivityTypeId!,
        customerId: objectType == 'CUSTOMER' ? objectId : null,
        hvcId: objectType == 'HVC' ? objectId : null,
        brokerId: objectType == 'BROKER' ? objectId : null,
        keyPersonId: _selectedKeyPersonId,
        summary: _summaryController.text.isNotEmpty
            ? _summaryController.text
            : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        latitude: position?.latitude,
        longitude: position?.longitude,
        locationAccuracy: position?.accuracy,
      );
      await ref.read(activityFormNotifierProvider.notifier).createImmediateActivity(dto);
      
      // Save captured photos if any
      final formState = ref.read(activityFormNotifierProvider);
      if (_capturedPhotos.isNotEmpty && formState.savedActivity != null) {
        await ref
            .read(activityFormNotifierProvider.notifier)
            .addPhotosWithBytes(
              formState.savedActivity!.id,
              _capturedPhotos,
              latitude: position?.latitude,
              longitude: position?.longitude,
            );
      }
    } else {
      // Create scheduled activity
      final dto = ActivityCreateDto(
        objectType: objectType,
        activityTypeId: _selectedActivityTypeId!,
        scheduledDatetime: scheduledDatetime,
        customerId: objectType == 'CUSTOMER' ? objectId : null,
        hvcId: objectType == 'HVC' ? objectId : null,
        brokerId: objectType == 'BROKER' ? objectId : null,
        keyPersonId: _selectedKeyPersonId,
        summary: _summaryController.text.isNotEmpty
            ? _summaryController.text
            : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );
      ref.read(activityFormNotifierProvider.notifier).createActivity(dto);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
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

  IconData _getActivityTypeIcon(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'visit':
      case 'place':
      case 'location':
        return Icons.place;
      case 'call':
      case 'phone':
        return Icons.phone;
      case 'meeting':
      case 'people':
        return Icons.people;
      case 'email':
      case 'mail':
        return Icons.email;
      case 'presentation':
      case 'slideshow':
        return Icons.slideshow;
      case 'quotation':
      case 'request_quote':
        return Icons.request_quote;
      case 'contract':
      case 'description':
        return Icons.description;
      default:
        return Icons.event;
    }
  }

  /// Build key person field based on selected object type.
  Widget _buildKeyPersonField(ThemeData theme) {
    final objectType = _selectedObjectType ?? widget.objectType;
    final objectId = _selectedObjectId ?? widget.objectId;

    if (objectType == null || objectId == null) {
      return const SizedBox.shrink();
    }

    switch (objectType) {
      case 'CUSTOMER':
        return _buildCustomerKeyPersonField(theme);
      case 'HVC':
        return _buildHvcKeyPersonField(theme);
      case 'BROKER':
        return _buildBrokerKeyPersonField(theme);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCustomerKeyPersonField(ThemeData theme) {
    final keyPersonsAsync = ref.watch(customerKeyPersonsProvider(_selectedObjectId!));

    return keyPersonsAsync.when(
      data: (keyPersons) {
        if (keyPersons.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Belum ada key person untuk customer ini',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
          );
        }
        return SearchableDropdown<String>(
          label: 'Key Person (Opsional)',
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
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildBrokerKeyPersonField(ThemeData theme) {
    final keyPersonsAsync = ref.watch(brokerKeyPersonsProvider(_selectedObjectId!));

    return keyPersonsAsync.when(
      data: (keyPersons) {
        if (keyPersons.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Belum ada key person untuk broker ini',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
          );
        }
        return SearchableDropdown<String>(
          label: 'Key Person (Opsional)',
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
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildHvcKeyPersonField(ThemeData theme) {
    final objectId = _selectedObjectId ?? widget.objectId;
    if (objectId == null) return const SizedBox.shrink();

    final keyPersonsAsync = ref.watch(hvcKeyPersonsProvider(objectId));

    return keyPersonsAsync.when(
      data: (keyPersons) {
        if (keyPersons.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Belum ada key person untuk HVC ini',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
          );
        }
        return SearchableDropdown<String>(
          label: 'Key Person (Opsional)',
          hint: 'Pilih key person HVC...',
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
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => const SizedBox.shrink(),
    );
  }

  /// Build entity picker based on selected object type.
  Widget _buildEntityPicker(ThemeData theme) {
    switch (_selectedObjectType) {
      case 'CUSTOMER':
        return _buildCustomerPicker(theme);
      case 'HVC':
        return _buildHvcPicker(theme);
      case 'BROKER':
        return _buildBrokerPicker(theme);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCustomerPicker(ThemeData theme) {
    final customersAsync = ref.watch(customerListStreamProvider);
    
    return customersAsync.when(
      data: (customers) {
        if (customers.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Belum ada customer',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
          );
        }

        return SearchableDropdown<String>(
          label: 'Pilih Customer',
          hint: 'Ketuk untuk memilih customer...',
          modalTitle: 'Pilih Customer',
          searchHint: 'Cari customer...',
          prefixIcon: Icons.business,
          value: _selectedObjectId,
          items: customers.map((customer) {
            return DropdownItem(
              value: customer.id,
              label: customer.name,
              subtitle: customer.address,
              icon: Icons.business,
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedObjectId = value;
              _selectedKeyPersonId = null; // Reset key person when customer changes
            });
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e'),
    );
  }

  Widget _buildHvcPicker(ThemeData theme) {
    final hvcsAsync = ref.watch(hvcListStreamProvider);
    
    return hvcsAsync.when(
      data: (hvcs) {
        if (hvcs.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Belum ada HVC',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
          );
        }

        return SearchableDropdown<String>(
          label: 'Pilih HVC',
          hint: 'Ketuk untuk memilih HVC...',
          modalTitle: 'Pilih HVC',
          searchHint: 'Cari HVC...',
          prefixIcon: Icons.star,
          value: _selectedObjectId,
          items: hvcs.map((hvc) {
            return DropdownItem(
              value: hvc.id,
              label: hvc.name,
              icon: Icons.star,
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedObjectId = value;
            });
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e'),
    );
  }

  Widget _buildBrokerPicker(ThemeData theme) {
    final brokersAsync = ref.watch(brokerListStreamProvider);
    
    return brokersAsync.when(
      data: (brokers) {
        if (brokers.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Belum ada broker',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
          );
        }

        return SearchableDropdown<String>(
          label: 'Pilih Broker',
          hint: 'Ketuk untuk memilih broker...',
          modalTitle: 'Pilih Broker',
          searchHint: 'Cari broker...',
          prefixIcon: Icons.handshake,
          value: _selectedObjectId,
          items: brokers.map((broker) {
            return DropdownItem(
              value: broker.id,
              label: broker.name,
              icon: Icons.handshake,
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedObjectId = value;
              _selectedKeyPersonId = null; // Reset key person when broker changes
            });
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e'),
    );
  }

  // ==========================================
  // GPS and Photo Methods (for immediate activities)
  // ==========================================

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
                        child: _buildPhotoImage(photo, theme),
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
                onPressed: _pickFromGallery,
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

  /// Build photo image widget that handles web and mobile platforms.
  Widget _buildPhotoImage(CapturedPhoto photo, ThemeData theme) {
    // On web, use bytes if available
    if (kIsWeb) {
      if (photo.bytes != null) {
        return Image.memory(
          photo.bytes!,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        );
      }
      // Fallback placeholder for web without bytes
      return Container(
        width: 100,
        height: 100,
        color: theme.colorScheme.surfaceContainerHighest,
        child: const Icon(Icons.photo, size: 40),
      );
    }
    
    // On mobile, use File
    try {
      return Image.file(
        File(photo.localPath),
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 100,
            height: 100,
            color: theme.colorScheme.surfaceContainerHighest,
            child: const Icon(Icons.broken_image, size: 40),
          );
        },
      );
    } catch (e) {
      return Container(
        width: 100,
        height: 100,
        color: theme.colorScheme.surfaceContainerHighest,
        child: const Icon(Icons.broken_image, size: 40),
      );
    }
  }
}

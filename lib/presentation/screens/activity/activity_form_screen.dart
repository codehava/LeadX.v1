import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/dtos/activity_dtos.dart';
import '../../../domain/entities/activity.dart';
import '../../providers/activity_providers.dart';

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
  String? _selectedActivityTypeId;
  DateTime _scheduledDate = DateTime.now();
  TimeOfDay _scheduledTime = TimeOfDay.now();
  
  final _summaryController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedObjectType = widget.objectType;
    _selectedObjectId = widget.objectId;
    
    if (widget.isImmediate) {
      // For immediate activities, set time to now
      _scheduledDate = DateTime.now();
      _scheduledTime = TimeOfDay.now();
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
    final activityTypesAsync = ref.watch(activityTypesProvider);

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
      body: Form(
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
                onSelectionChanged: (selected) {
                  setState(() {
                    _selectedObjectType = selected.first;
                    _selectedObjectId = null;
                  });
                },
              ),
              const SizedBox(height: 16),
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
            ],

            // Activity Type Selection
            Text(
              'Tipe Aktivitas',
              style: theme.textTheme.titleSmall,
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
                      onSelected: (selected) {
                        setState(() {
                          _selectedActivityTypeId = selected ? type.id : null;
                        });
                      },
                      avatar: Icon(
                        _getActivityTypeIcon(type.icon),
                        size: 18,
                        color: isSelected
                            ? theme.colorScheme.onPrimaryContainer
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
            const SizedBox(height: 32),

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
          ],
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

  void _submitForm() {
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
      // Create immediate activity
      final dto = ImmediateActivityDto(
        objectType: objectType,
        activityTypeId: _selectedActivityTypeId!,
        customerId: objectType == 'CUSTOMER' ? objectId : null,
        hvcId: objectType == 'HVC' ? objectId : null,
        brokerId: objectType == 'BROKER' ? objectId : null,
        summary: _summaryController.text.isNotEmpty
            ? _summaryController.text
            : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        // GPS will be captured separately
      );
      ref.read(activityFormNotifierProvider.notifier).createImmediateActivity(dto);
    } else {
      // Create scheduled activity
      final dto = ActivityCreateDto(
        objectType: objectType,
        activityTypeId: _selectedActivityTypeId!,
        scheduledDatetime: scheduledDatetime,
        customerId: objectType == 'CUSTOMER' ? objectId : null,
        hvcId: objectType == 'HVC' ? objectId : null,
        brokerId: objectType == 'BROKER' ? objectId : null,
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
}

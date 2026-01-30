import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/entities/cadence.dart';
import '../../../providers/cadence_providers.dart';

/// Form screen for creating/editing cadence schedule configurations.
class CadenceConfigFormScreen extends ConsumerStatefulWidget {
  const CadenceConfigFormScreen({
    this.configId,
    super.key,
  });

  final String? configId;

  @override
  ConsumerState<CadenceConfigFormScreen> createState() =>
      _CadenceConfigFormScreenState();
}

class _CadenceConfigFormScreenState
    extends ConsumerState<CadenceConfigFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _defaultTimeController;
  late TextEditingController _durationController;
  late TextEditingController _preMeetingHoursController;

  String _targetRole = 'RM';
  String _facilitatorRole = 'BH';
  MeetingFrequency _frequency = MeetingFrequency.weekly;
  int? _dayOfWeek = 1; // Monday
  int? _dayOfMonth = 1;
  bool _isActive = true;
  bool _isLoading = false;
  bool _isInitialized = false;

  bool get _isEditMode => widget.configId != null;

  static const _roles = ['RM', 'BH', 'BM', 'ROH', 'DIRECTOR', 'ADMIN'];
  static const _daysOfWeek = [
    (0, 'Minggu'),
    (1, 'Senin'),
    (2, 'Selasa'),
    (3, 'Rabu'),
    (4, 'Kamis'),
    (5, 'Jumat'),
    (6, 'Sabtu'),
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _defaultTimeController = TextEditingController(text: '09:00');
    _durationController = TextEditingController(text: '60');
    _preMeetingHoursController = TextEditingController(text: '24');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _defaultTimeController.dispose();
    _durationController.dispose();
    _preMeetingHoursController.dispose();
    super.dispose();
  }

  void _populateForm(CadenceScheduleConfig config) {
    _nameController.text = config.name;
    _descriptionController.text = config.description ?? '';
    _targetRole = config.targetRole;
    _facilitatorRole = config.facilitatorRole;
    _frequency = config.frequency;
    _dayOfWeek = config.dayOfWeek;
    _dayOfMonth = config.dayOfMonth;
    _defaultTimeController.text = config.defaultTime ?? '09:00';
    _durationController.text = config.durationMinutes.toString();
    _preMeetingHoursController.text = config.preMeetingHours.toString();
    _isActive = config.isActive;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actionState = ref.watch(adminCadenceConfigNotifierProvider);

    // Load existing config if in edit mode
    if (_isEditMode && !_isInitialized) {
      final configAsync = ref.watch(cadenceConfigByIdProvider(widget.configId!));
      configAsync.whenData((config) {
        if (config != null && !_isInitialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _populateForm(config);
                _isInitialized = true;
              });
            }
          });
        }
      });
    }

    // Listen for success/error
    ref.listen(adminCadenceConfigNotifierProvider, (previous, next) {
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(adminCadenceConfigNotifierProvider.notifier).clearMessages();
        context.pop();
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(adminCadenceConfigNotifierProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Konfigurasi' : 'Tambah Konfigurasi'),
        actions: [
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _isLoading || actionState.isLoading
                  ? null
                  : () => _confirmDelete(),
              tooltip: 'Hapus',
            ),
        ],
      ),
      body: _isEditMode && !_isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Konfigurasi *',
                      hintText: 'Contoh: Team Cadence',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi',
                      hintText: 'Deskripsi singkat tentang konfigurasi ini',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),

                  // Role Section
                  Text(
                    'Pengaturan Level',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tentukan role peserta dan fasilitator untuk cadence ini',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _targetRole,
                          decoration: const InputDecoration(
                            labelText: 'Role Peserta *',
                            border: OutlineInputBorder(),
                          ),
                          items: _roles.map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(role),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _targetRole = value);
                            }
                          },
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(Icons.arrow_forward),
                      ),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _facilitatorRole,
                          decoration: const InputDecoration(
                            labelText: 'Role Fasilitator *',
                            border: OutlineInputBorder(),
                          ),
                          items: _roles.map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(role),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _facilitatorRole = value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Frequency Section
                  Text(
                    'Pengaturan Jadwal',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<MeetingFrequency>(
                    value: _frequency,
                    decoration: const InputDecoration(
                      labelText: 'Frekuensi *',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: MeetingFrequency.daily,
                        child: Text('Harian'),
                      ),
                      DropdownMenuItem(
                        value: MeetingFrequency.weekly,
                        child: Text('Mingguan'),
                      ),
                      DropdownMenuItem(
                        value: MeetingFrequency.monthly,
                        child: Text('Bulanan'),
                      ),
                      DropdownMenuItem(
                        value: MeetingFrequency.quarterly,
                        child: Text('Kuartalan'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _frequency = value;
                          // Reset day selections based on frequency
                          if (value == MeetingFrequency.weekly) {
                            _dayOfWeek = 1;
                            _dayOfMonth = null;
                          } else if (value == MeetingFrequency.monthly ||
                              value == MeetingFrequency.quarterly) {
                            _dayOfWeek = null;
                            _dayOfMonth = 1;
                          } else {
                            _dayOfWeek = null;
                            _dayOfMonth = null;
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Day of Week (for weekly)
                  if (_frequency == MeetingFrequency.weekly)
                    DropdownButtonFormField<int>(
                      value: _dayOfWeek ?? 1,
                      decoration: const InputDecoration(
                        labelText: 'Hari *',
                        border: OutlineInputBorder(),
                      ),
                      items: _daysOfWeek.map((day) {
                        return DropdownMenuItem(
                          value: day.$1,
                          child: Text(day.$2),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _dayOfWeek = value);
                      },
                    ),

                  // Day of Month (for monthly/quarterly)
                  if (_frequency == MeetingFrequency.monthly ||
                      _frequency == MeetingFrequency.quarterly)
                    DropdownButtonFormField<int>(
                      value: _dayOfMonth ?? 1,
                      decoration: const InputDecoration(
                        labelText: 'Tanggal *',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(31, (i) => i + 1).map((day) {
                        return DropdownMenuItem(
                          value: day,
                          child: Text('Tanggal $day'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _dayOfMonth = value);
                      },
                    ),
                  const SizedBox(height: 16),

                  // Time and Duration Row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _defaultTimeController,
                          decoration: const InputDecoration(
                            labelText: 'Waktu Default',
                            hintText: 'HH:mm',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.access_time),
                          ),
                          readOnly: true,
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time != null) {
                              _defaultTimeController.text =
                                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _durationController,
                          decoration: const InputDecoration(
                            labelText: 'Durasi (menit) *',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Wajib diisi';
                            }
                            final duration = int.tryParse(value);
                            if (duration == null || duration <= 0) {
                              return 'Tidak valid';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Pre-meeting hours
                  TextFormField(
                    controller: _preMeetingHoursController,
                    decoration: const InputDecoration(
                      labelText: 'Deadline Pre-Meeting (jam) *',
                      helperText:
                          'Berapa jam sebelum meeting form harus disubmit',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Wajib diisi';
                      }
                      final hours = int.tryParse(value);
                      if (hours == null || hours < 0) {
                        return 'Tidak valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Is Active
                  SwitchListTile(
                    title: const Text('Aktif'),
                    subtitle: const Text(
                        'Konfigurasi yang tidak aktif tidak akan generate meeting baru'),
                    value: _isActive,
                    onChanged: (value) {
                      setState(() => _isActive = value);
                    },
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  FilledButton.icon(
                    onPressed: _isLoading || actionState.isLoading
                        ? null
                        : _saveConfig,
                    icon: _isLoading || actionState.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(_isEditMode ? 'Simpan Perubahan' : 'Buat Konfigurasi'),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _saveConfig() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final notifier = ref.read(adminCadenceConfigNotifierProvider.notifier);

    if (_isEditMode) {
      await notifier.updateConfig(
        configId: widget.configId!,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        targetRole: _targetRole,
        facilitatorRole: _facilitatorRole,
        frequency: _frequency.name.toUpperCase(),
        dayOfWeek: _dayOfWeek,
        dayOfMonth: _dayOfMonth,
        defaultTime: _defaultTimeController.text.trim().isEmpty
            ? null
            : _defaultTimeController.text.trim(),
        durationMinutes: int.parse(_durationController.text),
        preMeetingHours: int.parse(_preMeetingHoursController.text),
        isActive: _isActive,
      );
    } else {
      await notifier.createConfig(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        targetRole: _targetRole,
        facilitatorRole: _facilitatorRole,
        frequency: _frequency.name.toUpperCase(),
        dayOfWeek: _dayOfWeek,
        dayOfMonth: _dayOfMonth,
        defaultTime: _defaultTimeController.text.trim().isEmpty
            ? null
            : _defaultTimeController.text.trim(),
        durationMinutes: int.parse(_durationController.text),
        preMeetingHours: int.parse(_preMeetingHoursController.text),
        isActive: _isActive,
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }

    // Navigation is handled in the listener
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Konfigurasi'),
        content: Text(
            'Apakah Anda yakin ingin menghapus "${_nameController.text}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _deleteConfig();
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteConfig() async {
    final success = await ref
        .read(adminCadenceConfigNotifierProvider.notifier)
        .deleteConfig(widget.configId!);
    if (success && mounted) {
      context.pop();
    }
  }
}

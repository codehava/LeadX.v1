import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/dtos/pipeline_dtos.dart';
import '../../providers/broker_providers.dart';
import '../../providers/customer_providers.dart';
import '../../providers/master_data_providers.dart';
import '../../providers/pipeline_providers.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/autocomplete_field.dart';
import '../../widgets/common/discard_confirmation_dialog.dart';
import '../../widgets/common/loading_indicator.dart';

/// Screen for creating or editing a pipeline.
class PipelineFormScreen extends ConsumerStatefulWidget {
  const PipelineFormScreen({
    super.key,
    required this.customerId,
    this.pipelineId,
  });

  final String customerId;
  final String? pipelineId;

  bool get isEditing => pipelineId != null;

  @override
  ConsumerState<PipelineFormScreen> createState() => _PipelineFormScreenState();
}

class _PipelineFormScreenState extends ConsumerState<PipelineFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _potentialPremiumController = TextEditingController();
  final _tsiController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedCobId;
  String? _selectedLobId;
  String? _selectedLeadSourceId;
  String? _selectedBrokerId;
  String? _selectedBrokerPicId;
  String? _selectedCustomerContactId;
  DateTime? _expectedCloseDate;
  bool _isTender = false;

  bool _isLoading = false;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loadPipeline();
    }
  }

  Future<void> _loadPipeline() async {
    if (widget.pipelineId == null) return;

    setState(() => _isLoading = true);

    final pipeline =
        await ref.read(pipelineDetailProvider(widget.pipelineId!).future);

    if (pipeline != null && mounted) {
      // Check if pipeline is closed - prevent editing
      if (pipeline.isClosed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pipeline sudah ditutup dan tidak dapat diedit'),
            backgroundColor: Colors.orange,
          ),
        );
        if (mounted) context.pop();
        return;
      }

      _potentialPremiumController.text = pipeline.potentialPremium.toString();
      _tsiController.text = pipeline.tsi?.toString() ?? '';
      _notesController.text = pipeline.notes ?? '';

      setState(() {
        _selectedCobId = pipeline.cobId;
        _selectedLobId = pipeline.lobId;
        _selectedLeadSourceId = pipeline.leadSourceId;
        _selectedBrokerId = pipeline.brokerId;
        _selectedBrokerPicId = pipeline.brokerPicId;
        _selectedCustomerContactId = pipeline.customerContactId;
        _expectedCloseDate = pipeline.expectedCloseDate;
        _isTender = pipeline.isTender;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _potentialPremiumController.dispose();
    _tsiController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(pipelineFormNotifierProvider);
    final theme = Theme.of(context);

    // Listen for successful save
    ref.listen<PipelineFormState>(pipelineFormNotifierProvider, (prev, next) {
      if (next.savedPipeline != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? 'Pipeline berhasil diupdate'
                  : 'Pipeline berhasil ditambahkan',
            ),
          ),
        );
        context.pop();
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldDiscard = await DiscardConfirmationDialog.show(context);
        if (shouldDiscard && mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isEditing ? 'Edit Pipeline' : 'Pipeline Baru'),
        ),
        body: _isLoading
            ? const Center(child: AppLoadingIndicator())
            : _buildForm(theme),
        bottomNavigationBar: _buildBottomBar(formState, theme),
      ),
    );
  }

  Widget _buildForm(ThemeData theme) {
    final cobsAsync = ref.watch(cobsStreamProvider);
    final lobsAsync = ref.watch(lobsByCobProvider(_selectedCobId));
    final leadSourcesAsync = ref.watch(leadSourcesStreamProvider);
    final brokersAsync = ref.watch(brokersStreamProvider);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Info Section
            _SectionHeader(title: 'Informasi Produk'),
            const SizedBox(height: 16),
            
            // COB and LOB
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: cobsAsync.when(
                    data: (cobs) => AutocompleteField<String>(
                      label: 'COB (Class of Business) *',
                      hint: 'Pilih COB...',
                      value: _selectedCobId,
                      items: cobs
                          .map((c) => AutocompleteItem(value: c.id, label: c.name))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCobId = value;
                          _selectedLobId = null; // Reset LOB when COB changes
                          _hasUnsavedChanges = true;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'COB wajib dipilih' : null,
                    ),
                    loading: () => _buildLoadingDropdown('COB *'),
                    error: (_, __) => _buildErrorDropdown('COB *'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: lobsAsync.when(
                    data: (lobs) => AutocompleteField<String>(
                      label: 'LOB (Line of Business) *',
                      hint: _selectedCobId == null
                          ? 'Pilih COB dulu'
                          : 'Pilih LOB...',
                      value: _selectedLobId,
                      enabled: _selectedCobId != null,
                      items: lobs
                          .map((l) => AutocompleteItem(value: l.id, label: l.name))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedLobId = value;
                          _hasUnsavedChanges = true;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'LOB wajib dipilih' : null,
                    ),
                    loading: () => _buildLoadingDropdown('LOB *'),
                    error: (_, __) => _buildErrorDropdown('LOB *'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Financial Info Section
            _SectionHeader(title: 'Informasi Finansial'),
            const SizedBox(height: 16),
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _potentialPremiumController,
                    label: 'Potensi Premi (Rp) *',
                    hint: 'Masukkan nominal',
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _hasUnsavedChanges = true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Potensi premi wajib diisi';
                      }
                      final parsed = double.tryParse(value.replaceAll(',', ''));
                      if (parsed == null || parsed <= 0) {
                        return 'Masukkan nominal yang valid';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppTextField(
                    controller: _tsiController,
                    label: 'TSI (Rp)',
                    hint: 'Masukkan nominal',
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _hasUnsavedChanges = true,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Source & Details Section
            _SectionHeader(title: 'Sumber & Detail'),
            const SizedBox(height: 16),
            
            leadSourcesAsync.when(
              data: (sources) => AutocompleteField<String>(
                label: 'Sumber Leads *',
                hint: 'Pilih sumber leads...',
                value: _selectedLeadSourceId,
                items: sources
                    .map((s) => AutocompleteItem(value: s.id, label: s.name))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLeadSourceId = value;
                    _hasUnsavedChanges = true;
                  });
                },
                validator: (value) =>
                    value == null ? 'Sumber leads wajib dipilih' : null,
              ),
              loading: () => _buildLoadingDropdown('Sumber Leads *'),
              error: (_, __) => _buildErrorDropdown('Sumber Leads *'),
            ),
            
            const SizedBox(height: 16),
            
            brokersAsync.when(
              data: (brokers) => AutocompleteField<String>(
                label: 'Broker (Opsional)',
                hint: 'Pilih broker...',
                value: _selectedBrokerId,
                items: brokers
                    .map((b) => AutocompleteItem(value: b.id, label: b.name))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBrokerId = value;
                    _selectedBrokerPicId = null; // Reset broker PIC when broker changes
                    _hasUnsavedChanges = true;
                  });
                },
              ),
              loading: () => _buildLoadingDropdown('Broker'),
              error: (_, __) => _buildErrorDropdown('Broker'),
            ),

            const SizedBox(height: 16),

            // Broker PIC (Key Person) - only show if broker is selected
            if (_selectedBrokerId != null) _buildBrokerPicField(),

            const SizedBox(height: 16),

            // Customer Contact (Key Person)
            _buildCustomerContactField(),
            
            const SizedBox(height: 16),
            
            // Expected Close Date
            _DatePickerField(
              label: 'Perkiraan Tanggal Closing',
              value: _expectedCloseDate,
              onChanged: (date) {
                setState(() {
                  _expectedCloseDate = date;
                  _hasUnsavedChanges = true;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Tender Switch
            SwitchListTile(
              title: const Text('Tender'),
              subtitle: const Text('Pipeline ini adalah untuk proses tender'),
              value: _isTender,
              onChanged: (value) {
                setState(() {
                  _isTender = value;
                  _hasUnsavedChanges = true;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            
            const SizedBox(height: 32),
            
            // Notes Section
            _SectionHeader(title: 'Catatan'),
            const SizedBox(height: 16),
            AppTextField(
              controller: _notesController,
              label: 'Catatan',
              hint: 'Tambahkan catatan (opsional)',
              maxLines: 4,
              onChanged: (_) => _hasUnsavedChanges = true,
            ),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingDropdown(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Memuat...'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorDropdown(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 16),
              SizedBox(width: 12),
              Text('Gagal memuat data'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBrokerPicField() {
    final brokerPicsAsync = ref.watch(brokerKeyPersonsProvider(_selectedBrokerId!));

    return brokerPicsAsync.when(
      data: (pics) {
        if (pics.isEmpty) {
          return const SizedBox.shrink();
        }
        return AutocompleteField<String>(
          label: 'Kontak Broker (Opsional)',
          hint: 'Pilih key person broker...',
          value: _selectedBrokerPicId,
          items: pics
              .map((pic) => AutocompleteItem(
                    value: pic.id,
                    label: pic.displayNameWithPosition,
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedBrokerPicId = value;
              _hasUnsavedChanges = true;
            });
          },
        );
      },
      loading: () => _buildLoadingDropdown('Kontak Broker'),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildCustomerContactField() {
    final keyPersonsAsync = ref.watch(customerKeyPersonsProvider(widget.customerId));

    return keyPersonsAsync.when(
      data: (keyPersons) {
        if (keyPersons.isEmpty) {
          return const SizedBox.shrink();
        }
        return AutocompleteField<String>(
          label: 'Kontak Customer (Opsional)',
          hint: 'Pilih key person...',
          value: _selectedCustomerContactId,
          items: keyPersons
              .map((kp) => AutocompleteItem(
                    value: kp.id,
                    label: kp.displayNameWithPosition,
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedCustomerContactId = value;
              _hasUnsavedChanges = true;
            });
          },
        );
      },
      loading: () => _buildLoadingDropdown('Kontak Customer'),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildBottomBar(PipelineFormState formState, ThemeData theme) {
    return SafeArea(
      child: Container(
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
              child: OutlinedButton(
                onPressed: () => context.pop(),
                child: const Text('Batal'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: AppButton(
                label: widget.isEditing ? 'Update' : 'Simpan',
                isLoading: formState.isLoading,
                onPressed: _handleSave,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCobId == null ||
        _selectedLobId == null ||
        _selectedLeadSourceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi semua field yang wajib diisi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final formNotifier = ref.read(pipelineFormNotifierProvider.notifier);
    final potentialPremium = double.parse(
      _potentialPremiumController.text.replaceAll(',', ''),
    );
    final tsi = _tsiController.text.isNotEmpty
        ? double.tryParse(_tsiController.text.replaceAll(',', ''))
        : null;

    if (widget.isEditing) {
      formNotifier.updatePipeline(
        widget.pipelineId!,
        PipelineUpdateDto(
          cobId: _selectedCobId,
          lobId: _selectedLobId,
          leadSourceId: _selectedLeadSourceId,
          brokerId: _selectedBrokerId,
          brokerPicId: _selectedBrokerPicId,
          customerContactId: _selectedCustomerContactId,
          potentialPremium: potentialPremium,
          tsi: tsi,
          expectedCloseDate: _expectedCloseDate,
          isTender: _isTender,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        ),
      );
    } else {
      formNotifier.createPipeline(
        PipelineCreateDto(
          customerId: widget.customerId,
          cobId: _selectedCobId!,
          lobId: _selectedLobId!,
          leadSourceId: _selectedLeadSourceId!,
          potentialPremium: potentialPremium,
          brokerId: _selectedBrokerId,
          brokerPicId: _selectedBrokerPicId,
          customerContactId: _selectedCustomerContactId,
          tsi: tsi,
          expectedCloseDate: _expectedCloseDate,
          isTender: _isTender,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        ),
      );
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayText = value != null
        ? '${value!.day}/${value!.month}/${value!.year}'
        : 'Pilih tanggal';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now().add(const Duration(days: 30)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 730)),
            );
            if (date != null) {
              onChanged(date);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 20, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 12),
                Text(
                  displayText,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: value != null
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (value != null) ...[
                  const Spacer(),
                  GestureDetector(
                    onTap: () => onChanged(null),
                    child: const Icon(Icons.clear, size: 20),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

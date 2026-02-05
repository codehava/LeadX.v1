import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../domain/entities/scoring_entities.dart';
import '../../../../providers/admin/admin_4dx_providers.dart';
import '../../../../providers/master_data_providers.dart';
import '../../../../widgets/admin/multi_select_checkbox_field.dart';

/// Admin Measure Form Screen.
///
/// Multi-step wizard for creating/editing measures:
/// 1. Template Selection (create only)
/// 2. Template Configuration (dynamic based on template)
/// 3. Scoring Configuration (weight, target, period)
/// 4. Preview & Save
class AdminMeasureFormScreen extends ConsumerStatefulWidget {
  final String? measureId; // Null for create, set for edit

  const AdminMeasureFormScreen({
    super.key,
    this.measureId,
  });

  @override
  ConsumerState<AdminMeasureFormScreen> createState() =>
      _AdminMeasureFormScreenState();
}

class _AdminMeasureFormScreenState
    extends ConsumerState<AdminMeasureFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Stepper state
  int _currentStep = 0;

  // Form data
  String? _selectedTemplate;
  final Map<String, dynamic> _templateConfig = {};

  // Basic info
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _measureType = 'LEAD'; // LEAD or LAG
  String _dataType = 'COUNT'; // COUNT, SUM, CALCULATED
  String? _unit;

  // Scoring config
  final _weightController = TextEditingController(text: '1.0');
  final _defaultTargetController = TextEditingController();
  String _periodType = 'WEEKLY'; // WEEKLY, MONTHLY, QUARTERLY

  // Generated from template
  String? _sourceTable;
  String? _sourceCondition;
  String? _calculationFormula;

  // Template-specific state
  // Activity Count
  Set<String> _selectedActivityTypeIds = {};
  bool _includeCompletedOnly = true;

  // Pipeline Count
  Set<String> _selectedStages = {};
  bool _excludeTenders = false;
  bool _excludeBrokerSourced = false;

  // Pipeline Revenue
  String _targetStage = 'ACCEPTED';
  String _revenueField = 'final_premium';
  bool _tendersOnly = false;
  bool _brokerSourcedOnly = false;

  // Stage Milestone
  String _milestoneTargetStage = 'P2';
  bool _fromAnyStage = true;
  String? _fromSpecificStage;

  // Customer Acquisition
  Set<String> _selectedCompanyTypeIds = {};
  Set<String> _selectedIndustryIds = {};

  // Edit mode data
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.measureId != null) {
      _loadExistingMeasure();
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _weightController.dispose();
    _defaultTargetController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingMeasure() async {
    setState(() => _isLoading = true);
    try {
      final measure =
          await ref.read(measureByIdProvider(widget.measureId!).future);
      if (measure != null) {
        setState(() {
          _codeController.text = measure.code;
          _nameController.text = measure.name;
          _descriptionController.text = measure.description ?? '';
          _measureType = measure.measureType;
          _dataType = measure.dataType;
          _unit = measure.unit;
          _weightController.text = measure.weight.toString();
          _defaultTargetController.text = measure.defaultTarget.toString();
          _periodType = measure.periodType ?? 'WEEKLY';
          _sourceTable = measure.sourceTable;
          _sourceCondition = measure.sourceCondition;
          _calculationFormula = measure.calculationFormula;
          _selectedTemplate = measure.templateType;
          if (measure.templateConfig != null) {
            _templateConfig.addAll(measure.templateConfig!);
          }

          // Restore template config selections
          if (measure.templateType != null && measure.templateConfig != null) {
            _restoreTemplateConfig(measure.templateType!, measure.templateConfig!);
          }

          // Skip template selection step if editing
          _currentStep = 1;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat measure: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.measureId != null;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Memuat...'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Measure' : 'Buat Measure Baru'),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: _onStepContinue,
          onStepCancel: _onStepCancel,
          onStepTapped: (step) => setState(() => _currentStep = step),
          controlsBuilder: _buildStepControls,
          steps: [
            // Step 0: Template Selection (create only)
            if (!isEditMode)
              Step(
                title: const Text('Pilih Template'),
                subtitle: const Text('Jenis measure yang akan dibuat'),
                content: _buildTemplateSelectionStep(),
                isActive: _currentStep >= 0,
                state: _currentStep > 0
                    ? StepState.complete
                    : StepState.indexed,
              ),

            // Step 1: Basic Info & Template Config
            Step(
              title: const Text('Konfigurasi'),
              subtitle: Text(
                _selectedTemplate != null
                    ? _formatTemplateName(_selectedTemplate!)
                    : 'Informasi dasar',
              ),
              content: _buildConfigurationStep(),
              isActive: _currentStep >= (isEditMode ? 1 : 1),
              state: _currentStep > (isEditMode ? 1 : 1)
                  ? StepState.complete
                  : StepState.indexed,
            ),

            // Step 2: Scoring Configuration
            Step(
              title: const Text('Scoring'),
              subtitle: const Text('Weight, target, dan periode'),
              content: _buildScoringStep(),
              isActive: _currentStep >= (isEditMode ? 2 : 2),
              state: _currentStep > (isEditMode ? 2 : 2)
                  ? StepState.complete
                  : StepState.indexed,
            ),

            // Step 3: Preview & Save
            Step(
              title: const Text('Preview'),
              subtitle: const Text('Review dan simpan'),
              content: _buildPreviewStep(),
              isActive: _currentStep >= (isEditMode ? 3 : 3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepControls(BuildContext context, ControlsDetails details) {
    final isLastStep = _currentStep == _getMaxSteps() - 1;
    final isFirstStep = _currentStep == 0;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          FilledButton(
            onPressed: details.onStepContinue,
            child: Text(isLastStep ? 'Simpan' : 'Lanjut'),
          ),
          const SizedBox(width: 12),
          if (!isFirstStep)
            OutlinedButton(
              onPressed: details.onStepCancel,
              child: const Text('Kembali'),
            ),
        ],
      ),
    );
  }

  int _getMaxSteps() {
    return widget.measureId != null ? 3 : 4; // Skip template selection in edit mode
  }

  void _onStepContinue() {
    if (_currentStep < _getMaxSteps() - 1) {
      // Validate current step
      if (_validateCurrentStep()) {
        setState(() => _currentStep++);
      }
    } else {
      // Last step - save
      _saveMeasure();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      context.pop();
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Template selection
        if (_selectedTemplate == null) {
          _showError('Pilih template terlebih dahulu');
          return false;
        }
        return true;

      case 1: // Configuration
        if (_codeController.text.isEmpty) {
          _showError('Code harus diisi');
          return false;
        }
        if (_nameController.text.isEmpty) {
          _showError('Nama harus diisi');
          return false;
        }

        // Generate query from template config (only for new measures)
        if (_selectedTemplate != null && widget.measureId == null) {
          try {
            _generateQueryFromTemplate(_selectedTemplate!);
          } catch (e) {
            _showError('Invalid template configuration: $e');
            return false;
          }
        }

        return true;

      case 2: // Scoring
        if (_weightController.text.isEmpty) {
          _showError('Weight harus diisi');
          return false;
        }
        if (_defaultTargetController.text.isEmpty) {
          _showError('Target harus diisi');
          return false;
        }
        return true;

      default:
        return true;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _saveMeasure() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final isEditMode = widget.measureId != null;

      if (isEditMode) {
        // Update existing measure
        await ref.read(measureFormProvider.notifier).updateMeasure(
              widget.measureId!,
              name: _nameController.text,
              description: _descriptionController.text.isEmpty
                  ? null
                  : _descriptionController.text,
              weight: double.parse(_weightController.text),
              defaultTarget: double.parse(_defaultTargetController.text),
              periodType: _periodType,
            );
      } else {
        // Create new measure
        await ref.read(measureFormProvider.notifier).createMeasure(
              code: _codeController.text,
              name: _nameController.text,
              description: _descriptionController.text.isEmpty
                  ? null
                  : _descriptionController.text,
              measureType: _measureType,
              dataType: _dataType,
              unit: _unit,
              sourceTable: _sourceTable,
              sourceCondition: _sourceCondition,
              calculationFormula: _calculationFormula,
              weight: double.parse(_weightController.text),
              defaultTarget: double.parse(_defaultTargetController.text),
              periodType: _periodType,
              templateType: _selectedTemplate,
              templateConfig: _templateConfig.isEmpty ? null : _templateConfig,
            );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditMode
                  ? 'Measure berhasil diupdate'
                  : 'Measure berhasil dibuat',
            ),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        _showError('Gagal menyimpan: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Step builders

  Widget _buildTemplateSelectionStep() {
    final templates = [
      _TemplateOption(
        id: 'activity_count',
        name: 'Activity Count',
        description: 'Hitung aktivitas yang diselesaikan (VISIT, CALL, MEETING)',
        icon: Icons.checklist,
        color: Colors.blue,
        example: 'Contoh: Visit Count, Call Count, Outreach Count',
      ),
      _TemplateOption(
        id: 'pipeline_count',
        name: 'Pipeline Count',
        description: 'Hitung pipeline berdasarkan stage',
        icon: Icons.trending_up,
        color: Colors.green,
        example: 'Contoh: New Pipeline, Advanced Pipeline Count',
      ),
      _TemplateOption(
        id: 'pipeline_revenue',
        name: 'Pipeline Revenue',
        description: 'Total premi dari pipeline',
        icon: Icons.attach_money,
        color: Colors.orange,
        example: 'Contoh: Premium Won, Referral Premium',
      ),
      _TemplateOption(
        id: 'pipeline_conversion',
        name: 'Pipeline Conversion',
        description: 'Persentase konversi pipeline',
        icon: Icons.percent,
        color: Colors.purple,
        example: 'Contoh: Conversion Rate',
      ),
      _TemplateOption(
        id: 'stage_milestone',
        name: 'Stage Milestone',
        description: 'Track pencapaian stage tertentu',
        icon: Icons.flag,
        color: Colors.red,
        example: 'Contoh: Proposal Stage Reached',
      ),
      _TemplateOption(
        id: 'customer_acquisition',
        name: 'Customer Acquisition',
        description: 'Jumlah customer baru yang dibuat',
        icon: Icons.person_add,
        color: Colors.teal,
        example: 'Contoh: New Customer, New Broker Customer',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Pilih template yang sesuai dengan measure yang ingin dibuat:',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        ...templates.map((template) => _TemplateCard(
              template: template,
              isSelected: _selectedTemplate == template.id,
              onTap: () {
                setState(() {
                  _selectedTemplate = template.id;
                  // Set defaults based on template
                  _dataType = _getDefaultDataType(template.id);
                  _unit = _getDefaultUnit(template.id);
                });
              },
            )),
      ],
    );
  }

  Widget _buildConfigurationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Basic info
        TextFormField(
          controller: _codeController,
          decoration: const InputDecoration(
            labelText: 'Code *',
            hintText: 'LEAD-001, LAG-001',
            border: OutlineInputBorder(),
          ),
          enabled: widget.measureId == null, // Can't change code in edit mode
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Code harus diisi';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nama *',
            hintText: 'Visit Count',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Nama harus diisi';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Deskripsi',
            hintText: 'Jumlah visit yang diselesaikan',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),

        // Measure Type
        DropdownButtonFormField<String>(
          initialValue: _measureType,
          decoration: const InputDecoration(
            labelText: 'Tipe Measure *',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'LEAD', child: Text('LEAD (60%)')),
            DropdownMenuItem(value: 'LAG', child: Text('LAG (40%)')),
          ],
          onChanged: widget.measureId == null // Can't change type in edit mode
              ? (value) => setState(() => _measureType = value!)
              : null,
        ),
        const SizedBox(height: 24),

        // Template-specific configuration
        if (_selectedTemplate != null) ...[
          Divider(),
          const SizedBox(height: 16),
          Text(
            'Konfigurasi ${_formatTemplateName(_selectedTemplate!)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildTemplateConfigWidget(_selectedTemplate!),
        ],
      ],
    );
  }

  Widget _buildTemplateConfigWidget(String templateId) {
    // TODO: Implement template-specific configuration widgets
    switch (templateId) {
      case 'activity_count':
        return _buildActivityCountConfig();
      case 'pipeline_count':
        return _buildPipelineCountConfig();
      case 'pipeline_revenue':
        return _buildPipelineRevenueConfig();
      case 'pipeline_conversion':
        return _buildPipelineConversionConfig();
      case 'stage_milestone':
        return _buildStageMilestoneConfig();
      case 'customer_acquisition':
        return _buildCustomerAcquisitionConfig();
      default:
        return const Text('Template configuration coming soon...');
    }
  }

  Widget _buildActivityCountConfig() {
    final activityTypesAsync = ref.watch(activityTypesStreamProvider);

    return activityTypesAsync.when(
      data: (types) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MultiSelectCheckboxField(
            label: 'Pilih Jenis Aktivitas',
            items: types,
            selectedIds: _selectedActivityTypeIds,
            onChanged: (ids) => setState(() => _selectedActivityTypeIds = ids),
            getItemId: (item) => item.id,
            getItemLabel: (item) => item.name,
            maxHeight: 300,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Hanya Aktivitas yang Sudah Selesai'),
            subtitle: const Text('Filter aktivitas dengan status COMPLETED'),
            value: _includeCompletedOnly,
            onChanged: (value) => setState(() => _includeCompletedOnly = value),
          ),
        ],
      ),
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Error loading activity types: $error',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ),
    );
  }

  Widget _buildPipelineCountConfig() {
    final stagesAsync = ref.watch(pipelineStagesStreamProvider);

    return stagesAsync.when(
      data: (stages) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Pilih Stage Pipeline:'),
          const SizedBox(height: 8),
          ...stages.map((stage) => CheckboxListTile(
                title: Text(stage.name),
                subtitle: Text('${stage.probability}% probability'),
                value: _selectedStages.contains(stage.code),
                onChanged: (selected) {
                  setState(() {
                    if (selected ?? false) {
                      _selectedStages.add(stage.code);
                    } else {
                      _selectedStages.remove(stage.code);
                    }
                  });
                },
              )),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Kecualikan Tender'),
            subtitle: const Text('Hanya hitung pipeline non-tender'),
            value: _excludeTenders,
            onChanged: (value) => setState(() => _excludeTenders = value),
          ),
          SwitchListTile(
            title: const Text('Kecualikan Pipeline dari Broker'),
            subtitle: const Text('Hanya hitung pipeline direct (non-broker)'),
            value: _excludeBrokerSourced,
            onChanged: (value) => setState(() => _excludeBrokerSourced = value),
          ),
        ],
      ),
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Error loading pipeline stages: $error',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ),
    );
  }

  Widget _buildPipelineRevenueConfig() {
    final stagesAsync = ref.watch(pipelineStagesStreamProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Stage selection dropdown
        stagesAsync.when(
          data: (stages) => DropdownButtonFormField<String>(
            initialValue: _targetStage,
            decoration: const InputDecoration(
              labelText: 'Target Stage',
              helperText: 'Stage pipeline untuk hitung revenue',
              border: OutlineInputBorder(),
            ),
            items: stages
                .map((stage) => DropdownMenuItem(
                      value: stage.code,
                      child: Text('${stage.name} (${stage.probability}%)'),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _targetStage = value!),
          ),
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text(
            'Error: $e',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
        const SizedBox(height: 16),

        // Revenue field selection
        DropdownButtonFormField<String>(
          initialValue: _revenueField,
          decoration: const InputDecoration(
            labelText: 'Field Revenue',
            helperText: 'Field yang akan dijumlahkan',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: 'final_premium',
              child: Text('Final Premium'),
            ),
            DropdownMenuItem(
              value: 'potential_premium',
              child: Text('Potential Premium'),
            ),
          ],
          onChanged: (value) => setState(() => _revenueField = value!),
        ),
        const SizedBox(height: 16),

        // Filters
        SwitchListTile(
          title: const Text('Tender Saja'),
          subtitle: const Text('Hanya hitung pipeline tender'),
          value: _tendersOnly,
          onChanged: (value) => setState(() => _tendersOnly = value),
        ),
        SwitchListTile(
          title: const Text('Broker-Sourced Saja'),
          subtitle: const Text('Hanya hitung pipeline dari broker'),
          value: _brokerSourcedOnly,
          onChanged: (value) => setState(() => _brokerSourcedOnly = value),
        ),
      ],
    );
  }

  Widget _buildPipelineConversionConfig() {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Kalkulasi Otomatis',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Conversion rate dihitung otomatis dengan formula:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '(Pipeline Won / Total Pipeline Closed) × 100',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tidak perlu konfigurasi tambahan.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStageMilestoneConfig() {
    final stagesAsync = ref.watch(pipelineStagesStreamProvider);

    return stagesAsync.when(
      data: (stages) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _milestoneTargetStage,
            decoration: const InputDecoration(
              labelText: 'Target Stage (Tujuan)',
              helperText: 'Stage yang ingin dicapai',
              border: OutlineInputBorder(),
            ),
            items: stages
                .map((stage) => DropdownMenuItem(
                      value: stage.code,
                      child: Text(stage.name),
                    ))
                .toList(),
            onChanged: (value) =>
                setState(() => _milestoneTargetStage = value!),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Dari Stage Manapun'),
            subtitle: Text(_fromAnyStage
                ? 'Hitung semua transisi ke target stage'
                : 'Hanya hitung dari stage tertentu'),
            value: _fromAnyStage,
            onChanged: (value) {
              setState(() {
                _fromAnyStage = value;
                if (value) _fromSpecificStage = null;
              });
            },
          ),
          if (!_fromAnyStage) ...[
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _fromSpecificStage,
              decoration: const InputDecoration(
                labelText: 'Dari Stage Tertentu',
                helperText: 'Stage asal yang diperhitungkan',
                border: OutlineInputBorder(),
              ),
              items: stages
                  .map((stage) => DropdownMenuItem(
                        value: stage.code,
                        child: Text(stage.name),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _fromSpecificStage = value),
            ),
          ],
        ],
      ),
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Error loading pipeline stages: $error',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerAcquisitionConfig() {
    final companyTypesAsync = ref.watch(companyTypesStreamProvider);
    final industriesAsync = ref.watch(industriesStreamProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Filter berdasarkan Company Type (opsional):',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        companyTypesAsync.when(
          data: (types) => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: types
                .map((type) => FilterChip(
                      label: Text(type.name),
                      selected: _selectedCompanyTypeIds.contains(type.id),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedCompanyTypeIds.add(type.id);
                          } else {
                            _selectedCompanyTypeIds.remove(type.id);
                          }
                        });
                      },
                    ))
                .toList(),
          ),
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text(
            'Error: $e',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Filter berdasarkan Industry (opsional):',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        industriesAsync.when(
          data: (industries) => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: industries
                .map((industry) => FilterChip(
                      label: Text(industry.name),
                      selected: _selectedIndustryIds.contains(industry.id),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedIndustryIds.add(industry.id);
                          } else {
                            _selectedIndustryIds.remove(industry.id);
                          }
                        });
                      },
                    ))
                .toList(),
          ),
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text(
            'Error: $e',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ],
    );
  }

  Widget _buildScoringStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _weightController,
          decoration: const InputDecoration(
            labelText: 'Weight *',
            hintText: '1.0',
            border: OutlineInputBorder(),
            helperText: 'Bobot dalam perhitungan score (default: 1.0)',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Weight harus diisi';
            }
            if (double.tryParse(value) == null) {
              return 'Weight harus berupa angka';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _defaultTargetController,
          decoration: const InputDecoration(
            labelText: 'Default Target *',
            hintText: '10',
            border: OutlineInputBorder(),
            helperText: 'Target default untuk user (bisa diubah per user)',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Target harus diisi';
            }
            if (double.tryParse(value) == null) {
              return 'Target harus berupa angka';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        DropdownButtonFormField<String>(
          initialValue: _periodType,
          decoration: const InputDecoration(
            labelText: 'Periode *',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'WEEKLY', child: Text('Mingguan')),
            DropdownMenuItem(value: 'MONTHLY', child: Text('Bulanan')),
            DropdownMenuItem(value: 'QUARTERLY', child: Text('Kuartalan')),
          ],
          onChanged: (value) => setState(() => _periodType = value!),
        ),
      ],
    );
  }

  Widget _buildPreviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Review Measure',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),

        _PreviewCard(
          title: 'Informasi Dasar',
          children: [
            _PreviewRow(label: 'Code', value: _codeController.text),
            _PreviewRow(label: 'Nama', value: _nameController.text),
            _PreviewRow(
                label: 'Deskripsi',
                value: _descriptionController.text.isEmpty
                    ? '-'
                    : _descriptionController.text),
            _PreviewRow(
                label: 'Tipe',
                value: _measureType == 'LEAD' ? 'LEAD (60%)' : 'LAG (40%)'),
            if (_selectedTemplate != null)
              _PreviewRow(
                  label: 'Template',
                  value: _formatTemplateName(_selectedTemplate!)),
          ],
        ),
        const SizedBox(height: 16),

        _PreviewCard(
          title: 'Scoring Configuration',
          children: [
            _PreviewRow(label: 'Weight', value: _weightController.text),
            _PreviewRow(
                label: 'Default Target', value: _defaultTargetController.text),
            _PreviewRow(label: 'Periode', value: _formatPeriodType(_periodType)),
          ],
        ),
        const SizedBox(height: 16),

        // Query preview
        if (_sourceTable != null) ...[
          _PreviewCard(
            title: 'Generated Query Configuration',
            children: [
              _PreviewRow(label: 'Source Table', value: _sourceTable!),
              _PreviewRow(label: 'Data Type', value: _dataType),
              if (_unit != null) _PreviewRow(label: 'Unit', value: _unit!),
              if (_sourceCondition != null)
                _PreviewRow(
                  label: 'Source Condition',
                  value: _sourceCondition!,
                  maxLines: 10,
                ),
              if (_calculationFormula != null)
                _PreviewRow(
                  label: 'Calculation Formula',
                  value: _calculationFormula!,
                  maxLines: 3,
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Info card explaining query
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Query ini akan dijalankan otomatis untuk menghitung score. '
                      'Placeholder :user_id akan diganti saat runtime.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  // Helper methods

  String _formatTemplateName(String templateId) {
    switch (templateId) {
      case 'activity_count':
        return 'Activity Count';
      case 'pipeline_count':
        return 'Pipeline Count';
      case 'pipeline_revenue':
        return 'Pipeline Revenue';
      case 'pipeline_conversion':
        return 'Pipeline Conversion';
      case 'stage_milestone':
        return 'Stage Milestone';
      case 'customer_acquisition':
        return 'Customer Acquisition';
      default:
        return templateId;
    }
  }

  String _formatPeriodType(String periodType) {
    switch (periodType) {
      case 'WEEKLY':
        return 'Mingguan';
      case 'MONTHLY':
        return 'Bulanan';
      case 'QUARTERLY':
        return 'Kuartalan';
      default:
        return periodType;
    }
  }

  String _getDefaultDataType(String templateId) {
    switch (templateId) {
      case 'activity_count':
      case 'pipeline_count':
      case 'stage_milestone':
      case 'customer_acquisition':
        return 'COUNT';
      case 'pipeline_revenue':
        return 'SUM';
      case 'pipeline_conversion':
        return 'CALCULATED';
      default:
        return 'COUNT';
    }
  }

  String? _getDefaultUnit(String templateId) {
    switch (templateId) {
      case 'activity_count':
      case 'pipeline_count':
      case 'stage_milestone':
      case 'customer_acquisition':
        return 'count';
      case 'pipeline_revenue':
        return 'IDR';
      case 'pipeline_conversion':
        return '%';
      default:
        return null;
    }
  }

  // Query generation methods
  void _generateQueryFromTemplate(String templateId) {
    switch (templateId) {
      case 'activity_count':
        _generateActivityCountQuery();
        break;
      case 'pipeline_count':
        _generatePipelineCountQuery();
        break;
      case 'pipeline_revenue':
        _generatePipelineRevenueQuery();
        break;
      case 'pipeline_conversion':
        _generatePipelineConversionQuery();
        break;
      case 'stage_milestone':
        _generateStageMilestoneQuery();
        break;
      case 'customer_acquisition':
        _generateCustomerAcquisitionQuery();
        break;
    }
  }

  void _generateActivityCountQuery() {
    _sourceTable = 'activities';

    final conditions = <String>[];

    // Activity type condition
    if (_selectedActivityTypeIds.isNotEmpty) {
      final typeIds = _selectedActivityTypeIds.map((id) => "'$id'").join(', ');
      conditions.add('activity_type_id IN ($typeIds)');
    }

    // Completed filter
    if (_includeCompletedOnly) {
      conditions.add("status = 'COMPLETED'");
    }

    conditions.add('user_id = :user_id');

    _sourceCondition = conditions.join(' AND ');

    // Store config
    _templateConfig['activity_type_ids'] = _selectedActivityTypeIds.toList();
    _templateConfig['include_completed_only'] = _includeCompletedOnly;
  }

  void _generatePipelineCountQuery() {
    _sourceTable = 'pipelines';

    final conditions = <String>[];

    // Stage condition
    if (_selectedStages.isNotEmpty) {
      final stageCodes = _selectedStages.map((code) => "'$code'").join(', ');
      conditions.add('stage IN ($stageCodes)');
    }

    // Filters
    if (_excludeTenders) {
      conditions.add('is_tender = FALSE');
    }
    if (_excludeBrokerSourced) {
      conditions.add('broker_id IS NULL');
    }

    conditions.add('assigned_rm_id = :user_id');

    _sourceCondition = conditions.join(' AND ');

    // Store config
    _templateConfig['stages'] = _selectedStages.toList();
    _templateConfig['exclude_tenders'] = _excludeTenders;
    _templateConfig['exclude_broker_sourced'] = _excludeBrokerSourced;
  }

  void _generatePipelineRevenueQuery() {
    _sourceTable = 'pipelines';
    _dataType = 'SUM';
    _unit = 'IDR';

    final conditions = <String>[];
    conditions.add("stage = '$_targetStage'");

    if (_tendersOnly) {
      conditions.add('is_tender = TRUE');
    }
    if (_brokerSourcedOnly) {
      conditions.add('broker_id IS NOT NULL');
    }

    conditions.add('scored_to_user_id = :user_id');

    _sourceCondition = conditions.join(' AND ');
    _calculationFormula = 'SUM($_revenueField)';

    // Store config
    _templateConfig['target_stage'] = _targetStage;
    _templateConfig['revenue_field'] = _revenueField;
    _templateConfig['tenders_only'] = _tendersOnly;
    _templateConfig['broker_sourced_only'] = _brokerSourcedOnly;
  }

  void _generatePipelineConversionQuery() {
    _sourceTable = 'pipelines';
    _dataType = 'CALCULATED';
    _unit = '%';
    _sourceCondition =
        'scored_to_user_id = :user_id AND closed_date IS NOT NULL';
    _calculationFormula =
        "(COUNT(CASE WHEN stage = 'ACCEPTED' THEN 1 END)::NUMERIC / COUNT(*)) * 100";
    _templateConfig.clear(); // No config
  }

  void _generateStageMilestoneQuery() {
    _sourceTable = 'pipeline_stage_history';
    _dataType = 'COUNT';

    final conditions = <String>[];
    conditions.add("to_stage = '$_milestoneTargetStage'");

    if (!_fromAnyStage && _fromSpecificStage != null) {
      conditions.add("from_stage = '$_fromSpecificStage'");
    }

    conditions.add('changed_by = :user_id');

    _sourceCondition = conditions.join(' AND ');

    // Store config
    _templateConfig['target_stage'] = _milestoneTargetStage;
    _templateConfig['from_any_stage'] = _fromAnyStage;
    if (!_fromAnyStage && _fromSpecificStage != null) {
      _templateConfig['from_specific_stage'] = _fromSpecificStage;
    }
  }

  void _generateCustomerAcquisitionQuery() {
    _sourceTable = 'customers';
    _dataType = 'COUNT';

    final conditions = <String>[];

    if (_selectedCompanyTypeIds.isNotEmpty) {
      final companyTypeIds =
          _selectedCompanyTypeIds.map((id) => "'$id'").join(', ');
      conditions.add('company_type_id IN ($companyTypeIds)');
    }

    if (_selectedIndustryIds.isNotEmpty) {
      final industryIds = _selectedIndustryIds.map((id) => "'$id'").join(', ');
      conditions.add('industry_id IN ($industryIds)');
    }

    conditions.add('created_by = :user_id');

    _sourceCondition = conditions.join(' AND ');

    // Store config
    _templateConfig['company_type_ids'] = _selectedCompanyTypeIds.toList();
    _templateConfig['industry_ids'] = _selectedIndustryIds.toList();
  }

  // Restore template config from saved data
  void _restoreTemplateConfig(String templateType, Map<String, dynamic> config) {
    switch (templateType) {
      case 'activity_count':
        _selectedActivityTypeIds = Set<String>.from(
          config['activity_type_ids'] as List? ?? [],
        );
        _includeCompletedOnly = config['include_completed_only'] as bool? ?? true;
        break;

      case 'pipeline_count':
        _selectedStages = Set<String>.from(
          config['stages'] as List? ?? [],
        );
        _excludeTenders = config['exclude_tenders'] as bool? ?? false;
        _excludeBrokerSourced = config['exclude_broker_sourced'] as bool? ?? false;
        break;

      case 'pipeline_revenue':
        _targetStage = config['target_stage'] as String? ?? 'ACCEPTED';
        _revenueField = config['revenue_field'] as String? ?? 'final_premium';
        _tendersOnly = config['tenders_only'] as bool? ?? false;
        _brokerSourcedOnly = config['broker_sourced_only'] as bool? ?? false;
        break;

      case 'stage_milestone':
        _milestoneTargetStage = config['target_stage'] as String? ?? 'P2';
        _fromAnyStage = config['from_any_stage'] as bool? ?? true;
        _fromSpecificStage = config['from_specific_stage'] as String?;
        break;

      case 'customer_acquisition':
        _selectedCompanyTypeIds = Set<String>.from(
          config['company_type_ids'] as List? ?? [],
        );
        _selectedIndustryIds = Set<String>.from(
          config['industry_ids'] as List? ?? [],
        );
        break;

      case 'pipeline_conversion':
        // No config to restore
        break;
    }
  }
}

// Supporting widgets

class _TemplateOption {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final String example;

  _TemplateOption({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.example,
  });
}

class _TemplateCard extends StatelessWidget {
  final _TemplateOption template;
  final bool isSelected;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.template,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected
          ? template.color.withValues(alpha: 0.1)
          : null,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: template.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  template.icon,
                  color: template.color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      template.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      template.example,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: template.color,
                  size: 32,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _PreviewCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final String label;
  final String value;
  final int maxLines;

  const _PreviewRow({
    required this.label,
    required this.value,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

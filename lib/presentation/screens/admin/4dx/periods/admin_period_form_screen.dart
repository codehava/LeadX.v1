import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../providers/admin/admin_4dx_providers.dart';

/// Admin Period Form Screen.
///
/// Simple form for creating/editing scoring periods.
/// Fields: name, period type, start date, end date, is current.
class AdminPeriodFormScreen extends ConsumerStatefulWidget {
  final String? periodId; // Null for create, set for edit

  const AdminPeriodFormScreen({
    super.key,
    this.periodId,
  });

  @override
  ConsumerState<AdminPeriodFormScreen> createState() =>
      _AdminPeriodFormScreenState();
}

class _AdminPeriodFormScreenState extends ConsumerState<AdminPeriodFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  String _periodType = 'WEEKLY';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isCurrent = false;

  bool _isLoading = false;
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    if (widget.periodId != null) {
      _loadExistingPeriod();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingPeriod() async {
    setState(() => _isLoading = true);
    try {
      final period =
          await ref.read(periodByIdProvider(widget.periodId!).future);
      if (period != null) {
        setState(() {
          _nameController.text = period.name;
          _periodType = period.periodType;
          _startDate = period.startDate;
          _endDate = period.endDate;
          _isCurrent = period.isCurrent;
          _isLocked = period.isLocked;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat periode: $e'),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEditMode = widget.periodId != null;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Memuat...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Periode' : 'Buat Periode Baru'),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Locked warning
            if (_isLocked)
              Card(
                color: colorScheme.errorContainer,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock,
                        color: colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Periode ini telah dikunci dan tidak bisa diedit.',
                          style: TextStyle(color: colorScheme.onErrorContainer),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Period Type
            DropdownButtonFormField<String>(
              initialValue: _periodType,
              decoration: const InputDecoration(
                labelText: 'Tipe Periode *',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'WEEKLY', child: Text('Mingguan')),
                DropdownMenuItem(value: 'MONTHLY', child: Text('Bulanan')),
                DropdownMenuItem(
                    value: 'QUARTERLY', child: Text('Kuartalan')),
              ],
              onChanged: (_isLocked || isEditMode)
                  ? null
                  : (value) => setState(() => _periodType = value!),
            ),
            const SizedBox(height: 16),

            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Periode *',
                hintText: 'Week 1, Feb 2026',
                border: OutlineInputBorder(),
                helperText: 'Kosongkan untuk auto-generate dari tanggal',
              ),
              enabled: !_isLocked,
              validator: (value) {
                // Name is optional - will be auto-generated if empty
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Start Date
            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(color: colorScheme.outline),
              ),
              leading: const Icon(Icons.calendar_today),
              title: const Text('Tanggal Mulai *'),
              subtitle: Text(
                _startDate != null
                    ? _formatDate(_startDate!)
                    : 'Pilih tanggal mulai',
                style: TextStyle(
                  color: _startDate != null
                      ? null
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              enabled: !_isLocked,
              onTap: () => _pickDate(isStart: true),
            ),
            const SizedBox(height: 16),

            // End Date
            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(color: colorScheme.outline),
              ),
              leading: const Icon(Icons.calendar_today),
              title: const Text('Tanggal Selesai *'),
              subtitle: Text(
                _endDate != null
                    ? _formatDate(_endDate!)
                    : 'Pilih tanggal selesai',
                style: TextStyle(
                  color: _endDate != null
                      ? null
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              enabled: !_isLocked,
              onTap: () => _pickDate(isStart: false),
            ),
            const SizedBox(height: 16),

            // Is Current
            SwitchListTile(
              title: const Text('Periode Berjalan Saat Ini'),
              subtitle: const Text(
                'Jadikan periode ini sebagai periode penilaian yang sedang berjalan',
              ),
              value: _isCurrent,
              onChanged: _isLocked
                  ? null
                  : (value) => setState(() => _isCurrent = value),
            ),
            const SizedBox(height: 24),

            // Date range info
            if (_startDate != null && _endDate != null) ...[
              Card(
                color: colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Durasi: ${_endDate!.difference(_startDate!).inDays + 1} hari '
                          '(${_formatDate(_startDate!)} - ${_formatDate(_endDate!)})',
                          style: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Save button
            if (!_isLocked)
              FilledButton.icon(
                onPressed: _isLoading ? null : _savePeriod,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _isLoading
                      ? 'Menyimpan...'
                      : (isEditMode ? 'Update Periode' : 'Simpan Periode'),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initialDate = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // Auto-set end date based on period type if not set
          _endDate ??= _calculateEndDate(picked, _periodType);
        } else {
          _endDate = picked;
        }
        // Auto-populate name if empty
        if (_nameController.text.isEmpty && _startDate != null) {
          _nameController.text = _autoGenerateName();
        }
      });
    }
  }

  DateTime _calculateEndDate(DateTime startDate, String periodType) {
    switch (periodType) {
      case 'WEEKLY':
        return startDate.add(const Duration(days: 6));
      case 'MONTHLY':
        return DateTime(startDate.year, startDate.month + 1, 0);
      case 'QUARTERLY':
        final quarterEndMonth = ((startDate.month - 1) ~/ 3 + 1) * 3;
        // Handle year rollover for Q4 (Oct-Dec) where quarterEndMonth = 12
        return quarterEndMonth == 12
            ? DateTime(startDate.year + 1, 1, 0) // Last day of Dec (year+1, month 1, day 0)
            : DateTime(startDate.year, quarterEndMonth + 1, 0);
      default:
        return startDate.add(const Duration(days: 6));
    }
  }

  String _autoGenerateName() {
    if (_startDate == null) return '';

    switch (_periodType) {
      case 'WEEKLY':
        return 'Week ${_weekOfMonth(_startDate!)}, ${_monthName(_startDate!.month)} ${_startDate!.year}';
      case 'MONTHLY':
        return '${_monthName(_startDate!.month)} ${_startDate!.year}';
      case 'QUARTERLY':
        final quarter = (_startDate!.month - 1) ~/ 3 + 1;
        return 'Q$quarter ${_startDate!.year}';
      default:
        return '';
    }
  }

  int _weekOfMonth(DateTime date) {
    return ((date.day - 1) ~/ 7) + 1;
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }

  Future<void> _savePeriod() async {
    if (_startDate == null) {
      _showError('Tanggal mulai harus diisi');
      return;
    }
    if (_endDate == null) {
      _showError('Tanggal selesai harus diisi');
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      _showError('Tanggal selesai harus setelah tanggal mulai');
      return;
    }

    // Auto-generate name if empty
    final name = _nameController.text.isNotEmpty
        ? _nameController.text
        : _autoGenerateName();

    if (name.isEmpty) {
      _showError('Nama periode harus diisi');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final isEditMode = widget.periodId != null;

      if (isEditMode) {
        await ref.read(periodFormProvider.notifier).updatePeriod(
              widget.periodId!,
              name: name,
              startDate: _startDate,
              endDate: _endDate,
              isCurrent: _isCurrent,
            );
      } else {
        await ref.read(periodFormProvider.notifier).createPeriod(
              name: name,
              periodType: _periodType,
              startDate: _startDate!,
              endDate: _endDate!,
              isCurrent: _isCurrent,
            );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditMode
                  ? 'Periode berhasil diupdate'
                  : 'Periode berhasil dibuat',
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

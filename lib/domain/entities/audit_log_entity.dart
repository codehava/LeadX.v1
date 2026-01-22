import 'package:freezed_annotation/freezed_annotation.dart';

part 'audit_log_entity.freezed.dart';
part 'audit_log_entity.g.dart';

// ============================================
// AUDIT LOG ENTITY
// ============================================

/// Represents an audit log entry from the database.
/// Captures INSERT, UPDATE, DELETE operations on tracked entities.
@freezed
class AuditLog with _$AuditLog {
  const AuditLog._();

  const factory AuditLog({
    required String id,
    String? userId,
    String? userEmail,
    required String action, // INSERT, UPDATE, DELETE
    required String targetTable,
    required String targetId,
    Map<String, dynamic>? oldValues,
    Map<String, dynamic>? newValues,
    String? ipAddress,
    String? userAgent,
    required DateTime createdAt,
    // Resolved display names
    String? userName,
  }) = _AuditLog;

  factory AuditLog.fromJson(Map<String, dynamic> json) =>
      _$AuditLogFromJson(json);

  /// Get a human-readable action label.
  String get actionLabel {
    switch (action) {
      case 'INSERT':
        return 'Dibuat';
      case 'UPDATE':
        return 'Diubah';
      case 'DELETE':
        return 'Dihapus';
      default:
        return action;
    }
  }

  /// Calculate changed fields between old and new values.
  List<FieldChange> get changedFields {
    if (action == 'INSERT') {
      // For INSERT, all new values are "changes"
      return newValues?.entries
              .where((e) => !_excludedFields.contains(e.key))
              .map((e) => FieldChange(
                    field: e.key,
                    oldValue: null,
                    newValue: e.value,
                  ))
              .toList() ??
          [];
    }

    if (action == 'DELETE') {
      // For DELETE, show what was deleted
      return oldValues?.entries
              .where((e) => !_excludedFields.contains(e.key))
              .map((e) => FieldChange(
                    field: e.key,
                    oldValue: e.value,
                    newValue: null,
                  ))
              .toList() ??
          [];
    }

    // For UPDATE, compare old and new
    if (oldValues == null || newValues == null) return [];

    final changes = <FieldChange>[];
    for (final key in newValues!.keys) {
      if (_excludedFields.contains(key)) continue;
      final oldVal = oldValues![key];
      final newVal = newValues![key];
      if (oldVal != newVal) {
        changes.add(FieldChange(field: key, oldValue: oldVal, newValue: newVal));
      }
    }
    return changes;
  }

  /// Fields to exclude from change display
  static const _excludedFields = {
    'updated_at',
    'last_sync_at',
    'is_pending_sync',
    'created_at',
  };
}

// ============================================
// FIELD CHANGE HELPER
// ============================================

/// Represents a single field change in an audit log.
class FieldChange {
  final String field;
  final dynamic oldValue;
  final dynamic newValue;

  const FieldChange({
    required this.field,
    this.oldValue,
    this.newValue,
  });

  /// Get a human-readable field name.
  String get displayName {
    return _fieldNameMap[field] ?? _formatFieldName(field);
  }

  String _formatFieldName(String name) {
    // Convert snake_case to Title Case
    return name
        .split('_')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }

  static const _fieldNameMap = {
    'name': 'Nama',
    'address': 'Alamat',
    'phone': 'Telepon',
    'email': 'Email',
    'notes': 'Catatan',
    'stage_id': 'Stage',
    'status_id': 'Status',
    'potential_premium': 'Premi Potensial',
    'final_premium': 'Premi Final',
    'policy_number': 'Nomor Polis',
    'decline_reason': 'Alasan Ditolak',
    'expected_close_date': 'Tanggal Target Close',
    'province_id': 'Provinsi',
    'city_id': 'Kota',
    'postal_code': 'Kode Pos',
    'website': 'Website',
    'company_type_id': 'Tipe Perusahaan',
    'ownership_type_id': 'Tipe Kepemilikan',
    'industry_id': 'Industri',
    'npwp': 'NPWP',
  };
}

// ============================================
// PIPELINE STAGE HISTORY ENTITY
// ============================================

/// Represents a pipeline stage transition history entry.
@freezed
class PipelineStageHistory with _$PipelineStageHistory {
  const PipelineStageHistory._();

  const factory PipelineStageHistory({
    required String id,
    required String pipelineId,
    String? fromStageId,
    required String toStageId,
    String? fromStatusId,
    String? toStatusId,
    String? notes,
    String? changedBy,
    required DateTime changedAt,
    double? latitude,
    double? longitude,
    // Resolved names for display
    String? fromStageName,
    String? toStageName,
    String? fromStatusName,
    String? toStatusName,
    String? changedByName,
    String? fromStageColor,
    String? toStageColor,
  }) = _PipelineStageHistory;

  factory PipelineStageHistory.fromJson(Map<String, dynamic> json) =>
      _$PipelineStageHistoryFromJson(json);

  /// Check if GPS data is available.
  bool get hasGpsData => latitude != null && longitude != null;

  /// Get a formatted description of the transition.
  String get transitionDescription {
    if (fromStageName == null) {
      return 'Pipeline dibuat dengan stage $toStageName';
    }
    return 'Stage diubah dari $fromStageName ke $toStageName';
  }
}

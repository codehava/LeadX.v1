/// Translates raw sync error strings and entity metadata
/// into user-friendly Indonesian messages for the sync queue UI.
class SyncErrorTranslator {
  /// Translate a raw error string to a user-friendly Indonesian message.
  static String translate(String? rawError) {
    if (rawError == null || rawError.isEmpty) return 'Kesalahan tidak diketahui';

    // Auth errors
    if (rawError.contains('Authentication failed') || rawError.contains('401')) {
      return 'Sesi login kedaluwarsa. Silakan login ulang.';
    }
    // Validation errors
    if (rawError.contains('Validation error')) {
      return 'Data tidak valid. Periksa dan coba lagi.';
    }
    // Network errors
    if (rawError.contains('Network unreachable') ||
        rawError.contains('SocketException')) {
      return 'Tidak ada koneksi internet.';
    }
    // Timeout
    if (rawError.contains('timed out') || rawError.contains('Timeout')) {
      return 'Server tidak merespons. Coba lagi nanti.';
    }
    // Conflict
    if (rawError.contains('Conflict')) {
      return 'Data konflik dengan server. Versi server lebih baru.';
    }
    // Server errors
    if (rawError.contains('Server error') || rawError.contains('500')) {
      return 'Server sedang bermasalah. Coba lagi nanti.';
    }
    // Foreign key / reference errors
    if (rawError.contains('violates foreign key') ||
        rawError.contains('not present in table')) {
      return 'Data referensi tidak ditemukan di server.';
    }
    // Max retries exhausted
    if (rawError.contains('Max retries')) {
      // Extract the underlying error after "exhausted: "
      final idx = rawError.indexOf('exhausted: ');
      if (idx >= 0) {
        final underlying = rawError.substring(idx + 'exhausted: '.length);
        return translate(underlying);
      }
      return 'Gagal setelah beberapa percobaan.';
    }

    // Fallback with truncated raw error
    final truncated =
        rawError.length > 80 ? '${rawError.substring(0, 80)}...' : rawError;
    return 'Gagal sinkronisasi: $truncated';
  }

  /// Translate entity type to Indonesian display name.
  static String entityTypeName(String entityType) => switch (entityType) {
        'customer' => 'Pelanggan',
        'keyPerson' => 'Kontak',
        'pipeline' => 'Pipeline',
        'activity' => 'Aktivitas',
        'hvc' => 'HVC',
        'customerHvcLink' => 'Link HVC',
        'broker' => 'Broker',
        'pipelineStageHistory' => 'Riwayat Pipeline',
        'pipelineReferral' => 'Referral',
        'cadenceMeeting' => 'Cadence',
        'cadenceParticipant' => 'Peserta Cadence',
        'cadenceConfig' => 'Konfigurasi Cadence',
        _ => entityType,
      };

  /// Translate operation to Indonesian display name.
  static String operationName(String operation) => switch (operation) {
        'create' => 'Buat',
        'update' => 'Ubah',
        'delete' => 'Hapus',
        _ => operation,
      };
}

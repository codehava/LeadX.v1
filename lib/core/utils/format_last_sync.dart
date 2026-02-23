/// Format a last sync timestamp into a user-friendly Indonesian relative string.
String formatLastSync(DateTime? lastSync) {
  if (lastSync == null) return 'Belum pernah sinkronisasi';
  final diff = DateTime.now().difference(lastSync);
  if (diff.inMinutes < 1) return 'Terakhir sinkronisasi: baru saja';
  if (diff.inMinutes < 60) {
    return 'Terakhir sinkronisasi: ${diff.inMinutes} menit lalu';
  }
  if (diff.inHours < 24) {
    return 'Terakhir sinkronisasi: ${diff.inHours} jam lalu';
  }
  return 'Terakhir sinkronisasi: ${diff.inDays} hari lalu';
}

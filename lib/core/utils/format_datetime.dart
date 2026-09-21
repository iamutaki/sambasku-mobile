/// Format tanggal-waktu UI Indonesia.
/// Contoh: `17 Nov 2026 21:00`
///
/// Pola baku mobile (lihat docs/mobile/mobile-base-stack.md).
/// Bulan singkat: Jan Feb Mar Apr Mei Jun Jul Agu Sep Okt Nov Des.
library;

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

String _pad2(int n) => n.toString().padLeft(2, '0');

/// Format [DateTime] lokal: `17 Nov 2026 21:00`.
String formatDateTime(DateTime? value) {
  if (value == null) return '';
  final local = value.toLocal();
  return '${local.day} ${_months[local.month - 1]} ${local.year} '
      '${_pad2(local.hour)}:${_pad2(local.minute)}';
}

/// Parse ISO (UTC/offset) lalu format lokal. String kosong/invalid → `''`.
String formatDateTimeIso(String? iso) {
  if (iso == null || iso.isEmpty) return '';
  final dt = DateTime.tryParse(iso);
  if (dt == null) return '';
  return formatDateTime(dt);
}

/// Tanggal kalender `YYYY-MM-DD` tanpa geser zona. Contoh: `21 Sep 2026`.
String formatDateYmd(String? ymd) {
  if (ymd == null || ymd.isEmpty) return '';
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(ymd);
  if (match == null) return '';
  final year = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final day = int.parse(match.group(3)!);
  if (month < 1 || month > 12) return '';
  return '$day ${_months[month - 1]} $year';
}

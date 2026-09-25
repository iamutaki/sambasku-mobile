/// Normalisasi key L1: `METHOD|path|normalizedQuery`.
/// Tanpa host tier, Authorization, atau device id (§5.4 MOBILE_LOCAL_STRATEGI).
String buildCacheKey({
  required String method,
  required String path,
  Map<String, dynamic>? query,
}) {
  final m = method.trim().toUpperCase();
  final p = _normalizePath(path);
  final q = _normalizeQuery(query);
  return q.isEmpty ? '$m|$p' : '$m|$p|$q';
}

String _normalizePath(String path) {
  var p = path.trim();
  if (!p.startsWith('/')) p = '/$p';
  if (p.length > 1 && p.endsWith('/')) {
    p = p.substring(0, p.length - 1);
  }
  return p;
}

String _normalizeQuery(Map<String, dynamic>? query) {
  if (query == null || query.isEmpty) return '';
  final entries = <String, String>{};
  for (final e in query.entries) {
    final v = e.value;
    if (v == null) continue;
    final s = v.toString();
    if (s.isEmpty) continue;
    entries[e.key] = s;
  }
  final keys = entries.keys.toList()..sort();
  return keys.map((k) => '$k=${entries[k]}').join('&');
}

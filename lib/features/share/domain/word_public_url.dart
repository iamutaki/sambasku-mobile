import '../../../core/constants/env.dart';

/// URL publik HTTPS untuk detail kata (share caption + deep link).
String? wordPublicUrl(String lemma) {
  final base = Env.webAppUrl;
  if (base == null || base.isEmpty) return null;
  final trimmed = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
  return '$trimmed/words/${Uri.encodeComponent(lemma)}';
}

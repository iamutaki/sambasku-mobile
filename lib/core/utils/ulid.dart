/// ULID Crockford base32 (26 karakter). Sama pola web
/// `web/app/routes/words.$lemma.tsx` untuk bedakan URL lama by-id vs lemma.
final RegExp kUlidPattern = RegExp(r'^[0-9A-HJKMNP-TV-Z]{26}$', caseSensitive: false);

bool looksLikeUlid(String value) => kUlidPattern.hasMatch(value.trim());

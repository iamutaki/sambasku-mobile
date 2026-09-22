const otpCodeLength = 8;

/// Buang selain 0-9A-Z, huruf besar. Tidak memotong panjang.
String normalizeOtpInput(String raw) =>
    raw.replaceAll(RegExp(r'[^0-9A-Za-z]'), '').toUpperCase();

/// Tampilan `XXXX-XXXX`, max 8 karakter.
String formatOtpDisplay(String raw) {
  final code = normalizeOtpInput(raw);
  final clipped = code.length > otpCodeLength
      ? code.substring(0, otpCodeLength)
      : code;
  if (clipped.length <= 4) return clipped;
  return '${clipped.substring(0, 4)}-${clipped.substring(4)}';
}

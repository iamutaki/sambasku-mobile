import 'package:flutter/services.dart';

import '../otp_code.dart';

/// Input OTP 8 karakter 0-9A-Z, tampilan XXXX-XXXX.
class OtpCodeDashFormatter extends TextInputFormatter {
  const OtpCodeDashFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final display = formatOtpDisplay(newValue.text);
    return TextEditingValue(
      text: display,
      selection: TextSelection.collapsed(offset: display.length),
    );
  }
}

import 'package:fpdart/fpdart.dart';

import '../../otp_code.dart';
import '../failures/auth_failure.dart';
import '../repositories/auth_repository.dart';

/// Ambil token dari query `?token=` (tautan email / deep link) atau
/// kembalikan string mentah kalau user menempel token saja.
String extractResetToken(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return '';
  final uri = Uri.tryParse(trimmed);
  if (uri != null) {
    final fromQuery = uri.queryParameters['token'];
    if (fromQuery != null && fromQuery.isNotEmpty) return fromQuery;
  }
  return trimmed;
}

class ResetPasswordUseCase {
  const ResetPasswordUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<AuthFailure, String>> call(ResetPasswordParams params) {
    final token = params.token == null
        ? null
        : extractResetToken(params.token!);
    return _repository.resetPassword(
      token: token == null || token.isEmpty ? null : token,
      email: params.email?.trim(),
      code: params.code == null ? null : normalizeOtpInput(params.code!),
      newPassword: params.newPassword,
    );
  }
}

class ResetPasswordParams {
  const ResetPasswordParams({
    this.token,
    this.email,
    this.code,
    required this.newPassword,
  });

  final String? token;
  final String? email;
  final String? code;
  final String newPassword;
}

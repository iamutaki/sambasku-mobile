import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/submit_word_result.dart';
import '../../domain/failures/contribution_failure.dart';
import '../../domain/providers/contribution_domain_providers.dart';
import '../../domain/usecases/submit_anon_word_use_case.dart';
import '../models/submit_word_state.dart';

part 'submit_word_providers.g.dart';

@riverpod
class SubmitWordNotifier extends _$SubmitWordNotifier {
  @override
  SubmitWordState build() {
    ref.onDispose(() {});
    return const SubmitWordState();
  }

  /// Set initial value dari GoRouter query params.
  /// Dipanggil 1x di initState contribute_page.
  void initPrefill({String? lemma, String? searchIn}) {
    state = state.copyWith(
      initialLemma: lemma,
      initialSearchIn: searchIn,
    );
  }

  /// Clear inline VALIDATION_ERROR details saat user mulai mengetik lagi
  /// (UX: error hilang saat edit, supaya tidak "mengganggu").
  void clearFieldErrors() {
    if (state.failure is! ContributionFailure) return;
    state = state.copyWith(clearFailure: true, clearErrorMessage: true);
  }

  /// Trigger kirim usulan kata (anonim).
  ///
  /// Semua parameter WAJIB dari form UI. Minimal 1 translation_text.
  Future<void> submit({
    required String lemma,
    required String languageId,
    required String wordClassId,
    required String definition,
    String? dialectId,
    required List<String> translationTexts,
    List<String> categoryIds = const [],
    String? notes,
  }) async {
    if (state.isSubmitting) return;

    state = state.copyWith(
      isSubmitting: true,
      clearFailure: true,
      clearErrorMessage: true,
      clearResult: true,
    );

    final usecase = ref.read(submitAnonWordUseCaseProvider);
    final result = await usecase(SubmitAnonWordParams(
      lemma: lemma,
      languageId: languageId,
      wordClassId: wordClassId,
      definition: definition,
      dialectId: dialectId,
      translationTexts: translationTexts,
      categoryIds: categoryIds,
      notes: notes,
    ));

    result.match(
      (failure) {
        state = state.copyWith(
          isSubmitting: false,
          failure: failure,
          errorMessage: failure.isValidationError ? null : failure.message,
        );
      },
      (success) {
        state = state.copyWith(
          isSubmitting: false,
          result: success,
          clearFailure: true,
          clearErrorMessage: true,
        );
      },
    );
  }

  /// Helper read error inline untuk field. UI panggil ini di bawah FTextField.
  String? errorFor(String field) {
    final f = state.failure;
    if (f is! ContributionFailure) return null;
    return f.errorFor(field);
  }

  /// Shortcut untuk UI: jika success, kembalikan result typed.
  SubmitWordResult? get successResult {
    final r = state.result;
    return r is SubmitWordResult ? r : null;
  }
}

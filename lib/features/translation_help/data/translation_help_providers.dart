import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import 'translation_help_image_upload_service.dart';
import 'translation_help_repository.dart';

final translationHelpRepositoryProvider = Provider<TranslationHelpRepository>(
  (ref) => TranslationHelpRepository(ref.watch(dioProvider)),
);

final translationHelpImageUploadServiceProvider =
    Provider<TranslationHelpImageUploadService>(
      (ref) => TranslationHelpImageUploadService(
        ref.watch(translationHelpRepositoryProvider),
      ),
    );

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers/dictionary_data_providers.dart';
import '../usecases/get_word_by_id_use_case.dart';
import '../usecases/search_words_use_case.dart';

part 'dictionary_domain_providers.g.dart';

@riverpod
SearchWordsUseCase searchWordsUseCase(Ref ref) =>
    SearchWordsUseCase(ref.watch(dictionaryRepositoryProvider));

@riverpod
GetWordByIdUseCase getWordByIdUseCase(Ref ref) =>
    GetWordByIdUseCase(ref.watch(dictionaryRepositoryProvider));

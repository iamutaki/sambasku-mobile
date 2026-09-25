import 'package:fpdart/fpdart.dart';

import '../entities/word_of_day.dart';
import '../failures/dictionary_failure.dart';
import '../repositories/dictionary_repository.dart';

class GetWordOfDayUseCase {
  const GetWordOfDayUseCase(this._repository);

  final DictionaryRepository _repository;

  Future<Either<DictionaryFailure, WordOfDay?>> call({
    bool forceRefresh = false,
  }) =>
      _repository.getWordOfDay(forceRefresh: forceRefresh);
}

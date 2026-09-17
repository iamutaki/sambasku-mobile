import 'package:fpdart/fpdart.dart';

import '../entities/word_detail.dart';
import '../failures/dictionary_failure.dart';
import '../repositories/dictionary_repository.dart';

class GetWordByIdUseCase {
  const GetWordByIdUseCase(this._repository);

  final DictionaryRepository _repository;

  Future<Either<DictionaryFailure, WordDetail>> call(String id) =>
      _repository.getWordById(id);
}

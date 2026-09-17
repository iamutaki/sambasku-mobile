import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../domain/repositories/dictionary_repository.dart';
import '../datasources/dictionary_remote_datasource.dart';
import '../repositories/dictionary_repository_impl.dart';

part 'dictionary_data_providers.g.dart';

@riverpod
DictionaryRemoteDatasource dictionaryRemoteDatasource(Ref ref) =>
    DictionaryRemoteDatasource(ref.watch(dioProvider));

@riverpod
DictionaryRepository dictionaryRepository(Ref ref) =>
    DictionaryRepositoryImpl(ref.watch(dictionaryRemoteDatasourceProvider));

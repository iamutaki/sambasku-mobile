import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers/search_miss_data_providers.dart';
import '../usecases/list_search_misses_use_case.dart';

part 'search_miss_domain_providers.g.dart';

@riverpod
ListSearchMissesUseCase listSearchMissesUseCase(Ref ref) =>
    ListSearchMissesUseCase(ref.watch(searchMissRepositoryProvider));

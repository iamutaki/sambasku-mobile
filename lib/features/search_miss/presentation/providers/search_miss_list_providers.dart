import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/entities/search_miss.dart';
import '../../domain/providers/search_miss_domain_providers.dart';
import '../../domain/usecases/list_search_misses_use_case.dart';

/// Shared list: beranda idle (limit kecil) & tab Kontribusi (limit lebih besar).
final searchMissListProvider =
    FutureProvider.family<List<SearchMiss>, int>((ref, limit) async {
  final usecase = ref.watch(listSearchMissesUseCaseProvider);
  final result = await usecase(ListSearchMissesParams(limit: limit));
  return result.match((_) => <SearchMiss>[], (r) => r);
});

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers/contribution_data_providers.dart';
import '../usecases/submit_anon_word_use_case.dart';

part 'contribution_domain_providers.g.dart';

@riverpod
SubmitAnonWordUseCase submitAnonWordUseCase(Ref ref) =>
    SubmitAnonWordUseCase(ref.watch(contributionRepositoryProvider));

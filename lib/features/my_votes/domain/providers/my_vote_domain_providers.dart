import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers/my_vote_data_providers.dart';
import '../usecases/list_my_votes_use_case.dart';

part 'my_vote_domain_providers.g.dart';

@riverpod
ListMyVotesUseCase listMyVotesUseCase(Ref ref) =>
    ListMyVotesUseCase(ref.watch(myVoteRepositoryProvider));

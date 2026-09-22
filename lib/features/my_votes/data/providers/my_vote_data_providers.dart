import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../domain/repositories/my_vote_repository.dart';
import '../repositories/my_vote_repository_impl.dart';

part 'my_vote_data_providers.g.dart';

@riverpod
MyVoteRepository myVoteRepository(Ref ref) =>
    MyVoteRepositoryImpl(ref.watch(dioProvider));

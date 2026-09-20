import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../domain/repositories/my_contribution_repository.dart';
import '../repositories/my_contribution_repository_impl.dart';

part 'my_contribution_data_providers.g.dart';

@riverpod
MyContributionRepository myContributionRepository(Ref ref) =>
    MyContributionRepositoryImpl(ref.watch(dioProvider));

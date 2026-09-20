import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers/my_contribution_data_providers.dart';
import '../usecases/my_contribution_use_cases.dart';

part 'my_contribution_domain_providers.g.dart';

@riverpod
ListMyContributionsUseCase listMyContributionsUseCase(Ref ref) =>
    ListMyContributionsUseCase(ref.watch(myContributionRepositoryProvider));

@riverpod
GetMyContributionDetailUseCase getMyContributionDetailUseCase(Ref ref) =>
    GetMyContributionDetailUseCase(ref.watch(myContributionRepositoryProvider));

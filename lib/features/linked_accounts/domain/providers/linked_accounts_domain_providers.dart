import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers/linked_accounts_data_providers.dart';
import '../usecases/linked_accounts_use_cases.dart';

part 'linked_accounts_domain_providers.g.dart';

@riverpod
GetGoogleLinkStatusUseCase getGoogleLinkStatusUseCase(Ref ref) =>
    GetGoogleLinkStatusUseCase(ref.watch(linkedAccountsRepositoryProvider));

@riverpod
LinkGoogleAccountUseCase linkGoogleAccountUseCase(Ref ref) =>
    LinkGoogleAccountUseCase(ref.watch(linkedAccountsRepositoryProvider));

@riverpod
UnlinkGoogleAccountUseCase unlinkGoogleAccountUseCase(Ref ref) =>
    UnlinkGoogleAccountUseCase(ref.watch(linkedAccountsRepositoryProvider));

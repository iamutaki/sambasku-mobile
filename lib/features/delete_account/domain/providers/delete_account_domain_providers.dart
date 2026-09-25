import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers/delete_account_data_providers.dart';
import '../usecases/delete_account_use_case.dart';

part 'delete_account_domain_providers.g.dart';

@riverpod
DeleteAccountUseCase deleteAccountUseCase(Ref ref) =>
    DeleteAccountUseCase(ref.watch(deleteAccountRepositoryProvider));

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers/auth_data_providers.dart';
import '../usecases/login_use_case.dart';

part 'auth_domain_providers.g.dart';

@riverpod
LoginUseCase authLoginUseCase(Ref ref) =>
    LoginUseCase(ref.watch(authRepositoryProvider));

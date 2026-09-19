import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers/auth_data_providers.dart';
import '../usecases/login_use_case.dart';
import '../usecases/logout_use_case.dart';
import '../usecases/register_use_case.dart';

part 'auth_domain_providers.g.dart';

@riverpod
RegisterUseCase authRegisterUseCase(Ref ref) =>
    RegisterUseCase(ref.watch(authRepositoryProvider));

@riverpod
LoginUseCase authLoginUseCase(Ref ref) =>
    LoginUseCase(ref.watch(authRepositoryProvider));

@riverpod
LogoutUseCase authLogoutUseCase(Ref ref) =>
    LogoutUseCase(ref.watch(authRepositoryProvider));

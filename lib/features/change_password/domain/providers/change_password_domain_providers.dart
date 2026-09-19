import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers/change_password_data_providers.dart';
import '../usecases/change_password_use_case.dart';

part 'change_password_domain_providers.g.dart';

@riverpod
ChangePasswordUseCase changePasswordUseCase(Ref ref) =>
    ChangePasswordUseCase(ref.watch(changePasswordRepositoryProvider));

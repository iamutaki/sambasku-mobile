import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers/my_comment_data_providers.dart';
import '../usecases/list_my_comments_use_case.dart';

part 'my_comment_domain_providers.g.dart';

@riverpod
ListMyCommentsUseCase listMyCommentsUseCase(Ref ref) =>
    ListMyCommentsUseCase(ref.watch(myCommentRepositoryProvider));

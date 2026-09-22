import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../domain/repositories/my_comment_repository.dart';
import '../repositories/my_comment_repository_impl.dart';

part 'my_comment_data_providers.g.dart';

@riverpod
MyCommentRepository myCommentRepository(Ref ref) =>
    MyCommentRepositoryImpl(ref.watch(dioProvider));

import 'package:fpdart/fpdart.dart';

import '../entities/my_comment_page.dart';
import '../failures/my_comment_failure.dart';

abstract interface class MyCommentRepository {
  Future<Either<MyCommentFailure, MyCommentPage>> listMine({
    int limit = 20,
    String? cursor,
    String? status,
  });
}

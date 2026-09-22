import 'my_submission.dart';

class MySubmissionPage {
  const MySubmissionPage({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
  });

  final List<MySubmission> items;
  final String? nextCursor;
  final bool hasMore;
}

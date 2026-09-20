import '../../domain/entities/my_submission.dart';

class MyContributionsState {
  const MyContributionsState({
    this.items = const [],
    this.nextCursor,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  final List<MySubmission> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;

  MyContributionsState copyWith({
    List<MySubmission>? items,
    String? nextCursor,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return MyContributionsState(
      items: items ?? this.items,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

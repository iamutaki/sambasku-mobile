import '../../domain/entities/my_vote_item.dart';

class MyVotesState {
  const MyVotesState({
    this.items = const [],
    this.nextCursor,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  final List<MyVoteItem> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;

  MyVotesState copyWith({
    List<MyVoteItem>? items,
    String? nextCursor,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return MyVotesState(
      items: items ?? this.items,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

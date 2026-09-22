import 'my_vote_item.dart';

class MyVotePage {
  const MyVotePage({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
  });

  final List<MyVoteItem> items;
  final String? nextCursor;
  final bool hasMore;
}

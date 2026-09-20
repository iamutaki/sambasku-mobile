import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/router/route_definer.dart';
import 'presentation/pages/word_detail_page.dart';
import 'presentation/pages/word_list_page.dart';
import '../suggest_edit/presentation/pages/suggest_edit_page.dart';
import '../suggest_edit/presentation/pages/word_change_history_page.dart';

class DictionaryRouter {
  DictionaryRouter._();

  /// Daftar semua kata A-Z (18-api-list-words.md). '/words' exact hanya
  /// match list - tidak bentrok '/words/:id' (go_router).
  static const list = RouteDefiner(
    path: '/words',
    name: 'DictionaryRouter.list',
  );

  static const detail = RouteDefiner(
    path: '/words/:id',
    name: 'DictionaryRouter.detail',
  );

  static const changeHistory = RouteDefiner(
    path: '/words/:id/history',
    name: 'DictionaryRouter.changeHistory',
  );

  static const suggestEdit = RouteDefiner(
    path: '/suggest-edit/:wordId',
    name: 'DictionaryRouter.suggestEdit',
  );

  static final List<GoRoute> routes = [
    GoRoute(
      path: list.path,
      name: list.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => const WordListPage(),
    ),
    // Spesifik dulu supaya '/words/:id/history' tidak tertelan detail.
    GoRoute(
      path: changeHistory.path,
      name: changeHistory.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => WordChangeHistoryPage(
        wordId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: detail.path,
      name: detail.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => WordDetailPage(
        wordId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: suggestEdit.path,
      name: suggestEdit.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => SuggestEditPage(
        wordId: state.pathParameters['wordId']!,
      ),
    ),
  ];
}

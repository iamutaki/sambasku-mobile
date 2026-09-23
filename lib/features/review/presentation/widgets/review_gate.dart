import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../domain/review_access.dart';
import '../pages/review_forbidden_page.dart';

/// Penjaga rute /review. Peran dicek di klien; API tetap sumber kebenaran.
class ReviewGate extends ConsumerWidget {
  const ReviewGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStatusProvider);
    return auth.when(
      loading: () => const FScaffold(child: Center(child: FCircularProgress())),
      error: (_, _) => const ReviewForbiddenPage(),
      data: (status) => canReviewQueue(status.role) ? child : const ReviewForbiddenPage(),
    );
  }
}

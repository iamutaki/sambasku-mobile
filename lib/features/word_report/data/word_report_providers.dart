import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import 'word_report_repository.dart';

final wordReportRepositoryProvider = Provider<WordReportRepository>(
  (ref) => WordReportRepository(ref.watch(dioProvider)),
);

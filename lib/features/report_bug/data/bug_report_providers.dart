import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../data/bug_report_repository.dart';
import '../data/report_image_upload_service.dart';

final bugReportRepositoryProvider = Provider<BugReportRepository>(
  (ref) => BugReportRepository(ref.watch(dioProvider)),
);

final reportImageUploadServiceProvider = Provider<ReportImageUploadService>(
  (ref) => ReportImageUploadService(ref.watch(bugReportRepositoryProvider)),
);

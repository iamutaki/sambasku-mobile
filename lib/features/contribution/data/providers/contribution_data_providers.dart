import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../domain/repositories/contribution_repository.dart';
import '../datasources/contribution_remote_datasource.dart';
import '../datasources/image_remote_datasource.dart';
import '../datasources/imagekit_uploader.dart';
import '../datasources/private_image_upload_service.dart';
import '../datasources/word_image_upload_service.dart';
import '../repositories/contribution_repository_impl.dart';

part 'contribution_data_providers.g.dart';

@riverpod
ContributionRemoteDatasource contributionRemoteDatasource(Ref ref) =>
    ContributionRemoteDatasource(ref.watch(dioProvider));

@riverpod
ContributionRepository contributionRepository(Ref ref) =>
    ContributionRepositoryImpl(ref.watch(contributionRemoteDatasourceProvider));

@riverpod
ImageRemoteDatasource imageRemoteDatasource(Ref ref) =>
    ImageRemoteDatasource(ref.watch(dioProvider));

@riverpod
WordImageUploadService wordImageUploadService(Ref ref) =>
    WordImageUploadService(
      ref.watch(imageRemoteDatasourceProvider),
      ImageKitUploader(),
    );

@riverpod
PrivateImageUploadService privateImageUploadService(Ref ref) =>
    PrivateImageUploadService(
      ref.watch(imageRemoteDatasourceProvider),
      ImageKitUploader(),
    );

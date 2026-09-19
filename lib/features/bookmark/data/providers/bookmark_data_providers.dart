import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../domain/repositories/bookmark_repository.dart';
import '../datasources/bookmark_remote_datasource.dart';
import '../repositories/bookmark_repository_impl.dart';

part 'bookmark_data_providers.g.dart';

@riverpod
BookmarkRemoteDatasource bookmarkRemoteDatasource(Ref ref) =>
    BookmarkRemoteDatasource(ref.watch(dioProvider));

@riverpod
BookmarkRepository bookmarkRepository(Ref ref) =>
    BookmarkRepositoryImpl(ref.watch(bookmarkRemoteDatasourceProvider));

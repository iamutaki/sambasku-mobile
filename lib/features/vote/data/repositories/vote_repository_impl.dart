import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../domain/entities/vote_target.dart';
import '../../domain/entities/vote_view.dart';
import '../../domain/failures/vote_failure.dart';
import '../../domain/repositories/vote_repository.dart';
import '../datasources/vote_remote_datasource.dart';
import '../models/my_vote_dto.dart';
import '../models/vote_count_dto.dart';
import '../models/vote_toggle_request_dto.dart';

class VoteRepositoryImpl implements VoteRepository {
  VoteRepositoryImpl(this._remoteDatasource);

  final VoteRemoteDatasource _remoteDatasource;

  @override
  Future<Either<VoteFailure, VoteView>> toggle(
    VoteTarget target,
    int value,
  ) async {
    try {
      final response = await _remoteDatasource.toggle(
        VoteToggleRequestDto(
          targetType: target.type,
          targetId: target.id,
          value: value,
        ),
      );

      if (response.success == false || response.data == null) {
        return Either.left(
          VoteFailure(
            response.message ?? 'Gagal mengubah vote',
            errorCode: response.errorCode,
          ),
        );
      }

      final dto = response.data!;
      return Either.right(
        VoteView(
          target: VoteTarget(type: dto.targetType, id: dto.targetId),
          upvotes: dto.upvotes,
          downvotes: dto.downvotes,
          myVote: dto.myVote,
        ),
      );
    } on DioException catch (error) {
      return Either.left(_mapDio(error));
    } catch (error) {
      return Either.left(VoteFailure(error.toString()));
    }
  }

  @override
  Future<Either<VoteFailure, Map<String, VoteCounts>>> countMany(
    List<VoteTarget> targets,
  ) async {
    try {
      final response = await _remoteDatasource.getCounts(_targetsQuery(targets));

      if (response.success == false) {
        return Either.left(
          VoteFailure(
            response.message ?? 'Gagal memuat jumlah vote',
            errorCode: response.errorCode,
          ),
        );
      }

      final items = response.data ?? const <VoteCountDto>[];
      final result = <String, VoteCounts>{};
      for (final dto in items) {
        result['${dto.targetType}:${dto.targetId}'] = VoteCounts(
          upvotes: dto.upvotes,
          downvotes: dto.downvotes,
        );
      }
      return Either.right(result);
    } on DioException catch (error) {
      return Either.left(_mapDio(error));
    } catch (error) {
      return Either.left(VoteFailure(error.toString()));
    }
  }

  @override
  Future<Either<VoteFailure, Map<String, int>>> myVotes(
    List<VoteTarget> targets,
  ) async {
    try {
      final response = await _remoteDatasource.getMyVotes(
        _targetsQuery(targets),
      );

      if (response.success == false) {
        return Either.left(
          VoteFailure(
            response.message ?? 'Gagal memuat vote Anda',
            errorCode: response.errorCode,
          ),
        );
      }

      final items = response.data ?? const <MyVoteDto>[];
      final result = <String, int>{};
      for (final dto in items) {
        result['${dto.targetType}:${dto.targetId}'] = dto.value;
      }
      return Either.right(result);
    } on DioException catch (error) {
      return Either.left(_mapDio(error));
    } catch (error) {
      return Either.left(VoteFailure(error.toString()));
    }
  }

  /// Query param `targets` = daftar "type:id" dipisah koma (max 50 pasang,
  /// validator backend yang menegakkan).
  Map<String, dynamic> _targetsQuery(List<VoteTarget> targets) => {
        'targets': targets.map((t) => '${t.type}:${t.id}').join(','),
      };

  VoteFailure _mapDio(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final code = data['error_code'] as String?;
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        final proper = code == 'VOTE_TARGET_NOT_FOUND'
            ? 'Target vote tidak ditemukan atau sudah dihapus'
            : message;
        return VoteFailure(proper, errorCode: code);
      }
      final fallback = _fallbackForStatus(error.response?.statusCode, code);
      return VoteFailure(fallback, errorCode: code);
    }
    return VoteFailure(_fallbackForStatus(error.response?.statusCode, null));
  }

  String _fallbackForStatus(int? statusCode, String? errorCode) {
    if (statusCode == 429 || errorCode == 'RATE_LIMITED') {
      return 'Terlalu banyak vote. Coba lagi nanti.';
    }
    if (statusCode == 401) {
      return 'Sesi berakhir, silakan masuk kembali';
    }
    if (statusCode != null && statusCode >= 500) {
      return 'Server sedang gangguan. Coba lagi nanti.';
    }
    return 'Terjadi kesalahan saat memuat vote, coba lagi';
  }
}
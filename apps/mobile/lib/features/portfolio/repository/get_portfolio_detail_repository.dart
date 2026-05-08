import 'package:runway/domain/entity/portfolio_detail.dart';
import 'package:runway/features/portfolio/dto/portfolio_detail_response_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:runway/core/error/failure.dart';
import 'package:dartz/dartz.dart';

class GetPortfolioDetailRepository {
  final SupabaseClient _client;

  GetPortfolioDetailRepository({required SupabaseClient client})
    : _client = client;

  Future<Either<Failure, PortfolioDetail>> getPortfolioDetail(
    String portfolioId,
  ) async {
    try {
      final response = await _client.functions.invoke(
        'portfolios/$portfolioId',
        method: HttpMethod.get,
      );

      if (response.status != 200) {
        return Left(ServerFailure('조회 실패'));
      }

      if (response.data is! Map<String, dynamic>) {
        return Left(ServerFailure('포트폴리오 상세 응답 형식이 올바르지 않습니다.'));
      }

      final Map<String, dynamic> portfolioDetailJson =
          response.data as Map<String, dynamic>;

      final bool hasDetailShape =
          portfolioDetailJson.containsKey('simulationInput') &&
          portfolioDetailJson.containsKey('simulationResult');

      if (!hasDetailShape) {
        return Left(ServerFailure('포트폴리오 상세 정보를 아직 불러올 수 없습니다.'));
      }

      final portfolioDetail = PortfolioDetailResponseDto.fromJson(
        portfolioDetailJson,
      ).toModel();

      return Right(portfolioDetail);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  Future<Either<Failure, PortfolioDetail>> getPortfolioSnapshotDetail(
    String portfolioSnapshotId,
  ) async {
    try {
      final response = await _client.functions.invoke(
        'portfolios/snapshots/$portfolioSnapshotId',
        method: HttpMethod.get,
      );

      if (response.status != 200) {
        return Left(ServerFailure('조회 실패'));
      }

      if (response.data is! Map<String, dynamic>) {
        return Left(ServerFailure('포트폴리오 상세 응답 형식이 올바르지 않습니다.'));
      }

      final Map<String, dynamic> portfolioDetailJson =
          response.data as Map<String, dynamic>;

      final bool hasDetailShape =
          portfolioDetailJson.containsKey('simulationInput') &&
          portfolioDetailJson.containsKey('simulationResult');

      if (!hasDetailShape) {
        return Left(ServerFailure('포트폴리오 상세 정보를 아직 불러올 수 없습니다.'));
      }

      final portfolioDetail = PortfolioDetailResponseDto.fromJson(
        portfolioDetailJson,
      ).toModel();

      return Right(portfolioDetail);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}

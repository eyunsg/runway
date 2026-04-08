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

      final portfolioDetailJson = response.data as Map<String, dynamic>;

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

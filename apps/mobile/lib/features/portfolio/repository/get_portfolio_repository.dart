import 'package:runway/domain/entity/portfolio.dart';
import 'package:runway/features/portfolio/dto/portfolio_response_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:runway/core/error/failure.dart';
import 'package:dartz/dartz.dart';

class GetPortfolioRepository {
  final SupabaseClient _client;

  GetPortfolioRepository({required SupabaseClient client}) : _client = client;

  Future<Either<Failure, List<Portfolio>>> getPortfolio() async {
    try {
      final response = await _client.functions.invoke(
        'portfolios',
        method: HttpMethod.get,
      );

      if (response.status != 200) {
        return Left(ServerFailure('조회 실패'));
      }

      final portfoliosJson = response.data['portfolios'] as List;

      final portfolios = portfoliosJson
          .map((e) => PortfolioResponseDto.fromJson(e).toModel())
          .toList();

      return Right(portfolios);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // pagination 사용 시
  // Future<Either<Failure, List<Portfolio>>> getPortfolio({
  //   required int limit,
  //   required int offset,
  // }) async {
  //   try {
  //     final response = await _client.functions.invoke(
  //       'portfolios?limit=$limit&offset=$offset',
  //       method: HttpMethod.get,
  //     );
  //
  //     if (response.status != 200) {
  //       return Left(ServerFailure('조회 실패'));
  //     }
  //
  //     final portfoliosJson = response.data['portfolios'] as List;
  //
  //     final portfolios = portfoliosJson
  //         .map((e) => PortfolioResponseDto.fromJson(e).toModel())
  //         .toList();
  //
  //     return Right(portfolios);
  //   } on AuthException catch (e) {
  //     return Left(AuthFailure(e.message));
  //   } on PostgrestException catch (e) {
  //     return Left(ServerFailure(e.message));
  //   } on Exception catch (e) {
  //     return Left(UnknownFailure(e.toString()));
  //   }
  // }
}

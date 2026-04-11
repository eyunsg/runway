import 'package:dartz/dartz.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/features/portfolio/dto/create_portfolio_request_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdatePortfolioRepository {
  final SupabaseClient _client;

  UpdatePortfolioRepository({required SupabaseClient client})
    : _client = client;

  Future<Either<Failure, void>> updatePortfolio(
    String portfolioId,
    CreatePortfolioRequestDto dto,
  ) async {
    try {
      final response = await _client.functions.invoke(
        'portfolios/$portfolioId',
        method: HttpMethod.patch,
        body: dto.toJson(),
      );

      if (response.status != 204) {
        final errorMessage =
            response.data?['error']?['message'] ?? 'Update failed';
        return Left(ServerFailure(errorMessage));
      }

      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}

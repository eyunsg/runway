import 'package:runway/features/portfolio/dto/create_portfolio_request_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:runway/core/error/failure.dart';
import 'package:dartz/dartz.dart';

class CreatePortfolioRepository {
  final SupabaseClient _client;

  CreatePortfolioRepository({required SupabaseClient client})
    : _client = client;

  Future<Either<Failure, void>> createPortfolio(
    CreatePortfolioRequestDto dto,
  ) async {
    try {
      final response = await _client.functions.invoke(
        'portfolios',
        method: HttpMethod.post,
        body: dto.toJson(),
      );

      if (response.status != 201) {
        return Left(ServerFailure('Create failed'));
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

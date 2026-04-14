import 'package:dartz/dartz.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/domain/entity/portfolio_detail.dart';
import 'package:runway/features/portfolio/repository/get_portfolio_detail_repository.dart';

class GetPortfolioDetailUseCase {
  final GetPortfolioDetailRepository repository;

  GetPortfolioDetailUseCase(this.repository);

  Future<Either<Failure, PortfolioDetail>> execute({
    required String portfolioId,
  }) async {
    final result = await repository.getPortfolioDetail(portfolioId);
    return result;
  }
}

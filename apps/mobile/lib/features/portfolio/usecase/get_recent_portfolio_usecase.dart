import 'package:dartz/dartz.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/domain/entity/portfolio.dart';
import 'package:runway/features/portfolio/repository/get_portfolio_repository.dart';

class GetRecentPortfolioUseCase {
  final GetPortfolioRepository repository;

  GetRecentPortfolioUseCase(this.repository);

  Future<Either<Failure, Portfolio?>> execute() async {
    final result = await repository.getRecentPortfolio();

    return result;
  }
}

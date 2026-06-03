import 'package:dartz/dartz.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/domain/entity/portfolio.dart';
import 'package:runway/features/portfolio/repository/get_portfolio_repository.dart';

class GetPortfolioUseCase {
  final GetPortfolioRepository repository;

  GetPortfolioUseCase(this.repository);

  Future<Either<Failure, List<Portfolio>>> execute() async {
    final result = await repository.getPortfolio();

    return result;
  }
}

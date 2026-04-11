import 'package:dartz/dartz.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/features/portfolio/repository/delete_portfolio_repository.dart';

class DeletePortfolioUsecase {
  final DeletePortfolioRepository repository;

  DeletePortfolioUsecase({required this.repository});

  Future<Either<Failure, void>> execute(String portfolioId) async {
    return await repository.deletePortfolio(portfolioId);
  }
}

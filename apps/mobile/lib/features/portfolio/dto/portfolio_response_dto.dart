import 'package:runway/domain/entity/portfolio.dart';

class PortfolioResponseDto {
  final int portfolioId;
  final String name;
  final int assetCount;
  final int investmentPeriodMonths;
  final String updatedAt;

  PortfolioResponseDto({
    required this.portfolioId,
    required this.name,
    required this.assetCount,
    required this.investmentPeriodMonths,
    required this.updatedAt,
  });

  factory PortfolioResponseDto.fromJson(Map<String, dynamic> json) {
    return PortfolioResponseDto(
      portfolioId: json['portfolioId'] as int,
      name: json['name'] as String,
      assetCount: json['assetCount'] as int,
      investmentPeriodMonths: json['investmentPeriodMonths'] as int,
      updatedAt: json['updatedAt'] as String,
    );
  }
}

extension PortfolioMapper on PortfolioResponseDto {
  Portfolio toModel() {
    return Portfolio(
      id: portfolioId,
      name: name,
      assetCount: assetCount,
      periodMonths: investmentPeriodMonths,
      updatedAt: DateTime.parse(updatedAt),
    );
  }
}

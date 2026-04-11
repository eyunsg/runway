class SimulationInput {
  final Goal goal;
  final List<Asset> assets;

  SimulationInput({required this.goal, required this.assets});

  Map<String, dynamic> toJson() => {
    'goal': goal.toJson(),
    'assets': assets.map((e) => e.toJson()).toList(),
  };
}

class Goal {
  final int investmentPeriodMonths;
  final num targetPortfolioValue;
  final num targetMonthlyDividend;

  Goal({
    required this.investmentPeriodMonths,
    required this.targetPortfolioValue,
    required this.targetMonthlyDividend,
  });

  Map<String, dynamic> toJson() => {
    'investmentPeriodMonths': investmentPeriodMonths,
    'targetPortfolioValue': targetPortfolioValue,
    'targetMonthlyDividend': targetMonthlyDividend,
  };
}

class Asset {
  final String assetName;
  final String assetType;
  final num initialPrice;
  final num expectedAnnualPriceGrowthRate;
  final num initialInvestmentAmount;
  final num monthlyContributionAmount;
  final bool isDividendAsset;

  final num? dividendPerShare;
  final num? expectedAnnualDividendGrowthRate;
  final int? dividendFrequency;
  final bool? isReinvestDividends;

  Asset({
    required this.assetName,
    required this.assetType,
    required this.initialPrice,
    required this.expectedAnnualPriceGrowthRate,
    required this.initialInvestmentAmount,
    required this.monthlyContributionAmount,
    required this.isDividendAsset,
    this.dividendPerShare,
    this.expectedAnnualDividendGrowthRate,
    this.dividendFrequency,
    this.isReinvestDividends,
  });

  Map<String, dynamic> toJson() {
    final map = {
      'assetName': assetName,
      'assetType': assetType,
      'initialPrice': initialPrice,
      'expectedAnnualPriceGrowthRate': expectedAnnualPriceGrowthRate,
      'initialInvestmentAmount': initialInvestmentAmount,
      'monthlyContributionAmount': monthlyContributionAmount,
      'isDividendAsset': isDividendAsset,
    };

    if (isDividendAsset) {
      map.addAll({
        'dividendPerShare': dividendPerShare!,
        'expectedAnnualDividendGrowthRate': expectedAnnualDividendGrowthRate!,
        'dividendFrequency': dividendFrequency!,
        'isReinvestDividends': isReinvestDividends!,
      });
    }

    return map;
  }
}

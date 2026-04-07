// 개별 자산 카드에서 쓸 모델 관리하기 위한 데이터 클래스

class SimulationAsset {
  const SimulationAsset({
    required this.id,
    required this.assetName,
    required this.assetType,
    required this.price,
    required this.amount,
    required this.yield,
    required this.isDividendAsset,
    required this.dividendAmount,
    required this.dividendGrowth,
    required this.dividendPeriod,
    required this.isDividendReinvest,
    required this.monthlyVolatility,
  });

  final String id;
  final String assetName;
  final String assetType;
  final double price;
  final double amount;
  final double yield;
  final bool isDividendAsset;
  final double dividendAmount;
  final double dividendGrowth;
  final String dividendPeriod;
  final bool isDividendReinvest;
  final double monthlyVolatility;
}

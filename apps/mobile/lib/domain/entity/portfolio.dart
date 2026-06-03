class Portfolio {
  final String id;
  final String name;
  final int assetCount;
  final int periodMonths;
  final DateTime updatedAt;

  Portfolio({
    required this.id,
    required this.name,
    required this.assetCount,
    required this.periodMonths,
    required this.updatedAt,
  });
}

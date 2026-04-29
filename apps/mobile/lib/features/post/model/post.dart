class Post {
  final int postId;
  final String authorDisplayName;
  final String portfolioName;
  final int assetCount;
  final int investmentPeriodMonths;
  final DateTime createdAt;
  final int commentCount;

  const Post({
    required this.postId,
    required this.authorDisplayName,
    required this.portfolioName,
    required this.assetCount,
    required this.investmentPeriodMonths,
    required this.createdAt,
    required this.commentCount,
  });
}

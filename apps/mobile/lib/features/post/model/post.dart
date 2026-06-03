class Post {
  final String postId;
  final String content;
  final String authorDisplayName;
  final String? portfolioSnapshotId;
  final String portfolioName;
  final int assetCount;
  final int investmentPeriodMonths;
  final DateTime createdAt;
  final int commentCount;

  const Post({
    required this.postId,
    required this.content,
    required this.authorDisplayName,
    this.portfolioSnapshotId,
    required this.portfolioName,
    required this.assetCount,
    required this.investmentPeriodMonths,
    required this.createdAt,
    required this.commentCount,
  });
}

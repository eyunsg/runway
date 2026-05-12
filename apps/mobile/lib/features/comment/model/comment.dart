class Comment {
  final String commentId;
  final String content;
  final String authorDisplayName;
  final DateTime createdAt;

  const Comment({
    required this.commentId,
    required this.content,
    required this.authorDisplayName,
    required this.createdAt,
  });
}

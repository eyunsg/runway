import 'package:runway/features/comment/model/comment.dart';

class CommentResponseDto {
  final String commentId;
  final String content;
  final String authorDisplayName;
  final DateTime createdAt;

  CommentResponseDto({
    required this.commentId,
    required this.content,
    required this.authorDisplayName,
    required this.createdAt,
  });

  factory CommentResponseDto.fromJson(Map<String, dynamic> json) {
    return CommentResponseDto(
      commentId: (json['commentId'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      authorDisplayName: (json['authorDisplayName'] ?? '').toString(),
      createdAt: DateTime.parse((json['createdAt'] ?? '').toString()),
    );
  }

  Comment toModel() {
    return Comment(
      commentId: commentId,
      content: content,
      authorDisplayName: authorDisplayName,
      createdAt: createdAt,
    );
  }
}

class GetCommentsResponseDto {
  final List<CommentResponseDto> comments;

  GetCommentsResponseDto({required this.comments});

  factory GetCommentsResponseDto.fromJson(Map<String, dynamic> json) {
    final raw = json['comments'];
    if (raw is! List) {
      return GetCommentsResponseDto(comments: []);
    }
    return GetCommentsResponseDto(
      comments: raw
          .whereType<Map<String, dynamic>>()
          .map((e) => CommentResponseDto.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

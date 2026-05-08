import 'package:runway/features/post/model/post.dart';

class PostDetailResponseDto {
  final PostDetailDto post;

  PostDetailResponseDto({required this.post});

  factory PostDetailResponseDto.fromJson(Map<String, dynamic> json) {
    final postMap = json['data'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['data'] as Map)
        : Map<String, dynamic>.from(json);

    return PostDetailResponseDto(post: PostDetailDto.fromJson(postMap));
  }
}

class PostDetailDto {
  final String postId;
  final String content;
  final String authorDisplayName;
  final String? portfolioSnapshotId;
  final String? portfolioName;
  final int? assetCount;
  final int? investmentPeriodMonths;
  final String createdAt;
  final int commentCount;

  PostDetailDto({
    required this.postId,
    required this.content,
    required this.authorDisplayName,
    required this.portfolioSnapshotId,
    required this.portfolioName,
    required this.assetCount,
    required this.investmentPeriodMonths,
    required this.createdAt,
    required this.commentCount,
  });

  factory PostDetailDto.fromJson(Map<String, dynamic> json) {
    return PostDetailDto(
      postId: json['postId'] as String,
      content: (json['content'] as String?) ?? '',
      authorDisplayName: (json['authorDisplayName'] as String?) ?? '',
      portfolioSnapshotId: json['portfolioSnapshotId'] as String?,
      portfolioName: json['portfolioName'] as String?,
      assetCount: json['assetCount'] as int?,
      investmentPeriodMonths: json['investmentPeriodMonths'] as int?,
      createdAt: json['createdAt'] as String,
      commentCount: (json['commentCount'] as int?) ?? 0,
    );
  }
}

extension PostDetailMapper on PostDetailDto {
  Post toModel() {
    return Post(
      postId: postId,
      content: content,
      authorDisplayName:
          authorDisplayName.trim().isEmpty || authorDisplayName == '알 수 없는 사용자'
          ? 'displayName'
          : authorDisplayName,
      portfolioName: portfolioName ?? '',
      assetCount: assetCount ?? 0,
      investmentPeriodMonths: investmentPeriodMonths ?? 0,
      createdAt: DateTime.parse(createdAt),
      commentCount: commentCount,
    );
  }
}

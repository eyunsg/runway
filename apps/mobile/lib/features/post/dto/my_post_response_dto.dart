import 'package:runway/features/post/model/post.dart';

class MyPostResponseDto {
  final String postId;
  final String? content;
  final String? authorDisplayName;
  final String? portfolioName;
  final int assetCount;
  final int investmentPeriodMonths;
  final String createdAt;
  final int commentCount;

  MyPostResponseDto({
    required this.postId,
    required this.content,
    required this.authorDisplayName,
    required this.portfolioName,
    required this.assetCount,
    required this.investmentPeriodMonths,
    required this.createdAt,
    required this.commentCount,
  });

  factory MyPostResponseDto.fromJson(Map<String, dynamic> json) {
    return MyPostResponseDto(
      postId: json['postId'] as String,
      content: json['content'] as String?,
      authorDisplayName: json['authorDisplayName'] as String?,
      portfolioName: json['portfolioName'] as String?,
      assetCount: (json['assetCount'] as num?)?.toInt() ?? 0,
      investmentPeriodMonths:
          (json['investmentPeriodMonths'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] as String,
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
    );
  }

  static List<MyPostResponseDto> listFromResponseJson(
    Map<String, dynamic> json,
  ) {
    final root = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final rawPosts = root['posts'];

    if (rawPosts == null) {
      throw const FormatException('"posts" key is missing or null.');
    }

    if (rawPosts is! List) {
      throw const FormatException('"posts" must be a list.');
    }

    return rawPosts
        .map((e) => MyPostResponseDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

extension MyPostMapper on MyPostResponseDto {
  Post toModel() {
    return Post(
      postId: postId,
      content: content ?? '',
      authorDisplayName:
          authorDisplayName == null ||
              authorDisplayName!.trim().isEmpty ||
              authorDisplayName == '알 수 없는 사용자'
          ? 'displayName'
          : authorDisplayName!,
      portfolioName: portfolioName ?? '',
      assetCount: assetCount,
      investmentPeriodMonths: investmentPeriodMonths,
      createdAt: DateTime.parse(createdAt),
      commentCount: commentCount,
    );
  }
}

import 'package:runway/features/post/model/post.dart';

class PostResponseDto {
  final int postId;
  final String authorDisplayName;
  final String portfolioName;
  final int assetCount;
  final int investmentPeriodMonths;
  final String createdAt;
  final int commentCount;

  PostResponseDto({
    required this.postId,
    required this.authorDisplayName,
    required this.portfolioName,
    required this.assetCount,
    required this.investmentPeriodMonths,
    required this.createdAt,
    required this.commentCount,
  });

  factory PostResponseDto.fromJson(Map<String, dynamic> json) {
    return PostResponseDto(
      postId: json['postId'] as int,
      authorDisplayName: json['authorDisplayName'] as String,
      portfolioName: json['portfolioName'] as String,
      assetCount: json['assetCount'] as int,
      investmentPeriodMonths: json['investmentPeriodMonths'] as int,
      createdAt: json['createdAt'] as String,
      commentCount: json['commentCount'] as int,
    );
  }

  static List<PostResponseDto> listFromResponseJson(Map<String, dynamic> json) {
    final rawPosts = json['posts'];
    if (rawPosts == null) {
      throw const FormatException('"posts" key is missing or null.');
    }
    if (rawPosts is! List) {
      throw const FormatException('"posts" must be a list.');
    }
    return rawPosts
        .map((e) => PostResponseDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

extension PostMapper on PostResponseDto {
  Post toModel() {
    return Post(
      postId: postId,
      authorDisplayName: authorDisplayName,
      portfolioName: portfolioName,
      assetCount: assetCount,
      investmentPeriodMonths: investmentPeriodMonths,
      createdAt: DateTime.parse(createdAt),
      commentCount: commentCount,
    );
  }
}

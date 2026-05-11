class UpdatePostRequestDto {
  final String postId;
  final String content;
  final String? portfolioId;
  final bool isPortfolioRemoved;

  const UpdatePostRequestDto({
    required this.postId,
    required this.content,
    required this.portfolioId,
    required this.isPortfolioRemoved,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'portfolioId': isPortfolioRemoved ? null : portfolioId,
    };
  }
}

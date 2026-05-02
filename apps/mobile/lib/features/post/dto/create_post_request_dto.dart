class CreatePostRequestDto {
  final String? portfolioId;
  final String content;

  const CreatePostRequestDto({
    required this.portfolioId,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'content': content};

    if (portfolioId != null) {
      data['portfolioId'] = portfolioId;
    }

    return data;
  }
}

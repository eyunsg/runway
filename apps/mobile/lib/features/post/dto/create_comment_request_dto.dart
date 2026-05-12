class CreateCommentRequestDto {
  final String content;
  const CreateCommentRequestDto({required this.content});

  Map<String, dynamic> toJson() {
    return {'content': content};
  }
}

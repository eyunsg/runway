import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:runway/features/comment/usecase/get_comments_usecase.dart';
import 'package:runway/features/comment/repository/get_comments_repository.dart';
import 'package:runway/features/comment/model/comment.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/core/error/validation_failure.dart';

class MockCommentRepository extends Mock implements GetCommentsRepository {}

void main() {
  late GetCommentsUsecase usecase;
  late MockCommentRepository mockRepository;

  const testPostId = 'post-1';

  final dummyComments = <Comment>[
    Comment(
      commentId: 'c1',
      content: '첫 번째 댓글',
      authorDisplayName: 'user1',
      createdAt: DateTime(2024, 1, 1),
    ),
  ];

  setUp(() {
    mockRepository = MockCommentRepository();
    usecase = GetCommentsUsecase(mockRepository);
  });

  group('GetCommentsUsecase', () {
    test('성공 케이스: repository 결과 그대로 반환', () async {
      when(
        () => mockRepository.getComments(testPostId),
      ).thenAnswer((_) async => Right(dummyComments));

      final result = await usecase.execute(testPostId);

      verify(() => mockRepository.getComments(testPostId)).called(1);
      expect(result.isRight(), true);

      result.fold((_) => fail('Right가 와야 함'), (comments) {
        expect(comments, dummyComments);
        expect(comments.first.commentId, 'c1');
        expect(comments.first.authorDisplayName, 'user1');
      });
    });

    test('실패 케이스: repository Failure 그대로 반환', () async {
      const errorMsg = 'server error';

      when(
        () => mockRepository.getComments(testPostId),
      ).thenAnswer((_) async => Left(ServerFailure(errorMsg)));

      final result = await usecase.execute(testPostId);

      verify(() => mockRepository.getComments(testPostId)).called(1);
      expect(result.isLeft(), true);

      result.fold(
        (failure) => expect(failure.message, errorMsg),
        (_) => fail('Left가 와야 함'),
      );
    });

    test('실패 케이스: postId가 비어 있으면 validation failure 반환', () async {
      final result = await usecase.execute('');

      verifyNever(() => mockRepository.getComments(any()));
      expect(result.isLeft(), true);

      result.fold((failure) {
        expect(failure, isA<PortfolioValidationFailure>());
        expect(failure.message, '유효한 게시물 ID가 필요합니다.');
      }, (_) => fail('Left가 와야 함'));
    });

    test('실패 케이스: postId가 공백만 있으면 validation failure 반환', () async {
      final result = await usecase.execute('   ');

      verifyNever(() => mockRepository.getComments(any()));
      expect(result.isLeft(), true);

      result.fold((failure) {
        expect(failure, isA<PortfolioValidationFailure>());
        expect(failure.message, '유효한 게시물 ID가 필요합니다.');
      }, (_) => fail('Left가 와야 함'));
    });
  });
}

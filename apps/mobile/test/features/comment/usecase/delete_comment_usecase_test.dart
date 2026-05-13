import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/core/error/validation_failure.dart';
import 'package:runway/features/comment/repository/delete_comment_repository.dart';
import 'package:runway/features/comment/usecase/delete_comment_usecase.dart';

class MockDeleteCommentRepository extends Mock
    implements DeleteCommentRepository {}

void main() {
  late DeleteCommentUsecase usecase;
  late MockDeleteCommentRepository mockRepository;

  setUp(() {
    mockRepository = MockDeleteCommentRepository();
    usecase = DeleteCommentUsecase(mockRepository);
  });

  group('DeleteCommentUsecase', () {
    test('commentId가 빈 문자열이면 PortfolioValidationFailure를 반환한다', () async {
      final result = await usecase.execute('');

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<PortfolioValidationFailure>());
        expect(failure.message, '유효한 댓글 ID가 필요합니다.');
      }, (_) => fail('Left가 반환되어야 합니다.'));

      verifyNever(() => mockRepository.deleteComment(any()));
    });

    test('commentId가 공백만 있으면 PortfolioValidationFailure를 반환한다', () async {
      final result = await usecase.execute('   ');

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<PortfolioValidationFailure>());
        expect(failure.message, '유효한 댓글 ID가 필요합니다.');
      }, (_) => fail('Left가 반환되어야 합니다.'));

      verifyNever(() => mockRepository.deleteComment(any()));
    });

    test('유효한 commentId면 repository.deleteComment를 호출하고 성공 결과를 반환한다', () async {
      const commentId = 'comment-123';

      when(
        () => mockRepository.deleteComment(commentId),
      ).thenAnswer((_) async => const Right(true));

      final result = await usecase.execute(commentId);

      expect(result, const Right(true));
      verify(() => mockRepository.deleteComment(commentId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('유효한 commentId면 repository의 실패 결과를 그대로 반환한다', () async {
      const commentId = 'comment-123';
      const failure = ServerFailure('댓글 삭제 실패');

      when(
        () => mockRepository.deleteComment(commentId),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase.execute(commentId);

      expect(result, const Left(failure));
      verify(() => mockRepository.deleteComment(commentId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}

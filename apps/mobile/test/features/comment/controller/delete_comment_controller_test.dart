import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/features/comment/controller/delete_comment_controller.dart';
import 'package:runway/features/comment/usecase/delete_comment_usecase.dart';

class MockDeleteCommentUsecase extends Mock implements DeleteCommentUsecase {}

void main() {
  late DeleteCommentController controller;
  late MockDeleteCommentUsecase mockUsecase;

  setUp(() {
    mockUsecase = MockDeleteCommentUsecase();
    controller = DeleteCommentController(useCase: mockUsecase);
  });

  group('DeleteCommentController', () {
    test('초기 상태는 기본값이다', () {
      expect(controller.state.isSubmitting, false);
      expect(controller.state.isSuccess, false);
      expect(controller.state.error, null);
    });

    test('deleteComment 성공 시 state가 success로 변경된다', () async {
      const commentId = 'comment-123';

      when(
        () => mockUsecase.execute(commentId),
      ).thenAnswer((_) async => const Right(true));

      final future = controller.deleteComment(commentId: commentId);

      expect(controller.state.isSubmitting, true);
      expect(controller.state.isSuccess, false);
      expect(controller.state.error, null);

      await future;

      expect(controller.state.isSubmitting, false);
      expect(controller.state.isSuccess, true);
      expect(controller.state.error, null);

      verify(() => mockUsecase.execute(commentId)).called(1);
      verifyNoMoreInteractions(mockUsecase);
    });

    test('deleteComment 실패 시 state에 error가 반영된다', () async {
      const commentId = 'comment-123';
      const failure = ServerFailure('댓글 삭제 실패');

      when(
        () => mockUsecase.execute(commentId),
      ).thenAnswer((_) async => const Left(failure));

      final future = controller.deleteComment(commentId: commentId);

      expect(controller.state.isSubmitting, true);
      expect(controller.state.isSuccess, false);
      expect(controller.state.error, null);

      await future;

      expect(controller.state.isSubmitting, false);
      expect(controller.state.isSuccess, false);
      expect(controller.state.error, '댓글 삭제 실패');

      verify(() => mockUsecase.execute(commentId)).called(1);
      verifyNoMoreInteractions(mockUsecase);
    });

    test('deleteComment 실패 시 AuthFailure는 사용자 메시지로 변환된다', () async {
      const commentId = 'comment-123';
      const failure = AuthFailure('raw auth error');

      when(
        () => mockUsecase.execute(commentId),
      ).thenAnswer((_) async => const Left(failure));

      await controller.deleteComment(commentId: commentId);

      expect(controller.state.isSubmitting, false);
      expect(controller.state.isSuccess, false);
      expect(controller.state.error, '로그인이 필요합니다.');

      verify(() => mockUsecase.execute(commentId)).called(1);
      verifyNoMoreInteractions(mockUsecase);
    });

    test('clearError 호출 시 error가 null로 초기화된다', () async {
      const commentId = 'comment-123';
      const failure = ServerFailure('댓글 삭제 실패');

      when(
        () => mockUsecase.execute(commentId),
      ).thenAnswer((_) async => const Left(failure));

      await controller.deleteComment(commentId: commentId);
      expect(controller.state.error, '댓글 삭제 실패');

      controller.clearError();

      expect(controller.state.error, null);
    });

    test('clearSuccess 호출 시 isSuccess가 false로 변경된다', () async {
      const commentId = 'comment-123';

      when(
        () => mockUsecase.execute(commentId),
      ).thenAnswer((_) async => const Right(true));

      await controller.deleteComment(commentId: commentId);
      expect(controller.state.isSuccess, true);

      controller.clearSuccess();

      expect(controller.state.isSuccess, false);
    });

    test('reset 호출 시 초기 상태로 돌아간다', () async {
      const commentId = 'comment-123';
      const failure = ServerFailure('댓글 삭제 실패');

      when(
        () => mockUsecase.execute(commentId),
      ).thenAnswer((_) async => const Left(failure));

      await controller.deleteComment(commentId: commentId);
      expect(controller.state.error, isNotNull);

      controller.reset();

      expect(controller.state.isSubmitting, false);
      expect(controller.state.isSuccess, false);
      expect(controller.state.error, null);
    });
  });
}

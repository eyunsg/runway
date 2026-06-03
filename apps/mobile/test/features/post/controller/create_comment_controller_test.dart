import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/features/post/controller/create_comment_controller.dart';
import 'package:runway/features/post/usecase/create_comment_usecase.dart';

class MockCreateCommentUsecase extends Mock implements CreateCommentUsecase {}

void main() {
  late MockCreateCommentUsecase useCase;
  late CreateCommentController controller;

  setUp(() {
    useCase = MockCreateCommentUsecase();
    controller = CreateCommentController(useCase: useCase);
  });

  group('CreateCommentController', () {
    test('초기 상태는 기본값이다', () {
      expect(controller.state.content, '');
      expect(controller.state.isSubmitting, false);
      expect(controller.state.isSuccess, false);
      expect(controller.state.error, null);
    });

    test('updateContent 시 content가 반영되고 error/isSuccess가 초기화된다', () {
      controller.updateContent('테스트 댓글');

      expect(controller.state.content, '테스트 댓글');
      expect(controller.state.error, null);
      expect(controller.state.isSuccess, false);
    });

    test('clearError 시 error가 null이 된다', () async {
      when(
        () => useCase.execute(
          postId: any(named: 'postId'),
          content: any(named: 'content'),
        ),
      ).thenAnswer((_) async => const Left(ServerFailure('서버 원본 메시지')));

      controller.updateContent('실패 댓글');
      await controller.submitComment(postId: 'post-1');

      expect(controller.state.error, '서버 원본 메시지');

      controller.clearError();

      expect(controller.state.error, null);
    });

    test('clearSuccess 시 isSuccess가 false가 된다', () async {
      when(
        () => useCase.execute(
          postId: any(named: 'postId'),
          content: any(named: 'content'),
        ),
      ).thenAnswer((_) async => const Right(null));

      controller.updateContent('성공 댓글');
      await controller.submitComment(postId: 'post-1');

      expect(controller.state.isSuccess, true);

      controller.clearSuccess();

      expect(controller.state.isSuccess, false);
    });

    test('reset 시 상태가 초기값으로 돌아간다', () {
      controller.updateContent('초기화 전 댓글');

      controller.reset();

      expect(controller.state.content, '');
      expect(controller.state.isSubmitting, false);
      expect(controller.state.isSuccess, false);
      expect(controller.state.error, null);
    });

    test('submitComment 성공 시 로딩 후 성공 상태가 된다', () async {
      when(
        () => useCase.execute(
          postId: any(named: 'postId'),
          content: any(named: 'content'),
        ),
      ).thenAnswer((_) async => const Right(null));

      controller.updateContent('댓글 등록 테스트');

      final states = <dynamic>[];
      controller.addListener(states.add);

      await controller.submitComment(postId: 'post-1');

      verify(
        () => useCase.execute(postId: 'post-1', content: '댓글 등록 테스트'),
      ).called(1);

      expect(states.any((state) => state.isSubmitting == true), true);

      expect(controller.state.isSubmitting, false);
      expect(controller.state.isSuccess, true);
      expect(controller.state.error, null);
      expect(controller.state.content, '');
    });

    test('submitComment 실패 시 로딩 후 에러 상태가 된다', () async {
      when(
        () => useCase.execute(
          postId: any(named: 'postId'),
          content: any(named: 'content'),
        ),
      ).thenAnswer((_) async => const Left(ServerFailure('서버 원본 메시지')));

      controller.updateContent('댓글 실패 테스트');

      final states = <dynamic>[];
      controller.addListener(states.add);

      await controller.submitComment(postId: 'post-1');

      verify(
        () => useCase.execute(postId: 'post-1', content: '댓글 실패 테스트'),
      ).called(1);

      expect(states.any((state) => state.isSubmitting == true), true);

      expect(controller.state.isSubmitting, false);
      expect(controller.state.isSuccess, false);
      expect(controller.state.error, '서버 원본 메시지');
      expect(controller.state.content, '댓글 실패 테스트');
    });
  });
}

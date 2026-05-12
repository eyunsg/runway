import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:runway/features/comment/controller/get_comments_controller.dart';
import 'package:runway/features/comment/types/get_comments_state.dart';
import 'package:runway/features/comment/usecase/get_comments_usecase.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/features/comment/model/comment.dart';

class MockGetCommentsUsecase extends Mock implements GetCommentsUsecase {}

void main() {
  late GetCommentsController controller;
  late MockGetCommentsUsecase mockUsecase;

  const testPostId = 'post-1';

  final dummyComments = <Comment>[
    Comment(
      commentId: 'c1',
      content: '첫 번째 댓글',
      authorDisplayName: 'user1',
      createdAt: DateTime(2024, 1, 1),
    ),
    Comment(
      commentId: 'c2',
      content: '두 번째 댓글',
      authorDisplayName: 'user2',
      createdAt: DateTime(2024, 1, 2),
    ),
  ];

  setUp(() {
    mockUsecase = MockGetCommentsUsecase();
    controller = GetCommentsController(useCase: mockUsecase);
  });

  group('fetchComments', () {
    test('성공 시 loading → success 상태 + 댓글 리스트 세팅', () async {
      when(
        () => mockUsecase.execute(testPostId),
      ).thenAnswer((_) async => Right(dummyComments));

      final states = <GetCommentsState>[];
      controller.addListener((state) => states.add(state));

      await controller.fetchComments(testPostId);

      verify(() => mockUsecase.execute(testPostId)).called(1);

      expect(states.length, 3);

      expect(states[0].isLoading, false);
      expect(states[0].comments, isEmpty);
      expect(states[0].error, isNull);
      expect(states[0].isSuccess, false);

      expect(states[1].isLoading, true);
      expect(states[1].comments, isEmpty);
      expect(states[1].error, isNull);
      expect(states[1].isSuccess, false);

      expect(states[2].isLoading, false);
      expect(states[2].isSuccess, true);
      expect(states[2].error, isNull);
      expect(states[2].comments.length, 2);
      expect(states[2].comments[0].commentId, 'c1');
      expect(states[2].comments[0].authorDisplayName, 'user1');
      expect(states[2].comments[0].content, '첫 번째 댓글');
      expect(states[2].comments[0].createdAt, DateTime(2024, 1, 1));
    });

    test('실패 시 error 세팅', () async {
      when(
        () => mockUsecase.execute(testPostId),
      ).thenAnswer((_) async => Left(ServerFailure('server error')));

      final states = <GetCommentsState>[];
      controller.addListener((state) => states.add(state));

      await controller.fetchComments(testPostId);

      verify(() => mockUsecase.execute(testPostId)).called(1);

      expect(states.length, 3);

      expect(states[0].isLoading, false);
      expect(states[0].comments, isEmpty);
      expect(states[0].error, isNull);
      expect(states[0].isSuccess, false);

      expect(states[1].isLoading, true);
      expect(states[1].comments, isEmpty);
      expect(states[1].error, isNull);
      expect(states[1].isSuccess, false);

      expect(states[2].isLoading, false);
      expect(states[2].comments, isEmpty);
      expect(states[2].error, 'server error');
      expect(states[2].isSuccess, false);
    });
  });
}

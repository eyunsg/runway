import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:runway/features/post/controller/get_post_detail_controller.dart';
import 'package:runway/features/post/usecase/get_post_detail_usecase.dart';
import 'package:runway/features/post/types/get_post_detail_state.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/features/post/model/post.dart';

class MockGetPostDetailUsecase extends Mock implements GetPostDetailUsecase {}

void main() {
  late GetPostDetailController controller;
  late MockGetPostDetailUsecase mockUsecase;

  const testPostId = 'post-1';

  final dummyPost = Post(
    postId: testPostId,
    content: 'detail post content',
    authorDisplayName: 'detailUser',
    portfolioSnapshotId: 'snapshot-1',
    portfolioName: 'Detail Portfolio',
    assetCount: 5,
    investmentPeriodMonths: 12,
    createdAt: DateTime(2024, 1, 1),
    commentCount: 3,
  );

  setUp(() {
    mockUsecase = MockGetPostDetailUsecase();
    controller = GetPostDetailController(useCase: mockUsecase);
  });

  group('fetchPostDetail', () {
    test('성공 시 loading → success 상태 + 게시물 세팅', () async {
      when(
        () => mockUsecase.execute(testPostId),
      ).thenAnswer((_) async => Right(dummyPost));

      final states = <GetPostDetailState>[];
      controller.addListener((state) => states.add(state));

      await controller.fetchPostDetail(testPostId);

      verify(() => mockUsecase.execute(testPostId)).called(1);

      expect(states.length, 3);

      expect(states[0].isLoading, false);
      expect(states[0].post, isNull);
      expect(states[0].error, isNull);
      expect(states[0].isSuccess, false);

      expect(states[1].isLoading, true);
      expect(states[1].post, isNull);
      expect(states[1].error, isNull);
      expect(states[1].isSuccess, false);

      expect(states[2].isLoading, false);
      expect(states[2].post, dummyPost);
      expect(states[2].post!.postId, testPostId);
      expect(states[2].post!.authorDisplayName, 'detailUser');
      expect(states[2].post!.portfolioSnapshotId, 'snapshot-1');
      expect(states[2].post!.portfolioName, 'Detail Portfolio');
      expect(states[2].post!.assetCount, 5);
      expect(states[2].post!.investmentPeriodMonths, 12);
      expect(states[2].post!.createdAt, DateTime(2024, 1, 1));
      expect(states[2].post!.commentCount, 3);
      expect(states[2].post!.content, 'detail post content');
      expect(states[2].error, isNull);
      expect(states[2].isSuccess, true);
    });

    test('실패 시 error 세팅', () async {
      when(
        () => mockUsecase.execute(testPostId),
      ).thenAnswer((_) async => Left(ServerFailure('server error')));

      final states = <GetPostDetailState>[];
      controller.addListener((state) => states.add(state));

      await controller.fetchPostDetail(testPostId);

      verify(() => mockUsecase.execute(testPostId)).called(1);

      expect(states.length, 3);

      expect(states[0].isLoading, false);
      expect(states[0].post, isNull);
      expect(states[0].error, isNull);
      expect(states[0].isSuccess, false);

      expect(states[1].isLoading, true);
      expect(states[1].post, isNull);
      expect(states[1].error, isNull);
      expect(states[1].isSuccess, false);

      expect(states[2].isLoading, false);
      expect(states[2].post, isNull);
      expect(states[2].error, 'server error');
      expect(states[2].isSuccess, false);
    });
  });
}

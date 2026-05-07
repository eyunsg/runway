import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:runway/features/post/controller/get_my_post_controller.dart';
import 'package:runway/features/post/usecase/get_my_post_usecase.dart';
import 'package:runway/features/post/types/get_my_post_state.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/features/post/model/post.dart';

class MockGetMyPostUsecase extends Mock implements GetMyPostUsecase {}

void main() {
  late GetMyPostController controller;
  late MockGetMyPostUsecase mockUsecase;

  Post createDummyPost(int i) {
    return Post(
      postId: '$i',
      content: 'my post content_$i',
      authorDisplayName: 'myUser_$i',
      portfolioName: 'My Portfolio_$i',
      assetCount: 5,
      investmentPeriodMonths: 12,
      createdAt: DateTime(2024, 1, 1),
      commentCount: 3,
    );
  }

  final dummyList = List.generate(10, (i) => createDummyPost(i));

  setUp(() {
    mockUsecase = MockGetMyPostUsecase();
    controller = GetMyPostController(useCase: mockUsecase);
  });

  group('fetchMyPost', () {
    test('성공 시 loading → success 상태 + 리스트 세팅', () async {
      when(
        () => mockUsecase.execute(),
      ).thenAnswer((_) async => Right(dummyList));

      final states = <GetMyPostState>[];
      controller.addListener((state) => states.add(state));

      await controller.fetchMyPost();

      verify(() => mockUsecase.execute()).called(1);

      expect(states.length, 3);

      expect(states[0].isLoading, false);
      expect(states[0].posts, []);
      expect(states[0].error, isNull);

      expect(states[1].isLoading, true);
      expect(states[1].posts, []);
      expect(states[1].error, isNull);
      expect(states[1].hasMore, false);

      expect(states[2].isLoading, false);
      expect(states[2].posts, dummyList);
      expect(states[2].posts.first.postId, '0');
      expect(states[2].posts.first.authorDisplayName, 'myUser_0');
      expect(states[2].posts.first.portfolioName, 'My Portfolio_0');
      expect(states[2].posts.first.assetCount, 5);
      expect(states[2].posts.first.investmentPeriodMonths, 12);
      expect(states[2].posts.first.createdAt, DateTime(2024, 1, 1));
      expect(states[2].posts.first.commentCount, 3);
      expect(states[2].posts.first.content, 'my post content_0');
      expect(states[2].error, isNull);
      expect(states[2].hasMore, false);
    });

    test('실패 시 error 세팅', () async {
      when(
        () => mockUsecase.execute(),
      ).thenAnswer((_) async => Left(ServerFailure('server error')));

      final states = <GetMyPostState>[];
      controller.addListener((state) => states.add(state));

      await controller.fetchMyPost();

      verify(() => mockUsecase.execute()).called(1);

      expect(states.length, 3);

      expect(states[0].isLoading, false);
      expect(states[0].error, isNull);

      expect(states[1].isLoading, true);
      expect(states[1].posts, []);
      expect(states[1].error, isNull);
      expect(states[1].hasMore, false);

      expect(states[2].isLoading, false);
      expect(states[2].posts, []);
      expect(states[2].error, 'server error');
      expect(states[2].hasMore, false);
    });
  });
}

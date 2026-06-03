import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:runway/features/post/controller/get_recent_post_controller.dart';
import 'package:runway/features/post/usecase/get_recent_post_usecase.dart';
import 'package:runway/features/post/types/get_post_state.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/core/error/failure_extension.dart';
import 'package:runway/features/post/model/post.dart';

class MockGetRecentPostUsecase extends Mock implements GetRecentPostUsecase {}

void main() {
  late GetRecentPostController controller;
  late MockGetRecentPostUsecase mockUsecase;

  Post createDummyPost(int i) {
    return Post(
      postId: '$i',
      content: 'test content_$i',
      authorDisplayName: 'testUser_$i',
      portfolioName: 'Growth Portfolio_$i',
      assetCount: 5,
      investmentPeriodMonths: 12,
      createdAt: DateTime(2024, 1, 1),
      commentCount: 3,
    );
  }

  final dummyList = List.generate(10, (i) => createDummyPost(i));

  setUp(() {
    mockUsecase = MockGetRecentPostUsecase();
    controller = GetRecentPostController(useCase: mockUsecase);
  });

  group('fetchRecentPost', () {
    test('성공 시 loading → success 상태 + 3개 이하 리스트 세팅', () async {
      when(
        () => mockUsecase.execute(),
      ).thenAnswer((_) async => Right(dummyList.take(3).toList()));

      final states = <GetPostState>[];
      controller.addListener((state) => states.add(state));

      await controller.fetchRecentPost();

      verify(() => mockUsecase.execute()).called(1);

      expect(states.length, 3);

      expect(states[1].isLoading, true);
      expect(states[1].posts, []);

      expect(states[2].isLoading, false);
      expect(states[2].isSuccess, true);
      expect(states[2].posts.length, 3);

      expect(states[2].posts.first.postId, '0');
      expect(states[2].posts.first.authorDisplayName, 'testUser_0');
      expect(states[2].error, isNull);
    });

    test('실패 시 error 세팅', () async {
      const failure = ServerFailure('server error');
      when(
        () => mockUsecase.execute(),
      ).thenAnswer((_) async => const Left(failure));

      final states = <GetPostState>[];
      controller.addListener((state) => states.add(state));

      await controller.fetchRecentPost();

      expect(states.length, 3);
      expect(states[1].isLoading, true);
      expect(states[2].isLoading, false);
      expect(states[2].error, failure.toMessage());
    });
  });
}

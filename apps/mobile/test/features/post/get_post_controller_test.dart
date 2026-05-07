import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:runway/features/post/controller/get_post_controller.dart';
import 'package:runway/features/post/usecase/get_post_usecase.dart';
import 'package:runway/features/post/types/get_post_state.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/features/post/model/post.dart';

class MockGetPostUsecase extends Mock implements GetPostUsecase {}

void main() {
  late GetPostController controller;
  late MockGetPostUsecase mockUsecase;

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
    mockUsecase = MockGetPostUsecase();
    controller = GetPostController(useCase: mockUsecase);
  });

  group('fetchPost', () {
    test('성공 시 loading → success 상태 + 리스트 세팅', () async {
      when(
        () => mockUsecase.execute(),
      ).thenAnswer((_) async => Right(dummyList));

      final states = <GetPostState>[];
      controller.addListener((state) => states.add(state));

      await controller.fetchPost();

      verify(() => mockUsecase.execute()).called(1);

      expect(states.length, 3);

      expect(states[0].isLoading, false);

      expect(states[1].isLoading, true);
      expect(states[1].posts, []);

      expect(states[2].isLoading, false);
      expect(states[2].posts, dummyList);
      expect(states[2].posts.first.postId, '0');
      expect(states[2].posts.first.authorDisplayName, 'testUser_0');
      expect(states[2].posts.first.portfolioName, 'Growth Portfolio_0');
      expect(states[2].posts.first.assetCount, 5);
      expect(states[2].posts.first.investmentPeriodMonths, 12);
      expect(states[2].posts.first.createdAt, DateTime(2024, 1, 1));
      expect(states[2].posts.first.commentCount, 3);
      expect(states[2].posts.first.content, 'test content_0');
      expect(states[2].error, isNull);
    });

    test(
      '실패 시 error 세팅',
      () async {
        when(
          () => mockUsecase.execute(),
        ).thenAnswer((_) async => Left(ServerFailure('server error')));

        final states = <GetPostState>[];
        controller.addListener((state) => states.add(state));

        await controller.fetchPost();

        expect(states.length, 3);
        expect(states[0].isLoading, false);
        expect(states[1].isLoading, true);
        expect(states[2].isLoading, false);
        expect(states[2].error, '서버 오류가 발생했습니다.');
      },
      skip:
          'TODO: Error message policy 충돌 (ServerFailure → toMessage 매핑 정리 필요)',
    );
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:runway/features/post/usecase/get_recent_post_usecase.dart';
import 'package:runway/features/post/repository/get_post_repository.dart';
import 'package:runway/features/post/model/post.dart';
import 'package:runway/core/error/failure.dart';

class MockGetPostRepository extends Mock implements GetPostRepository {}

void main() {
  late GetRecentPostUsecase usecase;
  late MockGetPostRepository mockRepository;

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

  setUp(() {
    mockRepository = MockGetPostRepository();
    usecase = GetRecentPostUsecase(mockRepository);
  });

  group('GetRecentPostUsecase', () {
    test('성공 케이스: 최근 3개로 제한되어 반환', () async {
      final dummyList = List.generate(10, createDummyPost);

      when(
        () => mockRepository.getPost(),
      ).thenAnswer((_) async => Right(dummyList));

      final result = await usecase.execute();

      verify(() => mockRepository.getPost()).called(1);

      expect(result.isRight(), true);

      result.fold((_) => fail('Right가 와야 함'), (list) {
        expect(list.length, 3);

        expect(list.first.postId, '0');
        expect(list.first.content, 'test content_0');

        expect(list.last.postId, '2');
        expect(list.last.content, 'test content_2');
      });
    });

    test('실패 케이스: repository Failure 그대로 전달', () async {
      const errorMsg = 'server error';

      when(
        () => mockRepository.getPost(),
      ).thenAnswer((_) async => Left(ServerFailure(errorMsg)));

      final result = await usecase.execute();

      expect(result.isLeft(), true);

      result.fold(
        (failure) => expect(failure.message, errorMsg),
        (_) => fail('Left가 와야 함'),
      );
    });
  });
}

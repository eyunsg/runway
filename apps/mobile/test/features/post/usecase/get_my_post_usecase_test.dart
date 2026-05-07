import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:runway/features/post/usecase/get_my_post_usecase.dart';
import 'package:runway/features/post/repository/get_my_post_repository.dart';
import 'package:runway/features/post/model/post.dart';
import 'package:runway/core/error/failure.dart';

class MockGetMyPostRepository extends Mock implements GetMyPostRepository {}

void main() {
  late GetMyPostUsecase usecase;
  late MockGetMyPostRepository mockRepository;

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

  setUp(() {
    mockRepository = MockGetMyPostRepository();
    usecase = GetMyPostUsecase(mockRepository);
  });

  group('GetMyPostUsecase', () {
    test('성공 케이스: repository 결과 그대로 반환', () async {
      final dummyList = List.generate(10, createDummyPost);

      when(
        () => mockRepository.getMyPost(),
      ).thenAnswer((_) async => Right(dummyList));

      final result = await usecase.execute();

      verify(() => mockRepository.getMyPost()).called(1);

      expect(result.isRight(), true);

      result.fold((_) => fail('Right가 와야 함'), (list) {
        expect(list.length, 10);
        expect(list, dummyList);

        expect(list.first.postId, '0');
        expect(list.first.content, 'my post content_0');
        expect(list.first.authorDisplayName, 'myUser_0');
        expect(list.first.portfolioName, 'My Portfolio_0');
        expect(list.first.assetCount, 5);
        expect(list.first.investmentPeriodMonths, 12);
        expect(list.first.createdAt, DateTime(2024, 1, 1));
        expect(list.first.commentCount, 3);
      });
    });

    test('실패 케이스: repository Failure 그대로 반환', () async {
      const errorMsg = 'server error';

      when(
        () => mockRepository.getMyPost(),
      ).thenAnswer((_) async => Left(ServerFailure(errorMsg)));

      final result = await usecase.execute();

      verify(() => mockRepository.getMyPost()).called(1);

      expect(result.isLeft(), true);

      result.fold(
        (failure) => expect(failure.message, errorMsg),
        (_) => fail('Left가 와야 함'),
      );
    });
  });
}

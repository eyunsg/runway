import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:runway/features/post/usecase/get_post_usecase.dart';
import 'package:runway/features/post/repository/get_post_repository.dart';
import 'package:runway/features/post/model/post.dart';
import 'package:runway/core/error/failure.dart';

class MockGetPostRepository extends Mock implements GetPostRepository {}

void main() {
  late GetPostUsecase usecase;
  late MockGetPostRepository mockRepository;

  Post createDummyPost(int i) {
    return Post(
      postId: i,
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
    usecase = GetPostUsecase(mockRepository);
  });

  group('GetPostUsecase', () {
    test('성공 케이스: repository 결과 그대로 반환', () async {
      final dummyList = List.generate(10, createDummyPost);

      when(
        () => mockRepository.getPost(),
      ).thenAnswer((_) async => Right(dummyList));

      final result = await usecase.execute();

      verify(() => mockRepository.getPost()).called(1);

      expect(result.isRight(), true);

      result.fold((_) => fail('Right가 와야 함'), (list) {
        expect(list.length, 10);
        expect(list, dummyList);
      });
    });

    test('실패 케이스: repository Failure 그대로 반환', () async {
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

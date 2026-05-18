import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/features/post/repository/delete_post_repository.dart';
import 'package:runway/features/post/usecase/delete_post_usecase.dart';

class MockDeletePostRepository extends Mock implements DeletePostRepository {}

void main() {
  late DeletePostUsecase usecase;
  late MockDeletePostRepository mockRepository;

  const testPostId = 'test-post-id';

  setUp(() {
    mockRepository = MockDeletePostRepository();
    usecase = DeletePostUsecase(repository: mockRepository);
  });

  group('DeletePostUsecase', () {
    test('성공 케이스: repository 결과를 그대로 반환', () async {
      when(
        () => mockRepository.deletePost(testPostId),
      ).thenAnswer((_) async => const Right(null));

      final result = await usecase.execute(testPostId);

      verify(() => mockRepository.deletePost(testPostId)).called(1);
      expect(result.isRight(), true);
    });

    test('실패 케이스: repository Failure를 그대로 반환', () async {
      const errorMsg = 'server error';

      when(
        () => mockRepository.deletePost(testPostId),
      ).thenAnswer((_) async => Left(ServerFailure(errorMsg)));

      final result = await usecase.execute(testPostId);

      verify(() => mockRepository.deletePost(testPostId)).called(1);

      expect(result.isLeft(), true);

      result.fold(
        (failure) => expect(failure.message, errorMsg),
        (_) => fail('Left가 와야 함'),
      );
    });
  });
}

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/features/post/dto/create_post_request_dto.dart';
import 'package:runway/features/post/repository/create_post_repository.dart';
import 'package:runway/features/post/usecase/create_post_usecase.dart';

class MockCreatePostRepository extends Mock implements CreatePostRepository {}

class CreatePostRequestDtoFake extends Fake implements CreatePostRequestDto {}

void main() {
  late MockCreatePostRepository repository;
  late CreatePostUseCase useCase;

  setUpAll(() {
    registerFallbackValue(CreatePostRequestDtoFake());
  });

  setUp(() {
    repository = MockCreatePostRepository();
    useCase = CreatePostUseCase(repository);
  });

  group('CreatePostUseCase', () {
    test('content가 비어있으면 ServerFailure를 반환하고 repository를 호출하지 않는다', () async {
      final result = await useCase.execute(content: '   ', portfolioId: null);

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.message, '게시물 내용을 입력해주세요.');
      }, (_) => fail('Left가 반환되어야 한다'));

      verifyNever(() => repository.createPost(any()));
    });

    test(
      'content가 5000자를 초과하면 ServerFailure를 반환하고 repository를 호출하지 않는다',
      () async {
        final tooLongContent = 'a' * 5001;

        final result = await useCase.execute(
          content: tooLongContent,
          portfolioId: null,
        );

        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, '게시물 내용은 5000자 이내여야 합니다.');
        }, (_) => fail('Left가 반환되어야 한다'));

        verifyNever(() => repository.createPost(any()));
      },
    );

    test('portfolioId가 null이어도 repository 호출을 허용한다', () async {
      when(
        () => repository.createPost(any()),
      ).thenAnswer((_) async => const Right(null));

      final result = await useCase.execute(content: '내용입니다', portfolioId: null);

      expect(result, const Right<Failure, void>(null));

      final captured =
          verify(() => repository.createPost(captureAny())).captured.single
              as CreatePostRequestDto;

      expect(captured.content, '내용입니다');
      expect(captured.portfolioId, null);
    });

    test('portfolioId가 있으면 trim 후 repository에 전달한다', () async {
      when(
        () => repository.createPost(any()),
      ).thenAnswer((_) async => const Right(null));

      final result = await useCase.execute(
        content: '  내용입니다  ',
        portfolioId: '  portfolio-123  ',
      );

      expect(result, const Right<Failure, void>(null));

      final captured =
          verify(() => repository.createPost(captureAny())).captured.single
              as CreatePostRequestDto;

      expect(captured.content, '내용입니다');
      expect(captured.portfolioId, 'portfolio-123');
    });

    test('portfolioId가 공백이면 null로 정규화해서 repository에 전달한다', () async {
      when(
        () => repository.createPost(any()),
      ).thenAnswer((_) async => const Right(null));

      final result = await useCase.execute(
        content: '정상 내용',
        portfolioId: '   ',
      );

      expect(result, const Right<Failure, void>(null));

      final captured =
          verify(() => repository.createPost(captureAny())).captured.single
              as CreatePostRequestDto;

      expect(captured.content, '정상 내용');
      expect(captured.portfolioId, null);
    });
  });
}

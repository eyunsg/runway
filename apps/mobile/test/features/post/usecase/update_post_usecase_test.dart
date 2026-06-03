import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:runway/core/error/failure.dart';
import 'package:runway/features/post/dto/update_post_request_dto.dart';
import 'package:runway/features/post/repository/update_post_repository.dart';
import 'package:runway/features/post/usecase/update_post_usecase.dart';

class MockUpdatePostRepository extends Mock implements UpdatePostRepository {}

void main() {
  late UpdatePostUsecase usecase;
  late MockUpdatePostRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(
      const UpdatePostRequestDto(
        postId: '',
        content: '',
        portfolioId: null,
        isPortfolioRemoved: false,
      ),
    );
  });

  setUp(() {
    mockRepository = MockUpdatePostRepository();
    usecase = UpdatePostUsecase(mockRepository);
  });

  group('UpdatePostUsecase', () {
    test('성공 케이스: trim 후 repository 결과를 그대로 반환', () async {
      UpdatePostRequestDto? capturedDto;

      when(() => mockRepository.updatePost(any())).thenAnswer((
        invocation,
      ) async {
        capturedDto =
            invocation.positionalArguments.first as UpdatePostRequestDto;
        return const Right(null);
      });

      final result = await usecase.execute(
        postId: ' post-1 ',
        content: ' hello runway ',
        portfolioId: ' portfolio-1 ',
        isPortfolioRemoved: false,
      );

      verify(() => mockRepository.updatePost(any())).called(1);

      expect(result.isRight(), true);
      expect(capturedDto, isNotNull);
      expect(capturedDto!.postId, 'post-1');
      expect(capturedDto!.content, 'hello runway');
      expect(capturedDto!.portfolioId, 'portfolio-1');
      expect(capturedDto!.isPortfolioRemoved, false);
    });

    test('성공 케이스: 빈 portfolioId는 null로 변환', () async {
      UpdatePostRequestDto? capturedDto;

      when(() => mockRepository.updatePost(any())).thenAnswer((
        invocation,
      ) async {
        capturedDto =
            invocation.positionalArguments.first as UpdatePostRequestDto;
        return const Right(null);
      });

      final result = await usecase.execute(
        postId: 'post-1',
        content: 'content',
        portfolioId: '   ',
        isPortfolioRemoved: true,
      );

      verify(() => mockRepository.updatePost(any())).called(1);

      expect(result.isRight(), true);
      expect(capturedDto, isNotNull);
      expect(capturedDto!.postId, 'post-1');
      expect(capturedDto!.content, 'content');
      expect(capturedDto!.portfolioId, isNull);
      expect(capturedDto!.isPortfolioRemoved, true);
    });

    test('실패 케이스: postId가 비어 있으면 ServerFailure 반환', () async {
      final result = await usecase.execute(
        postId: '   ',
        content: 'content',
        portfolioId: 'portfolio-1',
        isPortfolioRemoved: false,
      );

      verifyNever(() => mockRepository.updatePost(any()));

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, '수정할 게시물 ID가 없습니다.'),
        (_) => fail('Left가 와야 함'),
      );
    });

    test('실패 케이스: content가 비어 있으면 ServerFailure 반환', () async {
      final result = await usecase.execute(
        postId: 'post-1',
        content: '   ',
        portfolioId: 'portfolio-1',
        isPortfolioRemoved: false,
      );

      verifyNever(() => mockRepository.updatePost(any()));

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, '게시물 내용을 입력해주세요.'),
        (_) => fail('Left가 와야 함'),
      );
    });

    test('실패 케이스: content가 5000자를 초과하면 ServerFailure 반환', () async {
      final result = await usecase.execute(
        postId: 'post-1',
        content: 'a' * 5001,
        portfolioId: 'portfolio-1',
        isPortfolioRemoved: false,
      );

      verifyNever(() => mockRepository.updatePost(any()));

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, '게시물 내용은 5000자 이내여야 합니다.'),
        (_) => fail('Left가 와야 함'),
      );
    });

    test('실패 케이스: repository Failure를 그대로 반환', () async {
      when(
        () => mockRepository.updatePost(any()),
      ).thenAnswer((_) async => Left(ServerFailure('server error')));

      final result = await usecase.execute(
        postId: 'post-1',
        content: 'content',
        portfolioId: 'portfolio-1',
        isPortfolioRemoved: false,
      );

      verify(() => mockRepository.updatePost(any())).called(1);

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, 'server error'),
        (_) => fail('Left가 와야 함'),
      );
    });
  });
}

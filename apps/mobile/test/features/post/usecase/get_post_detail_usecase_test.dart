import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:runway/features/post/usecase/get_post_detail_usecase.dart';
import 'package:runway/features/post/repository/get_post_detail_repository.dart';
import 'package:runway/features/post/model/post.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/core/error/validation_failure.dart';

class MockGetPostDetailRepository extends Mock
    implements GetPostDetailRepository {}

void main() {
  late GetPostDetailUsecase usecase;
  late MockGetPostDetailRepository mockRepository;

  const testPostId = 'post-1';

  final dummyPost = Post(
    postId: testPostId,
    content: 'detail post content',
    authorDisplayName: 'detailUser',
    portfolioName: 'Detail Portfolio',
    assetCount: 5,
    investmentPeriodMonths: 12,
    createdAt: DateTime(2024, 1, 1),
    commentCount: 3,
  );

  setUp(() {
    mockRepository = MockGetPostDetailRepository();
    usecase = GetPostDetailUsecase(mockRepository);
  });

  group('GetPostDetailUsecase', () {
    test('성공 케이스: repository 결과 그대로 반환', () async {
      when(
        () => mockRepository.getPostDetail(testPostId),
      ).thenAnswer((_) async => Right(dummyPost));

      final result = await usecase.execute(testPostId);

      verify(() => mockRepository.getPostDetail(testPostId)).called(1);

      expect(result.isRight(), true);

      result.fold((_) => fail('Right가 와야 함'), (post) {
        expect(post, dummyPost);
        expect(post.postId, testPostId);
        expect(post.content, 'detail post content');
        expect(post.authorDisplayName, 'detailUser');
        expect(post.portfolioName, 'Detail Portfolio');
        expect(post.assetCount, 5);
        expect(post.investmentPeriodMonths, 12);
        expect(post.createdAt, DateTime(2024, 1, 1));
        expect(post.commentCount, 3);
      });
    });

    test('실패 케이스: repository Failure 그대로 반환', () async {
      const errorMsg = 'server error';

      when(
        () => mockRepository.getPostDetail(testPostId),
      ).thenAnswer((_) async => Left(ServerFailure(errorMsg)));

      final result = await usecase.execute(testPostId);

      verify(() => mockRepository.getPostDetail(testPostId)).called(1);

      expect(result.isLeft(), true);

      result.fold(
        (failure) => expect(failure.message, errorMsg),
        (_) => fail('Left가 와야 함'),
      );
    });

    test('실패 케이스: postId가 비어 있으면 validation failure 반환', () async {
      final result = await usecase.execute('');

      verifyNever(() => mockRepository.getPostDetail(any()));

      expect(result.isLeft(), true);

      result.fold((failure) {
        expect(failure, isA<PortfolioValidationFailure>());
        expect(failure.message, '유효한 게시물 ID가 필요합니다.');
      }, (_) => fail('Left가 와야 함'));
    });

    test('실패 케이스: postId가 공백만 있으면 validation failure 반환', () async {
      final result = await usecase.execute('   ');

      verifyNever(() => mockRepository.getPostDetail(any()));

      expect(result.isLeft(), true);

      result.fold((failure) {
        expect(failure, isA<PortfolioValidationFailure>());
        expect(failure.message, '유효한 게시물 ID가 필요합니다.');
      }, (_) => fail('Left가 와야 함'));
    });
  });
}

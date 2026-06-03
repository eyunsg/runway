import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/features/post/dto/create_comment_request_dto.dart';
import 'package:runway/features/post/repository/create_comment_repository.dart';
import 'package:runway/features/post/usecase/create_comment_usecase.dart';

class MockCreateCommentRepository extends Mock
    implements CreateCommentRepository {}

class CreateCommentRequestDtoFake extends Fake
    implements CreateCommentRequestDto {}

void main() {
  late MockCreateCommentRepository repository;
  late CreateCommentUsecase useCase;

  setUpAll(() {
    registerFallbackValue(CreateCommentRequestDtoFake());
  });

  setUp(() {
    repository = MockCreateCommentRepository();
    useCase = CreateCommentUsecase(repository);
  });

  group('CreateCommentUsecase', () {
    test('content가 비어있으면 ServerFailure를 반환하고 repository를 호출하지 않는다', () async {
      final result = await useCase.execute(postId: 'post-1', content: '   ');

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.message, '댓글 내용을 입력해주세요.');
      }, (_) => fail('Left가 반환되어야 한다'));

      verifyNever(
        () => repository.createComment(
          postId: any(named: 'postId'),
          requestDto: any(named: 'requestDto'),
        ),
      );
    });

    test(
      'content가 1000자를 초과하면 ServerFailure를 반환하고 repository를 호출하지 않는다',
      () async {
        final tooLongContent = 'a' * 1001;

        final result = await useCase.execute(
          postId: 'post-1',
          content: tooLongContent,
        );

        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, '댓글 내용은 1000자 이내여야 합니다.');
        }, (_) => fail('Left가 반환되어야 한다'));

        verifyNever(
          () => repository.createComment(
            postId: any(named: 'postId'),
            requestDto: any(named: 'requestDto'),
          ),
        );
      },
    );

    test('정상 입력이면 trim 후 repository에 전달한다', () async {
      when(
        () => repository.createComment(
          postId: any(named: 'postId'),
          requestDto: any(named: 'requestDto'),
        ),
      ).thenAnswer((_) async => const Right(null));

      final result = await useCase.execute(
        postId: ' post-1 ',
        content: '  정상 댓글입니다.  ',
      );

      expect(result, const Right<Failure, void>(null));

      final captured = verify(
        () => repository.createComment(
          postId: captureAny(named: 'postId'),
          requestDto: captureAny(named: 'requestDto'),
        ),
      ).captured;

      expect(captured[0], 'post-1');

      final dto = captured[1] as CreateCommentRequestDto;
      expect(dto.content, '정상 댓글입니다.');
    });

    test('repository 실패를 그대로 반환한다', () async {
      when(
        () => repository.createComment(
          postId: any(named: 'postId'),
          requestDto: any(named: 'requestDto'),
        ),
      ).thenAnswer((_) async => const Left(ServerFailure('서버 오류')));

      final result = await useCase.execute(postId: 'post-1', content: '정상 댓글');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, '서버 오류'),
        (_) => fail('Left가 와야 함'),
      );
    });
  });
}

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/features/post/controller/delete_post_controller.dart';
import 'package:runway/features/post/types/delete_post_state.dart';
import 'package:runway/features/post/usecase/delete_post_usecase.dart';

class MockDeletePostUseCase extends Mock implements DeletePostUsecase {}

void main() {
  late DeletePostController controller;
  late MockDeletePostUseCase mockUseCase;

  const testPostId = 'test-post-id';

  setUp(() {
    mockUseCase = MockDeletePostUseCase();
    controller = DeletePostController(useCase: mockUseCase);
  });

  group('deletePost', () {
    test('성공 시 loading → success 상태로 변경된다', () async {
      when(
        () => mockUseCase.execute(testPostId),
      ).thenAnswer((_) async => const Right(null));

      final states = <DeletePostState>[];
      controller.addListener(states.add);

      await controller.deletePost(testPostId);

      verify(() => mockUseCase.execute(testPostId)).called(1);

      expect(states.length, 3);
      expect(states[0].isLoading, false);

      expect(states[1].isLoading, true);
      expect(states[1].isSuccess, false);

      expect(states[2].isLoading, false);
      expect(states[2].isSuccess, true);
      expect(states[2].error, isNull);
    });

    test('실패 시 error 세팅', () async {
      when(
        () => mockUseCase.execute(testPostId),
      ).thenAnswer((_) async => Left(ServerFailure('server error')));

      final states = <DeletePostState>[];
      controller.addListener(states.add);

      await controller.deletePost(testPostId);

      verify(() => mockUseCase.execute(testPostId)).called(1);

      expect(states.length, 3);
      expect(states[0].isLoading, false);

      expect(states[1].isLoading, true);

      expect(states[2].isLoading, false);
      expect(states[2].isSuccess, false);
      expect(states[2].error, 'server error');
    });
  });
}

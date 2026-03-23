import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:runway/core/error/failure.dart';
import 'package:runway/features/profile/controller/delete_profile_controller.dart';
import 'package:runway/features/profile/usecase/delete_profile_usecase.dart';

class MockDeleteProfileUseCase extends Mock implements DeleteProfileUseCase {}

class TestFailure extends Failure {
  TestFailure(super.message);
}

void main() {
  late MockDeleteProfileUseCase mockUseCase;
  late DeleteProfileController controller;

  setUp(() {
    mockUseCase = MockDeleteProfileUseCase();
    controller = DeleteProfileController(deleteProfileUseCase: mockUseCase);
  });

  test('deleteProfile 성공 시 isSuccess가 true로 설정되어야 한다', () async {
    when(
      () => mockUseCase.execute(),
    ).thenAnswer((_) async => const Right(null));

    await controller.deleteProfile();

    expect(controller.state.isLoading, false);
    expect(controller.state.error, null);
    expect(controller.state.isSuccess, true);

    verify(() => mockUseCase.execute()).called(1);
  });

  test('deleteProfile 실패 시 error가 설정되어야 한다', () async {
    final failure = TestFailure('삭제 실패');

    when(() => mockUseCase.execute()).thenAnswer((_) async => Left(failure));

    await controller.deleteProfile();

    expect(controller.state.isLoading, false);
    expect(controller.state.error, '삭제 실패');
    expect(controller.state.isSuccess, false);

    verify(() => mockUseCase.execute()).called(1);
  });
}

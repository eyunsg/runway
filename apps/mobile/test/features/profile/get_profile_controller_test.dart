import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/domain/entity/profile.dart';

import 'package:runway/features/profile/controller/get_profile_controller.dart';
import 'package:runway/features/profile/usecase/get_profile_usecase.dart';

class MockGetProfileUseCase extends Mock implements GetProfileUseCase {}

void main() {
  late MockGetProfileUseCase mockUseCase;
  late GetProfileController controller;

  setUp(() {
    mockUseCase = MockGetProfileUseCase();
  });

  test('fetchProfile 성공 시 state에 데이터가 반영되어야 한다', () async {
    final mockProfile = Profile(email: 'test@test.com', displayName: 'tester');

    when(
      () => mockUseCase.execute(),
    ).thenAnswer((_) async => Right(mockProfile));

    controller = GetProfileController(useCase: mockUseCase);

    await Future.delayed(Duration.zero);

    expect(controller.state.isLoading, false);
    expect(controller.state.error, null);
    expect(controller.state.email, 'test@test.com');
    expect(controller.state.displayName, 'tester');
    expect(controller.state.isSuccess, true);

    verify(() => mockUseCase.execute()).called(1);
  });

  test('fetchProfile 실패 시 state에 error가 반영되어야 한다', () async {
    final failure = ServerFailure('서버 오류');

    when(() => mockUseCase.execute()).thenAnswer((_) async => Left(failure));

    controller = GetProfileController(useCase: mockUseCase);

    await Future.delayed(Duration.zero);

    expect(controller.state.isLoading, false);
    expect(controller.state.error, '서버 오류');
    expect(controller.state.email, null);
    expect(controller.state.displayName, null);
    expect(controller.state.isSuccess, false);

    verify(() => mockUseCase.execute()).called(1);
  });
}

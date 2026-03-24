import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:runway/features/profile/controller/update_profile_controller.dart';

import 'package:runway/features/profile/usecase/update_profile_usecase.dart';
import 'package:runway/features/profile/types/profile_state.dart';
import 'package:runway/core/error/failure.dart';

class MockUpdateProfileUseCase extends Mock implements UpdateProfileUseCase {}

void main() {
  late UpdateProfileController controller;
  late MockUpdateProfileUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockUpdateProfileUseCase();
    controller = UpdateProfileController(useCase: mockUseCase);
  });

  test('프로필 수정 성공 시 loading → success 상태로 변경된다', () async {
    const newName = '성공닉네임';

    when(
      () => mockUseCase.execute(any<String>()),
    ).thenAnswer((_) async => const Right(null));

    final states = <ProfileState>[];

    controller.addListener((state) {
      states.add(state);
    });

    await controller.updateProfile(newName);

    verify(() => mockUseCase.execute(newName)).called(1);

    expect(states.length, 2);

    expect(states[0].isLoading, true);

    expect(states[1].isLoading, false);
    expect(states[1].isSuccess, true);
    expect(states[1].error, isNull);
  });

  test('프로필 수정 실패 시 loading → error 상태로 변경된다', () async {
    const errorMsg = 'Update failed';

    when(
      () => mockUseCase.execute(any<String>()),
    ).thenAnswer((_) async => Left<Failure, void>(ServerFailure(errorMsg)));

    final states = <ProfileState>[];

    controller.addListener((state) {
      states.add(state);
    });

    await controller.updateProfile('실패닉네임');

    verify(() => mockUseCase.execute('실패닉네임')).called(1);

    expect(states.length, 2);

    expect(states[0].isLoading, true);

    expect(states[1].isLoading, false);
    expect(states[1].isSuccess, false);
    expect(states[1].error, errorMsg);
  });
}

// TODO: 테스트 통과하도록 수정

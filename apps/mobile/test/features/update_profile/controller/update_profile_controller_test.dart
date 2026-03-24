import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:runway/features/update_profile/controller/update_profile_controller.dart';
import 'package:runway/features/update_profile/usecase/update_profile_usecase.dart';
import 'package:runway/features/profile/types/profile_state.dart';

class MockUpdateProfileUseCase extends Mock implements UpdateProfileUseCase {}

void main() {
  late UpdateProfileController controller;
  late MockUpdateProfileUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockUpdateProfileUseCase();
    controller = UpdateProfileController(useCase: mockUseCase);
  });

  test('프로필 수정 성공 시 상태가 loading → success로 변경되고 데이터가 반영된다', () async {
    const newName = '성공닉네임';
    final mockResponse = {'email': 'test@example.com', 'displayName': newName};

    when(
      () => mockUseCase.execute(any()),
    ).thenAnswer((_) async => mockResponse);

    final states = <ProfileState>[];
    controller.addListener(states.add);

    await controller.updateProfile(newName);

    final changedStates = states.skip(1).toList();

    expect(changedStates.length, 2);

    expect(changedStates[0].isLoading, true);

    expect(changedStates[1].isLoading, false);
    expect(changedStates[1].isSuccess, true);
    expect(changedStates[1].displayName, newName);
    expect(changedStates[1].error, isNull);
  });

  test('프로필 수정 실패 시 상태가 loading → error로 변경되고 에러 메시지가 설정된다', () async {
    const errorMsg = 'Update failed';
    when(() => mockUseCase.execute(any())).thenThrow(Exception(errorMsg));

    final states = <ProfileState>[];
    controller.addListener(states.add);

    await controller.updateProfile('실패닉네임');

    final changedStates = states.skip(1).toList();

    expect(changedStates.length, 2);

    expect(changedStates[0].isLoading, true);

    expect(changedStates[1].isLoading, false);
    expect(changedStates[1].isSuccess, false);

    expect(changedStates[1].error, contains(errorMsg));
  });
}

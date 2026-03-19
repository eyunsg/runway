import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:runway/features/profile/controller/profile_controller.dart';
import 'package:runway/features/profile/usecase/profile_usecase.dart';

class MockGetProfileUseCase extends Mock implements GetProfileUseCase {}

void main() {
  late MockGetProfileUseCase mockUseCase;
  late ProfileController controller;

  setUp(() {
    mockUseCase = MockGetProfileUseCase();
    controller = ProfileController(useCase: mockUseCase);
  });

  test('fetchProfile 성공 시 state에 데이터가 반영되어야 한다', () async {
    const accessToken = 'test_token';

    final mockResponse = {'email': 'test@test.com', 'displayName': 'tester'};

    when(
      () => mockUseCase.execute(accessToken),
    ).thenAnswer((_) async => mockResponse);

    await controller.fetchProfile(accessToken);

    expect(controller.state.isLoading, false);
    expect(controller.state.error, null);
    expect(controller.state.email, 'test@test.com');
    expect(controller.state.displayName, 'tester');

    verify(() => mockUseCase.execute(accessToken)).called(1);
  });

  test('fetchProfile 실패 시 error가 설정되어야 한다', () async {
    const accessToken = 'test_token';

    when(() => mockUseCase.execute(accessToken)).thenThrow(Exception('error'));

    await controller.fetchProfile(accessToken);

    expect(controller.state.isLoading, false);
    expect(controller.state.error, isNotNull);
    expect(controller.state.email, null);
    expect(controller.state.displayName, null);

    verify(() => mockUseCase.execute(accessToken)).called(1);
  });
}

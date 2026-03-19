import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:runway/features/profile/repository/profile_reposity.dart';
import 'package:runway/features/profile/usecase/profile_usecase.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late MockProfileRepository mockRepository;
  late GetProfileUseCase useCase;

  setUp(() {
    mockRepository = MockProfileRepository();
    useCase = GetProfileUseCase(mockRepository);
  });

  test('repository에서 전달된 프로필 데이터를 그대로 반환해야 한다', () async {
    const accessToken = 'test_token';

    final mockResponse = {'email': 'test@test.com', 'displayName': 'tester'};

    when(
      () => mockRepository.getProfile(accessToken),
    ).thenAnswer((_) async => mockResponse);

    final result = await useCase.execute(accessToken);

    expect(result, mockResponse);

    verify(() => mockRepository.getProfile(accessToken)).called(1);
  });
}

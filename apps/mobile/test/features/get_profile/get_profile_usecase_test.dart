import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:runway/features/get_profile/repository/get_profile_reposity.dart';
import 'package:runway/features/get_profile/usecase/get_profile_usecase.dart';

class MockProfileRepository extends Mock implements GetProfileReposity {}

void main() {
  late MockProfileRepository mockRepository;
  late GetProfileUseCase useCase;

  setUp(() {
    mockRepository = MockProfileRepository();
    useCase = GetProfileUseCase(mockRepository);
  });

  test('repository에서 전달된 프로필 데이터를 그대로 반환해야 한다', () async {
    final mockResponse = {'email': 'test@test.com', 'displayName': 'tester'};

    when(
      () => mockRepository.getProfile(),
    ).thenAnswer((_) async => mockResponse);

    final result = await useCase.execute();

    expect(result, mockResponse);

    verify(() => mockRepository.getProfile()).called(1);
  });
}

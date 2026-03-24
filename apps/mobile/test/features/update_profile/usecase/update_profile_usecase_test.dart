import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:runway/features/update_profile/usecase/update_profile_usecase.dart';
import 'package:runway/features/update_profile/repository/update_profile_repository.dart';

class MockUpdateProfileRepository extends Mock
    implements UpdateProfileRepository {}

void main() {
  late UpdateProfileUseCase usecase;
  late MockUpdateProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockUpdateProfileRepository();
    usecase = UpdateProfileUseCase(repository: mockRepository);
  });

  test('Usecase는 입력받은 newDisplayName을 Repository에 정확히 전달한다', () async {
    const testNickname = '새로운닉네임';

    final mockResponse = {
      'email': 'test@example.com',
      'displayName': testNickname,
    };

    when(
      () => mockRepository.updateProfile(any()),
    ).thenAnswer((_) async => mockResponse);

    final result = await usecase.execute(testNickname);

    verify(() => mockRepository.updateProfile(testNickname)).called(1);

    expect(result['displayName'], testNickname);
    expect(result['email'], 'test@example.com');
  });

  test('Repository에서 Exception 발생 시 UseCase는 이를 그대로 상위로 던진다', () async {
    const errorMsg = 'Update failed';
    when(
      () => mockRepository.updateProfile(any()),
    ).thenThrow(Exception(errorMsg));

    expect(() => usecase.execute('에러테스트'), throwsA(isA<Exception>()));
  });
}

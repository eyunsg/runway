import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:runway/features/login/usecase/login_usecase.dart';
import 'package:runway/features/login/repository/login_repository.dart';

class MockLoginRepository extends Mock implements LoginRepository {}

void main() {
  late LoginUsecase usecase;
  late MockLoginRepository mockRepository;

  setUp(() {
    mockRepository = MockLoginRepository();
    usecase = LoginUsecase(repository: mockRepository);
  });

  test('로그인 Usecase는 Repository를 호출한다', () async {
    final mockUser = User(
      id: 'test-id',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
    );

    when(
      () => mockRepository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => mockUser);

    final result = await usecase.execute(
      email: 'test@email.com',
      password: '123456',
    );

    expect(result.id, 'test-id');

    verify(
      () => mockRepository.login(email: 'test@email.com', password: '123456'),
    ).called(1);
  });
}

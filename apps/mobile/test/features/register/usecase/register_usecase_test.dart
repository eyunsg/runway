import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:runway/features/register/usecase/register_usecase.dart';
import 'package:runway/features/register/repository/register_repository.dart';

class MockRegisterRepository extends Mock implements RegisterRepository {}

void main() {
  late RegisterUsecase usecase;
  late MockRegisterRepository mockRepository;

  setUp(() {
    mockRepository = MockRegisterRepository();
    usecase = RegisterUsecase(repository: mockRepository);
  });

  test('회원가입 Usecase는 Repository를 호출한다', () async {
    final mockUser = User(
      id: 'test-id',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
    );

    when(
      () => mockRepository.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
        displayName: any(named: 'displayName'),
      ),
    ).thenAnswer((_) async => mockUser);

    final result = await usecase.execute(
      email: 'test@email.com',
      password: '123456',
      displayName: 'tester',
    );

    expect(result.id, 'test-id');

    verify(
      () => mockRepository.signUp(
        email: 'test@email.com',
        password: '123456',
        displayName: 'tester',
      ),
    ).called(1);
  });
}

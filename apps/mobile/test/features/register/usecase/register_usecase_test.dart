import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:runway/core/error/validation_failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:runway/features/register/usecase/register_usecase.dart';
import 'package:runway/features/register/repository/register_repository.dart';
import 'package:runway/core/error/failure.dart';

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
      passwordConfirm: '123456',
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

  test('비밀번호 불일치 시 AuthFailure를 throw', () async {
    expect(
      () => usecase.execute(
        email: 'test@email.com',
        password: '123456',
        passwordConfirm: '1234567',
        displayName: 'tester',
      ),
      throwsA(isA<AuthFailure>()),
    );
  });

  test('비밀번호 6자 미만이면 PasswordFailure를 throw', () async {
    expect(
      () => usecase.execute(
        email: 'test@email.com',
        password: '123',
        passwordConfirm: '123',
        displayName: 'tester',
      ),
      throwsA(isA<PasswordFailure>()),
    );
  });
}

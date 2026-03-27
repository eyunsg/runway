import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dartz/dartz.dart';
import 'package:runway/core/error/validation_failure.dart';
import 'package:runway/features/login/usecase/login_usecase.dart';
import 'package:runway/features/login/repository/login_repository.dart';

class MockLoginRepository extends Mock implements LoginRepository {}

class MockUser extends Mock implements User {}

void main() {
  late LoginUsecase usecase;
  late MockLoginRepository mockRepository;

  setUp(() {
    mockRepository = MockLoginRepository();
    usecase = LoginUsecase(repository: mockRepository);
  });

  test('정상 입력 시 Repository 호출 후 Right(User) 반환', () async {
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
    ).thenAnswer((_) async => Right(mockUser));

    final result = await usecase.execute(
      email: 'test@email.com',
      password: '123456',
    );

    expect(result.isRight(), true);

    final user = result.getOrElse(() => throw Exception());
    expect(user.id, 'test-id');

    verify(
      () => mockRepository.login(email: 'test@email.com', password: '123456'),
    ).called(1);
  });

  test('이메일 검증 실패 시 Left<EmailFailure> 반환', () async {
    final result = await usecase.execute(email: '', password: '123456');

    expect(result.isLeft(), true);

    result.fold(
      (failure) => expect(failure, isA<EmailFailure>()),
      (_) => throw Exception('테스트 실패: Left여야 함'),
    );

    verifyNever(
      () => mockRepository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );
  });

  test('비밀번호 검증 실패 시 Left<PasswordFailure> 반환', () async {
    final result = await usecase.execute(
      email: 'test@email.com',
      password: '123',
    );

    expect(result.isLeft(), true);

    result.fold(
      (failure) => expect(failure, isA<PasswordFailure>()),
      (_) => throw Exception('테스트 실패: Left여야 함'),
    );

    verifyNever(
      () => mockRepository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );
  });
}

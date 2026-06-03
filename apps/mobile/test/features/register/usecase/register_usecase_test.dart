import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:runway/core/error/validation_failure.dart';
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

  group('RegisterUsecase.execute', () {
    test('Repository 호출 확인', () async {
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
      ).thenAnswer((_) async => Right(mockUser));

      final result = await usecase.execute(
        email: 'test@email.com',
        password: '123456',
        passwordConfirm: '123456',
        displayName: 'tester',
      );

      final user = result.getOrElse(() => throw Exception('실패'));
      expect(user.id, 'test-id');

      verify(
        () => mockRepository.signUp(
          email: 'test@email.com',
          password: '123456',
          displayName: 'tester',
        ),
      ).called(1);
    });

    test('비밀번호 불일치 시 PasswordFailure 반환', () async {
      final result = await usecase.execute(
        email: 'test@email.com',
        password: '123456',
        passwordConfirm: '1234567',
        displayName: 'tester',
      );

      expect(result.isLeft(), true);

      result.fold((failure) {
        expect(failure, isA<PasswordFailure>());
        expect((failure as PasswordFailure).message, '비밀번호 확인이 일치하지 않습니다.');
      }, (_) => fail('Should return Left<Failure>'));
    });

    test('6자 미만 비밀번호는 PasswordFailure 반환', () async {
      final result = await usecase.execute(
        email: 'test@email.com',
        password: '123',
        passwordConfirm: '123',
        displayName: 'tester',
      );

      expect(result.isLeft(), true);

      result.fold((failure) {
        expect(failure, isA<PasswordFailure>());
        expect((failure as PasswordFailure).message, '비밀번호는 6자 이상이어야 합니다.');
      }, (_) => fail('Should return Left<Failure>'));
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:runway/core/error/failure.dart';
import 'package:runway/features/password_reset/repository/reset_password_repository.dart';
import 'package:runway/features/password_reset/usecase/reset_password_usecase.dart';

class MockRequestPasswordResetRepository extends Mock
    implements RequestPasswordResetRepository {}

void main() {
  late RequestPasswordResetUsecase usecase;
  late MockRequestPasswordResetRepository mockRepository;

  setUp(() {
    mockRepository = MockRequestPasswordResetRepository();
    usecase = RequestPasswordResetUsecase(repository: mockRepository);
  });

  test('성공 시: Repository 호출 후 Right(unit) 반환', () async {
    when(
      () => mockRepository.requestPasswordReset(
        email: any<String>(named: 'email'),
      ),
    ).thenAnswer((_) async => const Right(unit));

    final result = await usecase.execute(emailInput: 'test@test.com');

    expect(result, const Right(unit));

    verify(
      () => mockRepository.requestPasswordReset(email: 'test@test.com'),
    ).called(1);
  });

  test('Repository가 Failure를 반환하면 그대로 전달', () async {
    final failure = ServerFailure('error');

    when(
      () => mockRepository.requestPasswordReset(
        email: any<String>(named: 'email'),
      ),
    ).thenAnswer((_) async => Left(failure));

    final result = await usecase.execute(emailInput: 'test@test.com');

    expect(result, Left(failure));
  });

  test('이메일 형식이 잘못되면 Left(Failure) 반환 + Repository 호출 안 함', () async {
    final result = await usecase.execute(emailInput: 'invalid-email');

    expect(result.isLeft(), true);

    verifyNever(
      () => mockRepository.requestPasswordReset(
        email: any<String>(named: 'email'),
      ),
    );
  });
}

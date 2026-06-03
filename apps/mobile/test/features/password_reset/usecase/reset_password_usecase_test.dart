import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:runway/core/error/failure.dart';
import 'package:runway/core/error/validation_failure.dart';
import 'package:runway/features/password_reset/usecase/reset_password_usecase.dart';
import 'package:runway/features/password_reset/repository/reset_password_repository.dart';

class MockResetPasswordRepository extends Mock
    implements ResetPasswordRepository {}

void main() {
  late ResetPasswordUsecase usecase;
  late MockResetPasswordRepository mockRepository;

  setUp(() {
    mockRepository = MockResetPasswordRepository();
    usecase = ResetPasswordUsecase(repository: mockRepository);
  });

  test('정상 입력 시 Right(unit) 반환 및 repository 호출', () async {
    when(
      () => mockRepository.resetPassword(
        newPassword: any<String>(named: 'newPassword'),
      ),
    ).thenAnswer((_) async => const Right(unit));

    final result = await usecase.execute(
      newPassword: '123456',
      passwordConfirm: '123456',
    );

    expect(result, const Right(unit));

    verify(() => mockRepository.resetPassword(newPassword: '123456')).called(1);
  });

  test('비밀번호 형식 오류 시 Left(PasswordFailure) 반환', () async {
    final result = await usecase.execute(
      newPassword: '123',
      passwordConfirm: '123',
    );

    expect(result.isLeft(), true);

    final failure = result.swap().getOrElse(() => throw Exception());
    expect(failure, isA<PasswordFailure>());

    verifyNever(
      () =>
          mockRepository.resetPassword(newPassword: any(named: 'newPassword')),
    );
  });

  test('비밀번호 불일치 시 Left(PasswordFailure) 반환', () async {
    final result = await usecase.execute(
      newPassword: '123456',
      passwordConfirm: '654321',
    );

    expect(result.isLeft(), true);

    final failure = result.swap().getOrElse(() => throw Exception());
    expect(failure, isA<PasswordFailure>());
  });

  test('Repository가 Failure를 반환하면 그대로 전달', () async {
    final failure = ServerFailure('error');

    when(
      () => mockRepository.resetPassword(
        newPassword: any<String>(named: 'newPassword'),
      ),
    ).thenAnswer((_) async => Left(failure));

    final result = await usecase.execute(
      newPassword: '123456',
      passwordConfirm: '123456',
    );

    expect(result, Left(failure));
  });
}

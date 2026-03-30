import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/core/error/validation_failure.dart';
import 'package:runway/features/password_change/usecase/password_change_usecase.dart';
import 'package:runway/features/password_change/repository/password_change_repository.dart';

class MockPasswordChangeRepository extends Mock
    implements PasswordChangeRepository {}

void main() {
  late PasswordChangeUsecase usecase;
  late MockPasswordChangeRepository mockRepository;

  setUp(() {
    mockRepository = MockPasswordChangeRepository();
    usecase = PasswordChangeUsecase(repository: mockRepository);
  });

  group('PasswordChangeUsecase', () {
    const validCurrentPassword = 'oldPassword123';
    const validNewPassword = 'newPassword456';
    const validNewPasswordConfirm = 'newPassword456';

    test('레포지토리 호출 후 정상 UserResponse 반환', () async {
      when(
        () => mockRepository.changePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer((_) async => const Right(unit));

      final result = await usecase.execute(
        currentPassword: validCurrentPassword,
        newPassword: validNewPassword,
        newPasswordConfirm: validNewPasswordConfirm,
      );

      expect(result.isRight(), true);
      verify(
        () => mockRepository.changePassword(
          currentPassword: validCurrentPassword,
          newPassword: validNewPassword,
        ),
      ).called(1);
    });

    test('현재 비밀번호 검증 실패 시 Left<PasswordFailure> 반환', () async {
      final result = await usecase.execute(
        currentPassword: 'short',
        newPassword: validNewPassword,
        newPasswordConfirm: validNewPasswordConfirm,
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<PasswordFailure>()),
        (_) => fail('Should return Left'),
      );

      verifyNever(
        () => mockRepository.changePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        ),
      );
    });

    test('새 비밀번호와 확인값 불일치 시 Left<PasswordFailure> 반환', () async {
      final result = await usecase.execute(
        currentPassword: validCurrentPassword,
        newPassword: validNewPassword,
        newPasswordConfirm: 'differentPassword!',
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<PasswordFailure>());
        expect((failure as PasswordFailure).message, '비밀번호 확인이 일치하지 않습니다.');
      }, (_) => fail('Should return Left'));

      verifyNever(
        () => mockRepository.changePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        ),
      );
    });

    test('레포지토리에서 AuthFailure 발생 시 Usecase도 Left<AuthFailure> 반환', () async {
      when(
        () => mockRepository.changePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer((_) async => Left(AuthFailure('현재 비밀번호가 올바르지 않습니다.')));

      final result = await usecase.execute(
        currentPassword: validCurrentPassword,
        newPassword: validNewPassword,
        newPasswordConfirm: validNewPasswordConfirm,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AuthFailure>());
        expect((failure as AuthFailure).message, '현재 비밀번호가 올바르지 않습니다.');
      }, (_) => fail('Should return Left'));

      verify(
        () => mockRepository.changePassword(
          currentPassword: validCurrentPassword,
          newPassword: validNewPassword,
        ),
      ).called(1);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:runway/features/password_change/repository/password_change_repository.dart';
import 'package:runway/features/password_change/usecase/password_change_usecase.dart';

class MockPasswordChangeRepository extends Mock
    implements PasswordChangeRepository {}

class MockUserResponse extends Mock implements UserResponse {}

void main() {
  late PasswordChangeUsecase usecase;
  late MockPasswordChangeRepository mockRepository;

  setUp(() {
    mockRepository = MockPasswordChangeRepository();
    usecase = PasswordChangeUsecase(repository: mockRepository);
  });

  group('PasswordChangeUsecase 테스트', () {
    const validCurrentPassword = 'oldPassword123';
    const validNewPassword = 'newPassword456';
    const validNewPasswordConfirm = 'newPassword456';

    test('유즈케이스는 입력받은 비밀번호를 레포지토리에 전달한다', () async {
      final mockResponse = MockUserResponse();

      when(
        () => mockRepository.changePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer((_) async => mockResponse);

      final result = await usecase.execute(
        currentPassword: validCurrentPassword,
        newPassword: validNewPassword,
        newPasswordConfirm: validNewPasswordConfirm,
      );

      verify(
        () => mockRepository.changePassword(
          currentPassword: validCurrentPassword,
          newPassword: validNewPassword,
        ),
      ).called(1);

      expect(result, mockResponse);
    });

    test('레포지토리에서 Exception 발생 시 유즈케이스에서도 그대로 전달됨', () async {
      when(
        () => mockRepository.changePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenThrow(Exception('change failed'));

      expect(
        () => usecase.execute(
          currentPassword: validCurrentPassword,
          newPassword: validNewPassword,
          newPasswordConfirm: validNewPasswordConfirm,
        ),
        throwsA(isA<Exception>()),
      );

      verify(
        () => mockRepository.changePassword(
          currentPassword: validCurrentPassword,
          newPassword: validNewPassword,
        ),
      ).called(1);
    });
  });
}

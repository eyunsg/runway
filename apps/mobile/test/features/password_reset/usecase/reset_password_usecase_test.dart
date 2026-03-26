import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:runway/domain/value_objects/password_reset_input.dart';
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

  test('Usecase는 input.password.value를 Repository에 전달한다', () async {
    final input = PasswordResetInput(
      password: Password('123456'),
      passwordConfirm: PasswordConfirm('123456'),
    );

    final mockUser = User(
      id: 'test-id',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
    );

    when(
      () =>
          mockRepository.resetPassword(newPassword: any(named: 'newPassword')),
    ).thenAnswer((_) async => mockUser);

    final result = await usecase.execute(input: input);

    verify(() => mockRepository.resetPassword(newPassword: '123456')).called(1);

    expect(result.id, 'test-id');
  });

  test('Repository에서 Exception 발생 시 그대로 전달된다', () async {
    final input = PasswordResetInput(
      password: Password('123456'),
      passwordConfirm: PasswordConfirm('123456'),
    );

    when(
      () =>
          mockRepository.resetPassword(newPassword: any(named: 'newPassword')),
    ).thenThrow(Exception('reset failed'));

    expect(() => usecase.execute(input: input), throwsA(isA<Exception>()));
  });
}

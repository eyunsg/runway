import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:runway/features/password_reset/repository/reset_password_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUserResponse extends Mock implements UserResponse {}

void main() {
  setUpAll(() {
    registerFallbackValue(UserAttributes(password: 'dummy'));
  });

  late ResetPasswordRepository repository;
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();

    when(() => mockClient.auth).thenReturn(mockAuth);

    repository = ResetPasswordRepository(client: mockClient);
  });

  test('비밀번호 변경 성공 시 User 반환', () async {
    final mockUser = User(
      id: 'test-id',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
    );

    final mockResponse = MockUserResponse();

    when(() => mockResponse.user).thenReturn(mockUser);

    when(
      () => mockAuth.updateUser(any()),
    ).thenAnswer((_) async => mockResponse);

    final result = await repository.resetPassword(newPassword: '123456');

    expect(result.id, 'test-id');
  });
}

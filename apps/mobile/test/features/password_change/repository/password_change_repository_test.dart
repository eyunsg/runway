import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:runway/features/password_change/repository/password_change_repository.dart';

const _currentPassword = 'currentPassword123';
const _testPassword = 'newPassword123';
const _testUserId = 'test-user-id';
const _testEmail = 'test@example.com';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUserResponse extends Mock implements UserResponse {}

class MockAuthResponse extends Mock implements AuthResponse {}

void main() {
  setUpAll(() {
    registerFallbackValue(UserAttributes(password: _testPassword));
  });

  late PasswordChangeRepository repository;
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    when(() => mockClient.auth).thenReturn(mockAuth);
    repository = PasswordChangeRepository(client: mockClient);
  });

  group('PasswordChangeRepository 테스트', () {
    test('비밀번호 변경 시 현재 비밀번호로 재인증을 거친 후 변경이 완료되어야 함', () async {
      final mockAuthResponse = MockAuthResponse();
      final mockResponse = MockUserResponse();
      final mockUser = User(
        id: _testUserId,
        email: _testEmail,
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
      );

      when(() => mockAuth.currentUser).thenReturn(mockUser);

      when(() => mockAuthResponse.user).thenReturn(mockUser);
      when(
        () => mockAuth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => mockAuthResponse);

      when(() => mockResponse.user).thenReturn(mockUser);
      when(
        () => mockAuth.updateUser(any()),
      ).thenAnswer((_) async => mockResponse);

      final result = await repository.changePassword(
        currentPassword: _currentPassword,
        newPassword: _testPassword,
      );

      expect(result.user?.id, _testUserId);

      verify(
        () => mockAuth.signInWithPassword(
          email: _testEmail,
          password: _currentPassword,
        ),
      ).called(1);

      verify(
        () => mockAuth.updateUser(
          any(
            that: isA<UserAttributes>().having(
              (a) => a.password,
              'password',
              _testPassword,
            ),
          ),
        ),
      ).called(1);
    });

    test('현재 비밀번호가 틀리면 updateUser를 호출하지 않고 에러를 던져야 함', () async {
      final mockUser = User(
        id: _testUserId,
        email: _testEmail,
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
      );
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      when(
        () => mockAuth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(AuthException('현재 비밀번호가 틀렸습니다.'));

      expect(
        () => repository.changePassword(
          currentPassword: 'wrong_password',
          newPassword: _testPassword,
        ),
        throwsA(isA<AuthException>()),
      );

      verifyNever(() => mockAuth.updateUser(any()));
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:runway/features/password_change/repository/password_change_repository.dart';

const _testPassword = 'newPassword123';
const _testUserId = 'test-user-id';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUserResponse extends Mock implements UserResponse {}

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
    test('비밀번호 변경 성공 시 UserResponse가 데이터 유실 없이 반환되어야 함', () async {
      final mockResponse = MockUserResponse();
      final mockUser = User(
        id: _testUserId,
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
      );

      when(() => mockResponse.user).thenReturn(mockUser);
      when(
        () => mockAuth.updateUser(any()),
      ).thenAnswer((_) async => mockResponse);

      final result = await repository.changePassword(_testPassword);

      expect(result.user?.id, _testUserId);

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

    test('서버 에러 발생 시 원본 에러를 rethrow 하고, 전달된 값의 무결성을 확인해야 함', () async {
      final serverError = Exception('서버 점검 중');
      when(() => mockAuth.updateUser(any())).thenThrow(serverError);

      expect(
        () => repository.changePassword(_testPassword),
        throwsA(isA<Exception>()),
      );

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
  });
}

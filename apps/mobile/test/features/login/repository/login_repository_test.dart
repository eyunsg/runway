import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:runway/features/login/repository/login_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  late LoginRepository repository;
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();

    when(() => mockClient.auth).thenReturn(mockAuth);

    repository = LoginRepository(client: mockClient);
  });

  test('로그인 성공 시 User 반환', () async {
    final mockUser = User(
      id: 'test-id',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
    );

    final response = AuthResponse(user: mockUser, session: null);

    when(
      () => mockAuth.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => response);

    final result = await repository.login(
      email: 'test@email.com',
      password: '123456',
    );

    expect(result.id, 'test-id');
  });

  test('로그인 실패 시 Exception 발생', () async {
    final response = AuthResponse(user: null, session: null);

    when(
      () => mockAuth.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => response);

    expect(
      () => repository.login(email: 'test@email.com', password: '123456'),
      throwsException,
    );
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:runway/features/register/repository/register_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  late RegisterRepository repository;
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();

    when(() => mockClient.auth).thenReturn(mockAuth);

    repository = RegisterRepository(client: mockClient);
  });

  test('회원가입 성공 시 User 반환', () async {
    final mockUser = User(
      id: 'test-id',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
    );

    final response = AuthResponse(user: mockUser, session: null);

    when(
      () => mockAuth.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async => response);

    final result = await repository.signUp(
      email: 'test@email.com',
      password: '123456',
      displayName: 'tester',
    );

    expect(result.id, 'test-id');
  });

  test('회원가입 실패 시 Exception 발생', () async {
    final response = AuthResponse(user: null, session: null);

    when(
      () => mockAuth.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async => response);

    expect(
      () => repository.signUp(
        email: 'test@email.com',
        password: '123456',
        displayName: 'tester',
      ),
      throwsException,
    );
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:runway/features/logout/repository/logout_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  late LogoutRepository repository;
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();

    when(() => mockClient.auth).thenReturn(mockAuth);

    repository = LogoutRepository(client: mockClient);
  });

  test('로그아웃 성공 시 오류 없이 로그아웃 되어야 함', () async {
    when(() => mockAuth.signOut()).thenAnswer((_) async => {});
    expect(repository.logout(), completes);
    verify(() => mockAuth.signOut()).called(1);
  });

  test('로그아웃 실패 시 Exception 발생', () async {
    when(() => mockAuth.signOut()).thenThrow(Exception('네트워크 에러'));
    expect(() => repository.logout(), throwsA(isA<Exception>()));
  });
}

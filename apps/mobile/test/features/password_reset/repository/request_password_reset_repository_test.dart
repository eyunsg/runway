import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:runway/features/password_reset/repository/request_password_reset_repository.dart.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  late RequestPasswordResetRepository repository;
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();

    when(() => mockClient.auth).thenReturn(mockAuth);

    repository = RequestPasswordResetRepository(client: mockClient);
  });

  test('비밀번호 초기화 이메일 요청 성공 시 예외 없이 종료', () async {
    when(
      () => mockAuth.resetPasswordForEmail(
        any(),
        redirectTo: any(named: 'redirectTo'),
      ),
    ).thenAnswer((_) async {});

    await repository.requestPasswordReset(email: 'test@email.com');

    verify(
      () => mockAuth.resetPasswordForEmail(
        'test@email.com',
        redirectTo: 'http://localhost:3000/reset-password/new',
      ),
    ).called(1);
  });

  test('가입되지 않은 이메일이면 Exception 발생', () async {
    when(
      () => mockAuth.resetPasswordForEmail(
        any(),
        redirectTo: any(named: 'redirectTo'),
      ),
    ).thenThrow(AuthApiException('User not found', statusCode: '404'));

    expect(
      () => repository.requestPasswordReset(email: 'test@email.com'),
      throwsA(
        predicate(
          (e) => e is Exception && e.toString().contains('가입되지 않은 이메일입니다.'),
        ),
      ),
    );
  });

  test('기타 AuthApiException 발생 시 원본 메시지 전달', () async {
    when(
      () => mockAuth.resetPasswordForEmail(
        any(),
        redirectTo: any(named: 'redirectTo'),
      ),
    ).thenThrow(AuthApiException('Something went wrong', statusCode: '500'));

    expect(
      () => repository.requestPasswordReset(email: 'test@email.com'),
      throwsA(
        predicate(
          (e) =>
              e is Exception && e.toString().contains('Something went wrong'),
        ),
      ),
    );
  });
}

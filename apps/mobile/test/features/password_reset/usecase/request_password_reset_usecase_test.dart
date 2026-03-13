import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:runway/features/password_reset/repository/request_password_reset_repository.dart.dart';
import 'package:runway/features/password_reset/usecase/request_password_reset_usecase.dart.dart';

class MockRequestPasswordResetRepository extends Mock
    implements RequestPasswordResetRepository {}

void main() {
  late RequestPasswordResetUsecase usecase;
  late MockRequestPasswordResetRepository mockRepository;

  setUp(() {
    mockRepository = MockRequestPasswordResetRepository();
    usecase = RequestPasswordResetUsecase(repository: mockRepository);
  });

  test('Usecase는 Repository.requestPasswordReset을 호출한다', () async {
    when(
      () => mockRepository.requestPasswordReset(email: any(named: 'email')),
    ).thenAnswer((_) async {});

    await usecase.execute(email: 'test@test.com');

    verify(
      () => mockRepository.requestPasswordReset(email: 'test@test.com'),
    ).called(1);
  });

  test('Repository에서 예외 발생 시 그대로 전달된다', () async {
    when(
      () => mockRepository.requestPasswordReset(email: any(named: 'email')),
    ).thenThrow(Exception('reset error'));

    expect(
      () => usecase.execute(email: 'test@test.com'),
      throwsA(isA<Exception>()),
    );
  });
}

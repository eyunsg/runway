import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/features/logout/usecase/logout_usecase.dart';
import 'package:runway/features/logout/repository/logout_repository.dart';

class MockLogoutRepository extends Mock implements LogoutRepository {}

void main() {
  late LogoutUsecase usecase;
  late MockLogoutRepository mockRepository;

  setUp(() {
    mockRepository = MockLogoutRepository();
    usecase = LogoutUsecase(repository: mockRepository);
  });

  test('로그아웃 Usecase는 Repository의 logout 메서드를 호출한다', () async {
    when(
      () => mockRepository.logout(),
    ).thenAnswer((_) async => const Right(unit));
    await usecase.execute();
    verify(() => mockRepository.logout()).called(1);
  });

  test('Repository에서 에러 발생 시 Usecase도 Left<Failure> 반환', () async {
    when(
      () => mockRepository.logout(),
    ).thenAnswer((_) async => Left(ServerFailure('로그아웃 실패')));

    final result = await usecase.execute();

    expect(result, isA<Left<Failure, Unit>>());

    result.fold((failure) {
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).message, '로그아웃 실패');
    }, (_) => fail('성공 케이스가 아님'));
  });
}

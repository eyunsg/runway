import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:runway/core/error/failure.dart';
import 'package:runway/features/profile/repository/delete_profile_repository.dart';
import 'package:runway/features/profile/usecase/delete_profile_usecase.dart';

class MockDeleteProfileRepository extends Mock
    implements DeleteProfileRepository {}

class FakeFailure extends Fake implements Failure {}

void main() {
  late MockDeleteProfileRepository mockRepository;
  late DeleteProfileUseCase useCase;

  setUpAll(() {
    registerFallbackValue(FakeFailure());
  });

  setUp(() {
    mockRepository = MockDeleteProfileRepository();
    useCase = DeleteProfileUseCase(repository: mockRepository);
  });

  test('repository에서 전달된 성공 결과(Right)를 그대로 반환해야 한다', () async {
    when(
      () => mockRepository.deleteProfile(),
    ).thenAnswer((_) async => const Right(null));

    final result = await useCase.execute();

    expect(result, const Right(null));
    verify(() => mockRepository.deleteProfile()).called(1);
  });

  test('repository에서 전달된 실패 결과(Left)를 그대로 반환해야 한다', () async {
    final failure = FakeFailure();

    when(
      () => mockRepository.deleteProfile(),
    ).thenAnswer((_) async => Left(failure));

    final result = await useCase.execute();

    expect(result, Left(failure));
    verify(() => mockRepository.deleteProfile()).called(1);
  });
}

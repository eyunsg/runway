import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:runway/features/profile/usecase/update_profile_usecase.dart';
import 'package:runway/features/profile/repository/update_profile_repository.dart';
import 'package:runway/core/error/failure.dart';

class MockUpdateProfileRepository extends Mock
    implements UpdateProfileRepository {}

void main() {
  late UpdateProfileUseCase usecase;
  late MockUpdateProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockUpdateProfileRepository();
    usecase = UpdateProfileUseCase(repository: mockRepository);
  });

  test('UseCase는 repository 결과를 그대로 반환한다 (성공)', () async {
    const testNickname = '새로운닉네임';

    when(
      () => mockRepository.updateProfile(any()),
    ).thenAnswer((_) async => const Right(null));

    final result = await usecase.execute(testNickname);

    verify(() => mockRepository.updateProfile(testNickname)).called(1);

    expect(result.isRight(), true);
  });

  test('UseCase는 repository 결과를 그대로 반환한다 (실패)', () async {
    const errorMsg = 'Update failed';

    when(
      () => mockRepository.updateProfile(any()),
    ).thenAnswer((_) async => Left(ServerFailure(errorMsg)));

    final result = await usecase.execute('에러테스트');

    verify(() => mockRepository.updateProfile('에러테스트')).called(1);

    expect(result.isLeft(), true);

    result.fold(
      (failure) => expect(failure.message, errorMsg),
      (_) => fail('Left가 와야 함'),
    );
  });
}

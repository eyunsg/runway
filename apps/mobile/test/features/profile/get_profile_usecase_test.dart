import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/features/profile/data/dto/profile_dto.dart';
import 'package:runway/features/profile/repository/get_profile_reposity.dart';
import 'package:runway/features/profile/usecase/get_profile_usecase.dart';

class MockProfileRepository extends Mock implements GetProfileRepository {}

void main() {
  late MockProfileRepository mockRepository;
  late GetProfileUseCase useCase;

  setUp(() {
    mockRepository = MockProfileRepository();
    useCase = GetProfileUseCase(mockRepository);
  });

  test('Repository에서 전달된 Profile을 Entity로 반환해야 한다', () async {
    final mockDto = ProfileDto(email: 'test@test.com', displayName: 'tester');

    when(
      () => mockRepository.getProfile(),
    ).thenAnswer((_) async => Right(mockDto));

    final result = await useCase.execute();

    result.fold((failure) => fail('실패하면 안됨: ${failure.message}'), (profile) {
      expect(profile.email, 'test@test.com');
      expect(profile.displayName, 'tester');
    });

    verify(() => mockRepository.getProfile()).called(1);
  });

  test('Repository 실패 시 Failure 반환', () async {
    final failure = ServerFailure('서버 오류');

    when(
      () => mockRepository.getProfile(),
    ).thenAnswer((_) async => Left(failure));

    final result = await useCase.execute();

    result.fold((f) => expect(f, isA<ServerFailure>()), (_) => fail('성공하면 안됨'));

    verify(() => mockRepository.getProfile()).called(1);
  });
}

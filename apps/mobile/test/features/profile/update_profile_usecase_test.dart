import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:runway/features/profile/usecase/update_profile_usecase.dart';
import 'package:runway/features/profile/repository/update_profile_repository.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/core/error/validation_failure.dart';

class MockUpdateProfileRepository extends Mock
    implements UpdateProfileRepository {}

void main() {
  late UpdateProfileUseCase usecase;
  late MockUpdateProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockUpdateProfileRepository();
    usecase = UpdateProfileUseCase(repository: mockRepository);
  });

  test('성공 케이스: Repository가 Right(null)을 반환하면 UseCase도 Right(null)', () async {
    const rawNickname = '  새로운닉네임  ';
    const trimmedNickname = '새로운닉네임';

    when(
      () => mockRepository.updateProfile(trimmedNickname),
    ).thenAnswer((_) async => const Right(null));

    final result = await usecase.execute(rawNickname);

    verify(() => mockRepository.updateProfile(trimmedNickname)).called(1);
    expect(result.isRight(), true);
  });

  test('서버 실패 케이스: Repository가 Left(Failure)을 반환하면 UseCase도 그대로 반환', () async {
    const rawNickname = '에러닉네임';
    const trimmedNickname = '에러닉네임';
    const errorMsg = 'Update failed';

    when(
      () => mockRepository.updateProfile(trimmedNickname),
    ).thenAnswer((_) async => Left(ServerFailure(errorMsg)));

    final result = await usecase.execute(rawNickname);

    verify(() => mockRepository.updateProfile(trimmedNickname)).called(1);
    expect(result.isLeft(), true);

    result.fold(
      (failure) => expect(failure.message, errorMsg),
      (_) => fail('Left가 와야 함'),
    );
  });

  test('Validation 실패 케이스: 공백만 입력하면 DisplayNameFailure 반환', () async {
    const rawNickname = '   ';

    final result = await usecase.execute(rawNickname);

    expect(result.isLeft(), true);
    result.fold(
      (failure) => expect(failure, isA<DisplayNameFailure>()),
      (_) => fail('Left가 와야 함'),
    );

    result.fold(
      (failure) => expect(failure.message, '닉네임을 입력해주세요'),
      (_) => null,
    );
  });

  test('Validation 실패 케이스: 50자 초과하면 DisplayNameFailure 반환', () async {
    final rawNickname = List.generate(51, (_) => 'a').join();

    final result = await usecase.execute(rawNickname);

    expect(result.isLeft(), true);
    result.fold(
      (failure) => expect(failure, isA<DisplayNameFailure>()),
      (_) => fail('Left가 와야 함'),
    );

    result.fold(
      (failure) => expect(failure.message, '닉네임은 50자 이하로 입력해주세요'),
      (_) => null,
    );
  });
}

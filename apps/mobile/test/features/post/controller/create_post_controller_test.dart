import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/features/post/controller/create_post_controller.dart';
import 'package:runway/features/post/model/create_post_selected_portfolio.dart';
import 'package:runway/features/post/usecase/create_post_usecase.dart';

class MockCreatePostUseCase extends Mock implements CreatePostUseCase {}

void main() {
  late MockCreatePostUseCase useCase;
  late CreatePostController controller;

  const portfolio1 = CreatePostSelectedPortfolio(
    id: 'portfolio-1',
    name: '포트폴리오 1',
    assetCount: 3,
    periodMonths: 12,
  );

  const portfolio2 = CreatePostSelectedPortfolio(
    id: 'portfolio-2',
    name: '포트폴리오 2',
    assetCount: 5,
    periodMonths: 24,
  );

  setUp(() {
    useCase = MockCreatePostUseCase();
    controller = CreatePostController(useCase: useCase);
  });

  group('CreatePostController', () {
    test('초기 상태는 기본값이다', () {
      expect(controller.state.content, '');
      expect(controller.state.selectedPortfolio, null);
      expect(controller.state.isSubmitting, false);
      expect(controller.state.isSuccess, false);
      expect(controller.state.error, null);
      expect(controller.state.shouldShowPortfolioDeletedMessage, false);
    });

    test('updateContent 시 content가 반영되고 error/isSuccess가 초기화된다', () {
      controller.updateContent('테스트 내용');

      expect(controller.state.content, '테스트 내용');
      expect(controller.state.error, null);
      expect(controller.state.isSuccess, false);
    });

    test('selectPortfolio 시 selectedPortfolio가 반영되고 관련 플래그가 초기화된다', () {
      controller.selectPortfolio(portfolio1);

      expect(controller.state.selectedPortfolio, portfolio1);
      expect(controller.state.error, null);
      expect(controller.state.isSuccess, false);
      expect(controller.state.shouldShowPortfolioDeletedMessage, false);
    });

    test(
      'clearSelectedPortfolio 시 selectedPortfolio가 null이 되고 삭제 메시지 플래그가 true가 된다',
      () {
        controller.selectPortfolio(portfolio1);

        controller.clearSelectedPortfolio();

        expect(controller.state.selectedPortfolio, null);
        expect(controller.state.error, null);
        expect(controller.state.isSuccess, false);
        expect(controller.state.shouldShowPortfolioDeletedMessage, true);
      },
    );

    test('포트폴리오 변경 시 새 포트폴리오로 교체된다', () {
      controller.selectPortfolio(portfolio1);

      controller.selectPortfolio(portfolio2);

      expect(controller.state.selectedPortfolio, portfolio2);
    });

    test(
      'clearDeletedMessage 시 shouldShowPortfolioDeletedMessage가 false가 된다',
      () {
        controller.selectPortfolio(portfolio1);
        controller.clearSelectedPortfolio();

        controller.clearDeletedMessage();

        expect(controller.state.shouldShowPortfolioDeletedMessage, false);
      },
    );

    test('clearSuccess 시 isSuccess가 false가 된다', () async {
      when(
        () => useCase.execute(
          content: any(named: 'content'),
          portfolioId: any(named: 'portfolioId'),
        ),
      ).thenAnswer((_) async => const Right(null));

      controller.updateContent('성공 테스트');
      await controller.submitPost();

      expect(controller.state.isSuccess, true);

      controller.clearSuccess();

      expect(controller.state.isSuccess, false);
    });

    test('clearError 시 error가 null이 된다', () async {
      when(
        () => useCase.execute(
          content: any(named: 'content'),
          portfolioId: any(named: 'portfolioId'),
        ),
      ).thenAnswer((_) async => const Left(ServerFailure('서버 원본 메시지')));

      controller.updateContent('실패 테스트');
      await controller.submitPost();

      // failure_extension.dart 에서 ServerFailure는 원본 message를 그대로 노출한다.
      expect(controller.state.error, '서버 원본 메시지');

      controller.clearError();

      expect(controller.state.error, null);
    });

    test('submitPost 성공 시 로딩 후 성공 상태가 된다', () async {
      when(
        () => useCase.execute(
          content: any(named: 'content'),
          portfolioId: any(named: 'portfolioId'),
        ),
      ).thenAnswer((_) async => const Right(null));

      controller.updateContent('게시글 내용');
      controller.selectPortfolio(portfolio1);

      final states = <dynamic>[];
      controller.addListener(states.add);

      await controller.submitPost();

      verify(
        () => useCase.execute(content: '게시글 내용', portfolioId: 'portfolio-1'),
      ).called(1);

      expect(states.isNotEmpty, true);
      expect(states.any((state) => state.isSubmitting == true), true);

      expect(controller.state.isSubmitting, false);
      expect(controller.state.isSuccess, true);
      expect(controller.state.error, null);
    });

    test('submitPost 실패 시 로딩 후 에러 상태가 된다', () async {
      when(
        () => useCase.execute(
          content: any(named: 'content'),
          portfolioId: any(named: 'portfolioId'),
        ),
      ).thenAnswer((_) async => const Left(ServerFailure('서버 원본 메시지')));

      controller.updateContent('게시글 내용');
      controller.selectPortfolio(portfolio1);

      final states = <dynamic>[];
      controller.addListener(states.add);

      await controller.submitPost();

      verify(
        () => useCase.execute(content: '게시글 내용', portfolioId: 'portfolio-1'),
      ).called(1);

      expect(states.any((state) => state.isSubmitting == true), true);

      expect(controller.state.isSubmitting, false);
      expect(controller.state.isSuccess, false);
      // 여기서도 공통 문구가 아니라 원본 메시지가 노출되는 게 현재 정책이다.
      expect(controller.state.error, '서버 원본 메시지');
    });

    test('submitPost 시 portfolio가 없으면 portfolioId null로 호출한다', () async {
      when(
        () => useCase.execute(
          content: any(named: 'content'),
          portfolioId: any(named: 'portfolioId'),
        ),
      ).thenAnswer((_) async => const Right(null));

      controller.updateContent('포트폴리오 없이 작성');

      await controller.submitPost();

      verify(
        () => useCase.execute(content: '포트폴리오 없이 작성', portfolioId: null),
      ).called(1);

      expect(controller.state.isSuccess, true);
    });

    test('reset 시 상태가 초기값으로 돌아간다', () {
      controller.updateContent('초기화 전');
      controller.selectPortfolio(portfolio1);

      controller.reset();

      expect(controller.state.content, '');
      expect(controller.state.selectedPortfolio, null);
      expect(controller.state.isSubmitting, false);
      expect(controller.state.isSuccess, false);
      expect(controller.state.error, null);
      expect(controller.state.shouldShowPortfolioDeletedMessage, false);
    });
  });
}

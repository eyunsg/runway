import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:runway/core/error/failure.dart';
import 'package:runway/features/post/controller/update_post_controller.dart';
import 'package:runway/features/post/model/create_post_selected_portfolio.dart';
import 'package:runway/features/post/model/post.dart';
import 'package:runway/features/post/types/update_post_state.dart';
import 'package:runway/features/post/usecase/update_post_usecase.dart';

class MockUpdatePostUsecase extends Mock implements UpdatePostUsecase {}

void main() {
  late UpdatePostController controller;
  late MockUpdatePostUsecase mockUsecase;

  Post createDummyPost({
    String postId = 'post-1',
    String content = 'original content',
    String portfolioName = 'My Portfolio',
    int assetCount = 5,
    int investmentPeriodMonths = 12,
  }) {
    return Post(
      postId: postId,
      content: content,
      authorDisplayName: 'tester',
      portfolioName: portfolioName,
      assetCount: assetCount,
      investmentPeriodMonths: investmentPeriodMonths,
      createdAt: DateTime(2024, 1, 1),
      commentCount: 3,
    );
  }

  CreatePostSelectedPortfolio createDummyPortfolio({
    String id = 'portfolio-1',
    String name = 'Updated Portfolio',
    int assetCount = 7,
    int periodMonths = 24,
  }) {
    return CreatePostSelectedPortfolio(
      id: id,
      name: name,
      assetCount: assetCount,
      periodMonths: periodMonths,
    );
  }

  setUp(() {
    mockUsecase = MockUpdatePostUsecase();
    controller = UpdatePostController(useCase: mockUsecase);
  });

  group('initialize', () {
    test('post 정보로 state를 초기화한다', () {
      final post = createDummyPost();

      controller.initialize(post);

      expect(controller.state.postId, 'post-1');
      expect(controller.state.content, 'original content');
      expect(controller.state.selectedPortfolio, isNotNull);
      expect(controller.state.selectedPortfolio!.id, '');
      expect(controller.state.selectedPortfolio!.name, 'My Portfolio');
      expect(controller.state.selectedPortfolio!.assetCount, 5);
      expect(controller.state.selectedPortfolio!.periodMonths, 12);
      expect(controller.state.isInitialized, true);
      expect(controller.state.isPortfolioChanged, false);
      expect(controller.state.isPortfolioRemoved, false);
      expect(controller.state.error, isNull);
      expect(controller.state.isSuccess, false);
      expect(controller.state.isSubmitting, false);
    });

    test('portfolioName이 비어 있으면 selectedPortfolio는 null이다', () {
      final post = createDummyPost(portfolioName: '   ');

      controller.initialize(post);

      expect(controller.state.postId, 'post-1');
      expect(controller.state.content, 'original content');
      expect(controller.state.selectedPortfolio, isNull);
      expect(controller.state.isInitialized, true);
    });

    test('같은 postId로 initialize를 다시 호출하면 상태를 유지한다', () {
      final post = createDummyPost();
      controller.initialize(post);
      controller.updateContent('changed content');

      controller.initialize(post);

      expect(controller.state.content, 'changed content');
    });
  });

  group('state update', () {
    test('updateContent는 content를 변경하고 isSuccess를 false로 만든다', () {
      controller.updateContent('new content');

      expect(controller.state.content, 'new content');
      expect(controller.state.isSuccess, false);
    });

    test('selectPortfolio는 선택 포트폴리오를 반영한다', () {
      final portfolio = createDummyPortfolio();

      controller.selectPortfolio(portfolio);

      expect(controller.state.selectedPortfolio, isNotNull);
      expect(controller.state.selectedPortfolio!.id, 'portfolio-1');
      expect(controller.state.selectedPortfolio!.name, 'Updated Portfolio');
      expect(controller.state.isPortfolioChanged, true);
      expect(controller.state.isPortfolioRemoved, false);
      expect(controller.state.shouldShowPortfolioDeletedMessage, false);
      expect(controller.state.error, isNull);
      expect(controller.state.isSuccess, false);
    });

    test('clearSelectedPortfolio는 포트폴리오를 제거하고 삭제 메시지 플래그를 true로 만든다', () {
      controller.selectPortfolio(createDummyPortfolio());

      controller.clearSelectedPortfolio();

      expect(controller.state.selectedPortfolio, isNull);
      expect(controller.state.shouldShowPortfolioDeletedMessage, true);
      expect(controller.state.isPortfolioChanged, true);
      expect(controller.state.isPortfolioRemoved, true);
      expect(controller.state.error, isNull);
      expect(controller.state.isSuccess, false);
    });

    test('reset은 초기 상태로 되돌린다', () {
      controller.initialize(createDummyPost());
      controller.updateContent('changed');
      controller.clearSelectedPortfolio();

      controller.reset();

      expect(controller.state, const UpdatePostState());
    });
  });

  group('submitUpdate', () {
    test('성공 시 isSubmitting false, isSuccess true로 변경된다', () async {
      controller.initialize(createDummyPost());
      controller.updateContent('updated content');
      controller.selectPortfolio(createDummyPortfolio());

      when(
        () => mockUsecase.execute(
          postId: 'post-1',
          content: 'updated content',
          portfolioId: 'portfolio-1',
          isPortfolioRemoved: false,
        ),
      ).thenAnswer((_) async => const Right(null));

      final states = <UpdatePostState>[];
      controller.addListener((state) => states.add(state));

      await controller.submitUpdate();

      verify(
        () => mockUsecase.execute(
          postId: 'post-1',
          content: 'updated content',
          portfolioId: 'portfolio-1',
          isPortfolioRemoved: false,
        ),
      ).called(1);

      expect(states.length, 3);

      expect(states[0].isSubmitting, false);
      expect(states[0].error, isNull);
      expect(states[0].isSuccess, false);

      expect(states[1].isSubmitting, true);
      expect(states[1].error, isNull);
      expect(states[1].isSuccess, false);

      expect(states[2].isSubmitting, false);
      expect(states[2].error, isNull);
      expect(states[2].isSuccess, true);
    });

    test('실패 시 error를 세팅하고 isSuccess는 false다', () async {
      controller.initialize(createDummyPost());
      controller.updateContent('updated content');

      when(
        () => mockUsecase.execute(
          postId: 'post-1',
          content: 'updated content',
          portfolioId: '',
          isPortfolioRemoved: false,
        ),
      ).thenAnswer((_) async => Left(ServerFailure('server error')));

      final states = <UpdatePostState>[];
      controller.addListener((state) => states.add(state));

      await controller.submitUpdate();

      verify(
        () => mockUsecase.execute(
          postId: 'post-1',
          content: 'updated content',
          portfolioId: '',
          isPortfolioRemoved: false,
        ),
      ).called(1);

      expect(states.length, 3);

      expect(states[0].isSubmitting, false);
      expect(states[0].error, isNull);
      expect(states[0].isSuccess, false);

      expect(states[1].isSubmitting, true);
      expect(states[1].error, isNull);
      expect(states[1].isSuccess, false);

      expect(states[2].isSubmitting, false);
      expect(states[2].error, 'server error');
      expect(states[2].isSuccess, false);
    });

    test('포트폴리오 삭제 상태면 isPortfolioRemoved=true로 전달한다', () async {
      controller.initialize(createDummyPost());
      controller.clearSelectedPortfolio();

      when(
        () => mockUsecase.execute(
          postId: 'post-1',
          content: 'original content',
          portfolioId: null,
          isPortfolioRemoved: true,
        ),
      ).thenAnswer((_) async => const Right(null));

      await controller.submitUpdate();

      verify(
        () => mockUsecase.execute(
          postId: 'post-1',
          content: 'original content',
          portfolioId: null,
          isPortfolioRemoved: true,
        ),
      ).called(1);
    });
  });
}

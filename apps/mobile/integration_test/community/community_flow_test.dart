import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:runway/features/comment/dto/comment_response_dto.dart';
import 'package:runway/features/post/dto/create_comment_request_dto.dart';
import 'package:runway/features/post/dto/create_post_request_dto.dart';
import 'package:runway/features/post/dto/my_post_response_dto.dart';
import 'package:runway/features/post/dto/post_detail_response_dto.dart';
import 'package:runway/features/post/dto/post_response_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../helpers/test_setup.dart';
import '../helpers/test_utils.dart';

void main() {
  late SupabaseClient client;
  late SupabaseClient adminClient;

  const password = '123456';

  setUpAll(() async {
    client = await initTestSupabase();

    adminClient = SupabaseClient(
      const String.fromEnvironment('SUPABASE_URL'),
      const String.fromEnvironment('SUPABASE_SERVICE_ROLE_KEY'),
    );
  });

  setUp(() async {
    await client.auth.signOut();
    await client.rpc('reset_test_data');
  });

  String generateEmail() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(10000);
    return 'test_${timestamp}_$random@test.com';
  }

  bool isUuidV4Like(String value) {
    final regex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return regex.hasMatch(value);
  }

  Map<String, dynamic> toMap(dynamic data, {required String context}) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);

    fail('$context: 응답 데이터가 Map이 아닙니다. actual=${data.runtimeType}');
  }

  Future<({String email, String userId})> createAndLoginUser({
    required String displayName,
  }) async {
    final email = generateEmail();

    await signUp(
      client,
      email: email,
      password: password,
      displayName: displayName,
    );

    final loginRes = await login(client, email: email, password: password);

    final userId = loginRes.user!.id;

    expect(userId.isNotEmpty, true);
    expect(isUuidV4Like(userId), true);

    return (email: email, userId: userId);
  }

  Future<String> createPortfolio({required String userId}) async {
    const portfolioName = 'community portfolio';

    final simulationInput = <String, dynamic>{
      'goal': <String, dynamic>{
        'investment_period_months': 120,
        'target_portfolio_value': 10000000,
        'target_monthly_dividend': 100000,
      },
      'assets': <Map<String, dynamic>>[
        <String, dynamic>{
          'asset_name': 'test asset',
          'asset_type': 'INDEX',
          'initial_price': 50000,
          'expected_annual_price_growth_rate': 7,
          'initial_investment_amount': 2000000,
          'monthly_contribution_amount': 100000,
          'is_dividend_asset': true,
          'dividend_per_share': 383,
          'expected_annual_dividend_growth_rate': 8,
          'dividend_frequency': 4,
          'is_reinvest_dividends': true,
        },
      ],
    };

    final simulationResult = <String, dynamic>{
      'percentiles': <String, dynamic>{
        'portfolio_value': <String, dynamic>{
          'p10': 100.0,
          'p50': 200.0,
          'p90': 300.0,
        },
        'monthly_dividend': <String, dynamic>{
          'p10': 10.0,
          'p50': 20.0,
          'p90': 30.0,
        },
      },
      'goal_analysis': <String, dynamic>{
        'portfolio_value_goal': <String, dynamic>{
          'expected_months_to_target': 12,
        },
        'monthly_dividend_goal': <String, dynamic>{
          'expected_months_to_target': 24,
        },
      },
    };

    final insertedPortfolio = await client
        .from('portfolios')
        .insert(<String, dynamic>{
          'user_id': userId,
          'name': portfolioName,
          'simulation_input': simulationInput,
          'simulation_result': simulationResult,
        })
        .select('id')
        .single();

    final portfolioId = insertedPortfolio['id'].toString();

    expect(isUuidV4Like(portfolioId), true);

    return portfolioId;
  }

  Future<String> createPost({required String portfolioId}) async {
    final postContent =
        'integration test post ${DateTime.now().toIso8601String()}';

    final dto = CreatePostRequestDto(
      portfolioId: portfolioId,
      content: postContent,
    );

    final res = await client.functions.invoke(
      'posts',
      method: HttpMethod.post,
      body: dto.toJson(),
    );

    expect(res.status, 201);

    // Edge Function이 postId를 반환하도록 변경했으므로 목록 조회에 의존하지 않는다.
    // (테스트 병렬 실행/환경 리셋 등으로 인한 플래키를 줄임)
    final bodyMap = toMap(res.data, context: 'POST /posts');
    final data = bodyMap['data'];
    if (data is! Map) {
      fail('POST /posts: data가 Map이 아닙니다. actual=${data.runtimeType}');
    }
    final postId = (data['postId'] as String?) ?? '';
    expect(postId.isNotEmpty, true);
    expect(isUuidV4Like(postId), true);

    // GET /posts/{id}가 가능해질 때까지 짧게 retry (eventual consistency/트리거 지연 대비)
    for (var i = 0; i < 10; i++) {
      final detailRes = await client.functions.invoke(
        'posts/$postId',
        method: HttpMethod.get,
      );

      if (detailRes.status == 200) {
        final detailMap = toMap(detailRes.data, context: 'GET /posts/{id}');
        final dto = PostDetailResponseDto.fromJson(detailMap);
        if (dto.post.postId == postId && dto.post.content == postContent) {
          return postId;
        }
      }

      await Future<void>.delayed(Duration(milliseconds: 200 * (i + 1)));
    }

    fail('POST /posts 이후 상세 조회에서 게시글을 찾지 못했습니다. postId=$postId');
  }

  Future<String> createComment({required String postId}) async {
    const commentContent = 'integration test comment';

    final dto = CreateCommentRequestDto(content: commentContent);

    final res = await client.functions.invoke(
      'create-comment/posts/$postId/comments',
      method: HttpMethod.post,
      body: dto.toJson(),
    );

    expect(res.status, 201);

    final commentsRes = await client.functions.invoke(
      'get-comments/posts/$postId/comments',
      method: HttpMethod.get,
    );

    expect(commentsRes.status, 200);

    final commentsMap = toMap(commentsRes.data, context: 'GET comments');

    final commentsDto = GetCommentsResponseDto.fromJson(commentsMap);

    final comment = commentsDto.comments.single;

    return comment.commentId;
  }

  group('Community Post', () {
    test('게시글 생성 후 목록 조회에 포함된다', () async {
      final user = await createAndLoginUser(displayName: 'communityUserA');

      final portfolioId = await createPortfolio(userId: user.userId);

      final postId = await createPost(portfolioId: portfolioId);

      final getPostsRes = await client.functions.invoke(
        'posts',
        method: HttpMethod.get,
      );

      expect(getPostsRes.status, 200);

      final postsMap = toMap(getPostsRes.data, context: 'GET /posts');

      final posts = PostResponseDto.listFromResponseJson(postsMap);

      expect(posts.any((e) => e.postId == postId), true);
    });

    test('생성한 게시글은 내 게시글 목록에 포함된다', () async {
      final user = await createAndLoginUser(displayName: 'communityUserA');

      final portfolioId = await createPortfolio(userId: user.userId);

      final postId = await createPost(portfolioId: portfolioId);

      final myPostsRes = await client.functions.invoke(
        'posts/me',
        method: HttpMethod.get,
      );

      expect(myPostsRes.status, 200);

      final myPostsMap = toMap(myPostsRes.data, context: 'GET /posts/me');

      final myPosts = MyPostResponseDto.listFromResponseJson(myPostsMap);

      expect(myPosts.any((e) => e.postId == postId), true);
    });

    test('게시글 상세 조회 시 snapshot 정보가 포함된다', () async {
      final user = await createAndLoginUser(displayName: 'communityUserA');

      final portfolioId = await createPortfolio(userId: user.userId);

      final postId = await createPost(portfolioId: portfolioId);

      final detailRes = await client.functions.invoke(
        'posts/$postId',
        method: HttpMethod.get,
      );

      expect(detailRes.status, 200);

      final detailMap = toMap(detailRes.data, context: 'GET /posts/{id}');

      final dto = PostDetailResponseDto.fromJson(detailMap);

      expect(dto.post.postId, postId);
      expect(dto.post.portfolioSnapshotId, isNotNull);
      expect(dto.post.assetCount, 1);
      expect(dto.post.investmentPeriodMonths, 120);
    });

    test('다른 사용자는 타인의 게시글을 삭제할 수 없다', () async {
      final userA = await createAndLoginUser(displayName: 'communityUserA');

      final portfolioId = await createPortfolio(userId: userA.userId);

      final postId = await createPost(portfolioId: portfolioId);

      await client.auth.signOut();

      final userB = await createAndLoginUser(displayName: 'communityUserB');

      expect(userB.userId != userA.userId, true);

      expect(
        () async => await client.functions.invoke(
          'posts/$postId',
          method: HttpMethod.delete,
        ),
        throwsA(
          isA<FunctionException>().having((e) => e.status, 'status', 403),
        ),
      );
    });
  });

  group('Community Comment', () {
    test('댓글 생성 시 commentCount가 증가한다', () async {
      final user = await createAndLoginUser(displayName: 'communityUserA');

      final portfolioId = await createPortfolio(userId: user.userId);

      final postId = await createPost(portfolioId: portfolioId);

      await createComment(postId: postId);

      final detailRes = await client.functions.invoke(
        'posts/$postId',
        method: HttpMethod.get,
      );

      expect(detailRes.status, 200);

      final detailMap = toMap(detailRes.data, context: 'GET post detail');

      final dto = PostDetailResponseDto.fromJson(detailMap);

      expect(dto.post.commentCount, 1);
    });

    test('댓글 생성 후 목록 조회에 포함된다', () async {
      final user = await createAndLoginUser(displayName: 'communityUserA');

      final portfolioId = await createPortfolio(userId: user.userId);

      final postId = await createPost(portfolioId: portfolioId);

      final commentId = await createComment(postId: postId);

      final commentsRes = await client.functions.invoke(
        'get-comments/posts/$postId/comments',
        method: HttpMethod.get,
      );

      expect(commentsRes.status, 200);

      final commentsMap = toMap(commentsRes.data, context: 'GET comments');

      final dto = GetCommentsResponseDto.fromJson(commentsMap);

      expect(dto.comments.any((e) => e.commentId == commentId), true);
    });

    test('다른 사용자는 타인의 댓글을 삭제할 수 없다', () async {
      final userA = await createAndLoginUser(displayName: 'communityUserA');

      final portfolioId = await createPortfolio(userId: userA.userId);

      final postId = await createPost(portfolioId: portfolioId);

      final commentId = await createComment(postId: postId);

      await client.auth.signOut();

      final userB = await createAndLoginUser(displayName: 'communityUserB');

      expect(userB.userId != userA.userId, true);

      expect(
        () async => await client.functions.invoke(
          'delete-comments/comments/$commentId',
          method: HttpMethod.delete,
        ),
        throwsA(
          isA<FunctionException>().having((e) => e.status, 'status', 403),
        ),
      );
    });

    test('작성자는 자신의 댓글을 soft delete 할 수 있다', () async {
      final user = await createAndLoginUser(displayName: 'communityUserA');

      final portfolioId = await createPortfolio(userId: user.userId);

      final postId = await createPost(portfolioId: portfolioId);

      final commentId = await createComment(postId: postId);

      final deleteRes = await client.functions.invoke(
        'delete-comments/comments/$commentId',
        method: HttpMethod.delete,
      );

      expect(deleteRes.status, 204);

      final deletedComment = await adminClient
          .from('comments')
          .select('id, deleted_at')
          .eq('id', commentId)
          .maybeSingle();

      expect(deletedComment, isNotNull);

      expect(deletedComment!['deleted_at'], isNotNull);
    });

    test('댓글 삭제 시 commentCount가 감소한다', () async {
      final user = await createAndLoginUser(displayName: 'communityUserA');

      final portfolioId = await createPortfolio(userId: user.userId);

      final postId = await createPost(portfolioId: portfolioId);

      final commentId = await createComment(postId: postId);

      final deleteRes = await client.functions.invoke(
        'delete-comments/comments/$commentId',
        method: HttpMethod.delete,
      );

      expect(deleteRes.status, 204);

      final detailRes = await client.functions.invoke(
        'posts/$postId',
        method: HttpMethod.get,
      );

      expect(detailRes.status, 200);

      final detailMap = toMap(
        detailRes.data,
        context: 'GET post detail after delete',
      );

      final dto = PostDetailResponseDto.fromJson(detailMap);

      expect(dto.post.commentCount, 0);
    });
  });
}

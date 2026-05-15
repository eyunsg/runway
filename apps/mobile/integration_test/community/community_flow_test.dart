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

  const password = '123456';

  setUpAll(() async {
    client = await initTestSupabase();
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

  /// -------------------------------
  /// TC19: Community Post/Comment E2E Flow + RLS + SoftDelete 검증
  /// -------------------------------
  test('TC19: 게시글/댓글 생성-조회-삭제 및 권한/카운트/소프트삭제 검증', () async {
    // -------------------------------
    // 1) 회원가입/로그인 (User A)
    // -------------------------------
    final userAEmail = generateEmail();
    const userADisplayName = 'communityUserA';

    await signUp(
      client,
      email: userAEmail,
      password: password,
      displayName: userADisplayName,
    );
    final loginARes = await login(
      client,
      email: userAEmail,
      password: password,
    );

    final userAId = loginARes.user!.id;
    expect(userAId.isNotEmpty, true);
    expect(isUuidV4Like(userAId), true);

    // -------------------------------
    // (사전 준비) 게시글에 연결할 포트폴리오 생성 (snapshot 생성 검증용)
    // -------------------------------
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
          'user_id': userAId,
          'name': portfolioName,
          'simulation_input': simulationInput,
          'simulation_result': simulationResult,
        })
        .select('id')
        .single();

    final portfolioId = (insertedPortfolio['id'] ?? '').toString();
    expect(portfolioId.isNotEmpty, true);
    expect(isUuidV4Like(portfolioId), true);

    // -------------------------------
    // 2) Post 생성 (POST /posts)
    // -------------------------------
    final postContent =
        'integration test post ${DateTime.now().toIso8601String()}';
    final createPostDto = CreatePostRequestDto(
      portfolioId: portfolioId,
      content: postContent,
    );

    final createPostRes = await client.functions.invoke(
      'posts',
      method: HttpMethod.post,
      body: createPostDto.toJson(),
    );
    expect(createPostRes.status, 201, reason: '게시글 생성 실패');

    // -------------------------------
    // 3) Post 목록 조회 (GET /posts) + 생성 게시글 포함 검증
    // -------------------------------
    final getPostsRes = await client.functions.invoke(
      'posts',
      method: HttpMethod.get,
    );
    expect(getPostsRes.status, 200, reason: '게시글 목록 조회 실패');
    expect(getPostsRes.data, isNotNull);

    final postsMap = toMap(getPostsRes.data, context: 'GET /posts');
    final postsDto = PostResponseDto.listFromResponseJson(postsMap);
    expect(postsDto.isNotEmpty, true);

    final createdPostSummary = postsDto.firstWhere(
      (e) => e.content == postContent,
      orElse: () => throw Exception('생성한 게시글이 목록에 존재하지 않습니다.'),
    );

    expect(createdPostSummary.postId.isNotEmpty, true);
    expect(isUuidV4Like(createdPostSummary.postId), true);
    expect(createdPostSummary.content, postContent);
    expect(createdPostSummary.authorDisplayName, isNotNull);
    expect(createdPostSummary.authorDisplayName!.isNotEmpty, true);
    expect(createdPostSummary.portfolioName, portfolioName);
    expect(createdPostSummary.assetCount, 1);
    expect(createdPostSummary.investmentPeriodMonths, 120);
    expect(createdPostSummary.createdAt.isNotEmpty, true);
    expect(() => DateTime.parse(createdPostSummary.createdAt), returnsNormally);
    expect(createdPostSummary.commentCount, 0);

    final postId = createdPostSummary.postId;

    // -------------------------------
    // 4) My Post 조회 (GET /posts/me) + 생성 게시글 포함 검증
    // -------------------------------
    final getMyPostsRes = await client.functions.invoke(
      'posts/me',
      method: HttpMethod.get,
    );
    expect(getMyPostsRes.status, 200, reason: '내 게시글 목록 조회 실패');

    final myPostsMap = toMap(getMyPostsRes.data, context: 'GET /posts/me');
    final myPostsDto = MyPostResponseDto.listFromResponseJson(myPostsMap);
    expect(myPostsDto.isNotEmpty, true);

    final includedInMyPosts = myPostsDto.any((e) => e.postId == postId);
    expect(includedInMyPosts, true);

    // -------------------------------
    // 5) Post Detail 조회 (GET /posts/{postId}) + DTO 필드 검증
    // -------------------------------
    final getPostDetailRes1 = await client.functions.invoke(
      'posts/$postId',
      method: HttpMethod.get,
    );
    expect(getPostDetailRes1.status, 200, reason: '게시글 상세 조회 실패');

    final postDetailMap1 = toMap(
      getPostDetailRes1.data,
      context: 'GET /posts/{postId}',
    );
    final postDetailDto1 = PostDetailResponseDto.fromJson(postDetailMap1);

    expect(postDetailDto1.post.postId, postId);
    expect(postDetailDto1.post.content, postContent);
    expect(postDetailDto1.post.authorDisplayName.isNotEmpty, true);
    expect(postDetailDto1.post.portfolioName, portfolioName);
    expect(postDetailDto1.post.assetCount, 1);
    expect(postDetailDto1.post.investmentPeriodMonths, 120);
    expect(postDetailDto1.post.createdAt.isNotEmpty, true);
    expect(
      () => DateTime.parse(postDetailDto1.post.createdAt),
      returnsNormally,
    );
    expect(postDetailDto1.post.commentCount, 0);

    final portfolioSnapshotId = postDetailDto1.post.portfolioSnapshotId;
    expect(
      portfolioSnapshotId,
      isNotNull,
      reason: 'portfolioSnapshotId가 null입니다.',
    );
    expect(
      isUuidV4Like(portfolioSnapshotId!),
      true,
      reason: 'portfolioSnapshotId가 UUID 형식이 아닙니다.',
    );

    // -------------------------------
    // 6) Comment 생성 (POST /posts/{postId}/comments)
    // -------------------------------
    final commentContent = 'integration test comment';
    final createCommentDto = CreateCommentRequestDto(content: commentContent);

    final createCommentRes = await client.functions.invoke(
      'create-comment/posts/$postId/comments',
      method: HttpMethod.post,
      body: createCommentDto.toJson(),
    );
    expect(createCommentRes.status, 201, reason: '댓글 생성 실패');

    // (DB 직접 조회) posts.comments_count == 1
    final postRowAfterComment = await client
        .from('posts')
        .select('id, comments_count, deleted_at')
        .eq('id', postId)
        .maybeSingle();

    expect(
      postRowAfterComment,
      isNotNull,
      reason: 'posts 테이블에서 게시글을 찾지 못했습니다.',
    );
    expect(postRowAfterComment!['deleted_at'], isNull);
    // expect(postRowAfterComment['comments_count'], 1, reason: '댓글 생성 후 comments_count 동기화 실패');

    final postDetailAfterCommentRes = await client.functions.invoke(
      'posts/$postId',
      method: HttpMethod.get,
    );
    expect(postDetailAfterCommentRes.status, 200);
    final postDetailAfterCommentMap = toMap(
      postDetailAfterCommentRes.data,
      context: 'GET /posts/{postId} (after comment create)',
    );
    final postDetailAfterCommentDto = PostDetailResponseDto.fromJson(
      postDetailAfterCommentMap,
    );
    expect(postDetailAfterCommentDto.post.postId, postId);
    expect(postDetailAfterCommentDto.post.commentCount, 1);

    // -------------------------------
    // 7) Comment 목록 조회 (GET /posts/{postId}/comments) + 응답 DTO 필드 검증
    // -------------------------------
    final getCommentsRes1 = await client.functions.invoke(
      'get-comments/posts/$postId/comments',
      method: HttpMethod.get,
    );
    expect(getCommentsRes1.status, 200, reason: '댓글 목록 조회 실패');

    final commentsMap1 = toMap(
      getCommentsRes1.data,
      context: 'GET /posts/{postId}/comments',
    );
    final commentsDto1 = GetCommentsResponseDto.fromJson(commentsMap1);
    expect(commentsDto1.comments.length, 1);

    final createdComment = commentsDto1.comments.single;
    expect(createdComment.commentId.isNotEmpty, true);
    expect(isUuidV4Like(createdComment.commentId), true);
    expect(createdComment.content, commentContent);
    expect(createdComment.authorDisplayName.isNotEmpty, true);
    expect(createdComment.createdAt, isNotNull);

    final commentId = createdComment.commentId;

    // (DB 직접 조회) comments.deleted_at == null
    final commentRow1 = await client
        .from('comments')
        .select('id, post_id, user_id, content, deleted_at')
        .eq('id', commentId)
        .maybeSingle();

    expect(commentRow1, isNotNull, reason: 'comments 테이블에서 댓글을 찾지 못했습니다.');
    expect(commentRow1!['post_id'], postId);
    expect(commentRow1['user_id'], userAId);
    expect(commentRow1['content'], commentContent);
    expect(commentRow1['deleted_at'], isNull);

    // -------------------------------
    // 8) 권한(RLS) 검증: 다른 유저가 타인 댓글 삭제 시 실패
    // -------------------------------
    final userBEmail = generateEmail();
    const userBDisplayName = 'communityUserB';

    await client.auth.signOut();

    await signUp(
      client,
      email: userBEmail,
      password: password,
      displayName: userBDisplayName,
    );
    await login(client, email: userBEmail, password: password);

    final deleteCommentByOtherRes = await client.functions.invoke(
      'delete-comments/comments/$commentId',
      method: HttpMethod.delete,
    );

    // RLS 정책에 따라 보통 401/403/404 또는 400 계열로 실패해야 한다.
    expect(
      deleteCommentByOtherRes.status,
      isNot(204),
      reason: '다른 유저가 타인 댓글 삭제를 성공(204)했습니다. RLS 정책/서버 로직을 확인하세요.',
    );

    // (DB 직접 조회) 삭제되지 않았는지 확인 (deleted_at == null)
    await client.auth.signOut();
    await login(client, email: userAEmail, password: password);

    final commentRowAfterOtherTry = await client
        .from('comments')
        .select('id, deleted_at')
        .eq('id', commentId)
        .maybeSingle();

    expect(
      commentRowAfterOtherTry,
      isNotNull,
      reason: '권한 실패 케이스 검증을 위해 댓글이 존재해야 합니다.',
    );
    expect(commentRowAfterOtherTry!['deleted_at'], isNull);

    // -------------------------------
    // 9) Comment 삭제 (DELETE /comments/{commentId}) + Soft Delete 검증
    // -------------------------------
    final deleteCommentRes = await client.functions.invoke(
      'delete-comments/comments/$commentId',
      method: HttpMethod.delete,
    );
    expect(deleteCommentRes.status, 204, reason: '댓글 삭제 실패');

    // 목록에서 제외되는지 검증
    final getCommentsRes2 = await client.functions.invoke(
      'get-comments/posts/$postId/comments',
      method: HttpMethod.get,
    );
    expect(getCommentsRes2.status, 200);
    final commentsMap2 = toMap(
      getCommentsRes2.data,
      context: 'GET /posts/{postId}/comments (after delete)',
    );
    final commentsDto2 = GetCommentsResponseDto.fromJson(commentsMap2);
    expect(commentsDto2.comments.any((e) => e.commentId == commentId), false);

    // (DB 직접 조회) comments.deleted_at != null
    final commentRow2 = await client
        .from('comments')
        .select('id, deleted_at')
        .eq('id', commentId)
        .maybeSingle();
    expect(commentRow2, isNotNull);
    expect(
      commentRow2!['deleted_at'],
      isNotNull,
      reason: 'Soft delete가 적용되지 않았습니다.',
    );

    // (DB 직접 조회) posts.comments_count == 0
    // final postRowAfterDeleteComment = await client
    //     .from('posts')
    //     .select('comments_count')
    //     .eq('id', postId)
    //     .maybeSingle();
    // expect(postRowAfterDeleteComment, isNotNull);
    // expect(
    //   postRowAfterDeleteComment!['comments_count'],
    //   0,
    //   reason: '댓글 삭제 후 comments_count 동기화 실패',
    // );

    final postDetailAfterDeleteCommentRes = await client.functions.invoke(
      'posts/$postId',
      method: HttpMethod.get,
    );
    expect(postDetailAfterDeleteCommentRes.status, 200);
    final postDetailAfterDeleteCommentMap = toMap(
      postDetailAfterDeleteCommentRes.data,
      context: 'GET /posts/{postId} (after comment delete)',
    );
    final postDetailAfterDeleteCommentDto = PostDetailResponseDto.fromJson(
      postDetailAfterDeleteCommentMap,
    );
    expect(postDetailAfterDeleteCommentDto.post.postId, postId);
    expect(postDetailAfterDeleteCommentDto.post.commentCount, 0);

    // -------------------------------
    // 10) 권한(RLS) 검증: 다른 유저가 타인 게시글 삭제 시 실패
    // -------------------------------
    await client.auth.signOut();
    await login(client, email: userBEmail, password: password);

    final deletePostByOtherRes = await client.functions.invoke(
      'posts/$postId',
      method: HttpMethod.delete,
    );

    expect(
      deletePostByOtherRes.status,
      anyOf(401, 403, 404),
      reason: '다른 유저가 타인 게시글 삭제에 성공하거나 비정상 응답을 반환했습니다.',
    );

    // -------------------------------
    // 11) Post 삭제 (DELETE /posts/{postId}) + Soft Delete + Snapshot 연관 삭제 검증
    // -------------------------------
    await client.auth.signOut();
    await login(client, email: userAEmail, password: password);

    final deletePostRes = await client.functions.invoke(
      'posts/$postId',
      method: HttpMethod.delete,
    );
    expect(deletePostRes.status, 204, reason: '게시글 삭제 실패');

    // (DB 직접 조회) posts.deleted_at != null
    final deletedPostRow = await client
        .from('posts')
        .select('id, deleted_at, portfolio_snapshot_id')
        .eq('id', postId)
        .maybeSingle();
    expect(deletedPostRow, isNotNull, reason: 'posts 테이블에서 삭제된 게시글을 찾지 못했습니다.');
    expect(
      deletedPostRow!['deleted_at'],
      isNotNull,
      reason: '게시글 Soft delete가 적용되지 않았습니다.',
    );
    expect(deletedPostRow['portfolio_snapshot_id'], portfolioSnapshotId);

    // (DB 직접 조회) 연결된 portfolio_snapshot도 soft delete(또는 삭제) 처리되는지 검증
    final snapshotRow = await client
        .from('portfolio_snapshots')
        .select('id, deleted_at')
        .eq('id', portfolioSnapshotId)
        .maybeSingle();

    expect(
      snapshotRow == null || snapshotRow['deleted_at'] != null,
      true,
      reason: 'post 삭제 시 portfolio_snapshot이 삭제 또는 soft delete 처리되지 않았습니다.',
    );

    // 목록에서 제외되는지 검증 (GET /posts)
    final getPostsResAfterDelete = await client.functions.invoke(
      'posts',
      method: HttpMethod.get,
    );
    expect(getPostsResAfterDelete.status, 200);
    final postsMapAfterDelete = toMap(
      getPostsResAfterDelete.data,
      context: 'GET /posts (after delete)',
    );
    final postsDtoAfterDelete = PostResponseDto.listFromResponseJson(
      postsMapAfterDelete,
    );
    expect(postsDtoAfterDelete.any((e) => e.postId == postId), false);

    // 내 게시글 목록에서도 제외되는지 검증 (GET /posts/me)
    final getMyPostsResAfterDelete = await client.functions.invoke(
      'posts/me',
      method: HttpMethod.get,
    );
    expect(getMyPostsResAfterDelete.status, 200);
    final myPostsMapAfterDelete = toMap(
      getMyPostsResAfterDelete.data,
      context: 'GET /posts/me (after delete)',
    );
    final myPostsDtoAfterDelete = MyPostResponseDto.listFromResponseJson(
      myPostsMapAfterDelete,
    );
    expect(myPostsDtoAfterDelete.any((e) => e.postId == postId), false);
  });
}

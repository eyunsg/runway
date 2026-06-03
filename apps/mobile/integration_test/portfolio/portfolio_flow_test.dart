import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../helpers/test_setup.dart';
import '../helpers/test_utils.dart';

void main() {
  late SupabaseClient client;
  late String portfolioId;

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

  test('TC18: 포트폴리오 생성/목록/상세/삭제 플로우', () async {
    final email = generateEmail();

    await signUp(
      client,
      email: email,
      password: password,
      displayName: 'portfolioUser',
    );
    final loginRes = await login(client, email: email, password: password);
    final userId = loginRes.user!.id;

    final name = 'test portfolio';

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

    final inserted = await client
        .from('portfolios')
        .insert({
          'user_id': userId,
          'name': name,
          'simulation_input': simulationInput,
          'simulation_result': simulationResult,
        })
        .select('id')
        .single();

    portfolioId = inserted['id'] as String;
    expect(portfolioId.isNotEmpty, true);

    final listRes1 = await client.functions.invoke(
      'portfolios',
      method: HttpMethod.get,
    );
    expect(listRes1.status, 200);
    expect(listRes1.data, isNotNull);

    final portfolios1 = (listRes1.data['portfolios'] as List).cast<dynamic>();
    final included = portfolios1.any((e) {
      if (e is Map) {
        return e['portfolioId'] == portfolioId;
      }
      return false;
    });
    expect(included, true);

    final createdSummary = portfolios1.firstWhere(
      (e) => e is Map && e['portfolioId'] == portfolioId,
      orElse: () => null,
    );
    expect(createdSummary != null, true);
    if (createdSummary is Map) {
      expect(createdSummary['name'], name);
      expect(createdSummary['assetCount'], 1);
      expect(createdSummary['investmentPeriodMonths'], 120);
      expect(createdSummary['updatedAt'], isNotNull);
    }

    final detailRes = await client.functions.invoke(
      'portfolios/$portfolioId',
      method: HttpMethod.get,
    );
    expect(detailRes.status, 200);
    expect(detailRes.data, isNotNull);

    final detail = detailRes.data as Map<String, dynamic>;
    expect(detail['name'], name);

    final detailInput = detail['simulationInput'] as Map<String, dynamic>;
    final detailGoal = detailInput['goal'] as Map<String, dynamic>;

    expect(
      (detailGoal['investmentPeriodMonths'] as num).toInt(),
      (simulationInput['goal']
          as Map<String, dynamic>)['investment_period_months'],
    );
    expect(
      (detailGoal['targetPortfolioValue'] as num).toInt(),
      (simulationInput['goal']
          as Map<String, dynamic>)['target_portfolio_value'],
    );
    expect(
      (detailGoal['targetMonthlyDividend'] as num).toInt(),
      (simulationInput['goal']
          as Map<String, dynamic>)['target_monthly_dividend'],
    );

    final detailAssets = (detailInput['assets'] as List).cast<dynamic>();
    expect(detailAssets.isNotEmpty, true);

    final asset = detailAssets.first as Map<String, dynamic>;
    final expectedAsset =
        (simulationInput['assets'] as List).first as Map<String, dynamic>;

    expect(asset['assetName'], expectedAsset['asset_name']);
    expect(asset['assetType'], expectedAsset['asset_type']);
    expect(
      (asset['initialPrice'] as num).toDouble(),
      (expectedAsset['initial_price'] as num).toDouble(),
    );
    expect(
      (asset['expectedAnnualPriceGrowthRate'] as num).toDouble(),
      (expectedAsset['expected_annual_price_growth_rate'] as num).toDouble(),
    );
    expect(
      (asset['initialInvestmentAmount'] as num).toInt(),
      expectedAsset['initial_investment_amount'],
    );
    expect(
      (asset['monthlyContributionAmount'] as num).toInt(),
      expectedAsset['monthly_contribution_amount'],
    );
    expect(asset['isDividendAsset'], expectedAsset['is_dividend_asset']);
    expect(
      (asset['dividendPerShare'] as num).toDouble(),
      (expectedAsset['dividend_per_share'] as num).toDouble(),
    );
    expect(
      (asset['expectedAnnualDividendGrowthRate'] as num).toDouble(),
      (expectedAsset['expected_annual_dividend_growth_rate'] as num).toDouble(),
    );
    expect(
      (asset['dividendFrequency'] as num).toInt(),
      expectedAsset['dividend_frequency'],
    );
    expect(
      asset['isReinvestDividends'],
      expectedAsset['is_reinvest_dividends'],
    );

    final detailResult = detail['simulationResult'] as Map<String, dynamic>;
    final detailPercentiles =
        detailResult['percentiles'] as Map<String, dynamic>;

    final pv = detailPercentiles['portfolioValue'] as Map<String, dynamic>;
    final md = detailPercentiles['monthlyDividend'] as Map<String, dynamic>;

    final expectedPercentiles =
        simulationResult['percentiles'] as Map<String, dynamic>;
    final expectedPv =
        expectedPercentiles['portfolio_value'] as Map<String, dynamic>;
    final expectedMd =
        expectedPercentiles['monthly_dividend'] as Map<String, dynamic>;

    expect(
      (pv['p10'] as num).toDouble(),
      (expectedPv['p10'] as num).toDouble(),
    );
    expect(
      (pv['p50'] as num).toDouble(),
      (expectedPv['p50'] as num).toDouble(),
    );
    expect(
      (pv['p90'] as num).toDouble(),
      (expectedPv['p90'] as num).toDouble(),
    );

    expect(
      (md['p10'] as num).toDouble(),
      (expectedMd['p10'] as num).toDouble(),
    );
    expect(
      (md['p50'] as num).toDouble(),
      (expectedMd['p50'] as num).toDouble(),
    );
    expect(
      (md['p90'] as num).toDouble(),
      (expectedMd['p90'] as num).toDouble(),
    );

    final detailGoalAnalysis =
        detailResult['goalAnalysis'] as Map<String, dynamic>;
    final pvGoal =
        detailGoalAnalysis['portfolioValueGoal'] as Map<String, dynamic>;
    final mdGoal =
        detailGoalAnalysis['monthlyDividendGoal'] as Map<String, dynamic>;

    expect(
      (pvGoal['target'] as num).toInt(),
      (simulationInput['goal']
          as Map<String, dynamic>)['target_portfolio_value'],
    );
    expect(
      (mdGoal['target'] as num).toInt(),
      (simulationInput['goal']
          as Map<String, dynamic>)['target_monthly_dividend'],
    );
    expect((pvGoal['achievementProbability'] as num).toDouble(), 0);
    expect((mdGoal['achievementProbability'] as num).toDouble(), 0);

    final expectedGoalAnalysis =
        simulationResult['goal_analysis'] as Map<String, dynamic>;
    final expectedPvGoal =
        expectedGoalAnalysis['portfolio_value_goal'] as Map<String, dynamic>;
    final expectedMdGoal =
        expectedGoalAnalysis['monthly_dividend_goal'] as Map<String, dynamic>;

    expect(
      (pvGoal['expectedMonthsToTarget'] as num).toInt(),
      expectedPvGoal['expected_months_to_target'],
    );
    expect(
      (mdGoal['expectedMonthsToTarget'] as num).toInt(),
      expectedMdGoal['expected_months_to_target'],
    );

    final now = DateTime.now().toUtc().toIso8601String();
    final softDeleteResponse = await client
        .from('portfolios')
        .update({'deleted_at': now})
        .eq('id', portfolioId)
        .select();

    expect(softDeleteResponse, isNotEmpty);
    expect(softDeleteResponse.first['deleted_at'], isNotNull);

    final listRes2 = await client.functions.invoke(
      'portfolios',
      method: HttpMethod.get,
    );
    expect(listRes2.status, 200);
    expect(listRes2.data, isNotNull);

    final portfolios2 = (listRes2.data['portfolios'] as List).cast<dynamic>();
    final excluded = !portfolios2.any((e) {
      if (e is Map) {
        return e['portfolioId'] == portfolioId;
      }
      return false;
    });
    expect(excluded, true);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../helpers/test_setup.dart';

void main() {
  late SupabaseClient client;

  setUpAll(() async {
    client = await initTestSupabase();
  });

  setUp(() async {
    await client.auth.signOut();
  });

  Map<String, dynamic> baseRequest() {
    return {
      "goal": {
        "investmentPeriodMonths": 240,
        "targetPortfolioValue": 1000000000,
        "targetMonthlyDividend": 5000000,
      },
      "assets": [
        {
          "assetName": "test asset",
          "assetType": "INDEX",
          "initialPrice": 40000,
          "expectedAnnualPriceGrowthRate": 7,
          "initialInvestmentAmount": 20000000,
          "monthlyContributionAmount": 1000000,
          "isDividendAsset": true,
          "dividendPerShare": 383,
          "expectedAnnualDividendGrowthRate": 8,
          "dividendFrequency": 4,
          "isReinvestDividends": true,
        },
      ],
    };
  }

  void validateSuccessResponse(dynamic data) {
    expect(data, isNotNull);

    final p = data['percentiles']['portfolioValue'];
    final p10 = p['p10'];
    final p50 = p['p50'];
    final p90 = p['p90'];

    expect(p10, isA<num>());
    expect(p50, isA<num>());
    expect(p90, isA<num>());

    expect(p10 <= p50, true);
    expect(p50 <= p90, true);

    final months =
        data['goalAnalysis']['portfolioValueGoal']['expectedMonthsToTarget'];

    expect(months, isA<num>());
    expect(months >= 0, true);
  }

  /// -------------------------------
  /// TC10: 정상 요청
  /// -------------------------------
  test('TC10: 정상 요청', () async {
    final res = await client.functions.invoke(
      'simulations',
      body: baseRequest(),
    );

    expect(res.status, 200);
    expect(res.data, isNotNull);

    validateSuccessResponse(res.data);
  });

  /// -------------------------------
  /// TC11: validation 실패
  /// -------------------------------
  test('TC11: invalid goal 값', () async {
    final req = baseRequest();
    req['goal']['investmentPeriodMonths'] = -1;

    final res = await client.functions.invoke('simulations', body: req);

    expect(res.status, isNot(200));
  });

  /// -------------------------------
  /// TC12: asset 0개
  /// -------------------------------
  test('TC12: assets 빈 배열', () async {
    final req = baseRequest();
    req['assets'] = [];

    final res = await client.functions.invoke('simulations', body: req);

    expect(res.status, isNot(200));
  });

  /// -------------------------------
  /// TC13: 배당 자산만 존재
  /// -------------------------------
  test('TC13: dividend asset only', () async {
    final req = baseRequest();

    req['assets'] = [
      {
        "assetName": "dividend only",
        "assetType": "INDEX",
        "initialPrice": 50000,
        "expectedAnnualPriceGrowthRate": 6,
        "initialInvestmentAmount": 10000000,
        "monthlyContributionAmount": 500000,
        "isDividendAsset": true,
        "dividendPerShare": 200,
        "expectedAnnualDividendGrowthRate": 5,
        "dividendFrequency": 4,
        "isReinvestDividends": true,
      },
    ];

    final res = await client.functions.invoke('simulations', body: req);

    expect(res.status, 200);
    expect(res.data, isNotNull);

    validateSuccessResponse(res.data);
  });

  /// -------------------------------
  /// TC14: 비배당 자산만 존재
  /// -------------------------------
  test('TC14: non-dividend asset only', () async {
    final req = baseRequest();

    req['assets'] = [
      {
        "assetName": "growth only",
        "assetType": "GOLD",
        "initialPrice": 250000,
        "expectedAnnualPriceGrowthRate": 5,
        "initialInvestmentAmount": 10000000,
        "monthlyContributionAmount": 250000,
        "isDividendAsset": false,
        "dividendPerShare": 0,
        "expectedAnnualDividendGrowthRate": 0,
        "dividendFrequency": 0,
        "isReinvestDividends": false,
      },
    ];

    final res = await client.functions.invoke('simulations', body: req);

    expect(res.status, 200);
    expect(res.data, isNotNull);

    validateSuccessResponse(res.data);
  });

  /// -------------------------------
  /// TC15: 결과 변동성 존재 검증
  /// -------------------------------
  test('TC15: Monte Carlo 결과는 변동성이 있어야 한다', () async {
    final results = <num>[];

    for (int i = 0; i < 20; i++) {
      final res = await client.functions.invoke(
        'simulations',
        body: baseRequest(),
      );

      expect(res.status, 200);

      final p50 = res.data['percentiles']['portfolioValue']['p50'];
      results.add(p50);
    }

    // 모든 값이 동일한지 체크
    final uniqueValues = results.toSet();

    expect(uniqueValues.length > 1, true);
  });

  /// -------------------------------
  /// TC16: percentile 간 차이 존재
  /// -------------------------------
  test('TC16: percentile 간 의미 있는 차이가 있어야 한다', () async {
    final res = await client.functions.invoke(
      'simulations',
      body: baseRequest(),
    );

    final p = res.data['percentiles']['portfolioValue'];

    final diff = p['p90'] - p['p10'];

    expect(diff > 0, true);
  });

  /// -------------------------------
  /// TC17: 값 범위 sanity check
  /// -------------------------------
  test('TC17: 결과 값이 비정상적으로 크지 않아야 한다', () async {
    final res = await client.functions.invoke(
      'simulations',
      body: baseRequest(),
    );

    final p50 = res.data['percentiles']['portfolioValue']['p50'];

    expect(p50 < 1e15, true); // 1,000조
  });
}

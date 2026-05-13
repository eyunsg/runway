import 'package:flutter/material.dart';

// 400 Medium
// 500 Regular
// 600 SemiBold
// 700 Bold
// 800 ExtraBold

class AppTypography {
  static const family = 'Inter';

  static final heading = Heading();
  static final body = Body();
  static final action = Action();
  static final caption = Caption();
}

// Heading (H1 ~ H5)
class Heading {
  final h1 = const TextStyle(
    fontFamily: AppTypography.family,
    fontSize: 24,
    fontWeight: FontWeight.w800, // ExtraBold
    letterSpacing: 24 * 0.01, // 1%
  );

  final h2 = const TextStyle(
    fontFamily: AppTypography.family,
    fontSize: 18,
    fontWeight: FontWeight.w800, // ExtraBold
    letterSpacing: 18 * 0.005, // 0.5%
  );

  final h3 = const TextStyle(
    fontFamily: AppTypography.family,
    fontSize: 16,
    fontWeight: FontWeight.w800, // ExtraBold
    letterSpacing: 16 * 0.005, // 0.5%
  );

  final h4 = const TextStyle(
    fontFamily: AppTypography.family,
    fontSize: 14,
    fontWeight: FontWeight.w700, // Bold
    letterSpacing: 0, // 0%
  );

  final h5 = const TextStyle(
    fontFamily: AppTypography.family,
    fontSize: 12,
    fontWeight: FontWeight.w700, // Bold
    letterSpacing: 0, // 0%
  );
}

// Body (XL~XS)
class Body {
  final xl = const TextStyle(
    fontFamily: AppTypography.family,
    fontSize: 18,
    fontWeight: FontWeight.w500, // Regular
    letterSpacing: 0, // 0%
  );

  final l = const TextStyle(
    fontFamily: AppTypography.family,
    fontSize: 16,
    fontWeight: FontWeight.w500, // Regular
    letterSpacing: 0, //0%
  );

  final m = const TextStyle(
    fontFamily: AppTypography.family,
    fontSize: 14,
    fontWeight: FontWeight.w500, // Regular
    letterSpacing: 0, // 0%
  );

  final s = const TextStyle(
    fontFamily: AppTypography.family,
    fontSize: 12,
    fontWeight: FontWeight.w500, // Regular
    letterSpacing: 12 * 0.01, // 1%
  );

  final xs = const TextStyle(
    fontFamily: AppTypography.family,
    fontSize: 10,
    fontWeight: FontWeight.w400, // Medium
    letterSpacing: 10 * 0.015, // 1.5%
  );
}

// Action (L~S)
class Action {
  final l = const TextStyle(
    fontFamily: AppTypography.family,
    fontSize: 14,
    fontWeight: FontWeight.w600, // SemiBold
    letterSpacing: 0, // 0%
  );

  final m = const TextStyle(
    fontFamily: AppTypography.family,
    fontSize: 12,
    fontWeight: FontWeight.w600, // SemiBold
    letterSpacing: 0, // 0%
  );

  final s = const TextStyle(
    fontFamily: AppTypography.family,
    fontSize: 10,
    fontWeight: FontWeight.w600, // SemiBold
    letterSpacing: 0, // 0%
  );
}

// Caption (M)
class Caption {
  final m = const TextStyle(
    fontFamily: AppTypography.family,
    fontSize: 10,
    fontWeight: FontWeight.w600, // SemiBold
    letterSpacing: 10 * 0.05, // 5%
  );
}

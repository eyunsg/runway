import 'failure.dart';
import 'validation_failure.dart';

extension FailureX on Failure {
  String toMessage() {
    if (this is EmptyAssetsFailure) {
      return '자산을 최소 1개 이상 추가해야 합니다.';
    }

    if (this is InvalidAssetFailure) {
      return '배당 자산 정보가 올바르지 않습니다.';
    }

    if (this is EmailFailure) {
      return '이메일 형식이 올바르지 않습니다.';
    }

    if (this is PasswordFailure) {
      return '비밀번호 형식이 올바르지 않습니다.';
    }

    if (this is DisplayNameFailure) {
      return '닉네임 형식이 올바르지 않습니다.';
    }

    if (this is AuthFailure) {
      return '로그인이 필요합니다.';
    }

    if (this is NetworkFailure) {
      return '네트워크 오류가 발생했습니다.';
    }

    if (this is ServerFailure) {
      // return '서버 오류가 발생했습니다.';
      return message;
    }

    return '알 수 없는 오류가 발생했습니다.';
  }
}

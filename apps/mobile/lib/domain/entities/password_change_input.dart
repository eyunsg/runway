class PasswordChangeInput {
  final String currentPassword;
  final String newPassword;
  final String newPasswordConfirm;

  PasswordChangeInput({
    required this.currentPassword,
    required this.newPassword,
    required this.newPasswordConfirm,
  }) {
    if (newPassword.length < 6) {
      throw ArgumentError('새 비밀번호는 최소 6자 이상이어야 합니다.');
    }

    if (newPassword != newPasswordConfirm) {
      throw ArgumentError('새 비밀번호가 일치하지 않습니다.');
    }

    if (currentPassword == newPassword) {
      throw ArgumentError('새 비밀번호는 현재 비밀번호와 다르게 설정해야 합니다.');
    }
  }
}

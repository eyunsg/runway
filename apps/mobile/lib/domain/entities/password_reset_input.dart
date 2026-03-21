class PasswordResetInput {
  final Password password;
  final PasswordConfirm passwordConfirm;

  PasswordResetInput({required this.password, required this.passwordConfirm}) {
    if (password.value != passwordConfirm.value) {
      throw ArgumentError('비밀번호가 일치하지 않습니다.');
    }
  }
}

class Password {
  final String value;

  Password(this.value) {
    if (value.isEmpty) {
      throw ArgumentError('비밀번호를 입력해주세요.');
    }

    if (value.length < 6) {
      throw ArgumentError('비밀번호는 최소 6자 이상이어야 합니다.');
    }
  }
}

class PasswordConfirm {
  final String value;

  PasswordConfirm(this.value) {
    if (value.isEmpty) {
      throw ArgumentError('비밀번호를 다시 입력해주세요.');
    }

    if (value.length < 6) {
      throw ArgumentError('비밀번호는 최소 6자 이상이어야 합니다.');
    }
  }
}

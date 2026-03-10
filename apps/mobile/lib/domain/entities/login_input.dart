class LoginInput {
  final Email email;
  final Password password;

  LoginInput({required this.email, required this.password});
}

class Email {
  final String value;
  Email(this.value) {
    if (value.isEmpty) {
      throw ArgumentError('이메일을 입력해주세요.');
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(value)) {
      throw ArgumentError('유효한 이메일 형식이 아닙니다.');
    }
  }
}

class Password {
  final String value;
  Password(this.value) {
    if (value.length < 6) {
      throw ArgumentError('비밀번호는 최소 6자 이상이어야 합니다.');
    }
  }
}

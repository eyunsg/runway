class SignUpInput {
  final Email email;
  final Password password;
  final Username username;

  SignUpInput({
    required this.email,
    required this.password,
    required this.username,
  });
}

class Email {
  final String value;
  Email(this.value) {
    if (value.isEmpty) throw ArgumentError('이메일을 입력해주세요.');
  }
}

class Password {
  final String value;
  Password(this.value) {
    if (value.length < 6) throw ArgumentError('비밀번호는 최소 6자 이상이어야 합니다.');
  }
}

class Username {
  final String value;
  Username(this.value) {
    if (value.isEmpty || value.length > 20) {
      throw ArgumentError('사용자명은 1~20자 사이여야 합니다.');
    }
  }
}

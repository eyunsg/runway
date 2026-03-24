class ProfileState {
  final bool isLoading;
  final String? error;
  final String? email;
  final String? displayName;
  final bool isSuccess;

  const ProfileState({
    this.isLoading = false,
    this.error,
    this.email,
    this.displayName,
    this.isSuccess = false,
  });

  ProfileState copyWith({
    bool? isLoading,
    String? error,
    String? email,
    String? displayName,
    bool? isSuccess,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

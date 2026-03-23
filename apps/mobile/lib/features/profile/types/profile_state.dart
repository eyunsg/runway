class ProfileState {
  final bool isLoading;
  final String? error;
  final String? email;
  final String? displayName;

  const ProfileState({
    this.isLoading = false,
    this.error,
    this.email,
    this.displayName,
  });

  ProfileState copyWith({
    bool? isLoading,
    String? error,
    String? email,
    String? displayName,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
    );
  }
}

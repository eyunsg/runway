enum AsyncStatus { initial, loading, success, error }

class AsyncState<T, E> {
  final AsyncStatus status;
  final T? data;
  final E? error;
  final String? message;

  const AsyncState({
    this.status = AsyncStatus.initial,
    this.data,
    this.error,
    this.message,
  });

  AsyncState<T, E> copyWith({
    AsyncStatus? status,
    T? data,
    E? error,
    String? message,
  }) {
    return AsyncState(
      status: status ?? this.status,
      data: data ?? this.data,
      error: error ?? this.error,
      message: message ?? this.message,
    );
  }
}

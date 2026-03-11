enum AsyncStatus { initial, loading, success, error }

class AsyncState<T> {
  final AsyncStatus status;
  final T? data;
  final String? error;

  const AsyncState({this.status = AsyncStatus.initial, this.data, this.error});

  AsyncState<T> copyWith({AsyncStatus? status, T? data, String? error}) {
    return AsyncState(
      status: status ?? this.status,
      data: data ?? this.data,
      error: error ?? this.error,
    );
  }
}

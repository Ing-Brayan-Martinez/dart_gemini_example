enum AsyncStateStatus { initial, loading, completed, error }

final class AsyncState<T> {
  const AsyncState.initial()
      : status = AsyncStateStatus.initial,
        data = null,
        error = null;

  const AsyncState.loading()
      : status = AsyncStateStatus.loading,
        data = null,
        error = null;

  const AsyncState.completed(T value)
      : status = AsyncStateStatus.completed,
        data = value,
        error = null;

  const AsyncState.error(Object value)
      : status = AsyncStateStatus.error,
        data = null,
        error = value;

  final AsyncStateStatus status;
  final T? data;
  final Object? error;
}

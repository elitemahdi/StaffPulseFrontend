abstract class DataState<T> {
  final T? data;
  final String? error;
  final int? errorCode;

  const DataState({
    this.data,
    this.error,
    this.errorCode,
  });
}

class DataSuccess<T> extends DataState<T> {
  const DataSuccess(T data)
      : super(
          data: data,
          error: null,
          errorCode: null,
        );
}

class DataFailed<T> extends DataState<T> {
  const DataFailed(
    String error, [
    int? errorCode,
  ]) : super(
          data: null,
          error: error,
          errorCode: errorCode,
        );
}

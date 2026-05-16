sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Failure<T> extends Result<T> {
  final String message;
  const Failure(this.message);
}

extension ResultX<T> on Result<T> {
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => isSuccess ? (this as Success<T>).data : null;
  String? get errorOrNull => isFailure ? (this as Failure<T>).message : null;

  R when<R>({
    required R Function(T data) success,
    required R Function(String error) failure,
  }) {
    if (this is Success<T>) return success((this as Success<T>).data);
    return failure((this as Failure<T>).message);
  }
}

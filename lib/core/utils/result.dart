sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Failure<T> extends Result<T> {
  final String message;
  final int? statusCode;
  const Failure(this.message, {this.statusCode});
}

extension ResultExtension<T> on Result<T> {
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => switch (this) {
        Success<T> s => s.data,
        Failure<T> _ => null,
      };

  String? get errorOrNull => switch (this) {
        Success<T> _ => null,
        Failure<T> f => f.message,
      };

  R when<R>({
    required R Function(T data) success,
    required R Function(String message, int? statusCode) failure,
  }) =>
      switch (this) {
        Success<T> s => success(s.data),
        Failure<T> f => failure(f.message, f.statusCode),
      };
}
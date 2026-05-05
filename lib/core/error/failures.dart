abstract class Failure {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message) : super(statusCode: 401);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message) : super(statusCode: 404);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message) : super(statusCode: 422);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
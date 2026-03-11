abstract class Failure {
  final String message;
  final dynamic error;

  const Failure(this.message, {this.error});

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.error});
}

class ConnectionFailure extends Failure {
  const ConnectionFailure(super.message, {super.error});
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.error});
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

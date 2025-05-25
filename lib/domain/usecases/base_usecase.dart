/// Base class for all use cases in the application
/// Provides a common interface for executing business logic operations
abstract class UseCase<Type, Params> {
  /// Executes the use case with the given parameters
  /// Returns the result of type [Type]
  Future<Type> call(Params params);
}

/// Base class for use cases that don't require parameters
abstract class NoParamsUseCase<Type> {
  /// Executes the use case without parameters
  /// Returns the result of type [Type]
  Future<Type> call();
}

/// Base class for synchronous use cases
abstract class SyncUseCase<Type, Params> {
  /// Executes the use case synchronously with the given parameters
  /// Returns the result of type [Type]
  Type call(Params params);
}

/// Base class for synchronous use cases that don't require parameters
abstract class SyncNoParamsUseCase<Type> {
  /// Executes the use case synchronously without parameters
  /// Returns the result of type [Type]
  Type call();
}

/// Represents no parameters for use cases that don't need input
class NoParams {
  const NoParams();
}

/// Represents the result of a use case operation
class UseCaseResult<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  const UseCaseResult._({this.data, this.error, required this.isSuccess});

  /// Creates a successful result with data
  factory UseCaseResult.success(T data) {
    return UseCaseResult._(data: data, isSuccess: true);
  }

  /// Creates a failure result with error message
  factory UseCaseResult.failure(String error) {
    return UseCaseResult._(error: error, isSuccess: false);
  }

  /// Gets the data if successful, throws if failed
  T get dataOrThrow {
    if (!isSuccess) {
      throw Exception(error ?? 'Use case failed');
    }
    return data!;
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'UseCaseResult.success($data)';
    } else {
      return 'UseCaseResult.failure($error)';
    }
  }
}

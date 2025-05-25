import 'package:get_it/get_it.dart';

/// Dependency injection container for Tetris game
/// Handles registration and retrieval of dependencies following Clean Architecture
final GetIt getIt = GetIt.instance;

/// Sets up all dependencies for the application
/// Must be called before using any dependencies
Future<void> setupDependencies() async {
  // Register data sources
  await _registerDataSources();

  // Register repositories
  await _registerRepositories();

  // Register use cases
  await _registerUseCases();

  // Register BLoCs
  await _registerBlocs();
}

/// Registers data source dependencies
Future<void> _registerDataSources() async {
  // Data sources will be registered here
  // Example:
  // getIt.registerLazySingleton<LocalGameDataSource>(
  //   () => LocalGameDataSource(),
  // );
}

/// Registers repository dependencies
Future<void> _registerRepositories() async {
  // Repository implementations will be registered here
  // Example:
  // getIt.registerLazySingleton<GameRepository>(
  //   () => GameRepositoryImpl(getIt()),
  // );
}

/// Registers use case dependencies
Future<void> _registerUseCases() async {
  // Use cases will be registered here
  // Example:
  // getIt.registerLazySingleton<StartGameUseCase>(
  //   () => StartGameUseCase(getIt()),
  // );
}

/// Registers BLoC dependencies
Future<void> _registerBlocs() async {
  // BLoCs will be registered here as factories (new instance each time)
  // Example:
  // getIt.registerFactory<GameBloc>(
  //   () => GameBloc(getIt()),
  // );
}

/// Clears all registered dependencies
/// Useful for testing and cleanup
Future<void> clearDependencies() async {
  await getIt.reset();
}

/// Type-safe dependency retrieval
/// Example usage: final repository = DI.get`<GameRepository>`();
class DI {
  /// Gets a registered dependency of type T
  static T get<T extends Object>() => getIt.get<T>();

  /// Checks if a dependency of type T is registered
  static bool isRegistered<T extends Object>() => getIt.isRegistered<T>();

  /// Safely gets a dependency, returns null if not registered
  static T? tryGet<T extends Object>() {
    try {
      return getIt.get<T>();
    } catch (e) {
      return null;
    }
  }
}

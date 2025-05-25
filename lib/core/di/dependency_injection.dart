import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Domain layer imports
import '../../domain/repositories/game_repository.dart';
import '../../domain/repositories/score_repository.dart';
import '../../domain/usecases/drop_piece_usecase.dart';
import '../../domain/usecases/get_high_scores_usecase.dart';
import '../../domain/usecases/hold_piece_usecase.dart';
import '../../domain/usecases/load_game_usecase.dart';
import '../../domain/usecases/move_piece_usecase.dart';
import '../../domain/usecases/pause_game_usecase.dart';
import '../../domain/usecases/place_piece_usecase.dart';
import '../../domain/usecases/resume_game_usecase.dart';
import '../../domain/usecases/rotate_piece_usecase.dart';
import '../../domain/usecases/save_game_usecase.dart';
import '../../domain/usecases/start_game_usecase.dart';

// Data layer imports
import '../../data/datasources/local_game_data_source.dart';
import '../../data/datasources/local_score_data_source.dart';
import '../../data/repositories/game_repository_impl.dart';
import '../../data/repositories/score_repository_impl.dart';

// Presentation layer imports
import '../../presentation/blocs/game/simple_game_bloc.dart';

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
  // Register SharedPreferences instance
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Register data sources
  getIt.registerLazySingleton<LocalGameDataSource>(
    () => LocalGameDataSource(getIt()),
  );

  getIt.registerLazySingleton<LocalScoreDataSource>(
    () => LocalScoreDataSource(getIt()),
  );
}

/// Registers repository dependencies
Future<void> _registerRepositories() async {
  // Register repository implementations
  getIt.registerLazySingleton<GameRepository>(
    () => GameRepositoryImpl(getIt()),
  );

  getIt.registerLazySingleton<ScoreRepository>(
    () => ScoreRepositoryImpl(getIt()),
  );
}

/// Registers use case dependencies
Future<void> _registerUseCases() async {
  // Game control use cases
  getIt.registerLazySingleton<StartGameUseCase>(
    () => StartGameUseCase(getIt()),
  );

  getIt.registerLazySingleton<MovePieceUseCase>(
    () => MovePieceUseCase(getIt()),
  );

  getIt.registerLazySingleton<RotatePieceUseCase>(
    () => RotatePieceUseCase(getIt()),
  );

  getIt.registerLazySingleton<DropPieceUseCase>(
    () => DropPieceUseCase(getIt(), getIt()),
  );

  getIt.registerLazySingleton<HoldPieceUseCase>(
    () => HoldPieceUseCase(getIt()),
  );

  getIt.registerLazySingleton<PlacePieceUseCase>(
    () => PlacePieceUseCase(getIt(), getIt()),
  );

  // Game state use cases
  getIt.registerLazySingleton<PauseGameUseCase>(
    () => PauseGameUseCase(getIt()),
  );

  getIt.registerLazySingleton<ResumeGameUseCase>(
    () => ResumeGameUseCase(getIt()),
  );

  getIt.registerLazySingleton<SaveGameUseCase>(() => SaveGameUseCase(getIt()));

  getIt.registerLazySingleton<LoadGameUseCase>(() => LoadGameUseCase(getIt()));

  getIt.registerLazySingleton<HasSavedGameUseCase>(
    () => HasSavedGameUseCase(getIt()),
  );

  // Score use cases
  getIt.registerLazySingleton<GetHighScoresUseCase>(
    () => GetHighScoresUseCase(getIt()),
  );

  getIt.registerLazySingleton<GetGameStatisticsUseCase>(
    () => GetGameStatisticsUseCase(getIt()),
  );

  getIt.registerLazySingleton<IsNewHighScoreUseCase>(
    () => IsNewHighScoreUseCase(getIt()),
  );
}

/// Registers BLoC dependencies
Future<void> _registerBlocs() async {
  // Register BLoCs as factories (new instance each time)
  getIt.registerFactory<SimpleGameBloc>(
    () => SimpleGameBloc(
      startGameUseCase: getIt(),
      movePieceUseCase: getIt(),
      rotatePieceUseCase: getIt(),
      placePieceUseCase: getIt(),
      gameRepository: getIt(),
    ),
  );
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

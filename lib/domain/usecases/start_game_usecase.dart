import '../entities/game_state.dart';
import '../repositories/game_repository.dart';
import 'base_usecase.dart';

/// Use case for starting a new game or resuming a saved game
class StartGameUseCase extends UseCase<GameState, StartGameParams> {
  final GameRepository _gameRepository;

  StartGameUseCase(this._gameRepository);

  @override
  Future<GameState> call(StartGameParams params) async {
    try {
      GameState gameState;

      if (params.resumeSavedGame) {
        // Try to load saved game
        final savedGame = await _gameRepository.loadGameState();
        if (savedGame != null) {
          // Resume the saved game
          gameState = savedGame.resumeGame();
        } else {
          // No saved game found, start new game
          gameState = GameState.initial().startGame();
        }
      } else {
        // Start a completely new game
        gameState = GameState.initial().startGame();
        
        // Clear any existing saved game if starting fresh
        if (params.clearSavedGame) {
          await _gameRepository.deleteSavedGame();
        }
      }

      // Auto-save the initial game state
      await _gameRepository.autoSaveGameState(gameState);

      return gameState;
    } catch (e) {
      // If anything fails, return a new game
      return GameState.initial().startGame();
    }
  }
}

/// Parameters for starting a game
class StartGameParams {
  final bool resumeSavedGame;
  final bool clearSavedGame;

  const StartGameParams({
    this.resumeSavedGame = false,
    this.clearSavedGame = false,
  });

  /// Creates params for starting a new game
  factory StartGameParams.newGame() {
    return const StartGameParams(
      resumeSavedGame: false,
      clearSavedGame: true,
    );
  }

  /// Creates params for resuming a saved game
  factory StartGameParams.resumeGame() {
    return const StartGameParams(
      resumeSavedGame: true,
      clearSavedGame: false,
    );
  }

  @override
  String toString() {
    return 'StartGameParams(resume: $resumeSavedGame, clear: $clearSavedGame)';
  }
} 
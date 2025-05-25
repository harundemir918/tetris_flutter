import '../entities/game_state.dart';
import '../repositories/game_repository.dart';
import 'base_usecase.dart';

/// Use case for loading a saved game state
class LoadGameUseCase extends NoParamsUseCase<GameState?> {
  final GameRepository _gameRepository;

  LoadGameUseCase(this._gameRepository);

  @override
  Future<GameState?> call() async {
    try {
      // Try to load the manually saved game first
      final savedGame = await _gameRepository.loadGameState();
      if (savedGame != null) {
        return savedGame;
      }

      // If no manual save, try auto-saved game
      final autoSavedGame = await _gameRepository.loadAutoSavedGameState();
      return autoSavedGame;
    } catch (e) {
      return null;
    }
  }
}

/// Use case for checking if a saved game exists
class HasSavedGameUseCase extends NoParamsUseCase<bool> {
  final GameRepository _gameRepository;

  HasSavedGameUseCase(this._gameRepository);

  @override
  Future<bool> call() async {
    try {
      // Check for manual save first
      final hasManualSave = await _gameRepository.hasSavedGame();
      if (hasManualSave) {
        return true;
      }

      // Check for auto-save
      final autoSavedGame = await _gameRepository.loadAutoSavedGameState();
      return autoSavedGame != null;
    } catch (e) {
      return false;
    }
  }
} 
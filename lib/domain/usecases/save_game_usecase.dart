import '../entities/game_state.dart';
import '../repositories/game_repository.dart';
import 'base_usecase.dart';

/// Use case for manually saving the game state
class SaveGameUseCase extends UseCase<bool, SaveGameParams> {
  final GameRepository _gameRepository;

  SaveGameUseCase(this._gameRepository);

  @override
  Future<bool> call(SaveGameParams params) async {
    try {
      final success = await _gameRepository.saveGameState(params.gameState);
      
      // Also update auto-save if manual save was successful
      if (success) {
        await _gameRepository.autoSaveGameState(params.gameState);
      }
      
      return success;
    } catch (e) {
      return false;
    }
  }
}

/// Parameters for saving the game
class SaveGameParams {
  final GameState gameState;

  const SaveGameParams({
    required this.gameState,
  });

  @override
  String toString() {
    return 'SaveGameParams(status: ${gameState.status}, score: ${gameState.score.points})';
  }
} 
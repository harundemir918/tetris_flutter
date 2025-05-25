import '../entities/game_state.dart';
import '../repositories/game_repository.dart';
import '../repositories/score_repository.dart';
import 'base_usecase.dart';

/// Use case for placing the current piece when it can no longer move down
class PlacePieceUseCase extends UseCase<GameState, PlacePieceParams> {
  final GameRepository _gameRepository;
  final ScoreRepository _scoreRepository;

  PlacePieceUseCase(this._gameRepository, this._scoreRepository);

  @override
  Future<GameState> call(PlacePieceParams params) async {
    final newState = params.currentState.placeCurrentPiece();

    // If the game ended, save the final score
    if (newState.isGameOver && !params.currentState.isGameOver) {
      final gameDuration = newState.getGameDuration();
      await _scoreRepository.saveScore(newState.score, gameDuration);

      // Clear auto-saved game since game is over
      await _gameRepository.clearAutoSavedGameState();
    } else {
      // Auto-save the game state if it changed and game is still active
      if (newState != params.currentState && !newState.isGameOver) {
        await _gameRepository.autoSaveGameState(newState);
      }
    }

    return newState;
  }
}

/// Parameters for placing a piece
class PlacePieceParams {
  final GameState currentState;

  const PlacePieceParams({required this.currentState});

  @override
  String toString() {
    return 'PlacePieceParams(hasCurrentPiece: ${currentState.currentPiece != null})';
  }
}

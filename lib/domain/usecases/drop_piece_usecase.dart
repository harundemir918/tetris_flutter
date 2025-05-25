import '../entities/game_state.dart';
import '../repositories/game_repository.dart';
import '../repositories/score_repository.dart';
import 'base_usecase.dart';

/// Use case for dropping pieces (soft drop and hard drop)
class DropPieceUseCase extends UseCase<GameState, DropPieceParams> {
  final GameRepository _gameRepository;
  final ScoreRepository _scoreRepository;

  DropPieceUseCase(this._gameRepository, this._scoreRepository);

  @override
  Future<GameState> call(DropPieceParams params) async {
    GameState newState;

    switch (params.dropType) {
      case DropType.soft:
        newState = params.currentState.moveCurrentPieceDown();
        break;
      case DropType.hard:
        newState = params.currentState.hardDropCurrentPiece();
        break;
    }

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

/// Parameters for dropping a piece
class DropPieceParams {
  final GameState currentState;
  final DropType dropType;

  const DropPieceParams({
    required this.currentState,
    required this.dropType,
  });

  /// Creates params for soft drop
  factory DropPieceParams.softDrop(GameState currentState) {
    return DropPieceParams(
      currentState: currentState,
      dropType: DropType.soft,
    );
  }

  /// Creates params for hard drop
  factory DropPieceParams.hardDrop(GameState currentState) {
    return DropPieceParams(
      currentState: currentState,
      dropType: DropType.hard,
    );
  }

  @override
  String toString() {
    return 'DropPieceParams(dropType: $dropType)';
  }
}

/// Enumeration of drop types
enum DropType {
  soft,
  hard,
}

extension DropTypeExtension on DropType {
  String get displayName {
    switch (this) {
      case DropType.soft:
        return 'Soft Drop';
      case DropType.hard:
        return 'Hard Drop';
    }
  }

  bool get isHard => this == DropType.hard;
  bool get isSoft => this == DropType.soft;
} 
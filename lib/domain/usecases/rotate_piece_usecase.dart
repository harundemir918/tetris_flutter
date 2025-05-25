import '../entities/game_state.dart';
import '../repositories/game_repository.dart';
import 'base_usecase.dart';

/// Use case for rotating the current piece in the game
class RotatePieceUseCase extends UseCase<GameState, RotatePieceParams> {
  final GameRepository _gameRepository;

  RotatePieceUseCase(this._gameRepository);

  @override
  Future<GameState> call(RotatePieceParams params) async {
    GameState newState;

    switch (params.direction) {
      case RotationDirection.clockwise:
        newState = params.currentState.rotateCurrentPieceClockwise();
        break;
      case RotationDirection.counterClockwise:
        newState = params.currentState.rotateCurrentPieceCounterClockwise();
        break;
    }

    // Auto-save the game state if it changed
    if (newState != params.currentState) {
      await _gameRepository.autoSaveGameState(newState);
    }

    return newState;
  }
}

/// Parameters for rotating a piece
class RotatePieceParams {
  final GameState currentState;
  final RotationDirection direction;

  const RotatePieceParams({
    required this.currentState,
    required this.direction,
  });

  @override
  String toString() {
    return 'RotatePieceParams(direction: $direction)';
  }
}

/// Enumeration of possible rotation directions
enum RotationDirection {
  clockwise,
  counterClockwise,
}

extension RotationDirectionExtension on RotationDirection {
  String get displayName {
    switch (this) {
      case RotationDirection.clockwise:
        return 'Clockwise';
      case RotationDirection.counterClockwise:
        return 'Counter-Clockwise';
    }
  }

  String get shortName {
    switch (this) {
      case RotationDirection.clockwise:
        return 'CW';
      case RotationDirection.counterClockwise:
        return 'CCW';
    }
  }
} 
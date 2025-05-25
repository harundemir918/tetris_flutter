import '../entities/game_state.dart';
import '../repositories/game_repository.dart';
import 'base_usecase.dart';

/// Use case for moving the current piece in the game
class MovePieceUseCase extends UseCase<GameState, MovePieceParams> {
  final GameRepository _gameRepository;

  MovePieceUseCase(this._gameRepository);

  @override
  Future<GameState> call(MovePieceParams params) async {
    GameState newState;

    switch (params.direction) {
      case MoveDirection.left:
        newState = params.currentState.moveCurrentPieceLeft();
        break;
      case MoveDirection.right:
        newState = params.currentState.moveCurrentPieceRight();
        break;
      case MoveDirection.down:
        newState = params.currentState.moveCurrentPieceDown();
        break;
    }

    // Auto-save the game state if it changed
    if (newState != params.currentState) {
      await _gameRepository.autoSaveGameState(newState);
    }

    return newState;
  }
}

/// Parameters for moving a piece
class MovePieceParams {
  final GameState currentState;
  final MoveDirection direction;

  const MovePieceParams({required this.currentState, required this.direction});

  @override
  String toString() {
    return 'MovePieceParams(direction: $direction)';
  }
}

/// Enumeration of possible move directions
enum MoveDirection { left, right, down }

extension MoveDirectionExtension on MoveDirection {
  String get displayName {
    switch (this) {
      case MoveDirection.left:
        return 'Left';
      case MoveDirection.right:
        return 'Right';
      case MoveDirection.down:
        return 'Down';
    }
  }
}

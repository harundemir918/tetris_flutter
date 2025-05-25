import '../entities/game_state.dart';
import '../repositories/game_repository.dart';
import 'base_usecase.dart';

/// Use case for holding the current piece
class HoldPieceUseCase extends UseCase<GameState, HoldPieceParams> {
  final GameRepository _gameRepository;

  HoldPieceUseCase(this._gameRepository);

  @override
  Future<GameState> call(HoldPieceParams params) async {
    final newState = params.currentState.holdCurrentPiece();

    // Auto-save the game state if it changed
    if (newState != params.currentState) {
      await _gameRepository.autoSaveGameState(newState);
    }

    return newState;
  }
}

/// Parameters for holding a piece
class HoldPieceParams {
  final GameState currentState;

  const HoldPieceParams({required this.currentState});

  @override
  String toString() {
    return 'HoldPieceParams(canHold: ${currentState.canHold})';
  }
}

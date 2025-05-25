import '../entities/game_state.dart';
import '../repositories/game_repository.dart';
import 'base_usecase.dart';

/// Use case for pausing the game
class PauseGameUseCase extends UseCase<GameState, PauseGameParams> {
  final GameRepository _gameRepository;

  PauseGameUseCase(this._gameRepository);

  @override
  Future<GameState> call(PauseGameParams params) async {
    final newState = params.currentState.pauseGame();

    // Save the game state when pausing
    if (newState != params.currentState) {
      await _gameRepository.saveGameState(newState);
    }

    return newState;
  }
}

/// Parameters for pausing the game
class PauseGameParams {
  final GameState currentState;

  const PauseGameParams({required this.currentState});

  @override
  String toString() {
    return 'PauseGameParams(currentStatus: ${currentState.status})';
  }
}

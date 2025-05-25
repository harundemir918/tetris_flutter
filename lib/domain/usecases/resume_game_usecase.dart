import '../entities/game_state.dart';
import '../repositories/game_repository.dart';
import 'base_usecase.dart';

/// Use case for resuming a paused game
class ResumeGameUseCase extends UseCase<GameState, ResumeGameParams> {
  final GameRepository _gameRepository;

  ResumeGameUseCase(this._gameRepository);

  @override
  Future<GameState> call(ResumeGameParams params) async {
    final newState = params.currentState.resumeGame();

    // Auto-save the resumed game state
    if (newState != params.currentState) {
      await _gameRepository.autoSaveGameState(newState);
    }

    return newState;
  }
}

/// Parameters for resuming the game
class ResumeGameParams {
  final GameState currentState;

  const ResumeGameParams({required this.currentState});

  @override
  String toString() {
    return 'ResumeGameParams(currentStatus: ${currentState.status})';
  }
}

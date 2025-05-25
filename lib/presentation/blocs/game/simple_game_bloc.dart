import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/game_state.dart';
import '../../../domain/usecases/start_game_usecase.dart';
import '../../../domain/usecases/move_piece_usecase.dart';
import '../../../domain/repositories/game_repository.dart';

/// Simplified events for the game
abstract class SimpleGameEvent {}

class InitializeGame extends SimpleGameEvent {}

class StartGame extends SimpleGameEvent {}

class MovePieceLeft extends SimpleGameEvent {}

class MovePieceRight extends SimpleGameEvent {}

class MovePieceDown extends SimpleGameEvent {}

class PauseGame extends SimpleGameEvent {}

class ResumeGame extends SimpleGameEvent {}

/// Simplified states for the game
abstract class SimpleGameState {}

class GameInitialState extends SimpleGameState {}

class GameLoadingState extends SimpleGameState {}

class GameReadyState extends SimpleGameState {
  final GameState gameState;
  final Map<String, dynamic> settings;

  GameReadyState({required this.gameState, required this.settings});
}

class GamePlayingState extends SimpleGameState {
  final GameState gameState;
  final Map<String, dynamic> settings;

  GamePlayingState({required this.gameState, required this.settings});
}

class GamePausedState extends SimpleGameState {
  final GameState gameState;
  final Map<String, dynamic> settings;

  GamePausedState({required this.gameState, required this.settings});
}

class GameErrorState extends SimpleGameState {
  final String message;

  GameErrorState({required this.message});
}

/// Simplified GameBloc for core functionality
class SimpleGameBloc extends Bloc<SimpleGameEvent, SimpleGameState> {
  final StartGameUseCase _startGameUseCase;
  final MovePieceUseCase _movePieceUseCase;
  final GameRepository _gameRepository;

  GameState? _currentGameState;
  Map<String, dynamic> _gameSettings = {};
  Timer? _gameTimer;

  SimpleGameBloc({
    required StartGameUseCase startGameUseCase,
    required MovePieceUseCase movePieceUseCase,
    required GameRepository gameRepository,
  }) : _startGameUseCase = startGameUseCase,
       _movePieceUseCase = movePieceUseCase,
       _gameRepository = gameRepository,
       super(GameInitialState()) {
    on<InitializeGame>(_onInitializeGame);
    on<StartGame>(_onStartGame);
    on<MovePieceLeft>(_onMovePieceLeft);
    on<MovePieceRight>(_onMovePieceRight);
    on<MovePieceDown>(_onMovePieceDown);
    on<PauseGame>(_onPauseGame);
    on<ResumeGame>(_onResumeGame);

    // Trigger initialization
    add(InitializeGame());
  }

  @override
  Future<void> close() {
    _gameTimer?.cancel();
    return super.close();
  }

  Future<void> _onInitializeGame(
    InitializeGame event,
    Emitter<SimpleGameState> emit,
  ) async {
    emit(GameLoadingState());

    try {
      _gameSettings = await _gameRepository.loadGameSettings();
      _currentGameState = GameState.initial();

      emit(
        GameReadyState(gameState: _currentGameState!, settings: _gameSettings),
      );
    } catch (e) {
      emit(GameErrorState(message: 'Failed to initialize: $e'));
    }
  }

  Future<void> _onStartGame(
    StartGame event,
    Emitter<SimpleGameState> emit,
  ) async {
    try {
      final gameState = await _startGameUseCase.call(StartGameParams.newGame());
      _currentGameState = gameState;
      _startGameTimer();

      emit(
        GamePlayingState(
          gameState: _currentGameState!,
          settings: _gameSettings,
        ),
      );
    } catch (e) {
      emit(GameErrorState(message: 'Failed to start game: $e'));
    }
  }

  Future<void> _onMovePieceLeft(
    MovePieceLeft event,
    Emitter<SimpleGameState> emit,
  ) async {
    await _movePiece(MoveDirection.left, emit);
  }

  Future<void> _onMovePieceRight(
    MovePieceRight event,
    Emitter<SimpleGameState> emit,
  ) async {
    await _movePiece(MoveDirection.right, emit);
  }

  Future<void> _onMovePieceDown(
    MovePieceDown event,
    Emitter<SimpleGameState> emit,
  ) async {
    await _movePiece(MoveDirection.down, emit);
  }

  Future<void> _movePiece(
    MoveDirection direction,
    Emitter<SimpleGameState> emit,
  ) async {
    if (_currentGameState == null ||
        _currentGameState!.status != GameStatus.playing) {
      return;
    }

    try {
      final gameState = await _movePieceUseCase.call(
        MovePieceParams(currentState: _currentGameState!, direction: direction),
      );

      _currentGameState = gameState;

      emit(
        GamePlayingState(
          gameState: _currentGameState!,
          settings: _gameSettings,
        ),
      );
    } catch (e) {
      // Ignore movement errors
    }
  }

  Future<void> _onPauseGame(
    PauseGame event,
    Emitter<SimpleGameState> emit,
  ) async {
    if (_currentGameState == null) return;

    _gameTimer?.cancel();
    _currentGameState = _currentGameState!.pauseGame();

    emit(
      GamePausedState(gameState: _currentGameState!, settings: _gameSettings),
    );
  }

  Future<void> _onResumeGame(
    ResumeGame event,
    Emitter<SimpleGameState> emit,
  ) async {
    if (_currentGameState == null) return;

    _currentGameState = _currentGameState!.resumeGame();
    _startGameTimer();

    emit(
      GamePlayingState(gameState: _currentGameState!, settings: _gameSettings),
    );
  }

  void _startGameTimer() {
    _gameTimer?.cancel();

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentGameState?.status == GameStatus.playing) {
        add(MovePieceDown());
      }
    });
  }
}

import 'package:equatable/equatable.dart';
import '../../core/utils/game_utils.dart';
import 'game_board.dart';
import 'score.dart';
import 'tetromino.dart';

/// Represents the overall state of the Tetris game
/// Immutable entity that contains all game information
class GameState extends Equatable {
  final GameBoard board;
  final Tetromino? currentPiece;
  final Tetromino? nextPiece;
  final Tetromino? heldPiece;
  final Score score;
  final GameStatus status;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool canHold;
  final List<String> pieceBag;

  const GameState({
    required this.board,
    this.currentPiece,
    this.nextPiece,
    this.heldPiece,
    required this.score,
    required this.status,
    this.startTime,
    this.endTime,
    this.canHold = true,
    this.pieceBag = const [],
  });

  /// Creates initial game state
  factory GameState.initial() {
    final bag = GameUtils.generatePieceBag();
    final firstPiece = Tetromino.spawn(bag[0]);
    final secondPiece = Tetromino.spawn(bag[1]);

    return GameState(
      board: GameBoard.empty(),
      currentPiece: firstPiece,
      nextPiece: secondPiece,
      score: const Score.initial(),
      status: GameStatus.ready,
      canHold: true,
      pieceBag: bag.sublist(2), // Remove first two pieces
    );
  }

  /// Creates game state for testing
  factory GameState.test({
    GameBoard? board,
    Tetromino? currentPiece,
    Tetromino? nextPiece,
    Tetromino? heldPiece,
    Score? score,
    GameStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    bool? canHold,
    List<String>? pieceBag,
  }) {
    return GameState(
      board: board ?? GameBoard.empty(),
      currentPiece: currentPiece,
      nextPiece: nextPiece,
      heldPiece: heldPiece,
      score: score ?? const Score.initial(),
      status: status ?? GameStatus.ready,
      startTime: startTime,
      endTime: endTime,
      canHold: canHold ?? true,
      pieceBag: pieceBag ?? [],
    );
  }

  /// Starts the game
  GameState startGame() {
    if (status != GameStatus.ready) {
      return this;
    }

    return copyWith(status: GameStatus.playing, startTime: DateTime.now());
  }

  /// Pauses the game
  GameState pauseGame() {
    if (status != GameStatus.playing) {
      return this;
    }

    return copyWith(status: GameStatus.paused);
  }

  /// Resumes the game
  GameState resumeGame() {
    if (status != GameStatus.paused) {
      return this;
    }

    return copyWith(status: GameStatus.playing);
  }

  /// Ends the game
  GameState endGame() {
    if (status == GameStatus.gameOver) {
      return this;
    }

    return copyWith(status: GameStatus.gameOver, endTime: DateTime.now());
  }

  /// Resets the game to initial state
  GameState resetGame() {
    return GameState.initial();
  }

  /// Moves current piece left
  GameState moveCurrentPieceLeft() {
    if (!_canMovePiece()) return this;

    final movedPiece = currentPiece!.moveLeft();
    if (board.canPlaceTetromino(movedPiece)) {
      return copyWith(currentPiece: movedPiece);
    }

    return this;
  }

  /// Moves current piece right
  GameState moveCurrentPieceRight() {
    if (!_canMovePiece()) return this;

    final movedPiece = currentPiece!.moveRight();
    if (board.canPlaceTetromino(movedPiece)) {
      return copyWith(currentPiece: movedPiece);
    }

    return this;
  }

  /// Moves current piece down (soft drop)
  GameState moveCurrentPieceDown() {
    if (!_canMovePiece()) return this;

    final movedPiece = currentPiece!.moveDown();
    if (board.canPlaceTetromino(movedPiece)) {
      return copyWith(currentPiece: movedPiece);
    }

    return this;
  }

  /// Rotates current piece clockwise
  GameState rotateCurrentPieceClockwise() {
    if (!_canMovePiece()) return this;

    final rotatedPiece = currentPiece!.rotateClockwise();
    if (board.canPlaceTetromino(rotatedPiece)) {
      return copyWith(currentPiece: rotatedPiece);
    }

    return this;
  }

  /// Rotates current piece counter-clockwise
  GameState rotateCurrentPieceCounterClockwise() {
    if (!_canMovePiece()) return this;

    final rotatedPiece = currentPiece!.rotateCounterClockwise();
    if (board.canPlaceTetromino(rotatedPiece)) {
      return copyWith(currentPiece: rotatedPiece);
    }

    return this;
  }

  /// Hard drops current piece
  GameState hardDropCurrentPiece() {
    if (!_canMovePiece()) return this;

    int dropDistance = 0;
    Tetromino droppedPiece = currentPiece!;

    // Find the lowest valid position
    while (true) {
      final nextPosition = droppedPiece.moveDown();
      if (board.canPlaceTetromino(nextPosition)) {
        droppedPiece = nextPosition;
        dropDistance++;
      } else {
        break;
      }
    }

    // Place the piece and add hard drop bonus
    final newBoard = board.placeTetromino(droppedPiece);
    final newScore = score.addHardDropBonus(dropDistance);

    return _placePieceAndContinue(newBoard, newScore);
  }

  /// Holds the current piece
  GameState holdCurrentPiece() {
    if (!_canMovePiece() || !canHold) return this;

    if (heldPiece == null) {
      // First hold - move current to held, spawn next
      return _spawnNextPiece().copyWith(
        heldPiece: Tetromino.spawn(currentPiece!.type),
        canHold: false,
      );
    } else {
      // Swap current with held
      final newCurrent = Tetromino.spawn(heldPiece!.type);
      final newHeld = Tetromino.spawn(currentPiece!.type);

      return copyWith(
        currentPiece: newCurrent,
        heldPiece: newHeld,
        canHold: false,
      );
    }
  }

  /// Places current piece on board (called when piece can't move down)
  GameState placeCurrentPiece() {
    if (!_canMovePiece()) return this;

    final newBoard = board.placeTetromino(currentPiece!);
    return _placePieceAndContinue(newBoard, score);
  }

  /// Gets the ghost piece position (preview of where piece will land)
  Tetromino? getGhostPiece() {
    if (currentPiece == null) return null;

    Tetromino ghostPiece = currentPiece!;

    // Find the lowest valid position
    while (true) {
      final nextPosition = ghostPiece.moveDown();
      if (board.canPlaceTetromino(nextPosition)) {
        ghostPiece = nextPosition;
      } else {
        break;
      }
    }

    return ghostPiece;
  }

  /// Gets game duration
  Duration getGameDuration() {
    if (startTime == null) return Duration.zero;

    final endTimeToUse = endTime ?? DateTime.now();
    return endTimeToUse.difference(startTime!);
  }

  /// Checks if game is active (playing or paused)
  bool get isActive =>
      status == GameStatus.playing || status == GameStatus.paused;

  /// Checks if game is playing
  bool get isPlaying => status == GameStatus.playing;

  /// Checks if game is paused
  bool get isPaused => status == GameStatus.paused;

  /// Checks if game is over
  bool get isGameOver => status == GameStatus.gameOver;

  /// Checks if game is ready to start
  bool get isReady => status == GameStatus.ready;

  /// Helper method to check if current piece can be moved
  bool _canMovePiece() {
    return currentPiece != null && status == GameStatus.playing;
  }

  /// Helper method to spawn next piece
  GameState _spawnNextPiece() {
    if (nextPiece == null) return this;

    // Check if the next piece can be placed at spawn position
    if (!board.canPlaceTetromino(nextPiece!)) {
      // Game over - can't spawn new piece
      print(
        'DEBUG: Cannot spawn next piece ${nextPiece!.type} at position ${nextPiece!.position}',
      );
      return copyWith(clearCurrentPiece: true).endGame();
    }

    List<String> newBag = List.from(pieceBag);
    Tetromino? newNext;

    // Get next piece from bag or generate new bag
    if (newBag.isNotEmpty) {
      newNext = Tetromino.spawn(newBag.removeAt(0));
    } else {
      newBag = GameUtils.generatePieceBag();
      newNext = Tetromino.spawn(newBag.removeAt(0));
    }

    print(
      'DEBUG: Successfully spawning piece ${nextPiece!.type} as current, next will be ${newNext?.type}',
    );

    return copyWith(
      currentPiece: nextPiece,
      nextPiece: newNext,
      pieceBag: newBag,
      canHold: true,
    );
  }

  /// Helper method to place piece and handle line clearing
  GameState _placePieceAndContinue(GameBoard newBoard, Score currentScore) {
    print('DEBUG: Placing piece and continuing...');

    // Clear complete lines
    final clearResult = newBoard.clearCompleteLines();
    final finalBoard = clearResult.board;
    final linesCleared = clearResult.linesCleared;

    print('DEBUG: Lines cleared: $linesCleared');

    // Update score with cleared lines
    final newScore = currentScore.addLinesCleared(linesCleared);

    // Check for game over - temporarily disabled to debug
    // if (finalBoard.isGameOver()) {
    //   print('DEBUG: Game over detected by board.isGameOver()');
    //   return copyWith(
    //     board: finalBoard,
    //     score: newScore,
    //     clearCurrentPiece: true,
    //   ).endGame();
    // }

    print('DEBUG: Board is not game over, spawning next piece...');

    // Spawn next piece
    final nextState = _spawnNextPiece();

    return nextState.copyWith(board: finalBoard, score: newScore);
  }

  /// Creates a copy of this game state with optional modifications
  GameState copyWith({
    GameBoard? board,
    Tetromino? currentPiece,
    Tetromino? nextPiece,
    Tetromino? heldPiece,
    Score? score,
    GameStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    bool? canHold,
    List<String>? pieceBag,
    bool clearCurrentPiece = false,
    bool clearNextPiece = false,
    bool clearHeldPiece = false,
    bool clearStartTime = false,
    bool clearEndTime = false,
  }) {
    return GameState(
      board: board ?? this.board,
      currentPiece: clearCurrentPiece
          ? null
          : (currentPiece ?? this.currentPiece),
      nextPiece: clearNextPiece ? null : (nextPiece ?? this.nextPiece),
      heldPiece: clearHeldPiece ? null : (heldPiece ?? this.heldPiece),
      score: score ?? this.score,
      status: status ?? this.status,
      startTime: clearStartTime ? null : (startTime ?? this.startTime),
      endTime: clearEndTime ? null : (endTime ?? this.endTime),
      canHold: canHold ?? this.canHold,
      pieceBag: pieceBag ?? this.pieceBag,
    );
  }

  @override
  List<Object?> get props => [
    board,
    currentPiece,
    nextPiece,
    heldPiece,
    score,
    status,
    startTime,
    endTime,
    canHold,
    pieceBag,
  ];

  @override
  String toString() {
    return 'GameState(status: $status, score: ${score.points}, level: ${score.level})';
  }
}

/// Enumeration of possible game states
enum GameStatus { ready, playing, paused, gameOver }

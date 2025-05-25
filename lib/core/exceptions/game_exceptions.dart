/// Custom exceptions for Tetris game
/// Provides specific error types for different game scenarios
library;

/// Base exception class for all game-related errors
abstract class GameException implements Exception {
  final String message;
  final String? code;

  const GameException(this.message, [this.code]);

  @override
  String toString() =>
      'GameException: $message${code != null ? ' ($code)' : ''}';
}

/// Exception thrown when an invalid move is attempted
class InvalidMoveException extends GameException {
  const InvalidMoveException(String message) : super(message, 'INVALID_MOVE');
}

/// Exception thrown when trying to rotate a piece in an invalid position
class InvalidRotationException extends GameException {
  const InvalidRotationException(String message)
    : super(message, 'INVALID_ROTATION');
}

/// Exception thrown when accessing invalid board coordinates
class InvalidBoardPositionException extends GameException {
  const InvalidBoardPositionException(String message)
    : super(message, 'INVALID_POSITION');
}

/// Exception thrown when game is in wrong state for operation
class InvalidGameStateException extends GameException {
  const InvalidGameStateException(String message)
    : super(message, 'INVALID_STATE');
}

/// Exception thrown when piece spawning fails
class PieceSpawnException extends GameException {
  const PieceSpawnException(String message) : super(message, 'SPAWN_FAILED');
}

/// Exception thrown when board operation fails
class BoardOperationException extends GameException {
  const BoardOperationException(String message)
    : super(message, 'BOARD_OPERATION');
}

/// Exception thrown when score calculation fails
class ScoreCalculationException extends GameException {
  const ScoreCalculationException(String message)
    : super(message, 'SCORE_CALCULATION');
}

import 'dart:math';
import '../constants/game_constants.dart';

/// Utility functions for Tetris game operations
class GameUtils {
  GameUtils._();

  static final Random _random = Random();

  /// Generates a random tetromino type
  static String getRandomPieceType() {
    return GameConstants.pieceTypes[_random.nextInt(
      GameConstants.pieceTypes.length,
    )];
  }

  /// Generates a bag of 7 pieces (standard Tetris randomization)
  static List<String> generatePieceBag() {
    final bag = List<String>.from(GameConstants.pieceTypes);
    bag.shuffle(_random);
    return bag;
  }

  /// Checks if a position is within board bounds
  static bool isValidBoardPosition(int row, int col) {
    return row >= 0 &&
        row < GameConstants.boardHeight &&
        col >= 0 &&
        col < GameConstants.boardWidth;
  }

  /// Checks if a position is within tetromino shape bounds
  static bool isValidShapePosition(int row, int col, int shapeSize) {
    return row >= 0 && row < shapeSize && col >= 0 && col < shapeSize;
  }

  /// Gets the current level based on lines cleared
  static int calculateLevel(int linesCleared) {
    return (linesCleared ~/ GameConstants.linesPerLevel).clamp(
      0,
      GameConstants.maxLevel,
    );
  }

  /// Calculates drop speed for given level
  static int calculateDropSpeed(int level) {
    final speed =
        GameConstants.initialDropSpeed -
        (level * GameConstants.levelSpeedDecrease);
    return speed.clamp(
      GameConstants.minDropSpeed,
      GameConstants.initialDropSpeed,
    );
  }

  /// Calculates score based on lines cleared and level
  static int calculateScore(
    int linesCleared,
    int level, {
    bool isSoftDrop = false,
    bool isHardDrop = false,
  }) {
    int baseScore = 0;

    switch (linesCleared) {
      case 1:
        baseScore = GameConstants.singleLineScore;
        break;
      case 2:
        baseScore = GameConstants.doubleLineScore;
        break;
      case 3:
        baseScore = GameConstants.tripleLineScore;
        break;
      case 4:
        baseScore = GameConstants.tetrisScore;
        break;
      default:
        baseScore = 0;
    }

    // Apply level multiplier
    int score = baseScore * (level + 1);

    // Apply drop bonuses
    if (isSoftDrop) {
      score += GameConstants.softDropBonus;
    }
    if (isHardDrop) {
      score *= GameConstants.hardDropMultiplier;
    }

    return score;
  }

  /// Rotates a 2D matrix 90 degrees clockwise
  static List<List<int>> rotateMatrixClockwise(List<List<int>> matrix) {
    final size = matrix.length;
    final rotated = List.generate(size, (_) => List.filled(size, 0));

    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        rotated[j][size - 1 - i] = matrix[i][j];
      }
    }

    return rotated;
  }

  /// Rotates a 2D matrix 90 degrees counter-clockwise
  static List<List<int>> rotateMatrixCounterClockwise(List<List<int>> matrix) {
    final size = matrix.length;
    final rotated = List.generate(size, (_) => List.filled(size, 0));

    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        rotated[size - 1 - j][i] = matrix[i][j];
      }
    }

    return rotated;
  }

  /// Gets all filled positions from a tetromino shape
  static List<List<int>> getFilledPositions(List<List<int>> shape) {
    final positions = <List<int>>[];

    for (int row = 0; row < shape.length; row++) {
      for (int col = 0; col < shape[row].length; col++) {
        if (shape[row][col] == 1) {
          positions.add([row, col]);
        }
      }
    }

    return positions;
  }

  /// Converts absolute board positions to relative shape positions
  static List<List<int>> boardToShapePositions(
    List<List<int>> boardPositions,
    int pieceRow,
    int pieceCol,
  ) {
    return boardPositions
        .map((pos) => [pos[0] - pieceRow, pos[1] - pieceCol])
        .toList();
  }

  /// Converts relative shape positions to absolute board positions
  static List<List<int>> shapeToBoardPositions(
    List<List<int>> shapePositions,
    int pieceRow,
    int pieceCol,
  ) {
    return shapePositions
        .map((pos) => [pos[0] + pieceRow, pos[1] + pieceCol])
        .toList();
  }

  /// Clamps a value between min and max
  static T clamp<T extends num>(T value, T min, T max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  /// Checks if two 2D lists are equal
  static bool areListsEqual<T>(List<List<T>> list1, List<List<T>> list2) {
    if (list1.length != list2.length) return false;

    for (int i = 0; i < list1.length; i++) {
      if (list1[i].length != list2[i].length) return false;
      for (int j = 0; j < list1[i].length; j++) {
        if (list1[i][j] != list2[i][j]) return false;
      }
    }

    return true;
  }

  /// Creates a deep copy of a 2D list
  static List<List<T>> deepCopyMatrix<T>(List<List<T>> matrix) {
    return matrix.map((row) => List<T>.from(row)).toList();
  }
}

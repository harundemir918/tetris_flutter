import 'package:equatable/equatable.dart';
import '../../core/constants/game_constants.dart';
import '../../core/exceptions/game_exceptions.dart';
import 'position.dart';

/// Represents a Tetromino piece in the Tetris game
/// Immutable entity containing shape, position, rotation, and type information
class Tetromino extends Equatable {
  final String type;
  final Position position;
  final int rotationState;
  final List<List<int>> shape;

  const Tetromino({
    required this.type,
    required this.position,
    required this.rotationState,
    required this.shape,
  });

  /// Creates a new Tetromino of the specified type at spawn position
  factory Tetromino.spawn(String type) {
    if (!GameConstants.pieceTypes.contains(type)) {
      throw InvalidBoardPositionException('Invalid tetromino type: $type');
    }

    const spawnPosition = Position(
      row: GameConstants.spawnRow,
      column: GameConstants.spawnColumn,
    );

    final shapes = GameConstants.tetrominoShapes[type]!;

    return Tetromino(
      type: type,
      position: spawnPosition,
      rotationState: 0,
      shape: _deepCopyShape(shapes[0]),
    );
  }

  /// Creates a tetromino for testing purposes
  factory Tetromino.test({
    required String type,
    Position? position,
    int? rotationState,
    List<List<int>>? shape,
  }) {
    const defaultPosition = Position(row: 0, column: 0);
    const defaultRotation = 0;

    final defaultShape =
        GameConstants.tetrominoShapes[type]?[0] ??
        [
          [1, 1],
          [1, 1],
        ];

    return Tetromino(
      type: type,
      position: position ?? defaultPosition,
      rotationState: rotationState ?? defaultRotation,
      shape: shape ?? _deepCopyShape(defaultShape),
    );
  }

  /// Moves the tetromino to a new position
  Tetromino moveTo(Position newPosition) {
    return copyWith(position: newPosition);
  }

  /// Moves the tetromino by the given offset
  Tetromino moveBy({int deltaRow = 0, int deltaColumn = 0}) {
    final newPosition = position.moveBy(
      deltaRow: deltaRow,
      deltaColumn: deltaColumn,
    );
    return copyWith(position: newPosition);
  }

  /// Moves the tetromino left by one column
  Tetromino moveLeft() => moveBy(deltaColumn: -1);

  /// Moves the tetromino right by one column
  Tetromino moveRight() => moveBy(deltaColumn: 1);

  /// Moves the tetromino down by one row
  Tetromino moveDown() => moveBy(deltaRow: 1);

  /// Rotates the tetromino clockwise
  Tetromino rotateClockwise() {
    final shapes = GameConstants.tetrominoShapes[type]!;
    final newRotationState = (rotationState + 1) % shapes.length;
    final newShape = _deepCopyShape(shapes[newRotationState]);

    return copyWith(rotationState: newRotationState, shape: newShape);
  }

  /// Rotates the tetromino counter-clockwise
  Tetromino rotateCounterClockwise() {
    final shapes = GameConstants.tetrominoShapes[type]!;
    final newRotationState = (rotationState - 1) % shapes.length;
    final adjustedRotationState = newRotationState < 0
        ? shapes.length - 1
        : newRotationState;
    final newShape = _deepCopyShape(shapes[adjustedRotationState]);

    return copyWith(rotationState: adjustedRotationState, shape: newShape);
  }

  /// Gets all absolute positions occupied by this tetromino on the board
  List<Position> getOccupiedPositions() {
    final positions = <Position>[];

    for (int row = 0; row < shape.length; row++) {
      for (int col = 0; col < shape[row].length; col++) {
        if (shape[row][col] == 1) {
          positions.add(
            Position(row: position.row + row, column: position.column + col),
          );
        }
      }
    }

    return positions;
  }

  /// Gets the relative positions of filled cells within the shape
  List<Position> getShapePositions() {
    final positions = <Position>[];

    for (int row = 0; row < shape.length; row++) {
      for (int col = 0; col < shape[row].length; col++) {
        if (shape[row][col] == 1) {
          positions.add(Position(row: row, column: col));
        }
      }
    }

    return positions;
  }

  /// Checks if this tetromino would be at a valid position on the board
  bool isValidPosition({
    int? boardWidth,
    int? boardHeight,
    List<List<bool>>? occupiedCells,
  }) {
    final width = boardWidth ?? GameConstants.boardWidth;
    final height = boardHeight ?? GameConstants.boardHeight;

    final occupiedPositions = getOccupiedPositions();

    for (final pos in occupiedPositions) {
      // Check board bounds
      if (!pos.isWithinBounds(height, width)) {
        return false;
      }

      // Check collision with existing pieces
      if (occupiedCells != null) {
        if (pos.row >= 0 &&
            pos.row < occupiedCells.length &&
            pos.column >= 0 &&
            pos.column < occupiedCells[pos.row].length) {
          if (occupiedCells[pos.row][pos.column]) {
            return false;
          }
        }
      }
    }

    return true;
  }

  /// Gets the color for this tetromino type
  int getColor() {
    return GameConstants.pieceColors[type] ??
        GameConstants.pieceColors['empty']!;
  }

  /// Gets the bounding box of the shape (for rendering optimization)
  ({int minRow, int maxRow, int minCol, int maxCol}) getBoundingBox() {
    int minRow = shape.length;
    int maxRow = -1;
    int minCol = shape[0].length;
    int maxCol = -1;

    for (int row = 0; row < shape.length; row++) {
      for (int col = 0; col < shape[row].length; col++) {
        if (shape[row][col] == 1) {
          minRow = minRow < row ? minRow : row;
          maxRow = maxRow > row ? maxRow : row;
          minCol = minCol < col ? minCol : col;
          maxCol = maxCol > col ? maxCol : col;
        }
      }
    }

    return (minRow: minRow, maxRow: maxRow, minCol: minCol, maxCol: maxCol);
  }

  /// Creates a copy of this tetromino with optional modifications
  Tetromino copyWith({
    String? type,
    Position? position,
    int? rotationState,
    List<List<int>>? shape,
  }) {
    return Tetromino(
      type: type ?? this.type,
      position: position ?? this.position,
      rotationState: rotationState ?? this.rotationState,
      shape: shape ?? _deepCopyShape(this.shape),
    );
  }

  /// Creates a deep copy of a 2D list shape
  static List<List<int>> _deepCopyShape(List<List<int>> original) {
    return original.map((row) => List<int>.from(row)).toList();
  }

  @override
  List<Object?> get props => [type, position, rotationState, shape];

  @override
  String toString() {
    return 'Tetromino(type: $type, position: $position, rotation: $rotationState)';
  }
}

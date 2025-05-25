import 'package:equatable/equatable.dart';
import '../../core/constants/game_constants.dart';
import '../../core/exceptions/game_exceptions.dart';
import 'position.dart';
import 'tetromino.dart';

/// Represents the Tetris game board
/// Immutable entity that manages the 10x20 playing field
class GameBoard extends Equatable {
  final List<List<String?>> cells;
  final int width;
  final int height;

  const GameBoard({
    required this.cells,
    required this.width,
    required this.height,
  });

  /// Creates an empty game board with standard Tetris dimensions
  factory GameBoard.empty() {
    return GameBoard(
      cells: List.generate(
        GameConstants.boardHeight,
        (_) => List.filled(GameConstants.boardWidth, null),
      ),
      width: GameConstants.boardWidth,
      height: GameConstants.boardHeight,
    );
  }

  /// Creates a game board for testing with custom dimensions
  factory GameBoard.test({
    int? width,
    int? height,
    List<List<String?>>? cells,
  }) {
    final boardWidth = width ?? GameConstants.boardWidth;
    final boardHeight = height ?? GameConstants.boardHeight;

    return GameBoard(
      cells:
          cells ??
          List.generate(boardHeight, (_) => List.filled(boardWidth, null)),
      width: boardWidth,
      height: boardHeight,
    );
  }

  /// Checks if a position is valid on this board
  bool isValidPosition(Position position) {
    return position.row >= 0 &&
        position.row < height &&
        position.column >= 0 &&
        position.column < width;
  }

  /// Checks if a cell is occupied at the given position
  bool isCellOccupied(Position position) {
    if (!isValidPosition(position)) {
      throw InvalidBoardPositionException(
        'Position $position is outside board bounds',
      );
    }
    return cells[position.row][position.column] != null;
  }

  /// Checks if a tetromino can be placed at its current position
  bool canPlaceTetromino(Tetromino tetromino) {
    final occupiedPositions = tetromino.getOccupiedPositions();

    for (final position in occupiedPositions) {
      // Check if position is within board bounds
      if (!isValidPosition(position)) {
        return false;
      }

      // Check if cell is already occupied
      if (isCellOccupied(position)) {
        return false;
      }
    }

    return true;
  }

  /// Places a tetromino on the board, returning a new board
  GameBoard placeTetromino(Tetromino tetromino) {
    if (!canPlaceTetromino(tetromino)) {
      throw InvalidMoveException(
        'Cannot place tetromino at position ${tetromino.position}',
      );
    }

    final newCells = _deepCopyCells();
    final occupiedPositions = tetromino.getOccupiedPositions();

    for (final position in occupiedPositions) {
      newCells[position.row][position.column] = tetromino.type;
    }

    return copyWith(cells: newCells);
  }

  /// Checks if a row is completely filled
  bool isRowComplete(int row) {
    if (row < 0 || row >= height) {
      throw InvalidBoardPositionException('Row $row is outside board bounds');
    }

    return cells[row].every((cell) => cell != null);
  }

  /// Gets all complete row indices
  List<int> getCompleteRows() {
    final completeRows = <int>[];

    for (int row = 0; row < height; row++) {
      if (isRowComplete(row)) {
        completeRows.add(row);
      }
    }

    return completeRows;
  }

  /// Clears complete lines and returns new board with cleared lines
  /// Returns a record with the new board and number of lines cleared
  ({GameBoard board, int linesCleared}) clearCompleteLines() {
    final completeRows = getCompleteRows();

    if (completeRows.isEmpty) {
      return (board: this, linesCleared: 0);
    }

    final newCells = <List<String?>>[];

    // Add empty rows at the top for each cleared line
    for (int i = 0; i < completeRows.length; i++) {
      newCells.add(List.filled(width, null));
    }

    // Add remaining rows (skip complete rows)
    for (int row = 0; row < height; row++) {
      if (!completeRows.contains(row)) {
        newCells.add(List<String?>.from(cells[row]));
      }
    }

    final newBoard = copyWith(cells: newCells);
    return (board: newBoard, linesCleared: completeRows.length);
  }

  /// Gets the highest occupied row (lowest row number)
  int getHighestOccupiedRow() {
    for (int row = 0; row < height; row++) {
      if (cells[row].any((cell) => cell != null)) {
        return row;
      }
    }
    return height; // Board is empty
  }

  /// Checks if the board is in a game over state
  /// Game over occurs when pieces reach the top of the board
  bool isGameOver() {
    // Check if any cell in the spawn area is occupied
    for (int col = 0; col < width; col++) {
      if (cells[GameConstants.spawnRow][col] != null) {
        return true;
      }
    }
    return false;
  }

  /// Gets the number of occupied cells
  int getOccupiedCellCount() {
    int count = 0;
    for (int row = 0; row < height; row++) {
      for (int col = 0; col < width; col++) {
        if (cells[row][col] != null) {
          count++;
        }
      }
    }
    return count;
  }

  /// Gets all occupied positions on the board
  List<Position> getOccupiedPositions() {
    final positions = <Position>[];

    for (int row = 0; row < height; row++) {
      for (int col = 0; col < width; col++) {
        if (cells[row][col] != null) {
          positions.add(Position(row: row, column: col));
        }
      }
    }

    return positions;
  }

  /// Gets the piece type at a specific position
  String? getPieceTypeAt(Position position) {
    if (!isValidPosition(position)) {
      throw InvalidBoardPositionException(
        'Position $position is outside board bounds',
      );
    }
    return cells[position.row][position.column];
  }

  /// Creates a copy of this board with optional modifications
  GameBoard copyWith({List<List<String?>>? cells, int? width, int? height}) {
    return GameBoard(
      cells: cells ?? _deepCopyCells(),
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  /// Creates a deep copy of the cells matrix
  List<List<String?>> _deepCopyCells() {
    return cells.map((row) => List<String?>.from(row)).toList();
  }

  /// Checks if the board is empty
  bool isEmpty() {
    return cells.every((row) => row.every((cell) => cell == null));
  }

  /// Gets a visual representation of the board for debugging
  String toDebugString() {
    final buffer = StringBuffer();
    buffer.writeln('GameBoard ${width}x$height:');

    for (int row = 0; row < height; row++) {
      buffer.write('|');
      for (int col = 0; col < width; col++) {
        final cell = cells[row][col];
        buffer.write(cell ?? '.');
      }
      buffer.writeln('|');
    }

    return buffer.toString();
  }

  @override
  List<Object?> get props => [cells, width, height];

  @override
  String toString() =>
      'GameBoard(${width}x$height, occupied: ${getOccupiedCellCount()})';
}

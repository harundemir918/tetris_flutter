import 'package:equatable/equatable.dart';

/// Represents a position on the Tetris game board
/// Immutable entity that follows domain-driven design principles
class Position extends Equatable {
  final int row;
  final int column;

  const Position({required this.row, required this.column});

  /// Creates a position at the origin (0, 0)
  const Position.origin() : row = 0, column = 0;

  /// Creates a new position moved by the given offset
  Position moveBy({int deltaRow = 0, int deltaColumn = 0}) {
    return Position(row: row + deltaRow, column: column + deltaColumn);
  }

  /// Creates a new position moved left by one column
  Position moveLeft() => moveBy(deltaColumn: -1);

  /// Creates a new position moved right by one column
  Position moveRight() => moveBy(deltaColumn: 1);

  /// Creates a new position moved down by one row
  Position moveDown() => moveBy(deltaRow: 1);

  /// Creates a new position moved up by one row
  Position moveUp() => moveBy(deltaRow: -1);

  /// Checks if this position is within the given bounds
  bool isWithinBounds(int maxRow, int maxColumn) {
    return row >= 0 && row < maxRow && column >= 0 && column < maxColumn;
  }

  /// Checks if this position is valid for a Tetris board
  bool isValidBoardPosition() {
    return row >= 0 && row < 20 && column >= 0 && column < 10;
  }

  /// Distance to another position (Manhattan distance)
  int distanceTo(Position other) {
    return (row - other.row).abs() + (column - other.column).abs();
  }

  /// Creates a copy of this position with optional modifications
  Position copyWith({int? row, int? column}) {
    return Position(row: row ?? this.row, column: column ?? this.column);
  }

  @override
  List<Object?> get props => [row, column];

  @override
  String toString() => 'Position(row: $row, column: $column)';
}

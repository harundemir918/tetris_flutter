import 'package:flutter_test/flutter_test.dart';
import 'package:tetris_flutter/domain/entities/position.dart';

void main() {
  group('Position', () {
    group('creation', () {
      test('should create position with given row and column', () {
        // Act
        const position = Position(row: 5, column: 3);

        // Assert
        expect(position.row, 5);
        expect(position.column, 3);
      });

      test('should create position at origin', () {
        // Act
        const position = Position.origin();

        // Assert
        expect(position.row, 0);
        expect(position.column, 0);
      });
    });

    group('movement', () {
      const initialPosition = Position(row: 5, column: 5);

      test('should move by delta values', () {
        // Act
        final moved = initialPosition.moveBy(deltaRow: 2, deltaColumn: -1);

        // Assert
        expect(moved.row, 7);
        expect(moved.column, 4);
      });

      test('should move left by one column', () {
        // Act
        final moved = initialPosition.moveLeft();

        // Assert
        expect(moved.row, 5);
        expect(moved.column, 4);
      });

      test('should move right by one column', () {
        // Act
        final moved = initialPosition.moveRight();

        // Assert
        expect(moved.row, 5);
        expect(moved.column, 6);
      });

      test('should move down by one row', () {
        // Act
        final moved = initialPosition.moveDown();

        // Assert
        expect(moved.row, 6);
        expect(moved.column, 5);
      });

      test('should move up by one row', () {
        // Act
        final moved = initialPosition.moveUp();

        // Assert
        expect(moved.row, 4);
        expect(moved.column, 5);
      });

      test('should not modify original position when moving', () {
        // Act
        initialPosition.moveBy(deltaRow: 10, deltaColumn: 10);

        // Assert
        expect(initialPosition.row, 5);
        expect(initialPosition.column, 5);
      });
    });

    group('bounds checking', () {
      test('should return true when position is within bounds', () {
        // Arrange
        const position = Position(row: 3, column: 4);

        // Act
        final result = position.isWithinBounds(10, 10);

        // Assert
        expect(result, true);
      });

      test('should return false when row is negative', () {
        // Arrange
        const position = Position(row: -1, column: 4);

        // Act
        final result = position.isWithinBounds(10, 10);

        // Assert
        expect(result, false);
      });

      test('should return false when column is negative', () {
        // Arrange
        const position = Position(row: 3, column: -1);

        // Act
        final result = position.isWithinBounds(10, 10);

        // Assert
        expect(result, false);
      });

      test('should return false when row exceeds bounds', () {
        // Arrange
        const position = Position(row: 10, column: 4);

        // Act
        final result = position.isWithinBounds(10, 10);

        // Assert
        expect(result, false);
      });

      test('should return false when column exceeds bounds', () {
        // Arrange
        const position = Position(row: 3, column: 10);

        // Act
        final result = position.isWithinBounds(10, 10);

        // Assert
        expect(result, false);
      });
    });

    group('Tetris board validation', () {
      test('should return true for valid board position', () {
        // Arrange
        const position = Position(row: 10, column: 5);

        // Act
        final result = position.isValidBoardPosition();

        // Assert
        expect(result, true);
      });

      test('should return false for position outside board height', () {
        // Arrange
        const position = Position(row: 20, column: 5);

        // Act
        final result = position.isValidBoardPosition();

        // Assert
        expect(result, false);
      });

      test('should return false for position outside board width', () {
        // Arrange
        const position = Position(row: 10, column: 10);

        // Act
        final result = position.isValidBoardPosition();

        // Assert
        expect(result, false);
      });

      test('should return false for negative position', () {
        // Arrange
        const position = Position(row: -1, column: 5);

        // Act
        final result = position.isValidBoardPosition();

        // Assert
        expect(result, false);
      });
    });

    group('distance calculation', () {
      test('should calculate Manhattan distance correctly', () {
        // Arrange
        const pos1 = Position(row: 1, column: 1);
        const pos2 = Position(row: 4, column: 5);

        // Act
        final distance = pos1.distanceTo(pos2);

        // Assert
        expect(distance, 7); // |1-4| + |1-5| = 3 + 4 = 7
      });

      test('should return zero distance for same position', () {
        // Arrange
        const position = Position(row: 3, column: 3);

        // Act
        final distance = position.distanceTo(position);

        // Assert
        expect(distance, 0);
      });
    });

    group('copying', () {
      test('should copy with modified row', () {
        // Arrange
        const original = Position(row: 5, column: 3);

        // Act
        final copied = original.copyWith(row: 8);

        // Assert
        expect(copied.row, 8);
        expect(copied.column, 3);
        expect(original.row, 5); // Original unchanged
      });

      test('should copy with modified column', () {
        // Arrange
        const original = Position(row: 5, column: 3);

        // Act
        final copied = original.copyWith(column: 7);

        // Assert
        expect(copied.row, 5);
        expect(copied.column, 7);
        expect(original.column, 3); // Original unchanged
      });

      test('should copy with both values modified', () {
        // Arrange
        const original = Position(row: 5, column: 3);

        // Act
        final copied = original.copyWith(row: 1, column: 9);

        // Assert
        expect(copied.row, 1);
        expect(copied.column, 9);
      });

      test('should copy without modifications when no parameters given', () {
        // Arrange
        const original = Position(row: 5, column: 3);

        // Act
        final copied = original.copyWith();

        // Assert
        expect(copied.row, 5);
        expect(copied.column, 3);
        expect(copied, original);
      });
    });

    group('equality', () {
      test('should be equal when row and column are same', () {
        // Arrange
        const pos1 = Position(row: 3, column: 4);
        const pos2 = Position(row: 3, column: 4);

        // Assert
        expect(pos1, pos2);
        expect(pos1.hashCode, pos2.hashCode);
      });

      test('should not be equal when row differs', () {
        // Arrange
        const pos1 = Position(row: 3, column: 4);
        const pos2 = Position(row: 5, column: 4);

        // Assert
        expect(pos1, isNot(pos2));
      });

      test('should not be equal when column differs', () {
        // Arrange
        const pos1 = Position(row: 3, column: 4);
        const pos2 = Position(row: 3, column: 6);

        // Assert
        expect(pos1, isNot(pos2));
      });
    });

    group('string representation', () {
      test('should return readable string representation', () {
        // Arrange
        const position = Position(row: 3, column: 4);

        // Act
        final string = position.toString();

        // Assert
        expect(string, 'Position(row: 3, column: 4)');
      });
    });
  });
}

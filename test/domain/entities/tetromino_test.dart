import 'package:flutter_test/flutter_test.dart';
import 'package:tetris_flutter/core/exceptions/game_exceptions.dart';
import 'package:tetris_flutter/domain/entities/position.dart';
import 'package:tetris_flutter/domain/entities/tetromino.dart';

void main() {
  group('Tetromino', () {
    group('creation', () {
      test('should create tetromino with given properties', () {
        // Arrange
        const position = Position(row: 5, column: 3);
        const shape = [
          [1, 1],
          [1, 1],
        ];

        // Act
        final tetromino = Tetromino(
          type: 'O',
          position: position,
          rotationState: 0,
          shape: shape,
        );

        // Assert
        expect(tetromino.type, 'O');
        expect(tetromino.position, position);
        expect(tetromino.rotationState, 0);
        expect(tetromino.shape, shape);
      });

      test('should spawn I piece at correct position', () {
        // Act
        final tetromino = Tetromino.spawn('I');

        // Assert
        expect(tetromino.type, 'I');
        expect(tetromino.position.row, 0);
        expect(tetromino.position.column, 4);
        expect(tetromino.rotationState, 0);
        expect(tetromino.shape.length, 4);
      });

      test('should spawn O piece correctly', () {
        // Act
        final tetromino = Tetromino.spawn('O');

        // Assert
        expect(tetromino.type, 'O');
        expect(tetromino.shape, [
          [0, 1, 1, 0],
          [0, 1, 1, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ]);
      });

      test('should throw exception for invalid piece type', () {
        // Act & Assert
        expect(
          () => Tetromino.spawn('X'),
          throwsA(isA<InvalidBoardPositionException>()),
        );
      });

      test('should create test tetromino with defaults', () {
        // Act
        final tetromino = Tetromino.test(type: 'T');

        // Assert
        expect(tetromino.type, 'T');
        expect(tetromino.position, const Position(row: 0, column: 0));
        expect(tetromino.rotationState, 0);
      });

      test('should create test tetromino with custom values', () {
        // Arrange
        const position = Position(row: 5, column: 3);
        const shape = [
          [1, 0],
          [1, 1],
        ];

        // Act
        final tetromino = Tetromino.test(
          type: 'L',
          position: position,
          rotationState: 2,
          shape: shape,
        );

        // Assert
        expect(tetromino.type, 'L');
        expect(tetromino.position, position);
        expect(tetromino.rotationState, 2);
        expect(tetromino.shape, shape);
      });
    });

    group('movement', () {
      late Tetromino tetromino;

      setUp(() {
        tetromino = Tetromino.test(
          type: 'T',
          position: const Position(row: 5, column: 5),
        );
      });

      test('should move to new position', () {
        // Arrange
        const newPosition = Position(row: 8, column: 3);

        // Act
        final moved = tetromino.moveTo(newPosition);

        // Assert
        expect(moved.position, newPosition);
        expect(moved.type, tetromino.type);
        expect(moved.rotationState, tetromino.rotationState);
      });

      test('should move by delta values', () {
        // Act
        final moved = tetromino.moveBy(deltaRow: 2, deltaColumn: -1);

        // Assert
        expect(moved.position.row, 7);
        expect(moved.position.column, 4);
      });

      test('should move left', () {
        // Act
        final moved = tetromino.moveLeft();

        // Assert
        expect(moved.position.row, 5);
        expect(moved.position.column, 4);
      });

      test('should move right', () {
        // Act
        final moved = tetromino.moveRight();

        // Assert
        expect(moved.position.row, 5);
        expect(moved.position.column, 6);
      });

      test('should move down', () {
        // Act
        final moved = tetromino.moveDown();

        // Assert
        expect(moved.position.row, 6);
        expect(moved.position.column, 5);
      });

      test('should not modify original when moving', () {
        // Act
        tetromino.moveBy(deltaRow: 10, deltaColumn: 10);

        // Assert
        expect(tetromino.position.row, 5);
        expect(tetromino.position.column, 5);
      });
    });

    group('rotation', () {
      test('should rotate I piece clockwise correctly', () {
        // Arrange
        final tetromino = Tetromino.spawn('I');

        // Act
        final rotated = tetromino.rotateClockwise();

        // Assert
        expect(rotated.rotationState, 1);
        expect(rotated.shape, [
          [0, 0, 1, 0],
          [0, 0, 1, 0],
          [0, 0, 1, 0],
          [0, 0, 1, 0],
        ]);
      });

      test('should rotate T piece clockwise through all states', () {
        // Arrange
        final tetromino = Tetromino.spawn('T');

        // Act & Assert
        final rotation1 = tetromino.rotateClockwise();
        expect(rotation1.rotationState, 1);

        final rotation2 = rotation1.rotateClockwise();
        expect(rotation2.rotationState, 2);

        final rotation3 = rotation2.rotateClockwise();
        expect(rotation3.rotationState, 3);

        final rotation4 = rotation3.rotateClockwise();
        expect(rotation4.rotationState, 0); // Back to original
      });

      test('should rotate counter-clockwise correctly', () {
        // Arrange
        final tetromino = Tetromino.spawn('T');

        // Act
        final rotated = tetromino.rotateCounterClockwise();

        // Assert
        expect(rotated.rotationState, 3); // Last rotation state
      });

      test('should handle multiple counter-clockwise rotations', () {
        // Arrange
        final tetromino = Tetromino.spawn('T');

        // Act
        final rotation1 = tetromino.rotateCounterClockwise();
        final rotation2 = rotation1.rotateCounterClockwise();

        // Assert
        expect(rotation1.rotationState, 3);
        expect(rotation2.rotationState, 2);
      });

      test('should maintain other properties during rotation', () {
        // Arrange
        const position = Position(row: 5, column: 3);
        final tetromino = Tetromino.test(type: 'T', position: position);

        // Act
        final rotated = tetromino.rotateClockwise();

        // Assert
        expect(rotated.type, 'T');
        expect(rotated.position, position);
      });
    });

    group('position calculations', () {
      test('should get occupied positions correctly', () {
        // Arrange
        final tetromino = Tetromino.test(
          type: 'T',
          position: const Position(row: 1, column: 2),
          shape: const [
            [0, 1, 0],
            [1, 1, 1],
            [0, 0, 0],
          ],
        );

        // Act
        final positions = tetromino.getOccupiedPositions();

        // Assert
        expect(positions.length, 4);
        expect(
          positions,
          containsAll([
            const Position(row: 1, column: 3), // Top center
            const Position(row: 2, column: 2), // Bottom left
            const Position(row: 2, column: 3), // Bottom center
            const Position(row: 2, column: 4), // Bottom right
          ]),
        );
      });

      test('should get shape positions correctly', () {
        // Arrange
        final tetromino = Tetromino.test(
          type: 'T',
          shape: const [
            [0, 1, 0],
            [1, 1, 1],
            [0, 0, 0],
          ],
        );

        // Act
        final positions = tetromino.getShapePositions();

        // Assert
        expect(positions.length, 4);
        expect(
          positions,
          containsAll([
            const Position(row: 0, column: 1), // Top center
            const Position(row: 1, column: 0), // Bottom left
            const Position(row: 1, column: 1), // Bottom center
            const Position(row: 1, column: 2), // Bottom right
          ]),
        );
      });

      test('should calculate bounding box correctly', () {
        // Arrange
        final tetromino = Tetromino.test(
          type: 'T',
          shape: const [
            [0, 1, 0, 0],
            [1, 1, 1, 0],
            [0, 0, 0, 0],
            [0, 0, 0, 0],
          ],
        );

        // Act
        final bounds = tetromino.getBoundingBox();

        // Assert
        expect(bounds.minRow, 0);
        expect(bounds.maxRow, 1);
        expect(bounds.minCol, 0);
        expect(bounds.maxCol, 2);
      });
    });

    group('validation', () {
      test('should validate position within board bounds', () {
        // Arrange
        final tetromino = Tetromino.test(
          type: 'O',
          position: const Position(row: 5, column: 5),
          shape: const [
            [1, 1],
            [1, 1],
          ],
        );

        // Act
        final isValid = tetromino.isValidPosition(
          boardWidth: 10,
          boardHeight: 20,
        );

        // Assert
        expect(isValid, true);
      });

      test('should invalidate position outside board bounds', () {
        // Arrange
        final tetromino = Tetromino.test(
          type: 'O',
          position: const Position(row: 5, column: 9),
          shape: const [
            [1, 1],
            [1, 1],
          ],
        );

        // Act
        final isValid = tetromino.isValidPosition(
          boardWidth: 10,
          boardHeight: 20,
        );

        // Assert
        expect(isValid, false); // Piece extends beyond right edge
      });

      test('should invalidate position with collision', () {
        // Arrange
        final tetromino = Tetromino.test(
          type: 'O',
          position: const Position(row: 5, column: 5),
          shape: const [
            [1, 1],
            [1, 1],
          ],
        );

        final occupiedCells = List.generate(
          20,
          (i) => List.generate(10, (j) => i == 6 && j == 5),
        );

        // Act
        final isValid = tetromino.isValidPosition(
          boardWidth: 10,
          boardHeight: 20,
          occupiedCells: occupiedCells,
        );

        // Assert
        expect(isValid, false);
      });

      test('should validate position without collision', () {
        // Arrange
        final tetromino = Tetromino.test(
          type: 'O',
          position: const Position(row: 5, column: 5),
          shape: const [
            [1, 1],
            [1, 1],
          ],
        );

        final occupiedCells = List.generate(
          20,
          (i) => List.generate(10, (j) => false),
        );

        // Act
        final isValid = tetromino.isValidPosition(
          boardWidth: 10,
          boardHeight: 20,
          occupiedCells: occupiedCells,
        );

        // Assert
        expect(isValid, true);
      });
    });

    group('color', () {
      test('should return correct color for each piece type', () {
        // Test each piece type
        for (final type in ['I', 'O', 'T', 'S', 'Z', 'J', 'L']) {
          final tetromino = Tetromino.spawn(type);
          final color = tetromino.getColor();
          expect(color, isA<int>());
          expect(color, isNot(0xFF000000)); // Not empty color
        }
      });

      test('should return empty color for unknown type', () {
        // Arrange
        final tetromino = Tetromino.test(type: 'X');

        // Act
        final color = tetromino.getColor();

        // Assert
        expect(color, 0xFF000000); // Empty color
      });
    });

    group('copying', () {
      test('should copy with modified position', () {
        // Arrange
        final original = Tetromino.spawn('T');
        const newPosition = Position(row: 10, column: 5);

        // Act
        final copied = original.copyWith(position: newPosition);

        // Assert
        expect(copied.position, newPosition);
        expect(copied.type, original.type);
        expect(copied.rotationState, original.rotationState);
        expect(original.position, isNot(newPosition)); // Original unchanged
      });

      test('should copy with modified rotation state', () {
        // Arrange
        final original = Tetromino.spawn('T');

        // Act
        final copied = original.copyWith(rotationState: 2);

        // Assert
        expect(copied.rotationState, 2);
        expect(copied.type, original.type);
        expect(copied.position, original.position);
        expect(original.rotationState, 0); // Original unchanged
      });

      test('should deep copy shape', () {
        // Arrange
        final original = Tetromino.spawn('T');

        // Act
        final copied = original.copyWith();
        copied.shape[0][0] = 9; // Modify copy

        // Assert
        expect(original.shape[0][0], isNot(9)); // Original unchanged
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        // Arrange
        const position = Position(row: 5, column: 3);
        const shape = [
          [1, 1],
          [1, 1],
        ];

        final tetromino1 = Tetromino(
          type: 'O',
          position: position,
          rotationState: 0,
          shape: shape,
        );

        final tetromino2 = Tetromino(
          type: 'O',
          position: position,
          rotationState: 0,
          shape: shape,
        );

        // Assert
        expect(tetromino1, tetromino2);
        expect(tetromino1.hashCode, tetromino2.hashCode);
      });

      test('should not be equal when type differs', () {
        // Arrange
        final tetromino1 = Tetromino.spawn('I');
        final tetromino2 = Tetromino.spawn('O');

        // Assert
        expect(tetromino1, isNot(tetromino2));
      });

      test('should not be equal when position differs', () {
        // Arrange
        final tetromino1 = Tetromino.test(
          type: 'T',
          position: const Position(row: 1, column: 1),
        );
        final tetromino2 = Tetromino.test(
          type: 'T',
          position: const Position(row: 2, column: 1),
        );

        // Assert
        expect(tetromino1, isNot(tetromino2));
      });
    });

    group('string representation', () {
      test('should return readable string representation', () {
        // Arrange
        final tetromino = Tetromino.test(
          type: 'T',
          position: const Position(row: 5, column: 3),
          rotationState: 2,
        );

        // Act
        final string = tetromino.toString();

        // Assert
        expect(
          string,
          'Tetromino(type: T, position: Position(row: 5, column: 3), rotation: 2)',
        );
      });
    });
  });
}

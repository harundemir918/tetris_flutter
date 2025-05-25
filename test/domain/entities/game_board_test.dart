import 'package:flutter_test/flutter_test.dart';
import 'package:tetris_flutter/core/exceptions/game_exceptions.dart';
import 'package:tetris_flutter/domain/entities/game_board.dart';
import 'package:tetris_flutter/domain/entities/position.dart';
import 'package:tetris_flutter/domain/entities/tetromino.dart';

void main() {
  group('GameBoard', () {
    group('creation', () {
      test('should create board with given properties', () {
        // Arrange
        final cells = [
          ['I', null, 'O'],
          [null, 'T', null],
        ];

        // Act
        final board = GameBoard(cells: cells, width: 3, height: 2);

        // Assert
        expect(board.cells, cells);
        expect(board.width, 3);
        expect(board.height, 2);
      });

      test('should create empty board with standard dimensions', () {
        // Act
        final board = GameBoard.empty();

        // Assert
        expect(board.width, 10);
        expect(board.height, 20);
        expect(board.isEmpty(), true);
      });

      test('should create test board with custom dimensions', () {
        // Act
        final board = GameBoard.test(width: 5, height: 8);

        // Assert
        expect(board.width, 5);
        expect(board.height, 8);
        expect(board.isEmpty(), true);
      });

      test('should create test board with custom cells', () {
        // Arrange
        final cells = [
          ['I', 'O'],
          [null, 'T'],
        ];

        // Act
        final board = GameBoard.test(width: 2, height: 2, cells: cells);

        // Assert
        expect(board.cells, cells);
        expect(board.width, 2);
        expect(board.height, 2);
      });
    });

    group('position validation', () {
      late GameBoard board;

      setUp(() {
        board = GameBoard.test(width: 3, height: 3);
      });

      test('should validate position within bounds', () {
        // Arrange
        const position = Position(row: 1, column: 1);

        // Act
        final isValid = board.isValidPosition(position);

        // Assert
        expect(isValid, true);
      });

      test('should invalidate negative row', () {
        // Arrange
        const position = Position(row: -1, column: 1);

        // Act
        final isValid = board.isValidPosition(position);

        // Assert
        expect(isValid, false);
      });

      test('should invalidate negative column', () {
        // Arrange
        const position = Position(row: 1, column: -1);

        // Act
        final isValid = board.isValidPosition(position);

        // Assert
        expect(isValid, false);
      });

      test('should invalidate row beyond bounds', () {
        // Arrange
        const position = Position(row: 3, column: 1);

        // Act
        final isValid = board.isValidPosition(position);

        // Assert
        expect(isValid, false);
      });

      test('should invalidate column beyond bounds', () {
        // Arrange
        const position = Position(row: 1, column: 3);

        // Act
        final isValid = board.isValidPosition(position);

        // Assert
        expect(isValid, false);
      });
    });

    group('cell occupation', () {
      late GameBoard board;

      setUp(() {
        board = GameBoard.test(
          width: 3,
          height: 3,
          cells: [
            ['I', null, 'O'],
            [null, 'T', null],
            ['S', null, 'Z'],
          ],
        );
      });

      test('should detect occupied cell', () {
        // Arrange
        const position = Position(row: 0, column: 0);

        // Act
        final isOccupied = board.isCellOccupied(position);

        // Assert
        expect(isOccupied, true);
      });

      test('should detect empty cell', () {
        // Arrange
        const position = Position(row: 0, column: 1);

        // Act
        final isOccupied = board.isCellOccupied(position);

        // Assert
        expect(isOccupied, false);
      });

      test('should throw exception for invalid position', () {
        // Arrange
        const position = Position(row: 5, column: 5);

        // Act & Assert
        expect(
          () => board.isCellOccupied(position),
          throwsA(isA<InvalidBoardPositionException>()),
        );
      });

      test('should get piece type at position', () {
        // Arrange
        const position = Position(row: 0, column: 0);

        // Act
        final pieceType = board.getPieceTypeAt(position);

        // Assert
        expect(pieceType, 'I');
      });

      test('should return null for empty cell', () {
        // Arrange
        const position = Position(row: 0, column: 1);

        // Act
        final pieceType = board.getPieceTypeAt(position);

        // Assert
        expect(pieceType, null);
      });
    });

    group('tetromino placement', () {
      late GameBoard board;

      setUp(() {
        board = GameBoard.test(width: 5, height: 5);
      });

      test('should allow placing tetromino in empty space', () {
        // Arrange
        final tetromino = Tetromino.test(
          type: 'O',
          position: const Position(row: 1, column: 1),
          shape: const [
            [1, 1],
            [1, 1],
          ],
        );

        // Act
        final canPlace = board.canPlaceTetromino(tetromino);

        // Assert
        expect(canPlace, true);
      });

      test('should prevent placing tetromino outside bounds', () {
        // Arrange
        final tetromino = Tetromino.test(
          type: 'O',
          position: const Position(row: 4, column: 4),
          shape: const [
            [1, 1],
            [1, 1],
          ],
        );

        // Act
        final canPlace = board.canPlaceTetromino(tetromino);

        // Assert
        expect(canPlace, false);
      });

      test('should prevent placing tetromino on occupied cells', () {
        // Arrange
        final boardWithPieces = GameBoard.test(
          width: 5,
          height: 5,
          cells: [
            [null, null, null, null, null],
            [null, 'I', 'I', null, null],
            [null, null, null, null, null],
            [null, null, null, null, null],
            [null, null, null, null, null],
          ],
        );

        final tetromino = Tetromino.test(
          type: 'O',
          position: const Position(row: 0, column: 1),
          shape: const [
            [1, 1],
            [1, 1],
          ],
        );

        // Act
        final canPlace = boardWithPieces.canPlaceTetromino(tetromino);

        // Assert
        expect(canPlace, false);
      });

      test('should place tetromino successfully', () {
        // Arrange
        final tetromino = Tetromino.test(
          type: 'O',
          position: const Position(row: 1, column: 1),
          shape: const [
            [1, 1],
            [1, 1],
          ],
        );

        // Act
        final newBoard = board.placeTetromino(tetromino);

        // Assert
        expect(newBoard.getPieceTypeAt(const Position(row: 1, column: 1)), 'O');
        expect(newBoard.getPieceTypeAt(const Position(row: 1, column: 2)), 'O');
        expect(newBoard.getPieceTypeAt(const Position(row: 2, column: 1)), 'O');
        expect(newBoard.getPieceTypeAt(const Position(row: 2, column: 2)), 'O');
        expect(board.isEmpty(), true); // Original unchanged
      });

      test('should throw exception when placing invalid tetromino', () {
        // Arrange
        final tetromino = Tetromino.test(
          type: 'O',
          position: const Position(row: 4, column: 4),
          shape: const [
            [1, 1],
            [1, 1],
          ],
        );

        // Act & Assert
        expect(
          () => board.placeTetromino(tetromino),
          throwsA(isA<InvalidMoveException>()),
        );
      });
    });

    group('line completion', () {
      test('should detect complete row', () {
        // Arrange
        final board = GameBoard.test(
          width: 3,
          height: 3,
          cells: [
            ['I', 'O', 'T'],
            [null, 'S', null],
            ['Z', 'J', 'L'],
          ],
        );

        // Act
        final isComplete0 = board.isRowComplete(0);
        final isComplete1 = board.isRowComplete(1);
        final isComplete2 = board.isRowComplete(2);

        // Assert
        expect(isComplete0, true);
        expect(isComplete1, false);
        expect(isComplete2, true);
      });

      test('should throw exception for invalid row', () {
        // Arrange
        final board = GameBoard.test(width: 3, height: 3);

        // Act & Assert
        expect(
          () => board.isRowComplete(-1),
          throwsA(isA<InvalidBoardPositionException>()),
        );
        expect(
          () => board.isRowComplete(3),
          throwsA(isA<InvalidBoardPositionException>()),
        );
      });

      test('should get all complete rows', () {
        // Arrange
        final board = GameBoard.test(
          width: 3,
          height: 4,
          cells: [
            ['I', 'O', 'T'],
            [null, 'S', null],
            ['Z', 'J', 'L'],
            ['I', 'I', 'I'],
          ],
        );

        // Act
        final completeRows = board.getCompleteRows();

        // Assert
        expect(completeRows, [0, 2, 3]);
      });

      test('should clear complete lines', () {
        // Arrange
        final board = GameBoard.test(
          width: 3,
          height: 4,
          cells: [
            ['I', 'O', 'T'], // Complete
            [null, 'S', null],
            ['Z', 'J', 'L'], // Complete
            [null, null, 'I'],
          ],
        );

        // Act
        final result = board.clearCompleteLines();

        // Assert
        expect(result.linesCleared, 2);
        expect(result.board.cells, [
          [null, null, null], // New empty row
          [null, null, null], // New empty row
          [null, 'S', null], // Moved down
          [null, null, 'I'], // Moved down
        ]);
      });

      test('should return same board when no lines to clear', () {
        // Arrange
        final board = GameBoard.test(
          width: 3,
          height: 3,
          cells: [
            ['I', null, 'T'],
            [null, 'S', null],
            ['Z', null, 'L'],
          ],
        );

        // Act
        final result = board.clearCompleteLines();

        // Assert
        expect(result.linesCleared, 0);
        expect(result.board, board);
      });
    });

    group('board analysis', () {
      test('should get highest occupied row', () {
        // Arrange
        final board = GameBoard.test(
          width: 3,
          height: 5,
          cells: [
            [null, null, null],
            [null, null, null],
            ['I', null, null],
            [null, 'O', null],
            [null, null, 'T'],
          ],
        );

        // Act
        final highestRow = board.getHighestOccupiedRow();

        // Assert
        expect(highestRow, 2);
      });

      test('should return height for empty board', () {
        // Arrange
        final board = GameBoard.empty();

        // Act
        final highestRow = board.getHighestOccupiedRow();

        // Assert
        expect(highestRow, 20);
      });

      test('should count occupied cells', () {
        // Arrange
        final board = GameBoard.test(
          width: 3,
          height: 3,
          cells: [
            ['I', null, 'O'],
            [null, 'T', null],
            ['S', null, null],
          ],
        );

        // Act
        final count = board.getOccupiedCellCount();

        // Assert
        expect(count, 4);
      });

      test('should get all occupied positions', () {
        // Arrange
        final board = GameBoard.test(
          width: 3,
          height: 3,
          cells: [
            ['I', null, 'O'],
            [null, 'T', null],
            ['S', null, null],
          ],
        );

        // Act
        final positions = board.getOccupiedPositions();

        // Assert
        expect(positions.length, 4);
        expect(
          positions,
          containsAll([
            const Position(row: 0, column: 0),
            const Position(row: 0, column: 2),
            const Position(row: 1, column: 1),
            const Position(row: 2, column: 0),
          ]),
        );
      });

      test('should detect empty board', () {
        // Arrange
        final emptyBoard = GameBoard.empty();
        final nonEmptyBoard = GameBoard.test(
          width: 2,
          height: 2,
          cells: [
            [null, null],
            ['I', null],
          ],
        );

        // Act & Assert
        expect(emptyBoard.isEmpty(), true);
        expect(nonEmptyBoard.isEmpty(), false);
      });
    });

    group('game over detection', () {
      test('should detect game over when spawn area is occupied', () {
        // Arrange
        final board = GameBoard.test(
          width: 10,
          height: 20,
          cells: List.generate(
            20,
            (row) =>
                List.generate(10, (col) => row == 0 && col == 4 ? 'I' : null),
          ),
        );

        // Act
        final isGameOver = board.isGameOver();

        // Assert
        expect(isGameOver, true);
      });

      test('should not detect game over when spawn area is clear', () {
        // Arrange
        final board = GameBoard.test(
          width: 10,
          height: 20,
          cells: List.generate(
            20,
            (row) =>
                List.generate(10, (col) => row == 19 && col == 4 ? 'I' : null),
          ),
        );

        // Act
        final isGameOver = board.isGameOver();

        // Assert
        expect(isGameOver, false);
      });
    });

    group('copying', () {
      test('should copy with modified cells', () {
        // Arrange
        final original = GameBoard.test(width: 2, height: 2);
        final newCells = [
          ['I', 'O'],
          ['T', 'S'],
        ];

        // Act
        final copied = original.copyWith(cells: newCells);

        // Assert
        expect(copied.cells, newCells);
        expect(copied.width, original.width);
        expect(copied.height, original.height);
        expect(original.isEmpty(), true); // Original unchanged
      });

      test('should copy with modified dimensions', () {
        // Arrange
        final original = GameBoard.test(width: 2, height: 2);

        // Act
        final copied = original.copyWith(width: 5, height: 8);

        // Assert
        expect(copied.width, 5);
        expect(copied.height, 8);
        expect(copied.cells, isNot(original.cells)); // Deep copied
      });

      test('should deep copy cells when no modifications', () {
        // Arrange
        final original = GameBoard.test(
          width: 2,
          height: 2,
          cells: [
            ['I', null],
            [null, 'O'],
          ],
        );

        // Act
        final copied = original.copyWith();
        copied.cells[0][0] = 'T'; // Modify copy

        // Assert
        expect(original.cells[0][0], 'I'); // Original unchanged
        expect(copied.cells[0][0], 'T'); // Copy modified
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        // Arrange
        final cells = [
          ['I', 'O'],
          ['T', 'S'],
        ];

        final board1 = GameBoard(cells: cells, width: 2, height: 2);
        final board2 = GameBoard(cells: cells, width: 2, height: 2);

        // Assert
        expect(board1, board2);
        expect(board1.hashCode, board2.hashCode);
      });

      test('should not be equal when cells differ', () {
        // Arrange
        final board1 = GameBoard.test(
          width: 2,
          height: 2,
          cells: [
            ['I', 'O'],
            ['T', 'S'],
          ],
        );
        final board2 = GameBoard.test(
          width: 2,
          height: 2,
          cells: [
            ['I', 'O'],
            ['T', 'Z'],
          ],
        );

        // Assert
        expect(board1, isNot(board2));
      });

      test('should not be equal when dimensions differ', () {
        // Arrange
        final board1 = GameBoard.test(width: 2, height: 2);
        final board2 = GameBoard.test(width: 3, height: 2);

        // Assert
        expect(board1, isNot(board2));
      });
    });

    group('string representation', () {
      test('should return readable string representation', () {
        // Arrange
        final board = GameBoard.test(width: 5, height: 3);

        // Act
        final string = board.toString();

        // Assert
        expect(string, 'GameBoard(5x3, occupied: 0)');
      });

      test('should return debug string representation', () {
        // Arrange
        final board = GameBoard.test(
          width: 3,
          height: 2,
          cells: [
            ['I', null, 'O'],
            [null, 'T', null],
          ],
        );

        // Act
        final debugString = board.toDebugString();

        // Assert
        expect(debugString, contains('GameBoard 3x2:'));
        expect(debugString, contains('|I.O|'));
        expect(debugString, contains('|.T.|'));
      });
    });
  });
}

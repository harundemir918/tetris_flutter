import 'package:flutter_test/flutter_test.dart';
import 'package:tetris_flutter/domain/entities/game_board.dart';
import 'package:tetris_flutter/domain/entities/game_state.dart';
import 'package:tetris_flutter/domain/entities/position.dart';
import 'package:tetris_flutter/domain/entities/score.dart';
import 'package:tetris_flutter/domain/entities/tetromino.dart';

void main() {
  group('GameState', () {
    group('creation', () {
      test('should create game state with given properties', () {
        // Arrange
        final board = GameBoard.empty();
        final currentPiece = Tetromino.spawn('I');
        final score = const Score.initial();

        // Act
        final gameState = GameState(
          board: board,
          currentPiece: currentPiece,
          score: score,
          status: GameStatus.playing,
        );

        // Assert
        expect(gameState.board, board);
        expect(gameState.currentPiece, currentPiece);
        expect(gameState.score, score);
        expect(gameState.status, GameStatus.playing);
      });

      test('should create initial game state', () {
        // Act
        final gameState = GameState.initial();

        // Assert
        expect(gameState.board.isEmpty(), true);
        expect(gameState.currentPiece, isNotNull);
        expect(gameState.nextPiece, isNotNull);
        expect(gameState.heldPiece, null);
        expect(gameState.score, const Score.initial());
        expect(gameState.status, GameStatus.ready);
        expect(gameState.canHold, true);
        expect(gameState.pieceBag.length, 5); // 7 - 2 pieces already used
      });

      test('should create test game state with defaults', () {
        // Act
        final gameState = GameState.test();

        // Assert
        expect(gameState.board.isEmpty(), true);
        expect(gameState.currentPiece, null);
        expect(gameState.nextPiece, null);
        expect(gameState.score, const Score.initial());
        expect(gameState.status, GameStatus.ready);
      });

      test('should create test game state with custom values', () {
        // Arrange
        final board = GameBoard.test(width: 5, height: 5);
        final currentPiece = Tetromino.spawn('T');
        final score = const Score.test(points: 1000);

        // Act
        final gameState = GameState.test(
          board: board,
          currentPiece: currentPiece,
          score: score,
          status: GameStatus.playing,
        );

        // Assert
        expect(gameState.board, board);
        expect(gameState.currentPiece, currentPiece);
        expect(gameState.score, score);
        expect(gameState.status, GameStatus.playing);
      });
    });

    group('game status management', () {
      test('should start game from ready state', () {
        // Arrange
        final gameState = GameState.test(status: GameStatus.ready);

        // Act
        final startedState = gameState.startGame();

        // Assert
        expect(startedState.status, GameStatus.playing);
        expect(startedState.startTime, isNotNull);
        expect(gameState.status, GameStatus.ready); // Original unchanged
      });

      test('should not start game from non-ready state', () {
        // Arrange
        final gameState = GameState.test(status: GameStatus.playing);

        // Act
        final result = gameState.startGame();

        // Assert
        expect(result, gameState);
      });

      test('should pause game from playing state', () {
        // Arrange
        final gameState = GameState.test(status: GameStatus.playing);

        // Act
        final pausedState = gameState.pauseGame();

        // Assert
        expect(pausedState.status, GameStatus.paused);
      });

      test('should not pause game from non-playing state', () {
        // Arrange
        final gameState = GameState.test(status: GameStatus.ready);

        // Act
        final result = gameState.pauseGame();

        // Assert
        expect(result, gameState);
      });

      test('should resume game from paused state', () {
        // Arrange
        final gameState = GameState.test(status: GameStatus.paused);

        // Act
        final resumedState = gameState.resumeGame();

        // Assert
        expect(resumedState.status, GameStatus.playing);
      });

      test('should not resume game from non-paused state', () {
        // Arrange
        final gameState = GameState.test(status: GameStatus.playing);

        // Act
        final result = gameState.resumeGame();

        // Assert
        expect(result, gameState);
      });

      test('should end game', () {
        // Arrange
        final gameState = GameState.test(status: GameStatus.playing);

        // Act
        final endedState = gameState.endGame();

        // Assert
        expect(endedState.status, GameStatus.gameOver);
        expect(endedState.endTime, isNotNull);
      });

      test('should not end already ended game', () {
        // Arrange
        final gameState = GameState.test(status: GameStatus.gameOver);

        // Act
        final result = gameState.endGame();

        // Assert
        expect(result, gameState);
      });

      test('should reset game to initial state', () {
        // Arrange
        final gameState = GameState.test(
          status: GameStatus.gameOver,
          score: const Score.test(points: 1000),
        );

        // Act
        final resetState = gameState.resetGame();

        // Assert
        expect(resetState.status, GameStatus.ready);
        expect(resetState.score, const Score.initial());
        expect(resetState.currentPiece, isNotNull);
        expect(resetState.nextPiece, isNotNull);
      });
    });

    group('status getters', () {
      test('should correctly identify game states', () {
        // Arrange & Act & Assert
        expect(GameState.test(status: GameStatus.ready).isReady, true);
        expect(GameState.test(status: GameStatus.playing).isPlaying, true);
        expect(GameState.test(status: GameStatus.paused).isPaused, true);
        expect(GameState.test(status: GameStatus.gameOver).isGameOver, true);

        expect(GameState.test(status: GameStatus.playing).isActive, true);
        expect(GameState.test(status: GameStatus.paused).isActive, true);
        expect(GameState.test(status: GameStatus.ready).isActive, false);
        expect(GameState.test(status: GameStatus.gameOver).isActive, false);
      });
    });

    group('piece movement', () {
      late GameState playingState;

      setUp(() {
        playingState = GameState.test(
          status: GameStatus.playing,
          currentPiece: Tetromino.test(
            type: 'O',
            position: const Position(row: 5, column: 5),
            shape: const [
              [1, 1],
              [1, 1],
            ],
          ),
          board: GameBoard.test(width: 10, height: 10),
        );
      });

      test('should move piece left when valid', () {
        // Act
        final movedState = playingState.moveCurrentPieceLeft();

        // Assert
        expect(movedState.currentPiece!.position.column, 4);
        expect(
          playingState.currentPiece!.position.column,
          5,
        ); // Original unchanged
      });

      test('should not move piece left when invalid', () {
        // Arrange
        final stateAtEdge = playingState.copyWith(
          currentPiece: playingState.currentPiece!.moveTo(
            const Position(row: 5, column: 0),
          ),
        );

        // Act
        final result = stateAtEdge.moveCurrentPieceLeft();

        // Assert
        expect(result, stateAtEdge);
      });

      test('should move piece right when valid', () {
        // Act
        final movedState = playingState.moveCurrentPieceRight();

        // Assert
        expect(movedState.currentPiece!.position.column, 6);
      });

      test('should not move piece right when invalid', () {
        // Arrange
        final stateAtEdge = playingState.copyWith(
          currentPiece: playingState.currentPiece!.moveTo(
            const Position(row: 5, column: 8),
          ),
        );

        // Act
        final result = stateAtEdge.moveCurrentPieceRight();

        // Assert
        expect(result, stateAtEdge);
      });

      test('should move piece down when valid', () {
        // Act
        final movedState = playingState.moveCurrentPieceDown();

        // Assert
        expect(movedState.currentPiece!.position.row, 6);
      });

      test('should not move piece down when invalid', () {
        // Arrange
        final stateAtBottom = playingState.copyWith(
          currentPiece: playingState.currentPiece!.moveTo(
            const Position(row: 8, column: 5),
          ),
        );

        // Act
        final result = stateAtBottom.moveCurrentPieceDown();

        // Assert
        expect(result, stateAtBottom);
      });

      test('should not move piece when not playing', () {
        // Arrange
        final pausedState = playingState.copyWith(status: GameStatus.paused);

        // Act
        final leftResult = pausedState.moveCurrentPieceLeft();
        final rightResult = pausedState.moveCurrentPieceRight();
        final downResult = pausedState.moveCurrentPieceDown();

        // Assert
        expect(leftResult, pausedState);
        expect(rightResult, pausedState);
        expect(downResult, pausedState);
      });

      test('should not move piece when no current piece', () {
        // Arrange
        final noPieceState = GameState.test(
          status: GameStatus.playing,
          currentPiece: null,
          board: GameBoard.test(width: 10, height: 10),
        );

        // Act
        final leftResult = noPieceState.moveCurrentPieceLeft();
        final rightResult = noPieceState.moveCurrentPieceRight();
        final downResult = noPieceState.moveCurrentPieceDown();

        // Assert
        expect(leftResult, noPieceState);
        expect(rightResult, noPieceState);
        expect(downResult, noPieceState);
      });
    });

    group('piece rotation', () {
      late GameState playingState;

      setUp(() {
        playingState = GameState.test(
          status: GameStatus.playing,
          currentPiece: Tetromino.spawn('T'),
          board: GameBoard.test(width: 10, height: 10),
        );
      });

      test('should rotate piece clockwise when valid', () {
        // Arrange
        final originalRotation = playingState.currentPiece!.rotationState;

        // Act
        final rotatedState = playingState.rotateCurrentPieceClockwise();

        // Assert
        expect(
          rotatedState.currentPiece!.rotationState,
          (originalRotation + 1) % 4,
        );
      });

      test('should rotate piece counter-clockwise when valid', () {
        // Arrange
        final originalRotation = playingState.currentPiece!.rotationState;

        // Act
        final rotatedState = playingState.rotateCurrentPieceCounterClockwise();

        // Assert
        final expectedRotation = originalRotation == 0
            ? 3
            : originalRotation - 1;
        expect(rotatedState.currentPiece!.rotationState, expectedRotation);
      });

      test('should not rotate piece when invalid position', () {
        // Arrange - Create a state where rotation would cause collision
        final boardWithObstacles = GameBoard.test(
          width: 10,
          height: 10,
          cells: List.generate(
            10,
            (row) => List.generate(
              10,
              (col) => row == 2 && col >= 2 && col <= 5 ? 'I' : null,
            ),
          ),
        );

        final constrainedState = playingState.copyWith(
          board: boardWithObstacles,
          currentPiece: Tetromino.test(
            type: 'I',
            position: const Position(row: 1, column: 3),
            shape: const [
              [0, 0, 0, 0],
              [1, 1, 1, 1],
              [0, 0, 0, 0],
              [0, 0, 0, 0],
            ],
          ),
        );

        // Act
        final result = constrainedState.rotateCurrentPieceClockwise();

        // Assert
        expect(result, constrainedState);
      });

      test('should not rotate piece when not playing', () {
        // Arrange
        final pausedState = playingState.copyWith(status: GameStatus.paused);

        // Act
        final clockwiseResult = pausedState.rotateCurrentPieceClockwise();
        final counterClockwiseResult = pausedState
            .rotateCurrentPieceCounterClockwise();

        // Assert
        expect(clockwiseResult, pausedState);
        expect(counterClockwiseResult, pausedState);
      });
    });

    group('hard drop', () {
      test('should hard drop piece to bottom', () {
        // Arrange
        final gameState = GameState.test(
          status: GameStatus.playing,
          currentPiece: Tetromino.test(
            type: 'O',
            position: const Position(row: 2, column: 4),
            shape: const [
              [1, 1],
              [1, 1],
            ],
          ),
          board: GameBoard.test(width: 10, height: 10),
          nextPiece: Tetromino.spawn('I'),
          pieceBag: const ['T', 'S', 'Z'],
        );

        // Act
        final droppedState = gameState.hardDropCurrentPiece();

        // Assert
        expect(droppedState.currentPiece!.type, 'I'); // Next piece spawned
        expect(
          droppedState.board.getPieceTypeAt(const Position(row: 8, column: 4)),
          'O',
        );
        expect(
          droppedState.board.getPieceTypeAt(const Position(row: 8, column: 5)),
          'O',
        );
        expect(
          droppedState.board.getPieceTypeAt(const Position(row: 9, column: 4)),
          'O',
        );
        expect(
          droppedState.board.getPieceTypeAt(const Position(row: 9, column: 5)),
          'O',
        );
        expect(
          droppedState.score.points,
          greaterThan(0),
        ); // Hard drop bonus added
      });

      test('should not hard drop when not playing', () {
        // Arrange
        final gameState = GameState.test(
          status: GameStatus.paused,
          currentPiece: Tetromino.spawn('O'),
        );

        // Act
        final result = gameState.hardDropCurrentPiece();

        // Assert
        expect(result, gameState);
      });
    });

    group('piece placement', () {
      test('should place piece and spawn next', () {
        // Arrange
        final gameState = GameState.test(
          status: GameStatus.playing,
          currentPiece: Tetromino.test(
            type: 'O',
            position: const Position(row: 8, column: 4),
            shape: const [
              [1, 1],
              [1, 1],
            ],
          ),
          board: GameBoard.test(width: 10, height: 10),
          nextPiece: Tetromino.spawn('I'),
          pieceBag: const ['T', 'S', 'Z'],
        );

        // Act
        final placedState = gameState.placeCurrentPiece();

        // Assert
        expect(placedState.currentPiece!.type, 'I'); // Next piece spawned
        expect(
          placedState.board.getPieceTypeAt(const Position(row: 8, column: 4)),
          'O',
        );
        expect(placedState.canHold, true); // Can hold again after placing
      });

      test('should clear lines when placing piece', () {
        // Arrange - Create board with almost complete line
        final boardWithAlmostCompleteLine = GameBoard.test(
          width: 4,
          height: 4,
          cells: [
            [null, null, null, null],
            [null, null, null, null],
            [null, null, null, null],
            ['I', 'I', null, 'I'], // Missing one piece for complete line
          ],
        );

        final gameState = GameState.test(
          status: GameStatus.playing,
          currentPiece: Tetromino.test(
            type: 'I',
            position: const Position(row: 3, column: 2),
            shape: const [
              [1],
            ],
          ),
          board: boardWithAlmostCompleteLine,
          nextPiece: Tetromino.spawn('I'),
          pieceBag: const ['T'],
        );

        // Act
        final placedState = gameState.placeCurrentPiece();

        // Assert
        expect(placedState.score.totalLinesCleared, 1);
        expect(placedState.score.points, greaterThan(0));
        expect(
          placedState.board.getPieceTypeAt(const Position(row: 3, column: 2)),
          null,
        ); // Line cleared
      });

      test('should end game when board is full', () {
        // Arrange - Create board that will cause game over
        final fullBoard = GameBoard.test(
          width: 10,
          height: 20,
          cells: List.generate(
            20,
            (row) => List.generate(
              10,
              (col) => row == 0 && col == 4 ? 'I' : null, // Spawn area occupied
            ),
          ),
        );

        final gameState = GameState.test(
          status: GameStatus.playing,
          currentPiece: Tetromino.test(
            type: 'O',
            position: const Position(row: 18, column: 0),
            shape: const [
              [1, 1],
              [1, 1],
            ],
          ),
          board: fullBoard,
          nextPiece: Tetromino.spawn('I'),
        );

        // Act
        final placedState = gameState.placeCurrentPiece();

        // Assert
        expect(placedState.status, GameStatus.gameOver);
        expect(placedState.currentPiece, null);
      });
    });

    group('hold functionality', () {
      test('should hold piece for first time', () {
        // Arrange
        final gameState = GameState.test(
          status: GameStatus.playing,
          currentPiece: Tetromino.spawn('T'),
          nextPiece: Tetromino.spawn('I'),
          pieceBag: const ['O', 'S'],
          canHold: true,
        );

        // Act
        final heldState = gameState.holdCurrentPiece();

        // Assert
        expect(heldState.heldPiece!.type, 'T');
        expect(heldState.currentPiece!.type, 'I'); // Next piece becomes current
        expect(heldState.nextPiece!.type, 'O'); // First from bag becomes next
        expect(heldState.canHold, false);
        expect(heldState.pieceBag, ['S']); // Bag reduced by one
      });

      test('should swap held piece with current', () {
        // Arrange
        final gameState = GameState.test(
          status: GameStatus.playing,
          currentPiece: Tetromino.spawn('T'),
          heldPiece: Tetromino.spawn('I'),
          canHold: true,
        );

        // Act
        final swappedState = gameState.holdCurrentPiece();

        // Assert
        expect(swappedState.heldPiece!.type, 'T');
        expect(swappedState.currentPiece!.type, 'I');
        expect(swappedState.canHold, false);
      });

      test('should not hold when cannot hold', () {
        // Arrange
        final gameState = GameState.test(
          status: GameStatus.playing,
          currentPiece: Tetromino.spawn('T'),
          canHold: false,
        );

        // Act
        final result = gameState.holdCurrentPiece();

        // Assert
        expect(result, gameState);
      });

      test('should not hold when not playing', () {
        // Arrange
        final gameState = GameState.test(
          status: GameStatus.paused,
          currentPiece: Tetromino.spawn('T'),
          canHold: true,
        );

        // Act
        final result = gameState.holdCurrentPiece();

        // Assert
        expect(result, gameState);
      });
    });

    group('ghost piece', () {
      test('should calculate ghost piece position', () {
        // Arrange
        final gameState = GameState.test(
          currentPiece: Tetromino.test(
            type: 'O',
            position: const Position(row: 2, column: 4),
            shape: const [
              [1, 1],
              [1, 1],
            ],
          ),
          board: GameBoard.test(width: 10, height: 10),
        );

        // Act
        final ghostPiece = gameState.getGhostPiece();

        // Assert
        expect(ghostPiece, isNotNull);
        expect(ghostPiece!.position.row, 8); // Should be at bottom
        expect(ghostPiece.position.column, 4); // Same column
        expect(ghostPiece.type, 'O'); // Same type
      });

      test('should return null when no current piece', () {
        // Arrange
        final gameState = GameState.test(currentPiece: null);

        // Act
        final ghostPiece = gameState.getGhostPiece();

        // Assert
        expect(ghostPiece, null);
      });
    });

    group('game duration', () {
      test('should calculate game duration', () {
        // Arrange
        final startTime = DateTime(2023, 1, 1, 12, 0, 0);
        final endTime = DateTime(2023, 1, 1, 12, 5, 30);

        final gameState = GameState.test(
          startTime: startTime,
          endTime: endTime,
        );

        // Act
        final duration = gameState.getGameDuration();

        // Assert
        expect(duration, const Duration(minutes: 5, seconds: 30));
      });

      test('should calculate duration to current time when no end time', () {
        // Arrange
        final startTime = DateTime.now().subtract(const Duration(minutes: 2));
        final gameState = GameState.test(startTime: startTime);

        // Act
        final duration = gameState.getGameDuration();

        // Assert
        expect(
          duration.inMinutes,
          greaterThanOrEqualTo(1),
        ); // At least 1 minute
        expect(duration.inMinutes, lessThanOrEqualTo(3)); // At most 3 minutes
      });

      test('should return zero duration when no start time', () {
        // Arrange
        final gameState = GameState.test();

        // Act
        final duration = gameState.getGameDuration();

        // Assert
        expect(duration, Duration.zero);
      });
    });

    group('copying', () {
      test('should copy with modified properties', () {
        // Arrange
        final original = GameState.test(status: GameStatus.ready);
        final newBoard = GameBoard.test(width: 5, height: 5);

        // Act
        final copied = original.copyWith(
          board: newBoard,
          status: GameStatus.playing,
        );

        // Assert
        expect(copied.board, newBoard);
        expect(copied.status, GameStatus.playing);
        expect(original.status, GameStatus.ready); // Original unchanged
      });

      test('should copy without modifications', () {
        // Arrange
        final original = GameState.test(status: GameStatus.playing);

        // Act
        final copied = original.copyWith();

        // Assert
        expect(copied, original);
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        // Arrange
        final board = GameBoard.empty();
        final score = const Score.initial();

        final state1 = GameState(
          board: board,
          score: score,
          status: GameStatus.ready,
        );

        final state2 = GameState(
          board: board,
          score: score,
          status: GameStatus.ready,
        );

        // Assert
        expect(state1, state2);
        expect(state1.hashCode, state2.hashCode);
      });

      test('should not be equal when properties differ', () {
        // Arrange
        final state1 = GameState.test(status: GameStatus.ready);
        final state2 = GameState.test(status: GameStatus.playing);

        // Assert
        expect(state1, isNot(state2));
      });
    });

    group('string representation', () {
      test('should return readable string representation', () {
        // Arrange
        final gameState = GameState.test(
          status: GameStatus.playing,
          score: const Score.test(points: 1500, level: 3),
        );

        // Act
        final string = gameState.toString();

        // Assert
        expect(
          string,
          'GameState(status: GameStatus.playing, score: 1500, level: 3)',
        );
      });
    });
  });

  group('GameStatus', () {
    test('should have all expected values', () {
      // Assert
      expect(GameStatus.values, [
        GameStatus.ready,
        GameStatus.playing,
        GameStatus.paused,
        GameStatus.gameOver,
      ]);
    });
  });
}

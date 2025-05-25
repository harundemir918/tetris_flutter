import 'package:flutter/material.dart';

import '../../core/constants/game_constants.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/tetromino.dart';

/// Widget that displays the Tetris game board
class GameBoardWidget extends StatelessWidget {
  final GameState gameState;

  const GameBoardWidget({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: AspectRatio(
        aspectRatio: GameConstants.boardWidth / GameConstants.boardHeight,
        child: Container(
          color: Colors.black,
          child: CustomPaint(
            painter: GameBoardPainter(gameState),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

/// Custom painter for the game board
class GameBoardPainter extends CustomPainter {
  final GameState gameState;

  GameBoardPainter(this.gameState);

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / GameConstants.boardWidth;
    final cellHeight = size.height / GameConstants.boardHeight;

    // Draw grid lines
    _drawGrid(canvas, size, cellWidth, cellHeight);

    // Draw placed pieces on the board
    _drawBoard(canvas, cellWidth, cellHeight);

    // Draw current piece
    if (gameState.currentPiece != null) {
      _drawTetromino(canvas, gameState.currentPiece!, cellWidth, cellHeight);
    }
  }

  void _drawGrid(
    Canvas canvas,
    Size size,
    double cellWidth,
    double cellHeight,
  ) {
    final paint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 0.5;

    // Draw vertical lines
    for (int i = 0; i <= GameConstants.boardWidth; i++) {
      final x = i * cellWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (int i = 0; i <= GameConstants.boardHeight; i++) {
      final y = i * cellHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawBoard(Canvas canvas, double cellWidth, double cellHeight) {
    final board = gameState.board;

    for (int row = 0; row < GameConstants.boardHeight; row++) {
      for (int col = 0; col < GameConstants.boardWidth; col++) {
        final cell = board.cells[row][col];
        if (cell != null) {
          final colorValue = GameConstants.pieceColors[cell];
          final color = colorValue != null ? Color(colorValue) : Colors.grey;
          _drawCell(canvas, col, row, color, cellWidth, cellHeight);
        }
      }
    }
  }

  void _drawTetromino(
    Canvas canvas,
    Tetromino tetromino,
    double cellWidth,
    double cellHeight,
  ) {
    final shape = tetromino.shape;
    final position = tetromino.position;
    final colorValue = tetromino.getColor();

    for (int row = 0; row < shape.length; row++) {
      for (int col = 0; col < shape[row].length; col++) {
        if (shape[row][col] == 1) {
          final boardCol = position.column + col;
          final boardRow = position.row + row;

          // Only draw if within board bounds
          if (boardCol >= 0 &&
              boardCol < GameConstants.boardWidth &&
              boardRow >= 0 &&
              boardRow < GameConstants.boardHeight) {
            _drawCell(
              canvas,
              boardCol,
              boardRow,
              Color(colorValue),
              cellWidth,
              cellHeight,
            );
          }
        }
      }
    }
  }

  void _drawCell(
    Canvas canvas,
    int col,
    int row,
    Color color,
    double cellWidth,
    double cellHeight,
  ) {
    final rect = Rect.fromLTWH(
      col * cellWidth,
      row * cellHeight,
      cellWidth,
      cellHeight,
    );

    // Fill the cell
    final fillPaint = Paint()..color = color;
    canvas.drawRect(rect, fillPaint);

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.white30
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(rect, borderPaint);
  }

  @override
  bool shouldRepaint(GameBoardPainter oldDelegate) {
    return oldDelegate.gameState != gameState;
  }
}

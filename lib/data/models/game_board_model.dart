import '../../domain/entities/game_board.dart';

/// Data model for GameBoard that can be serialized to/from JSON
class GameBoardModel {
  final List<List<String?>> cells;
  final int width;
  final int height;

  const GameBoardModel({
    required this.cells,
    required this.width,
    required this.height,
  });

  /// Creates a GameBoardModel from a domain GameBoard entity
  factory GameBoardModel.fromEntity(GameBoard gameBoard) {
    return GameBoardModel(
      cells: gameBoard.cells.map((row) => List<String?>.from(row)).toList(),
      width: gameBoard.width,
      height: gameBoard.height,
    );
  }

  /// Creates a GameBoardModel from JSON
  factory GameBoardModel.fromJson(Map<String, dynamic> json) {
    return GameBoardModel(
      cells: (json['cells'] as List)
          .map((row) => List<String?>.from(row as List))
          .toList(),
      width: json['width'] as int,
      height: json['height'] as int,
    );
  }

  /// Converts this model to JSON
  Map<String, dynamic> toJson() {
    return {'cells': cells, 'width': width, 'height': height};
  }

  /// Converts this model to a domain GameBoard entity
  GameBoard toEntity() {
    return GameBoard(
      cells: cells.map((row) => List<String?>.from(row)).toList(),
      width: width,
      height: height,
    );
  }

  @override
  String toString() {
    return 'GameBoardModel(${width}x$height)';
  }
}

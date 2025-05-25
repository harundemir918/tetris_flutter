import '../../domain/entities/position.dart';
import '../../domain/entities/tetromino.dart';

/// Data model for Tetromino that can be serialized to/from JSON
class TetrominoModel {
  final String type;
  final Map<String, int> position; // {row: int, column: int}
  final int rotationState;
  final List<List<int>> shape;

  const TetrominoModel({
    required this.type,
    required this.position,
    required this.rotationState,
    required this.shape,
  });

  /// Creates a TetrominoModel from a domain Tetromino entity
  factory TetrominoModel.fromEntity(Tetromino tetromino) {
    return TetrominoModel(
      type: tetromino.type,
      position: {
        'row': tetromino.position.row,
        'column': tetromino.position.column,
      },
      rotationState: tetromino.rotationState,
      shape: tetromino.shape.map((row) => List<int>.from(row)).toList(),
    );
  }

  /// Creates a TetrominoModel from JSON
  factory TetrominoModel.fromJson(Map<String, dynamic> json) {
    return TetrominoModel(
      type: json['type'] as String,
      position: Map<String, int>.from(json['position'] as Map),
      rotationState: json['rotationState'] as int,
      shape: (json['shape'] as List)
          .map((row) => List<int>.from(row as List))
          .toList(),
    );
  }

  /// Converts this model to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'position': position,
      'rotationState': rotationState,
      'shape': shape,
    };
  }

  /// Converts this model to a domain Tetromino entity
  Tetromino toEntity() {
    return Tetromino.test(
      type: type,
      position: Position(
        row: position['row']!,
        column: position['column']!,
      ),
      rotationState: rotationState,
      shape: shape,
    );
  }

  @override
  String toString() {
    return 'TetrominoModel(type: $type, position: $position, rotation: $rotationState)';
  }
} 
import '../../domain/entities/score.dart';

/// Data model for Score that can be serialized to/from JSON
class ScoreModel {
  final int points;
  final int level;
  final int linesCleared;
  final int totalLinesCleared;

  const ScoreModel({
    required this.points,
    required this.level,
    required this.linesCleared,
    required this.totalLinesCleared,
  });

  /// Creates a ScoreModel from a domain Score entity
  factory ScoreModel.fromEntity(Score score) {
    return ScoreModel(
      points: score.points,
      level: score.level,
      linesCleared: score.linesCleared,
      totalLinesCleared: score.totalLinesCleared,
    );
  }

  /// Creates a ScoreModel from JSON
  factory ScoreModel.fromJson(Map<String, dynamic> json) {
    return ScoreModel(
      points: json['points'] as int,
      level: json['level'] as int,
      linesCleared: json['linesCleared'] as int,
      totalLinesCleared: json['totalLinesCleared'] as int,
    );
  }

  /// Converts this model to JSON
  Map<String, dynamic> toJson() {
    return {
      'points': points,
      'level': level,
      'linesCleared': linesCleared,
      'totalLinesCleared': totalLinesCleared,
    };
  }

  /// Converts this model to a domain Score entity
  Score toEntity() {
    return Score(
      points: points,
      level: level,
      linesCleared: linesCleared,
      totalLinesCleared: totalLinesCleared,
    );
  }

  @override
  String toString() {
    return 'ScoreModel(points: $points, level: $level, lines: $linesCleared/$totalLinesCleared)';
  }
}

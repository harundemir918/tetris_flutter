import '../../domain/repositories/score_repository.dart';
import 'score_model.dart';

/// Data model for ScoreEntry that can be serialized to/from JSON
class ScoreEntryModel {
  final ScoreModel score;
  final int gameDurationMs;
  final String timestamp;
  final int rank;

  const ScoreEntryModel({
    required this.score,
    required this.gameDurationMs,
    required this.timestamp,
    required this.rank,
  });

  /// Creates a ScoreEntryModel from a domain ScoreEntry
  factory ScoreEntryModel.fromEntity(ScoreEntry scoreEntry) {
    return ScoreEntryModel(
      score: ScoreModel.fromEntity(scoreEntry.score),
      gameDurationMs: scoreEntry.gameDuration.inMilliseconds,
      timestamp: scoreEntry.timestamp.toIso8601String(),
      rank: scoreEntry.rank,
    );
  }

  /// Creates a ScoreEntryModel from JSON
  factory ScoreEntryModel.fromJson(Map<String, dynamic> json) {
    return ScoreEntryModel(
      score: ScoreModel.fromJson(json['score'] as Map<String, dynamic>),
      gameDurationMs: json['gameDurationMs'] as int,
      timestamp: json['timestamp'] as String,
      rank: json['rank'] as int,
    );
  }

  /// Converts this model to JSON
  Map<String, dynamic> toJson() {
    return {
      'score': score.toJson(),
      'gameDurationMs': gameDurationMs,
      'timestamp': timestamp,
      'rank': rank,
    };
  }

  /// Converts this model to a domain ScoreEntry
  ScoreEntry toEntity() {
    return ScoreEntry(
      score: score.toEntity(),
      gameDuration: Duration(milliseconds: gameDurationMs),
      timestamp: DateTime.parse(timestamp),
      rank: rank,
    );
  }

  @override
  String toString() {
    return 'ScoreEntryModel(score: ${score.points}, rank: $rank)';
  }
}

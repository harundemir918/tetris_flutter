import '../entities/score.dart';

/// Repository interface for score tracking and statistics management
/// Defines contracts for high scores, statistics, and achievements
abstract class ScoreRepository {
  /// Saves a completed game score
  /// Returns true if save was successful
  Future<bool> saveScore(Score score, Duration gameDuration);

  /// Gets the highest score ever achieved
  /// Returns null if no scores exist
  Future<Score?> getHighScore();

  /// Gets the top N high scores
  /// Returns empty list if no scores exist
  Future<List<ScoreEntry>> getHighScores({int limit = 10});

  /// Gets total statistics across all games
  Future<GameStatistics> getTotalStatistics();

  /// Gets statistics for a specific time period
  Future<GameStatistics> getStatisticsForPeriod(DateTime start, DateTime end);

  /// Checks if a score qualifies as a new high score
  Future<bool> isNewHighScore(Score score);

  /// Gets the rank of a score among all scores
  /// Returns 1 for highest score, 2 for second highest, etc.
  Future<int> getScoreRank(Score score);

  /// Clears all saved scores and statistics
  /// Returns true if clearing was successful
  Future<bool> clearAllScores();

  /// Gets recent game scores (last N games)
  Future<List<ScoreEntry>> getRecentScores({int limit = 5});

  /// Gets average score over all games
  Future<double> getAverageScore();

  /// Gets total number of games played
  Future<int> getTotalGamesPlayed();
}

/// Represents a score entry with metadata
class ScoreEntry {
  final Score score;
  final Duration gameDuration;
  final DateTime timestamp;
  final int rank;

  const ScoreEntry({
    required this.score,
    required this.gameDuration,
    required this.timestamp,
    required this.rank,
  });

  /// Creates a score entry for a completed game
  factory ScoreEntry.fromGame({
    required Score score,
    required Duration gameDuration,
    DateTime? timestamp,
    int? rank,
  }) {
    return ScoreEntry(
      score: score,
      gameDuration: gameDuration,
      timestamp: timestamp ?? DateTime.now(),
      rank: rank ?? 0,
    );
  }

  @override
  String toString() {
    return 'ScoreEntry(score: ${score.points}, duration: ${gameDuration.inMinutes}m, rank: $rank)';
  }
}

/// Represents aggregated game statistics
class GameStatistics {
  final int totalGamesPlayed;
  final int totalLinesCleared;
  final int totalPoints;
  final Duration totalPlayTime;
  final double averageScore;
  final double averageLinesPerGame;
  final double averageGameDuration;
  final Score? bestScore;
  final int longestGameDuration;
  final int shortestGameDuration;
  final Map<String, int> pieceStatistics; // Piece type -> count used

  const GameStatistics({
    required this.totalGamesPlayed,
    required this.totalLinesCleared,
    required this.totalPoints,
    required this.totalPlayTime,
    required this.averageScore,
    required this.averageLinesPerGame,
    required this.averageGameDuration,
    this.bestScore,
    required this.longestGameDuration,
    required this.shortestGameDuration,
    required this.pieceStatistics,
  });

  /// Creates empty statistics
  factory GameStatistics.empty() {
    return const GameStatistics(
      totalGamesPlayed: 0,
      totalLinesCleared: 0,
      totalPoints: 0,
      totalPlayTime: Duration.zero,
      averageScore: 0.0,
      averageLinesPerGame: 0.0,
      averageGameDuration: 0.0,
      bestScore: null,
      longestGameDuration: 0,
      shortestGameDuration: 0,
      pieceStatistics: {},
    );
  }

  /// Gets efficiency rating (points per minute)
  double get pointsPerMinute {
    if (totalPlayTime.inMinutes == 0) return 0.0;
    return totalPoints / totalPlayTime.inMinutes;
  }

  /// Gets lines per minute across all games
  double get linesPerMinute {
    if (totalPlayTime.inMinutes == 0) return 0.0;
    return totalLinesCleared / totalPlayTime.inMinutes;
  }

  @override
  String toString() {
    return 'GameStatistics(games: $totalGamesPlayed, avgScore: ${averageScore.toStringAsFixed(1)}, totalLines: $totalLinesCleared)';
  }
} 
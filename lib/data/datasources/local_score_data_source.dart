import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/score_entry_model.dart';

/// Data source for local score and statistics persistence using SharedPreferences
class LocalScoreDataSource {
  static const String _scoresKey = 'tetris_scores';
  static const String _statisticsKey = 'tetris_statistics';

  final SharedPreferences _prefs;

  LocalScoreDataSource(this._prefs);

  /// Saves a completed game score
  Future<bool> saveScore(ScoreEntryModel scoreEntry) async {
    try {
      final scores = await getScores();
      scores.add(scoreEntry);

      // Sort by score descending
      scores.sort((a, b) => b.score.points.compareTo(a.score.points));

      // Update ranks
      for (int i = 0; i < scores.length; i++) {
        scores[i] = ScoreEntryModel(
          score: scores[i].score,
          gameDurationMs: scores[i].gameDurationMs,
          timestamp: scores[i].timestamp,
          rank: i + 1,
        );
      }

      // Keep only top 100 scores to prevent unlimited growth
      if (scores.length > 100) {
        scores.removeRange(100, scores.length);
      }

      return await _saveScores(scores);
    } catch (e) {
      return false;
    }
  }

  /// Gets all saved scores
  Future<List<ScoreEntryModel>> getScores() async {
    try {
      final jsonString = _prefs.getString(_scoresKey);
      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((json) => ScoreEntryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Gets the top N high scores
  Future<List<ScoreEntryModel>> getHighScores({int limit = 10}) async {
    try {
      final scores = await getScores();
      return scores.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  /// Gets the highest score ever achieved
  Future<ScoreEntryModel?> getHighScore() async {
    try {
      final scores = await getScores();
      return scores.isNotEmpty ? scores.first : null;
    } catch (e) {
      return null;
    }
  }

  /// Gets recent game scores (last N games)
  Future<List<ScoreEntryModel>> getRecentScores({int limit = 5}) async {
    try {
      final scores = await getScores();
      // Sort by timestamp descending (most recent first)
      scores.sort(
        (a, b) =>
            DateTime.parse(b.timestamp).compareTo(DateTime.parse(a.timestamp)),
      );
      return scores.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  /// Checks if a score qualifies as a new high score
  Future<bool> isNewHighScore(int points) async {
    try {
      final highScore = await getHighScore();
      return highScore == null || points > highScore.score.points;
    } catch (e) {
      return false;
    }
  }

  /// Gets the rank of a score among all scores
  Future<int> getScoreRank(int points) async {
    try {
      final scores = await getScores();
      int rank = 1;
      for (final score in scores) {
        if (points >= score.score.points) {
          break;
        }
        rank++;
      }
      return rank;
    } catch (e) {
      return 1;
    }
  }

  /// Gets total number of games played
  Future<int> getTotalGamesPlayed() async {
    try {
      final scores = await getScores();
      return scores.length;
    } catch (e) {
      return 0;
    }
  }

  /// Gets average score over all games
  Future<double> getAverageScore() async {
    try {
      final scores = await getScores();
      if (scores.isEmpty) return 0.0;

      final totalPoints = scores.fold<int>(
        0,
        (sum, score) => sum + score.score.points,
      );
      return totalPoints / scores.length;
    } catch (e) {
      return 0.0;
    }
  }

  /// Saves game statistics
  Future<bool> saveStatistics(Map<String, dynamic> statistics) async {
    try {
      final jsonString = jsonEncode(statistics);
      return await _prefs.setString(_statisticsKey, jsonString);
    } catch (e) {
      return false;
    }
  }

  /// Loads game statistics
  Future<Map<String, dynamic>> loadStatistics() async {
    try {
      final jsonString = _prefs.getString(_statisticsKey);
      if (jsonString == null) {
        return _getDefaultStatistics();
      }

      return Map<String, dynamic>.from(jsonDecode(jsonString) as Map);
    } catch (e) {
      return _getDefaultStatistics();
    }
  }

  /// Clears all saved scores and statistics
  Future<bool> clearAllScores() async {
    try {
      final scoresRemoved = await _prefs.remove(_scoresKey);
      final statsRemoved = await _prefs.remove(_statisticsKey);
      return scoresRemoved && statsRemoved;
    } catch (e) {
      return false;
    }
  }

  /// Private method to save scores list
  Future<bool> _saveScores(List<ScoreEntryModel> scores) async {
    try {
      final jsonList = scores.map((score) => score.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      return await _prefs.setString(_scoresKey, jsonString);
    } catch (e) {
      return false;
    }
  }

  /// Returns default statistics structure
  Map<String, dynamic> _getDefaultStatistics() {
    return {
      'totalGamesPlayed': 0,
      'totalLinesCleared': 0,
      'totalPoints': 0,
      'totalPlayTimeMs': 0,
      'pieceStatistics': <String, int>{},
    };
  }
}

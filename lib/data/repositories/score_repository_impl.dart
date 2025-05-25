import '../../domain/entities/score.dart';
import '../../domain/repositories/score_repository.dart';
import '../datasources/local_score_data_source.dart';
import '../models/score_entry_model.dart';

/// Implementation of ScoreRepository using local data source
class ScoreRepositoryImpl implements ScoreRepository {
  final LocalScoreDataSource _localDataSource;

  ScoreRepositoryImpl(this._localDataSource);

  @override
  Future<bool> saveScore(Score score, Duration gameDuration) async {
    try {
      final scoreEntry = ScoreEntry.fromGame(
        score: score,
        gameDuration: gameDuration,
      );
      final scoreEntryModel = ScoreEntryModel.fromEntity(scoreEntry);
      
      final success = await _localDataSource.saveScore(scoreEntryModel);
      
      // Update statistics after saving score
      if (success) {
        await _updateStatistics(score, gameDuration);
      }
      
      return success;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Score?> getHighScore() async {
    try {
      final scoreEntryModel = await _localDataSource.getHighScore();
      return scoreEntryModel?.score.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<ScoreEntry>> getHighScores({int limit = 10}) async {
    try {
      final scoreEntryModels = await _localDataSource.getHighScores(limit: limit);
      return scoreEntryModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<GameStatistics> getTotalStatistics() async {
    try {
      final stats = await _localDataSource.loadStatistics();
      final scores = await _localDataSource.getScores();
      
      if (scores.isEmpty) {
        return GameStatistics.empty();
      }

      final totalGamesPlayed = scores.length;
      final totalLinesCleared = scores.fold<int>(0, (sum, score) => sum + score.score.linesCleared);
      final totalPoints = scores.fold<int>(0, (sum, score) => sum + score.score.points);
      final totalPlayTimeMs = scores.fold<int>(0, (sum, score) => sum + score.gameDurationMs);
      
      final averageScore = totalPoints / totalGamesPlayed;
      final averageLinesPerGame = totalLinesCleared / totalGamesPlayed;
      final averageGameDurationMs = totalPlayTimeMs / totalGamesPlayed;
      
      final bestScoreModel = await _localDataSource.getHighScore();
      final bestScore = bestScoreModel?.score.toEntity();
      
      final longestGameMs = scores.fold<int>(0, (max, score) => 
          score.gameDurationMs > max ? score.gameDurationMs : max);
      final shortestGameMs = scores.fold<int>(scores.first.gameDurationMs, (min, score) => 
          score.gameDurationMs < min ? score.gameDurationMs : min);

      return GameStatistics(
        totalGamesPlayed: totalGamesPlayed,
        totalLinesCleared: totalLinesCleared,
        totalPoints: totalPoints,
        totalPlayTime: Duration(milliseconds: totalPlayTimeMs),
        averageScore: averageScore,
        averageLinesPerGame: averageLinesPerGame,
        averageGameDuration: averageGameDurationMs / 1000, // Convert to seconds
        bestScore: bestScore,
        longestGameDuration: longestGameMs ~/ 1000, // Convert to seconds
        shortestGameDuration: shortestGameMs ~/ 1000, // Convert to seconds
        pieceStatistics: Map<String, int>.from(stats['pieceStatistics'] ?? {}),
      );
    } catch (e) {
      return GameStatistics.empty();
    }
  }

  @override
  Future<GameStatistics> getStatisticsForPeriod(DateTime start, DateTime end) async {
    try {
      final allScores = await _localDataSource.getScores();
      final periodScores = allScores.where((score) {
        final scoreDate = DateTime.parse(score.timestamp);
        return scoreDate.isAfter(start) && scoreDate.isBefore(end);
      }).toList();

      if (periodScores.isEmpty) {
        return GameStatistics.empty();
      }

      final totalGamesPlayed = periodScores.length;
      final totalLinesCleared = periodScores.fold<int>(0, (sum, score) => sum + score.score.linesCleared);
      final totalPoints = periodScores.fold<int>(0, (sum, score) => sum + score.score.points);
      final totalPlayTimeMs = periodScores.fold<int>(0, (sum, score) => sum + score.gameDurationMs);
      
      final averageScore = totalPoints / totalGamesPlayed;
      final averageLinesPerGame = totalLinesCleared / totalGamesPlayed;
      final averageGameDurationMs = totalPlayTimeMs / totalGamesPlayed;
      
      // Find best score in period
      periodScores.sort((a, b) => b.score.points.compareTo(a.score.points));
      final bestScore = periodScores.first.score.toEntity();
      
      final longestGameMs = periodScores.fold<int>(0, (max, score) => 
          score.gameDurationMs > max ? score.gameDurationMs : max);
      final shortestGameMs = periodScores.fold<int>(periodScores.first.gameDurationMs, (min, score) => 
          score.gameDurationMs < min ? score.gameDurationMs : min);

      return GameStatistics(
        totalGamesPlayed: totalGamesPlayed,
        totalLinesCleared: totalLinesCleared,
        totalPoints: totalPoints,
        totalPlayTime: Duration(milliseconds: totalPlayTimeMs),
        averageScore: averageScore,
        averageLinesPerGame: averageLinesPerGame,
        averageGameDuration: averageGameDurationMs / 1000,
        bestScore: bestScore,
        longestGameDuration: longestGameMs ~/ 1000,
        shortestGameDuration: shortestGameMs ~/ 1000,
        pieceStatistics: <String, int>{}, // Not tracked per period
      );
    } catch (e) {
      return GameStatistics.empty();
    }
  }

  @override
  Future<bool> isNewHighScore(Score score) async {
    try {
      return await _localDataSource.isNewHighScore(score.points);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<int> getScoreRank(Score score) async {
    try {
      return await _localDataSource.getScoreRank(score.points);
    } catch (e) {
      return 1;
    }
  }

  @override
  Future<bool> clearAllScores() async {
    try {
      return await _localDataSource.clearAllScores();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<ScoreEntry>> getRecentScores({int limit = 5}) async {
    try {
      final scoreEntryModels = await _localDataSource.getRecentScores(limit: limit);
      return scoreEntryModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<double> getAverageScore() async {
    try {
      return await _localDataSource.getAverageScore();
    } catch (e) {
      return 0.0;
    }
  }

  @override
  Future<int> getTotalGamesPlayed() async {
    try {
      return await _localDataSource.getTotalGamesPlayed();
    } catch (e) {
      return 0;
    }
  }

  /// Updates game statistics after saving a score
  Future<void> _updateStatistics(Score score, Duration gameDuration) async {
    try {
      final currentStats = await _localDataSource.loadStatistics();
      
      final updatedStats = {
        'totalGamesPlayed': (currentStats['totalGamesPlayed'] as int) + 1,
        'totalLinesCleared': (currentStats['totalLinesCleared'] as int) + score.totalLinesCleared,
        'totalPoints': (currentStats['totalPoints'] as int) + score.points,
        'totalPlayTimeMs': (currentStats['totalPlayTimeMs'] as int) + gameDuration.inMilliseconds,
        'pieceStatistics': currentStats['pieceStatistics'] ?? <String, int>{},
      };
      
      await _localDataSource.saveStatistics(updatedStats);
    } catch (e) {
      // Ignore statistics update errors
    }
  }
} 
import 'package:equatable/equatable.dart';
import '../../core/constants/game_constants.dart';
import '../../core/utils/game_utils.dart';

/// Represents the scoring system for the Tetris game
/// Immutable entity that tracks score, level, lines cleared, and provides calculations
class Score extends Equatable {
  final int points;
  final int level;
  final int linesCleared;
  final int totalLinesCleared;

  const Score({
    required this.points,
    required this.level,
    required this.linesCleared,
    required this.totalLinesCleared,
  });

  /// Creates a new game score starting at zero
  const Score.initial()
    : points = 0,
      level = 0,
      linesCleared = 0,
      totalLinesCleared = 0;

  /// Creates a score for testing purposes
  const Score.test({
    int? points,
    int? level,
    int? linesCleared,
    int? totalLinesCleared,
  }) : points = points ?? 0,
       level = level ?? 0,
       linesCleared = linesCleared ?? 0,
       totalLinesCleared = totalLinesCleared ?? 0;

  /// Adds points to the current score
  Score addPoints(int additionalPoints) {
    if (additionalPoints < 0) {
      return this; // Don't allow negative points
    }

    return copyWith(points: points + additionalPoints);
  }

  /// Adds lines cleared and calculates new score and level
  Score addLinesCleared(
    int lines, {
    bool isSoftDrop = false,
    bool isHardDrop = false,
  }) {
    if (lines < 0 || lines > 4) {
      return this; // Invalid line count
    }

    if (lines == 0) {
      return this; // No lines cleared
    }

    // Calculate score for lines cleared
    final lineScore = GameUtils.calculateScore(
      lines,
      level,
      isSoftDrop: isSoftDrop,
      isHardDrop: isHardDrop,
    );

    final newTotalLines = totalLinesCleared + lines;
    final newLevel = GameUtils.calculateLevel(newTotalLines);
    final newLinesInCurrentLevel = newTotalLines % GameConstants.linesPerLevel;

    return Score(
      points: points + lineScore,
      level: newLevel,
      linesCleared: newLinesInCurrentLevel,
      totalLinesCleared: newTotalLines,
    );
  }

  /// Adds soft drop bonus points
  Score addSoftDropBonus(int dropDistance) {
    if (dropDistance <= 0) {
      return this;
    }

    final bonus = dropDistance * GameConstants.softDropBonus;
    return addPoints(bonus);
  }

  /// Adds hard drop bonus points
  Score addHardDropBonus(int dropDistance) {
    if (dropDistance <= 0) {
      return this;
    }

    final bonus = dropDistance * GameConstants.hardDropMultiplier;
    return addPoints(bonus);
  }

  /// Gets the current drop speed based on level
  int getDropSpeed() {
    return GameUtils.calculateDropSpeed(level);
  }

  /// Gets lines needed to reach next level
  int getLinesUntilNextLevel() {
    if (level >= GameConstants.maxLevel) {
      return 0; // Already at max level
    }

    return GameConstants.linesPerLevel - linesCleared;
  }

  /// Checks if the player has reached a new level
  bool hasLeveledUp(Score previousScore) {
    return level > previousScore.level;
  }

  /// Gets the score multiplier for the current level
  double getScoreMultiplier() {
    return 1.0 + (level * 0.1); // 10% increase per level
  }

  /// Calculates points per minute (PPM) based on game time
  double getPointsPerMinute(Duration gameTime) {
    if (gameTime.inSeconds == 0) {
      return 0.0;
    }

    final minutes = gameTime.inMilliseconds / 60000.0;
    return points / minutes;
  }

  /// Calculates lines per minute (LPM) based on game time
  double getLinesPerMinute(Duration gameTime) {
    if (gameTime.inSeconds == 0) {
      return 0.0;
    }

    final minutes = gameTime.inMilliseconds / 60000.0;
    return totalLinesCleared / minutes;
  }

  /// Gets efficiency rating (points per line)
  double getEfficiency() {
    if (totalLinesCleared == 0) {
      return 0.0;
    }

    return points / totalLinesCleared;
  }

  /// Checks if this is a high score compared to another score
  bool isHigherThan(Score other) {
    return points > other.points;
  }

  /// Gets a performance grade based on efficiency and level
  String getPerformanceGrade() {
    final efficiency = getEfficiency();

    if (efficiency >= 800) return 'S+';
    if (efficiency >= 600) return 'S';
    if (efficiency >= 500) return 'A+';
    if (efficiency >= 400) return 'A';
    if (efficiency >= 300) return 'B+';
    if (efficiency >= 200) return 'B';
    if (efficiency >= 150) return 'C+';
    if (efficiency >= 100) return 'C';
    if (efficiency >= 50) return 'D';
    return 'F';
  }

  /// Gets score breakdown for display
  Map<String, dynamic> getScoreBreakdown() {
    return {
      'points': points,
      'level': level,
      'linesCleared': linesCleared,
      'totalLinesCleared': totalLinesCleared,
      'linesUntilNextLevel': getLinesUntilNextLevel(),
      'dropSpeed': getDropSpeed(),
      'efficiency': getEfficiency(),
      'grade': getPerformanceGrade(),
    };
  }

  /// Resets the score to initial state
  Score reset() {
    return const Score.initial();
  }

  /// Creates a copy of this score with optional modifications
  Score copyWith({
    int? points,
    int? level,
    int? linesCleared,
    int? totalLinesCleared,
  }) {
    return Score(
      points: points ?? this.points,
      level: level ?? this.level,
      linesCleared: linesCleared ?? this.linesCleared,
      totalLinesCleared: totalLinesCleared ?? this.totalLinesCleared,
    );
  }

  /// Validates that the score state is consistent
  bool isValid() {
    return points >= 0 &&
        level >= 0 &&
        level <= GameConstants.maxLevel &&
        linesCleared >= 0 &&
        linesCleared < GameConstants.linesPerLevel &&
        totalLinesCleared >= 0 &&
        totalLinesCleared >= linesCleared;
  }

  @override
  List<Object?> get props => [points, level, linesCleared, totalLinesCleared];

  @override
  String toString() {
    return 'Score(points: $points, level: $level, lines: $linesCleared/$totalLinesCleared)';
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:tetris_flutter/domain/entities/score.dart';

void main() {
  group('Score', () {
    group('creation', () {
      test('should create score with given properties', () {
        // Act
        const score = Score(
          points: 1000,
          level: 5,
          linesCleared: 3,
          totalLinesCleared: 53,
        );

        // Assert
        expect(score.points, 1000);
        expect(score.level, 5);
        expect(score.linesCleared, 3);
        expect(score.totalLinesCleared, 53);
      });

      test('should create initial score with zeros', () {
        // Act
        const score = Score.initial();

        // Assert
        expect(score.points, 0);
        expect(score.level, 0);
        expect(score.linesCleared, 0);
        expect(score.totalLinesCleared, 0);
      });

      test('should create test score with defaults', () {
        // Act
        const score = Score.test();

        // Assert
        expect(score.points, 0);
        expect(score.level, 0);
        expect(score.linesCleared, 0);
        expect(score.totalLinesCleared, 0);
      });

      test('should create test score with custom values', () {
        // Act
        const score = Score.test(
          points: 500,
          level: 3,
          linesCleared: 7,
          totalLinesCleared: 37,
        );

        // Assert
        expect(score.points, 500);
        expect(score.level, 3);
        expect(score.linesCleared, 7);
        expect(score.totalLinesCleared, 37);
      });
    });

    group('adding points', () {
      test('should add positive points', () {
        // Arrange
        const score = Score.test(points: 100);

        // Act
        final newScore = score.addPoints(50);

        // Assert
        expect(newScore.points, 150);
        expect(score.points, 100); // Original unchanged
      });

      test('should ignore negative points', () {
        // Arrange
        const score = Score.test(points: 100);

        // Act
        final newScore = score.addPoints(-50);

        // Assert
        expect(newScore.points, 100);
      });

      test('should handle zero points', () {
        // Arrange
        const score = Score.test(points: 100);

        // Act
        final newScore = score.addPoints(0);

        // Assert
        expect(newScore.points, 100);
      });
    });

    group('adding lines cleared', () {
      test('should add single line and calculate score', () {
        // Arrange
        const score = Score.test(level: 2);

        // Act
        final newScore = score.addLinesCleared(1);

        // Assert
        expect(newScore.totalLinesCleared, 1);
        expect(newScore.linesCleared, 1);
        expect(newScore.points, 300); // 100 * (2 + 1) = 300
        expect(newScore.level, 0); // Still level 0 (need 10 lines for level 1)
      });

      test('should add double lines and calculate score', () {
        // Arrange
        const score = Score.test(level: 1);

        // Act
        final newScore = score.addLinesCleared(2);

        // Assert
        expect(newScore.totalLinesCleared, 2);
        expect(newScore.linesCleared, 2);
        expect(newScore.points, 600); // 300 * (1 + 1) = 600
      });

      test('should add triple lines and calculate score', () {
        // Arrange
        const score = Score.test(level: 0);

        // Act
        final newScore = score.addLinesCleared(3);

        // Assert
        expect(newScore.totalLinesCleared, 3);
        expect(newScore.points, 500); // 500 * (0 + 1) = 500
      });

      test('should add tetris (4 lines) and calculate score', () {
        // Arrange
        const score = Score.test(level: 1);

        // Act
        final newScore = score.addLinesCleared(4);

        // Assert
        expect(newScore.totalLinesCleared, 4);
        expect(newScore.points, 1600); // 800 * (1 + 1) = 1600
      });

      test('should level up when reaching 10 lines', () {
        // Arrange
        const score = Score.test(totalLinesCleared: 8);

        // Act
        final newScore = score.addLinesCleared(3);

        // Assert
        expect(newScore.totalLinesCleared, 11);
        expect(newScore.level, 1);
        expect(newScore.linesCleared, 1); // 11 % 10 = 1
      });

      test('should handle soft drop bonus', () {
        // Arrange
        const score = Score.test(level: 0);

        // Act
        final newScore = score.addLinesCleared(1, isSoftDrop: true);

        // Assert
        expect(newScore.points, 101); // 100 + 1 soft drop bonus
      });

      test('should handle hard drop bonus', () {
        // Arrange
        const score = Score.test(level: 0);

        // Act
        final newScore = score.addLinesCleared(1, isHardDrop: true);

        // Assert
        expect(newScore.points, 200); // 100 * 2 hard drop multiplier
      });

      test('should ignore invalid line counts', () {
        // Arrange
        const score = Score.test(points: 100);

        // Act
        final negativeLines = score.addLinesCleared(-1);
        final tooManyLines = score.addLinesCleared(5);
        final zeroLines = score.addLinesCleared(0);

        // Assert
        expect(negativeLines, score);
        expect(tooManyLines, score);
        expect(zeroLines, score);
      });
    });

    group('drop bonuses', () {
      test('should add soft drop bonus', () {
        // Arrange
        const score = Score.test(points: 100);

        // Act
        final newScore = score.addSoftDropBonus(5);

        // Assert
        expect(newScore.points, 105); // 100 + (5 * 1)
      });

      test('should add hard drop bonus', () {
        // Arrange
        const score = Score.test(points: 100);

        // Act
        final newScore = score.addHardDropBonus(3);

        // Assert
        expect(newScore.points, 106); // 100 + (3 * 2)
      });

      test('should ignore non-positive drop distances', () {
        // Arrange
        const score = Score.test(points: 100);

        // Act
        final zeroDistance = score.addSoftDropBonus(0);
        final negativeDistance = score.addHardDropBonus(-1);

        // Assert
        expect(zeroDistance.points, 100);
        expect(negativeDistance.points, 100);
      });
    });

    group('level progression', () {
      test('should calculate drop speed based on level', () {
        // Arrange
        const level0 = Score.test(level: 0);
        const level5 = Score.test(level: 5);
        const level10 = Score.test(level: 10);

        // Act & Assert
        expect(level0.getDropSpeed(), 800); // 800 - (0 * 50)
        expect(level5.getDropSpeed(), 550); // 800 - (5 * 50)
        expect(level10.getDropSpeed(), 300); // 800 - (10 * 50)
      });

      test('should calculate lines until next level', () {
        // Arrange
        const score = Score.test(linesCleared: 3);

        // Act
        final linesNeeded = score.getLinesUntilNextLevel();

        // Assert
        expect(linesNeeded, 7); // 10 - 3 = 7
      });

      test('should return 0 lines needed at max level', () {
        // Arrange
        const score = Score.test(level: 20); // Max level

        // Act
        final linesNeeded = score.getLinesUntilNextLevel();

        // Assert
        expect(linesNeeded, 0);
      });

      test('should detect level up', () {
        // Arrange
        const oldScore = Score.test(level: 2);
        const newScore = Score.test(level: 3);
        const sameScore = Score.test(level: 2);

        // Act & Assert
        expect(newScore.hasLeveledUp(oldScore), true);
        expect(sameScore.hasLeveledUp(oldScore), false);
      });

      test('should calculate score multiplier', () {
        // Arrange
        const level0 = Score.test(level: 0);
        const level5 = Score.test(level: 5);

        // Act & Assert
        expect(level0.getScoreMultiplier(), 1.0);
        expect(level5.getScoreMultiplier(), 1.5); // 1.0 + (5 * 0.1)
      });
    });

    group('performance metrics', () {
      test('should calculate points per minute', () {
        // Arrange
        const score = Score.test(points: 1200);
        const gameTime = Duration(minutes: 2);

        // Act
        final ppm = score.getPointsPerMinute(gameTime);

        // Assert
        expect(ppm, 600.0); // 1200 / 2
      });

      test('should calculate lines per minute', () {
        // Arrange
        const score = Score.test(totalLinesCleared: 30);
        const gameTime = Duration(minutes: 3);

        // Act
        final lpm = score.getLinesPerMinute(gameTime);

        // Assert
        expect(lpm, 10.0); // 30 / 3
      });

      test('should handle zero game time', () {
        // Arrange
        const score = Score.test(points: 1000, totalLinesCleared: 10);
        const zeroTime = Duration.zero;

        // Act
        final ppm = score.getPointsPerMinute(zeroTime);
        final lpm = score.getLinesPerMinute(zeroTime);

        // Assert
        expect(ppm, 0.0);
        expect(lpm, 0.0);
      });

      test('should calculate efficiency (points per line)', () {
        // Arrange
        const score = Score.test(points: 1500, totalLinesCleared: 10);

        // Act
        final efficiency = score.getEfficiency();

        // Assert
        expect(efficiency, 150.0); // 1500 / 10
      });

      test('should handle zero lines for efficiency', () {
        // Arrange
        const score = Score.test(points: 1000, totalLinesCleared: 0);

        // Act
        final efficiency = score.getEfficiency();

        // Assert
        expect(efficiency, 0.0);
      });

      test('should compare scores', () {
        // Arrange
        const higherScore = Score.test(points: 1000);
        const lowerScore = Score.test(points: 500);

        // Act & Assert
        expect(higherScore.isHigherThan(lowerScore), true);
        expect(lowerScore.isHigherThan(higherScore), false);
      });
    });

    group('performance grading', () {
      test('should assign correct grades based on efficiency', () {
        // Arrange & Act & Assert
        expect(
          Score.test(points: 8000, totalLinesCleared: 10).getPerformanceGrade(),
          'S+',
        ); // 800
        expect(
          Score.test(points: 6000, totalLinesCleared: 10).getPerformanceGrade(),
          'S',
        ); // 600
        expect(
          Score.test(points: 5000, totalLinesCleared: 10).getPerformanceGrade(),
          'A+',
        ); // 500
        expect(
          Score.test(points: 4000, totalLinesCleared: 10).getPerformanceGrade(),
          'A',
        ); // 400
        expect(
          Score.test(points: 3000, totalLinesCleared: 10).getPerformanceGrade(),
          'B+',
        ); // 300
        expect(
          Score.test(points: 2000, totalLinesCleared: 10).getPerformanceGrade(),
          'B',
        ); // 200
        expect(
          Score.test(points: 1500, totalLinesCleared: 10).getPerformanceGrade(),
          'C+',
        ); // 150
        expect(
          Score.test(points: 1000, totalLinesCleared: 10).getPerformanceGrade(),
          'C',
        ); // 100
        expect(
          Score.test(points: 500, totalLinesCleared: 10).getPerformanceGrade(),
          'D',
        ); // 50
        expect(
          Score.test(points: 100, totalLinesCleared: 10).getPerformanceGrade(),
          'F',
        ); // 10
      });

      test('should handle zero efficiency', () {
        // Arrange
        const score = Score.test(points: 0, totalLinesCleared: 0);

        // Act
        final grade = score.getPerformanceGrade();

        // Assert
        expect(grade, 'F');
      });
    });

    group('score breakdown', () {
      test('should provide complete score breakdown', () {
        // Arrange
        const score = Score.test(
          points: 1500,
          level: 3,
          linesCleared: 5,
          totalLinesCleared: 35,
        );

        // Act
        final breakdown = score.getScoreBreakdown();

        // Assert
        expect(breakdown['points'], 1500);
        expect(breakdown['level'], 3);
        expect(breakdown['linesCleared'], 5);
        expect(breakdown['totalLinesCleared'], 35);
        expect(breakdown['linesUntilNextLevel'], 5); // 10 - 5
        expect(breakdown['dropSpeed'], 650); // 800 - (3 * 50)
        expect(breakdown['efficiency'], closeTo(42.86, 0.01)); // 1500 / 35
        expect(breakdown['grade'], 'F');
      });
    });

    group('validation', () {
      test('should validate correct score state', () {
        // Arrange
        const validScore = Score.test(
          points: 1000,
          level: 5,
          linesCleared: 3,
          totalLinesCleared: 53,
        );

        // Act
        final isValid = validScore.isValid();

        // Assert
        expect(isValid, true);
      });

      test('should invalidate negative points', () {
        // Arrange
        const invalidScore = Score(
          points: -100,
          level: 0,
          linesCleared: 0,
          totalLinesCleared: 0,
        );

        // Act
        final isValid = invalidScore.isValid();

        // Assert
        expect(isValid, false);
      });

      test('should invalidate negative level', () {
        // Arrange
        const invalidScore = Score(
          points: 100,
          level: -1,
          linesCleared: 0,
          totalLinesCleared: 0,
        );

        // Act
        final isValid = invalidScore.isValid();

        // Assert
        expect(isValid, false);
      });

      test('should invalidate level above max', () {
        // Arrange
        const invalidScore = Score(
          points: 100,
          level: 21, // Max is 20
          linesCleared: 0,
          totalLinesCleared: 0,
        );

        // Act
        final isValid = invalidScore.isValid();

        // Assert
        expect(isValid, false);
      });

      test('should invalidate lines cleared above limit', () {
        // Arrange
        const invalidScore = Score(
          points: 100,
          level: 0,
          linesCleared: 10, // Should be < 10
          totalLinesCleared: 10,
        );

        // Act
        final isValid = invalidScore.isValid();

        // Assert
        expect(isValid, false);
      });

      test('should invalidate inconsistent line counts', () {
        // Arrange
        const invalidScore = Score(
          points: 100,
          level: 0,
          linesCleared: 5,
          totalLinesCleared: 3, // Should be >= linesCleared
        );

        // Act
        final isValid = invalidScore.isValid();

        // Assert
        expect(isValid, false);
      });
    });

    group('resetting', () {
      test('should reset to initial state', () {
        // Arrange
        const score = Score.test(
          points: 1000,
          level: 5,
          linesCleared: 7,
          totalLinesCleared: 57,
        );

        // Act
        final resetScore = score.reset();

        // Assert
        expect(resetScore.points, 0);
        expect(resetScore.level, 0);
        expect(resetScore.linesCleared, 0);
        expect(resetScore.totalLinesCleared, 0);
      });
    });

    group('copying', () {
      test('should copy with modified points', () {
        // Arrange
        const original = Score.test(points: 100, level: 2);

        // Act
        final copied = original.copyWith(points: 500);

        // Assert
        expect(copied.points, 500);
        expect(copied.level, 2);
        expect(original.points, 100); // Original unchanged
      });

      test('should copy with all modifications', () {
        // Arrange
        const original = Score.initial();

        // Act
        final copied = original.copyWith(
          points: 1000,
          level: 5,
          linesCleared: 3,
          totalLinesCleared: 53,
        );

        // Assert
        expect(copied.points, 1000);
        expect(copied.level, 5);
        expect(copied.linesCleared, 3);
        expect(copied.totalLinesCleared, 53);
      });

      test('should copy without modifications', () {
        // Arrange
        const original = Score.test(points: 500, level: 3);

        // Act
        final copied = original.copyWith();

        // Assert
        expect(copied, original);
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        // Arrange
        const score1 = Score(
          points: 1000,
          level: 5,
          linesCleared: 3,
          totalLinesCleared: 53,
        );
        const score2 = Score(
          points: 1000,
          level: 5,
          linesCleared: 3,
          totalLinesCleared: 53,
        );

        // Assert
        expect(score1, score2);
        expect(score1.hashCode, score2.hashCode);
      });

      test('should not be equal when properties differ', () {
        // Arrange
        const score1 = Score.test(points: 1000);
        const score2 = Score.test(points: 2000);

        // Assert
        expect(score1, isNot(score2));
      });
    });

    group('string representation', () {
      test('should return readable string representation', () {
        // Arrange
        const score = Score.test(
          points: 1500,
          level: 3,
          linesCleared: 5,
          totalLinesCleared: 35,
        );

        // Act
        final string = score.toString();

        // Assert
        expect(string, 'Score(points: 1500, level: 3, lines: 5/35)');
      });
    });
  });
}

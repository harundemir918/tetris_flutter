import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tetris_flutter/domain/entities/game_state.dart';
import 'package:tetris_flutter/domain/entities/score.dart';
import 'package:tetris_flutter/domain/repositories/game_repository.dart';
import 'package:tetris_flutter/domain/usecases/start_game_usecase.dart';

import 'start_game_usecase_test.mocks.dart';

@GenerateMocks([GameRepository])
void main() {
  group('StartGameUseCase', () {
    late StartGameUseCase useCase;
    late MockGameRepository mockGameRepository;

    setUp(() {
      mockGameRepository = MockGameRepository();
      useCase = StartGameUseCase(mockGameRepository);
    });

    group('starting new game', () {
      test(
        'should start new game and clear saved game when requested',
        () async {
          // Arrange
          const params = StartGameParams(
            resumeSavedGame: false,
            clearSavedGame: true,
          );

          when(
            mockGameRepository.deleteSavedGame(),
          ).thenAnswer((_) async => true);
          when(
            mockGameRepository.autoSaveGameState(any),
          ).thenAnswer((_) async => true);

          // Act
          final result = await useCase(params);

          // Assert
          expect(result.status, GameStatus.playing);
          expect(result.startTime, isNotNull);
          verify(mockGameRepository.deleteSavedGame()).called(1);
          verify(mockGameRepository.autoSaveGameState(any)).called(1);
        },
      );

      test(
        'should start new game without clearing saved game when not requested',
        () async {
          // Arrange
          const params = StartGameParams(
            resumeSavedGame: false,
            clearSavedGame: false,
          );

          when(
            mockGameRepository.autoSaveGameState(any),
          ).thenAnswer((_) async => true);

          // Act
          final result = await useCase(params);

          // Assert
          expect(result.status, GameStatus.playing);
          expect(result.startTime, isNotNull);
          verifyNever(mockGameRepository.deleteSavedGame());
          verify(mockGameRepository.autoSaveGameState(any)).called(1);
        },
      );

      test('should use factory method for new game', () async {
        // Arrange
        final params = StartGameParams.newGame();

        when(
          mockGameRepository.deleteSavedGame(),
        ).thenAnswer((_) async => true);
        when(
          mockGameRepository.autoSaveGameState(any),
        ).thenAnswer((_) async => true);

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.status, GameStatus.playing);
        expect(params.resumeSavedGame, false);
        expect(params.clearSavedGame, true);
      });
    });

    group('resuming saved game', () {
      test('should resume saved game when one exists', () async {
        // Arrange
        final savedGame = GameState.test(
          status: GameStatus.paused,
          score: const Score.test(points: 1000),
        );
        const params = StartGameParams(resumeSavedGame: true);

        when(
          mockGameRepository.loadGameState(),
        ).thenAnswer((_) async => savedGame);
        when(
          mockGameRepository.autoSaveGameState(any),
        ).thenAnswer((_) async => true);

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.status, GameStatus.playing);
        expect(result.score.points, 1000);
        verify(mockGameRepository.loadGameState()).called(1);
        verify(mockGameRepository.autoSaveGameState(any)).called(1);
      });

      test('should start new game when no saved game exists', () async {
        // Arrange
        const params = StartGameParams(resumeSavedGame: true);

        when(mockGameRepository.loadGameState()).thenAnswer((_) async => null);
        when(
          mockGameRepository.autoSaveGameState(any),
        ).thenAnswer((_) async => true);

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.status, GameStatus.playing);
        expect(result.score.points, 0); // New game score
        verify(mockGameRepository.loadGameState()).called(1);
        verify(mockGameRepository.autoSaveGameState(any)).called(1);
      });

      test('should use factory method for resume game', () async {
        // Arrange
        final params = StartGameParams.resumeGame();

        when(mockGameRepository.loadGameState()).thenAnswer((_) async => null);
        when(
          mockGameRepository.autoSaveGameState(any),
        ).thenAnswer((_) async => true);

        // Act
        await useCase(params);

        // Assert
        expect(params.resumeSavedGame, true);
        expect(params.clearSavedGame, false);
      });
    });

    group('error handling', () {
      test('should return new game when loading saved game fails', () async {
        // Arrange
        const params = StartGameParams(resumeSavedGame: true);

        when(
          mockGameRepository.loadGameState(),
        ).thenThrow(Exception('Load failed'));
        when(
          mockGameRepository.autoSaveGameState(any),
        ).thenAnswer((_) async => true);

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.status, GameStatus.playing);
        expect(result.score.points, 0); // New game score
      });

      test('should return new game when auto-save fails', () async {
        // Arrange
        const params = StartGameParams(resumeSavedGame: false);

        when(
          mockGameRepository.autoSaveGameState(any),
        ).thenThrow(Exception('Auto-save failed'));

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.status, GameStatus.playing);
        expect(result.score.points, 0); // New game score
      });

      test('should return new game when delete saved game fails', () async {
        // Arrange
        const params = StartGameParams(
          resumeSavedGame: false,
          clearSavedGame: true,
        );

        when(
          mockGameRepository.deleteSavedGame(),
        ).thenThrow(Exception('Delete failed'));
        when(
          mockGameRepository.autoSaveGameState(any),
        ).thenAnswer((_) async => true);

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.status, GameStatus.playing);
        expect(result.score.points, 0); // New game score
      });
    });

    group('parameters', () {
      test('should have correct string representation', () {
        // Arrange
        const params1 = StartGameParams(
          resumeSavedGame: true,
          clearSavedGame: false,
        );
        const params2 = StartGameParams(
          resumeSavedGame: false,
          clearSavedGame: true,
        );

        // Act & Assert
        expect(
          params1.toString(),
          'StartGameParams(resume: true, clear: false)',
        );
        expect(
          params2.toString(),
          'StartGameParams(resume: false, clear: true)',
        );
      });
    });
  });
}

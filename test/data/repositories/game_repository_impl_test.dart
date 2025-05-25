import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:tetris_flutter/data/datasources/local_game_data_source.dart';
import 'package:tetris_flutter/data/models/game_state_model.dart';
import 'package:tetris_flutter/data/repositories/game_repository_impl.dart';
import 'package:tetris_flutter/domain/entities/game_state.dart';

import 'game_repository_impl_test.mocks.dart';

@GenerateMocks([LocalGameDataSource])
void main() {
  late GameRepositoryImpl repository;
  late MockLocalGameDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockLocalGameDataSource();
    repository = GameRepositoryImpl(mockDataSource);
  });

  group('GameRepositoryImpl', () {
    test('should save game state successfully', () async {
      // Arrange
      final gameState = GameState.initial();
      when(mockDataSource.saveGameState(any)).thenAnswer((_) async => true);

      // Act
      final result = await repository.saveGameState(gameState);

      // Assert
      expect(result, true);
      verify(mockDataSource.saveGameState(any)).called(1);
    });

    test('should load game state successfully', () async {
      // Arrange
      final gameState = GameState.initial();
      final gameStateModel = GameStateModel.fromEntity(gameState);
      when(
        mockDataSource.loadGameState(),
      ).thenAnswer((_) async => gameStateModel);

      // Act
      final result = await repository.loadGameState();

      // Assert
      expect(result, isNotNull);
      expect(result!.status, gameState.status);
      verify(mockDataSource.loadGameState()).called(1);
    });

    test('should return null when no saved game exists', () async {
      // Arrange
      when(mockDataSource.loadGameState()).thenAnswer((_) async => null);

      // Act
      final result = await repository.loadGameState();

      // Assert
      expect(result, isNull);
      verify(mockDataSource.loadGameState()).called(1);
    });

    test('should check if saved game exists', () async {
      // Arrange
      when(mockDataSource.hasSavedGame()).thenAnswer((_) async => true);

      // Act
      final result = await repository.hasSavedGame();

      // Assert
      expect(result, true);
      verify(mockDataSource.hasSavedGame()).called(1);
    });

    test('should delete saved game successfully', () async {
      // Arrange
      when(mockDataSource.deleteSavedGame()).thenAnswer((_) async => true);

      // Act
      final result = await repository.deleteSavedGame();

      // Assert
      expect(result, true);
      verify(mockDataSource.deleteSavedGame()).called(1);
    });

    test('should save game settings successfully', () async {
      // Arrange
      final settings = {'soundEnabled': true, 'vibrationEnabled': false};
      when(mockDataSource.saveGameSettings(any)).thenAnswer((_) async => true);

      // Act
      final result = await repository.saveGameSettings(settings);

      // Assert
      expect(result, true);
      verify(mockDataSource.saveGameSettings(settings)).called(1);
    });

    test('should load game settings successfully', () async {
      // Arrange
      final settings = {'soundEnabled': true, 'vibrationEnabled': false};
      when(mockDataSource.loadGameSettings()).thenAnswer((_) async => settings);

      // Act
      final result = await repository.loadGameSettings();

      // Assert
      expect(result, settings);
      verify(mockDataSource.loadGameSettings()).called(1);
    });

    test('should handle errors gracefully', () async {
      // Arrange
      when(
        mockDataSource.saveGameState(any),
      ).thenThrow(Exception('Test error'));

      // Act
      final result = await repository.saveGameState(GameState.initial());

      // Assert
      expect(result, false);
    });
  });
}

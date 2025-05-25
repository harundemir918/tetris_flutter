import '../../domain/entities/game_state.dart';
import '../../domain/repositories/game_repository.dart';
import '../datasources/local_game_data_source.dart';
import '../models/game_state_model.dart';

/// Implementation of GameRepository using local data source
class GameRepositoryImpl implements GameRepository {
  final LocalGameDataSource _localDataSource;

  GameRepositoryImpl(this._localDataSource);

  @override
  Future<bool> saveGameState(GameState gameState) async {
    try {
      final gameStateModel = GameStateModel.fromEntity(gameState);
      return await _localDataSource.saveGameState(gameStateModel);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<GameState?> loadGameState() async {
    try {
      final gameStateModel = await _localDataSource.loadGameState();
      return gameStateModel?.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> hasSavedGame() async {
    try {
      return await _localDataSource.hasSavedGame();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteSavedGame() async {
    try {
      return await _localDataSource.deleteSavedGame();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> saveGameSettings(Map<String, dynamic> settings) async {
    try {
      return await _localDataSource.saveGameSettings(settings);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> loadGameSettings() async {
    try {
      return await _localDataSource.loadGameSettings();
    } catch (e) {
      // Return default settings on error
      return {
        'soundEnabled': true,
        'vibrationEnabled': true,
        'showGhostPiece': true,
        'dropSpeed': 1.0,
      };
    }
  }

  @override
  Future<bool> autoSaveGameState(GameState gameState) async {
    try {
      final gameStateModel = GameStateModel.fromEntity(gameState);
      return await _localDataSource.autoSaveGameState(gameStateModel);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<GameState?> loadAutoSavedGameState() async {
    try {
      final gameStateModel = await _localDataSource.loadAutoSavedGameState();
      return gameStateModel?.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> clearAutoSavedGameState() async {
    try {
      return await _localDataSource.clearAutoSavedGameState();
    } catch (e) {
      return false;
    }
  }
}

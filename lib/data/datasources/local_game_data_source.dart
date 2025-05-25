import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_state_model.dart';

/// Data source for local game state persistence using SharedPreferences
class LocalGameDataSource {
  static const String _gameStateKey = 'tetris_game_state';
  static const String _autoSaveGameStateKey = 'tetris_auto_save_game_state';
  static const String _gameSettingsKey = 'tetris_game_settings';

  final SharedPreferences _prefs;

  LocalGameDataSource(this._prefs);

  /// Saves the game state to local storage
  Future<bool> saveGameState(GameStateModel gameState) async {
    try {
      final jsonString = jsonEncode(gameState.toJson());
      return await _prefs.setString(_gameStateKey, jsonString);
    } catch (e) {
      return false;
    }
  }

  /// Loads the game state from local storage
  Future<GameStateModel?> loadGameState() async {
    try {
      final jsonString = _prefs.getString(_gameStateKey);
      if (jsonString == null) return null;

      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return GameStateModel.fromJson(jsonMap);
    } catch (e) {
      return null;
    }
  }

  /// Checks if a saved game exists
  Future<bool> hasSavedGame() async {
    return _prefs.containsKey(_gameStateKey);
  }

  /// Deletes the saved game state
  Future<bool> deleteSavedGame() async {
    try {
      return await _prefs.remove(_gameStateKey);
    } catch (e) {
      return false;
    }
  }

  /// Auto-saves the game state (for background/pause scenarios)
  Future<bool> autoSaveGameState(GameStateModel gameState) async {
    try {
      final jsonString = jsonEncode(gameState.toJson());
      return await _prefs.setString(_autoSaveGameStateKey, jsonString);
    } catch (e) {
      return false;
    }
  }

  /// Loads the auto-saved game state
  Future<GameStateModel?> loadAutoSavedGameState() async {
    try {
      final jsonString = _prefs.getString(_autoSaveGameStateKey);
      if (jsonString == null) return null;

      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return GameStateModel.fromJson(jsonMap);
    } catch (e) {
      return null;
    }
  }

  /// Clears auto-saved game state
  Future<bool> clearAutoSavedGameState() async {
    try {
      return await _prefs.remove(_autoSaveGameStateKey);
    } catch (e) {
      return false;
    }
  }

  /// Saves game settings/preferences
  Future<bool> saveGameSettings(Map<String, dynamic> settings) async {
    try {
      final jsonString = jsonEncode(settings);
      return await _prefs.setString(_gameSettingsKey, jsonString);
    } catch (e) {
      return false;
    }
  }

  /// Loads game settings/preferences
  Future<Map<String, dynamic>> loadGameSettings() async {
    try {
      final jsonString = _prefs.getString(_gameSettingsKey);
      if (jsonString == null) {
        // Return default settings
        return {
          'soundEnabled': true,
          'vibrationEnabled': true,
          'showGhostPiece': true,
          'dropSpeed': 1.0,
        };
      }

      return Map<String, dynamic>.from(jsonDecode(jsonString) as Map);
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
}

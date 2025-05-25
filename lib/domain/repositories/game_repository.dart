import '../entities/game_state.dart';

/// Repository interface for game state persistence and management
/// Defines contracts for saving, loading, and managing game data
abstract class GameRepository {
  /// Saves the current game state
  /// Returns true if save was successful, false otherwise
  Future<bool> saveGameState(GameState gameState);

  /// Loads the most recent saved game state
  /// Returns null if no saved game exists
  Future<GameState?> loadGameState();

  /// Checks if a saved game exists
  Future<bool> hasSavedGame();

  /// Deletes the saved game state
  /// Returns true if deletion was successful, false otherwise
  Future<bool> deleteSavedGame();

  /// Saves game settings/preferences
  Future<bool> saveGameSettings(Map<String, dynamic> settings);

  /// Loads game settings/preferences
  /// Returns default settings if none exist
  Future<Map<String, dynamic>> loadGameSettings();

  /// Auto-saves the game state (for background/pause scenarios)
  /// Returns true if auto-save was successful
  Future<bool> autoSaveGameState(GameState gameState);

  /// Loads the auto-saved game state
  /// Returns null if no auto-save exists
  Future<GameState?> loadAutoSavedGameState();

  /// Clears auto-saved game state
  Future<bool> clearAutoSavedGameState();
}

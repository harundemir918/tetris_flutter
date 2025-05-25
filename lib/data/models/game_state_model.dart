import '../../domain/entities/game_state.dart';
import 'game_board_model.dart';
import 'score_model.dart';
import 'tetromino_model.dart';

/// Data model for GameState that can be serialized to/from JSON
class GameStateModel {
  final GameBoardModel board;
  final TetrominoModel? currentPiece;
  final TetrominoModel? nextPiece;
  final TetrominoModel? heldPiece;
  final ScoreModel score;
  final String status;
  final String? startTime;
  final String? endTime;
  final bool canHold;
  final List<String> pieceBag;

  const GameStateModel({
    required this.board,
    this.currentPiece,
    this.nextPiece,
    this.heldPiece,
    required this.score,
    required this.status,
    this.startTime,
    this.endTime,
    required this.canHold,
    required this.pieceBag,
  });

  /// Creates a GameStateModel from a domain GameState entity
  factory GameStateModel.fromEntity(GameState gameState) {
    return GameStateModel(
      board: GameBoardModel.fromEntity(gameState.board),
      currentPiece: gameState.currentPiece != null
          ? TetrominoModel.fromEntity(gameState.currentPiece!)
          : null,
      nextPiece: gameState.nextPiece != null
          ? TetrominoModel.fromEntity(gameState.nextPiece!)
          : null,
      heldPiece: gameState.heldPiece != null
          ? TetrominoModel.fromEntity(gameState.heldPiece!)
          : null,
      score: ScoreModel.fromEntity(gameState.score),
      status: gameState.status.name,
      startTime: gameState.startTime?.toIso8601String(),
      endTime: gameState.endTime?.toIso8601String(),
      canHold: gameState.canHold,
      pieceBag: List<String>.from(gameState.pieceBag),
    );
  }

  /// Creates a GameStateModel from JSON
  factory GameStateModel.fromJson(Map<String, dynamic> json) {
    return GameStateModel(
      board: GameBoardModel.fromJson(json['board'] as Map<String, dynamic>),
      currentPiece: json['currentPiece'] != null
          ? TetrominoModel.fromJson(
              json['currentPiece'] as Map<String, dynamic>,
            )
          : null,
      nextPiece: json['nextPiece'] != null
          ? TetrominoModel.fromJson(json['nextPiece'] as Map<String, dynamic>)
          : null,
      heldPiece: json['heldPiece'] != null
          ? TetrominoModel.fromJson(json['heldPiece'] as Map<String, dynamic>)
          : null,
      score: ScoreModel.fromJson(json['score'] as Map<String, dynamic>),
      status: json['status'] as String,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      canHold: json['canHold'] as bool,
      pieceBag: List<String>.from(json['pieceBag'] as List),
    );
  }

  /// Converts this model to JSON
  Map<String, dynamic> toJson() {
    return {
      'board': board.toJson(),
      'currentPiece': currentPiece?.toJson(),
      'nextPiece': nextPiece?.toJson(),
      'heldPiece': heldPiece?.toJson(),
      'score': score.toJson(),
      'status': status,
      'startTime': startTime,
      'endTime': endTime,
      'canHold': canHold,
      'pieceBag': pieceBag,
    };
  }

  /// Converts this model to a domain GameState entity
  GameState toEntity() {
    return GameState(
      board: board.toEntity(),
      currentPiece: currentPiece?.toEntity(),
      nextPiece: nextPiece?.toEntity(),
      heldPiece: heldPiece?.toEntity(),
      score: score.toEntity(),
      status: _parseGameStatus(status),
      startTime: startTime != null ? DateTime.parse(startTime!) : null,
      endTime: endTime != null ? DateTime.parse(endTime!) : null,
      canHold: canHold,
      pieceBag: pieceBag,
    );
  }

  /// Parses game status string to enum
  GameStatus _parseGameStatus(String status) {
    switch (status) {
      case 'ready':
        return GameStatus.ready;
      case 'playing':
        return GameStatus.playing;
      case 'paused':
        return GameStatus.paused;
      case 'gameOver':
        return GameStatus.gameOver;
      default:
        return GameStatus.ready;
    }
  }

  @override
  String toString() {
    return 'GameStateModel(status: $status, score: ${score.points})';
  }
}

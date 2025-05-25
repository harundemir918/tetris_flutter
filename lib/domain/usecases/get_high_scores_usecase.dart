import '../entities/score.dart';
import '../repositories/score_repository.dart';
import 'base_usecase.dart';

/// Use case for getting high scores
class GetHighScoresUseCase
    extends UseCase<List<ScoreEntry>, GetHighScoresParams> {
  final ScoreRepository _scoreRepository;

  GetHighScoresUseCase(this._scoreRepository);

  @override
  Future<List<ScoreEntry>> call(GetHighScoresParams params) async {
    try {
      return await _scoreRepository.getHighScores(limit: params.limit);
    } catch (e) {
      return [];
    }
  }
}

/// Use case for getting game statistics
class GetGameStatisticsUseCase extends NoParamsUseCase<GameStatistics> {
  final ScoreRepository _scoreRepository;

  GetGameStatisticsUseCase(this._scoreRepository);

  @override
  Future<GameStatistics> call() async {
    try {
      return await _scoreRepository.getTotalStatistics();
    } catch (e) {
      return GameStatistics.empty();
    }
  }
}

/// Use case for checking if a score is a new high score
class IsNewHighScoreUseCase extends UseCase<bool, IsNewHighScoreParams> {
  final ScoreRepository _scoreRepository;

  IsNewHighScoreUseCase(this._scoreRepository);

  @override
  Future<bool> call(IsNewHighScoreParams params) async {
    try {
      return await _scoreRepository.isNewHighScore(params.score);
    } catch (e) {
      return false;
    }
  }
}

/// Parameters for getting high scores
class GetHighScoresParams {
  final int limit;

  const GetHighScoresParams({this.limit = 10});

  @override
  String toString() {
    return 'GetHighScoresParams(limit: $limit)';
  }
}

/// Parameters for checking if score is a new high score
class IsNewHighScoreParams {
  final Score score;

  const IsNewHighScoreParams({required this.score});

  @override
  String toString() {
    return 'IsNewHighScoreParams(score: ${score.points})';
  }
}

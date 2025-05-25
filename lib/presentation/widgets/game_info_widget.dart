import 'package:flutter/material.dart';

import '../../domain/entities/game_state.dart';

/// Widget that displays game information like score, level, and lines cleared
class GameInfoWidget extends StatelessWidget {
  final GameState gameState;

  const GameInfoWidget({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.black87,
        border: Border(bottom: BorderSide(color: Colors.white24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildInfoItem(
            'Score',
            gameState.score.points.toString(),
            Icons.star,
          ),
          _buildInfoItem(
            'Level',
            gameState.score.level.toString(),
            Icons.trending_up,
          ),
          _buildInfoItem(
            'Lines',
            gameState.score.linesCleared.toString(),
            Icons.horizontal_rule,
          ),
          _buildInfoItem('Time', _formatTime(gameState.startTime), Icons.timer),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime? startTime) {
    if (startTime == null) return '00:00';

    final duration = DateTime.now().difference(startTime);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

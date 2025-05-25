import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/game/simple_game_bloc.dart';

/// Widget that provides touch controls for the Tetris game
class GameControlsWidget extends StatelessWidget {
  const GameControlsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.black87,
        border: Border(top: BorderSide(color: Colors.white24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top row - Rotate and Hold
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: Icons.rotate_left,
                label: 'Rotate',
                onPressed: () {
                  context.read<SimpleGameBloc>().add(RotatePiece());
                },
              ),
              _buildControlButton(
                icon: Icons.pause,
                label: 'Hold',
                onPressed: () {
                  // TODO: Add hold when implemented
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Bottom row - Movement controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: Icons.keyboard_arrow_left,
                label: 'Left',
                onPressed: () {
                  context.read<SimpleGameBloc>().add(MovePieceLeft());
                },
              ),
              _buildControlButton(
                icon: Icons.keyboard_arrow_down,
                label: 'Down',
                onPressed: () {
                  context.read<SimpleGameBloc>().add(MovePieceDown());
                },
              ),
              _buildControlButton(
                icon: Icons.keyboard_arrow_right,
                label: 'Right',
                onPressed: () {
                  context.read<SimpleGameBloc>().add(MovePieceRight());
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}

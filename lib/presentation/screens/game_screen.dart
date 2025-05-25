import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/dependency_injection.dart';
import '../blocs/game/simple_game_bloc.dart';
import '../widgets/game_board_widget.dart';
import '../widgets/game_controls_widget.dart';
import '../widgets/game_info_widget.dart';

/// Main game screen that displays the Tetris game
class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DI.get<SimpleGameBloc>(),
      child: const GameScreenView(),
    );
  }
}

/// The main view of the game screen
class GameScreenView extends StatelessWidget {
  const GameScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Tetris',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          BlocBuilder<SimpleGameBloc, SimpleGameState>(
            builder: (context, state) {
              if (state is GamePlayingState) {
                return IconButton(
                  icon: const Icon(Icons.pause, color: Colors.white),
                  onPressed: () {
                    context.read<SimpleGameBloc>().add(PauseGame());
                  },
                );
              } else if (state is GamePausedState) {
                return IconButton(
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                  onPressed: () {
                    context.read<SimpleGameBloc>().add(ResumeGame());
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<SimpleGameBloc, SimpleGameState>(
        builder: (context, state) {
          if (state is GameLoadingState) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (state is GameErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Restart the bloc
                      context.read<SimpleGameBloc>().add(StartGame());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is GameReadyState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Ready to Play!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      context.read<SimpleGameBloc>().add(StartGame());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      'Start Game',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is GamePlayingState || state is GamePausedState) {
            final gameState = state is GamePlayingState
                ? state.gameState
                : (state as GamePausedState).gameState;

            return Column(
              children: [
                // Game info section
                GameInfoWidget(gameState: gameState),

                // Main game area
                Expanded(
                  child: Row(
                    children: [
                      // Game board
                      Expanded(
                        flex: 3,
                        child: GameBoardWidget(gameState: gameState),
                      ),

                      // Side panel with next piece, hold, etc.
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              // Next piece preview
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Column(
                                  children: [
                                    Text(
                                      'Next',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    // TODO: Add next piece preview
                                    SizedBox(
                                      height: 60,
                                      child: Center(
                                        child: Text(
                                          '?',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Hold piece
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Column(
                                  children: [
                                    Text(
                                      'Hold',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    // TODO: Add hold piece preview
                                    SizedBox(
                                      height: 60,
                                      child: Center(
                                        child: Text(
                                          '?',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Game controls
                GameControlsWidget(),

                // Pause overlay
                if (state is GamePausedState)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Text(
                        'PAUSED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }

          return const Center(
            child: Text('Unknown state', style: TextStyle(color: Colors.white)),
          );
        },
      ),
    );
  }
}

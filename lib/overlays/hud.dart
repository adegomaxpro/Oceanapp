import 'package:flutter/material.dart';
import '../game/aqua_path_game.dart';

class HUD extends StatelessWidget {
  final AquaPathGame game;

  const HUD({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Stack(
        children: [
          // Level Indicator (Top Left)
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getLevelColor(game.currentLevel).withValues(alpha: 0.9),
                    _getLevelColor(game.currentLevel).withValues(alpha: 0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white30, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.waves, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Level ${game.currentLevel}',
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Growth Bar & Score (Top Center)
          Align(
            alignment: Alignment.topCenter,
            child: ValueListenableBuilder<int>(
              valueListenable: game.player.foodEatenNotifier,
              builder: (context, count, child) {
                // Progress towards level goal
                final foodToWin = game.currentLevelConfig.foodToWin;
                final progress = (count / foodToWin).clamp(0.0, 1.0);

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Level Progress Bar
                    Container(
                      width: 180,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white24, width: 2),
                      ),
                      child: Stack(
                        children: [
                          // Fill
                          FractionallySizedBox(
                            widthFactor: progress,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.tealAccent, Colors.greenAccent],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          // Text Overlay
                          Center(
                            child: Text(
                              '$count / $foodToWin',
                              style: const TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Level Name
                    Text(
                      game.currentLevelConfig.name,
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 14,
                        color: Colors.white70,
                        shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          
          // Pause Button (Top Right)
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () {
                game.pauseGame();
              },
              child: Image.asset(
                'assets/images/btn_pause.png',
                width: 50,
                height: 50,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(int level) {
    switch (level) {
      // Zone 1: Beginner Waters (cool, inviting colors)
      case 1:
        return Colors.teal;
      case 2:
        return Colors.cyan;
      case 3:
        return Colors.blue;
      case 4:
        return Colors.indigo;
      // Zone 2: Intermediate Depths (transitional colors)
      case 5:
        return Colors.deepPurple;
      case 6:
        return Colors.purple;
      case 7:
        return Colors.pink;
      // Zone 3: Expert Currents (warm, intense colors)
      case 8:
        return Colors.deepOrange;
      case 9:
        return Colors.orange;
      case 10:
        return Colors.amber;
      // Zone 4: Master Challenge (prestigious gold)
      case 11:
        return const Color(0xFFFFD700); // Gold
      default:
        return Colors.teal;
    }
  }
}

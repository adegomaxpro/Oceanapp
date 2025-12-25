import 'package:flutter/material.dart';
import '../game/aqua_path_game.dart';
import '../models/level_config.dart';

class GameOverMenu extends StatelessWidget {
  final AquaPathGame game;
  final bool isWin;

  const GameOverMenu({super.key, required this.game, this.isWin = false});

  @override
  Widget build(BuildContext context) {
    final hasNextLevel = game.currentLevel < LevelConfig.totalLevels;
    
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.5),
      body: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isWin
                  ? [Colors.teal.shade800, Colors.teal.shade900]
                  : [Colors.red.shade900, Colors.grey.shade900],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isWin ? Colors.tealAccent : Colors.redAccent,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                isWin ? 'LEVEL CLEARED!' : 'GAME OVER',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 28,
                  color: isWin ? Colors.greenAccent : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  shadows: const [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Level Info
              Text(
                'Level ${game.currentLevel}: ${game.currentLevelConfig.name}',
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Score
              ValueListenableBuilder<int>(
                valueListenable: game.player.foodEatenNotifier,
                builder: (context, count, child) {
                  final goal = game.currentLevelConfig.foodToWin;
                  return Column(
                    children: [
                      Text(
                        'Score: $count / $goal',
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                      if (isWin) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade700,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/images/currency_shells.png',
                                width: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '+${count + game.currentLevel * 10}',
                                style: const TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
              
              const SizedBox(height: 30),
              
              // Next Level Button (only if won and has more levels)
              if (isWin && hasNextLevel) ...[
                GestureDetector(
                  onTap: () {
                    game.nextLevel();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade500, Colors.green.shade700],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.greenAccent, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'NEXT LEVEL',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: Colors.white),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // All Levels Complete Message
              if (isWin && !hasNextLevel) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.emoji_events, color: Colors.amber, size: 28),
                      SizedBox(width: 8),
                      Text(
                        'ALL LEVELS COMPLETE!',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 14,
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Restart and Home row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      game.resetGame();
                    },
                    child: Image.asset(
                      'assets/images/btn_restart.png',
                      width: 70,
                    ),
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: () {
                      game.returnToMenu();
                    },
                    child: Image.asset(
                      'assets/images/btn_home.png',
                      width: 70,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


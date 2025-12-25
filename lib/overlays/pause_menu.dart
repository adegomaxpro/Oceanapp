import 'package:flutter/material.dart';
import '../game/aqua_path_game.dart';

class PauseMenu extends StatelessWidget {
  final AquaPathGame game;

  const PauseMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.5),
      body: Center(
        child: Container(
          width: 300,
          height: 400,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/panel_wooden_board.png'),
              fit: BoxFit.contain,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'PAUSED',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 32,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              // Resume
              GestureDetector(
                onTap: () {
                  game.resumeGame();
                },
                child: Image.asset(
                  'assets/images/btn_play.png', // Reusing play button for resume
                  width: 100,
                ),
              ),
              const SizedBox(height: 20),
              
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
                      width: 60,
                    ),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      game.returnToMenu();
                    },
                    child: Image.asset(
                      'assets/images/btn_home.png',
                      width: 60,
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


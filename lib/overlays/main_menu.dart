import 'dart:math';
import 'package:flutter/material.dart';
import '../game/aqua_path_game.dart';

class MainMenu extends StatefulWidget {
  final AquaPathGame game;

  const MainMenu({super.key, required this.game});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  int _fishCount = 0;
  final List<Offset> _fishPositions = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final count = await widget.game.localStorage.getFishCount();
    setState(() {
      _fishCount = count;
      _generateFishPositions();
    });
  }

  void _generateFishPositions() {
    _fishPositions.clear();
    // Cap visual fish to avoid clutter, e.g., 20
    final int visualCount = _fishCount > 20 ? 20 : _fishCount;
    
    for (int i = 0; i < visualCount; i++) {
      // Random positions within screen bounds (assuming standard mobile portrait/landscape)
      // Since we don't have exact screen size in initState, we'll use LayoutBuilder in build
      // or just random values 0.0-1.0 and multiply by constraints.
      _fishPositions.add(Offset(_random.nextDouble(), _random.nextDouble()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_reef_sanctuary.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // Render Saved Fish
                ..._fishPositions.map((relativePos) {
                  return Positioned(
                    left: relativePos.dx * (constraints.maxWidth - 50),
                    top: relativePos.dy * (constraints.maxHeight - 50),
                    child: Image.asset(
                      'assets/images/fish_clownfish.png', // Or random fish type
                      width: 40,
                      color: Colors.white.withValues(alpha: 0.8), // Slight tint or just normal
                      colorBlendMode: BlendMode.modulate,
                    ),
                  );
                }),

                // UI Overlay
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Image.asset(
                        'assets/images/logo.png',
                        width: 300,
                      ),
                      const SizedBox(height: 50),
                      
                      // Play Button
                      GestureDetector(
                        onTap: () {
                          widget.game.startGame();
                        },
                        child: Image.asset(
                          'assets/images/btn_play.png',
                          width: 150,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Other buttons (Row)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildMenuButton('assets/images/btn_fish_collection.png', () {
                            widget.game.openFishCollection();
                          }),
                          const SizedBox(width: 20),
                          _buildMenuButton('assets/images/btn_store.png', () {
                            widget.game.openStore();
                          }),
                          const SizedBox(width: 20),
                          _buildMenuButton('assets/images/btn_settings.png', () {
                            widget.game.openSettings();
                          }),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      // Display Fish Count Text
                      Text(
                        'Fish Saved: $_fishCount',
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 20,
                          color: Colors.white,
                          shadows: [
                             Shadow(
                              blurRadius: 4,
                              color: Colors.black,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenuButton(String assetPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(
        assetPath,
        width: 60,
      ),
    );
  }
}

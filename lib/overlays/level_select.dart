import 'package:flutter/material.dart';
import '../game/aqua_path_game.dart';
import '../models/level_config.dart';

class LevelSelect extends StatefulWidget {
  final AquaPathGame game;

  const LevelSelect({super.key, required this.game});

  @override
  State<LevelSelect> createState() => _LevelSelectState();
}

class _LevelSelectState extends State<LevelSelect> {
  int _highestUnlocked = 1;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final highest = await widget.game.localStorage.getHighestLevel();
    setState(() {
      _highestUnlocked = highest;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D3B66),
              Color(0xFF14213D),
              Color(0xFF000814),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        widget.game.playButtonSound();
                        widget.game.closeLevelSelect();
                      },
                      child: Image.asset(
                        'assets/images/btn_home.png',
                        width: 50,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'SELECT LEVEL',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 8,
                              color: Colors.black,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 50),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Level Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    itemCount: LevelConfig.totalLevels,
                    itemBuilder: (context, index) {
                      final level = LevelConfig.levels[index];
                      final isUnlocked = level.levelNumber <= _highestUnlocked;
                      return _buildLevelCard(level, isUnlocked);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard(LevelConfig level, bool isUnlocked) {
    return GestureDetector(
      onTap: isUnlocked
          ? () {
              widget.game.playButtonSound();
              widget.game.startLevel(level.levelNumber);
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUnlocked ? _getLevelColor(level.levelNumber) : Colors.grey.shade700,
            width: 3,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: _getLevelColor(level.levelNumber).withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              Image.asset(
                'assets/images/${level.backgroundAsset}',
                fit: BoxFit.cover,
                color: isUnlocked ? null : Colors.black54,
                colorBlendMode: isUnlocked ? null : BlendMode.darken,
              ),

              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Level Number Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? _getLevelColor(level.levelNumber)
                            : Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Level ${level.levelNumber}',
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Level Name
                    Text(
                      level.name,
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 18,
                        color: isUnlocked ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold,
                        shadows: const [
                          Shadow(color: Colors.black, blurRadius: 4),
                        ],
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Difficulty Indicator (5 stars max, based on difficulty tier)
                    Row(
                      children: [
                        ...List.generate(5, (i) {
                          // Map 11 levels to 5 difficulty tiers:
                          // Levels 1-2: 1 star, 3-4: 2 stars, 5-6: 3 stars, 7-8: 4 stars, 9-11: 5 stars
                          final difficultyTier = ((level.levelNumber + 1) / 2.2).ceil().clamp(1, 5);
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              i < difficultyTier ? Icons.star : Icons.star_border,
                              size: 16,
                              color: isUnlocked
                                  ? (i < difficultyTier ? Colors.amber : Colors.white54)
                                  : Colors.grey,
                            ),
                          );
                        }),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Stats Row
                    if (isUnlocked)
                      Row(
                        children: [
                          _buildStatChip(
                            Icons.speed,
                            '${level.baseSpeed.toInt()}',
                            Colors.cyan,
                          ),
                          const SizedBox(width: 8),
                          _buildStatChip(
                            Icons.restaurant,
                            '${level.foodToWin}',
                            Colors.green,
                          ),
                        ],
                      ),

                    // Lock Icon
                    if (!isUnlocked)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey, width: 2),
                          ),
                          child: const Icon(
                            Icons.lock,
                            color: Colors.grey,
                            size: 28,
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
    );
  }

  Widget _buildStatChip(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(int levelNumber) {
    switch (levelNumber) {
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


/// Configuration for each game level
class LevelConfig {
  final int levelNumber;
  final String name;
  final String backgroundAsset;
  final double baseSpeed;
  final double spawnInterval; // seconds between obstacle spawns
  final double hazardChance; // 0.0 to 1.0
  final int foodToWin;
  final double speedIncrement; // speed increase per 10 seconds

  const LevelConfig({
    required this.levelNumber,
    required this.name,
    required this.backgroundAsset,
    required this.baseSpeed,
    required this.spawnInterval,
    required this.hazardChance,
    required this.foodToWin,
    this.speedIncrement = 5.0,
  });

  /// All available levels in the game
  static const List<LevelConfig> levels = [
    // --- Zone 1: Beginner Waters (Levels 1-4) ---
    LevelConfig(
      levelNumber: 1,
      name: 'Reef Sanctuary',
      backgroundAsset: 'background_reef_sanctuary.png',
      baseSpeed: 80.0,
      spawnInterval: 2.5,
      hazardChance: 0.20,
      foodToWin: 20,
      speedIncrement: 3.0,
    ),
    LevelConfig(
      levelNumber: 2,
      name: 'Mid Waters',
      backgroundAsset: 'background_mid_water.png',
      baseSpeed: 100.0,
      spawnInterval: 2.0,
      hazardChance: 0.30,
      foodToWin: 25,
      speedIncrement: 4.0,
    ),
    LevelConfig(
      levelNumber: 3,
      name: 'Deep Ocean',
      backgroundAsset: 'background_deep_ocean.png',
      baseSpeed: 130.0,
      spawnInterval: 1.5,
      hazardChance: 0.40,
      foodToWin: 30,
      speedIncrement: 5.0,
    ),
    LevelConfig(
      levelNumber: 4,
      name: 'Ocean Floor',
      backgroundAsset: 'background_seabed.png',
      baseSpeed: 160.0,
      spawnInterval: 1.2,
      hazardChance: 0.50,
      foodToWin: 35,
      speedIncrement: 6.0,
    ),
    // --- Zone 2: Intermediate Depths (Levels 5-7) ---
    LevelConfig(
      levelNumber: 5,
      name: 'Coral Gardens',
      backgroundAsset: 'background_reef_sanctuary.png',
      baseSpeed: 190.0,
      spawnInterval: 1.0,
      hazardChance: 0.55,
      foodToWin: 40,
      speedIncrement: 7.0,
    ),
    LevelConfig(
      levelNumber: 6,
      name: 'Twilight Zone',
      backgroundAsset: 'background_mid_water.png',
      baseSpeed: 215.0,
      spawnInterval: 0.9,
      hazardChance: 0.58,
      foodToWin: 45,
      speedIncrement: 7.5,
    ),
    LevelConfig(
      levelNumber: 7,
      name: 'Abyss Edge',
      backgroundAsset: 'background_deep_ocean.png',
      baseSpeed: 240.0,
      spawnInterval: 0.8,
      hazardChance: 0.62,
      foodToWin: 50,
      speedIncrement: 8.0,
    ),
    // --- Zone 3: Expert Currents (Levels 8-10) ---
    LevelConfig(
      levelNumber: 8,
      name: 'Volcanic Vents',
      backgroundAsset: 'background_seabed.png',
      baseSpeed: 260.0,
      spawnInterval: 0.75,
      hazardChance: 0.65,
      foodToWin: 55,
      speedIncrement: 8.5,
    ),
    LevelConfig(
      levelNumber: 9,
      name: 'Shipwreck Reef',
      backgroundAsset: 'background_reef_sanctuary.png',
      baseSpeed: 280.0,
      spawnInterval: 0.7,
      hazardChance: 0.68,
      foodToWin: 60,
      speedIncrement: 9.0,
    ),
    LevelConfig(
      levelNumber: 10,
      name: 'Stormy Currents',
      backgroundAsset: 'background_mid_water.png',
      baseSpeed: 300.0,
      spawnInterval: 0.65,
      hazardChance: 0.70,
      foodToWin: 65,
      speedIncrement: 9.5,
    ),
    // --- Zone 4: Master Challenge (Level 11) ---
    LevelConfig(
      levelNumber: 11,
      name: 'The Final Depths',
      backgroundAsset: 'background_deep_ocean.png',
      baseSpeed: 320.0,
      spawnInterval: 0.6,
      hazardChance: 0.72,
      foodToWin: 70,
      speedIncrement: 10.0,
    ),
  ];

  /// Get level config by level number (1-indexed)
  static LevelConfig getLevel(int levelNumber) {
    final index = (levelNumber - 1).clamp(0, levels.length - 1);
    return levels[index];
  }

  /// Total number of levels
  static int get totalLevels => levels.length;
}


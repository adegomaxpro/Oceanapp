import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/timer.dart';
import 'package:flame_audio/flame_audio.dart';
import '../components/world_background.dart';
import '../components/fish_player.dart';
import '../components/obstacle_manager.dart';
import '../components/obstacles.dart';
import '../services/local_storage.dart';
import '../models/level_config.dart';

class AquaPathGame extends FlameGame with PanDetector, HasCollisionDetection {
  late final FishPlayer player;
  late final WorldBackground background;
  late final ObstacleManager obstacleManager;
  final LocalStorage localStorage = LocalStorage();
  
  // Level System
  int currentLevel = 1;
  LevelConfig get currentLevelConfig => LevelConfig.getLevel(currentLevel);
  
  // Difficulty Scaling
  double gameSpeed = 100.0;
  late Timer _speedTimer;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Audio Setup
    FlameAudio.bgm.initialize();
    await FlameAudio.audioCache.loadAll([
      'bgsong.mp3',
      'bloop.wav',
      'buttonClick.wav',
      'levelUp.wav',
      'thud.wav',
      'win.wav',
      'gameover.wav',
    ]);

    // Add background first so it renders behind
    background = WorldBackground();
    add(background);

    // Add player
    player = FishPlayer();
    add(player);

    // Add Obstacle Manager
    obstacleManager = ObstacleManager();
    add(obstacleManager);
    
    // Initialize Speed Timer (Increase speed based on level config)
    _speedTimer = Timer(10.0, repeat: true, onTick: () {
      gameSpeed += currentLevelConfig.speedIncrement;
    });
    
    // Start in Menu
    pauseEngine();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _speedTimer.update(dt);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    // Pass the vertical delta to the player
    player.moveY(info.delta.global.y);
  }
  
  // Lifecycle Management for Audio
  @override
  void onDetach() {
    FlameAudio.bgm.stop();
    FlameAudio.bgm.dispose();
    super.onDetach();
  }
  
  void playButtonSound() {
    FlameAudio.play('buttonClick.wav');
  }

  // Start game from main menu (defaults to level 1)
  void startGame() {
    playButtonSound();
    overlays.remove('MainMenu');
    openLevelSelect();
  }

  // Start a specific level
  void startLevel(int level) async {
    currentLevel = level;
    await localStorage.saveCurrentLevel(level);
    
    // Apply level configuration
    gameSpeed = currentLevelConfig.baseSpeed;
    obstacleManager.updateSpawnInterval(currentLevelConfig.spawnInterval);
    await background.setLevelBackground(currentLevelConfig.backgroundAsset);
    
    overlays.remove('LevelSelect');
    overlays.add('HUD');
    resetGame();
  }

  void pauseGame() {
    playButtonSound();
    pauseEngine();
    FlameAudio.bgm.pause();
    overlays.add('PauseMenu');
  }

  void resumeGame() {
    playButtonSound();
    overlays.remove('PauseMenu');
    FlameAudio.bgm.resume();
    resumeEngine();
  }

  void gameOver() {
    pauseEngine();
    FlameAudio.bgm.stop();
    overlays.add('GameOverMenu');
    overlays.remove('HUD');
    _saveData(levelCompleted: false);
  }

  void levelComplete() async {
    pauseEngine();
    FlameAudio.bgm.stop();
    
    // Unlock next level
    final nextLevel = currentLevel + 1;
    if (nextLevel <= LevelConfig.totalLevels) {
      await localStorage.saveHighestLevel(nextLevel);
    }
    
    overlays.add('WinMenu');
    overlays.remove('HUD');
    await _saveData(levelCompleted: true);
    FlameAudio.play('win.wav');
  }

  /// Check if player has reached the food goal for current level
  void checkLevelProgress() {
    if (player.foodEaten >= currentLevelConfig.foodToWin) {
      levelComplete();
    }
  }

  Future<void> _saveData({required bool levelCompleted}) async {
    // Save shells (currency) based on food eaten
    // Bonus shells for completing level
    int shellsEarned = player.foodEaten;
    if (levelCompleted) {
      shellsEarned += currentLevel * 10; // Bonus for completing level
    }
    
    int currentShells = await localStorage.getShells();
    await localStorage.saveShells(currentShells + shellsEarned);
    
    // Save fish count if evolved to Blue Tang
    if (player.evolution == FishEvolution.blueTang) {
      int currentFish = await localStorage.getFishCount();
      await localStorage.saveFishCount(currentFish + 1);
    }
  }

  void resetGame() {
    player.reset();
    
    // Reset Speed to level's base speed
    gameSpeed = currentLevelConfig.baseSpeed;
    _speedTimer.stop();
    _speedTimer.start();
    
    // Remove all obstacles
    children.whereType<Obstacle>().forEach((obstacle) {
      obstacle.removeFromParent();
    });
    
    overlays.remove('GameOverMenu');
    overlays.remove('WinMenu');
    overlays.remove('PauseMenu');
    
    if (!overlays.isActive('HUD')) {
      overlays.add('HUD');
    }
    
    resumeEngine();
    FlameAudio.bgm.play('bgsong.mp3', volume: 0.5);
  }
  
  void returnToMenu() {
    playButtonSound();
    overlays.remove('GameOverMenu');
    overlays.remove('WinMenu');
    overlays.remove('PauseMenu');
    overlays.remove('HUD');
    overlays.remove('LevelSelect');
    overlays.add('MainMenu');
    FlameAudio.bgm.stop();
    pauseEngine();
  }

  // Go to next level after winning
  void nextLevel() async {
    playButtonSound();
    final next = currentLevel + 1;
    if (next <= LevelConfig.totalLevels) {
      overlays.remove('WinMenu');
      startLevel(next);
    } else {
      // All levels complete - return to menu
      returnToMenu();
    }
  }

  // Navigation to Level Select
  void openLevelSelect() {
    playButtonSound();
    overlays.remove('MainMenu');
    overlays.add('LevelSelect');
  }

  void closeLevelSelect() {
    overlays.remove('LevelSelect');
    overlays.add('MainMenu');
  }

  // Navigation to Fish Collection
  void openFishCollection() {
    playButtonSound();
    overlays.add('FishCollection');
  }

  void closeFishCollection() {
    overlays.remove('FishCollection');
  }

  // Navigation to Store
  void openStore() {
    playButtonSound();
    overlays.add('Store');
  }

  void closeStore() {
    overlays.remove('Store');
  }

  // Navigation to Settings
  void openSettings() {
    playButtonSound();
    overlays.add('Settings');
  }

  void closeSettings() {
    overlays.remove('Settings');
  }
}

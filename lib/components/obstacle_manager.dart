import 'dart:math';
import 'package:flame/components.dart';
import '../game/aqua_path_game.dart';
import 'obstacles.dart';

class ObstacleManager extends Component with HasGameReference<AquaPathGame> {
  final Random _random = Random();
  late Timer _spawnTimer;
  double _spawnInterval = 2.0;

  @override
  Future<void> onLoad() async {
    _spawnTimer = Timer(_spawnInterval, repeat: true, onTick: _onTick);
    _spawnTimer.start();
  }

  @override
  void update(double dt) {
    _spawnTimer.update(dt);
  }

  /// Update spawn interval based on level config
  void updateSpawnInterval(double interval) {
    _spawnInterval = interval;
    _spawnTimer.stop();
    _spawnTimer = Timer(_spawnInterval, repeat: true, onTick: _onTick);
    _spawnTimer.start();
  }

  void _onTick() {
    // Use hazard chance from current level config
    final hazardChance = game.currentLevelConfig.hazardChance;
    
    if (_random.nextDouble() >= hazardChance) {
      _spawnFood();
    } else {
      _spawnHazard();
    }
  }

  void _spawnFood() {
    final food = Food(speed: game.gameSpeed); 
    _positionObstacle(food);
    game.add(food);
  }

  void _spawnHazard() {
    final hazardAssets = [
      'obstacle_fishing_net.png',
      'obstacle_plastic_bottle.png',
      'obstacle_plastic_bag.png',
      'obstacle_six_pack_rings.png',
      'obstacle_oil_spill.png',
      'obstacle_algae_pollution.png',
    ];
    final asset = hazardAssets[_random.nextInt(hazardAssets.length)];
    
    final hazard = Hazard(speed: game.gameSpeed, assetName: asset);
    _positionObstacle(hazard);
    game.add(hazard);
  }

  void _positionObstacle(PositionComponent obstacle) {
    // Top, Center, or Bottom lanes roughly
    // Game height is flexible, so we use relative positioning.
    // 25%, 50%, 75% of screen height
    final lane = _random.nextInt(3);
    double yPos;
    switch (lane) {
      case 0:
        yPos = game.size.y * 0.25;
        break;
      case 1:
        yPos = game.size.y * 0.5;
        break;
      case 2:
      default:
        yPos = game.size.y * 0.75;
        break;
    }

    obstacle.position = Vector2(game.size.x + 50, yPos);
  }
}


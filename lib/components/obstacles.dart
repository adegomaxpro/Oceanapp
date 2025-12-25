import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import '../game/aqua_path_game.dart';

import '../components/fish_player.dart'; // For FishEvolution enum

abstract class Obstacle extends SpriteComponent
    with HasGameReference<AquaPathGame>, CollisionCallbacks {
  final double speed;
  // Define obstacle size tier for immunity logic
  // 0: Small (Harmless to Medium+)
  // 1: Medium (Harmless to Large+)
  // 2: Large (Dangerous to all)
  final int threatLevel;

  Obstacle({required this.speed, this.threatLevel = 2})
    : super(anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    // Move using current speed, but since 'speed' was set at initialization in previous code,
    // we should consider if we want dynamic update.
    // However, Plan says "Pass this speed variable to the ObstacleManager so objects move faster over time."
    // This implies newly spawned objects get the new speed.
    // If we want EXISTING objects to speed up, we should use game.gameSpeed here.
    // Let's stick to what was passed in constructor for consistency with standard runners,
    // OR use game.gameSpeed if we want global acceleration.
    // The implementation in ObstacleManager passes 'game.gameSpeed' to the constructor.
    // So new objects will be faster. Existing objects will stay at their spawn speed unless we change this.
    // Let's keep it simple: spawn speed determines speed for that object's life.
    // BUT, if the user wants "objects move faster over time", usually in endless runners EVERYTHING speeds up.
    // Let's use game.gameSpeed to drive the movement if we want global sync.
    // But 'speed' is final. Let's rely on ObstacleManager spawning faster ones.
    // Wait, the Phase 4 text: "Pass this speed variable to the ObstacleManager so objects move faster over time."
    // This suggests ObstacleManager sets the speed.
    // So `x -= speed * dt` is correct if `speed` is set from `game.gameSpeed` at spawn.

    // UPDATE: User requested "increase the speed and obstacle" as levels increase/time passes.
    // To ensure ALL obstacles speed up (even existing ones), we should use game.gameSpeed directly.
    x -= game.gameSpeed * dt;

    if (x < -width) {
      removeFromParent();
    }
  }
}

class Food extends Obstacle {
  Food({required super.speed}) : super(threatLevel: 0);

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite('food_bubbles.png');
    size = Vector2.all(40);
    add(CircleHitbox());
  }
}

class Hazard extends Obstacle {
  final String assetName;

  Hazard({required super.speed, required this.assetName})
    : super(threatLevel: _determineThreatLevel(assetName));

  static int _determineThreatLevel(String assetName) {
    if (assetName.contains('bottle') || assetName.contains('can')) {
      return 0; // Small
    } else if (assetName.contains('plastic_bag') ||
        assetName.contains('six_pack')) {
      return 1; // Medium
    } else {
      return 2; // Nets, Oil spills, etc. (Large)
    }
  }

  bool canHarm(FishEvolution evolution) {
    // Evolution 0 (Clownfish) -> harmed by Level 0, 1, 2
    // Evolution 1 (Teal) -> harmed by Level 1, 2
    // Evolution 2 (Blue Tang) -> harmed by Level 2

    int fishLevel = 0;
    switch (evolution) {
      case FishEvolution.clownfish:
        fishLevel = 0;
        break;
      case FishEvolution.tealFish:
        fishLevel = 1;
        break;
      case FishEvolution.blueTang:
        fishLevel = 2;
        break;
    }

    return threatLevel >= fishLevel;
  }

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite(assetName);
    // Hazards might have different sizes, but for now we'll standardize or pass it in
    // Based on asset list, they seem to be various rubbish items.
    // Let's set a default size for hazards, potentially adjustable.
    size = Vector2(60, 60);
    add(RectangleHitbox());
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flame_audio/flame_audio.dart';
import '../game/aqua_path_game.dart';
import 'obstacles.dart';

enum FishEvolution { clownfish, tealFish, blueTang }

class FishPlayer extends SpriteComponent
    with HasGameReference<AquaPathGame>, CollisionCallbacks {
  FishEvolution evolution = FishEvolution.clownfish;

  // Growth Logic
  final ValueNotifier<int> foodEatenNotifier = ValueNotifier<int>(0);
  int get foodEaten => foodEatenNotifier.value;

  // Sprites
  late final Sprite clownfishSprite;
  late final Sprite tealFishSprite;
  late final Sprite blueTangSprite;

  // Swimming animation
  double _swimTime = 0;
  double _baseY = 0;
  static const double _swimFrequency = 3.0; // Oscillation speed
  static const double _swimAmplitude = 2.5; // Vertical sway amount
  static const double _rotationAmplitude = 0.04; // Subtle body wiggle (radians)

  FishPlayer() : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Load all sprites upfront
    clownfishSprite = await game.loadSprite('fish_clownfish.png');
    tealFishSprite = await game.loadSprite('fish_teal.png');
    blueTangSprite = await game.loadSprite('fish_blue_tang.png');

    // Set initial state
    setEvolution(FishEvolution.clownfish);

    // Initial position (center-left)
    position = Vector2(game.size.x * 0.2, game.size.y / 2);
    _baseY = position.y;

    // Collision
    add(CircleHitbox());
  }

  void setEvolution(FishEvolution newEvolution) {
    evolution = newEvolution;
    switch (evolution) {
      case FishEvolution.clownfish:
        sprite = clownfishSprite;
        size = Vector2(
          60,
          45,
        ); // Adjust size as needed based on asset aspect ratio
        break;
      case FishEvolution.tealFish:
        sprite = tealFishSprite;
        size = Vector2(80, 60);
        break;
      case FishEvolution.blueTang:
        sprite = blueTangSprite;
        size = Vector2(100, 75);
        break;
    }
    // Ensure sprite faces right after changing sprite
    // Only flip if not already facing right (isFlippedHorizontally means facing right)
    if (isMounted && !isFlippedHorizontally) {
      flipHorizontally();
    }
  }

  @override
  void onMount() {
    super.onMount();
    // Ensure initial flip if needed
    if (!isFlippedHorizontally) {
      flipHorizontally();
    }
  }

  void reset() {
    foodEatenNotifier.value = 0;
    setEvolution(FishEvolution.clownfish);
    position = Vector2(game.size.x * 0.2, game.size.y / 2);
    _baseY = position.y;
    _swimTime = 0;
    angle = 0;
  }

  void moveY(double deltaY) {
    _baseY += deltaY;
    position.y = _baseY;
    clampPosition();
    _baseY = position.y; // Update base after clamping
  }

  void clampPosition() {
    // Clamp Y to screen bounds, keeping the fish fully visible
    final halfHeight = size.y / 2;
    position.y = position.y.clamp(halfHeight, game.size.y - halfHeight);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Re-clamp if screen resizes
    if (isMounted) {
      clampPosition();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Swimming animation - subtle wiggle effect
    _swimTime += dt;

    // Body rotation wiggle (like a whale fish swimming)
    angle = math.sin(_swimTime * _swimFrequency * 1.5) * _rotationAmplitude;

    // Subtle vertical bob
    final verticalOffset =
        math.sin(_swimTime * _swimFrequency) * _swimAmplitude;
    position.y = _baseY + verticalOffset;

    // Keep position clamped
    clampPosition();
    _baseY = position.y - verticalOffset;
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Food) {
      grow();
      other.removeFromParent();
      FlameAudio.play('bloop.wav');
      _spawnEatParticles();
    } else if (other is Hazard) {
      // Size-based immunity:
      // Clownfish (Evolution 0) - vulnerable to everything
      // TealFish (Evolution 1) - vulnerable to big hazards only?
      // Blue Tang (Evolution 2) - vulnerable to even bigger?

      // User requirement: "smaller obstacles like bottles might not affect larger fish"
      // Let's implement a simple check.
      if (other.canHarm(evolution)) {
        takeDamage();
        game.gameOver();
        FlameAudio.play('gameover.wav');
      } else {
        // Harmless collision (maybe just bounce or ignore)
        // Visual feedback that it didn't hurt?
      }
    }
  }

  void _spawnEatParticles() {
    final random = math.Random();

    // Position slightly offset to mouth area (right side of fish)
    final spawnPos = position + Vector2(size.x / 2, 0);

    // Primary sparkle particles - white/yellow burst
    final sparkleCount = 8 + random.nextInt(5);
    game.add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: sparkleCount,
          lifespan: 0.6,
          generator: (i) {
            final angle = (i / sparkleCount) * math.pi * 2;
            final speed = 80.0 + random.nextDouble() * 60;
            return AcceleratedParticle(
              acceleration: Vector2(0, 50), // Slight downward drift
              speed: Vector2(math.cos(angle) * speed, math.sin(angle) * speed),
              position: spawnPos.clone(),
              child: ScalingParticle(
                lifespan: 0.6,
                to: 0,
                child: CircleParticle(
                  radius: 3 + random.nextDouble() * 2,
                  paint: Paint()
                    ..color = Color.lerp(
                      Colors.white,
                      Colors.yellowAccent,
                      random.nextDouble() * 0.5,
                    )!.withValues(alpha: 0.9),
                ),
              ),
            );
          },
        ),
      ),
    );

    // Secondary bubble particles - small floating bubbles
    final bubbleCount = 4 + random.nextInt(3);
    game.add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: bubbleCount,
          lifespan: 0.8,
          generator: (i) {
            final offsetX = (random.nextDouble() - 0.5) * 30;
            final offsetY = (random.nextDouble() - 0.5) * 20;
            return AcceleratedParticle(
              acceleration: Vector2(0, -60), // Float upward
              speed: Vector2(offsetX, -30 - random.nextDouble() * 40),
              position: spawnPos.clone() + Vector2(offsetX, offsetY),
              child: ScalingParticle(
                lifespan: 0.8,
                to: 0.3,
                child: CircleParticle(
                  radius: 4 + random.nextDouble() * 3,
                  paint: Paint()
                    ..color = Colors.lightBlueAccent.withValues(alpha: 0.6)
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 1.5,
                ),
              ),
            );
          },
        ),
      ),
    );

    // Quick "munch" scale effect on fish
    _triggerEatPulse();
  }

  void _triggerEatPulse() {
    // Quick scale pulse animation
    final originalSize = size.clone();
    final pulseSize = originalSize * 1.15;

    // Scale up
    size = pulseSize;

    // Schedule scale back down
    Future.delayed(const Duration(milliseconds: 80), () {
      if (isMounted) {
        size = originalSize;
      }
    });
  }

  void grow() {
    foodEatenNotifier.value++;

    // Evolution Thresholds:
    // 0-5: Clownfish
    // 6-15: Teal Fish
    // 16+: Blue Tang
    if (foodEaten == 6) {
      setEvolution(FishEvolution.tealFish);
      FlameAudio.play('levelUp.wav');
    } else if (foodEaten == 16) {
      setEvolution(FishEvolution.blueTang);
      FlameAudio.play('levelUp.wav');
    }

    // Check if level goal is reached (based on current level config)
    game.checkLevelProgress();
  }

  void takeDamage() {
    // Placeholder for visual feedback or health reduction
  }
}

import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/widgets.dart';
import '../game/aqua_path_game.dart';

class WorldBackground extends ParallaxComponent<AquaPathGame> {
  String _currentBackground = 'background_reef_sanctuary.png';

  @override
  Future<void> onLoad() async {
    await _loadBackground(_currentBackground);
  }

  Future<void> _loadBackground(String backgroundAsset) async {
    parallax = await game.loadParallax(
      [
        ParallaxImageData(backgroundAsset),
      ],
      baseVelocity: Vector2(30, 0),
      repeat: ImageRepeat.repeat,
    );
  }

  /// Change background for a specific level
  Future<void> setLevelBackground(String backgroundAsset) async {
    if (_currentBackground != backgroundAsset) {
      _currentBackground = backgroundAsset;
      await _loadBackground(backgroundAsset);
    }
  }
}


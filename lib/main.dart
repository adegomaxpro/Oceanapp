import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/aqua_path_game.dart';
import 'overlays/main_menu.dart';
import 'overlays/hud.dart';
import 'overlays/pause_menu.dart';
import 'overlays/game_over_menu.dart';
import 'overlays/fish_collection.dart';
import 'overlays/store.dart';
import 'overlays/settings.dart';
import 'overlays/level_select.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Ocean',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Fredoka',
      ),
      home: GameWidget(
        game: AquaPathGame(),
        overlayBuilderMap: {
          'MainMenu': (BuildContext context, AquaPathGame game) => MainMenu(game: game),
          'HUD': (BuildContext context, AquaPathGame game) => HUD(game: game),
          'PauseMenu': (BuildContext context, AquaPathGame game) => PauseMenu(game: game),
          'GameOverMenu': (BuildContext context, AquaPathGame game) => GameOverMenu(game: game, isWin: false),
          'WinMenu': (BuildContext context, AquaPathGame game) => GameOverMenu(game: game, isWin: true),
          'FishCollection': (BuildContext context, AquaPathGame game) => FishCollection(game: game),
          'Store': (BuildContext context, AquaPathGame game) => Store(game: game),
          'Settings': (BuildContext context, AquaPathGame game) => Settings(game: game),
          'LevelSelect': (BuildContext context, AquaPathGame game) => LevelSelect(game: game),
        },
        initialActiveOverlays: const ['MainMenu'],
      ),
    ),
  );
}

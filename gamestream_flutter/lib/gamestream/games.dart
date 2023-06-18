
import 'package:gamestream_flutter/gamestream/games/capture_the_flag/capture_the_flag_game.dart';
import 'package:gamestream_flutter/gamestream/games/survival/survival_game.dart';

import 'games/game_cube3d.dart';
import 'games/fight2d/game_fight2d.dart';
import 'games/website/game_website.dart';
import 'games/isometric/game_isometric.dart';
import 'gamestream.dart';

class Games {
  late final GameIsometric isometric;
  late final fight2D = GameFight2D();
  late final cube3D = GameCube3D();
  late final website = GameWebsite();
  late final GameIsometric isometricEditor;
  late final CaptureTheFlagGame captureTheFlag;
  late final SurvivalGame survival;

  Games(Gamestream gamestream) {
     isometric = GameIsometric(isometric: gamestream.isometric);
     captureTheFlag = CaptureTheFlagGame(gamestream: gamestream);
     isometricEditor = GameIsometric(isometric: gamestream.isometric);
     survival = SurvivalGame(isometric: gamestream.isometric);
  }
}
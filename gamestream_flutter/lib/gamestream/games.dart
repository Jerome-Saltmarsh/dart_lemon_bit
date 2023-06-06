
import 'package:gamestream_flutter/gamestream/games/capture_the_flag/capture_the_flag_game.dart';

import 'games/game_cube3d.dart';
import 'games/fight2d/game_fight2d.dart';
import 'games/website/game_website.dart';
import 'games/isometric/game_isometric.dart';

class Games {
  late final isometric = GameIsometric();
  late final fight2D = GameFight2D();
  late final cube3D = GameCube3D();
  late final website = GameWebsite();
  late final captureTheFlag = CaptureTheFlagGame();
}
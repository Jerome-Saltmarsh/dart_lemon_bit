import 'package:gamestream_flutter/game_animation.dart';
import 'package:gamestream_flutter/games/isometric/game_isometric.dart';
import 'package:gamestream_flutter/games/game_cube3d.dart';
import 'package:gamestream_flutter/games/game_fight2d.dart';
import 'package:gamestream_flutter/games/game_website.dart';

class Games {
  late final isometric = GameIsometric();
  late final gameFight2D = GameFight2D();
  late final gameCube3D = GameCube3D();
  late final gameWebsite = GameWebsite();
}
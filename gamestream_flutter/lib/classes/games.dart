import 'package:gamestream_flutter/game_animation.dart';
import 'package:gamestream_flutter/games/game_isometric.dart';
import 'package:gamestream_flutter/games/game_cube3d.dart';
import 'package:gamestream_flutter/games/game_fight2d.dart';
import 'package:gamestream_flutter/games/game_website.dart';

class Games {
  late final gameFight2D = GameFight2D();
  late final gameCube3D = GameCube3D();
  late final aeon = GameIsometric();
  late final combat = GameIsometric();
  late final animation = GameAnimation();
  late final gameWebsite = GameWebsite();
}
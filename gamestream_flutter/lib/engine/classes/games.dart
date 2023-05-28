import 'package:gamestream_flutter/engine/games/game_combat.dart';
import 'package:gamestream_flutter/engine/games/game_cube3d.dart';
import 'package:gamestream_flutter/engine/games/game_fight2d.dart';
import 'package:gamestream_flutter/engine/games/game_website.dart';
import 'package:gamestream_flutter/game_animation.dart';

class Games {
  late final gameFight2D = GameFight2D();
  late final gameCube3D = GameCube3D();
  late final animation = GameAnimation();
  late final combat = GameCombat();
  late final gameWebsite = GameWebsite();
}
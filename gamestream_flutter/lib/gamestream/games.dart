
import 'games/game_cube3d.dart';
import 'games/game_fight2d.dart';
import 'games/game_website.dart';
import 'games/isometric/game_isometric.dart';

class Games {
  late final isometric = GameIsometric();
  late final gameFight2D = GameFight2D();
  late final gameCube3D = GameCube3D();
  late final gameWebsite = GameWebsite();
}
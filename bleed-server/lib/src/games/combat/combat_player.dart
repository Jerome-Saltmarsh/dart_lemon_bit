
import 'package:bleed_server/src/games/isometric/isometric_player.dart';

import 'game_combat.dart';

class CombatPlayer extends IsometricPlayer {

  final GameCombat game;

  CombatPlayer(this.game) : super(game: game);

}
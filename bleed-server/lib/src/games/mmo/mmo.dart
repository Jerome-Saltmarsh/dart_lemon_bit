
import 'package:bleed_server/common/src.dart';
import 'package:bleed_server/src/games/mmo/MmoPlayer.dart';
import 'package:bleed_server/src/isometric/isometric_game.dart';

class Mmo extends IsometricGame<MmoPlayer> {

  Mmo({
    required super.scene,
    required super.time,
    required super.environment,
  }) : super(gameType: GameType.Mmo);

  @override
  MmoPlayer buildPlayer() => MmoPlayer(game: this)
    ..x = 100
    ..y = 100
    ..z = 50;

  @override
  int get maxPlayers => 64;

}
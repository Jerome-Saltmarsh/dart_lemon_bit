import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/classes/src/player.dart';

abstract class Game {
  var playerId = 0;
  final players = <IsometricPlayer>[];

  void update();

  /// @override
  void customPlayerWrite(IsometricPlayer player){ }

  Player createPlayer();
}


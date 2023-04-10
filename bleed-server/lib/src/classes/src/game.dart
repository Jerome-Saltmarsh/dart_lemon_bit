import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/classes/src/player.dart';

abstract class Game {
  var playerId = 0;

  void updateStatus();

  /// @override
  void customPlayerWrite(IsometricPlayer player){ }

  Player createPlayer();
}


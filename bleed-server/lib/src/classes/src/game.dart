import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/classes/src/player.dart';

abstract class Game <T extends Player> {
  var playerId = 0;
  List<T> get players;

  void update();

  /// @override
  void customPlayerWrite(IsometricPlayer player){ }

  Player createPlayer();
}


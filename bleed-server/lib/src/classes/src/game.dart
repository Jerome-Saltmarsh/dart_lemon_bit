import 'package:bleed_server/gamestream.dart';

abstract class Game {
  var playerId = 0;

  void updateStatus();

  /// @override
  void customPlayerWrite(Player player){ }
}


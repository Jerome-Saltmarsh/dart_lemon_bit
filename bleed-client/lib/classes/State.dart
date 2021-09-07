
import 'package:bleed_client/classes/Player.dart';

import 'CompiledGame.dart';
import 'Lobby.dart';

class State {
  Lobby lobby;
  List<Lobby> lobbies = [];
  Player player = Player();
  CompiledGame compiledGame = CompiledGame();
}
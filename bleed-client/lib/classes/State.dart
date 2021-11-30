
import 'package:bleed_client/classes/DeathMatch.dart';
import 'package:bleed_client/classes/Player.dart';

import 'Lobby.dart';

class State {
  Lobby lobby;
  List<Lobby> lobbies = [];
  Player player = Player();
  String lobbyGameUuid = "";
  DeathMatch deathMatch = DeathMatch();
  bool storeVisible = true;
  int serverVersion;
}
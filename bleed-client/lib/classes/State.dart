
import 'package:bleed_client/classes/DeathMatch.dart';
import 'package:bleed_client/classes/Player.dart';
import 'package:bleed_client/classes/Score.dart';
import 'package:bleed_client/common/GameState.dart';

import 'Lobby.dart';

class State {
  Lobby lobby;
  List<Lobby> lobbies = [];
  Player player = Player();
  String lobbyGameUuid = "";
  GameState gameState = GameState.InProgress;
  DeathMatch deathMatch = DeathMatch();
  bool storeVisible = true;
  List<Score> score = [];
  int serverVersion;
}
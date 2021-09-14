
import 'package:bleed_client/classes/DeathMatch.dart';
import 'package:bleed_client/classes/Player.dart';
import 'package:bleed_client/common/GameState.dart';

import 'CompiledGame.dart';
import 'Lobby.dart';

class State {
  Lobby lobby;
  List<Lobby> lobbies = [];
  Player player = Player();
  CompiledGame compiledGame = CompiledGame();
  String lobbyGameUuid = "";
  GameState gameState = GameState.InProgress;
  DeathMatch deathMatch = DeathMatch();
  bool storeVisible = false;
}
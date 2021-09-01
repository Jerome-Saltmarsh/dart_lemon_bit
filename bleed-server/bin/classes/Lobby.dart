import '../enums/GameType.dart';
import '../functions/randomUuid.dart';
import 'Game.dart';

class Lobby {
  int maxPlayers;
  GameType gameType;
  List<LobbyUser> players = [];
  Game? game;
  final String uuid = randomUuid();

  Lobby(this.maxPlayers, this.gameType);
}

class LobbyUser {
  final String uuid = randomUuid();
  int framesSinceUpdate = 0;
}
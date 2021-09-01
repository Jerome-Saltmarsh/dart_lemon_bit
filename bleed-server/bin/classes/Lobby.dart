import '../enums/GameType.dart';
import '../functions/randomUuid.dart';

class Lobby {
  int maxPlayers;
  GameType gameType;
  List<LobbyUser> players = [];
  final String uuid = randomUuid();

  Lobby(this.maxPlayers, this.gameType);
}

class LobbyUser {
  final String uuid = randomUuid();
}
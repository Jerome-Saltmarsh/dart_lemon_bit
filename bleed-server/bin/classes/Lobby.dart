import '../common/GameType.dart';
import '../functions/randomUuid.dart';
import '../settings.dart';
import 'Game.dart';

class Lobby {
  int maxPlayers;
  GameType gameType;
  List<LobbyUser> players = [];
  String? name;
  Game? game;
  bool private;
  int countDown = settings.gameStartingCountDown;
  int squadSize;
  final String uuid = randomUuid();

  bool get full => players.length >= maxPlayers;

  Lobby({
      required this.maxPlayers,
      required this.gameType,
      this.name,
      this.private = false,
      required this.squadSize
  });
}

class LobbyUser {
  final String uuid = randomUuid();
  int framesSinceUpdate = 0;
}

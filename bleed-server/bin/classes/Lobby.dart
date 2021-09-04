import '../enums/GameType.dart';
import '../functions/randomUuid.dart';
import 'Game.dart';

class Lobby {
  int maxPlayers;
  GameType gameType;
  List<LobbyUser> players = [];
  String? name;
  Game? game;
  bool private;
  final String uuid = randomUuid();

  bool get full => players.length >= maxPlayers;

  Lobby({required this.maxPlayers, required this.gameType, this.name, this.private = false});
}

class LobbyUser {
  final String uuid = randomUuid();
  int framesSinceUpdate = 0;
}
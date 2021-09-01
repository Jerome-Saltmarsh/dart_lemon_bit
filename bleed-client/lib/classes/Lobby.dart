class Lobby {
  final String uuid;
  final String playerUuid;
  int maxPlayers = 0;
  int playersJoined = 0;
  Lobby(this.uuid, this.playerUuid);
}
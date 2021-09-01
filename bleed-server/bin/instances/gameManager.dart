import '../classes/Game.dart';
import '../classes/GameManager.dart';
import '../classes/Lobby.dart';

GameManager gameManager = GameManager();

List<Game> get games => gameManager.games;

Lobby? findLobbyByUuid(String uuid){
  for (Lobby lobby in gameManager.lobbies) {
    if (lobby.uuid == uuid) return lobby;
  }
  return null;
}

void removePlayerFromLobby(Lobby lobby, String playerUuid){
  lobby.players.removeWhere((element) => element.uuid == playerUuid);
}
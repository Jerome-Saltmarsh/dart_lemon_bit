import '../classes/Game.dart';
import '../classes/GameManager.dart';
import '../classes/Lobby.dart';

GameManager gameManager = GameManager();

List<Game> get games => gameManager.games;
List<Lobby> get lobbies => gameManager.lobbies;

Lobby? findLobbyByUuid(String uuid){
  for (Lobby lobby in gameManager.lobbies) {
    if (lobby.uuid == uuid) return lobby;
  }
  return null;
}

LobbyUser? findLobbyUser(Lobby lobby, String playerUuid){
  for(LobbyUser user in lobby.players){
    if(user.uuid == playerUuid) return user;
  }
  return null;
}

void removePlayerFromLobby(Lobby lobby, String playerUuid){
  lobby.players.removeWhere((element) => element.uuid == playerUuid);
}

Game? findGameById(String id) {
  for (Game game in games) {
    if (game.id == id) {
      return game;
    }
  }
  return null;
}
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'classes/Game.dart';
import 'classes/Lobby.dart';
import 'classes/Player.dart';
import 'compile.dart';
import 'enums/ClientRequest.dart';
import 'enums/GameError.dart';
import 'enums/GameEventType.dart';
import 'enums/GameType.dart';
import 'enums/ServerResponse.dart';
import 'enums/Weapons.dart';
import 'enums.dart';
import 'functions/loadScenes.dart';
import 'instances/gameManager.dart';
import 'settings.dart';
import 'update.dart';
import 'utils.dart';

const String _space = " ";
final int errorIndex = ServerResponse.Error.index;
final StringBuffer _buffer = StringBuffer();

const List<ClientRequest> clientRequests = ClientRequest.values;
final int clientRequestsLength = clientRequests.length;

void main() {
  print('Bleed Game Server Starting');
  initUpdateLoop();
  loadScenes();

  var handler = webSocketHandler((WebSocketChannel webSocket) {
    void sendToClient(String response) {
      webSocket.sink.add(response);
    }

    void sendCompiledPlayerState(Game game, Player player) {
      _buffer.clear();
      _buffer.write(game.compiled);
      compilePlayer(_buffer, player);
      sendToClient(_buffer.toString());
    }

    void joinGame(Game game) {
      print("join game");
      _buffer.clear();
      Player player = game.spawnPlayer(name: 'test');
      compilePlayer(_buffer, player);
      compileTiles(_buffer, game.scene.tiles);
      compileBlocks(_buffer, game.scene.blocks);
      compileGame(game);
      _buffer.write(game.compiled);
      _buffer.write(
          '${ServerResponse.Player_Created.index} ${player.id} ${player.uuid} ${player.x.toInt()} ${player.y.toInt()} ; ');
      sendToClient(_buffer.toString());
    }

    void error(GameError error) {
      sendToClient('$errorIndex ${error.index}');
    }

    void errorGameNotFound() {
      error(GameError.GameNotFound);
    }

    void errorGameFull() {
      error(GameError.GameFull);
    }

    void errorInvalidArguments() {
      error(GameError.InvalidArguments);
    }

    void errorLobbyNotFound() {
      error(GameError.LobbyNotFound);
    }

    void errorLobbyUserNotFound() {
      error(GameError.LobbyUserNotFound);
    }

    void errorPlayerNotFound() {
      error(GameError.PlayerNotFound);
    }

    void errorInvalidPlayerUUID() {
      error(GameError.InvalidPlayerUUID);
    }

    void onEvent(requestD) {
      String requestString = requestD;
      List<String> arguments = requestString.split(_space);

      if (arguments.isEmpty) {
        error(GameError.ClientRequestArgumentsEmpty);
        return;
      }

      int? clientRequestInt = int.tryParse(arguments[0]);
      if (clientRequestInt == null) {
        error(GameError.ClientRequestRequired);
        return;
      }

      if (clientRequestInt >= clientRequestsLength) {
        error(GameError.UnrecognizedClientRequest);
        return;
      }

      ClientRequest request = clientRequests[clientRequestInt];

      switch (request) {
        case ClientRequest.Game_Join_Fortress:
          joinGame(gameManager.findOrCreateGameFortress());
          break;

        case ClientRequest.Game_Join_Open_World:
          Game openWorld = gameManager.getAvailableOpenWorld();
          joinGame(openWorld);
          break;

        case ClientRequest.Game_Update:
          Game? game = gameManager.findGameById(arguments[1]);
          if (game == null) {
            errorGameNotFound();
            return;
          }
          Player? player = game.findPlayerById(int.parse(arguments[2]));
          if (player == null) {
            errorPlayerNotFound();
            return;
          }
          if (arguments[3] != player.uuid) {
            errorInvalidPlayerUUID();
            return;
          }
          player.lastEventFrame = 0;
          CharacterState requestedState =
              CharacterState.values[int.parse(arguments[4])];
          Direction requestedDirection =
              Direction.values[int.parse(arguments[5])];
          double aim = double.parse(arguments[6]);
          player.aimAngle = aim;
          setDirection(player, requestedDirection);
          game.setCharacterState(player, requestedState);
          sendCompiledPlayerState(game, player);
          return;

        case ClientRequest.Player_Use_MedKit:
          Game? game = gameManager.findGameById(arguments[1]);
          if (game == null) {
            errorGameNotFound();
            return;
          }
          Player? player = game.findPlayerById(int.parse(arguments[2]));
          if (player == null) {
            errorPlayerNotFound();
            return;
          }
          if (arguments[3] != player.uuid) {
            errorInvalidPlayerUUID();
            return;
          }
          if (player.health == player.maxHealth) return;
          if (player.dead) return;
          if (player.meds <= 0) return;
          player.meds--;
          player.health = player.maxHealth;
          game.dispatch(GameEventType.Use_MedKit, player.x, player.y, 0, 0);
          break;

        case ClientRequest.Lobby_Create:

          if (arguments.length < 4) {
            errorInvalidArguments();
            return;
          }

          int maxPlayers = int.parse(arguments[1]);
          GameType gameType = GameType.values[int.parse(arguments[2])];
          String name = arguments[3];
          Lobby lobby = gameManager.createLobby(maxPlayer: maxPlayers, gameType: gameType, name: name);
          LobbyUser user = LobbyUser();
          lobby.players.add(user);
          sendToClient('${ServerResponse.Lobby_Joined.index} ${lobby.uuid} ${user.uuid}');
          return;

        case ClientRequest.Game_Join_Random:
          Game deathMatch = gameManager.getAvailableDeathMatch();
          joinGame(deathMatch);
          break;

        case ClientRequest.Ping:
          sendToClient('${ServerResponse.Pong.index} ;');
          break;

        case ClientRequest.Lobby_Join:
          LobbyUser user = LobbyUser();
          Lobby lobby = gameManager.findAvailableDeathMatchLobby();
          lobby.players.add(user);

          if (lobby.players.length == lobby.maxPlayers) {
            Game game = gameManager.createDeathMatch(maxPlayer: lobby.maxPlayers);
            lobby.game = game;
          }

          sendToClient('${ServerResponse.Lobby_Joined.index} ${lobby.uuid} ${user.uuid}');
          break;

        case ClientRequest.Game_Join:
          if (arguments.length < 2) {
            errorInvalidArguments();
            return;
          }
          String gameUuid = arguments[1];

          for (Game game in gameManager.games) {
            if (game.uuid != gameUuid) continue;
            if (game.players.length == game.maxPlayers) {
              errorGameFull();
              return;
            }
            joinGame(game);
            return;
          }

          errorGameNotFound();
          break;

        case ClientRequest.Lobby_Update:
          if (arguments.length < 3) {
            errorInvalidArguments();
            return;
          }
          String lobbyUuid = arguments[1];
          Lobby? lobby = findLobbyByUuid(lobbyUuid);
          if (lobby == null){
            errorLobbyNotFound();
            return;
          }
          String playerUuid = arguments[2];
          LobbyUser? user = findLobbyUser(lobby, playerUuid);
          if (user == null){
            errorLobbyUserNotFound();
            return;
          }
          user.framesSinceUpdate = 0;
          StringBuffer buffer = StringBuffer("${ServerResponse.Lobby_Update.index} ");
          compileLobby(buffer, lobby);
          sendToClient(buffer.toString());
          break;

        case ClientRequest.Lobby_List:
          sendToClient(compileLobbies());
          return;

        case ClientRequest.Player_Revive:
          String gameId = arguments[1];
          Game? game = gameManager.findGameById(gameId);
          if (game == null) {
            errorGameNotFound();
            return;
          }
          int id = int.parse(arguments[2]);
          Player? player = game.findPlayerById(id);
          if (player == null) {
            errorPlayerNotFound();
            return;
          }
          String uuid = arguments[3];
          if (uuid != player.uuid) {
            errorInvalidPlayerUUID();
            return;
          }
          if (player.alive) {
            error(GameError.PlayerStillAlive);
            return;
          }
          game.revive(player);
          return;

        case ClientRequest.Spawn_Npc:
          String gameId = arguments[1];
          Game? game = gameManager.findGameById(gameId);
          if (game == null) {
            errorGameNotFound();
            return;
          }
          game.spawnRandomNpc();
          return;

        case ClientRequest.Player_Equip:
          String gameId = arguments[1];
          Game? game = gameManager.findGameById(gameId);
          if (game == null) {
            errorGameNotFound();
            return;
          }
          int id = int.parse(arguments[2]);
          Player? player = game.findPlayerById(id);
          if (player == null) {
            errorPlayerNotFound();
            return;
          }
          String uuid = arguments[3];
          if (uuid != player.uuid) {
            errorInvalidPlayerUUID();
            return;
          }
          Weapon weapon = Weapon.values[int.parse(arguments[4])];
          if (player.stateDuration > 0) return;
          if (player.weapon == weapon) return;
          player.weapon = weapon;
          game.setCharacterState(player, CharacterState.ChangingWeapon);
          return;

        case ClientRequest.Lobby_Exit:
          if (arguments.length < 3) {
            errorInvalidArguments();
            return;
          }
          String lobbyUuid = arguments[1];
          Lobby? lobby = findLobbyByUuid(lobbyUuid);
          if (lobby == null) {
            errorLobbyNotFound();
            return;
          }
          String playerUuid = arguments[2];
          removePlayerFromLobby(lobby, playerUuid);
          break;

        case ClientRequest.Player_Throw_Grenade:
          String gameId = arguments[1];
          Game? game = gameManager.findGameById(gameId);
          if (game == null) {
            error(GameError.GameNotFound);
            return;
          }

          int id = int.parse(arguments[2]);
          Player? player = game.findPlayerById(id);
          if (player == null) {
            error(GameError.PlayerNotFound);
            return;
          }

          String uuid = arguments[3];
          if (uuid != player.uuid) {
            error(GameError.InvalidPlayerUUID);
            return;
          }

          if (player.grenades <= 0) return;

          double strength = double.parse(arguments[4]);
          double aim = double.parse(arguments[5]);
          game.throwGrenade(player.x, player.y, aim, strength);
          game.dispatch(GameEventType.Throw_Grenade, player.x, player.y, 0, 0);
          player.grenades--;
          return;
      }
    }

    webSocket.stream.listen(onEvent);
  });

  shelf_io.serve(handler, host, port).then((server) {
    print('Serving at wss://${server.address.host}:${server.port}');
  });
}

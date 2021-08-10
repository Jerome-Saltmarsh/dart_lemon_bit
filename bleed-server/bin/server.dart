import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'classes/Game.dart';
import 'classes.dart';
import 'compile.dart';
import 'enums/ClientRequest.dart';
import 'enums/ServerResponse.dart';
import 'enums/Weapons.dart';
import 'enums.dart';
import 'instances/gameManager.dart';
import 'settings.dart';
import 'state.dart';
import 'update.dart';
import 'utils.dart';

const String _space = " ";

void main() {
  print('Bleed Game Server Starting');
  initUpdateLoop();

  var handler = webSocketHandler((WebSocketChannel webSocket) {
    void sendToClient(String response) {
      webSocket.sink.add(response);
    }

    void sendCompiledPlayerState(Game game, Player player) {
      StringBuffer buffer = StringBuffer(game.compiled);
      compilePlayer(buffer, player);
      sendToClient(buffer.toString());
    }

    void onEvent(requestD) {
      String requestString = requestD;
      List<String> arguments = requestString.split(_space);

      if (arguments.isEmpty) {
        sendToClient('${ServerResponse.Error.index} arguments required');
        return;
      }

      int? clientRequestInt = int.tryParse(arguments[0]);
      if (clientRequestInt == null) {
        sendToClient('${ServerResponse.Error.index} client request (int) required. Received $requestString');
        return;
      }

      if (clientRequestInt >= ClientRequest.values.length) {
        sendToClient('${ServerResponse.Error.index} invalid client request int');
        return;
      }

      ClientRequest request = ClientRequest.values[clientRequestInt];

      switch (request) {
        case ClientRequest.Game_Join_Open_World:
          Player player = gameManager.openWorldGame.spawnPlayer(name: 'test');
          StringBuffer buffer = StringBuffer();
          compilePlayer(buffer, player);
          compileTiles(buffer, gameManager.openWorldGame.tiles);
          compileState(gameManager.openWorldGame);
          buffer.write(gameManager.openWorldGame.compiled);
          buffer.write('${ServerResponse.Player_Created.index} ${player.id} ${player.uuid} ${player.x.toInt()} ${player.y.toInt()} ; ');
          sendToClient(buffer.toString());
          break;

        case ClientRequest.Game_Update:
          int gameId = int.parse(arguments[1]);
          Game? game = gameManager.findGameById(gameId);
          if (game == null) {
            sendToClient('${ServerResponse.Error.index} - game-not-found');
            return;
          }
          int id = int.parse(arguments[2]);
          Player? player = game.findPlayerById(id);
          if (player == null) {
            sendToClient('${ServerResponse.Error.index} - player-not-found');
            return;
          }
          String uuid = arguments[3];
          if (uuid != player.uuid) {
            sendToClient('${ServerResponse.Error.index} : invalid-player-uuid');
            return;
          }
          player.lastEventFrame = 0;
          CharacterState requestedState = CharacterState.values[int.parse(arguments[4])];
          Direction requestedDirection =
              Direction.values[int.parse(arguments[5])];
          double aim = double.parse(arguments[6]);
          player.aimAngle = aim;
          setDirection(player, requestedDirection);
          game.setCharacterState(player, requestedState);
          sendCompiledPlayerState(game, player);
          return;

        case ClientRequest.Game_Create:
          print("ClientRequest.Game_Create");
          Game game = Game();
          generateTiles(game);
          gameManager.games.add(game);
          sendToClient('game-created ${game.id}');
          return;

        case ClientRequest.Game_Join:
          print("ClientRequest.Game_Join");
          if (arguments.length <= 1) {
            sendToClient('game-join-error: game uuid required');
            return;
          }
          int gameUuid = int.parse(arguments[1]);
          Game? game = gameManager.findGameById(gameUuid);
          if (game == null) {
            sendToClient('game-join-error: game not found: $gameUuid');
            return;
          }
          Player player = game.spawnPlayer(name: "Test");
          sendToClient(
              "game-joined ${game.id} ${player.id} ${player.uuid} ${player.x.toInt()} ${player.y.toInt()} ; ");
          return;

        case ClientRequest.Ping:
          sendToClient('${ServerResponse.Pong.index} ;');
          break;

        case ClientRequest.Player_Revive:
          int gameId = int.parse(arguments[1]);
          Game? game = gameManager.findGameById(gameId);
          if (game == null) {
            sendToClient('game-not-found ; ');
            return;
          }
          int id = int.parse(arguments[2]);
          Player? player = game.findPlayerById(id);
          if (player == null) {
            sendToClient('player-not-found ; ');
            return;
          }
          String uuid = arguments[3];
          if (uuid != player.uuid) {
            sendToClient('invalid-uuid ; ');
            return;
          }
          if (player.alive) {
            sendToClient('player-alive ;');
            return;
          }
          revive(player);
          return;

        case ClientRequest.Spawn_Npc:
        // print("received spawn npc request. Npcs: ${game.npcs.length}");
        // game.spawnRandomNpc();
          return;

        case ClientRequest.Player_Equip:
          int gameId = int.parse(arguments[1]);
          Game? game = gameManager.findGameById(gameId);
          if (game == null) {
            sendToClient('game-not-found ; ');
            return;
          }
          int id = int.parse(arguments[1]);
          Player? player = game.findPlayerById(id);
          if (player == null) {
            sendToClient('player-not-found ; ');
            return;
          }
          String uuid = arguments[2];
          if (uuid != player.uuid) {
            sendToClient('invalid-uuid ; ');
            return;
          }
          Weapon weapon = Weapon.values[int.parse(arguments[3])];
          if (player.stateDuration > 0) return;
          if (player.weapon == weapon) return;
          player.weapon = weapon;
          game.setCharacterState(player, CharacterState.ChangingWeapon);
          print('player equipped $weapon');
          return;

        case ClientRequest.Player_Throw_Grenade:
          int gameId = int.parse(arguments[1]);
          Game? game = gameManager.findGameById(gameId);
          if (game == null) {
            sendToClient('game-not-found ; ');
            return;
          }

          int id = int.parse(arguments[1]);
          Player? player = game.findPlayerById(id);
          if (player == null) {
            sendToClient('player-not-found ; ');
            return;
          }

          String uuid = arguments[2];
          if (uuid != player.uuid) {
            sendToClient('invalid-uuid ; ');
            return;
          }
          double strength = double.parse(arguments[3]);
          game.throwGrenade(player.x, player.y, player.aimAngle, strength);
          return;
      }
    }

    webSocket.stream.listen(onEvent);
  });

  shelf_io.serve(handler, host, port).then((server) {
    print('Serving at wss://${server.address.host}:${server.port}');
  });
}

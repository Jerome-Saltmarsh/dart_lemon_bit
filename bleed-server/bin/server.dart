
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'classes/Game.dart';
import 'classes.dart';
import 'classes/Inventory.dart';
import 'classes/Player.dart';
import 'compile.dart';
import 'enums/ClientRequest.dart';
import 'enums/GameError.dart';
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


void main() {
  print('Bleed Game Server Starting');
  initUpdateLoop();
  loadScenes();

  var handler = webSocketHandler((WebSocketChannel webSocket) {
    void sendToClient(String response) {
      webSocket.sink.add(response);
    }

    void sendCompiledPlayerState(Game game, Player player) {
      StringBuffer buffer = StringBuffer(game.compiled);
      compilePlayer(buffer, player);
      sendToClient(buffer.toString());
    }

    void joinGame(Game game) {
      Player player = game.spawnPlayer(name: 'test');
      StringBuffer buffer = StringBuffer();
      compilePlayer(buffer, player);
      compileTiles(buffer, game.scene.tiles);
      compileBlocks(buffer, game.scene.blocks);
      compileState(game);
      buffer.write(game.compiled);
      buffer.write(
          '${ServerResponse.Player_Created.index} ${player.id} ${player
              .uuid} ${player.x.toInt()} ${player.y.toInt()} ; ');
      sendToClient(buffer.toString());
    }

    void error(GameError error) {
      sendToClient('$errorIndex ${error.index}');
    }

    void errorGameNotFound() {
      error(GameError.GameNotFound);
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

      if (clientRequestInt >= ClientRequest.values.length) {
        error(GameError.UnrecognizedClientRequest);
        return;
      }

      ClientRequest request = ClientRequest.values[clientRequestInt];

      switch (request) {
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
          CharacterState requestedState = CharacterState.values[int.parse(
              arguments[4])];
          Direction requestedDirection = Direction.values[int.parse(
              arguments[5])];
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

          int index = player.inventory.items.indexWhere((element) => element.type == InventoryItemType.HealthPack);
          if (index == -1) return;
          player.health = player.maxHealth;
          player.inventory.items.removeAt(index);
          break;

        case ClientRequest.Game_Create:
        // print("ClientRequest.Game_Create");
        // Game game = Game(GameType.DeathMatch);
        // generateTiles(game);
        // gameManager.games.add(game);
        // sendToClient('game-created ${game.id}');
          return;

        case ClientRequest.Game_Join_Random:
          Game deathMatch = gameManager.getAvailableDeathMatch();
          joinGame(deathMatch);
          break;

      // case ClientRequest.Game_Join:
      //   if (arguments.length <= 1) {
      //     error('game uuid required');
      //     return;
      //   }
      //   String gameId = arguments[1];
      //   Game? game = gameManager.findGameById(gameId);
      //   if (game == null) {
      //     error('game not found: $gameId ;');
      //     return;
      //   }
      //   Player player = game.spawnPlayer(name: "Test");
      //   sendToClient("game-joined ${game.id} ${player.id} ${player.uuid} ${player.x.toInt()} ${player.y.toInt()} ; ");
      //   return;

        case ClientRequest.Ping:
          sendToClient('${ServerResponse.Pong.index} ;');
          break;

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
          double strength = double.parse(arguments[4]);
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

import 'package:lemon_math/diff_over.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'classes/Game.dart';
import 'classes/Inventory.dart';
import 'classes/Player.dart';
import 'classes/Weapon.dart';
import 'common/CharacterState.dart';
import 'common/enums/Direction.dart';
import 'common/version.dart';
import 'compile.dart';
import 'common/ClientRequest.dart';
import 'common/GameError.dart';
import 'common/GameEventType.dart';
import 'common/ServerResponse.dart';
import 'common/WeaponType.dart';
import 'functions/loadScenes.dart';
import 'games/world.dart';
import 'settings.dart';
import 'update.dart';
import 'utils.dart';
import 'utils/player_utils.dart';
import 'values/world.dart';

const String _space = " ";
final int errorIndex = ServerResponse.Error.index;
final StringBuffer _buffer = StringBuffer();

const List<ClientRequest> clientRequests = ClientRequest.values;
final int clientRequestsLength = clientRequests.length;

Game findGameById(String id) {
  for (Game game in world.games) {
    if (game.id == id) return game;
  }
  throw Exception();
}

Player? findPlayerById(String id) {
  for (Game game in world.games) {
    for (Player player in game.players) {
      if (player.uuid == id) {
        return player;
      }
    }
  }
  return null;
}

void main() {
  print('Bleed Game Server Starting');
  initUpdateLoop();
  loadScenes();

  int totalConnections = 0;

  var handler = webSocketHandler((WebSocketChannel webSocket) {
    totalConnections++;
    print("New connection established. Total Connections $totalConnections");

    void sendToClient(String response) {
      webSocket.sink.add(response);
    }

    void sendCompiledPlayerState(Game game, Player player) {
      _buffer.clear();
      _buffer.write(game.compiled);
      compileWeapons(_buffer, player.weapons);
      compilePlayer(_buffer, player);
      if (player.message.isNotEmpty) {
        compilePlayerMessage(_buffer, player.message);
        player.message = "";
      }
      sendToClient(_buffer.toString());
    }

    void joinGame(Game game) {
      _buffer.clear();
      Player player = spawnPlayerInTown();
      compilePlayer(_buffer, player);
      _buffer.write(
          '${ServerResponse.Game_Joined.index} ${player.id} ${player.uuid} ${player.x.toInt()} ${player.y.toInt()} ${game.id} ${player.squad} ');
      _buffer.write(game.compiledTiles);
      _buffer.write(game.compiledEnvironmentObjects);
      _buffer.write(game.compiled);
      sendToClient(_buffer.toString());
    }

    void error(GameError error, {String message = ""}) {
      sendToClient('$errorIndex ${error.index} $message');
    }

    void errorArgsExpected(int expected, List arguments) {
      sendToClient(
          '$errorIndex ${GameError.InvalidArguments.index} expected $expected but got ${arguments.length}');
    }

    void errorGameNotFound() {
      error(GameError.GameNotFound);
    }

    void errorPlayerNotFound() {
      error(GameError.PlayerNotFound);
    }

    void errorPlayerDead() {
      error(GameError.PlayerDead);
    }

    void errorInvalidPlayerUUID() {
      error(GameError.InvalidPlayerUUID);
    }

    void errorWeaponNotAcquired() {
      error(GameError.WeaponNotAcquired);
    }

    void errorWeaponAlreadyAcquired() {
      error(GameError.WeaponAlreadyAcquired);
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
        case ClientRequest.Update:
          Player? player = findPlayerById(arguments[3]);
          if (player == null) {
            errorPlayerNotFound();
            return;
          }

          player.lastUpdateFrame = 0;
          Game game = player.game;

          if (player.sceneChanged) {
            player.sceneChanged = false;
            _buffer.clear();
            _buffer.write(
                '${ServerResponse.Scene_Changed.index} ${player.x.toInt()} ${player.y.toInt()} ');
            _buffer.write(game.compiledTiles);
            _buffer.write(game.compiledEnvironmentObjects);
            _buffer.write(game.compiled);
            sendToClient(_buffer.toString());
            return;
          }

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

        case ClientRequest.Join:
          joinGame(world.town);
          break;

        case ClientRequest.Ping:
          sendToClient('${ServerResponse.Pong.index} ;');
          break;

        case ClientRequest.Revive:
          String uuid = arguments[3];
          Player? player = findPlayerById(uuid);

          if (player == null) {
            errorPlayerNotFound();
            return;
          }
          if (player.alive) {
            error(GameError.PlayerStillAlive);
            return;
          }
          player.game.revive(player);
          return;

        case ClientRequest.CasteFireball:
          Player? player = findPlayerById(arguments[3]);
          if (player == null) {
            errorPlayerNotFound();
            return;
          }
          if (player.dead) {
            errorPlayerDead();
            return;
          }
          if (player.busy) {
            return;
          }
          player.aimAngle = double.parse(arguments[4]);
          player.game.spawnFireball(player);
          return;

        case ClientRequest.Teleport:
          Player? player = findPlayerById(arguments[3]);
          if (player == null) {
            errorPlayerNotFound();
            return;
          }
          double x = double.parse(arguments[4]);
          double y = double.parse(arguments[5]);
          player.x = x;
          player.y = y;
          break;

        case ClientRequest.Equip:

          if (arguments.length < 4){
            error(GameError.InvalidArguments, message: "ClientRequest.Equip Error: Expected 4 args but got ${arguments.length}");
            return;
          }

          Player? player = findPlayerById(arguments[3]);
          if (player == null) {
            errorPlayerNotFound();
            return;
          }

          int? weaponIndex = int.tryParse(arguments[4]);
          if (weaponIndex == null){
            error(GameError.InvalidArguments, message: "arg4, weapon-index: $weaponIndex integer expected");
            return;
          }
          if (weaponIndex < 0){
            error(GameError.InvalidArguments, message: "arg4, weapon-index: $weaponIndex must be greater than 0, got ");
          }
          if (weaponIndex >= player.weapons.length){
            error(GameError.InvalidArguments, message: "arg4, weapon-index: $weaponIndex cannot be greater than player.weapons.length: ${player.weapons.length}");
          }

          changeWeapon(player, weaponIndex);
          return;

        case ClientRequest.Grenade:
          String gameId = arguments[1];
          Game? game = findGameById(gameId);
          if (game == null) {
            error(GameError.GameNotFound);
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
            error(GameError.InvalidPlayerUUID);
            return;
          }

          if (player.grenades <= 0) return;

          double strength = double.parse(arguments[4]);
          double aim = double.parse(arguments[5]);
          game.throwGrenade(player, aim, strength);
          game.dispatch(GameEventType.Throw_Grenade, player.x, player.y, 0, 0);
          player.grenades--;
          return;

        case ClientRequest.Purchase:
          return;

        case ClientRequest.SetCompilePaths:
          if (arguments.length != 5) {
            errorArgsExpected(5, arguments);
            return;
          }

          String gameId = arguments[1];
          Game? game = findGameById(gameId);
          if (game == null) {
            error(GameError.GameNotFound);
            return;
          }
          // type gameId playerId playerUuid value
          int value = int.parse(arguments[4]);
          game.compilePaths = value == 1;
          print("game.compilePaths = ${game.compilePaths}");
          break;

        case ClientRequest.Version:
          sendToClient('${ServerResponse.Version.index} $version');
          break;

        case ClientRequest.SkipHour:
          time = (time + secondsPerHour) % secondsPerDay;
          break;

        case ClientRequest.ReverseHour:
          time = (time - secondsPerHour) % secondsPerDay;
          break;

        case ClientRequest.Speak:
          String gameId = arguments[1];
          Game? game = findGameById(gameId);
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

          player.text = arguments
              .sublist(4, arguments.length)
              .fold("", (previousValue, element) => '$previousValue $element');
          player.textDuration = 150;
          break;

        case ClientRequest.Interact:
          String uuid = arguments[3];
          Player? player = findPlayerById(uuid);

          if (player == null) {
            errorPlayerNotFound();
            return;
          }
          if (player.dead) {
            errorPlayerDead();
            return;
          }

          playerInteract(player);
      }
    }

    webSocket.stream.listen(onEvent);
  });

  shelf_io.serve(handler, settings.host, settings.port).then((server) {
    print('Serving at wss://${server.address.host}:${server.port}');
  });
}

Player spawnPlayerInTown() {
  Player player = Player(
    game: world.town,
    x: 0,
    y: 1750,
    inventory: Inventory(0, 0, []),
    clips: Clips(),
    squad: 1,
    weapons: [
      Weapon(type: WeaponType.HandGun, damage: 1, capacity: 24),
      Weapon(type: WeaponType.Shotgun, damage: 1, capacity: 12)
    ]
  );
  world.town.players.add(player);
  return player;
}

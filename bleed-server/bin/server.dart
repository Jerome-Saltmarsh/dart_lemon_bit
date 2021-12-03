import 'dart:math';

import 'package:lemon_math/angle_between.dart';
import 'package:lemon_math/distance_between.dart';
import 'package:lemon_math/pi2.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'bleed/maps/ability_range.dart';
import 'classes/Character.dart';
import 'classes/Game.dart';
import 'classes/Inventory.dart';
import 'classes/Player.dart';
import 'classes/Weapon.dart';
import 'common/Ability.dart';
import 'common/CharacterAction.dart';
import 'common/CharacterState.dart';
import 'common/CharacterType.dart';
import 'common/enums/Direction.dart';
import 'common/version.dart';
import 'compile.dart';
import 'common/ClientRequest.dart';
import 'common/GameError.dart';
import 'common/GameEventType.dart';
import 'common/ServerResponse.dart';
import 'common/WeaponType.dart';
import 'functions/loadScenes.dart';
import 'functions/withinRadius.dart';
import 'games/world.dart';
import 'maths.dart';
import 'settings.dart';
import 'update.dart';
import 'utils.dart';
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

Player? findPlayerByUuid(String uuid) {
  for (Game game in world.games) {
    for (Player player in game.players) {
      if (player.uuid == uuid) {
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

    void errorInvalidArg(String message) {
      sendToClient('$errorIndex ${GameError.InvalidArguments.index} $message');
    }

    void errorArgsExpected(int expected, List arguments) {
      errorInvalidArg(
          'Invalid number of arguments received. Expected $expected but got ${arguments.length}');
    }

    void errorIntegerExpected(int index, got) {
      errorInvalidArg(
          'Invalid type at index $index, expected integer but got $got');
    }

    void errorPlayerNotFound() {
      error(GameError.PlayerNotFound);
    }

    void errorPlayerDead() {
      error(GameError.PlayerDead);
    }

    void errorInsufficientSkillPoints() {
      error(GameError.InsufficientSkillPoints);
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
          Player? player = findPlayerByUuid(arguments[1]);
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

          if (!player.busy && !player.dead) {
            CharacterAction action = characterActions[int.parse(arguments[2])];
            double mouseX = double.parse(arguments[4]);
            double mouseY = double.parse(arguments[5]);

            playerSetAbilityTarget(player, mouseX, mouseY);

            switch (action) {
              case CharacterAction.Idle:
                game.setCharacterState(player, CharacterState.Idle);
                break;
              case CharacterAction.Perform:
                Ability ability = player.ability;
                if (ability == Ability.None){
                  characterAimAt(player, mouseX, mouseY);
                  game.setCharacterState(player, CharacterState.Striking);
                  break;
                }
                player.performing = player.ability;
                game.setCharacterState(player, CharacterState.Performing);
                player.ability = Ability.None;
                break;
              case CharacterAction.Run:
                Direction direction = directions[int.parse(arguments[3])];
                setDirection(player, direction);
                game.setCharacterState(player, CharacterState.Running);
                break;
            }
          }
          sendCompiledPlayerState(game, player);
          return;

        case ClientRequest.Join:
          joinGame(world.town);
          break;

        case ClientRequest.Ping:
          sendToClient('${ServerResponse.Pong.index} ;');
          break;

        case ClientRequest.Revive:
          Player? player = findPlayerByUuid(arguments[1]);

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
          Player? player = findPlayerByUuid(arguments[1]);
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
          player.aimAngle = double.parse(arguments[2]);
          player.game.spawnFireball(player);
          return;

        case ClientRequest.SelectCharacterType:
          if (arguments.length != 3) {
            errorArgsExpected(3, arguments);
            return;
          }

          Player? player = findPlayerByUuid(arguments[1]);
          if (player == null) {
            errorPlayerNotFound();
            return;
          }

          int? characterTypeIndex = int.tryParse(arguments[2]);
          if (characterTypeIndex == null) {
            errorIntegerExpected(1, arguments[2]);
            return;
          }

          CharacterType characterType = characterTypes[characterTypeIndex];
          if (player.type != CharacterType.Human) {
            error(GameError.CharacterTypeAlreadySelected);
            break;
          }
          player.type = characterType;
          break;

        case ClientRequest.SelectAbility:
          if (arguments.length != 3) {
            errorArgsExpected(3, arguments);
            return;
          }

          Player? player = findPlayerByUuid(arguments[1]);
          if (player == null) {
            errorPlayerNotFound();
            return;
          }

          int? abilityIndex = int.tryParse(arguments[2]);

          if (abilityIndex == null){
            errorInvalidArg('arg[2] expected int but got $abilityIndex');
            return;
          }

          if (abilityIndex > maxAbilityIndex){
            errorInvalidArg('arg[2] $abilityIndex is greater than the max ability index $maxAbilityIndex');
            return;
          }

          Ability ability = abilities[abilityIndex];
          if (player.ability == ability){
            player.ability = Ability.None;
          }else{
            player.ability = ability;
          }
          break;

        case ClientRequest.AcquireAbility:
          if (arguments.length != 3) {
            errorArgsExpected(3, arguments);
            return;
          }
          Player? player = findPlayerByUuid(arguments[1]);
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
          if (player.skillPoints <= 0) {
            errorInsufficientSkillPoints();
            return;
          }

          int? weaponTypeIndex = int.tryParse(arguments[2]);
          if (weaponTypeIndex == null) {
            errorIntegerExpected(2, arguments[2]);
            return;
          }

          if (weaponTypeIndex >= weaponTypes.length) {
            errorInvalidArg(
                "WeaponType $weaponTypeIndex cannot be greater than ${weaponTypes.length}");
            return;
          }

          if (weaponTypeIndex < 0) {
            errorInvalidArg("WeaponType $weaponTypeIndex cannot be negative");
            return;
          }

          WeaponType type = weaponTypes[int.parse(arguments[2])];

          switch (type) {
            case WeaponType.Shotgun:
              player.weapons.add(
                  Weapon(type: WeaponType.Shotgun, damage: 1, capacity: 5));
              player.weaponsDirty = true;
              player.skillPoints--;
              break;

            case WeaponType.HandGun:
              player.weapons.add(
                  Weapon(type: WeaponType.HandGun, damage: 1, capacity: 5));
              player.weaponsDirty = true;
              player.skillPoints--;
              break;

            case WeaponType.Firebolt:
              player.weapons.add(
                  Weapon(type: WeaponType.Firebolt, damage: 1, capacity: 5));
              player.weaponsDirty = true;
              player.skillPoints--;
              break;
          }
          break;

        case ClientRequest.Teleport:
          Player? player = findPlayerByUuid(arguments[1]);
          if (player == null) {
            errorPlayerNotFound();
            return;
          }
          double x = double.parse(arguments[2]);
          double y = double.parse(arguments[3]);
          player.x = x;
          player.y = y;
          break;

        case ClientRequest.Equip:
          if (arguments.length < 3) {
            error(GameError.InvalidArguments,
                message:
                    "ClientRequest.Equip Error: Expected 2 args but got ${arguments.length}");
            return;
          }

          Player? player = findPlayerByUuid(arguments[1]);
          if (player == null) {
            errorPlayerNotFound();
            return;
          }

          int? weaponIndex = int.tryParse(arguments[2]);
          if (weaponIndex == null) {
            error(GameError.InvalidArguments,
                message: "arg4, weapon-index: $weaponIndex integer expected");
            return;
          }
          if (weaponIndex < 0) {
            error(GameError.InvalidArguments,
                message:
                    "arg4, weapon-index: $weaponIndex must be greater than 0, got ");
          }
          if (weaponIndex >= player.weapons.length) {
            error(GameError.InvalidArguments,
                message:
                    "arg4, weapon-index: $weaponIndex cannot be greater than player.weapons.length: ${player.weapons.length}");
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
          if (arguments.length != 2) {
            errorArgsExpected(2, arguments);
            return;
          }

          Player? player = findPlayerByUuid(arguments[1]);
          if (player == null) {
            errorPlayerNotFound();
            return;
          }

          // type gameId playerId playerUuid value
          int value = int.parse(arguments[4]);
          player.game.compilePaths = value == 1;
          print("game.compilePaths = ${player.game.compilePaths}");
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
          Player? player = findPlayerByUuid(arguments[1]);
          if (player == null) {
            errorPlayerNotFound();
            return;
          }

          player.text = arguments
              .sublist(2, arguments.length)
              .fold("", (previousValue, element) => '$previousValue $element');
          player.textDuration = 150;
          break;

        case ClientRequest.Interact:
          Player? player = findPlayerByUuid(arguments[1]);

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
      squad: 1,
      weapons: [
        Weapon(type: WeaponType.Unarmed, damage: 1, capacity: 0),
        Weapon(type: WeaponType.HandGun, damage: 1, capacity: 12),
        Weapon(type: WeaponType.Bow, damage: 3, capacity: 12),
        Weapon(type: WeaponType.SlowingCircle, damage: 3, capacity: 100),
      ]);
  player.skillPoints = 1;
  world.town.players.add(player);
  return player;
}

Player spawnPlayerInWildernessEast() {
  Player player = Player(
      game: world.wildernessEast,
      x: 0,
      y: 1750,
      inventory: Inventory(0, 0, []),
      squad: 1,
      weapons: [
        Weapon(type: WeaponType.Unarmed, damage: 1, capacity: 0),
        Weapon(type: WeaponType.HandGun, damage: 1, capacity: 12),
        Weapon(type: WeaponType.Bow, damage: 3, capacity: 12),
      ]);
  player.skillPoints = 1;
  world.wildernessEast.players.add(player);
  return player;
}
